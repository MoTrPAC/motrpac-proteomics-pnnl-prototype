
load("msgfData_prot_coverage_filtered.RData")
# msgfData$pepSeq <- sub(".\\.(.+?)\\..","\\1",msgfData$Peptide)
# msgfData <- subset(msgfData, !grepl("Contaminant", Protein))
# msgfData <- subset(msgfData, !grepl("XXX", Protein)) # 85257


library(dplyr)
msgfData <- mutate(msgfData, pepSeq = gsub("[.#*]","",Peptide) %>% sub("^.(.*).$","\\1",.)) %>%
    filter(!grepl("XXX", Protein)) %>%
    filter(!grepl("Contaminant", Protein))


load("protein_inference.RData")
nrow(msgfData)
length(unique(msgfData$pepSeq))
msgfData <- subset(msgfData, Protein %in% unique(res$Protein))
nrow(msgfData)
length(unique(msgfData$pepSeq))

# now remove contaminants and reverse hits.
# Basically, let's retain only NP_*
# msgfData <- subset(msgfData, grepl("^NP_.*",Protein))
# unique(msgfData$Protein) %>% substr(1,3) %>% table() %>% sort()


save(msgfData, file='msgfData_filtered_final.RData')




