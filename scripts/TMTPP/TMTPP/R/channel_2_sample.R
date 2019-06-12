
#' TMT Label Design
#'
#' Isobaric Tag Labeling Scheme for Samples
#'
#' @param masicData data.frame. Original MASIC Results table
#' @param label_file A character vector. The path to the file that links reporter ion channels to samples
#' @param ReporterConverter A character vector. Path to the file that has conversion between TMT Channel and Reporter Ion
#'
#' @return Saves R object to working directory containing three data.frames: isobaricTagSamples, isobaricTagReference, and
#' isobaricTagFractions
#' @importFrom dplyr distinct filter inner_join mutate select %>%
#' @importFrom stringr str_extract
#' @importFrom utils read.delim
#' @export channel_2_sample
#'
#' @examples
#' \dontrun{
#' channel_2_sample(masicData, label_file = "./pre_isobaricTagSamples.txt",
#' ReporterConverter = "./ReporterConverter.txt")
#' }
channel_2_sample <- function(masicData, label_file, ReporterConverter) {

isobaricTagFractions <- masicData %>%
    select(Dataset) %>%
    distinct() %>%
    mutate(MixID = str_extract(Dataset, "B[0-9]+S[0-9]+"))

isobaricTagSamples <- read.delim(label_file,
                                 stringsAsFactors = F,
								 na.strings = "")

isobaricTagSamples[is.na(isobaricTagSamples)] <- ""

ReporterConverter <- read.delim(ReporterConverter,
                                 stringsAsFactors = F,
								 na.strings = "")

isobaricTagSamples <- inner_join(isobaricTagSamples, ReporterConverter) %>%
   select(-TMTChannel)

isobaricTagReference <- data.frame(MixID = unique(isobaricTagFractions$MixID),
                                   QuantBlock = rep(1, length(unique(isobaricTagFractions$MixID))),
                                   Reference = rep("ref", length(unique(isobaricTagFractions$MixID))))

save(isobaricTagFractions, isobaricTagSamples, isobaricTagReference, file = "isobaricTagDesign.RData")

}
