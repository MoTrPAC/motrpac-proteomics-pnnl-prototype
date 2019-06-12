

#' Get Job Results from DMS
#'
#' @param dataPackageNumber Data package ID(s) from DMS
#'
#' @return Writes two tables to tab-delimited .txt files. (MASIC and MSGF+ Results)
#' @importFrom plyr llply
#' @importFrom data.table rbindlist
#' @importFrom RODBC odbcDriverConnect sqlQuery
#' @importFrom stringr str_detect
#' @importFrom utils write.table
#' @export get_data
#'
#' @examples
#' \dontrun{
#' get_data(dp1)
#' get_data(c(dp1, dp2, dp3))
#' }
get_data <- function(dataPackageNumber) {

  # Get job records ====
  if (length(dataPackageNumber) > 1) {

    job_rec_ls <- lapply(dataPackageNumber, get_job_records_by_dataset_package)
    jobRecords <- Reduce(rbind, job_rec_ls)

  }

  else {

    jobRecords <- get_job_records_by_dataset_package(dataPackageNumber)

  }

  # Get MASIC ====
  jobRecords_MASIC <- filter(jobRecords, str_detect(jobRecords$Tool, "MASIC") == TRUE)

  system.time({
    masicData <- get_results_for_multiple_jobs.dt(jobRecords_MASIC)
  })


  results = llply( jobRecords_MASIC[["Folder"]],
                   get_results_for_single_job.dt,
                   fileNamePattern="_SICstats.txt",
                   .progress = "text")
  results.dt <- rbindlist(results)
  masicStats <- as.data.frame(results.dt)


  # hack to remove redundant Dataset column
  masicData  <- masicData[,-2]
  masicStats <- masicStats[,-2]

  # Rename FragScanNumber to ScanNumber
  masicStats <- dplyr::rename(masicStats, ScanNumber = FragScanNumber)

  # Combine masicData and masicStats
  x <- select(masicData, Dataset, ScanNumber, starts_with("Ion"), -contains("Resolution"))
  y <- select(masicStats, Dataset, ScanNumber, contains('InterferenceScore'))
  z <- inner_join(x, y)

  masicData <- z

  save(masicData, file = "masicData_original.RData", compress = T)


  # Get MSGF ====
  jobRecords_MSGF <- filter(jobRecords, str_detect(jobRecords$Tool, "MSGFPlus") == TRUE)

  system.time({
    msgfData <- get_results_for_multiple_jobs.dt(jobRecords_MSGF)
  })

  save(msgfData, file = "msgfData_original.RData", compress = T)


}
