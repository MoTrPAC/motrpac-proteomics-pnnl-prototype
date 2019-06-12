
# source("_parameters.R") # get dataPackageNumber


library("devtools")
source_url("https://raw.githubusercontent.com/vladpetyuk/PNNL_misc/master/PNNL_DMS_utils.R")

# 1
jobRecords <- get_job_records_by_dataset_package("2900")


jobRecords <- subset(jobRecords, Tool == "MSGFPlus_MzML")

# 2
tool2suffix$MSGFPlus_MzML <- "_msgfplus_syn.txt"
system.time({
    msgfData <- get_results_for_multiple_jobs.dt(jobRecords)
})

save(msgfData, file="msgfData_original.RData")

