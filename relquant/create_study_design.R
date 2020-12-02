#!/usr/bin/env Rscript

# Assumed that PlexedPiper is already installed. Otherwise...
if(!require("dplyr", quietly = TRUE)) install.packages("dplyr")
if(!require("stringr", quietly = TRUE)) install.packages("stringr")

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(dplyr, warn.conflicts = FALSE))
suppressPackageStartupMessages(library(stringr, warn.conflicts = FALSE))

option_list <- list(
  make_option(c("-f", "--file_vial_metadata"), type="character", default=NULL, 
              help="File vial_metadata.txt", metavar="character"),
  make_option(c("-r", "--raw_folder"), type="character", default=NULL, 
              help="RAW folder", metavar="character"),
  make_option(c("-c", "--cas"), type="character", default=NULL, 
              help="CAS (broad or pnnl)", metavar="character"),
  make_option(c("-o", "--output_folder"), type="character", default=NULL, 
              help="PlexedPiper output folder (Crosstabs)", metavar="character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$file_vial_metadata) | 
    is.null(opt$raw_folder) | 
    is.null(opt$cas) | 
    is.null(opt$output_folder)
){
  print_help(opt_parser)
  stop("4 arguments are required", call.=FALSE)
}

# DEBUG --------------------------------------------------------------------
# file_vial_metadata = 
# raw_folder <- 
# output_folder = 
# DEGUB --------------------------------------------------------------------

file_vial_metadata <- opt$file_vial_metadata
raw_folder <- opt$raw_folder
output_folder <- opt$output_folder
cas <- opt$cas

message("\n##### GENERATE PIPELINE PlexedPiper FILES #####")
message("- Vial metadata: ", file_vial_metadata)
message("- Raw folder: ", raw_folder)
message("- Output folder: ", output_folder)

raw_folder <- normalizePath(raw_folder)

message("\n+ Generate samples... ", appendLF = FALSE)
vial_metadata <- read.table(file_vial_metadata, 
                            sep="\t", 
                            header=TRUE, 
                            fill=TRUE)

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
  file_manifest <- gsub("(.*)(/RAW.*)", "\\1", raw_folder)
  file_tmt <- list.files(file.path(file_manifest),
                         pattern="file_manifest_",
                         ignore.case = TRUE,
                         full.names=TRUE,
                         recursive = TRUE)
  tmt <- read.csv(file_tmt, stringsAsFactors = FALSE)
  tmt <- tmt[grepl(".*\\.raw", tmt$file_name),]
  tmt <- as.data.frame(apply(tmt, 2, function(x) basename(x)))
  tmt$PlexID <- NA
  tmt$PlexID <- ifelse(grepl("01MoTrPAC", tmt$file_name, ignore.case = TRUE), "S1", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("02MoTrPAC", tmt$file_name, ignore.case = TRUE), "S2", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("03MoTrPAC", tmt$file_name, ignore.case = TRUE), "S3", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("04MoTrPAC", tmt$file_name, ignore.case = TRUE), "S4", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("05MoTrPAC", tmt$file_name, ignore.case = TRUE), "S5", tmt$PlexID)
  tmt$PlexID <- ifelse(grepl("06MoTrPAC", tmt$file_name, ignore.case = TRUE), "S6", tmt$PlexID)
  
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

if(!dir.exists(file.path(output_folder))){
  dir.create(file.path(output_folder), recursive = TRUE)
}

write.table(fractions,
            file = paste(output_folder, "fractions.txt", sep="/"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(references, 
            file = paste(output_folder, "references.txt", sep="/"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(samples, 
            file = paste(output_folder, "samples.txt", sep="/"),
            row.names = FALSE, sep = "\t", quote = FALSE)

message("All files are out!")
  
