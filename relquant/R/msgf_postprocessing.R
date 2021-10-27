
#' @param msnid (MSnID)
#' @param path_to_FASTA (character)
#' @param ascore (data.frame)
#' @param global_results (data.frame)
#' @return (MSnID)
#' @importFrom dplyr %>%
#' @importFrom Biostrings readAAStringSet
#' @importFrom MSnID correct_peak_selection apply_filter
#' infer_parsimonious_accessions compute_accession_coverage map_mod_sites
#' extract_sequence_window
#' @importFrom PlexedPiper filter_msgf_data compute_num_peptides_per_1000aa
#' assess_redundant_protein_matches assess_noninferable_proteins
#' 
#' @examples
#' out <- fetch_global_data_from_dms(3442)
#' msnid <- filter_global_msgf_results_motrpac(out$msnid, out$path_to_FASTA)
#' show(msnid)
#' 
#' out <- fetch_ptm_data_from_dms(3605)
#' msnid <- filter_ptm_msgf_results_motrpac(out$msnid, proteomics="ph",
#'                                          out$ascore, out$path_to_FASTA)
#' show(msnid)

#' @export
filter_global_msgf_results_motrpac <- function(msnid, path_to_FASTA) {
  
  fst <- readAAStringSet(path_to_FASTA)
  names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))
  
  qc <- append_qc(msnid, "Original")
  
  if (verbose) message("   + Correct for isotope selection error")
  msnid <- correct_peak_selection(msnid)
  
  if (verbose) message("   + MS/MS ID filter and peptide level")
  msnid <- filter_msgf_data(msnid, level = "peptide", fdr.max = 0.01)
  qc <- append_qc(msnid, qc, "Peptide-level FDR filter")
  
  if (verbose) message("   + MS/MS ID filter at protein level")
  msnid <- compute_num_peptides_per_1000aa(msnid, 
                                           path_to_FASTA = fasta_file)
  
  msnid <- filter_msgf_data(msnid, level = "accession", fdr.max = 0.01)
  qc <- append_qc(msnid, qc, "Protein-level FDR filter")
  
  if (verbose) message("   + Remove decoy accessions")
  msnid <- apply_filter(msnid, "!isDecoy")
  qc <- append_qc(msnid, qc, "Remove decoys")
  
  if (verbose) message("   + Concatenating redundant RefSeq matches")
  msnid <- assess_redundant_protein_matches(msnid, collapse = ",")
  
  if (verbose) message("   + Assessing non-inferable proteins")
  msnid <- assess_noninferable_proteins(msnid, collapse = ",")
  
  if (verbose) message("   + Inference of parsimonious protein set")
  msnid <- infer_parsimonious_accessions(msnid)
  qc <- append_qc(msnid, qc, "Infer parsimonious accessions")

  if (verbose) message("   + Compute protein coverage")
  msnid <- compute_accession_coverage(msnid, fst)
  
  list(msnid = msnid, qc = qc)
}

filter_ptm_msgf_results_motrpac <- function(msnid, ascore, path_to_FASTA,
                                            proteomics, global_results = NULL) {
  fst <- readAAStringSet(path_to_FASTA)
  names(fst) <- sub("^(\\S*)\\s.*", "\\1", names(fst))
  
  if (proteomics == "ph") {
    reg.expr <- "grepl(\"\\\\*\", peptide)"
  } else if (proteomics %in% c("ac", "ub")) {
    reg.expr <- "grepl(\"(@|#)\", peptide)"
  }
  
  if (is.null(global_results)) {
    prior <- character(0)
  } else {
    global_ratios <- read.table(global_results, header=T, sep="\t")
    prior <- unique(global_ratios$protein_id)
  }
  
  if(proteomics == "ph") {
    mod_char = "*"
  } else if (proteomics %in% c("ac", "ub")) {
    mod_char = "#"
  } else {
    stop("Proteomics variable not supported.")
  }
  
  qc <- append_qc(msnid, "Original data")
  
  message("   + Select best PTM location by AScore")
  msnid <- best_PTM_location_by_ascore(msnid, ascore)
  qc <- append_qc(msnid, qc, "Attach_AScore")
  
  message("   + Apply PTM filter")
  msnid <- apply_filter(msnid, reg.expr)
  qc <- append_qc(msnid, qc, "Subset to PTMs")
  
  message("   + FDR filter")
  msnid <- filter_msgf_data(msnid, level = "peptide", fdr.max = 0.01)
  qc <- append_qc(msnid, qc, "FDR filter")
  
  message("   + Remove decoy sequences")
  msnid <- apply_filter(msnid, "!isDecoy")
  qc <- append_qc(msnid, qc, "Remove decoys")
  
  message("   + Concatenating redundant RefSeq matches")
  msnid <- assess_redundant_protein_matches(msnid, collapse = ",")
  
  message("   + Assessing non-inferable proteins")
  msnid <- assess_noninferable_proteins(msnid, collapse = ",")
  
  message("   + Inference of parsimonius set")
  if (is.null(global_results)) {
    message("     > Reference global proteomics dataset NOT provided")
    prior <- character(0)
  } else {
    message("     > Global proteomics results provided: PROTEIN IDS will be used to infer parsimonious as prior")
    global_ratios <- read.table(global_results, header=T, sep="\t")
    prior <- unique(global_ratios$protein_id)
  }
  msnid <- infer_parsimonious_accessions(msnid, prior = prior)
  qc <- append_qc(msnid, qc, "Infer parsimonious accessions")
  
  message("   + Mapping sites to protein sequence")
  msnid <- map_mod_sites(msnid,
                         fasta           = fst,
                         accession_col   = "accession",
                         peptide_mod_col = "peptide", 
                         mod_char        = mod_char,
                         site_delimiter  = "lower")
  qc <- append_qc(msnid, qc, "Map mod sites")
  
  message("   + Map flanking sequences")
  msnid <- extract_sequence_window(msnid, fasta = fst)
  
  list(msnid = msnid, qc = qc)
}



append_qc <- function(msnid, qc=NULL, description="") {
  qc_new <- id_quality(msnid) %>% 
    t() %>% as.data.frame() %>%
    tibble::rownames_to_column("Measurement") %>%
    mutate(Measurement = if_else(Measurement == "n", "Count", "FDR")) %>%
    pivot_longer(!Measurement, names_to="level", values_to="value")
  if (is.null(qc)) {
    qc <- qc_new %>%
      mutate(step = 0,
             description = description)
  } else {
    qc_new <- qc_new %>%
      mutate(step = max(qc$step) + 1,
             description = description)
    qc <- rbind(qc, qc_new)
  }
  return(qc)
}

