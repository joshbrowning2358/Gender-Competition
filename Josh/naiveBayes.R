library(ggplot2)
library(data.table)
library(bit64)
library(e1071)
library(pROC)

sapply(dir("R/", full.names=TRUE), source)

trainData = fread("data/train_data_cleaned.csv")
testData = fread("data/test_data_cleaned.csv")
fullData = rbindlist(list(trainData, testData), fill=TRUE)

variables=c('pagetype', 'productid', 'webshop', 'trafficSource_source', 'trafficSource_medium',
            'totals_pageviews', 'totals_timeOnSite', 'geoNetwork_country', 'device_browser',
            'device_deviceCategory', 'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID',
            'BRANDID', 'time')
# variables=c('pagetype', 'BRANDID', 'geoNetwork_country')
#variables = c('BRANDID', 'device_operatingSystem', 'device_browser', 'PRODUCTGROUPID')
for(cvGroup in 1:10){
  start = Sys.time()
  maxRatio <- 100
  model = fitNaiveBayesModel(trainData[cvFold != cvGroup, ], variables = variables, targetVar = "GENDER",
                             maxRatio = 100)
  fitTime = Sys.time() - start

  start = Sys.time()
  predictions = predictNaiveBayesModel(model, newData = fullData, key = "localKey")
  predictTime = Sys.time() - start
  predictions = merge(fullData[, c("localKey", "GENDER", "cvFold"), with=FALSE], predictions, by="localKey")
  
  predictions[, target := as.numeric(GENDER == "M")]
  predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
  
  start = Sys.time()
  AUC = predictions[cvFold == cvGroup, auc(response = (GENDER=="M"), predictor=probability.M)]
  aucTime = Sys.time() - start
  
  cat("CV Fold", cvGroup, ":\n",
      "AUC:", AUC, "\n",
      "Time:", fitTime, "(fitting), ", predictTime, "(predicting), ", aucTime, "(calc AUC)", "\n")
  predictions[, c("GENDER", "target") := NULL]
  save(AUC, predictions, model, variables, maxRatio,
       file=paste0("data/output/prediction_cv", cvGroup, "_auc", round(AUC, 4), "_",
                   as.character(Sys.time(), format="%Y%m%d%H%M%S"), ".RData"))
}

# Trying new model:
model <- fitNonParametricDensity(independentVariable=trainData$time[1:100000], labels=trainData$GENDER[1:100000], variableName="time")
fittedValues <- predictNonParametricDensity(model, newdata=trainData[100001:200000, ])
fittedValues[, prob.M := density.M / (density.M + density.F)]
auc(response=trainData[100001:200000, GENDER == "M"], predictor = fittedValues$prob.M)


fullModel = fitNaiveBayesModel(trainData[cvFold != cvGroup, ], variables = variables, targetVar = "GENDER")
predictions = predictNaiveBayesModel(model, newData = testData, key = "localKey")
predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
predictions[, fullVisitorId := gsub("-.*", "", localKey)]
predictions[, visitId := gsub(".*-", "", localKey)]
predictions[, localKey := NULL]

predictions2 = merge(testData[, "localKey", with=FALSE], predictions, by="localKey")
predictions2[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
predictions2[, fullVisitorId := gsub("-.*", "", localKey)]
predictions2[, visitId := gsub(".*-", "", localKey)]
predictions2[, localKey := NULL]

predictions[, fullVisitorId := gsub("-.*", "", localKey)]
predictions[, visitId := gsub(".*-", "", localKey)]
predictions[, localKey := NULL]
write.csv(predictions, "prediction_1a.csv", row.names=FALSE)
write.csv(predictions2, "prediction_1b.csv", row.names=FALSE)

## Using maximum ratio for independent variables

fullModel = fitNaiveBayesModel(trainData, variables = variables, targetVar = "GENDER", maxRatio = 100)
predictions = predictNaiveBayesModel(fullModel, newData = testData, key = "localKey")
predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
predictions[, fullVisitorId := gsub("-.*", "", localKey)]
predictions[, visitId := gsub(".*-", "", localKey)]

predictions2 = merge(testData[, "localKey", with=FALSE], predictions, by="localKey")
predictions2[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
predictions2[, fullVisitorId := gsub("-.*", "", localKey)]
predictions2[, visitId := gsub(".*-", "", localKey)]
predictions2[, localKey := NULL]

predictions[, fullVisitorId := gsub("-.*", "", localKey)]
predictions[, visitId := gsub(".*-", "", localKey)]
predictions[, localKey := NULL]
write.csv(predictions, "data/output/prediction_2.csv", row.names=FALSE)
#write.csv(predictions2, "prediction_2.csv", row.names=FALSE)


# Let's cross-validate over time
variables=c('pagetype', 'productid', 'webshop', 'trafficSource_source', 'trafficSource_medium',
            'totals_pageviews', 'totals_timeOnSite', 'geoNetwork_country', 'device_browser',
            'device_deviceCategory', 'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID',
            'BRANDID', 'time')
# variables=c('pagetype', 'BRANDID', 'geoNetwork_country')
# variables = c('BRANDID', 'device_operatingSystem', 'device_browser', 'PRODUCTGROUPID')
uniqueDates <- sort(unique(trainData$date))
for(trainDate in uniqueDates){
  start = Sys.time()
  maxRatio = 100
  model = fitNaiveBayesModel(trainData[date <= trainDate, ], variables = variables,
                             targetVar = "GENDER", maxRatio = maxRatio)
  fitTime = difftime(Sys.time(), start, units="secs")/3600

  start = Sys.time()
#  predictions = predictNaiveBayesModel(model, newData = fullData, key = "localKey")
  predictions = predictNaiveBayesModel(model, newData = trainData, key = "localKey")
  predictTime = difftime(Sys.time(), start, units="secs")/3600
#  predictions = merge(fullData[, c("localKey", "GENDER", "date"), with=FALSE], predictions, by="localKey")
  predictions = merge(trainData[, c("localKey", "GENDER", "date"), with=FALSE], predictions, by="localKey")
  
  predictions[, target := as.numeric(GENDER == "M")]
  predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
  
  start = Sys.time()
  AUC = predictions[date > trainDate, caTools::colAUC(y=(GENDER=="M"), X=as.matrix(probability.M, ncol=1))]
  aucTime = difftime(Sys.time(), start, units="secs")/3600
  
  cat("Train Date", trainDate, ":\n",
      "AUC:", AUC, "\n",
      "Time:", fitTime, "(fitting), ", predictTime, "(predicting), ", aucTime, "(calc AUC)", "\n")
  predictions[, c("GENDER", "target") := NULL]
  save(AUC, predictions, model, variables, maxRatio,
       file=paste0("data/output/prediction_time", trainDate, "_auc", round(AUC, 4), "_",
                   as.character(Sys.time(), format="%Y%m%d%H%M%S"), ".RData"))
}
