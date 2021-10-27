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

if(!( proteomics %in% c("pr", "ph", "ac", "ub"))){
  stop("The < proteomics > variable is not correct. Accepted values: ph, pr, ac, ub")
}else{
  message("- Proteomics experiment: ", proteomics)
}

source("R/motrpac_pipelines.R")
source("R/msgf_postprocessing.R")
source("R/data_utils.R")

message("- Load PlexedPiper inptu data")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(msgf_output_folder)

message("   + Read the AScore output")
ascore <- PlexedPiper:::collate_files(ascore_output_folder, "_syn_ascore.txt")

message("   + Read the MASIC output")
masic_data <- read_masic_data(masic_output_folder, interference_score=TRUE)

message("- Main pipeline call")
out <- motrpac_pnnl_ptm_pipeline(msnid, fasta_file,
                                 masic_data, ascore,
                                 proteomics,
                                 study_design_folder,
                                 species, annotation,
                                 global_results = NULL,
                                 verbose = TRUE)
  
message("- Save results")
save_pnnl_pipeline_results(out, plexedpiper_output_folder)

message("- Done!")
unlink(".Rcache", recursive=TRUE)
