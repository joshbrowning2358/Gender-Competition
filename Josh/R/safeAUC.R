#' Safe AUC function
#' 
#' caTools::colAUC will fail if the target has only one class.  To avoid errors,
#' just use this function and return NA in those cases.
#' 
#' @param x Numeric vector of the predicted probabilities.
#' @param y Numeric vector of 0s or 1s representing the true values.
#' 
#' @return The value of the AUC, or NA if the target has only one level.

safeAUC <- function(x, y){
    if(length(unique(y))!=2)
        return(NA)
    caTools::colAUC(y=y, X=matrix(x, ncol=1))
}