
dataPackageNumber = 2900

library("devtools")
source_url("https://raw.githubusercontent.com/vladpetyuk/PNNL_misc/master/PNNL_DMS_utils.R")


# 1
jobRecords <- get_job_records_by_dataset_package(dataPackageNumber)
table(jobRecords$Tool)

# 3
jobRecords <- subset(jobRecords, Tool == "MASIC_Finnigan")
# jobRecords <- subset(jobRecords, grepl("CPTAC3_Harmonization_PNNL_W", Dataset))






system.time({
    masicData <- get_results_for_multiple_jobs.dt(jobRecords)
})


# save(masicData, file="masicData.RData")


# > tool2suffix
# $MSGFDB_DTARefinery
# [1] "_msgfdb_syn.txt"
# 
# $MSGFPlus_DTARefinery
# [1] "_msgfdb_syn.txt"
# 
# $MASIC_Finnigan
# [1] "_ReporterIons.txt"
# 
# "_SICstats.txt"


# > get_results_for_multiple_jobs.dt
# function( jobRecords){
#     toolName = unique(jobRecords[["Tool"]])
#     if (length(toolName) > 1){
#         stop("Contains results of more then one tool.")
#     }
#     library("plyr")
#     library("data.table")
#     results = llply( jobRecords[["Folder"]], 
#                      get_results_for_single_job.dt, 
#                      fileNamePattern=tool2suffix[[toolName]],
#                      .progress = "text")
#     results.dt <- rbindlist(results)
#     return( as.data.frame(results.dt) ) # in the future I may keep it as data.table
# }
# 


# > get_results_for_single_job.dt
# function(pathToFileLocation, fileNamePattern ){
#     pathToFile = list.files( path=as.character(pathToFileLocation), 
#                              pattern=fileNamePattern, 
#                              full.names=T)
#     if(length(pathToFile) == 0){
#         stop("can't find the results file")
#     }
#     if(length(pathToFile) > 1){
#         stop("ambiguous results files")
#     }
#     results = read.delim( pathToFile, header=T, stringsAsFactors = FALSE)
#     dataset = strsplit( basename(pathToFile), split=fileNamePattern)[[1]]
#     out = data.table(Dataset=dataset, results)
#     return(out)
# }




library(plyr)
library(data.table)
results = llply( jobRecords[["Folder"]],
                 get_results_for_single_job.dt,
                 fileNamePattern="_SICstats.txt",
                 .progress = "text")
results.dt <- rbindlist(results)
masicStats <- as.data.frame(results.dt)

# hack to remove redundant Dataset column
masicData  <- masicData[,-2] # use make.names and then remove Dataset.1
masicStats <- masicStats[,-2]
colnames(masicStats)[colnames(masicStats) == "FragScanNumber"] <- "ScanNumber" # dplyr::rename

library(dplyr)

x <- select(masicData, Dataset, ScanNumber, starts_with("Ion"), -contains("Resolution"))
y <- select(masicStats, Dataset, ScanNumber, InterferenceScore)
z <- inner_join(x, y)
masicData <- z
save(masicData, file="masicData_original.RData")






