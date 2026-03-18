# Extract Node List from GBM Model

Extracts node-level attributes from a gbm model via `pretty.gbm.tree()`.
Missing-sentinel nodes are excluded by keeping only nodes reachable
through `LeftNode`/`RightNode` edges from the root.

## Usage

``` r
# S3 method for class 'gbm'
nodelist(input_object, treenum = NULL, ...)
```

## Arguments

- input_object:

  A gbm model object from the gbm package

- treenum:

  Integer vector of 1-based tree numbers to extract (default: `NULL`
  extracts all trees).

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with one row per real node and the following columns:

- name:

  0-based node ID within the tree

- is_leaf:

  Logical: `TRUE` for terminal nodes

- split_var:

  0-based variable index (`NA` for leaves)

- split_var_name:

  Variable name (`NA` for leaves)

- split_point:

  Split threshold (`NA` for leaves)

- prediction:

  Prediction value at the node

- treenum:

  1-based tree number

- label:

  Display label: `"<var>\n< <threshold>"` for splits, rounded prediction
  for leaves

## Examples

``` r
if (requireNamespace("gbm", quietly = TRUE)) {
  set.seed(1)
  fit <- gbm::gbm(mpg ~ ., data = mtcars,
                   distribution = "gaussian", n.trees = 5,
                   interaction.depth = 3, n.minobsinnode = 3)
  nl <- nodelist(fit)
  head(nl)
}
#>   name is_leaf split_var split_var_name split_point prediction treenum
#> 1    0   FALSE         0            cyl         5.0 -0.0290625       1
#> 2    1    TRUE        NA           <NA>          NA  0.8434375       1
#> 3    2   FALSE         2            cyl       177.5 -0.3198958       1
#> 4    3   FALSE         0            cyl         7.0 -0.1176339       1
#> 5    4    TRUE        NA           <NA>          NA -0.0340625       1
#> 6    5    TRUE        NA           <NA>          NA -0.2290625       1
#>          label
#> 1     cyl\n< 5
#> 2       0.8434
#> 3 cyl\n< 177.5
#> 4     cyl\n< 7
#> 5      -0.0341
#> 6      -0.2291
```
