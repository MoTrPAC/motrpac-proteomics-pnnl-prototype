#!/usr/bin/env Rscript

suppressPackageStartupMessages(suppressWarnings(library(optparse)))
suppressPackageStartupMessages(suppressWarnings(library(purrr)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))
suppressPackageStartupMessages(suppressWarnings(library(PlexedPiper)))
suppressPackageStartupMessages(suppressWarnings(library(stringr)))

option_list <- list(
  make_option(c("-a", "--p1a"),
              type = "character",
              help = "path to pass1a study design",
              metavar = "character"),
  make_option(c("-c", "--p1c"),
              type = "character",
              help = "path to pass1c study design",
              metavar = "character"),
  make_option(c("-o", "--output_folder"),
              type = "character",
              help = "path to the output folder",
              metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$p1a) ||
    is.null(opt$p1c) ||
    is.null(opt$output_folder)) {
  print_help(opt_parser)
  stop("Required arguments are missed", call. = FALSE)
}

message("+ PlexedPiper version: ", paste(packageVersion("PlexedPiper")))

p1a <- opt$p1a
p1c <- opt$p1c
output_folder <- opt$output_folder

study_design_folder <- list("PASS1A" = p1a,
                            "PASS1C" = p1c)

message("+ Load study design folders")
prefix = NULL
study_design <- map(study_design_folder, read_study_design, prefix = prefix)

study_design <- map(names(study_design), function(name_i) {
  sd_i <- study_design[[name_i]]
  cols <- c("PlexID", "ReporterName", "MeasurementName", "Reference")
  sd_i <- map(sd_i, function(xi) {
    mutate(xi, across(intersect(cols, colnames(xi)), ~ paste0(.x, "_", name_i)))
  })
  return(sd_i)
})

study_design <- list_transpose(study_design) %>% map(bind_rows)

message("+ Remove duplicates (only vial labels)")
remove_duplicate_digits <- function(df) {
  df2 <- df %>%
    mutate(is_digit = str_detect(ReporterAlias, "^\\d+(\\.\\d+)?$"),
           ReporterAlias = ifelse(is_digit, make.unique(ReporterAlias), ReporterAlias))
  
  df2 <- select(df2, -is_digit)
  return(df2)
}

study_design$samples <- remove_duplicate_digits(study_design$samples)

# Save results (modify file path as needed)
message(paste("+ Save files to", output_folder))

if(!dir.exists(file.path(output_folder))){
  dir.create(file.path(output_folder), recursive = TRUE)
}

walk(names(study_design), function(name_i) {
  write.table(study_design[[name_i]],
              file = sprintf(file.path(output_folder, "%s.txt"), name_i),
              quote = FALSE, row.names = FALSE, sep = "\t")
})
