fitNonParametricDensity <- function(independentVariable, labels, variableName, targetName = "GENDER"){
  densityEstimate <- lapply(unique(labels), function(label){
    fit <- density(x=independentVariable[labels==label], bw="SJ", from=0, to=(23 + 59/60), n=24*60)
    fit$x <- round(fit$x, 5)
    return(data.table(x = fit$x, y = fit$y, label=label))
  })
  result <- do.call("rbind", densityEstimate)
  setnames(result, c(variableName, "density", targetName))
}