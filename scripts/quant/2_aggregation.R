# What does it do?
# Links individual fractions (DatasetName) to identifier of iTRAQ mix (iTRAQ_ID)



rm(list=ls(all=TRUE));gc()
load("quantData.RData") # 
# load("quantData_spectrum_level.RData") # spectrum level
load("../masicData/isobaricTagDesign.RData")
library("data.table")




aggregate_itraq <- function(quantData, isobaricTagFractions, aggregationLevel)
{

    quantData <- data.table( quantData, key="Dataset")
    isobaricTagFractions <- data.table(isobaricTagFractions, key="Dataset")
    quantData <- merge(quantData, isobaricTagFractions)
    #
    setkeyv(quantData, aggregationLevel)
    quantData <- quantData[,lapply(.SD,sum, na.rm=TRUE),
                            by=aggregationLevel,
                            .SDcols=grep("^Ion_1.*\\d$", colnames(quantData), value=T)] # grepping is not good here!

    quantData <- as.data.frame(quantData)
    specieIDs <- setdiff(aggregationLevel, "MixID")
    specieID.values <- do.call(paste, c(quantData[,specieIDs,drop=FALSE], sep='@'))
    quantData[['Specie']] <- specieID.values
    quantData <- quantData[,!(colnames(quantData) %in% specieIDs)]
                            
    return(quantData)
}

# quantData$PeptideClean <- sub(".\\.(.+?)\\..","\\1",quantData$Peptide)
# nrow(quantData)
# quantData <- subset(quantData, !grepl("\\*", PeptideClean))
# nrow(quantData)

aggregationLevel = c("MixID","Protein")
quantData <- aggregate_itraq(quantData, isobaricTagFractions, aggregationLevel)

save(quantData, file="quantData.RData")



