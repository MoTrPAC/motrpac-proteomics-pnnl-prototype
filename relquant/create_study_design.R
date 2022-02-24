#!/usr/bin/env Rscript

# Assumed that PlexedPiper is already installed. Otherwise...
if(!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if(!require("stringr", quietly = TRUE)) install.packages("stringr")

suppressPackageStartupMessages(library(optparse))
suppressWarnings(suppressPackageStartupMessages(library(dplyr, warn.conflicts = FALSE)))
suppressWarnings(suppressPackageStartupMessages(library(stringr, warn.conflicts = FALSE)))

option_list <- list(
  make_option(c("-f", "--file_vial_metadata"), 
              type="character", 
              default=NULL, 
              help="File vial_metadata.txt or type <generate> if it does not exist", 
              metavar="character"),
  make_option(c("-b", "--batch_folder"), 
              type="character", 
              default=NULL, 
              help="batch_folder", 
              metavar="character"),
  make_option(c("-c", "--cas"), type="character", default=NULL, 
              help="CAS (broad or pnnl)", metavar="character"),
  make_option(c("-o", "--output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs). 
              The preffix must be pipeline follows by the 
              PHASE-DD_TISSUE_EXPERIMENT_SITE(PN|BI)_DATAVERSION", 
              metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$file_vial_metadata) | 
    is.null(opt$batch_folder) | 
    is.null(opt$cas) | 
    is.null(opt$output_folder)
){
  print_help(opt_parser)
  stop("4 arguments are required", call.=FALSE)
}

# DEBUG --------------------------------------------------------------------
# setwd("~/Box/DavidBox/motrpac/proteomics/broad/PASS1B-06/T58/PROT_AC/BATCH01_20201012/")
# file_vial_metadata = "RESULTS_20210331/MOTRPAC_PASS1B-06_T58_AC_BI_20201012_vial_metadata.txt"
# raw_folder = "RAW_20200608"
# output_folder = "pipeline_PASS1B-06_T58_AC_BI_DF20210420"
# cas = "broad"

# setwd("~/Box/DavidBox/motrpac/proteomics/broad/HUMAN/COMPREF/PROT_PR/")
# file_vial_metadata = "BATCH01_20210622/RESULTS_20210622/MOTRPAC_COMPREF-01_T68_PR_BI_20210623_vial_metadata.txt"
# raw_folder = "BATCH01_20210622/"
# output_folder = "pipeline_HUMAN_COMPREF-01_T68_PR_BI_20210623"
# cas = "broad"

# file_vial_metadata = "generate"
# batch_folder = "~/Box/DavidBox/motrpac/proteomics/pnnl/PASS1B-06/T53/PROT_PH/BATCH1_20210802/"
# output_folder = "pipeline_PASS1B-06_T53_PH_PN_DF20210803"
# cas = "broad"

# DEGUB --------------------------------------------------------------------

file_vial_metadata <- opt$file_vial_metadata
batch_folder <- opt$batch_folder
output_folder <- opt$output_folder
cas <- opt$cas

message("\n##### GENERATE PIPELINE PlexedPiper FILES #####")
message("- Vial metadata: ", file_vial_metadata)
message("- Raw folder: ", batch_folder)
message("- Output folder: ", output_folder)

# Generate the motrpac code 
motrpac_code <- gsub("(pipeline_)(.*)", "\\2", output_folder)
motrpac_code <- paste0("MOTRPAC_", motrpac_code)

# Vial Metadata file name 
message("+ Generate vial_metadata.txt file... ", appendLF = FALSE)
vialmeta_filename <- paste0(motrpac_code,"_vial_metadata.txt")

# Process batch folder
batch_folder <- normalizePath(batch_folder)

# Get RAW files folder name
raw_folder <- list.files(batch_folder, pattern = "RAW*", full.names = TRUE)

message("done")

message("\n+ Generate samples... ", appendLF = FALSE)
nm_list = list()
if(file_vial_metadata == "generate"){
  tmt_details <- list.files(raw_folder, recursive = TRUE, full.names = TRUE)
  for (f in tmt_details ){
    nm_list[[f]] = read.delim(f)
  }
  vial_metadata <- bind_rows(nm_list)
  
}else{
  vial_metadata <- read.table(file_vial_metadata, 
                              sep="\t", 
                              header=TRUE, 
                              fill=TRUE)
}

vial_metadata$vial_label <- gsub(" ", "", vial_metadata$vial_label)

samples <- vial_metadata %>%
  mutate(PlexID = tmt_plex,
         QuantBlock = 1,
         ReporterName = tmt11_channel,
         ReporterAlias = vial_label,
         MeasurementName = vial_label) %>%
  dplyr::select(-tmt_plex, -tmt11_channel, -vial_label)
samples$ReporterName <- gsub("126C", "126", samples$ReporterName)
samples <- mutate(samples, MeasurementName = replace(MeasurementName, ReporterName=="131C", NA))

# SElect only required columns
samples <- samples[c("PlexID", "QuantBlock", "ReporterName", "ReporterAlias", "MeasurementName")]

message(" done")

message("+ Generate references... ", appendLF = FALSE)

references <- samples %>% filter(grepl("Ref",ReporterAlias)) %>%
  dplyr::select(-ReporterName, -MeasurementName) %>%
  dplyr::rename(Reference = ReporterAlias)

message(" done")

message("+ Generate fractions:")

if(cas == "pnnl"){
  raws <- list.files(raw_folder)
  fractions <- NULL
  for (i in 1:length(raws)){
    message("\t", i, ". Folder: ", raws[i], appendLF = FALSE)
    file_manifest <- list.files(file.path(raw_folder, raws[i]),
                                pattern="MANIFEST.txt",
                                ignore.case = TRUE,
                                full.names=TRUE,
                                recursive = TRUE)
    message(" + ", appendLF = FALSE)
    manifest <- read.delim(file_manifest, stringsAsFactors = FALSE)
    manifest <- manifest[c('raw_file')]
    manifest <- rename(manifest, Dataset=raw_file)
    
    file_tmt <- list.files(file.path(raw_folder, raws[i]),
                           pattern="TMTdetails.txt",
                           ignore.case = TRUE,
                           full.names=TRUE,
                           recursive = TRUE)
    message(" +")
    tmt <- read.delim(file_tmt, stringsAsFactors = FALSE)
    plex <- unique(tmt$tmt_plex)
    
    manifest$PlexID <- plex
    if(is.null(fractions)){
      fractions <- manifest
    }else{
      fractions <- rbind(fractions, manifest)
    }
  }
}else if(cas == "broad"){
  file_tmt <- list.files(file.path(batch_folder),
                         pattern="file_manifest_",
                         ignore.case = TRUE,
                         full.names=TRUE,
                         recursive = TRUE)
  file_tmt <- file_tmt[order(file_tmt, decreasing = TRUE)]
  tmt <- read.csv(file_tmt[1], stringsAsFactors = FALSE)
  tmt <- tmt[grepl(".*\\.raw", tmt$file_name),]
  tmt <- as.data.frame(apply(tmt, 2, function(x) basename(x)))
  tmt$PlexID <- NA
  tmt$PlexID <- ifelse(grepl("01M", tmt$file_name, ignore.case = TRUE), "S1", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("02M", tmt$file_name, ignore.case = TRUE), "S2", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("03M", tmt$file_name, ignore.case = TRUE), "S3", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("04M", tmt$file_name, ignore.case = TRUE), "S4", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("05M", tmt$file_name, ignore.case = TRUE), "S5", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("06M", tmt$file_name, ignore.case = TRUE), "S6", tmt$PlexID)
  
  tmt <- rename(tmt, Dataset=file_name)
  
  fractions <- tmt[c('Dataset', 'PlexID')]
}


fractions$Dataset <- gsub(".raw", "", fractions$Dataset)

# Check point
if(! all(unique(fractions$PlexID) %in% unique(samples$PlexID) )){
  stop('NOT ALL fractions$PlexID in samples$PlexID')
}

if(! all(unique(samples$PlexID) %in% unique(fractions$PlexID) )){
  stop('NOT ALL fractions$PlexID in samples$PlexID')
}

output_folder <- file.path(batch_folder, output_folder)

if(!dir.exists(file.path(output_folder))){
  dir.create(output_folder, recursive = TRUE)
}

write.table(fractions,
            file = file.path(output_folder, "fractions.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(references, 
            file = file.path(output_folder, "references.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(samples, 
            file = file.path(output_folder, "samples.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(vial_metadata, 
            file = file.path(output_folder, vialmeta_filename),
            row.names = FALSE, sep = "\t", quote = FALSE)


message("All files are out!")
  
