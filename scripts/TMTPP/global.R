# This file is a blueprint for how to run the scripts in library TMTPP as-is
# In practice, we tend to run the scripts manually, which allows for some customization
# of the parameters.  See these three directories:
#
#   pilot_data_global_20190110/scripts/masicData
#   pilot_data_global_20190110/scripts/msmsData
#   pilot_data_global_20190110/scripts/quant

library(TMTPP)

# get analysis job results from Data Package
get_data(dataPackageNumber = 2900)


# masicData ================================================
load("masicData_original.RData")

## Build isobaricTag Label tables
channel_2_sample(masicData, label_file = "pre_isobaricTagSamples.txt", ReporterConverter = "ReporterConverter.txt")

## filter MASIC
load("masicData_original.RData")

masicData <- filter_masic(masicData, s2n_min_threshold = 0, interference_score = 0.5)

save(masicData, file = "masicData_filtered.RData")


rm(list=ls(all=T));gc()


# msmsData ================================================
load("msgfData_original.RData")

## PSM filter
msgfData <- filter_msms(msgfData)

save(msgfData, file = "msgfData_psm_filtered.RData")

## Protein Coverage filter
load("msgfData_psm_filtered.RData")

msgfData <- protein_coverage_filter(msgfData, fasta = "Rattus_norvegicus_UniProt_MoTrPAC_2017-10-20.fasta.gz")

save(msgfData, file = "msgfData_prot_coverage_filtered.RData")

## Protein inference
msgfData <- protein_inference(msgfData)

save(msgfData, file = "msgfData_filtered_final.RData")


rm(list=ls(all=T));gc()


# quant ================================================

## link masic and msgf
load("msgfData_filtered_final.RData")
load("masicData_filtered.RData")

quantData <- link_msms_masic(msgfData, masicData)

save(quantData, file = "quantData.RData")

rm(list=ls(all=T));gc()

## aggregate to protein level

load("quantData.RData")
load("isobaricTagDesign.RData")

quantData <- aggregate_itraq(quantData, isobaricTagFractions, aggregationLevel = c("MixID", "Protein"))

save(quantData, file = "quantData.RData")

rm(list=ls(all=T));gc()

## Separate by samples + take log2-ratio over the reference channel
load("quantData.RData")
load("isobaricTagDesing.RData")

crossTab <- normalizing_by_reference(quantData, isobaricTagSamples, isobaricTagReference)

save(crossTab, file = "crossTab.RData")

rm(list=ls(all=T));gc()

## median-centered normalization
load("crossTab.RData")

crossTab <- normalize(crossTab)

save(crossTab, file = "crossTab_median_centered.RData")


