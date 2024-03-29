rm(list = ls())

library(rUtils)
library(rDatasets)

#------------------------ Sources -------------------------------------

source(file.path("resultGenerators", "featureSelectionDatasetsResultGenerator.R"))
source(file.path("resultGenerators", "featureSelectionResultsClustering.R"))
source(file.path("plots", "featureSelectionResultPlotting.R"))
source(file.path("plots", "dendrogramPlot.R"))
source(file.path("featureSelectionMethods", "FSelectorMethods.R"))
source(file.path("featureSelectionMethods", "generateFeatureSelectionMethods.R"))
source(file.path("clusterQualityIndexes", "clusterQualityIndexes.R"))
source(file.path("assessment", "classifiers", "classifiersWrappers.R"))
source(file.path("assessment", "metrics", "classificationMetrics.R"))
source(file.path("searchMethods", "sequential", "sequentialSearchMethods.R"))
source(file.path("utils", "syntheticBases.R"))
source(file.path("utils", "utils.R"))

#-----------------------------------------------------------------------

# remove scientific notation from double printing
options(scipen = 999)

searchMethods = list(SFS = sfs_fs)

classifiers = list(LDA = ldaWrapper,
                   svm = svmWrapper,
                   randomForest = randomForestWrapper)

clusterIndexesFeatureSelectionMethods <- generateFeatureSelectionMethods(
  searchMethods, multivariateCriterions = allClusterQualityIndexes)

featureSelectionMethods <- c(
  clusterIndexesFeatureSelectionMethods)

resultGenerator <- function() {
  result <<- featureSelectionDatasetsResultGenerator(
    datasets = syntheticDatasets(),
    featureSelectionMethods = featureSelectionMethods,
    assessmentClassifiers = classifiers,
    summaryFunction = featureSelectionResultSummary,
    allowParallel = TRUE)
  
  clusteringResult <<- computeHierarchicalClusteringFor(
    result$selectedFeaturesSubsets)
}

elapsedSeconds <- timeOperation(
  function() {
    runWithCpuParallelBackend(resultGenerator)
  })

load(file.path("main", "resultData", "syntheticDatasetsResult.RData"))

timePlot <- barplotForElapsedMinutes(result)
metricsPlots <- boxplotsForAllMetrics(result)

addCustomDescriptionToPlots(timePlot, metricsPlots)

plotDendrogram(clusteringResult$hclust)

print(paste("Elapsed:", elapsedSeconds / 60, "minutes"))

