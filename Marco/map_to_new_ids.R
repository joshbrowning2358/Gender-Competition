mapToNewIds <- function(dt) {
  uniqueRows <- unique(dt)
  nUniqueRows <- nrow(uniqueRows)
  mappedTable <- data.table(uniqueRows, Id = 1:nUniqueRows)
  mappedTable
}