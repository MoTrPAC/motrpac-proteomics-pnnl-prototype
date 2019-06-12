
#' Filter MASIC Results
#'
#' Filter MASIC Results by Signal to Noise Ratios and Interference Score
#'
#' @param masicData data.frame Original MASIC Results table
#' @param s2n_min_threshold numeric The minimum signal to noise ratio threshold. Default is 4
#' @param interference_score numeric The minimum interference score threshold. Default is 0.90
#' @return data.frame A filtered version of MASIC Results table
#' @importFrom dplyr contains starts_with
#' @importFrom tidyr gather spread
#' @export filter_masic
#'
#' @examples
#' \dontrun{
#' masicData_filtered <- filter_masic(masicData)
#' }
filter_masic <- function(masicData, s2n_min_threshold = 4, interference_score = 0.90) {

	masicData <- filter(masicData, InterferenceScore > interference_score)

	selected <- masicData %>%
		select(Dataset, ScanNumber, contains("SignalToNoise")) %>%
		gather(channel, s2n, -c(Dataset, ScanNumber)) %>%
		mutate(s2n = ifelse(is.na(s2n), 0, s2n)) %>%
		filter(s2n > s2n_min_threshold) %>%
		select(-s2n) %>%
		mutate(channel = sub("_SignalToNoise","",channel))

	masicData <- masicData %>%
		select(Dataset, ScanNumber, starts_with("Ion"), -contains("SignalToNoise")) %>%
		gather(channel,intensity,-c(Dataset,ScanNumber)) %>%
		inner_join(selected) %>%
		spread(channel, intensity)

	return(masicData)
}
