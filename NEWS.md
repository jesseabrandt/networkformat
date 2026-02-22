# networkformat 0.0.0.9000 (Development version)

## New Features

* Initial release with S3 methods for extracting network edgelists from tree models
* `edges()` generic function with methods for:
  - `randomForest` objects
  - `tree` objects  
  - `data.frame` objects
  - Default method with informative message
* `nodes()` generic function for extracting node lists with attributes
* Comprehensive test suite with edge case coverage
* Detailed README with usage examples and visualization

## Work in Progress

* `edges.xgb.Booster()` method for XGBoost models (stub implementation)
* `nodes.randomForest()` and `nodes.tree()` methods need full implementation
* Vignettes for common workflows

## Documentation

* roxygen2 documentation for all exported functions
* Examples demonstrating network visualization with igraph and ggraph
* Package-level documentation
