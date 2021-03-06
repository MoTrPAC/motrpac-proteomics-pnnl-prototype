% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/normalizing_by_reference.R
\name{normalizing_by_reference}
\alias{normalizing_by_reference}
\title{Channel Loading Normalization}
\usage{
normalizing_by_reference(quantData, isobaricTagSamples,
  isobaricTagReference)
}
\arguments{
\item{quantData}{data.frame}

\item{isobaricTagSamples}{data.frame}

\item{isobaricTagReference}{data.frame}
}
\value{
data.frame
}
\description{
Channel Loading Normalization
}
\examples{
\dontrun{
crossTab <- normalizing_by_reference(quantData, isobaricTagSamples, isobaricTagReference)
}
}
