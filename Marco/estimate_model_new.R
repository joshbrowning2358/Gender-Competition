estimateModel <- function(model, dataSet, parameters) UseMethod("estimateModel")

estimateModel.logit <- function(model, dt) {
  glm(DependentVariable ~ . -KeyId, data = dt, family = "binomial")
}


library(xgboost)
estimateModel.xgboost <- function(model, 
                                  dataSet,
                                  trainingSetPercentage = .9,
                                  parameters = list(xgbParameters = list(objective   = "binary:logistic", 
                                                                         eval_metric = "auc",
                                                                         eta              = 0.3,
                                                                         max_depth        = 6,
                                                                         nthread          = 8,
                                                                         
                                                                         subsample        = 0.8,
                                                                         colsample_bytree = 0.8,
                                                                         min_child_weight = 1),

                                                    nRounds = 50000,
                                                    stopAfterNRoundsWithNoImprovement = 250)) {
    
  nObservations <- nrow(dataSet$explanatoryVariables)
  
  trainingSetSize <- round(nObservations*trainingSetPercentage)
  trainingSetRows <- sample(1:nObservations, trainingSetSize)
  
  dMatrixTrainingDataSet <- xgb.DMatrix(data = dataSet$explanatoryVariables[trainingSetRows, ], 
                                        label = as.matrix(ifelse(dataSet$dependentVariable[trainingSetRows, 
                                                                                           GENDER] == "F", 1, 0)))
  
  dMatrixTestDataSet <- xgb.DMatrix(data = dataSet$explanatoryVariables[-trainingSetRows, ], 
                                    label = as.matrix(ifelse(dataSet$dependentVariable[-trainingSetRows, 
                                                                                       GENDER] == "F", 1, 0)))

  watchlist <- list(evaluationSet=dMatrixTestDataSet, trainingSet=dMatrixTrainingDataSet)
  
  trainedXgBoostModel <- xgb.train(params    = parameters$xgbParameters, 
                                   data      = dMatrixTrainingDataSet, 
                                   nrounds   = parameters$nRounds,
                                   early.stop.round = parameters$stopAfterNRoundsWithNoImprovement,
                                   watchlist = watchlist,
                                   maximize = TRUE)  

  trainedXgBoostModel
}