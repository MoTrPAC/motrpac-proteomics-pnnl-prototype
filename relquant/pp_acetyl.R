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

suppressWarnings(library(PlexedPiper))
library(optparse)
library(dplyr)

# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/

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

message("- Prepare MS/MS IDs")
message("   + Read the MS-GF+ output")
msnid <- read_msgf_data(opt$msgf_output_folder, suffix = "_syn.txt")

message("   + Correct for isotope selection error")
msnid <- correct_peak_selection(msnid)

message("   + MS/MS ID filter and peptide level")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("   + Switching annotation from RefSeq to gene symbols")
msnid <- remap_accessions_refseq_to_gene(msnid, 
                                         organism_name="Rattus norvegicus")

message("   + Loading fasta file")

path_to_FASTA_gene <- remap_accessions_refseq_to_gene_fasta(path_to_FASTA = opt$fasta_file ,
                                                            organism_name = "Rattus norvegicus")

message("   + MS/MS ID filter at protein level")
msnid <- compute_num_peptides_per_1000aa(msnid, path_to_FASTA_gene)
msnid <- filter_msgf_data_protein_level(msnid, 0.01)

message("   + Inference of parsimonious protein set")
msnid <- infer_parsimonious_accessions(msnid, unique_only=TRUE)

message("   + Remove decoy accessions")
msnid <- apply_filter(msnid, "!isDecoy")

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- opt$masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


message("- Fetch study design tables")
message("   + Read fractions.txt")
fractions <- read.table(paste(opt$study_design_folder,"fractions.txt",sep="/"),
                        stringsAsFactors = FALSE)

message("   + Read samples.txt")
samples <- read.table(paste(opt$study_design_folder,"samples.txt",sep="/"),
                      stringsAsFactors = FALSE)

message("   + Read reference.txt")
references <- read.table(paste(opt$study_design_folder,"references.txt",sep="/"),
                         stringsAsFactors = FALSE)

message("- Create quantitative crosstab")
aggregation_level <- c("accession")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)

quant_cross_tab <- signif(quant_cross_tab, 3)
quant_cross_tab <- data.frame(Protein = row.names(quant_cross_tab), quant_cross_tab)
row.names(quant_cross_tab) <- NULL

message("- Save crosstab to file")

if(!dir.exists(file.path(opt$plexedpiper_output_folder))){
  dir.create(file.path(opt$plexedpiper_output_folder), recursive = TRUE)
}
  
write.table(quant_cross_tab,
            file=paste(opt$plexedpiper_output_folder,"quant_crosstab_global.txt",sep="/"),
            quote = FALSE, 
            sep="\t",
            row.names = FALSE)

message("- Create RII")
samples_rii <- samples %>%
  mutate(MeasurementName = case_when(is.na(MeasurementName) ~ "ref",
                                    TRUE ~ MeasurementName)) %>%
  mutate(MeasurementName = paste0(MeasurementName,"",PlexID))

references_rii <- references %>%
  mutate(Reference = 1)
  
quant_cross_tab_rii <- create_crosstab(msnid, 
                                       masic_data, 
                                       aggregation_level, 
                                       fractions, samples_rii, references_rii)

quant_cross_tab_rii <- 2**quant_cross_tab_rii
quant_cross_tab <- data.frame(Protein = row.names(quant_cross_tab), quant_cross_tab)
row.names(quant_cross_tab) <- NULL

message("- Save RII to file")

write.table(quant_cross_tab_rii,
            file=paste(opt$plexedpiper_output_folder,"quant_crosstab_global_rii.txt", sep="/"),
            quote=FALSE, 
            sep="\t",
            row.names = FALSE)

unlink(".Rcache", recursive=TRUE)


