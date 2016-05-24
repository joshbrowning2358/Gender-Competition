source("get_variables_by_key.R")
source("calculate_principal_components.R")
#source('get_colors.R')

getExplanatoryVariablesUsingPrincipalComponents <- function(dt, keyColumnName, nPrincipalComponents = 10) {
  viewedProductGroupsByKey <- getVariablesByKey(dt, keyColumnName, "PRODUCTGROUPID")
  
  viewedProductGroupsPrincipalComponentsByKey <- 
    getPricipalComponentsByKey(viewedProductGroupsByKey, keyColumnName, nPrincipalComponents)
  
  webshopByKey <- getVariablesByKey(dt, keyColumnName, "webshop")
  
  webshopPrincipalComponentsByKey <- 
    getPricipalComponentsByKey(webshopByKey, keyColumnName, nPrincipalComponents)
  
  explanatoryVariables <- merge(viewedProductGroupsPrincipalComponentsByKey, 
                                webshopPrincipalComponentsByKey, 
                                by = keyColumnName)
  
  operatingSystemsByKey <- getVariablesByKey(dt, keyColumnName, "device_operatingSystem")
  operatingSystemsByKey <- as.data.table(as.matrix(operatingSystemsByKey))
  
  explanatoryVariables <- merge(explanatoryVariables, 
                                operatingSystemsByKey, 
                                by = keyColumnName)
  
  deviceBrowserByKey <- getVariablesByKey(dt, keyColumnName, "device_browser")
  deviceBrowserByKey <- as.data.table(as.matrix(deviceBrowserByKey))
  
  explanatoryVariables <- merge(explanatoryVariables, 
                                deviceBrowserByKey, 
                                by = keyColumnName)
  
  #colors <- getColors(cleanedData)
  #basicData <- merge(basicData, colors, by = keyColumnName)
  
  
  nExplanatoryVariables <- ncol(explanatoryVariables) - 1
  explanatoryVariableNames <- paste0("ExplanatoryVariable", 1:nExplanatoryVariables)
  
  setnames(explanatoryVariables, c(keyColumnName, explanatoryVariableNames))
  
  explanatoryVariables
}