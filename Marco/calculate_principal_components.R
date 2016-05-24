calculatePrincipalComponents <- function(dataSet) UseMethod("calculatePrincipalComponents")

library(Matrix)
library(irlba)

calculatePrincipalComponents.sparseMatrix <- function(sparseMatrix, nPrincipalComponents = 10){
  pcaResult <- irlba(sparseMatrix, nv = nPrincipalComponents, nu = 0)
  principalComponents <- sparseMatrix %*% pcaResult$v
  principalComponents
}

calculatePrincipalComponents.data.table <- function(dt){
  kMinimumCumulativeProportionOfVariance <- .8
  kIdentifierIndex <- 1
  kDependentVariableIndex <- 2
  kExplanatoryVariablesStartIndex <- 3
  
  explanatoryVariables <- dt[, kExplanatoryVariablesStartIndex:ncol(dt), with = FALSE]
  pcaResult <- prcomp(explanatoryVariables)
  cumulativeProportions <- cumsum(pcaResult$sdev^2)/sum(pcaResult$sdev^2)
  
  numberOfSelectedPrincipalComponents <- first(which(cumulativeProportions >= 
                                                       kMinimumCumulativeProportionOfVariance))
  
  selectedPrincipalComponents <- pcaResult$x[, seq_len(numberOfSelectedPrincipalComponents)]
  
  cbind(dt[, c(kIdentifierIndex, kDependentVariableIndex), with = FALSE], 
        selectedPrincipalComponents)
  
  #print(pcaResult)
  #plot(pcaResult, type = "l")
  #summary(pcaResult)
  #predict(ir.pca, newdata=tail(log.ir, 2))
}
