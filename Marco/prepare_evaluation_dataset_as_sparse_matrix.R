source('get_evaluation_data.R')
source('transform_data_to_sparse_matrix.R')

prepareEvaluationDatasetAsSparseMatrix <- function(config, keyColumnNames) {
  rawData <- getEvaluationData(config$dataSource)
  transformedDataSet <- transformDataToSparseMatrix(rawData, keyColumnNames, evaluationSet = TRUE)
  
  transformedDataSet
}