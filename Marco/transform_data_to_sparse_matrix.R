source("add_key_id.R")
source("get_explanatory_variables.R")
source('get_dependent_variable.R')

transformDataToSparseMatrix <- function(cleanedData, keyColumnNames, evaluationSet = FALSE) {
  kKeyColumnName <- "KeyId"
  kGenderColumnName <- "GENDER"
  
  dt <- addKeyId(cleanedData, keyColumnNames)
  explanatoryVariables <- getExplanatoryVariables(dt, kKeyColumnName)
  
  if(!evaluationSet) {
    dependentVariable <- getDependentVariable(dt, kKeyColumnName)
    dependentVariable <- as(as.matrix(dependentVariable), "sparseMatrix")
    transformedData <- cbind(dependentVariable, explanatoryVariables[, -1])
  } else {
    transformedData <- explanatoryVariables[, -1]
  }
  
  list(transformedData = transformedData,
       keyMapping = unique(dt[order(KeyId), c(keyColumnNames, kKeyColumnName), with = FALSE]),
       gender = unique(dt[order(KeyId), c(kKeyColumnName, kGenderColumnName), with = FALSE]))
}