#' Link MASIC and MS-GF+ Results
#'
#' @param msgfData data.frame
#' @param masicData data.frame
#'
#' @return data.frame
#' @export link_msms_masic
#'
#' @examples
#' \dontrun{
#' quantData <- link_msms_masic(msgfData, masicData)
#' }
link_msms_masic <- function(msgfData, masicData) {

  msgfData <- subset(msgfData,
                     select=c("Dataset","Scan","Peptide","Protein"))
  masicData <- subset(masicData,
                      select=c("Dataset","ScanNumber",
                               grep("^Ion.*\\d$",colnames(masicData),value=T)))
  masicData <- within(masicData, {Scan <- ScanNumber; ScanNumber <- NULL})

  msgfData <- data.table(msgfData, key=c("Dataset", "Scan"))
  masicData <- data.table(masicData, key=c("Dataset", "Scan"))

  quantData <- merge(msgfData, masicData)

  return(as.data.frame(quantData))

}
