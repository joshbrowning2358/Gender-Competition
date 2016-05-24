library(cbutils)
library(data.table)

#' Retrieves all raw evaluation data
#' @return a data.table with evaluation data

getEvaluationData <- function(dataSource) UseMethod("getEvaluationData")

getEvaluationData.rData <- function(dataSource) {
  load("rawEvaluationData.RData")
  rawData
}

getEvaluationData.mssql <- function(dataSource) {
  filename <- "get_evaluation_data.sql"
  query <- readQueryFromFile(filename)
  rawData <- as.data.table(executeQuery(query))
  save(rawData, file = "rawEvaluationData.RData")
  rawData
}

