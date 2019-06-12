# dividing by reference and reporting cross-tab



library("reshape2")

# quantData -- long form
# isobaricTagSamples
# isobaricTagReference


normalizing_by_reference <- function(quantData, isobaricTagSamples, isobaricTagReference)
{

    quantData <- melt(quantData, 
             id.vars=c("MixID","Specie"),
             measure.vars=grep("Ion_", colnames(quantData), value=TRUE),
             variable.name="ReporterChannel",
             value.name="Abundance")

    # adding ReporterAlias and QuantBlock (SubMixID)
    quantData <- merge(quantData, 
                 isobaricTagSamples, 
                 by.x=c("MixID", "ReporterChannel"), 
                 by.y=c("MixID","ReporterIon"))


    out <- list()
    #~~~
    for(i in seq_len(nrow(isobaricTagReference))){
        
        # unique MixID/QuantBlock combo
        ref_i <- isobaricTagReference[i,] 
        
        # subset a piece that is unique to that reference
        quantData_i <- subset(quantData, MixID == ref_i$MixID & QuantBlock == ref_i$QuantBlock)
        
        # now make wide by ReporterAlias
        quantData_i_w <- dcast(quantData_i, Specie ~ ReporterAlias, value.var='Abundance')
        
        # compute reference values
        ref.values <- with(quantData_i_w, eval(parse(text=ref_i$Reference)))
        
        # take the ratios over the reference
        quantData_i_w[,-match("Specie",colnames(quantData_i_w))] <- 
            quantData_i_w[,-match("Specie",colnames(quantData_i_w))]/ref.values
        
        # switching from ReporterAlias to MeasurementName
        quantData_i_l <- melt(quantData_i_w, id.vars="Specie", 
                              variable.name="ReporterAlias", value.name="Ratio")
        sampleNaming <- subset( isobaricTagSamples, 
                                MixID == ref_i$MixID & 
                                QuantBlock == ref_i$QuantBlock &
                                !is.na(MeasurementName) & MeasurementName != '',
                                select=c("ReporterAlias","MeasurementName"))
        quantData_i_l <- merge(quantData_i_l, sampleNaming)
        quantData_i_l <- quantData_i_l[,-match("ReporterAlias", colnames(quantData_i_l))]
        out <- c(out, list(quantData_i_l))
    }
    #~~~
    out <- Reduce(rbind, out)
    out <- acast(out, Specie ~ MeasurementName, value.var="Ratio")

    # Inf and 0 values turn into NA
    out[is.infinite(out)] <- NA
    out[out == 0] <- NA
    
    # log2-transform
    out <- log2(out)
    return(out)
}



#--------------------------------------------------------------------
load("quantData.RData") # quantData
load("../masicData/isobaricTagDesign.RData") # isobaricTagSamples, isobaricTagReference


crossTab <- normalizing_by_reference(quantData, 
                                     isobaricTagSamples, 
                                     isobaricTagReference)


# remove completely missing
nrow(crossTab)
crossTab <- crossTab[apply(!is.na(crossTab), 1, any),]
nrow(crossTab)


save(crossTab, file="crossTab.RData")


# 
# #--------------------------------------------------------------------
# load("quantData_peptide_level.RData") # quantData
# load("isobaricTagDesign.RData") # isobaricTagSamples, isobaricTagReference
# 
# crossTab <- normalizing_by_reference(quantData, isobaricTagSamples, isobaricTagReference)
# 
# save(crossTab, file="crossTab_peptide_level.RData")
# 
# 
# 
# 
# 
