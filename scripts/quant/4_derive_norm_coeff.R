

derive_sample_to_sample_norm_log2coeff <- function(crossTab)
{
   fully.present <- rowSums(is.na(crossTab)) == 0
   crossTab <- crossTab[fully.present,]
   norm.coeff <- apply(crossTab, 2, median, na.rm=TRUE)
   save(norm.coeff, file="norm.coeff.RData")
   return(norm.coeff)
}



#--------------------------------------------------------------------
load("crossTab.RData") 
norm.coeff <- derive_sample_to_sample_norm_log2coeff(crossTab)
save(norm.coeff, file="norm.coeff.RData")

# #--------------------------------------------------------------------
# load("crossTab_peptide_level.RData") 
# norm.coeff <- derive_sample_to_sample_norm_log2coeff(crossTab)
# save(norm.coeff, file="norm.coeff_peptide_level.RData")
