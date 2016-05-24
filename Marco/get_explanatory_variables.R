source("get_variables_by_key.R")
source("calculate_principal_components.R")

getExplanatoryVariables <- function(dt, keyColumnName) {
  viewedProductGroupsByKey <- getVariablesByKey(dt, keyColumnName, "PRODUCTGROUPID")
  viewedProductTypesByKey <- getVariablesByKey(dt, keyColumnName, "PRODUCTTYPEID")
  viewedBrandsByKey <- getVariablesByKey(dt, keyColumnName, "BRANDID")
  viewedProductsByKey <- getVariablesByKey(dt, keyColumnName, "productid")
  webshopByKey <- getVariablesByKey(dt, keyColumnName, "webshop")
  operatingSystemsByKey <- getVariablesByKey(dt, keyColumnName, "device_operatingSystem")
  deviceBrowserByKey <- getVariablesByKey(dt, keyColumnName, "device_browser")
  hourByKey <- getVariablesByKey(dt, keyColumnName, "hour")
  minuteByKey <- getVariablesByKey(dt, keyColumnName, "minute")
  trafficSourceByKey <- getVariablesByKey(dt, keyColumnName, "trafficSource_source")
  deviceCategoryByKey <- getVariablesByKey(dt, keyColumnName, "device_deviceCategory")
  countryByKey <- getVariablesByKey(dt, keyColumnName, "geoNetwork_country")
  operatingSystemByKey <- getVariablesByKey(dt, keyColumnName, "device_operatingSystem")

  explanatoryVariables <- cbind(viewedProductGroupsByKey,
                                viewedProductTypesByKey[, -1],
                                viewedBrandsByKey[, -1],
                                viewedProductsByKey[, -1],
                                webshopByKey[, -1],
                                operatingSystemsByKey[, -1],
                                deviceBrowserByKey[, -1],
                                hourByKey[, -1],
                                minuteByKey[, -1],
                                trafficSourceByKey[, -1],
                                deviceCategoryByKey[, -1],
                                countryByKey[, -1],
                                operatingSystemByKey[, -1])

  explanatoryVariables
}
