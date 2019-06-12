# What does it do?
# 1) Joins msgfData and masicData by DatasetName and Scan
#       output: quantData

library("data.table")

link_msgf_and_masic <- function(msgfData, masicData)
{
    msgfData <- subset(msgfData, 
                       select=c("Dataset","Scan","Peptide","Protein"))
    masicData <- subset(masicData,
                        select=c("Dataset","ScanNumber",
                                 grep("^Ion.*\\d$",colnames(masicData),value=T)))
                                 # "Ion_126","Ion_127","Ion_128","Ion_129","Ion_130","Ion_131"))
                                 # "Ion_114","Ion_115","Ion_116","Ion_117"))
    masicData <- within(masicData, {Scan <- ScanNumber; ScanNumber <- NULL})
    
    msgfData <- data.table(msgfData, key=c("Dataset", "Scan"))
    masicData <- data.table(masicData, key=c("Dataset", "Scan"))

    quantData <- merge(msgfData, masicData)

    return(as.data.frame(quantData))
}



load("../msmsData/msgfData_filtered_final.RData") # msgfData(_human)
load("../masicData/masicData_filtered.RData") # masicData


quantData <- link_msgf_and_masic(msgfData, masicData)

save(quantData, file="quantData.RData")

