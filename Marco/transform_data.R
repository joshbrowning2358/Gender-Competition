source("add_key_id.R")
source("get_explanatory_variables_using_principal_components.R")
source('get_dependent_variable.R')

transformData <- function(cleanedData, keyColumnNames) {
  kKeyColumnName <- "KeyId"
  
  dt <- addKeyId(cleanedData, keyColumnNames)
  explanatoryVariables <- getExplanatoryVariablesUsingPrincipalComponents(dt, kKeyColumnName)
  dependentVariable <- getDependentVariable(dt, kKeyColumnName)
  transformedData <- merge(dependentVariable, explanatoryVariables, by = kKeyColumnName)
  transformedData
}