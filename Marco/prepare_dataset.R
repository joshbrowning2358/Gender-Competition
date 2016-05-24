source('get_training_data.R')
source('clean_data.R')
source('transform_data.R')
source('get_training_and_test_set.R')

prepareDataset <- function(config, keyColumnNames) {
  rawData <- getTrainingData(config$dataSource)
  cleanedData <- cleanData(rawData)
  transformedData <- transformData(cleanedData, keyColumnNames)
  getTrainingAndTestSet(transformedData, config$trainingSetPercentage)
}