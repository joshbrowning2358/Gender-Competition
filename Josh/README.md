# Initial Steps

In order to run this code, you first need to run the initial_cleaning.R file and have two .csv files called train_data.csv and test_data.csv in a folder called data.  This script then creates two RData objects in that same folder which will be used later.

# Layout

Most of the .R files in the top directory are scripts I wrote while playing around with the data or trying different things.  The main script that I used in called fitCV.R, and this script fits cross-validation folds, defined by increasing training windows, to the training data while generating predictions on the test data (and evaluating the prediction on the out-of-bag training data).

The functions that I use in fitCV.R are all defined in the R directory.

My best model is the second call to fitTimeCVModel (in the fitCV.R script).  It fits a naive bayes model with all variables except productid.  Including productid as well had a very slight decrease to the AUC on the test set, but it did perform much better on the cross-validation folds.