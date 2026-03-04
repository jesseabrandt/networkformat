# Convert to igraph

Generic function to convert tree-based model objects into
[`igraph`](https://r.igraph.org/reference/aaa-igraph-package.html) graph
objects. Methods call
[`edgelist`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
and
[`nodelist`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
internally and handle column reconciliation so you get a ready-to-use
graph.

## Usage

``` r
as_igraph(x, ...)

# S3 method for class 'tree'
as_igraph(x, ...)

# S3 method for class 'randomForest'
as_igraph(x, treenum = NULL, ...)

# S3 method for class 'rpart'
as_igraph(x, ...)

# S3 method for class 'xgb.Booster'
as_igraph(x, treenum = NULL, ...)

# S3 method for class 'gbm'
as_igraph(x, treenum = NULL, ...)
```

## Arguments

- x:

  An object to convert (`tree`, `randomForest`, `rpart`, `xgb.Booster`,
  or `gbm`).

- ...:

  Additional arguments passed to methods.

- treenum:

  Integer vector of tree numbers to extract. Default `NULL` returns all
  trees combined into one graph with disconnected components. Pass a
  single integer (e.g. `1`) to extract one tree.

## Value

An [`igraph`](https://r.igraph.org/reference/aaa-igraph-package.html)
object. For `randomForest` with multiple trees, the graph contains
disconnected components (one per tree) and a `treenum` vertex/edge
attribute.
