library(ggplot2)
library(data.table)
library(bit64)

trainData <- fread("data/train_data_cleaned.csv")

# Gender density plots
ggsave("output/gender_time_plot.png",
    ggplot(trainData, aes(x=time, fill=GENDER, group=GENDER)) + geom_density(alpha=0.5)
)
ggsave("output/gender_timeOnSite.png",
    ggplot(trainData, aes(x=totals_timeOnSite, fill=GENDER, group=GENDER)) + geom_density(alpha=0.5)
)

trainData[totals_timeOnSite > 10000, totals_timeOnSite := 10000]
trainData[, totals_timeOnSite := round(totals_timeOnSite/100, 0)*100]
ggplot(trainData, aes(x=totals_timeOnSite, fill=GENDER, group=GENDER)) + geom_density(alpha=0.5)

ggsave("output/gender_pageViews.png",
    ggplot(trainData, aes(x=totals_pageviews, fill=GENDER, group=GENDER)) + geom_density(alpha=0.5)
)

# Overlap of fullVisitorIds
mean(testData$fullVisitorId %in% trainData$fullVisitorId)
aggData <- trainData[, mean(GENDER == "M"), by=fullVisitorId]
qplot(aggData$V1)

# Performance of model
cvFold <- 1
dataFiles <- dir("data/output", pattern="prediction_.*20160428.*", full.names=TRUE)
load(dataFiles[1])
ggsave("output/distribution_of_probabilities_from_model.png",
    ggplot(data=model, aes(x=probability.M)) + geom_density() +
        facet_wrap( ~ variable, scale="free")
)
evaluationSet <- predictions[, list(probability.M=mean(probability.M),
                                     probability.F=mean(probability.F)), by="localKey"]
evaluationSet <- merge(evaluationSet, trainData[, .(localKey, GENDER)], by="localKey")
evaluationSet[GENDER == "M", error := 1-probability.M]
evaluationSet[GENDER == "F", error := 1-probability.F]
evaluationSet <- evaluationSet[, list(error=mean(error)), by="localKey"]
trainData = merge(trainData, evaluationSet, by="localKey")
trainData[error == 1, .N, cvFold] # Definitely overfitting, mistakes are mostly in cvFold 1 (holdout).
trainData[error > 0.95 & error < 1, .N, cvFold] # Not bad if we remove the 0/1 predictions though.

# Fitting classes with small counts
model[, observedRatio := pmax(probability.M / probability.F, probability.F / probability.M)]
ggplot(model, aes(x=variable, group=variable, y=observedRatio)) + geom_boxplot()
model[, mean(observedRatio==Inf), by=variable]
