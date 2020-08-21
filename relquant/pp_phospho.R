#!/usr/bin/env Rscript

# Example command
# Rscript /relquant/pp.R -i /data/test_global/phrp_output \
# -j /data/test_global/masic_output \
# -f /data/ID_007275_FB1B42E8.fasta \
# -s /relquant/study_design \
# -o /relquant

install.packages("optparse")
if(!require("remotes", quietly = T)) install.packages("remotes")
remotes::install_github("vladpetyuk/PlexedPiper", build_vignettes = F)

library(PlexedPiper)
library("optparse")

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

opt = list()
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

message("- Prepare MS/MS IDs")
message("   + Read the MS-GF+ output + Ascore")
msnid <- read_msgf_data(opt$ascore_output_folder, "_syn_plus_ascore.txt")
msnid <- apply_filter(msnid, "grepl(\"\\\\*\", peptide)")

message("   + FDR filter")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("   + Inference of parsimonius set")
msnid <- infer_parsimonious_accessions(msnid)

message("   + Mapping sites to protein sequence")
fst <- Biostrings::readAAStringSet(opt$fasta_file)
names(fst) <- sub("^([A-Z]P_\\d+\\.\\d+)\\s.*", "\\1", names(fst))
msnid <- map_mod_sites(msnid, fst, 
                       accession_col = "accession", 
                       peptide_mod_col = "Peptide", 
                       mod_char = "*",
                       site_delimiter = "lower")

message("   + Remove decoy sequences")
msnid <- apply_filter(msnid, "!isDecoy")

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- opt$masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)


message("- Fetch study design tables")
message("   + Read fractions.txt")
fractions <- read.table(paste(opt$study_design_folder,"fractions.txt",sep="/"))

message("   + Read samples.txt")
samples <- read.table(paste(opt$study_design_folder,"samples.txt",sep="/"))

message("   + Read references.txt")
references <- read.table(paste(opt$study_design_folder,"references.txt",sep="/"))

message("- Create quantitative crosstab")
aggregation_level <- c("SiteID")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)

message("- Save crosstab to file")
write.table(quant_cross_tab,
            file=paste(opt$plexedpiper_output_folder,"quant_crosstab_phospho.txt",sep="/"),
            quote=F, sep="\t", eol="\r\n",)

unlink(".Rcache", recursive=TRUE)