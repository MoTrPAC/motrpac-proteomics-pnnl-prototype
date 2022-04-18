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
              help="Full scientific name for the species (e.g. -c \"Homo sapiens\")", metavar="character"),
  make_option(c("-d", "--annotation"), type="character", default=NULL,
              help="Name of Protein database (either RefSeq or UniProt)", metavar="character"),
  make_option(c("-a", "--ascore_output_folder"), type="character", default=NULL, 
              help="AScore output folder", metavar="character"),
  make_option(c("-g", "--plexedpiper_global_results_ratio"), type="character", default=NULL, 
              help="PlexedPiper global results ratio table", metavar="character"),
  make_option(c("-o", "--plexedpiper_output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs)", metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
message("+ PlexedPiper version: ", paste(packageVersion("PlexedPiper")))

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


# Let's make easy debugging
proteomics <- opt$proteomics
study_design_folder <- opt$study_design_folder
pp_output_name_prefix <- opt$pp_output_name_prefix
study_design_folder <- opt$study_design_folder
msgf_output_folder <- opt$msgf_output_folder
ascore_output_folder <- opt$ascore_output_folder
masic_output_folder <- opt$masic_output_folder
species <- opt$species
annotation <- opt$annotation
plexedpiper_global_results_ratio <- opt$plexedpiper_global_results_ratio
plexedpiper_output_folder <- opt$plexedpiper_output_folder
fasta_file <- opt$fasta_file

get_date <- function(){
  date2print <- Sys.time()
  date2print <- gsub("-", "", date2print)
  date2print <- gsub(" ", "_", date2print)
  date2print <- gsub(":", "", date2print)
  return(date2print)
}

date2print <- get_date()
if(is.null(pp_output_name_prefix)){
  pp_output_name_prefix <- paste0("MSGFPLUS_", toupper(proteomics),"-", date2print)  
}else{
  pp_output_name_prefix <- paste0(pp_output_name_prefix, "-", date2print)
}

if(!is.null(plexedpiper_global_results_ratio)){
  pp_output_name_prefix <- paste0(pp_output_name_prefix,"-ip")
}

# Pipeline call
results <- run_plexedpiper(msgf_output_folder = msgf_output_folder,
                           fasta_file  = fasta_file,
                           masic_output_folder = masic_output_folder,
                           ascore_output_folder = ascore_output_folder,
                           proteomics = tolower(proteomics),
                           study_design_folder = study_design_folder,
                           species = species,
                           annotation = annotation,
                           global_results = plexedpiper_global_results_ratio,
                           output_folder = plexedpiper_output_folder,
                           file_prefix = pp_output_name_prefix,
                           write_results_to_file = TRUE,
                           save_env = TRUE,
                           return_results = TRUE,
                           verbose = TRUE)


unlink(".Rcache", recursive=TRUE)
