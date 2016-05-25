predictNonParametricDensity <- function(model, newdata){
  variableName <- colnames(model)[1]
  targetVariable <- colnames(model)[ncol(model)]
  newdata <- newdata[, variableName, with=FALSE]
  newdata[, key := 1:nrow(newdata)]
  predictionLocations <- unique(newdata[[variableName]])
  for(label in unique(model[[targetVariable]])){
    subModel <- model[get(targetVariable) == label, ]
    densityEstimates <- spline(x=subModel[[variableName]], y=subModel$density, xout=predictionLocations)
    subModel <- data.table(x = densityEstimates$x, y = densityEstimates$y)
    setnames(subModel, "y", paste0("density.", label))
    newdata <- merge(newdata, subModel, by.x=variableName, by.y="x")
  }
  newdata <- newdata[order(key), ]
  newdata[, c("key", variableName) := NULL]
  return(newdata)
}