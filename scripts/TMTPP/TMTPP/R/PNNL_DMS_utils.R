

get_server_name_for_mtdb = function( mtdbName )
# a way to find which server MT DB is located
{
    con = odbcDriverConnect("DRIVER={SQL Server};SERVER=Pogo;DATABASE=MTS_Master;")
    strSQL = sprintf("SELECT Server_Name
                      FROM V_MTS_MT_DBs
                      WHERE MT_DB_Name = '%s'", mtdbName)
    dbServer = sqlQuery(con,strSQL)
    close(con)
    return(as.character(dbServer[1,1]))
}





# dictionary that defines the suffix of the files given the analysis tool
## Added "MSGFPlus" suffix (JM 4/10/18)
tool2suffix = list("MSGFDB_DTARefinery"="_msgfdb_syn.txt",
                   "MSGFPlus_DTARefinery"="_msgfdb_syn.txt",
                   "MASIC_Finnigan"="_ReporterIons.txt",
                   "MSGFPlus"="_msgfplus_syn.txt",
                   "MSGFPlus_MzML"="_msgfplus_syn.txt")



get_dms_job_records = function(
                                jobs = NULL,
                                datasetPttrn = "",
                                experimentPttrn = "",
                                toolPttrn = "",
                                parPttrn = "",
                                settingsPttrn = "",
                                fastaPttrn = "",
                                proteinOptionsPttrn = "",
                                intrumentPttrn = ""){

    # first check if the input is valid
    x = as.list(environment())
    x[["jobs"]] = NULL
    if( all(x == "") & is.null(jobs) ){
        stop("insufficients arguments provided")
    }
    if( any(x != "") & !is.null(jobs) ){
        stop("can't provide both: job list and search terms")
    }

    # initialize connection

    con <- odbcDriverConnect("DRIVER={SQL Server};SERVER=gigasax;DATABASE=dms5;")

    # set-up query based on job list
    if(!is.null(jobs)){
        strSQL = sprintf("SELECT *
                          FROM V_Mage_Analysis_Jobs
                          WHERE [Job] IN ('%s')
                          ",
                            paste(jobs,sep="",collapse="',\n'"))
    }else{
        strSQL = sprintf("SELECT *
                          FROM V_Mage_Analysis_Jobs
                          WHERE [Dataset] LIKE '%%%s%%'
                          AND [Experiment] LIKE '%%%s%%'
                          AND [Tool] LIKE '%%%s%%'
                          AND [Parameter_File] LIKE '%%%s%%'
                          AND [Settings_File] LIKE '%%%s%%'
                          AND [Protein Collection List] LIKE '%%%s%%'
                          AND [Protein Options] LIKE '%%%s%%'
                          AND [Instrument] LIKE '%%%s%%'
                          ",
                            datasetPttrn,
                            experimentPttrn,
                            toolPttrn,
                            parPttrn,
                            settingsPttrn,
                            fastaPttrn,
                            proteinOptionsPttrn,
                            intrumentPttrn)
    }
    locationPointersToMSMSjobs = sqlQuery(con, strSQL, stringsAsFactors=FALSE)
    close(con)
    return(locationPointersToMSMSjobs)
}




get_tool_output_files_for_job_number <- function(jobNumber, toolName,
                                                 filePattern, mostRecent=TRUE)
{
    # get job records first. This will be useful to get datasetfolder
    jobRecord = get_dms_job_records(jobNumber)
    datasetFolder = dirname( as.character(jobRecord$Folder))

    # get tool's subfolder
    if( is.null(toolName) ){
        toolFolder = ''
    }else{
        # return stuff from the main dataset folder
        toolFolder = get_output_folder_for_job_and_tool(jobNumber, toolName, mostRecent)
    }
    #
    candidateFiles = list.files(file.path(datasetFolder, toolFolder),
                                pattern=filePattern, full.names=TRUE,
                                ignore.case=TRUE)
    #
    if(length(candidateFiles) == 1){
        return(candidateFiles)
    }else{
        return(NA)
    }
}



get_output_folder_for_job_and_tool <- function(jobNumber, toolName, mostRecent=TRUE)
{
    con = odbcDriverConnect("DRIVER={SQL Server};SERVER=Gigasax;DATABASE=DMS_Pipeline;")
    strSQLPattern = "SELECT Output_Folder
                     FROM V_Job_Steps_History
                     WHERE (Job = %s) AND (Tool = '%s') AND (Most_Recent_Entry = 1)"
    strSQL = sprintf( strSQLPattern, jobNumber, toolName)
    qry = sqlQuery(con, strSQL)
    close(con)
    return(as.character(qry[1,1]))
}
# get_output_folder_for_job_and_tool(863951, "DTA_Refinery")






# Get AScore results for a given data package
get_AScore_results <- function(dataPkgNumber)
{
    #

    con <- odbcDriverConnect("DRIVER={SQL Server};SERVER=gigasax;DATABASE=dms5;")
    strSQL <- sprintf("SELECT *
                        FROM V_Mage_Analysis_Jobs
                        WHERE (Dataset LIKE 'DataPackage_%s%%')", dataPkgNumber)
    jobs <- sqlQuery(con, strSQL, stringsAsFactors=FALSE)
    close(con)
    #
    if(nrow(jobs) == 1){

        dlist <- dir(as.character(jobs["Folder"]))
        idx <- which.max(as.numeric(sub("Step_(\\d+)_.*", "\\1", dlist))) # the Results supposed to be in the last folder
        ascoreResultDB <- file.path( jobs["Folder"], dlist[idx], "Results.db3")
        db <- dbConnect(SQLite(), dbname = ascoreResultDB)
        AScores <- dbGetQuery(db, "SELECT * FROM t_results_ascore")
        dbDisconnect(db)
        return(AScores)
    }else{
        return(NULL)
    }
}




get_job_records_by_dataset_package <- function(dataPkgNumber)
{

    con <- odbcDriverConnect("DRIVER={SQL Server};SERVER=gigasax;DATABASE=dms5;")
    strSQL = sprintf("
                SELECT *
                FROM V_Mage_Data_Package_Analysis_Jobs
                WHERE Data_Package_ID = %s",
                dataPkgNumber)
    jr <- sqlQuery(con, strSQL, stringsAsFactors=FALSE)
    close(con)
    return(jr)
}


get_job_PSM_records_by_data_package <- function(dataPkgNumber) {

  con <- odbcDriverConnect("DRIVER={SQL Server};SERVER=gigasax;DATABASE=dms5;")
  strSQL = sprintf("
                  SELECT *
                  FROM V_Data_Package_Analysis_Job_PSM_List_Report
                  WHERE [Data Pkg] = %s",
                   dataPkgNumber)
  jr <- sqlQuery(con, strSQL, stringsAsFactors=FALSE)
  close(con)
  return(jr)

}


get_results_for_multiple_jobs = function( jobRecords){
    toolName = unique(jobRecords[["Tool"]])
    if (length(toolName) > 1){
        stop("Contains results of more then one tool.")
    }
    results = plyr::ldply( jobRecords[["Folder"]],
                     get_results_for_single_job,
                     fileNamePattern=tool2suffix[[toolName]],
                    .progress = "text")
    return( results )
}



get_results_for_multiple_jobs.dt = function( jobRecords){
    toolName = unique(jobRecords[["Tool"]])
    if (length(toolName) > 1){
        stop("Contains results of more then one tool.")
    }
    results = plyr::llply( jobRecords[["Folder"]],
                     get_results_for_single_job.dt,
                     fileNamePattern=tool2suffix[[toolName]],
                    .progress = "text")
    results.dt <- data.table::rbindlist(results)
    return( as.data.frame(results.dt) ) # in the future I may keep it as data.table
}



get_results_for_single_job = function(pathToFileLocation, fileNamePattern ){
    pathToFile = list.files( path=as.character(pathToFileLocation),
                             pattern=fileNamePattern,
                             full.names=T)
    if(length(pathToFile) == 0){
        stop("can't find the results file")
    }
    if(length(pathToFile) > 1){
        stop("ambiguous results files")
    }
    results = read.delim( pathToFile, header=T, stringsAsFactors = FALSE)
    dataset = strsplit( basename(pathToFile), split=fileNamePattern)[[1]]
    out = data.frame(Dataset=dataset, results, stringsAsFactors = FALSE)
    return(out)
}

get_results_for_single_job.dt = function(pathToFileLocation, fileNamePattern ){
    pathToFile = list.files( path=as.character(pathToFileLocation),
                             pattern=fileNamePattern,
                             full.names=T)
    if(length(pathToFile) == 0){
        stop("can't find the results file")
    }
    if(length(pathToFile) > 1){
        stop("ambiguous results files")
    }
    results = read.delim( pathToFile, header=T, stringsAsFactors = FALSE)
    dataset = strsplit( basename(pathToFile), split=fileNamePattern)[[1]]
    out = data.table(Dataset=dataset, results)
    return(out)
}


