#' Filter MS-GF+ Results
#'
#' Filter MS-GF+ results by PSM scores (PepQValue and |DelM_PPM|)
#'
#' @param msgfData data.frame Original results table downloaded from DMS.
#' @param filterString Character string. A string defining the threshold values to filter PSMs.
#'
#' @return data.frame A filtered version of the MS-GF+ results table.
#' @export filter_msms
#'
#' @examples
#' \dontrun{
#' msgfData <- filter_msms(msgfData, filterString = "PepQValue < 0.005 & abs(DelM_PPM) < 10")
#' }
filter_msms <- function(msgfData, filterString = "PepQValue < 0.005 & abs(DelM_PPM) < 10") {

  msgfData.filtered <- subset(msgfData, eval(parse(text=filterString)))

  # PSM FDR
  # XXX_ - these are reverse
  TF <- table(grepl("XXX_", msgfData$Protein))
  FDR = 100*TF['TRUE']/sum(TF)
  cat("PSM FDR", FDR, '(%) \n')

  # Peptide ID FDR
  # XXX_ - these are reverse
  msgfData.pep.prot <- unique(subset(msgfData, select=c("Peptide", "Protein")))
  TF <- table(grepl("XXX_", msgfData.pep.prot$Protein))
  FDR = 100*TF['TRUE']/sum(TF)
  cat("Peptide ID FDR", FDR, '(%) \n')

  return(msgfData.filtered)
}
