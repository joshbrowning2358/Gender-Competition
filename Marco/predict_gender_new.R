predictGender <- function(model, dataSet, parameters) UseMethod("predictGender")


predictGender.logit <- function(model, dataSet){
  kClassificationThreshold <- .14

  predictedProbabilities <- predict(model, newdata = dataSet, type = "response")
  ifelse(predictedProbabilities > kClassificationThreshold, 1, 0)
}


library(xgboost)

predictGender.xgb.Booster <- function(model, dataSet){
  kClassificationThreshold <- .5
  
  explanatoryVariables <- xgb.DMatrix(data = dataSet)
  
  predictedProbabilities <- predict(model, explanatoryVariables)
  #ifelse(predictedProbabilities > kClassificationThreshold, 1, 0)
}