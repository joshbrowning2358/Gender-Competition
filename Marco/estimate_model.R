estimateModel <- function(model, dataSet, parameters) UseMethod("estimateModel")

estimateModel.logit <- function(model, dt) {
  glm(DependentVariable ~ . -KeyId, data = dt, family = "binomial")
}


library(xgboost)
estimateModel.xgboost <- function(model, 
                                  dataSet,
                                  trainingSetPercentage = .8,
                                  parameters = list(xgbParameters = list(objective   = "binary:logistic", 
                                                                    eta              = 0.3,
                                                                    max_depth        = 6,
                                                                    nthread          = 8,
                                                                    subsample        = 0.8,
                                                                    colsample_bytree = 0.8,
                                                                    min_child_weight = 1),
                                                    nRounds = 100000,
                                                    stopAfterNRoundsWithNoImprovement = 500)) {
    
  nColumns <- ncol(dataSet)
  
  getTrainingAndTestSet(dataSet, trainingSetPercentage) {
    nObservations <- nrow(dataSet)
    
    trainingSetSize <- round(nObservations*trainingSetPercentage)
    trainingSetRows <- sample(1:nObservations, trainingSetSize)
    
    trainingData <- dataSet[trainingSetRows, ]
    testData <- dataSet[-trainingSetRows,]
    
    list(trainingData = trainingData, testData = testData)
  }
  
  
  dMatrixDataSet <- xgb.DMatrix(data = as.matrix(dataSet[, 3:nColumns, with = FALSE]), 
                                label = as.matrix(dataSet[, "DependentVariable", with = FALSE]))

  watchlist <- list(evaluationSet = dMatrixDataSet)
  
  trainedXgBoostModel <- xgb.train(params    = parameters$xgbParameters, 
                                   data      = dMatrixDataSet, 
                                   nrounds   = parameters$nRounds,
                                   early.stop.round = parameters$stopAfterNRoundsWithNoImprovement,
                                   watchlist = watchlist,
                                   maximize = FALSE)  
  
  trainedXgBoostModel
}