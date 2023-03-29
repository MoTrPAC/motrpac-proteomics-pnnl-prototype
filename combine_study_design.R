#!/usr/bin/env Rscript

suppressPackageStartupMessages(suppressWarnings(library(optparse)))
suppressPackageStartupMessages(suppressWarnings(library(purrr)))
suppressPackageStartupMessages(suppressWarnings(library(dplyr)))
suppressPackageStartupMessages(suppressWarnings(library(PlexedPiper)))

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

study_design_folder <- list("1A" = p1a,
                            "1C" = p1c)

message("+ Load study design folders")
prefix = NULL
study_design <- map(study_design_folder, read_study_design, prefix = prefix)

study_design <- map(names(study_design), function(name_i) {
  sd_i <- study_design[[name_i]] %>%
    map(function(xi) {
      mutate(xi, PASS = name_i)
    })
  return(sd_i)
}) %>%
  list_transpose() %>%
  map(bind_rows) %>%
  map(function(xi) {
    xi %>%
      mutate(across(
        any_of(c("ReporterAlias", "MeasurementName")),
        ~ ifelse(is.na(.x) | grepl("^ref", .x, ignore.case = TRUE),
                 .x, make.unique(.x))),
        across(any_of(c("ReporterAlias", "MeasurementName", "PlexID")),
               ~ ifelse(is.na(.x), NA, paste0(.x, "_", PASS))),
        # This can handle references that are combinations of multiple channels
        across(any_of("Reference"), function(ref) {
          map2_chr(ref, PASS, function(ref_i, pass_i) {
            parse(text = ref_i, keep.source = TRUE) %>%
              getParseData() %>%
              filter(terminal) %>%
              mutate(text = ifelse(token == "SYMBOL",
                                   paste0(text, "_", pass_i),
                                   text)) %>%
              pull(text) %>%
              paste(collapse = "")
          })
        }),
        PASS = NULL) # remove PASS column
  })

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
