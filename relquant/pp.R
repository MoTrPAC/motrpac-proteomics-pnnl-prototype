#!/usr/bin/env Rscript

# install.packages("~/github/vladpetyuk/PlexedPiper/", 
#                  repos = NULL, 
#                  type = "source")

# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/

option_list <- list(
  make_option(c("-i", "--msgf_output_folder"), type="character", default=NULL, 
              help="MSGF output folder", metavar="character"),
  make_option(c("-f", "--fasta_file"), type="character", default=NULL, 
              help="FASTA file (RefSeq format)", metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument is needed (input file).n", call.=FALSE)
}

# Load libraries
library("optparse")
library("PlexedPiper")

df <- read.table(opt$file, header=TRUE)
num_vars <- which(sapply(df, class)=="numeric")
df_out <- df[ ,num_vars]
write.table(df_out, file=opt$out, row.names=FALSE)

path_to_MSGF_results <- opt$file
path_to_MSGF_results <- system.file("extdata/global/msgf_output", package = "PlexedPiperTestData")

path_to_MSGF_results <- 


# Prepare MS/MS IDs
## Read the MS-GF+ output

# This simply reads parsed to text output of MS-GF+ search engine. The text files
# are collated together and the resulting `data.frame` used to create MSnID object.
message("- Loading msgf output files:")
path_to_MSGF_results <- system.file("extdata/global/msgf_output", package = "PlexedPiperTestData")
msnid <- read_msgf_data(path_to_MSGF_results)
. 
message("- Correct for isotope selection error")
msnid <- correct_peak_selection(msnid)

message("- MS/MS ID filter and peptide level")
msnid <- filter_msgf_data_peptide_level(msnid, 0.01)

message("- Switching annotation from RefSeq to gene symbols")
msnid <- remap_accessions_refseq_to_gene(msnid, 
                                         organism_name="Rattus norvegicus")

message("   + Loading fasta file")
path_to_FASTA <- system.file("extdata/Rattus_norvegicus_NCBI_RefSeq_2018-04-10.fasta.gz",
                             package = "PlexedPiperTestData")
temp_dir <- tempdir()
file.copy(path_to_FASTA, temp_dir)
path_to_FASTA <- file.path(temp_dir, basename(path_to_FASTA))
message("   + Re-mapping")
path_to_FASTA_gene <- remap_accessions_refseq_to_gene_fasta(path_to_FASTA, 
                                                            organism_name="Rattus norvegicus")

message("- MS/MS ID filter at protein level")
msnid <- compute_num_peptides_per_1000aa(msnid, path_to_FASTA_gene)
msnid <- filter_msgf_data_protein_level(msnid, 0.01)

message("- Inference of parsimonious protein set")
msnid <- infer_parsimonious_accessions(msnid, unique_only=TRUE)

message("- Remove decoy accessions")
msnid <- apply_filter(msnid, "!isDecoy")

message("- Prepare reporter ion intensities")
message("   + Read MASIC ouput")
path_to_MASIC_results <- system.file("extdata/global/masic_output", package = "PlexedPiperTestData")
masic_data <- read_masic_data(path_to_MASIC_results, interference_score=TRUE)

message("   + Filtering MASIC data")
masic_data <- filter_masic_data(masic_data, 0.5, 0)

message("   + Read fractions.txt")
fractions <- read_tsv(system.file("extdata/study_design/fractions.txt", package = "PlexedPiperTestData"))

message("   + Read samples.txt")
samples <- read_tsv(system.file("extdata/study_design/samples.txt", package = "PlexedPiperTestData"))

message("   + Read reference.txt")
references <- filter(samples, ReporterAlias == "ref")
references <- rename(references, Reference = ReporterAlias)
references <- references[c('PlexID', 'QuantBlock', 'Reference')]


message("- Creating quantitative cross-tab")
aggregation_level <- c("accession")
quant_cross_tab <- create_crosstab(msnid, 
                                   masic_data, 
                                   aggregation_level, 
                                   fractions, samples, references)

unlink(".Rcache", recursive=TRUE)


