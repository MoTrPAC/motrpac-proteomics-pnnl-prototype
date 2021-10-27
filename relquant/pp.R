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
if(!require("PlexedPiper", quietly = TRUE)) remotes::install_github("PNNL-Comp-Mass-Spec/PlexedPiper", build_vignettes = FALSE)

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
    )  {
  print_help(opt_parser)
  stop("5 arguments are required", call.=FALSE)
}


# To DEBUG ---------------------------------------------------------------------
# # Global
# msgf_output_folder        = "data/test_global/phrp_output"
# masic_output_folder       = "data/test_global/masic_output"
# fasta_file                = "data/ID_007275_FB1B42E8.fasta"
# study_design_folder       = "data/test_global/study_design"
# plexedpiper_output_folder = "data/test_global/plexedpiper_output300"
# To DEBUG ---------------------------------------------------------------------

msgf_output_folder        <- opt$msgf_output_folder 
masic_output_folder       <- opt$masic_output_folder 
fasta_file                <- opt$fasta_file
study_design_folder       <- opt$study_design_folder
plexedpiper_output_folder <- opt$plexedpiper_output_folder

source("R/motrpac_pipelines.R")
source("R/msgf_postprocessing.R")
source("R/data_utils.R")

message("- Load PlexedPiper inptu data")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(path_to_MSGF_results = msgf_output_folder)

message("   + Read the MASIC output")
masic_data <- read_masic_data(path_to_MASIC_results = masic_output_folder, 
                              interference_score = TRUE)

message("- Main pipeline call")
out <- motrpac_pnnl_global_pipeline(msnid               = msnid,
                                    path_to_FASTA       = fasta_file,
                                    masic_data          = masic_data,
                                    study_design_folder = study_design_folder,
                                    species             = "Rattus norvegicus",
                                    annotation          = "RefSeq",
                                    verbose             = TRUE)

message("- Save results")
save_pnnl_pipeline_results(out, plexedpiper_output_folder)

message("- Done!")
unlink(".Rcache", recursive=TRUE)


