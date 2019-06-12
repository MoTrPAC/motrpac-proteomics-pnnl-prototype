#' Protein Inference
#'
#' @param msgfData data.frame
#'
#' @return data.frame
#' @importFrom data.table setDT
#' @export protein_inference
#'
#' @examples
#' \dontrun{
#' msgfData_filtered_final <- protein_inference(msgfData)
#' }
protein_inference <- function(msgfData) {
  msgfData <- mutate(msgfData, pepSeq = gsub("[.#*]","",Peptide) %>%
                       sub("^.(.*).$","\\1",.)) %>%
    filter(!grepl("XXX", Protein)) %>%
    filter(!grepl("Contaminant", Protein)) %>%
    filter(!grepl("^sp", Protein)) %>%
    filter(!grepl("^tr", Protein)) %>%
    mutate(Protein = sub("^(ref\\|)?(.+?)(\\.\\d+)?$", "\\2", Protein))

  x <- unique(msgfData[,c("pepSeq","Protein")])
  colnames(x)[2] <- "accession"


  infer_acc <- function(x){
    res <- list()
    setDT(x)
    while(nrow(x) > 0){
      top_prot <- x[, .N, by=accession][which.max(N),,]$accession
      top_peps <- subset(x, accession == top_prot)
      res <- c(res, list(top_peps))
      x <- subset(x, !(pepSeq %in% top_peps[[1]]))
    }
    return(rbindlist(res, use.names=F, fill=FALSE, idcol=NULL))
  }

  res <- infer_acc(x)
  colnames(res)[2] <- "Protein"

  save(res, file = "protein_inference.RData")

    msgfData <- subset(msgfData, Protein %in% unique(res$Protein))

  return(msgfData)
}
