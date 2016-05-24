source('get_training_data.R')
source('clean_data.R')
source('transform_data_to_sparse_matrix.R')
source('get_training_and_test_set.R')

prepareEstimationDatasetAsSparseMatrix <- function(config, keyColumnNames) {
  rawData <- getTrainingData(config$dataSource)
  cleanedData <- cleanData(rawData)
  transformedData <- transformDataToSparseMatrix(cleanedData, keyColumnNames)
  getTrainingAndTestSet(transformedData, config$trainingSetPercentage)
}
