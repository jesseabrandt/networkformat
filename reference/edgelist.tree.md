# Extract Edgelist from Tree Model

Converts a tree model object (from the tree package) into a network
edgelist representation. The tree package uses binary heap numbering for
node IDs (root = 1, left child of k = 2k, right child of k = 2k + 1), so
parent-child edges are derived directly from the node IDs in
`rownames(input_object$frame)`.

## Usage

``` r
# S3 method for class 'tree'
edgelist(input_object, ...)
```

## Arguments

- input_object:

  A tree model object from the tree package

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the following columns:

- from:

  Parent node ID (binary heap index)

- to:

  Child node ID (binary heap index)

- label:

  Split condition label (variable and threshold)

- split_var:

  Variable name used for the split

- split_op:

  Operator: `"<"` or `">"` for numeric splits, `NA` for categorical
  splits

- split_point:

  Numeric threshold for the split (`NA` for categorical splits)

## Examples

``` r
if (requireNamespace("tree", quietly = TRUE)) {
  # Fit a classification tree
  tree_model <- tree::tree(Species ~ ., data = iris)

  # Extract edgelist
  tree_edges <- edgelist(tree_model)
  head(tree_edges)

  # Parsed split components
  tree_edges[, c("split_var", "split_op", "split_point")]
}
#>       split_var split_op split_point
#> 1  Petal.Length        <        2.45
#> 2  Petal.Length        >        2.45
#> 3   Petal.Width        <        1.75
#> 4  Petal.Length        <        4.95
#> 5  Sepal.Length        <        5.15
#> 6  Sepal.Length        >        5.15
#> 7  Petal.Length        >        4.95
#> 8   Petal.Width        >        1.75
#> 9  Petal.Length        <        4.95
#> 10 Petal.Length        >        4.95
```
