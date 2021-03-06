% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sstOutput-base.R
\name{getMarketRisk.sstOutput}
\alias{getMarketRisk.sstOutput}
\title{Get Market Risk}
\usage{
\method{getMarketRisk}{sstOutput}(object, exp.shortfall = F, ...)
}
\arguments{
\item{object}{S3 object of class sstOutput.}

\item{exp.shortfall}{logical value, by default set to \code{FALSE}.
Should the expected shortfall be returned?}

\item{...}{additional arguments.}
}
\value{
a numeric value.
}
\description{
S3 generic method to get market risk.
}
\seealso{
\code{\link{getMarketRisk}}.
}
