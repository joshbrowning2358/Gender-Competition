library(data.table)
library(bit64)

trainData = fread("data/train_data.csv", na.strings="NULL", sep=";")
testData = fread("data/test_data.csv", na.strings="NULL", sep=";")

trainNames = c('date', 'hour', 'minute', 'accountId', 'fullVisitorId', 'visitId', 'pagetype', 'productid',
               'webshop', 'transactionId', 'trafficSource_source', 'trafficSource_medium', 'totals_pageviews',
               'totals_timeOnSite', 'geoNetwork_country', 'device_browser', 'device_deviceCategory',
               'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID', 'BRANDID', 'COSTUMERID', 'GENDER')
setnames(trainData, trainNames)
testNames = trainNames[!trainNames %in% c('accountId', 'COSTUMERID', 'GENDER')]
setnames(testData, testNames)

colClasses=c("Date", "integer", "integer", "integer", "character", "integer", "factor", "factor",
             "factor", "logical", "factor", "factor", "integer", "integer", "factor", "factor",
             "factor", "factor", "factor", "factor", "factor", "integer", "factor")
testColClasses=c("Date", "integer", "integer", "character", "integer", "factor", "factor",
                 "factor", "logical", "factor", "factor", "integer", "integer", "factor", "factor",
                 "factor", "factor", "factor", "factor", "factor")
trainData[, date := as.Date(date, format="%Y%m%d")]
for(i in 2:ncol(trainData)){
    if(colClasses[i]=="factor"){
        trainData[, c(trainNames[i]) := as.factor(get(trainNames[i]))]
    } else {
        trainData[, c(trainNames[i]) := as(get(trainNames[i]), Class=colClasses[i])]
    }
}
testData[, date := as.Date(date, format="%Y%m%d")]
for(i in 2:ncol(testData)){
    if(testColClasses[i]=="factor"){
        testData[, c(testNames[i]) := as.factor(get(testNames[i]))]
    } else {
        testData[, c(testNames[i]) := as(get(testNames[i]), Class=testColClasses[i])]
    }
}
setkeyv(trainData, c("fullVisitorId", "visitId"))

trainData[, time := hour + minute/60]
uniqueIds = unique(trainData[, .(fullVisitorId, visitId)])
uniqueIds[, cvFold := sample(1:10, size=.N, replace=TRUE)]
trainData[uniqueIds, cvFold := cvFold]
trainData = trainData[GENDER != "?", ]
testData[, time := hour + minute/60]
trainData[, localKey := paste0(as.character(fullVisitorId), "-", as.character(visitId))]
testData[, localKey := paste0(as.character(fullVisitorId), "-", as.character(visitId))]

# Set new cv-folds called timeFold
# dayQuantiles <- trainData[, quantile(as.Date(date, format="%Y%m%d") - as.Date("2015-01-01"),
#                                      na.rm = TRUE, probs = 0:10/10)]

save(trainData, file="data/train_data_cleaned.RData")
save(testData, file="data/test_data_cleaned.RData")
