library(cbutils)
library(data.table)

#' Retrieves all raw training data
#' @return a data.table with training data

getTrainingData <- function(dataSource) UseMethod("getTrainingData")

getTrainingData.rData <- function(dataSource) {
  load("rawTrainingData.RData")
  rawData
}

getTrainingData.mssql <- function(dataSource) {
    filename <- "get_training_data.sql"
    query <- readQueryFromFile(filename)
    rawData <- as.data.table(executeQuery(query))
    save(rawData, file = "rawTrainingData.RData")
    rawData
}
  
