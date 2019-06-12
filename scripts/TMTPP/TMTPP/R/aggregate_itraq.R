
#' Aggregate iTRAQ/TMT
#'
#' @param quantData data.frame
#' @param isobaricTagFractions data.frame
#' @param aggregationLevel Character string
#'
#' @return data.frame
#' @importFrom data.table data.table setkeyv
#' @export aggregate_itraq
#'
#' @examples
#' \dontrun{
#' quantData <- aggregate_itraq(quantData, isobaricTagFractions)
#' }
aggregate_itraq <- function(quantData, isobaricTagFractions, aggregationLevel = c("MixID", "Protein")) {

  quantData <- data.table( quantData, key="Dataset")
  isobaricTagFractions <- data.table(isobaricTagFractions, key="Dataset")
  quantData <- merge(quantData, isobaricTagFractions)
  #
  setkeyv(quantData, aggregationLevel)
  quantData <- quantData[,lapply(.SD,sum, na.rm = TRUE),
                         by=aggregationLevel,
                         .SDcols=grep("^Ion_1.*\\d$", colnames(quantData), value=T)]

  quantData <- as.data.frame(quantData)
  specieIDs <- setdiff(aggregationLevel, "MixID")
  specieID.values <- do.call(paste, c(quantData[,specieIDs,drop=FALSE], sep='@'))
  quantData[['Specie']] <- specieID.values
  quantData <- quantData[,!(colnames(quantData) %in% specieIDs)]

  return(quantData)
}
