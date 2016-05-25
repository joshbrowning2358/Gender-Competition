#' Fit Cross Validation Fold
#' 
#' @param endTrainDate The last date which should be used for training the
#'   model.
#' @param fullData The data.table containing the training and testing data (will
#'   be split by date).
#' @param fitFunction See fitTimeCVModel.
#' @param predictFunction See fitTimeCVModel.
#' @param modelName See fitTimeCVModel.
#' @param testDate The first date of the testing period.
#'   
#' @return Generates a plot of the AUC, saves the estimated predictions on the
#'   entire dataset, and returns an object containing the AUC estimated on the
#'   test set, by day.
#'   

fitCVFold <- function(endTrainDate, fullData, fitFunction, predictFunction, modelName=modelName,
                      testDate=as.Date("2015-11-01")){
    start <- Sys.time()
    model <- fitFunction(trainData=fullData[date <= endTrainDate, ])
    fitTime <- difftime(Sys.time(), start, units="hours")
    cat("Model fit in", round(fitTime, 5), "hours.\n")
    
    start <- Sys.time()
    predictions <- predictFunction(model=model, newData=fullData)
    predictTime <- difftime(Sys.time(), start, units="hours")
    cat("Model estimated in", round(predictTime, 5), "hours.\n")
    predictions = merge(fullData[, c("localKey", "GENDER", "date"), with=FALSE], predictions, by="localKey")
    
    predictions[, target := as.numeric(GENDER == "M")]
    predictions[is.na(probability.M), c("probability.M", "probability.F") := 0.5]
    
    start <- Sys.time()
    AUC <- predictions[date > endTrainDate & date < testDate, safeAUC(y=target, x=probability.M), by=date]
    AUC[, trainDate := endTrainDate]
    setnames(AUC, "V1", "AUC")
    aucTime <- difftime(Sys.time(), start, units="hours")
    
    cat("Train Date", endTrainDate, ":\n", "AUC:", mean(AUC$AUC), "\n")
    print(ggplot(AUC, aes(x=date, y=AUC)) + geom_point() + labs(x="AUC Date"))
    predictions[, c("GENDER", "target") := NULL]
    save(AUC, predictions,
         file=paste0("data/output/prediction_time", endTrainDate, "_model.", modelName, "_auc",
                     round(mean(AUC$AUC), 4), "_", as.character(Sys.time(), format="%Y%m%d%H%M%S"), ".RData"))
    return(AUC)
}