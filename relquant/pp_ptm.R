#!/usr/bin/env Rscript

# Example command
# Rscript relquant/pp_ptm.R \
# -p ph \
# -i data/test_phospho/phrp_output/ \
# -a data/test_phospho/ascore_output/ \
# -j data/test_phospho/masic_output/ \
# -f data/ID_007275_FB1B42E8.fasta \
# -s data/test_phospho/study_design/ \
# -o data/test_phospho/plexedpiper_output/

# Assumed that PlexedPiper is already installed. Otherwise...
if(!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if(!require("optparse", quietly = TRUE)) install.packages("optparse")
if(!require("remotes", quietly = TRUE)) install.packages("remotes")
if(!require("PlexedPiper", quietly = TRUE)) remotes::install_github("vladpetyuk/PlexedPiper", build_vignettes = FALSE)


message("\n- Load required libraries")

suppressMessages(suppressWarnings(library(optparse)))
suppressMessages(suppressWarnings(library(dplyr)))
suppressMessages(suppressWarnings(library(PlexedPiper)))


option_list <- list(
  make_option(c("-p", "--proteomics"), type="character", default=NULL, 
              help="Proteomics experiment: pr/ph/ub/ac", metavar="character"),
  make_option(c("-i", "--msgf_output_folder"), type="character", default=NULL, 
              help="MSGF output folder", metavar="character"),
  make_option(c("-a", "--ascore_output_folder"), type="character", default=NULL, 
              help="AScore output folder", metavar="character"),
  make_option(c("-j", "--masic_output_folder"), type="character", default=NULL, 
              help="MASIC output folder", metavar="character"),
  make_option(c("-f", "--fasta_file"), type="character", default=NULL, 
              help="FASTA file (RefSeq format)", metavar="character"),
  make_option(c("-s", "--study_design_folder"), type="character", default=NULL, 
              help="Study design folder", metavar="character"),
  make_option(c("-o", "--plexedpiper_output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs)", metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$proteomics) | 
    is.null(opt$msgf_output_folder) | 
    is.null(opt$ascore_output_folder) | 
    is.null(opt$masic_output_folder) | 
    is.null(opt$fasta_file) |
    is.null(opt$study_design_folder) |
    is.null(opt$plexedpiper_output_folder)
){
  print_help(opt_parser)
  stop("7 arguments are required", call.=FALSE)
}

proteomics <- tolower(opt$proteomics)
msgf_output_folder <- opt$msgf_output_folder 
ascore_output_folder <- opt$ascore_output_folder 
masic_output_folder <- opt$masic_output_folder 
fasta_file<- opt$fasta_file
study_design_folder<- opt$study_design_folder
plexedpiper_output_folder<- opt$plexedpiper_output_folder

# To DEBUG ---------------------------------------------------------------------

# proteomics = "ph"
# msgf_output_folder = "out_phpr/"
# ascore_output_folder = "out_ascore/"
# masic_output_folder = "out_masic/"
# fasta_file = "ID_007275_FB1B42E8.fasta"
# study_design_folder = "study_design"
# plexedpiper_output_folder = "pp_output"

# proteomics = "ac"
# msgf_output_folder = "data/test_acetyl/phrp_output/"
# ascore_output_folder = "data/test_acetyl//ascore_output/"
# masic_output_folder = "data/test_acetyl/masic_output"
# fasta_file = "data/ID_007275_FB1B42E8.fasta"
# study_design_folder = "data/test_acetyl/study_design"
# plexedpiper_output_folder = "data/test_acetyl/plexedpiper_output"

# To DEBUG ---------------------------------------------------------------------

if(!( proteomics %in% c('pr', 'ph', 'ac', 'ub'))){
  stop("The < proteomics > variable is not correct. Accepted values: ph, pr, ac, ub")
}else{
  message("- Proteomics experiment: ", proteomics)
}

message("- Fetch study design tables")
message("   + Read fractions.txt")
fractions <- read.delim(paste(study_design_folder,"fractions.txt",sep="/"), 
                        stringsAsFactors = FALSE,
                        colClasses = "character")

message("   + Read samples.txt")
samples <- read.delim(paste(study_design_folder,"samples.txt",sep="/"), 
                      stringsAsFactors = FALSE,
                      colClasses = "character")

message("   + Read references.txt")
references <- read.delim(paste(study_design_folder,"references.txt",sep="/"), 
                         stringsAsFactors = FALSE,
                         colClasses = "character")

message("- Prepare MS/MS IDs")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(msgf_output_folder, "_syn.txt")

message("   + Read Ascore output")
ascore <- PlexedPiper:::collate_files(ascore_output_folder, "_syn_ascore.txt")

msnid <- best_PTM_location_by_ascore(msnid, ascore)

if(proteomics == "ph"){
  msnid <- apply_filter(msnid, "grepl(\"\\\\*\", peptide)")
}else if(proteomics %in% c('ac', 'ub')){
  msnid <- apply_filter(msnid, "grepl(\"\\\\#\", peptide)")
}else{
  stop("proteomics variable not supported")
}

message("   + FDR filter")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("   + Inference of parsimonius set")
msnid <- infer_parsimonious_accessions(msnid)

message("   + Mapping sites to protein sequence")
suppressMessages(
  fst <- Biostrings::readAAStringSet(fasta_file)
  )
names(fst) <- sub("^([A-Z]P_\\d+\\.\\d+)\\s.*", "\\1", names(fst))

if(proteomics == "ph"){
  msnid <- map_mod_sites(msnid, 
                         fst, 
                         accession_col = "accession", 
                         peptide_mod_col = "Peptide", 
                         mod_char = "*",
                         site_delimiter = "lower")
}else if(proteins %in% c('ac', 'ub')){
  msnid <- map_mod_sites(msnid, 
                         fst, 
                         accession_col = "accession", 
                         peptide_mod_col = "Peptide", 
                         mod_char = "#",
                         site_delimiter = "lower")
}else{
  stop("proteomics variable not supported")
}


message("   + Remove decoy sequences")
msnid <- apply_filter(msnid, "!isDecoy")

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


# NEW----------------------------------------------------------------------
results_ratio <- make_results_ratio_ph(msnid, 
                                       masic_data, 
                                       fractions, 
                                       samples,
                                       references, 
                                       org_name = "Rattus norvegicus")


rii_peptide <- make_rii_peptide_ph(msnid, 
                                   masic_data, 
                                   fractions, 
                                   samples,
                                   references, 
                                   org_name = "Rattus norvegicus")
# NEW----------------------------------------------------------------------

message("- Save results")

if(!dir.exists(file.path(plexedpiper_output_folder))){
  dir.create(file.path(plexedpiper_output_folder), recursive = TRUE)
}

write.table(rii_peptide,
            file = paste(plexedpiper_output_folder, "results_RII-peptide.txt", sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

write.table(results_ratio,
            file = paste(plexedpiper_output_folder, "results_ratio.txt", sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

message("- Done!")


unlink(".Rcache", recursive=TRUE)
