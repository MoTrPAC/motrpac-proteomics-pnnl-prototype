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
  make_option(c("-p", "--proteomics"), type="character", default=NULL, 
              help="Proteomics experiment: pr/ph/ub/ac", metavar="character"),
  make_option(c("-i", "--msgf_output_folder"), type="character", default=NULL, 
              help="MSGF output folder", metavar="character"),
  make_option(c("-j", "--masic_output_folder"), type="character", default=NULL, 
              help="MASIC output folder", metavar="character"),
  make_option(c("-f", "--fasta_file"), type="character", default=NULL, 
              help="FASTA file (RefSeq format)", metavar="character"),
  make_option(c("-s", "--study_design_folder"), type="character", default=NULL, 
              help="Study design folder", metavar="character"),
  make_option(c("-c", "--species"), type="character", default=NULL,
              help="Full scientific name for the species (e.g. -c \"Homo sapiens\")", metavar="character")
  make_option(c("-d", "--annotation"), type="character", default=NULL,
              help="Name of Protein database (either RefSeq or UniProt)", metavar="character")
  make_option(c("-a", "--ascore_output_folder"), type="character", default=NULL, 
              help="AScore output folder", metavar="character"),
  make_option(c("-g", "--plexedpiper_global_results_ratio"), type="character", default=NULL, 
              help="PlexedPiper global results ratio table", metavar="character"),
  make_option(c("-o", "--plexedpiper_output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs)", metavar="character")
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
    is.null(opt$masic_output_folder) | 
    is.null(opt$fasta_file) |
    is.null(opt$study_design_folder) |
    is.null(opt$species) |
    is.null(opt$annotation) |
    is.null(opt$plexedpiper_output_folder)
    ) {
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



date2print <- get_date()
if(is.null(opt$plexedpiper_output_name_prefix)){
  plexedpiper_output_name_prefix <- paste0("MSGFPLUS_PR_", toupper(proteomics),"_", date2print)
}else{
  plexedpiper_output_name_prefix <- opt$plexedpiper_output_name_prefix
  plexedpiper_output_name_prefix <- paste0(plexedpiper_output_name_prefix, "_", date2print)
}

# Data loading
message("- Fetch study design tables")
study_design <- read_study_design(opt$study_design_folder)

msnid <- read_msgf_data(opt$msgf_output_folder)

ascore <- read_AScore_results(opt$ascore_output_folder)

masic_data <- read_masic_data(opt$masic_output_folder, 
                              interference_score = TRUE)

# Pipeline call
source("motrpac_pipeline.R")
out <- motrpac_pnnl_pipeline(msnid          = msnid,
                             path_to_FASTA  = opt$fasta_file,
                             masic_data     = masic_data,
                             ascore         = ascore,
                             proteomics     = tolower(opt$proteomics),
                             study_design   = study_design,
                             species        = opt$species,
                             annotation     = opt$annotation,
                             global_results = opt$plexedpiper_global_results_ratio,
                             output_folder  = opt$plexedpiper_output_folder,
                             file_prefix    = plexedpiper_output_name_prefix,
                             save_env       = FALSE,
                             verbose        = TRUE)

unlink(".Rcache", recursive=TRUE)


