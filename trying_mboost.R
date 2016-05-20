library(data.table)
library(mboost)

sapply(dir("R/", full.names=TRUE), source)
load("data/train_data_cleaned.RData")
subData = trainData[1:100, ]

fit = mboost(factor(GENDER) ~ bbs(time) + btree(productid) + btree(webshop) +
                 bbs(totals_pageviews) + bbs(totals_timeOnSite) + btree(PRODUCTGROUPID) +
                 btree(BRANDID) + btree(device_deviceCategory), data=subData, family=Binomial())

data("bodyfat", package="TH.data")
mod <- mboost(DEXfat ~ btree(age) + bols(waistcirc) + bbs(hipcirc),
              data = bodyfat)
