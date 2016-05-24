
getGender <- function(data, keyColumnNames){
  kGenderColumnName <- "GENDER"
  kFemaleIndicator <- "F"
  
  data <- unique(data[, c(keyColumnNames, kGenderColumnName), with = FALSE])
  data[, GENDER := ifelse(GENDER == kFemaleIndicator, 1, 0)]
}