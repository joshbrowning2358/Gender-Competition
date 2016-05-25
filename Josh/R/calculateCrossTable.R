#' Calculate Cross Table
#' 
#' @param data The input data.table object.
#' 
#' @return A data.table object containing the cross table.
#' 

calculateCrossTable = function(data, variables=c('pagetype', 'productid', 'webshop', 'trafficSource_source',
                                                 'trafficSource_medium', 'totals_pageviews', 'totals_timeOnSite',
                                                 'geoNetwork_country', 'device_browser', 'device_deviceCategory',
                                                 'device_operatingSystem', 'PRODUCTGROUPID', 'PRODUCTTYPEID',
                                                 'BRANDID', 'time'),
                               targetVar="GENDER"){
  if(any(!variables %in% colnames(data))){
    missingVariables = variables[!variables %in% colnames(data)]
    stop("Not all variables are in colnames(data). Missing: ", paste0(missingVariables, collapse=", "))
  }
  crossTableList = lapply(variables, function(column){
    resultData = data[, .N, by=c(column, targetVar)]
    setnames(resultData, c(column, "N"), c("value", "count"))
    resultData[, variable := column]
  })
  crossTable = do.call("rbind", crossTableList)
  return(crossTable)
}
