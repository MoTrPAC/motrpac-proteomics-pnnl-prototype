
load("msgfData_prot_coverage_filtered.RData")


# msgfData$pepSeq <- sub(".\\.(.+?)\\..","\\1",msgfData$Peptide)
# # msgfData <- subset(msgfData, !grepl("Contaminant", Protein))
# # msgfData <- subset(msgfData, !grepl("XXX", Protein)) # 85257
# msgfData$Protein <- sub("(ref\\|)?(.+?)\\.\\d+", "\\1", msgfData$Protein)

library(dplyr)
msgfData <- mutate(msgfData, pepSeq = gsub("[.#*]","",Peptide) %>% 
                      sub("^.(.*).$","\\1",.)) %>%
    filter(!grepl("XXX", Protein)) %>%
    filter(!grepl("Contaminant", Protein))


# protein inference loop
x <- unique(msgfData[,c("pepSeq","Protein")])
colnames(x)[2] <- "accession"

library(data.table)


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

#' 
#' 
#' #' LOOP VERSION
#' infer_prot <- function(pep_pro){
#'     res <- list()
#'     while(nrow(pep_pro) > 0){
#'         top_prot <- names(which.max(table(pep_pro$Protein)))
#'         top_peps <- subset(pep_pro, Protein == top_prot)
#'         res <- c(res, list(top_peps))
#'         pep_pro <- subset(pep_pro, !(pepSeq %in% top_peps[,"pepSeq"]))
#'     }
#'     return(Reduce(rbind,res))
#' }


system.time(res <- infer_acc(x)) # 5 min
colnames(res)[2] <- "Protein"
save(res, file="protein_inference.RData")

# res$pepSeqIL <- sub("I","L",res$pepSeq)
# save(res, file="protein_inference_IL.RData")

#===============================================================================
# END right here

