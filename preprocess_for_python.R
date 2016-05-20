library(data.table)

load("data/train_data_cleaned.RData")
load("data/test_data_cleaned.RData")

fullData <- rbindlist(list(trainData, testData), use.names=TRUE, fill=TRUE)
rm(trainData, testData)
gc()

fullData
# Remove unneeded columns
fullData[, c("accountId", "transactionId", "COSTUMERID", "cvFold", "localKey", "hour", "minute") := NULL]

# Collapse unique keys to simpler key
uniqueKey = fullData[order(fullVisitorId, visitId), .N, by=c("fullVisitorId", "visitId")]
uniqueKey[, N := NULL]
uniqueKey[, myKey := 1:.N]
write.csv(uniqueKey, file="data/key_mapping.csv", row.names=FALSE)
setkeyv(uniqueKey, c("fullVisitorId", "visitId"))
setkeyv(fullData, c("fullVisitorId", "visitId"))
fullData[uniqueKey, myKey := myKey]
fullData[, c("fullVisitorId", "visitId") := NULL]

# Convert characters to factors, then numerics
factorVars <- c("pagetype", "productid", "webshop", "trafficSource_source", "trafficSource_medium",
                "geoNetwork_country", "device_browser", "device_deviceCategory", "device_operatingSystem",
                "PRODUCTGROUPID", "PRODUCTTYPEID", "BRANDID")
for(var in factorVars){
    fullData[, c(var) := factor(get(var))]
    fullData[, c(var) := as.numeric(get(var))]
}

# Convert GENDER to binary
fullData[, male := GENDER == "M"]
fullData[, GENDER := NULL]
write.csv(fullData, file="data/python_wide_input.csv", row.names=FALSE)
