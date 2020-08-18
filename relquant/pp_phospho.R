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

BiocManager::install("Biostrings")

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

opt = list()
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

msnid <- read_msgf_data(opt$msgf_output_folder, "_syn_plus_ascore.txt")

msnid <- apply_filter(msnid, "grepl(\"\\\\*\", peptide)")

msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

msnid <- infer_parsimonious_accessions(msnid)

msnid <- remap_accessions_refseq_to_gene(msnid, organism_name="Rattus norvegicus")

path_to_FASTA_gene <- remap_accessions_refseq_to_gene_fasta(opt$fasta_file, organism_name="Rattus norvegicus")

msnid <- compute_num_peptides_per_1000aa(msnid, path_to_FASTA_gene)

msnid <- filter_msgf_data_protein_level(msnid, 0.01)

msnid <- apply_filter(msnid, "!isDecoy")

fst <- Biostrings::readAAStringSet(path_to_FASTA_gene, format="fasta", 
                       nrec=-1L, skip=0L, use.names=TRUE)
ids <- psms(msnid) %>%
  distinct(accession, peptide)
ids_with_sites <- map_mod_sites(ids, fst, "accession", "peptide", "*")

ids_with_sites <- ids_with_sites %>%
  mutate(idx = map(PepLoc, length) %>% unlist) %>%
  filter(idx != 0) %>%
  dplyr::select(-idx)

ids_with_sites_simplified <- ids_with_sites %>%
  dplyr::select(accession, peptide, SiteCollapsedFirst) %>%
  mutate(site = unlist(SiteCollapsedFirst) %>%
           gsub(",","_",.) %>%
           paste(accession, ., sep="-")) %>%
  dplyr::select(-SiteCollapsedFirst)

psms(msnid) <- inner_join(psms(msnid), ids_with_sites_simplified)

psms(msnid) <- psms(msnid) %>%
  inner_join(ids_with_sites_simplified)




message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- opt$masic_output_folder
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("- Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)

#fractions <- read_tsv(system.file("extdata/study_design/fractions.txt", package = "PlexedPiperTestData"))
#fractions <- fractions[1:2,]
#write.table(fractions,
#            file=paste(study_design_folder,"fractions.txt",sep="/"),
#            quote=F, sep="\t", eol="\r\n",)

message("- Read fractions.txt")
fractions <- read.table(paste(opt$study_design_folder,"fractions.txt",sep="/"))

message("- Read samples.txt")
#samples <- read_tsv(system.file("extdata/study_design/samples.txt", package = "PlexedPiperTestData"))
#samples <- samples[1:10,]
#write.table(samples,
#            file=paste(study_design_folder,"samples.txt",sep="/"),
#            quote=F, sep="\t", eol="\r\n",)
samples <- read.table(paste(study_design_folder,"samples.txt",sep="/"))

message("- Read reference.txt")
#references <- filter(samples, ReporterAlias == "ref")
#names(references)[names(references) == "ReporterAlias"] <- "Reference"
#references <- references[c('PlexID', 'QuantBlock', 'Reference')]
#write.table(references,
#            file=paste(study_design_folder,"references.txt",sep="/"),
#            quote=F, sep="\t", eol="\r\n",)
references <- read.table(paste(study_design_folder,"references.txt",sep="/"))

message("- Creating quantitative cross-tab")
aggregation_level <- c("accession")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)

write.table(quant_cross_tab,
            file=paste(opt$plexedpiper_output_folder,"quant_cross_tab.txt",sep="/"),
            quote=F, sep="\t", eol="\r\n",)

unlink(".Rcache", recursive=TRUE)






# remap to site notation
# needed: 1) accession, 
#         2) fasta with accession, 
#         3) peptide sequence with asterisc location
# Let's borrow vp.misc remapping. !!! Ultimately it should be moved to MSnID
fst <- readAAStringSet(path_to_FASTA_gene, format="fasta", 
                       nrec=-1L, skip=0L, use.names=TRUE)
ids <- psms(msnid) %>%
  distinct(accession, peptide)
ids_with_sites <- map_PTM_sites(ids, fst, "accession", "peptide", "*")

ids_with_sites <- ids_with_sites %>%
  mutate(idx = map(PepLoc, length) %>% unlist) %>%
  filter(idx != 0) %>%
  dplyr::select(-idx)

ids_with_sites_simplified <- ids_with_sites %>%
  dplyr::select(accession, peptide, SiteCollapsedFirst) %>%
  mutate(site = unlist(SiteCollapsedFirst) %>%
           gsub(",","_",.) %>%
           paste(accession, ., sep="-")) %>%
  dplyr::select(-SiteCollapsedFirst)

psms(msnid) <- inner_join(psms(msnid), ids_with_sites_simplified)

psms(msnid) <- psms(msnid) %>%
  inner_join(ids_with_sites_simplified)






masic_data <- read_masic_data_from_DMS(3432, interference_score = T)
masic_data <- filter_masic_data(masic_data, 0.5, 0)

library(dplyr)
fractions <- masic_data %>%
  distinct(Dataset) %>%
  mutate(PlexID = sub("SHSY5Y_IIS_3x3_P_(B\\d).*","\\1",Dataset))
head(fractions)

library(readr)
samples <- read_tsv("../../3432/samples.txt")
head(samples,10)

ref <- "(`10min_control1`*`10min_control2`*`10min_Insulin`*`10min_IGF1`*`10min_IGF2`*`60min_control1`*`60min_control2`*`60min_Insulin`*`60min_IGF1`*`60min_IGF2`)^(1/10)"
references <- samples %>%
  distinct(PlexID, QuantBlock) %>%
  mutate(Reference = ref)


aggregation_level <- c("site")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)
dim(quant_cross_tab)
head(quant_cross_tab)
```



