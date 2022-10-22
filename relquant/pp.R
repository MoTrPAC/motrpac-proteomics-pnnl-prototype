#!/usr/bin/env Rscript

suppressPackageStartupMessages(suppressWarnings(library(optparse)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))
suppressPackageStartupMessages(suppressWarnings(library(PlexedPiper)))

option_list <- list(
  make_option(c("-p", "--proteomics_experiment"),
              type = "character",
              default = NULL,
              help = "Proteomics experiment: pr/ph/ub/ac",
              metavar = "character"),
  make_option(c("-i", "--msgf_output_folder"), type = "character", default = NULL, 
              help = "MSGF output folder", metavar = "character"),
  make_option(c("-j", "--masic_output_folder"), type = "character", default = NULL, 
              help = "MASIC output folder", metavar = "character"),
  make_option(c("-f", "--fasta_file"), type = "character", default = NULL, 
              help = "FASTA file (RefSeq format)", metavar = "character"),
  make_option(c("-s", "--study_design_folder"), type = "character", default = NULL, 
              help = "Study design folder", metavar = "character"),
  make_option(c("-c", "--species"), type = "character", default = NULL,
              help = "Full scientific name for the species (e.g. -c \"Homo sapiens\")", metavar = "character"),
  make_option(c("-d", "--annotation"), type = "character", default = NULL,
              help = "Name of Protein database (either RefSeq or UniProt)", metavar = "character"),
  make_option(c("-a", "--ascore_output_folder"), type = "character", default = NULL, 
              help = "PTM only: AScore output folder", metavar = "character"),
  make_option(c("-u", "--unique_only"), type = "character", default = FALSE, 
              help = "Whether to discard peptides that match multiple proteins in the 
              parsimonious protein inference step. It would ignore arguments -g and -r. Default: FALSE", metavar = "logical"),
  make_option(c("-g", "--plexedpiper_global_results_ratio"), type = "character", default = NULL, 
              help = "if prior, then provided global results ratio table", metavar = "character"),
  make_option(c("-r", "--refine_prior"), type = "logical", default = TRUE, 
              help = "Peptides are allowed to match multiple proteins in the prior. 
              That is, the greedy set cover algorithm is only applied to the set 
              of proteins not in the prior. If TRUE, the algorithm is applied 
              to the prior and non-prior sets separately before combining", metavar = "logical"),
  make_option(c("-n", "--results_prefix"), type = "character", default = NULL, 
              help = "Prefix for the result output files", metavar = "character"),
  make_option(c("-o", "--plexedpiper_output_folder"), type = "character", default = NULL, 
              help = "PlexedPiper output folder (Crosstabs)", metavar = "character"),
  make_option(c("-v", "--save_env"), type = "logical", default = FALSE, 
              help = "Save PP R env session", metavar = "logical")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
message("+ PlexedPiper version: ", paste(packageVersion("PlexedPiper")))

if (is.null(opt$proteomics_experiment) ||
    is.null(opt$msgf_output_folder) ||
    is.null(opt$masic_output_folder) ||
    is.null(opt$fasta_file) ||
    is.null(opt$study_design_folder) ||
    is.null(opt$species) ||
    is.null(opt$annotation) ||
    is.null(opt$plexedpiper_output_folder)) {
  print_help(opt_parser)
  stop("Required arguments are missed", call. = FALSE)
}


# Let's make easy debugging
proteomics_experiment <- opt$proteomics_experiment
study_design_folder <- opt$study_design_folder
results_prefix <- opt$results_prefix
study_design_folder <- opt$study_design_folder
msgf_output_folder <- opt$msgf_output_folder
ascore_output_folder <- opt$ascore_output_folder
masic_output_folder <- opt$masic_output_folder
species <- opt$species
annotation <- opt$annotation
plexedpiper_global_results_ratio <- opt$plexedpiper_global_results_ratio
plexedpiper_output_folder <- opt$plexedpiper_output_folder
fasta_file <- opt$fasta_file
unique_only <- opt$unique_only
refine_prior <- opt$refine_prior
save_env <- opt$save_env

if(refine_prior) {
  message("+ Refine Prior is set to ", refine_prior)
}

message("+ Unique only is: ", unique_only)

get_date <- function() {
  date2print <- Sys.time()
  date2print <- gsub("-", "", date2print)
  date2print <- gsub(" ", "_", date2print)
  date2print <- gsub(":", "", date2print)
  return(date2print)
}

date2print <- get_date()
if(is.null(results_prefix)) {
  results_prefix <- paste0("MSGFPLUS_", toupper(proteomics_experiment),"-", date2print)  
}else{
  results_prefix <- paste0(results_prefix, "-", date2print)
}


if(!is.null(plexedpiper_global_results_ratio)){
  # Check file name of the file
  if(plexedpiper_global_results_ratio == "no-prior"){
    plexedpiper_global_results_ratio = NULL
  }else{
    results_prefix <- paste0(results_prefix,"-ip")
  }
}

# Pipeline call
results <- run_plexedpiper(msgf_output_folder = msgf_output_folder,
                           fasta_file  = fasta_file,
                           masic_output_folder = masic_output_folder,
                           ascore_output_folder = ascore_output_folder,
                           proteomics = tolower(proteomics_experiment),
                           study_design_folder = study_design_folder,
                           species = species,
                           annotation = annotation,
                           global_results = plexedpiper_global_results_ratio,
                           refine_prior = refine_prior,
                           unique_only = unique_only,
                           output_folder = plexedpiper_output_folder,
                           file_prefix = results_prefix,
                           write_results_to_file = TRUE,
                           save_env = save_env,
                           return_results = TRUE,
                           verbose = TRUE)

# Create a barplot using ggplot with the results output and save it to a pdf file





unlink(".Rcache", recursive=TRUE)
