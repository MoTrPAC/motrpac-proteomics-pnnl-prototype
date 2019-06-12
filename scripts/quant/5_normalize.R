



normalize <- function(crossTab, norm.coeff)
{
   crossTab <- sweep( crossTab, 2, norm.coeff[colnames(crossTab)], '-')
}



#--------------------------------------------------------------------
# source("_parameters.R")
load("norm.coeff.RData") # this can be elsewhere as in case of phospho-data
load("crossTab.RData")

crossTab <- normalize(crossTab, norm.coeff)
save( crossTab, file="crossTab.RData")


