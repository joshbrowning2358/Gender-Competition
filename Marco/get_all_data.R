library(cbutils)
library(data.table)

#' Retrieves all raw training data
#' @return a data.table with training data

getAllData <- function(dataSource) UseMethod("getAllData")

getAllData.rData <- function(dataSource) {
  load("rawAllData.RData")
  rawData
}

getAllData.mssql <- function(dataSource) {
  filename <- "get_all_data.sql"
  query <- readQueryFromFile(filename)
  rawData <- as.data.table(executeQuery(query))
  save(rawData, file = "rawAllData.RData")
  rawData
}