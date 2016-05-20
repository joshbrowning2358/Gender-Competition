#' Predict with the Naive Bayes model
#' 
#' @param model An object returned by fitNaiveBayesModel.
#' @param newData The data.table object containing the new data. The new data
#'   should have columns named according to the variables in model.
#' @param Vector containing the key columns of the dataset.
#' @return A vector of predictions for class probabilities.
#'   

# newData = copy(testData)
# model = copy(probabilities)
# key = c("fullVisitorId", "visitId")

# stackoverflow.com/questions/10059594/a-simple-explanation-of-naive-bayes-classification
predictNaiveBayesModel = function(model, newData, key){
  countColumns = grep("counts", colnames(model), value = TRUE)
  model[, c(countColumns) := NULL]
  uniqueVariables = unique(model$variable)
  estimatedProbability = unique(newData[, key, with=FALSE])
  estimatedProbability[, c("probability.M", "probability.F") := 0]
  # Use a for loop to iteratively append on estimated probabilities
  for(column in uniqueVariables){
    subModel = model[variable == column, ]
    subModel[, variable := NULL]
    # unique() because we only want binary variables: did this user perform this action or not?
    subData = unique(newData[, c(key, column), with=FALSE])
    subData[, c(column) := as.character(get(column))]
    subData = merge(subData, subModel, by.x=column, by.y="value", all.x=TRUE)
    subData[is.na(probability.M), c("probability.M") := 1]
    subData[is.na(probability.F), c("probability.F") := 1]
    subData[, c(column) := NULL]
    subData = subData[, list(probability.M = sum(log(probability.M)),
                             probability.F = sum(log(probability.F))),
                      by = key]
    
    estimatedProbability = merge(subData, estimatedProbability, by=c(key), suffixes = c("_new", ""))
    estimatedProbability[, probability.M := probability.M + probability.M_new]
    estimatedProbability[, probability.F := probability.F + probability.F_new]
    estimatedProbability[, c("probability.M_new", "probability.F_new") := NULL]
  }
  estimatedProbability[, probability.M := exp(probability.M)]
  estimatedProbability[, probability.F := exp(probability.F)]
  estimatedProbability[, c("probability.M", "probability.F") :=
                           list(probability.M / (probability.M + probability.F),
                                probability.F / (probability.M + probability.F))]
  
  return(estimatedProbability)
}