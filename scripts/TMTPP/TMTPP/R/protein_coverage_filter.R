
#' Protein Coverage Filter
#'
#' Filter for protein coverage
#' @param msgfData data.frame The msgfData dataframe filtered by PSM quality scores
#' @param fasta.files Character A string that links the path to the protein collection used by MS-GF+
#'
#' @return data.frame
#' @importFrom Biostrings readAAStringSet
#' @importFrom dplyr group_by summarise n
#' @export protein_coverage_filter
#'
#' @examples
#' \dontrun{
#' msgfData <- protein_coverage_filter(msgfData, Npep = 7, fasta = "path/to/protein_collection.fasta/")
#' }
protein_coverage_filter <- function(msgfData, Npep = 7, fasta) {

  msgfData <- mutate(msgfData, isDecoy = grepl("^XXX", Protein),
                     cleanSeq = sub(".\\.(.*)\\..","\\1",Peptide))

  mySequences <- readAAStringSet(fasta.files)

  prot_lengths <- data.frame(Protein = sub("^(\\S+)\\s.*","\\1",names(mySequences)),
                             Length = width(mySequences),
                             stringsAsFactors = FALSE)
  prot_lengths <- mutate(prot_lengths, Protein = paste0("XXX_", Protein)) %>%
    rbind(prot_lengths, .)


  pepN1000 <- select(msgfData, Protein, Peptide) %>%
    distinct %>%
    group_by(Protein) %>%
    summarise(pepN = n()) %>%
    inner_join(prot_lengths) %>%
    mutate(pep_per_1000 = 1000*pepN/Length,
           isDecoy = grepl("^XXX", Protein))


  y <- filter(pepN1000, pep_per_1000 > Npep) %>%
    select(Protein) %>%
    inner_join(msgfData)

  # Peptide level FDR
  TF <- y %>%
    select(cleanSeq, isDecoy) %>%
    distinct %>%
    group_by(isDecoy) %>%
    dplyr::summarise(cnt = n())

  FDR <- TF[2,2]*100/sum(TF[,2])
  cat("Peptide FDR", FDR[[1]], '(%) \n')

  # Protein level FDR
  TF <- y %>%
    select(Protein, isDecoy) %>%
    distinct %>%
    group_by(isDecoy) %>%
    dplyr::summarise(FDR = n())

  FDR <- TF[2,2]*100/sum(TF[,2])
  cat("Protein FDR", FDR[[1]], '(%) \n')


  return(y)
}
