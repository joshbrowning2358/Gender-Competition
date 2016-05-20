library(data.table)

d <- fread("../Gender Competition/data/train_data_cleaned.csv", nrows = 100)
dcast.data.table(data = d, formula = visitId + fullVisitorId ~ pagetype, fun.aggregate = length)
