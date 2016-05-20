# The built-in model will not work because:
# - It calculates probabilities per obs, we want per ID
# - It may take a lot of memory to fit
# - It may be difficult to implement custom density estimation, like with time.

library(ggplot2)
library(data.table)
library(bit64)
library(e1071)
library(pROC)

sapply(dir("R/", full.names=TRUE), source)

trainData = fread("data/train_data_cleaned.csv")

variables = "device_operatingSystem"
tempData = copy(trainData)
tempModel = fitNaiveBayesModel(trainData, variables = variables, targetVar = "GENDER")

fitData = dcast(formula = fullVisitorId + visitId + GENDER ~ device_operatingSystem, data=trainData,
                fun.aggregate=function(x) min(length(x), 1))
fitData[, c("fullVisitorId", "visitId") := NULL]
builtinModel = naiveBayes(GENDER ~ ., data=fitData)
# Not sure why the estimated probabilities are off, but they seem to be...
tempModel[, probability.M := builtinModel$tables$device_operatingSystem["M", ]]
tempModel[, probability.F := builtinModel$tables$device_operatingSystem["F", ]]
tempModel[, value := colnames(builtinModel$tables$device_operatingSystem)]

predictions = predictNaiveBayesModel(tempModel, newData = trainData[1, ], key = "localKey")
predictions2 <- predict(builtinModel, newdata = as.data.frame(trainData[1, ]), type="raw")
predictions[, probability.M := probability.M * builtinModel$apriori[2]]
predictions[, probability.F := probability.F * builtinModel$apriori[1]]
predictions[, probability.M := probability.M / (probability.M + probability.F)]
predictions[, probability.F := (1 - probability.M)]
