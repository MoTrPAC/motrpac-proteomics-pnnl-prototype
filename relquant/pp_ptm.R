#!/usr/bin/env Rscript

suppressMessages(suppressWarnings(library(optparse)))

option_list <- list(
  make_option(c("-p", "--proteomics"), type="character", default=NULL, 
              help="Proteomics experiment: ph/ub/ac", metavar="character"),
  make_option(c("-i", "--msgf_output_folder"), type="character", default=NULL, 
              help="MSGF output folder", metavar="character"),
  make_option(c("-a", "--ascore_output_folder"), type="character", default=NULL, 
              help="AScore output folder", metavar="character"),
  make_option(c("-j", "--masic_output_folder"), type="character", default=NULL, 
              help="MASIC output folder", metavar="character"),
  make_option(c("-g", "--plexedpiper_global_results_ratio"), type="character", default=NULL, 
              help="PlexedPiper global results ratio table", metavar="character"),
  make_option(c("-f", "--fasta_file"), type="character", default=NULL, 
              help="FASTA file (RefSeq format)", metavar="character"),
  make_option(c("-s", "--study_design_folder"), type="character", default=NULL, 
              help="Study design folder", metavar="character"),
  make_option(c("-o", "--plexedpiper_output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs)", metavar="character"),
  make_option(c("-n", "--plexedpiper_output_name_prefix"), type="character", default=NULL,
              help="PlexedPiper output folder (Crosstabs)", metavar="character"),
  make_option(c("-c", "--species"), type="character", default=NULL,
              help="Full scientific name for the species (e.g. -c \"Homo sapiens\")", metavar="character")
)

get_date <- function(){
  # GET QC_DATE----
  date2print <- Sys.time()
  date2print <- gsub("-", "", date2print)
  date2print <- gsub(" ", "_", date2print)
  date2print <- gsub(":", "", date2print)
  return(date2print)
}

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$proteomics) | 
    is.null(opt$msgf_output_folder) | 
    is.null(opt$ascore_output_folder) | 
    is.null(opt$masic_output_folder) | 
    is.null(opt$fasta_file) |
    is.null(opt$study_design_folder) |
    is.null(opt$plexedpiper_output_folder) |
    is.null(opt$species)
){
  print_help(opt_parser)
  stop("Required arguments are missed", call.=FALSE)
}

message("\n- Load required libraries")
suppressMessages(suppressWarnings(library(dplyr)))
suppressMessages(suppressWarnings(library(PlexedPiper)))

# To DEBUG ---------------------------------------------------------------------

# proteomics = "ph"
# msgf_output_folder = "out_phpr/"
# ascore_output_folder = "out_ascore/"
# masic_output_folder = "out_masic/"
# fasta_file = "ID_007275_FB1B42E8.fasta"
# study_design_folder = "study_design"
# plexedpiper_output_folder = "pp_output"
# species = "Rattus novergicus"

# proteomics = "ac"
# msgf_output_folder = "data/test_acetyl/phrp_output/"
# ascore_output_folder = "data/test_acetyl//ascore_output/"
# masic_output_folder = "data/test_acetyl/masic_output"
# fasta_file = "data/ID_007275_FB1B42E8.fasta"
# study_design_folder = "data/test_acetyl/study_design"
# plexedpiper_output_folder = "data/test_acetyl/plexedpiper_output"

# To DEBUG ---------------------------------------------------------------------

proteomics <- tolower(opt$proteomics)
msgf_output_folder <- opt$msgf_output_folder 
ascore_output_folder <- opt$ascore_output_folder 
masic_output_folder <- opt$masic_output_folder 
plexedpiper_global_results_ratio <- opt$plexedpiper_global_results_ratio
fasta_file <- opt$fasta_file
study_design_folder <- opt$study_design_folder
plexedpiper_output_folder <- opt$plexedpiper_output_folder
species <- opt$species

date2print <- get_date()
if(is.null(opt$plexedpiper_output_name_prefix)){
  plexedpiper_output_name_prefix <- paste0("MSGFPLUS_", toupper(proteomics),"_", date2print)
}else{
  plexedpiper_output_name_prefix <- opt$plexedpiper_output_name_prefix
  plexedpiper_output_name_prefix <- paste0(plexedpiper_output_name_prefix, "_", date2print)
}

ptms <- c("ph", "ac", "ub")
if(!( proteomics %in% ptms)){
  stop("The < proteomics > variable is not correct. Accepted values: ", paste(ptms, collapse = ", "))
}else{
  message("- Proteomics experiment: ", proteomics)
}

message("- Fetch study design tables")
study_design <- read_study_design(study_design_folder)

fractions <- study_design$fractions

samples <- study_design$samples

references <- study_design$references

message("- Prepare MS/MS IDs")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(msgf_output_folder)

if (!setequal(fractions$Dataset, msnid$Dataset)) {
  stop("Datasets in MS-GF+ output and 'fractions.txt' do not match!")
}

message("   + Read Ascore output")
ascore <- read_AScore_results(ascore_output_folder)

message("   + Select best PTM location by AScore")
msnid <- best_PTM_location_by_ascore(msnid, ascore)

message("   + Apply PTM filter")
if (proteomics == "ph") {
  msnid <- apply_filter(msnid, "grepl(\"\\\\*\", peptide)")
} else if(proteomics %in% c("ac", "ub")) {
  msnid <- apply_filter(msnid, "grepl(\"\\\\#\", peptide)")
} else {
  stop("proteomics variable not supported")
}

message("   + FDR filter")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("   + Remove decoy sequences")
msnid <- apply_filter(msnid, "!isDecoy")

message("   + Concatenating redundant RefSeq matches")
msnid <- assess_redundant_protein_matches(msnid)

message("   + Assessing non-inferable proteins")
msnid <- assess_noninferable_proteins(msnid)

message("   + Inference of parsimonius set")

if (is.null(plexedpiper_global_results_ratio)) {
  message("     > Reference global proteomics dataset NOT provided")
  msnid <- infer_parsimonious_accessions(msnid)
} else {
  message("     > Global proteomics results provided: PROTEIN IDS will be used to infer parsimonious as prior")
  global_results_ratio <- read.table(plexedpiper_global_results_ratio, header=T, sep="\t")
  global_protein_ids <- unique(global_results_ratio$protein_id)
  msnid <- infer_parsimonious_accessions(msnid, prior=global_protein_ids)
}

message("   + Mapping sites to protein sequence")
suppressMessages(
  fst <- Biostrings::readAAStringSet(fasta_file)
  )
names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))

if(proteomics == "ph") {
  msnid <- map_mod_sites(msnid, 
                         fst, 
                         accession_col = "accession", 
                         peptide_mod_col = "peptide", 
                         mod_char = "*",
                         site_delimiter = "lower")
} else if (proteomics %in% c("ac", "ub")) {
  msnid <- map_mod_sites(msnid, 
                         fst, 
                         accession_col = "accession", 
                         peptide_mod_col = "peptide", 
                         mod_char = "#",
                         site_delimiter = "lower")
} else {
  stop("proteomics variable not supported")
}


message("   + Map flanking sequences")
msnid <- extract_sequence_window(msnid, fst)

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

if (!setequal(fractions$Dataset, masic_data$Dataset)) {
  stop("Datasets in MASIC output and 'fractions.txt' do not match!")
}

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


# NEW----------------------------------------------------------------------
message("   + Generate results ratio.", appendLF = FALSE)
results_ratio <- suppressMessages(
  suppressPackageStartupMessages(
    suppressWarnings(
      make_results_ratio_ph(msnid, 
                            masic_data, 
                            fractions, 
                            samples,
                            references, 
                            org_name = species)
    )
  )
)

message("Total number of unique ptm_ids: ", length(unique(results_ratio$ptm_id)))
                                                                                                        
message("   + Generate RII peptide. ", appendLF = FALSE)
rii_peptide <- suppressMessages(
  suppressPackageStartupMessages(
    suppressWarnings(
      make_rii_peptide_ph(msnid, 
                          masic_data, 
                          fractions, 
                          samples,
                          references, 
                          org_name = species)
    )))

message("Total number of unique ptm_ids: ", length(unique(rii_peptide$ptm_id)))

message("- Save results")

if(!dir.exists(file.path(plexedpiper_output_folder))){
  dir.create(file.path(plexedpiper_output_folder), recursive = TRUE)
}

file_rii <- paste0(plexedpiper_output_name_prefix, "_results_RII-peptide.txt")
file_ratio <- paste0(plexedpiper_output_name_prefix, "_results_ratio.txt")
write.table(rii_peptide,
            file = paste(plexedpiper_output_folder, file_rii, sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

write.table(results_ratio,
            file = paste(plexedpiper_output_folder, file_ratio, sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

message("- Done!")


unlink(".Rcache", recursive=TRUE)
