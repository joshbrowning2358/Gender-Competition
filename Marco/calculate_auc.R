calculateAUC <- function (actual, predicted) 
{
  r <- rank(predicted)
  n_pos <- sum(actual == 1)
  n_neg <- length(actual) - n_pos
  auc <- ((sum(r[actual == 1]) - n_pos * (n_pos + 1)/2)  /  (n_pos) ) * (1 / n_neg)
  auc
}