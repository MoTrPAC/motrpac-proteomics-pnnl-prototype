#!/usr/bin/env Rscript

# Example command
# Rscript /relquant/pp.R -i /data/test_global/phrp_output \
# -j /data/test_global/masic_output \
# -f /data/ID_007275_FB1B42E8.fasta \
# -s /relquant/study_design \
# -o /relquant

# Assumed that PlexedPiper is already installed. Otherwise...
if(!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if(!require("optparse", quietly = TRUE)) install.packages("optparse")
if(!require("remotes", quietly = TRUE)) install.packages("remotes")
if(!require("PlexedPiper", quietly = TRUE)) remotes::install_github("vladpetyuk/PlexedPiper", build_vignettes = FALSE)

suppressWarnings(library(optparse))
suppressWarnings(library(dplyr))
suppressWarnings(library(PlexedPiper))

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
              help="PlexedPiper output folder (Crosstabs)", metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$msgf_output_folder) | 
    is.null(opt$masic_output_folder) | 
    is.null(opt$fasta_file) |
    is.null(opt$study_design_folder) |
    is.null(opt$plexedpiper_output_folder)
    ){
  print_help(opt_parser)
  stop("5 arguments are required", call.=FALSE)
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
fasta_file<- opt$fasta_file
study_design_folder<- opt$study_design_folder
plexedpiper_output_folder<- opt$plexedpiper_output_folder

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
msnid <- compute_protein_coverage(msnid, path_to_FASTA = fasta_file)

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
masic_data <- read_masic_data(path_to_MASIC_results = masic_output_folder, 
                              interference_score = TRUE)

if (!setequal(fractions$Dataset, masic_data$Dataset)) {
  stop("Datasets in MASIC output and 'fractions.txt' do not match!")
}

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


message("- Create Reporter Ion Intensity Results")
rii_peptide <- make_rii_peptide_gl(msnid = msnid, 
                                   masic_data = masic_data, 
                                   fractions = fractions, 
                                   samples = samples, 
                                   references = references, 
                                   org_name = "Rattus norvegicus")

message("- Create Ratio Results")
ratio_results <- make_results_ratio_gl(msnid =  msnid, 
                                       masic_data = masic_data, 
                                       fractions = fractions, 
                                       samples = samples, 
                                       references = references, 
                                       org_name = "Rattus norvegicus")

message("- Save results")

if(!dir.exists(file.path(plexedpiper_output_folder))){
  dir.create(file.path(plexedpiper_output_folder), recursive = TRUE)
}

write.table(rii_peptide,
            file = paste(plexedpiper_output_folder, "results_RII-peptide.txt", sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

write.table(ratio_results,
            file = paste(plexedpiper_output_folder, "results_ratio.txt", sep="/"),
            sep="\t",
            row.names = FALSE,
            quote = FALSE)

message("- Done!")

unlink(".Rcache", recursive=TRUE)


