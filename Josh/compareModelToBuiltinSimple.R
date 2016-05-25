library(data.table)
d = data.table(x = as.factor(c(0, 0, 0, 1, 1, 1)), y = c("M", "M", "F", "M", "F", "F"),
               keyVar = 1:6)
model = naiveBayes(y ~ x, data=d)
predict(model, newdata = d, type="raw")

model2 = fitNaiveBayesModel(d, variables="x", targetVar="y", key="keyVar")
preds = predictNaiveBayesModel(model2, newData = d, key = "keyVar")
preds
