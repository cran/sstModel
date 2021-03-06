% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cashflow-valuation.R
\name{valExpression.cashflow}
\alias{valExpression.cashflow}
\title{Building the Valuation Expression for a Fixed-Income-Asset}
\usage{
\method{valExpression}{cashflow}(object, market.risk, standalone = NULL, ...)
}
\arguments{
\item{object}{S3 object of class cashflow.}

\item{market.risk}{S3 object of class marketRisk created using
\code{marketRisk}.}

\item{standalone}{S3 object of class standalone.}

\item{...}{additional arguments.}
}
\value{
a character value. The expression representing the valuation
  of the cashflow position.
}
\description{
\code{valExpression} is a generic S3 method for classes
  inheriting from item. It returns the valuation expression.
}
\seealso{
\code{\link{valExpression}}, \code{\link{cashflow}},
  \code{\link{marketRisk}}, \code{\link{standalone}}.
}
