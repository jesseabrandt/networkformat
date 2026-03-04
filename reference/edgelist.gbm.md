# Extract Edgelist from GBM Model

Converts a gbm model object into a network edgelist representation using
`pretty.gbm.tree()`. Missing-sentinel nodes (the phantom routing nodes
gbm creates for NA handling) are excluded — only real
`LeftNode`/`RightNode` edges are returned.

## Usage

``` r
# S3 method for class 'gbm'
edgelist(input_object, treenum = NULL, ...)
```

## Arguments

- input_object:

  A gbm model object from the gbm package

- treenum:

  Integer vector of 1-based tree numbers to extract (default: `NULL`
  extracts all trees). For multinomial models, this indexes physical
  trees (not boosting iterations).

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the following columns:

- from:

  Parent node ID (0-based integer)

- to:

  Child node ID (0-based integer)

- split_var:

  0-based variable index

- split_point:

  Split threshold for continuous variables, or `c.splits` index for
  categorical variables

- prediction:

  Prediction value at the child node

- treenum:

  1-based tree number

- split_var_name:

  Human-readable variable name

## Details

Node IDs are 0-based integers per tree. For models with
`num.classes > 1` (multinomial), physical trees are stored as
`n.trees * num.classes` entries; `treenum` indexes into this flat
sequence.

## Examples

``` r
if (requireNamespace("gbm", quietly = TRUE)) {
  set.seed(1)
  fit <- gbm::gbm(mpg ~ ., data = mtcars,
                   distribution = "gaussian", n.trees = 5,
                   interaction.depth = 3, n.minobsinnode = 3)
  el <- edgelist(fit)
  head(el)

  # Single tree
  el1 <- edgelist(fit, treenum = 1)
}
```
