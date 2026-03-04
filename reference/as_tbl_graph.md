# Convert to tbl_graph

Generic function and S3 methods for converting tree-based model objects
into
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
objects. Each method wraps the corresponding
[`as_igraph`](https://jesseabrandt.github.io/networkformat/reference/as_igraph.md)
method.

## Usage

``` r
as_tbl_graph(x, ...)

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

  Additional arguments passed to `as_igraph`.

- treenum:

  Integer vector of tree numbers to extract. Default `NULL` returns all
  trees combined into one graph with disconnected components. Pass a
  single integer (e.g. `1`) to extract one tree.

## Value

A
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
object.
