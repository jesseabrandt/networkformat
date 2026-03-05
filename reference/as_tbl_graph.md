# Convert to tbl_graph

S3 methods for converting tree-based model objects into
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
objects. Each method wraps the corresponding
[`as.igraph`](https://r.igraph.org/reference/as.igraph.html) method.
These methods are registered against the
[`as_tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
generic from tidygraph via delayed S3 registration and are available
whenever tidygraph is loaded.

## Usage

``` r
# S3 method for class 'tree'
as_tbl_graph(x, ...)

# S3 method for class 'randomForest'
as_tbl_graph(x, treenum = NULL, ...)

# S3 method for class 'rpart'
as_tbl_graph(x, ...)

# S3 method for class 'xgb.Booster'
as_tbl_graph(x, treenum = NULL, ...)

# S3 method for class 'gbm'
as_tbl_graph(x, treenum = NULL, ...)
```

## Arguments

- x:

  An object to convert (currently `tree`, `randomForest`, `rpart`,
  `xgb.Booster`, or `gbm`).

- ...:

  Additional arguments passed to
  [`as.igraph`](https://r.igraph.org/reference/as.igraph.html).

- treenum:

  Integer vector of tree numbers to extract. Default `NULL` returns all
  trees combined into one graph with disconnected components. Pass a
  single integer (e.g. `1`) to extract one tree.

## Value

A
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
object.
