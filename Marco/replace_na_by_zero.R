replaceNAByZero <- function(dt){
  for (j in seq_len(ncol(dt)))
    set(dt, which(is.na(dt[[j]])), j, 0)
  
  dt
}