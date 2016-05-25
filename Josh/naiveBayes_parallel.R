library(ggplot2)
library(data.table)
library(bit64)
library(e1071)
library(pROC)
library(foreach)
registerDoParallel(cores=detectCores(all.tests=TRUE))

sapply(dir("R/", full.names=TRUE), source)

trainData = fread("data/train_data_cleaned.csv")
testData = fread("data/test_data_cleaned.csv")
fullData = rbindlist(list(trainData, testData), fill=TRUE)

# Let's cross-validate over time
variables=c('pagetype', 'productid', 'webshop', 'trafficSource_source', 'trafficSource_medium',
            'totals_pageviews', 'totals_timeOnSite', 'geoNetwork_country', 'device_browser',
            'device_deviceCategory', 'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID',
            'BRANDID', 'time')
# variables = c('BRANDID', 'device_operatingSystem', 'device_browser', 'PRODUCTGROUPID')
uniqueDates <- sort(unique(trainData$date))
trainData <- trainData[sample(nrow(trainData), size=10000), ]
foreach(trainDate = uniqueDates) %dopar% {
  start = Sys.time()
  maxRatio = 100
  model = fitNaiveBayesModel(trainData[date <= trainDate, ], variables = variables,
                             targetVar = "GENDER", maxRatio = maxRatio)
  fitTime = Sys.time() - start

  start = Sys.time()
  predictions = predictNaiveBayesModel(model, newData = fullData, key = "localKey")
  predictTime = Sys.time() - start
  predictions = merge(fullData[, c("localKey", "GENDER", "date"), with=FALSE], predictions, by="localKey")
  
  predictions[, target := as.numeric(GENDER == "M")]
  predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
  
  start = Sys.time()
  AUC = predictions[date > trainDate, auc(response = (GENDER=="M"), predictor=probability.M)]
  aucTime = Sys.time() - start
  
  cat("Train Date", trainDate, ":\n",
      "AUC:", AUC, "\n",
      "Time:", fitTime, "(fitting), ", predictTime, "(predicting), ", aucTime, "(calc AUC)", "\n")
  predictions[, c("GENDER", "target") := NULL]
  save(AUC, predictions, model, variables, maxRatio,
       file=paste0("data/output/prediction_time", trainDate, "_auc", round(AUC, 4), "_",
                   as.character(Sys.time(), format="%Y%m%d%H%M%S"), ".RData"))
}
