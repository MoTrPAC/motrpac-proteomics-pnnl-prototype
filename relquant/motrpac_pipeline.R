
#' @param msnid (MSnID)
#' @param path_to_fasta (character)
#' @param masic_data (data.frame)
#' @param ascore (data.frame)
#' @param proteomics (character)
#' @param study_design (list)
#' @param species (character)
#' @param annotation (character)
#' @param global_results (character) Default is `NULL`.
#' @param output_folder (character)
#' @param file_prefix (character)
#' @param save_env (logical)
#' @param verbose (logical) Default is `FALSE`.
#' @return (list)
#' @importFrom Biostrings readAAStringSet
#' @importFrom PlexedPiper read_study_design filter_masic_data
#' make_rii_peptide_gl make_results_ratio_gl make_rii_peptide_ph
#' make_results_ratio_ph
#' 
#' @examples
#' out <- motrpac_pnnl_pipeline(msnid, path_to_fasta, masic_data, ascore=NULL,
#'                              proteomics = "pr",
#'                              study_design,
#'                              species = "Rattus norvegicus",
#'                              annotation = "RefSeq")
#' save_pnnl_pipeline_results(out, output_folder = "./global/output/")
#' 
#' out <- motrpac_pnnl_pipeline(msnid, path_to_fasta, masic_data, ascore,
#'                              proteomics = "ph",
#'                              study_design,
#'                              species = "Rattus norvegicus",
#'                              annotation = "RefSeq")
#' save_pnnl_pipeline_results(out, output_folder = "./phospho/output/")

#' @export
motrpac_pnnl_pipeline <- function(msnid, path_to_fasta, masic_data,
                                  ascore = NULL, proteomics,
                                  study_design, species, annotation,
                                  global_results = NULL, output_folder = ".",
                                  file_prefix = NULL, save_env = FALSE, verbose = TRUE) {
  if (verbose) {
    message("Running MoTrPAC PNNL pipeline with the following parameters:")
    message("proteomics: \"pr\".")
    message("Species: \"", species, "\".")
    message("Annotation: \"", annotation, "\".")
  }
  
  fst <- Biostrings::readAAStringSet(path_to_fasta)
  names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))
  
  if (verbose) message("Filtering MS-GF+ results.")
  if (proteomics == "pr") {
    if (verbose) message("   + Correct for isotope selection error")
    msnid <- correct_peak_selection(msnid)
  }
  
  if (proteomics != "pr") {
    if (verbose) message("   + Select best PTM location by AScore")
    msnid <- best_PTM_location_by_ascore(msnid, ascore)
    
    if (verbose) message("   + Apply PTM filter")
    if (proteomics == "ph") {
      reg.expr <- "grepl(\"\\\\*\", peptide)"
    } else if (proteomics == "ac") {
      reg.expr <- "grepl(\"#\", peptide)"
    } else if (proteomics == "ub") {
      psms(msnid) <- psms(msnid) %>% mutate(peptide = gsub("@", "#", peptide))
      reg.expr <- "grepl(\"#\", peptide)"
    }
    msnid <- apply_filter(msnid, reg.expr)
  }
  
  message("   + Peptide-level FDR filter")
  msnid <- filter_msgf_data(msnid, level = "peptide", fdr.max = 0.01)
  
  if (proteomics == "pr") {
    if (verbose) message("   + Protein-level FDR filter")
    msnid <- compute_num_peptides_per_1000aa(msnid, path_to_FASTA = path_to_fasta)
    
    msnid <- filter_msgf_data(msnid, level = "accession", fdr.max = 0.01)
  }
  
  message("   + Remove decoy sequences")
  msnid <- apply_filter(msnid, "!isDecoy")
  
  if (verbose) message("   + Concatenating redundant RefSeq matches")
  msnid <- assess_redundant_protein_matches(msnid, collapse = ",")
  
  if (verbose) message("   + Assessing non-inferable proteins")
  msnid <- assess_noninferable_proteins(msnid, collapse = ",")
  
  message("   + Inference of parsimonius set")
  if (proteomics == "pr") {
    prior <- character(0)
  } else if (is.null(global_results)) {
    message("     > Reference global proteomics dataset NOT provided")
    prior <- character(0)
  } else {
    global_ratios <- read.table(global_results, header=T, sep="\t")
    prior <- unique(global_ratios$protein_id)
  }
  msnid <- infer_parsimonious_accessions(msnid, prior = prior)
  
  fst <- readAAStringSet(path_to_fasta)
  names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))
  
  if (proteomics == "pr") {
    if (verbose) message("   + Compute protein coverage")
    msnid <- compute_accession_coverage(msnid, fst)
  }
  
  if (proteomics != "pr") {
    message("   + Mapping sites to protein sequence")
    if (proteomics == "ph") {
      mod_char = "*"
    } else if (proteomics %in% c("ac", "ub")) {
      mod_char = "#"
    } else {
      stop("Proteomics variable not supported.")
    }
    
    msnid <- map_mod_sites(msnid,
                           fasta           = fst,
                           accession_col   = "accession",
                           peptide_mod_col = "peptide", 
                           mod_char        = mod_char,
                           site_delimiter  = "lower")
    
    message("   + Map flanking sequences")
    msnid <- extract_sequence_window(msnid, fasta = fst)
  }
  
  if (verbose) message("Filtering MASIC results.")
  masic_data <- filter_masic_data(masic_data, 0.5, 0)
  
  args <- list(msnid      = msnid, 
               masic_data = masic_data, 
               fractions  = study_design$fractions, 
               samples    = study_design$samples, 
               references = study_design$references, 
               annotation = annotation,
               org_name   = species)
  
  if (verbose) message("Making results tables.")
  if (proteomics == "pr") {
    rii_peptide   <- do.call(make_rii_peptide_gl,   args)
    results_ratio <- do.call(make_results_ratio_gl, args)
  } else {
    rii_peptide   <- do.call(make_rii_peptide_ph,   args)
    results_ratio <- do.call(make_results_ratio_ph, args)
  }
  
  if (verbose) message("Saving results.")
  
  if (!is.null(output_folder)) {
    if (!dir.exists(file.path(output_folder))) {
      dir.create(file.path(output_folder), recursive = TRUE)
    }
    
    filename = paste0(file_prefix, "results_RII-peptide.txt")
    write.table(rii_peptide,
                file      = file.path(output_folder, filename),
                sep       = "\t",
                row.names = FALSE,
                quote     = FALSE)
    
    filename = paste0(file_prefix, "results_ratio.txt")
    write.table(results_ratio,
                file      = file.path(output_folder, filename),
                sep       = "\t",
                row.names = FALSE,
                quote     = FALSE)
    if (save_env) {
      save.image(file = file.path(output_folder, "env.RData"))
    }
  }
  if (verbose) message("Done!")
  return(list(rii_peptide = rii_peptide, results_ratio = results_ratio))
}
