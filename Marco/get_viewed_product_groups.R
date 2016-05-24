library(Matrix)
source("map_to_new_ids.R")

getViewedProductGroups <- function(dt, keyColumnName) {
  kProductGroupIdColumnName <- "PRODUCTGROUPID"
  
  dt <- unique(dt[, c(keyColumnName, kProductGroupIdColumnName), with = FALSE])
  dt[, viewed := 1]
  
  productGroupsMappingTable <- mapToNewIds(dt[, kProductGroupIdColumnName, with = FALSE])
  dt <- merge(dt, productGroupsMappingTable, by = kProductGroupIdColumnName)

  uniqueKeys <- unique(dt[[keyColumnName]])
  nUniqueKeys <- length(uniqueKeys)
  nUniqueProductGroups <- length(unique(dt$Id))
  
  viewedProductGroups <- sparseMatrix(i = dt[[keyColumnName]],
                                      j = dt$Id,
                                      x = dt$viewed,
                                      dims = c(nUniqueKeys, nUniqueProductGroups))

  viewedProductGroupsByKey <- cbind(uniqueKeys, viewedProductGroups)
  viewedProductGroupsByKey
}