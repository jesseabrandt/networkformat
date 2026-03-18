# Extract Node List from RandomForest Model

Extracts node-level attributes from every tree in a `randomForest`
model. Node IDs match the `from`/`to` indices produced by
[`edgelist.randomForest`](https://jesseabrandt.github.io/networkformat/reference/edgelist.randomForest.md),
so the two outputs can be passed directly to
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html)
(after filtering to a single `treenum`).

## Usage

``` r
# S3 method for class 'randomForest'
nodelist(input_object, treenum = NULL, ...)
```

## Arguments

- input_object:

  A randomForest model object from the randomForest package

- treenum:

  Integer vector of tree numbers to extract (default: `NULL` extracts
  all trees). Values must be between 1 and `input_object$ntree`.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with one row per node (across all trees) and the following
columns:

- name:

  Integer node ID within the tree (matches edgelist from/to)

- is_leaf:

  Logical: `TRUE` for terminal nodes

- split_var:

  Numeric index of the split variable (`NA` for leaves)

- split_var_name:

  Name of the split variable (`NA` for leaves)

- split_point:

  Split threshold (`NA` for leaves)

- prediction:

  Predicted value (numeric for regression, integer class index for
  classification)

- treenum:

  Integer identifying which tree the node belongs to

- label:

  Display label: `"<var>\n< <threshold>"` for internal nodes, predicted
  class name (classification) or numeric value (regression) for leaves

## Examples

``` r
if (requireNamespace("randomForest", quietly = TRUE)) {
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  nodes <- nodelist(rf)
  head(nodes)

  # Extract a single tree
  nodes1 <- nodelist(rf, treenum = 1)
}
```
