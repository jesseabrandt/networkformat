# Extract Edgelist from rpart Model

Converts an rpart model object into a network edgelist representation.
The rpart package uses binary heap numbering for node IDs (root = 1,
left child of k = 2k, right child of k = 2k + 1), so parent-child edges
are derived directly from the node IDs in
`rownames(input_object$frame)`.

## Usage

``` r
# S3 method for class 'rpart'
edgelist(input_object, ...)
```

## Arguments

- input_object:

  An rpart model object from the rpart package

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the following columns:

- from:

  Parent node ID (binary heap index)

- to:

  Child node ID (binary heap index)

- label:

  Split condition label from
  [`labels()`](https://rdrr.io/r/base/labels.html)

- split_var:

  Variable name used for the split

- split_op:

  Operator: `"<"` or `">="` for numeric splits, `NA` for categorical
  splits

- split_point:

  Numeric threshold for the split (`NA` for categorical splits)

## Details

Edge labels come from `labels(input_object, collapse = TRUE)`, which
correctly handles the `ncat` sign that controls split direction (left
child does not always get `"<"`).

## Examples

``` r
if (requireNamespace("rpart", quietly = TRUE)) {
  fit <- rpart::rpart(Species ~ ., data = iris)
  el <- edgelist(fit)
  head(el)

  # Parsed split components
  el[, c("split_var", "split_op", "split_point")]
}
#>      split_var split_op split_point
#> 1 Petal.Length        <        2.45
#> 2 Petal.Length       >=        2.45
#> 3  Petal.Width        <        1.75
#> 4  Petal.Width       >=        1.75
```
