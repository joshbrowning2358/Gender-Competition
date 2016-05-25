#' Combine Models
#' 
#' @param modelNames A character vector of model names, specifying which files
#'   should be loaded.
#' @param directory A character string specifying the directory of the models.
#' 

combineModels <- function(modelNames, directory = "E:/Github/Working/Gender Competition/data/output"){
    allFiles <- list.files(directory, pattern="*.RData")
    allModels <- unique(gsub(".*_model\\.|_auc.*", "", allFiles))
    if(!all(modelNames %in% allModels))
        stop("Not all modelNames are valid!  Possible options are:\n", paste0(allModels, collapse=", "))
}