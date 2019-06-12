
rm(list=ls(all=TRUE));gc()
# source("_parameters.R")


apply_filter_with_psms_rescue <- function(msgfData, filterString, boost.PSM=TRUE){

    # PSM FDR
    # XXX_ - these are reverse
    TF <- table(grepl("XXX_", msgfData$Protein))
    FDR = 100*TF['TRUE']/sum(TF)

    # Filter PSMs
    # .. filters are in the parameters.txt file
    msgfData.filtered <- subset( msgfData, eval(parse(text=filterString)))

    # PSM FDR
    # XXX_ - these are reverse
    TF <- table(grepl("XXX_", msgfData.filtered$Protein))
    (FDR = 100*TF['TRUE']/sum(TF))

    # Peptide ID FDR
    # XXX_ - these are reverse
    msgfData.filtered.pep.prot <- 
       unique(subset(msgfData.filtered, select=c("Peptide", "Protein")))
    TF <- table(grepl("XXX_", msgfData.filtered.pep.prot$Protein))
    (FDR = 100*TF['TRUE']/sum(TF))

    # boosting PSM rate
    if(boost.PSM){
        uniquePassedPeptides <- unique(msgfData.filtered.pep.prot[,'Peptide'])
        msgfData <- subset(msgfData, Peptide %in% uniquePassedPeptides)
    }else{
        msgfData <- msgfData.filtered
    }

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
    return(msgfData)
}



load("msgfData_original.RData")

#' I'll get rid of partially tryptic and oxidized methionine peptides
#' MSGFDB_PartTryp_DynMetOx_Stat_CysAlk_TMT_6Plex_20ppmParTol.txt

# msgfData <- subset(msgfData, !grepl("\\*",Peptide))

# i1 <- grepl("^[KR]\\.[^P]", msgfData$Peptide) # N-term cleavage pattern
# i2 <- grepl("^-\\.", msgfData$Peptide) # N-term protein
# i3 <- grepl("[KR]\\.[^P]$", msgfData$Peptide) # N-term cleavage pattern
# i4 <- grepl("\\.-$", msgfData$Peptide) # N-term cleavage pattern
# msgfData <- msgfData[(i1 | i2) & (i3 | i4),]


# filterString = "MSGFDB_SpecEValue < 10^-8 & abs(DelM_PPM) < 10"
# filterString = "PepQValue < 0.0029 & abs(DelM_PPM) < 10"
filterString = "PepQValue < 0.01 & abs(DelM_PPM) < 10"
msgfData <- apply_filter_with_psms_rescue(msgfData, filterString, boost.PSM=F)

save(msgfData, file="msgfData_psm_filtered.RData")

# PSM FDR 0.08964258 (%) 
# Peptide ID FDR 0.1581795 (%)
