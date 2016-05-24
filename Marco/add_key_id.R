library(data.table)

addKeyId <- function(dt, keyColumnNames) {
  kIdColumnName <- "Id"
  kSessionIdColumnName <- "KeyId"

  sessionMappingTable <- mapToNewIds(dt[, keyColumnNames, with = FALSE])
  dt <- merge(dt, sessionMappingTable, by = keyColumnNames)
  setnames(dt, kIdColumnName, kSessionIdColumnName)
  dt
}