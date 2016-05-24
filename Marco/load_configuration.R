loadConfiguration <- function(filename) {
  config <- loadConfigs(filename)
  config <- setClasses(config)
  config <- setNumericValues(config)
  config
}

setClasses <- function(config) {
  class(config$estimationDataPreparation$dataSource) <- config$estimationDataPreparation$dataSource
  class(config$evaluationDataPreparation$dataSource) <- config$evaluationDataPreparation$dataSource
  class(config$model) <- config$model
  config
}

setNumericValues <- function(config) {
  config$estimationDataPreparation$trainingSetPercentage <- 
    as.numeric(config$estimationDataPreparation$trainingSetPercentage)
  
  config
}