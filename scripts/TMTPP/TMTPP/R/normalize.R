#' Normalize
#'
#' @param crossTab data.frame
#'
#' @return data.frame
#' @importFrom stats median
#' @export normalize
#'
#' @examples
#' \dontrun{
#' crossTab <- normalize(crossTab)
#' }
normalize <- function(crossTab) {

  fully.present <- rowSums(is.na(crossTab)) == 0
  crossTab2 <- crossTab[fully.present,]
  norm.coeff <- apply(crossTab2, 2, median, na.rm=TRUE)

  crossTab <- sweep( crossTab, 2, norm.coeff[colnames(crossTab)], '-')

  return(crossTab)
}
