library(ggplot2)
library(data.table)
library(bit64)

sapply(dir("R/", full.names=TRUE), source)

load("data/train_data_cleaned.RData")
# subData = trainData[sample(nrow(trainData), size=100000), ]
subData = trainData[sample(nrow(trainData), size=10000), ]
load("data/test_data_cleaned.RData")

allVariables=c('pagetype', 'productid', 'webshop', 'trafficSource_source', 'trafficSource_medium',
               'totals_pageviews', 'totals_timeOnSite', 'geoNetwork_country', 'device_browser',
               'device_deviceCategory', 'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID',
               'BRANDID', 'time')

rfTrainData <- copy(trainData)
rfTestData <- copy(testData)
reduceCategories(rfTrainData, rfTestData,
                 allVariables[!allVariables %in% c("time", 'totals_pageviews', 'totals_timeOnSite')],
                 nasAsClass=TRUE)
warning("Assuming NA pageviews is equivalent to 0 pageviews")
rfTrainData[is.na(totals_pageviews), totals_pageviews := 0]
rfTrainData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
rfTestData[is.na(totals_pageviews), totals_pageviews := 0]
rfTestData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
## Free up some memory:
# rm(trainData, testData)
# gc()

fitTimeCVModel(trainData=trainData, testData=testData,
               fitFunction=function(trainData){
                   fitNaiveBayesModel(trainData, variables=allVariables,
                                      targetVar="GENDER", key="localKey", maxRatio=100)
               },
               predictFunction=function(model, newData){
                   predictNaiveBayesModel(model=model, newData=newData, key="localKey")
               }, modelName="NB_maxRatio100_allVariables")

fitTimeCVModel(trainData=trainData, testData=testData,
               fitFunction=function(trainData){
                   fitNaiveBayesModel(trainData, variables=allVariables[allVariables!="productid"],
                                      targetVar="GENDER", key="localKey", maxRatio=100)
               },
               predictFunction=function(model, newData){
                   predictNaiveBayesModel(model=model, newData=newData, key="localKey")
               }, modelName="NB_maxRatio100_allVariablesButProductid", skipDates=30)

nbTrainData = copy(trainData)
nbTestData = copy(testData)
reduceCategories(nbTrainData, nbTestData, independentColumnNames=allVariables, maxCount=NULL,
                 minObs=30)
fitTimeCVModel(trainData=nbTrainData, testData=nbTestData,
               fitFunction=function(trainData){
                   fitNaiveBayesModel(trainData, variables=allVariables,
                                      targetVar="GENDER", key="localKey", maxRatio=100)
               },
               predictFunction=function(model, newData){
                   predictNaiveBayesModel(model=model, newData=newData, key="localKey")
               }, modelName="NB_maxRatio100_allVariablesButMinObs30")

# Random Forest
fitTimeCVModel(trainData=rfTrainData, testData=rfTestData,
               fitFunction=function(trainData){
                   randomForest::randomForest(as.factor(GENDER) ~ ., na.action=na.omit,
                                              data=trainData[, c(allVariables, "GENDER"), with=FALSE], 
                                              #May run into space issues, tune these params
                                              mtry=3, ntree=500)
               },
               predictFunction=function(model, newData){
                   preds <- randomForest:::predict.randomForest(model, newdata=newData, type="prob")[, 1]
                   # Aggregate predictions by key
                   newData[, prediction := preds]
                   newData[, list(probability.M = mean(prediction)), by="localKey"]
               }, modelName="RF_default_allvars", skipDates=5)

# Ridge?

rfTrainData <- copy(trainData)
rfTestData <- copy(testData)
reduceCategories(rfTrainData, rfTestData,
                 allVariables[!allVariables %in% c("time", 'totals_pageviews', 'totals_timeOnSite')],
                 nasAsClass=TRUE)
warning("Assuming NA pageviews is equivalent to 0 pageviews")
rfTrainData[is.na(totals_pageviews), totals_pageviews := 0]
rfTrainData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
rfTestData[is.na(totals_pageviews), totals_pageviews := 0]
rfTestData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
# Boosted trees
fitTimeCVModel(trainData=rfTrainData, testData=rfTestData,
               fitFunction=function(trainData){
                   gbm::gbm(GENDER == "M" ~ .,
                            data=trainData[, c(allVariables, "GENDER"), with=FALSE], n.trees=1000)
               },
               predictFunction=function(model, newData){
                   preds <- gbm:::predict.gbm(model, newdata=newData, type="response", n.trees=1000)
                   # Aggregate predictions by key
                   newData[, prediction := preds]
                   newData[, list(probability.M = mean(prediction)), by="localKey"]
               }, modelName="GBM_default_allvars", skipDates=5)


rfTrainData <- copy(trainData)
rfTestData <- copy(testData)
reduceCategories(rfTrainData, rfTestData,
                 allVariables[!allVariables %in% c("time", 'totals_pageviews', 'totals_timeOnSite')],
                 nasAsClass=TRUE, maxCount = 1000)
warning("Assuming NA pageviews is equivalent to 0 pageviews")
rfTrainData[is.na(totals_pageviews), totals_pageviews := 0]
rfTrainData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
rfTestData[is.na(totals_pageviews), totals_pageviews := 0]
rfTestData[is.na(totals_timeOnSite), totals_timeOnSite := 0]
# Boosted trees with more levels
fitTimeCVModel(trainData=rfTrainData, testData=rfTestData,
               fitFunction=function(trainData){
                   gbm::gbm(GENDER == "M" ~ .,
                            data=trainData[, c(allVariables, "GENDER"), with=FALSE], n.trees=1000)
               },
               predictFunction=function(model, newData){
                   preds <- gbm:::predict.gbm(model, newdata=newData, type="response", n.trees=1000)
                   # Aggregate predictions by key
                   newData[, prediction := preds]
                   newData[, list(probability.M = mean(prediction)), by="localKey"]
               }, modelName="GBM_default_allvars", skipDates=5)

# Ensemble: build GBM on errors from NB?

# Tree model: cast data to wide format and run with counts.

# Naive Bayes on rows instead of keys
fitTimeCVModel(trainData=trainData, testData=testData,
               fitFunction=function(trainData){
                   fit <- e1071::naiveBayes(GENDER ~ .,
                            data=trainData[, c(allVariables, "GENDER"), with=FALSE])
                   return(fit)
               },
               predictFunction=function(model, newData){
                   preds <- predict(model, newdata=newData, type="raw")[, 2]
                   # Aggregate predictions by key
                   newData[, prediction := preds]
                   newData[, list(probability.M = mean(prediction)), by="localKey"]
               }, modelName="NB_builtin_default_allvars", skipDates = 5)