#!/usr/bin/env Rscript

# Assumed that PlexedPiper is already installed. Otherwise...
# if(!require("dplyr", quietly = TRUE)) install.packages("dplyr")
# if(!require("optparse", quietly = TRUE)) install.packages("optparse")
# if(!require("remotes", quietly = TRUE)) install.packages("remotes")
# if(!require("PlexedPiper", quietly = TRUE)) remotes::install_github("vladpetyuk/PlexedPiper", build_vignettes = FALSE)

suppressPackageStartupMessages(suppressWarnings(library(optparse)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))
suppressPackageStartupMessages(suppressWarnings(library(PlexedPiper)))

option_list <- list(
  make_option(c("-i", "--msgf_output_folder"), type="character", default=NULL, 
              help="MSGF output folder", metavar="character"),
  make_option(c("-j", "--masic_output_folder"), type="character", default=NULL, 
              help="MASIC output folder", metavar="character"),
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

if (is.null(opt$msgf_output_folder) | 
    is.null(opt$masic_output_folder) | 
    is.null(opt$fasta_file) |
    is.null(opt$study_design_folder) |
    is.null(opt$plexedpiper_output_folder) | 
    is.null(opt$species)
    ){
  print_help(opt_parser)
  stop("Required arguments are missed", call.=FALSE)
}


# To DEBUG ---------------------------------------------------------------------
# # Global
# msgf_output_folder = "data/test_global/phrp_output"
# masic_output_folder = "data/test_global/masic_output"
# fasta_file = "data/ID_007275_FB1B42E8.fasta"
# study_design_folder = "data/test_global/study_design"
# plexedpiper_output_folder = "data/test_global/plexedpiper_output300"
# To DEBUG ---------------------------------------------------------------------

msgf_output_folder <- opt$msgf_output_folder 
masic_output_folder <- opt$masic_output_folder 
fasta_file <- opt$fasta_file
study_design_folder <- opt$study_design_folder
plexedpiper_output_folder <- opt$plexedpiper_output_folder
species <- opt$species

date2print <- get_date()
if(is.null(opt$plexedpiper_output_name_prefix)){
  plexedpiper_output_name_prefix <- paste0("MSGFPLUS_PR_", toupper(proteomics),"_", date2print)
}else{
  plexedpiper_output_name_prefix <- opt$plexedpiper_output_name_prefix
  plexedpiper_output_name_prefix <- paste0(plexedpiper_output_name_prefix, "_", date2print)
}

message("- Fetch study design tables")
study_design <- read_study_design(study_design_folder)

fractions  <- study_design$fractions
samples    <- study_design$samples
references <- study_design$references


message("- Prepare MS/MS IDs")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(path_to_MSGF_results = msgf_output_folder)

if (!setequal(fractions$Dataset, msnid$Dataset)) {
  stop("Datasets in MS-GF+ output and 'fractions.txt' do not match!")
}

message("   + Correct for isotope selection error")
msnid <- correct_peak_selection(msnid)

message("   + MS/MS ID filter and peptide level")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("   + MS/MS ID filter at protein level")
msnid <- compute_num_peptides_per_1000aa(msnid, 
                                         path_to_FASTA = fasta_file)

msnid <- filter_msgf_data_protein_level(msnid, 0.01)

message("   + Remove decoy accessions")
msnid <- apply_filter(msnid, "!isDecoy")

message("   + Concatenating redundant RefSeq matches")
msnid <- assess_redundant_protein_matches(msnid)

message("   + Assessing non-inferable proteins")
msnid <- assess_noninferable_proteins(msnid)

message("   + Inference of parsimonious protein set")
msnid <- infer_parsimonious_accessions(msnid)

message("   + Compute protein coverage")
suppressMessages(
  fst <- Biostrings::readAAStringSet(fasta_file)
)
names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))
msnid <- compute_accession_coverage(msnid, fst)

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
masic_data <- read_masic_data(path_to_MASIC_results = masic_output_folder, 
                              interference_score = TRUE)

if (!setequal(fractions$Dataset, masic_data$Dataset)) {
  stop("Datasets in MASIC output and 'fractions.txt' do not match!")
}

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


message("   + Generate RII peptide. ", appendLF = FALSE)
rii_peptide <- suppressMessages(
  suppressPackageStartupMessages(
    suppressWarnings(
      make_rii_peptide_gl(msnid = msnid, 
                          masic_data = masic_data, 
                          fractions = fractions, 
                          samples = samples, 
                          references = references, 
                          org_name = species)
    )
  )
)
message("Total number of unique protein_id: ", length(unique(rii_peptide$protein_id)))

message("   + Make results ratio.", appendLF = FALSE)
results_ratio <- suppressMessages(
  suppressPackageStartupMessages(
    suppressWarnings(
      make_results_ratio_gl(msnid =  msnid, 
                            masic_data = masic_data, 
                            fractions = fractions, 
                            samples = samples, 
                            references = references, 
                            org_name = species)
    )
  )
)
message("Total number of unique protein_id: ", length(unique(results_ratio$protein_id)))

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


