library(Matrix)
source("map_to_new_ids.R")

getVariablesByKey <- function(dt, keyColumnName, variableColumnName) {
  kGenericKeyColumnName <- "KeyColumn"
  
  dt <- copy(dt)
  setnames(dt, keyColumnName, kGenericKeyColumnName)
  
  dt <- unique(dt[, c(kGenericKeyColumnName, variableColumnName), with = FALSE])
  dt[, Value := 1]
  
  mappingTable <- mapToNewIds(dt[, variableColumnName, with = FALSE])
  dt <- merge(dt, mappingTable, by = variableColumnName)
  
  dt <- dt[order(KeyColumn)]
  uniqueKeys <- unique(dt$KeyColumn)
  nUniqueKeys <- length(uniqueKeys)
  nUniqueVariables <- length(unique(dt$Id))

  variables <- sparseMatrix(i = dt$KeyColumn,
                            j = dt$Id,
                            x = dt$Value,
                            dims = c(nUniqueKeys, nUniqueVariables))
  
  variablesByKey <- cbind(uniqueKeys, variables)

  colnames(variablesByKey)[1] <- keyColumnName
  
  variablesByKey
}