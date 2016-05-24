predictGender <- function(model, dataSet, parameters) UseMethod("predictGender")


predictGender.logit <- function(model, dataSet){
  kClassificationThreshold <- .14

  predictedProbabilities <- predict(model, newdata = dataSet, type = "response")
  ifelse(predictedProbabilities > kClassificationThreshold, 1, 0)
}


library(xgboost)

predictGender.xgb.Booster <- function(model, dataSet){
  kClassificationThreshold <- .5
  
  nColumns <- ncol(dataSet)
  explanatoryVariables <- xgb.DMatrix(data = as.matrix(dataSet[, 3:nColumns, with = FALSE]))
  
  predictedProbabilities <- predict(model, explanatoryVariables)
  ifelse(predictedProbabilities > kClassificationThreshold, 1, 0)
}