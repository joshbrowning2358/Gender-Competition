library(data.table)

source('get_gender.R')

getDependentVariable <- function(dt, kKeyColumnName) {
  kGenderColumnName <- "GENDER"
  kDependentVariableName <- "DependentVariable"
  kGenericKeyColumnName <- "KeyColumn"
  
  dt <- copy(dt)
  setnames(dt, kKeyColumnName, kGenericKeyColumnName)
  
  dependentVariable <- getGender(dt, kGenericKeyColumnName)
  dependentVariable <- dependentVariable[order(KeyColumn)]
  
  setnames(dependentVariable, kGenderColumnName, kDependentVariableName)
  setnames(dependentVariable, kGenericKeyColumnName, kKeyColumnName)
  dependentVariable
}
  