#' Fit a Non-Parametric Density
#' 
#' This function is for fitting a non-parametric density to single variables, 
#' and is for use in the Naive Bayes model framework.
#' 
#' @param independentVariable Vector with the independent variable observations.
#' @param labels Vector with the class labels/target variables/dependent 
#'   variable observations.
#' @param variableName The name of the independent variable, used for naming of 
#'   the returned object.
#' @param targetName The name of the dependent variable, also used for naming of
#'   the returned object.
#' 
#' @return A data.table object containing the density for each class at various points.
#' 

fitNonParametricDensity <- function(independentVariable, labels, variableName, targetName = "GENDER"){
  stopifnot(length(independentVariable) == length(labels))
  densityEstimate <- lapply(unique(labels), function(label){
    fit <- density(x=independentVariable[labels==label], bw="SJ")
    fit$x <- round(fit$x, 5)
    return(data.table(x = fit$x, y = fit$y, label=label))
  })
  result <- do.call("rbind", densityEstimate)
  setnames(result, c(variableName, "density", targetName))
}