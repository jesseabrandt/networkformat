# Extract Node List from XGBoost Model

Extracts node-level attributes from an xgboost model via
`xgb.model.dt.tree()`. Node IDs are globally unique strings in
`"Tree-Node"` format and match the `from`/`to` columns produced by
[`edgelist.xgb.Booster`](https://jesseabrandt.github.io/networkformat/reference/edgelist.xgb.Booster.md).

## Usage

``` r
# S3 method for class 'xgb.Booster'
nodelist(input_object, treenum = NULL, ...)
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

A data.frame with one row per node and the following columns:

- name:

  Node ID string (`"Tree-Node"` format, matches edgelist from/to)

- is_leaf:

  Logical: `TRUE` for leaf nodes

- feature:

  Split variable name (`NA` for leaves)

- split:

  Split threshold (`NA` for leaves)

- quality:

  Information gain for splits, leaf score for leaves

- cover:

  Cover (sum of second-order gradient)

- treenum:

  1-based tree number

- label:

  Display label: `"<feature>\n< <threshold>"` for splits, rounded leaf
  score for leaves

## Examples

``` r
if (requireNamespace("xgboost", quietly = TRUE)) {
  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(
    x = agaricus.train$data,
    y = factor(agaricus.train$label),
    max_depth = 2, nrounds = 2, nthreads = 1
  )
  nl <- nodelist(bst)
  head(nl)
}
#>   name is_leaf                 feature   split      quality      cover treenum
#> 1  0-0   FALSE               odor=none 2.00001 4005.7177700 1626.16614       1
#> 2  0-1   FALSE spore-print-color=green 2.00001  198.1621090  702.84930       1
#> 3  0-2   FALSE         stalk-root=club 2.00001 1159.8702400  923.31677       1
#> 4  0-3    TRUE                    <NA>      NA    0.5785417   13.23304       1
#> 5  0-4    TRUE                    <NA>      NA   -0.5614965  689.61627       1
#> 6  0-5    TRUE                    <NA>      NA   -0.4894775  112.35602       1
#>                          label
#> 1               odor=none\n< 2
#> 2 spore-print-color=green\n< 2
#> 3         stalk-root=club\n< 2
#> 4                       0.5785
#> 5                      -0.5615
#> 6                      -0.4895
```
