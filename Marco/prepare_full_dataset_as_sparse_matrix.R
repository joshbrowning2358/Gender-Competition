source('get_all_data.R')
source('transform_data_to_sparse_matrix.R')

prepareFullDatasetAsSparseMatrix <- function(config, keyColumnNames) {
  rawData <- getAllData(config$dataSource)
  cleanedData <- cleanData(rawData)
  transformedDataSet <- transformDataToSparseMatrix(rawData, keyColumnNames, evaluationSet = TRUE)
  
  transformedDataSet
}