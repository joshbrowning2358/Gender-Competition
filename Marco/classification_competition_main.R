library(cbutils)
library(xgboost)
library(Epi)

source('load_configuration.R')
source('prepare_estimation_dataset_as_sparse_matrix.R')
source('prepare_evaluation_dataset_as_sparse_matrix.R')
source('prepare_full_dataset_as_sparse_matrix.R')
source('prepare_dataset.R')
#source('estimate_model.R')
source('estimate_model_new.R')
#source('predict_gender.R')
source('predict_gender_new.R')
source('calculate_auc.R')

options(scipen=999)

config <- loadConfiguration("config.ini")

keyColumnNames <- c("fullVisitorId", "visitId")

preparedFullDataset <- prepareFullDatasetAsSparseMatrix(config$estimationDataPreparation, 
                                                        keyColumnNames)

trainingSetRows <- preparedFullDataset$gender[!is.na(GENDER), "KeyId", with = FALSE]
evaluationSetRows <- preparedFullDataset$gender[is.na(GENDER), "KeyId", with = FALSE]

trainingSet <- list(explanatoryVariables = preparedFullDataset$transformedData[trainingSetRows$KeyId, ],
                    dependentVariable = preparedFullDataset$gender[trainingSetRows$KeyId, ])
 
nRowsTrainingSet <- nrow(trainingSet$dependentVariable)
nTrainingSets <- 10

nObervationsPerTrainingSet <- floor(nRowsTrainingSet / nTrainingSets)
trainingSetRowIndices <- trainingSetRows$KeyId

evaluationSet <- preparedFullDataset$transformedData[evaluationSetRows$KeyId, ]

sumOfScores <- rep(0, nrow(evaluationSetRows))
aucTraining <- rep(0, nTrainingSets)
proc.time()
for (i in 1:nTrainingSets) {
  rowsTrainingSubSet <- sample.int(nRowsTrainingSet, nObervationsPerTrainingSet)
  trainingSubSetRows <- trainingSetRows[rowsTrainingSubSet, ]
  
  trainingSubSet <- list(explanatoryVariables = preparedFullDataset$transformedData[trainingSubSetRows$KeyId, ],
                         dependentVariable = preparedFullDataset$gender[trainingSubSetRows$KeyId, ])
  
  estimatedModel <- estimateModel(config$model, trainingSubSet)
  
  predictedGender <- predictGender(estimatedModel, trainingSubSet$explanatoryVariables)
  genderTrainingSubSet <- ifelse(trainingSubSet$dependentVariable[, GENDER] == "F", 1, 0)
  aucTraining[i] <- estimatedModel$bestScore
  score <- predictGender(estimatedModel, evaluationSet)
  sumOfScores <- sumOfScores + score*aucTraining[i]
  
  trainingSetRows <- trainingSetRows[!rowsTrainingSubSet, ]
  nRowsTrainingSet <- nrow(trainingSetRows)
}
proc.time()
############################
#estimatedModel <- estimateModel(config$model, trainingSet)

#predictedGender <- predictGender(estimatedModel, trainingSet$explanatoryVariables)
#genderTrainingSet <- ifelse(trainingSet$dependentVariable[, GENDER] == "F", 1, 0)
#aucTraining <- calculateAUC(genderTrainingSet, predictedGender)

#evaluationSet <- preparedFullDataset$transformedData[evaluationSetRows$KeyId, ]
#score <- predictGender(estimatedModel, evaluationSet)
###################################################

score <- sumOfScores / sum(aucTraining)

preparedFullDataset$keyMapping

resultSet <- cbind(preparedFullDataset$keyMapping[evaluationSetRows$KeyId, c("fullVisitorId", "visitId"), with = FALSE],
                   score)
proc.time()
write.csv(resultSet, file = "predictedGender.csv", row.names = FALSE)

