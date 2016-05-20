#' Fit a model that generates "cross-validations" as a moving window in time.
#' 
#' @param trainData The data.table containing the training data.
#' @param testData The data.table containing the testing data (presumably very
#'   similar to trainData).  The structure of these datasets can be flexible,
#'   but the fitFunction and predictFunction will have to understand the formats
#'   provided.
#' @param fitFunction A function that takes only the trainData object, fits the 
#'   model, and returns an "appropriate model object" that will then work in 
#'   predictFunction.
#' @param predictFunction A function that takes two arguments: a data.table 
#'   similar to trainData as well as the model object coming from fitFunction. 
#'   The function should then return the fitted values on this new data.table.
#' @param modelName The name of the model, used for file naming.
#' @param parallel Logical.  Should this be run in parallel?
#' 
#' @return Nothing, but a plot is generated and files with the predictions are 
#'   saved (one for each day step in the train data, and with predictions on all
#'   the test observations).
#'   

fitTimeCVModel <- function(trainData, testData, fitFunction, predictFunction, modelName, skipDates=0, parallel=FALSE){
    if(parallel){
        library(parallel)
        library(foreach)
        library(doParallel)
        nCores <- detectCores()
        registerDoParallel(cores=nCores)
    }
    testDate <- as.Date("2015-11-01")
    uniqueDates <- sort(unique(trainData$date))
    uniqueDates <- uniqueDates[(skipDates + 1):length(uniqueDates)]
    AUCdata <- NULL
    fullData <- rbindlist(list(trainData, testData), fill=TRUE)
    if(parallel){
        AUCdata = foreach::foreach(i=1:length(uniqueDates), .combine=rbind) %dopar%
            fitCVFold(endTrainDate=uniqueDates[i], fullData=fullData,
                      fitFunction=fitFunction, predictFunction=predictFunction, modelName=modelName)
    } else {
        for(i in 1:length(uniqueDates)){
            AUCdata <- rbind(AUCdata, fitCVFold(endTrainDate=uniqueDates[i], fullData=fullData,
                                                fitFunction=fitFunction, predictFunction=predictFunction,
                                                modelName=modelName))
        }
    }
    invisible(print(ggplot(AUCdata, aes(x=date - trainDate, y=AUC, group=trainDate)) + geom_line(alpha=.4) +
                        geom_smooth(aes(group=NULL))))
    save(AUCdata,
         file=paste0("data/output/summary_model.", modelName,
                     "_", as.character(Sys.time(), format="%Y%m%d%H%M%S"), ".RData"))
    return(AUCdata)
}