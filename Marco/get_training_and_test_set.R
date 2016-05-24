

getTrainingAndTestSet <- function(dataSet, trainingSetPercentage) UseMethod("getTrainingAndTestSet")

getTrainingAndTestSet.data.table <- function(dataSet, trainingSetPercentage) {
  trainingSetSize <- round(nrow(dataSet)*trainingSetPercentage)
  trainingSetIds <- sample(dataSet$KeyId, trainingSetSize)
  
  trainingData <- dataSet[KeyId %in% trainingSetIds, ]
  testData <- dataSet[!trainingData]
  
  list(trainingData = trainingData, testData = testData)
}


getTrainingAndTestSet.sparseMatrix <- function(dataSet, trainingSetPercentage) {
  nObservations <- nrow(dataSet)
  
  trainingSetSize <- round(nObservations*trainingSetPercentage)
  trainingSetRows <- sample(1:nObservations, trainingSetSize)

  trainingData <- dataSet[trainingSetRows, ]
  testData <- dataSet[-trainingSetRows,]

  list(trainingData = trainingData, testData = testData)
}

