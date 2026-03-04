# Extract Edgelist from XGBoost Model

Converts an xgboost model object into a network edgelist representation
using `xgb.model.dt.tree()`. Each edge connects a split node to one of
its two children (yes/no branches). Node IDs are globally unique strings
in `"Tree-Node"` format (e.g., `"0-3"`).

## Usage

``` r
# S3 method for class 'xgb.Booster'
edgelist(input_object, treenum = NULL, ...)
```

## Arguments

- input_object:

  An xgboost model object (`xgb.Booster`)

- treenum:

  Integer vector of 1-based tree numbers to extract (default: `NULL`
  extracts all trees).

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the following columns:

- from:

  Parent node ID string (`"Tree-Node"` format)

- to:

  Child node ID string

- feature:

  Name of the split variable (or 0-based index string when feature names
  are absent)

- split:

  Numeric split threshold

- quality:

  Information gain at the split

- cover:

  Number of observations covered

- treenum:

  1-based tree number

## Examples

``` r
if (requireNamespace("xgboost", quietly = TRUE)) {
  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(
    x = agaricus.train$data,
    y = factor(agaricus.train$label),
    max_depth = 2, nrounds = 2, nthreads = 1
  )
  el <- edgelist(bst)
  head(el)
}
#>   from  to                 feature   split   quality     cover treenum
#> 1  0-0 0-1               odor=none 2.00001 4005.7178 1626.1661       1
#> 2  0-1 0-3 spore-print-color=green 2.00001  198.1621  702.8493       1
#> 3  0-2 0-5         stalk-root=club 2.00001 1159.8702  923.3168       1
#> 4  1-0 1-1               odor=none 2.00001 2170.2515 1511.9938       2
#> 5  1-1 1-3 spore-print-color=green 2.00001  112.4270  638.1204       2
#> 6  1-2 1-5        bruises?=bruises 2.00001  826.5358  873.8734       2
```
