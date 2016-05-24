
getPricipalComponentsByKey <- function(sparseMatrix, keyColumnName, nPrincipalComponents = 10) {
  kGenericKeyColumnName <- "keyId"
  
  keyId <- sparseMatrix[, 1]
  variables <- sparseMatrix[, -1]
  
  variablesPrincipalComponents <- calculatePrincipalComponents(variables)
  variablesPrincipalComponents <- as.data.table(as.matrix(variablesPrincipalComponents))
  
  variablesPrincipalComponentsByKey <- cbind(keyId, variablesPrincipalComponents)
  
  setnames(variablesPrincipalComponentsByKey, kGenericKeyColumnName, keyColumnName)
}
  