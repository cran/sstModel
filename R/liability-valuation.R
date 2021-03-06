#' Building the Valuation Expression for an Insurance Liability
#'
#' @description \code{valExpression} is a generic S3 method for S3 classes
#'   inheriting from item. It returns the valuation expression.
#'
#' @param object S3 object of class liability.
#' @param market.risk S3 object of class marketRisk created using the constructor
#'   \code{marketRisk}.
#' @param standalone S3 object of class standalone.
#' @param ... additional arguments.
#'
#' @return a character value. The expression representing the valuation
#'   of the liability position.
#'
#' @seealso \code{\link{valExpression}}, \code{\link{liability}},
#'   \code{\link{marketRisk}}, \code{\link{standalone}}.
#'
#' @export
valExpression.liability  <- function(object, market.risk, standalone = NULL, ...) {

  # PRIVATE FUNCTION.

  return(logNormalExpression(object      = object,
                             market.risk = market.risk,
                             standalone  = standalone))

}

#' Building the Valuation Function for an Insurance Liability Valuation
#'
#' @description \code{valFunction} is a generic S3 method for classes
#'   inheriting from item. It returns the valuation function.
#'
#' @param object S3 object of class liability.
#' @param market.risk S3 object of class marketRisk created using
#'   \code{marketRisk}.
#' @param with.constant a logical value, should the expression be with constant or not?
#' @param ... additional arguments.
#'
#' @return a function with one argument:
#'           \itemize{
#'             \item \code{x}: a matrix of simulations (numeric values) with named columns corresponding
#'               exactly to the name of base risk-factors in \code{marketRisk} keeping the
#'               same order, or an unnamed vector of simulations (numeric values) keeping the same
#'               ordering of base risk-factors as in \code{marketRisk}.
#'           }
#'
#' @seealso \code{\link{valFunction}}, \code{\link{liability}}.
#'
#' @export
valFunction.liability  <- function(object, market.risk, with.constant = T, ...) {

  # PUBLIC FUNCTION.

  # explicit evaluation of parameters in closure
  force(object)
  force(market.risk)
  force(with.constant)

  # liability checks
  checks <- check(object = object, market.risk = market.risk)

  if (!checks) {
    stop("Invalid liability for marketRisk, see ?valFunction.")
  }

  # obtain the liability information
  liability.info <- valInfo.liability(object      = object,
                                      market.risk = market.risk,
                                      standalone  = NULL)

  # return the evaluation function for the cashflow
  if (with.constant) {
    return( function(x) {

              # type checks
              if (!(is.matrix(x) & is.numeric(x)) && !is.numeric(x)) {
                stop("Invalid types, see ?valFunction.")
              }
              if (!is.matrix(x) && (length(x) != length(market.risk$name))) {
                stop("Invalid dimensions, see ?valFunction.")
              }
              if (any(!is.finite(x))) {
                stop("Missing values, see ?valFunction.")
              }
              if (!is.matrix(x)) {
                x <- matrix(x, nrow = 1)
                colnames(x) <- market.risk$name
              }

              # name checks
              if (is.null(colnames(x)) || !identical(colnames(x), market.risk$name)) {
                stop("Invalid dimensions or colnames, see ?valFunction.")
              }

              exponent <- matrix(NA, nrow = nrow(x),
                                 ncol = length(liability.info$risk.factor$name))


              for (i in 1:ncol(exponent)) {
                exponent[,i] <- liability.info$risk.factor$scale[i] *
                                x[,liability.info$risk.factor$name[i]]
              }

              return(liability.info$exposure * (exp(apply(exponent, 1, sum) +
                                                    liability.info$constant)-1))

    })

  } else {
    return( function(x) {

              # type checks
              if (!(is.matrix(x) & is.numeric(x)) && !is.numeric(x)) {
                stop("Invalid types, see ?valFunction.")
              }
              if (!is.matrix(x) && (length(x) != length(market.risk$name))) {
                stop("Invalid dimensions, see ?valFunction.")
              }
              if (any(!is.finite(x))) {
                stop("Missing values, see ?valFunction.")
              }
              if (!is.matrix(x)) {
                x <- matrix(x, nrow = 1)
                colnames(x) <- market.risk$name
              }

              # name checks
              if (is.null(colnames(x)) || !identical(colnames(x), market.risk$name)) {
                stop("Invalid dimensions or colnames, see ?valFunction.")
              }

              exponent <- matrix(NA, nrow = nrow(x),
                                 ncol = length(liability.info$risk.factor$name))


              for (i in 1:ncol(exponent)) {
                exponent[,i] <- liability.info$risk.factor$scale[i] *
                                x[,liability.info$risk.factor$name[i]]
              }

              return(liability.info$exposure * (exp(apply(exponent, 1, sum))-1))

    })
  }
}

#' Providing Information for Insurance Liability Valuation from a marketRisk
#'
#' @description \code{valInfo} is a generic S3 method for classes
#'   inheriting from item. It returns sufficient information for the
#'   creation of the valuation function of the item.
#'
#' @param object S3 object of class liability.
#' @param market.risk S3 object of class marketRisk created using the constructor
#'   \code{marketRisk}.
#' @param standalone S3 object of class standalone.
#' @param ... additional arguments.
#'
#' @return A list with the following elements:
#' \itemize{
#'   \item \code{exposure}: numeric value of length one. The nominal value of the liability.
#'   \item \code{constant}: numeric value of length one. The constant centering the
#'     log-normal expression.
#'   \item \code{risk.factor}: a \code{data.frame} with columns:
#'   \itemize{
#'     \item \code{name}: character value. The names of the base risk
#'       factors.
#'     \item \code{id}: integer value. The position of the base risk
#'       factors in the covariance matrix in \code{marketRisk}.
#'     \item \code{scale}: numeric value. The scales associated to the
#'       base risk factors.
#'   }
#' }
#'
#'
#' @seealso \code{\link{valInfo}}, \code{\link{liability}},
#'   \code{\link{marketRisk}}, \code{\link{standalone}}.
#'
#' @export
valInfo.liability  <- function(object, market.risk, standalone = NULL, ...) {

  # this function shall only be called after check.liability.
  # PRIVATE FUNCTION.

  risk.factor <- data.frame(name  = character(),
                            id    = integer(),
                            scale = numeric(),
                            stringsAsFactors = FALSE)

  mapping <- getMappingTime(object = market.risk,
                            time   = object$time)

  if (is.null(standalone) || rateIsIn(object   = standalone,
                                      currency = object$currency,
                                      horizon  = mapping)) {

    risk.factor <- data.frame(name  = getRateName(object   = market.risk,
                                                  currency = object$currency,
                                                  horizon  = mapping),
                              id    = getRateId(object   = market.risk,
                                                currency = object$currency,
                                                horizon  = mapping),
                              scale = -object$time *
                                getRateScale(object   = market.risk,
                                             currency = object$currency,
                                             horizon  = mapping),
                              stringsAsFactors = FALSE)

  }

  if (object$currency == market.risk$base.currency) {
    # minus sign here because of liabilities being evaluated with minus sign
    exposure <- -object$value *
      exp(-object$time *
            getInitialRate(object   = market.risk,
                           time     = object$time,
                           currency = object$currency))

  } else {
    exposure <- -object$value *
      exp(-object$time *
            getInitialRate(object   = market.risk,
                           time     = object$time,
                           currency = object$currency)) *
      getInitialFX(object = market.risk,
                   from   = object$currency,
                   to     = market.risk$base.currency)

    if (is.null(standalone) || currencyIsIn(object   = standalone,
                                            from     = object$currency,
                                            to       = market.risk$base.currency)) {

      risk.factor <- rbind(risk.factor,
                           data.frame(name  = getCurrencyName(object  = market.risk,
                                                              from    = object$currency,
                                                              to      = market.risk$base.currency),
                                      id    = getCurrencyId(object  = market.risk,
                                                            from    = object$currency,
                                                            to      = market.risk$base.currency),
                                      scale = getCurrencyScale(object = market.risk,
                                                               from   = object$currency,
                                                               to     = market.risk$base.currency),
                                      stringsAsFactors = F))
    }
  }

  constant <- computeConstant(id         = risk.factor$id,
                              scale      = risk.factor$scale,
                              cov.matrix = market.risk$cov.mat)

  l <- list(exposure    = exposure,
            constant    = constant,
            risk.factor = risk.factor)

  return(l)
}
