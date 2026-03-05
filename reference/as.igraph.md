# Convert to igraph

S3 methods for converting tree-based model objects into
[`igraph`](https://r.igraph.org/reference/aaa-igraph-package.html) graph
objects. Each method calls
[`edgelist`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
and
[`nodelist`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
internally and handles column reconciliation so you get a ready-to-use
graph. These methods are registered against the
[`as.igraph`](https://r.igraph.org/reference/as.igraph.html) generic
from igraph via delayed S3 registration and are available whenever
igraph is loaded.

## Usage

``` r
# S3 method for class 'tree'
as.igraph(x, ...)

# S3 method for class 'randomForest'
as.igraph(x, treenum = NULL, ...)

# S3 method for class 'rpart'
as.igraph(x, ...)

# S3 method for class 'xgb.Booster'
as.igraph(x, treenum = NULL, ...)

# S3 method for class 'gbm'
as.igraph(x, treenum = NULL, ...)
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
