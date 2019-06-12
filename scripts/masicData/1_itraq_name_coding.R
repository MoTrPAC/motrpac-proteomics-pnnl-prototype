


load("masicData_original.RData")
library(dplyr)
isobaricTagFractions <- 
    select(masicData, Dataset) %>%
    distinct() %>%
    mutate(MixID = sub("MoTrPAC_Pilot_TMT_W_(S\\d).*$","\\1",Dataset))
write.table(isobaricTagFractions,
            file = "isobaricTagFractions.txt",
            row.names = FALSE,
            sep="\t",
            quote=F)
isobaricTagFractions <- read.delim("isobaricTagFractions.txt", 
                                   stringsAsFactors = F)

isobaricTagSamples <- read.delim("pre_isobaricTagSamples.txt", 
                                 stringsAsFactors = F, na.strings = "")
ReporterConverter <- read.delim("ReporterConverter.txt", 
                                 stringsAsFactors = F, na.strings = "")
isobaricTagSamples <- inner_join(isobaricTagSamples, ReporterConverter) %>% 
   select(-TMTChannel)

isobaricTagReference <- read.delim("isobaricTagReference.txt", 
                                   stringsAsFactors = F)


# filter isobaricTagReference by Reference == ref
# exclude BxSx from Fractions and Samples as well
compref_sets <- filter(isobaricTagReference, Reference != "ref") %>% .$MixID
isobaricTagReference <- filter(isobaricTagReference, !(MixID %in% compref_sets))
isobaricTagSamples <- filter(isobaricTagSamples, !(MixID %in% compref_sets))


save(isobaricTagFractions, isobaricTagSamples, isobaricTagReference, 
     file="isobaricTagDesign.RData")

