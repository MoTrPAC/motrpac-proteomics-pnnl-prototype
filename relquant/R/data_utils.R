
#' @param out (list)
#' @param output_folder (character) Default is `"."`.
#' @param file_prefix (character) Default is `""`.
#' @return (None)
#' 
#' @examples
#' out <- fetch_global_data_from_dms(3442)
#' out <- motrpac_pnnl_global_pipeline(data_package_num,
#'                                     study_design_folder = "./study_design/",
#'                                     species = "Rattus norvegicus",
#'                                     annotation = "RefSeq")
#' save_pnnl_pipeline_results(out, output_folder = "./example_global_output/")
#' 
#' out <- fetch_ptm_data_from_dms(3605)
#' msnid <- filter_ptm_msgf_results_motrpac(out$msnid, proteomics="ph",
#'                                          out$ascore, out$path_to_FASTA)
#' save_pnnl_pipeline_results(out, output_folder = "./example_phospho_output/")

#' @export
save_pnnl_pipeline_results <- function(out, output_folder = ".", file_prefix = "") {
  if (!is.null(output_folder)) {
    if (!dir.exists(file.path(output_folder))) {
      dir.create(file.path(output_folder), recursive = TRUE)
    }
    filename = paste0(file_prefix, "results_RII-peptide.txt")
    write.table(out$rii_peptide,
                file      = file.path(output_folder, filename),
                sep       = "\t",
                row.names = FALSE,
                quote     = FALSE)
    filename = paste0(file_prefix, "results_ratio.txt")
    write.table(out$results_ratio,
                file      = file.path(output_folder, filename),
                sep       = "\t",
                row.names = FALSE,
                quote     = FALSE)
    save(out, file = file.path(output_folder, "env.RData"))
  }
}



fetch_global_data_from_dms <- memoise::memoise(
  function(data_package_num, verbose = TRUE) {
    if (verbose) message("Fetching data package no. ", data_package_num,
                         " from PNNL.\n(1/2): Reading MS-GF+ results.")
    msnid <- read_msgf_data_from_DMS(data_package_num)
    path_to_FASTA <- path_to_FASTA_used_by_DMS(data_package_num)
    if (verbose) message("(2/2): Reading MASIC results.")
    masic_data <- read_masic_data_from_DMS(data_package_num,
                                           interference_score = TRUE)
    out <- list(msnid         = msnid,
                path_to_FASTA = path_to_FASTA,
                masic_data    = masic_data)
  }
)


fetch_ptm_data_from_dms <- memoise::memoise(
  function(data_package_num, verbose = TRUE) {
    if (verbose) message("Fetching data package no. ", data_package_num,
                         " from PNNL.\n(1/3): Reading MS-GF+ results.")
    msnid <- read_msgf_data_from_DMS(data_package_num)
    path_to_FASTA <- path_to_FASTA_used_by_DMS(data_package_num)
    if (verbose) message("(2/3): Reading MASIC results.")
    masic_data <- read_masic_data_from_DMS(data_package_num,
                                           interference_score = TRUE)
    if (verbose) message("(3/3): Reading AScore results.")
    ascore <- get_AScore_results(data_package_num)
    out <- list(msnid         = msnid,
                path_to_FASTA = path_to_FASTA,
                masic_data    = masic_data,
                ascore        = ascore)
  }
)

