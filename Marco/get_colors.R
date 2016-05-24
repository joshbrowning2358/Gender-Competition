getColors <- function(dt, keyColumnNames) {
  existingColors <- getExistingColors()

  dt <- dt[!is.na(product), c('accountid','product'), with = FALSE]
  dt[, rowid := 1:nrow(dt)]
  setkey(dt, rowid)
  
  for (column in seq_len(ncol(existingColors)))
  {
    existingColor <- existingColors[, column]
    dt <- dt[, eval(head(existingColor, 1)) := getColor(.SD, existingColor), by = rowid]
  }

  dt
}

getColor <- function(row, existingColor) {
  result <- FALSE
  element <- 1
  
  words <- strsplit(row$product[[1]], " ")
  
  while (!result && element <= length(existingColor)) {
    result <- any(words[[1]] == existingColor[element])
    element <- element + 1
  }
    
  ifelse(result, 1, 0)
}

getExistingColors <- function() {
  rbind(c("Black", "Grey", "Silver", "Gold", "Blue", "Red", "Green", "Pink", "Purple", "White", "Yellow"),
                c("Zwart", "Grijs", "Zilver", "Goud", "Blauw", "Rood", "Groen", "Roze", "Paars", "Wit", "Geel"),
                c("zwart", "Gray", "zilver", "goud", "blauw", "rood", "groen", "roze", "paars", "wit", "geel"))
}
