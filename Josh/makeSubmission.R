load("data/output/prediction_time16739_model.NB_maxRatio100_allVariablesButProductid_aucNA_20160510093336.RData")

# One vector of predictions
preds <- predictions[, probability.M]
newData <- testData[, c("fullVisitorId", "visitId"), with=FALSE]
newData[, probability.M := preds]
newData <- newData[, list(probability.M = mean(probability.M)), by=c("fullVisitorId", "visitId")]
newData[, probability.F := 1-probability.M]
setcolorder(newData, c("probability.M", "probability.F", "fullVisitorId", "visitId"))
write.csv(newData, file="", row.names=FALSE)

# Data.table of predictions
predictions[, fullVisitorId := gsub("-.*", "", localKey)]
predictions[, visitId := gsub(".*-", "", localKey)]
predictions = predictions[date >= as.Date("2015-11-01"), ]
# Should be empty data.table:
predictions[, sd(probability.M), by=c("fullVisitorId", "visitId")][V1 > 0]
results <- predictions[, list(probability.M=mean(probability.M)),
                       by=c("fullVisitorId", "visitId")]
results[, probability.F := 1-probability.M]
setcolorder(results, c("probability.M", "probability.F", "fullVisitorId", "visitId"))
write.csv(results, file="data/output/prediction_4.csv", row.names=FALSE)