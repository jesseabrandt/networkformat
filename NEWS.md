# networkformat 0.0.0.9000 (Development version)

## New Features

* Initial release with S3 methods for extracting network edgelists from tree models
* `edgelist()` generic function with methods for:
  - `randomForest` objects
  - `tree` objects
  - `data.frame` objects
  - Default method with informative message
* `nodelist()` generic function for extracting node lists with attributes
* Comprehensive test suite with edge case coverage
* Detailed README with usage examples and visualization

## Work in Progress

* `edgelist.xgb.Booster()` method for XGBoost models (stub implementation)
* `nodelist.randomForest()` and `nodelist.tree()` methods need full implementation
* Vignettes for common workflows

## Documentation

* roxygen2 documentation for all exported functions
* Examples demonstrating network visualization with igraph and ggraph
* Package-level documentation
