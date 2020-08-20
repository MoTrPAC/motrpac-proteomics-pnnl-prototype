#!/usr/bin/env Rscript

# Example command
# Rscript /relquant/pp.R -i /data/test_global/phrp_output \
# -j /data/test_global/masic_output \
# -f /data/ID_007275_FB1B42E8.fasta \
# -s /relquant/study_design \
# -o /relquant

install.packages("optparse")
# install.packages("~/github/vladpetyuk/PlexedPiper/", 
#                  repos = NULL, 
#                  type = "source")

# Load libraries
library(MSnID)
library(PlexedPiper)
library(data.table)
library(dplyr)

# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/

library("optparse")

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


msnid <- read_msgf_data(opt$msgf_output_folder, suffix = "_syn.txt")

message("- Correct for isotope selection error")
msnid <- correct_peak_selection(msnid)

message("- MS/MS ID filter and peptide level")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("- Switching annotation from RefSeq to gene symbols")
msnid <- remap_accessions_refseq_to_gene(msnid, 
                                         organism_name="Rattus norvegicus")

message("   + Loading fasta file")
path_to_FASTA_gene <- remap_accessions_refseq_to_gene_fasta(
  opt$fasta_file organism_name="Rattus norvegicus")

message("- MS/MS ID filter at protein level")
msnid <- compute_num_peptides_per_1000aa(msnid, path_to_FASTA_gene)
msnid <- filter_msgf_data_protein_level(msnid, 0.01)

message("- Inference of parsimonious protein set")
msnid <- infer_parsimonious_accessions(msnid, unique_only=TRUE)

message("- Remove decoy accessions")
msnid <- apply_filter(msnid, "!isDecoy")

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- opt$masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("- Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


message("- Read fractions.txt")
fractions <- read.table(paste(opt$study_design_folder,"fractions.txt",sep="/"))

message("- Read samples.txt")
samples <- read.table(paste(opt$study_design_folder,"samples.txt",sep="/"))

message("- Read reference.txt")
references <- read.table(paste(opt$study_design_folder,"references.txt",sep="/"))

message("- Creating quantitative cross-tab")
aggregation_level <- c("accession")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)

write.table(quant_cross_tab,
            file=paste(opt$plexedpiper_output_folder,"quant_crosstab_global.txt",sep="/"),
            quote=F, sep="\t", eol="\r\n",)

unlink(".Rcache", recursive=TRUE)


