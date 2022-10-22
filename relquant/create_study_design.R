#!/usr/bin/env Rscript

suppressWarnings(suppressPackageStartupMessages(library(optparse)))
suppressWarnings(suppressPackageStartupMessages(library(dplyr, warn.conflicts = FALSE)))
suppressWarnings(suppressPackageStartupMessages(library(stringr, warn.conflicts = FALSE)))
library(MotrpacBicQC)

option_list <- list(
  make_option(c("-f", "--file_vial_metadata"), 
              type="character", 
              default="generate", 
              help="File <-vial_metadata.txt> or type <generate> if it does not exist", 
              metavar="character"),
  make_option(c("-b", "--batch_folder"), 
              type="character", 
              help="batch_folder", 
              metavar="character"),
  make_option(c("-c", "--cas"), 
              type="character", 
              help="CAS (BR or PN)", 
              metavar="character"),
  make_option(c("-s", "--raw_source"), 
              type="character", 
              default="folder", 
              help="Source to get the raw files: `manifest` from manifest file or `folder` to list them from the bucket raw folders", 
              metavar="character"),
  make_option(c("-t", "--tmt"),
              type="character",
              help="tmt11 or tmt16",
              metavar="character"),
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$file_vial_metadata) |
    is.null(opt$batch_folder) |
    is.null(opt$cas) |
    is.null(opt$raw_source) |
    is.null(opt$tmt)){
  print_help(opt_parser)
  stop("4 arguments are required", call.=FALSE)
}

validate_batch <- function(input_results_folder){
  batch_folder <- stringr::str_extract(string = input_results_folder, 
                                       pattern = "(BATCH\\d*\\_\\d{8})")
  
  if(is.na(batch_folder)){
    stop("`BATCH#_YYYYMMDD` folder is not recognized in the folder structure.")
  }else{
    return(batch_folder)
  }
}

# DEBUG LOCALLY ----------------------------------------------------------------
# setwd("~/Library/CloudStorage/Box-Box/DavidBox/motrpac/proteomics/broad/PASS1B-06/T58/PROT_PR/")
# file_vial_metadata <- "generate"
# batch_folder = "BATCH01_20200608/"
# output_viallabel_name = "pipeline_PASS1B-06_T58_AC_BI_DF20220616"
# cas = "broad"

# setwd("~/Box/DavidBox/motrpac/proteomics/broad/HUMAN/COMPREF/PROT_PR/")
# file_vial_metadata = "BATCH01_20210622/RESULTS_20210622/MOTRPAC_COMPREF-01_T68_PR_BI_20210623_vial_metadata.txt"
# raw_folder = "BATCH01_20210622/"
# output_viallabel_name = "pipeline_HUMAN_COMPREF-01_T68_PR_BI_20210623"
# cas = "broad"

# setwd("~/Library/CloudStorage/Box-Box/DavidBox/motrpac/proteomics/pnnl/PASS1A-06/T55/PROT_PR/")
# file_vial_metadata <- "generate"
# batch_folder = "~/Library/CloudStorage/Box-Box/DavidBox/motrpac/proteomics/pnnl/PASS1A-06/T55/PROT_PR/BATCH01_20190702"
# cas = "PN"
# raw_source = "folder"

# setwd("~/Library/CloudStorage/Box-Box/DavidBox/motrpac/proteomics/broad/PASS1A-06/T58/PROT_PR/BATCH01_20190828/RAW_20190828/")
# file_vial_metadata <- "generate"
# batch_folder = "~/Library/CloudStorage/Box-Box/DavidBox/motrpac/proteomics/broad/PASS1A-06/T58/PROT_PR/BATCH01_20190828/"
# cas = "BI"
# raw_source = "folder"

# ------------------------------------------------------------------------------

file_vial_metadata <- opt$file_vial_metadata
batch_folder <- opt$batch_folder
output_viallabel_name <- opt$output_viallabel_name
cas <- opt$cas
raw_source <- opt$raw_source
tmt <- opt$tmt

message("\n##### GENERATE PlexedPiper study_design  FILES #####")
message("-f: Vial metadata: ", file_vial_metadata)
message("-c: Bach folder: ", batch_folder)
message("-u: Get the raw files from: ", raw_source)
message("-t: tmt experiment: ", tmt)

# Generate vial_label file name (if not provided)------
batch <- validate_batch(batch_folder)
phase <- MotrpacBicQC::validate_phase(batch_folder)
assay <- MotrpacBicQC::validate_assay(batch_folder)
assay <- gsub("(PROT_)(.*)", "\\2", assay)
tissue <- MotrpacBicQC::validate_tissue(batch_folder)
valid_cas <- c("PN", "BI")
if(!any(cas %in% valid_cas)){
  stop("<cas> must be one of this: ", paste(valid_cas, collapse = ","))
}
date <- Sys.Date()
date <- gsub("-", "", date)

# Process batch folder-----
batch_folder <- normalizePath(batch_folder)

# Get RAW files folder name
raw_folder <- list.files(batch_folder, pattern = "RAW*", full.names = TRUE)

if(length(raw_folder) == 0){
  # if There is no raw folder, then use BATCH folder
  raw_folder <- batch_folder
}

# Generate samples.txt-----
message("\n+ Generate samples ", appendLF = FALSE)
nm_list = list()
if(file_vial_metadata == "generate"){
  message("(from tmt details.txt file)... ", appendLF = FALSE)
  tmt_details <- list.files(file.path(raw_folder),
                            pattern="details.txt",
                            ignore.case = TRUE,
                            full.names=TRUE,
                            recursive = TRUE)
                              
  for (f in tmt_details ){
    nm_list[[f]] = read.delim(f)
  }
  vial_metadata <- bind_rows(nm_list)
  file_vial_metadata <- paste0("MOTRPAC_", phase, "_", tissue, "_", assay, "_", date, "_vial_metadata.txt")
}else{
  message("(reading existing file_vial_metadata)... ", appendLF = FALSE)
  vial_metadata <- read.table(file_vial_metadata, 
                              sep="\t", 
                              header=TRUE, 
                              fill=TRUE)
}

message(" done!")

message("+ Vial label file name: ", file_vial_metadata)

colnames(vial_metadata) <- tolower(colnames(vial_metadata))
vial_metadata$vial_label <- ifelse(grepl("ref", vial_metadata$vial_label, ignore.case = TRUE), paste0("Ref_", vial_metadata$tmt_plex), vial_metadata$vial_label)

# Validate vial_label file-----
if(tmt == "tmt11"){
  ecolnames <- c("tmt_plex", "tmt11_channel", "vial_label")
}else if(tmt == "tmt16"){
  ecolnames <- c("tmt_plex", "tmt16_channel", "vial_label")
}else{
  stop("<tmt> must be one of this: tmt11, tmt16")
}

if( !all(ecolnames %in% colnames(vial_metadata)) ){
  stop("Vial Metadata. The expeted column names...\n\t", 
       paste(ecolnames, collapse = ", "), 
       "\nare not availble in vial_metadata: \n\t", 
       paste(colnames(vial_metadata), collapse = ", "))
}

# Remove white spaces (known issue for pnnl submissions)
vial_metadata$vial_label <- gsub(" ", "", vial_metadata$vial_label)

# Generate samples.txt-----
message("+ Generate samplex.txt... ", appendLF = FALSE)
if(tmt == "tmt11"){
  samples <- vial_metadata %>%
  mutate(PlexID = tmt_plex,
         QuantBlock = 1,
         ReporterName = tmt11_channel,
         ReporterAlias = vial_label,
         MeasurementName = vial_label) %>%
  dplyr::select(-tmt_plex, -tmt11_channel, -vial_label)
  samples <- mutate(samples, MeasurementName = replace(MeasurementName, ReporterName=="131C", NA))
}else if(tmt == "tmt16"){
  samples <- vial_metadata %>%
  mutate(PlexID = tmt_plex,
         QuantBlock = 1,
         ReporterName = tmt16_channel,
         ReporterAlias = vial_label,
         MeasurementName = vial_label) %>%
  dplyr::select(-tmt_plex, -tmt16_channel, -vial_label)
  samples <- mutate(samples, MeasurementName = replace(MeasurementName, ReporterName=="134N", NA))
}
samples$ReporterName <- gsub("126C", "126", samples$ReporterName)

# Select only required columns
samples <- samples[c("PlexID", "QuantBlock", "ReporterName", "ReporterAlias", "MeasurementName")]

message(" done")

# Generate references.txt-----
message("+ Generate references... ", appendLF = FALSE)

references <- samples %>% filter(grepl("Ref",ReporterAlias)) %>%
  dplyr::select(-ReporterName, -MeasurementName) %>%
  dplyr::rename(Reference = ReporterAlias)

message(" done")

# Generate fractions.txt-----
message("+ Generate fractions:", appendLF = FALSE)
fractions <- NULL
if(raw_source == "manifest"){
  # use the file_namifest to get information about 
  if(cas == "pnnl"){
    raws <- list.files(raw_folder)
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
    tmt$PlexID <- gsub("^(0)(\\d)(MOTRPAC.*)", "\\2", tmt$Dataset)
    tmt$PlexID <- paste0("S", tmt$PlexID)
    
    tmt <- rename(tmt, Dataset=file_name)
    
    fractions <- tmt[c('Dataset', 'PlexID')]
  }
}else if(raw_source == "folder"){
  message("...from listing raw files in folder...", appendLF = FALSE)
  # List raw files for each folder
  fractions <- as.data.frame(list.files(file.path(batch_folder),
                                       pattern="*.raw$",
                                       ignore.case = TRUE,
                                       full.names=TRUE,
                                       recursive = TRUE))
  colnames(fractions) <- c("Dataset")
  fractions <- as.data.frame(fractions)
  fractions$PlexID <- gsub("(.*/)(0)(\\d)(MOTRPAC.*)", "\\3", fractions$Dataset)
  fractions$Dataset <- basename(fractions$Dataset)
  fractions$PlexID <- paste0("S", fractions$PlexID)
  
}else{
  stop("The -s argument is not right. It should be either `manifest` or `folder`")
}

fractions$Dataset <- gsub(".raw", "", fractions$Dataset)
message("done")

message("+ Checking PlexID notations")
# Check points------
if(! all(unique(fractions$PlexID) %in% unique(samples$PlexID) )){
  stop('NOT ALL PlexedID of fractions.txt in samples.txt')
}

if(! all(unique(samples$PlexID) %in% unique(fractions$PlexID) )){
  stop('NOT ALL PlexedID of  samples.txt in fractions.txt')
}

# Print out files -----
# The study_design folder should be in the RAW folder, but given that in 
# some cases the RAW files where not given in the RAW folder, it might be 
# located in the BATCH folder.
output_viallabel_name <- file.path(raw_folder, "study_design")

if(!dir.exists(file.path(output_viallabel_name))){
  dir.create(output_viallabel_name, recursive = TRUE)
}

write.table(fractions,
            file = file.path(output_viallabel_name, "fractions.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(references, 
            file = file.path(output_viallabel_name, "references.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(samples, 
            file = file.path(output_viallabel_name, "samples.txt"),
            row.names = FALSE, sep = "\t", quote = FALSE)

write.table(vial_metadata, 
            file = file.path(output_viallabel_name, file_vial_metadata),
            row.names = FALSE, sep = "\t", quote = FALSE)


message("All files are out! Check it out at: ", file.path(output_viallabel_name))
  
