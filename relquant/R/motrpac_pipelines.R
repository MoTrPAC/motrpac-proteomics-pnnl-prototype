

#' @param data_package_num (integer)
#' @param study_design_folder (character)
#' @param species (character)
#' @param annotation (character)
#' @param return_all (logical) Default is `TRUE`.
#' @param verbose (logical) Default is `FALSE`.
#' @param proteomics (character) For PTM pipeline only.
#' @param global_results (character) Default is `NULL`.
#' @return (list)
#' @importFrom PlexedPiper read_study_design filter_masic_data
#' make_rii_peptide_gl make_results_ratio_gl make_rii_peptide_ph
#' make_results_ratio_ph
#' 
#' @examples
#' out <- motrpac_pnnl_global_pipeline(data_package_num = 3442,
#'                                     study_design_folder = "global/study_design/",
#'                                     species = "Rattus norvegicus",
#'                                     annotation = "RefSeq")
#' save_pnnl_pipeline_results(out, output_folder = "./global/output/")
#' 
#' out <- motrpac_pnnl_ptm_pipeline(proteomics = "ph",
#'                                  data_package_num = 3606,
#'                                  study_design_folder = "./phospho/study_design/",
#'                                  species = "Rattus norvegicus",
#'                                  annotation = "RefSeq")
#' save_pnnl_pipeline_results(out, output_folder = "./phospho/output/")

#' @export
motrpac_pnnl_global_pipeline <- function(msnid, path_to_FASTA, masic_data,
                                         study_design_folder, species,
                                         annotation, verbose = TRUE) {
  if (verbose) {
    message("Running MoTrPAC PNNL pipeline with the following parameters:")
    message("proteomics: \"pr\".")
    message("Study design folder: ", study_design_folder, "\".")
    message("Species: \"", species, "\".")
    message("Annotation: \"", annotation, "\".")
  }
  
  if (verbose) message("Reading study design tables from ", study_design_folder, ".")
  study_design <- read_study_design(study_design_folder)
  
  if (verbose) message("Filtering MS-GF+ results.")
  msnid <- filter_global_msgf_results_motrpac(msnid, path_to_FASTA)
  
  if (verbose) message("Filtering MASIC results.")
  masic_data_filtered <- filter_masic_data(masic_data, 0.5, 0)
  
  if (verbose) message("Making RII peptide table.")
  rii_peptide <- make_rii_peptide_gl(msnid      = msnid_filtered, 
                                     masic_data = masic_data_filtered, 
                                     fractions  = study_design$fractions, 
                                     samples    = study_design$samples, 
                                     references = study_design$references, 
                                     annotation = annotation,
                                     org_name   = species)
  
  if (verbose) message("Making ratio table.")
  results_ratio <- make_results_ratio_gl(msnid      =  msnid, 
                                         masic_data = masic_data, 
                                         fractions  = fractions, 
                                         samples    = samples, 
                                         references = references, 
                                         annotation = annotation,
                                         org_name   = species)
  if (verbose) message("Done!")
  list(msnid               = msnid,
       path_to_FASTA       = path_to_FASTA,
       msnid_filtered      = msnid_filtered,
       masic_data          = masic_data,
       masic_data_filtered = masic_data_filtered,
       rii_peptide         = rii_peptide,
       results_ratio       = results_ratio)
}

#' @export
motrpac_pnnl_ptm_pipeline <- function(msnid, path_to_FASTA, masic_data, ascore,
                                      proteomics,
                                      study_design_folder,
                                      species, annotation,
                                      global_results = NULL,
                                      verbose = TRUE) {
  if (verbose) {
    message("Running MoTrPAC PNNL pipeline with the following parameters:")
    message("proteomics: \"", proteomics, "\".")
    message("Study design folder: \"", study_design_folder, "\".")
    message("Species: \"", species, "\".")
    message("Annotation: \"", annotation, "\".")
    if (!is.null(global_results)) {
      message("Path to global results: \"", global_results, "\".")
    }
  }
  n_steps <- 6
  if (verbose) message("Step 1/", n_steps, ": Reading study design tables from ", study_design_folder, ".")
  study_design <- read_study_design(study_design_folder)
  
  if (verbose) message("Step 2/", n_steps, ": Filtering MS-GF+ output.")
  msnid_filtered <- filter_ptm_msgf_results_motrpac(msnid          = msnid,
                                                    proteomics     = proteomics,
                                                    ascore         = ascore,
                                                    path_to_FASTA  = path_to_FASTA,
                                                    global_results = global_results)
  
  if (verbose) message("Step 3/", n_steps, ": Filtering MASIC output.")
  masic_data_filtered <- filter_masic_data(masic_data, 0.5, 0)
  
  if (verbose) message("Step 4/", n_steps, ": Making RII peptide table.")
  rii_peptide <- make_rii_peptide_ph(msnid      = msnid_filtered, 
                                     masic_data = masic_data_filtered, 
                                     fractions  = study_design$fractions, 
                                     samples    = study_design$samples, 
                                     references = study_design$references,
                                     annotation = annotation,
                                     org_name   = species)
  
  if (verbose) message("Step 5/", n_steps, ": Making ratio table.")
  results_ratio <- make_results_ratio_ph(msnid      = msnid_filtered, 
                                         masic_data = masic_data_filtered, 
                                         fractions  = study_design$fractions, 
                                         samples    = study_design$samples, 
                                         references = study_design$references, 
                                         annotation = annotation,
                                         org_name   = species)
  if (verbose) message("Step 6/", n_steps, ": Saving results.")
  list(msnid               = msnid,
       ascore              = ascore,
       path_to_FASTA       = path_to_FASTA,
       msnid_filtered      = msnid_filtered,
       masic_data          = masic_data,
       masic_data_filtered = masic_data_filtered,
       rii_peptide         = rii_peptide,
       results_ratio       = results_ratio)
}

library(memoise)
motrpac_pnnl_global_pipeline <- memoise(motrpac_pnnl_global_pipeline)
motrpac_pnnl_ptm_pipeline    <- memoise(motrpac_pnnl_ptm_pipeline)


