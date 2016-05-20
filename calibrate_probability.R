library(data.table)
library(ggplot2)

outputFiles <- dir("data/output/", pattern="prediction_time2015-10-[0-9]{2}_model.NB_maxRatio100_allVariablesButProductid_auc",
                   full.names=TRUE)

trueGender <- fread("data/train_data.csv", select=c(5, 6, 23), colClasses="character")
trueGender[, localKey := paste(V5, V6, sep="-")]
trueGender[, c("V5", "V6") := NULL]
setnames(trueGender, "V23", "GENDER")
trueGender <- unique(trueGender)

fullSummary <- NULL

for(file in outputFiles){
    load(file)
    trainDate <- as.Date(gsub("(.*prediction_time|_model.*)", "", file))
    predictions <- predictions[, list(probability.M=mean(probability.M),
                                      date=min(date)), by="localKey"]
    predictions <- merge(predictions, trueGender, by="localKey")
    predictions[, trainDate := trainDate]
    predictions[, probQuantile := floor(probability.M*20)/20]
    predictions[, daysAhead := as.numeric(difftime(date, trainDate, units="days"))]
    predictions[, daysTrained := as.numeric(difftime(trainDate, as.Date("2015-09-30"), units="days"))]
    modelSummary <- predictions[, mean(GENDER=="M"), by=c("probQuantile", "daysAhead", "daysTrained")]
    setnames(modelSummary, "V1", "trueProbability")
    
    fullSummary <- rbind(fullSummary, modelSummary)
}


ggplot(fullSummary, aes(x=probQuantile, y=trueProbability, color=daysAhead, group=daysAhead)) +
    geom_line() + facet_wrap( ~ daysTrained)

fit <- glm(trueProbability ~ probQuantile * daysAhead * daysTrained, data=fullSummary)
summary(fit)

fullSummary[, fittedEffect := predict(fit, newdata = fullSummary)]
ggplot(fullSummary[daysAhead > 0, ], aes(x=fittedEffect, y=trueProbability, color=daysAhead, group=daysAhead)) +
    geom_line() + facet_wrap( ~ daysTrained)

ggplot(fullSummary[daysAhead > 0 & daysTrained == 15, ], aes(x=fittedEffect, y=trueProbability, color=daysAhead, group=daysAhead)) +
    geom_line() + facet_wrap( ~ daysTrained)
