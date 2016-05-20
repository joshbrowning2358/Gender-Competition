#' Reduce the number of categories in categorical variables.
#' 
#' @param trainData Category counts are aggregated over test and train.
#' @param testData
#' @param independentColumnNames Character vector specifying the factor columns.
#' @param maxCount Numeric value specifying the maximum number of levels 
#'   allowed.
#' @param minObs Instead of just taking the top maxCount categories, we can 
#'   remove categories with fewer than minObs observations.  Both approaches are
#'   not implemented, so either maxCount or minObs must be NULL.  minObs
#'   defaults to NULL.
#' @param nasAsClass Logical.  Should NA's be treated as a separate class?
#'   
#' @return No object is returned, but trainData and testData are modified in 
#'   place.
#'   

reduceCategories <- function(trainData, testData, independentColumnNames, maxCount=52, minObs=NULL,
                             nasAsClass=TRUE){
    if(!is.null(minObs) & !is.null(maxCount))
        stop("One of minObs and maxCount must be NULL!")
    if(is.null(minObs) & is.null(maxCount))
        stop("minObs and maxCount caanot both be NULL!")
    sapply(independentColumnNames, function(colname){
        trainData[, c(colname) := as.character(get(colname))]
        testData[, c(colname) := as.character(get(colname))]
        if(nasAsClass){
            trainData[is.na(get(colname)), c(colname) := "NA_level"]
            testData[is.na(get(colname)), c(colname) := "NA_level"]
        }
        fullVariable <- rbind(trainData[, colname, with=FALSE], testData[, colname, with=FALSE])
        fullVariable <- fullVariable[, .N, by=c(colname)][order(-N), ]
        if(!is.null(maxCount))
            topValues <- as.character(fullVariable[1:maxCount, get(colname)])
        else
            topValues <- fullVariable[N >= minObs, get(colname)]
        trainData[, c(colname) :=
                      ifelse(as.character(get(colname)) %in% topValues, as.character(get(colname)), "other")]
        testData[, c(colname) :=
                     ifelse(as.character(get(colname)) %in% topValues, as.character(get(colname)), "other")]
        # Set topValues as the levels so as to be sure both train and test have the same levels/orders.
        trainData[, c(colname) := factor(get(colname), levels=c(topValues, "other"))]
        testData[, c(colname) := factor(get(colname), levels=c(topValues, "other"))]
    })
    return()
}