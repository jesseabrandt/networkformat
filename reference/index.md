# Package index

## Core generics

The main generic functions exported by networkformat.

- [`networkformat`](https://jesseabrandt.github.io/networkformat/reference/networkformat-package.md)
  [`networkformat-package`](https://jesseabrandt.github.io/networkformat/reference/networkformat-package.md)
  : networkformat: Convert R Objects to Network Edgelists and Nodelists
- [`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
  : Extract Edgelist from Various Object Types
- [`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
  : Extract Node List from Various Objects
- [`as.igraph(`*`<tree>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
  [`as.igraph(`*`<randomForest>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
  [`as.igraph(`*`<rpart>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
  [`as.igraph(`*`<xgb.Booster>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
  [`as.igraph(`*`<gbm>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
  : Convert to igraph
- [`as_tbl_graph(`*`<tree>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  [`as_tbl_graph(`*`<randomForest>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  [`as_tbl_graph(`*`<rpart>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  [`as_tbl_graph(`*`<xgb.Booster>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  [`as_tbl_graph(`*`<gbm>`*`)`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  : Convert to tbl_graph

## Vector and data frame methods

Methods for atomic vectors (sequential edges) and data frames
(column-pair edges with tidyselect).

- [`edgelist(`*`<default>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.default.md)
  : Extract Edgelist from a Vector or Unsupported Object
- [`nodelist(`*`<default>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.default.md)
  : Extract Node List from a Vector or Unsupported Object
- [`edgelist(`*`<data.frame>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.data.frame.md)
  : Extract Edgelist from Data Frame
- [`nodelist(`*`<data.frame>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.data.frame.md)
  : Extract Node List from Data Frame

## List methods

Methods for lists and S3 objects (recursive parent-child decomposition).

- [`edgelist(`*`<list>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.list.md)
  : Extract Edgelist from a List
- [`nodelist(`*`<list>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.list.md)
  : Extract Node List from a List

## Tree model methods

Methods for tree-based machine learning models.

- [`edgelist(`*`<tree>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.tree.md)
  : Extract Edgelist from Tree Model
- [`nodelist(`*`<tree>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.tree.md)
  : Extract Node List from Tree Model
- [`edgelist(`*`<rpart>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.rpart.md)
  : Extract Edgelist from rpart Model
- [`nodelist(`*`<rpart>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.rpart.md)
  : Extract Node List from rpart Model
- [`edgelist(`*`<randomForest>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.randomForest.md)
  : Extract Edgelist from RandomForest Model
- [`nodelist(`*`<randomForest>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.randomForest.md)
  : Extract Node List from RandomForest Model
- [`edgelist(`*`<xgb.Booster>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.xgb.Booster.md)
  : Extract Edgelist from XGBoost Model
- [`nodelist(`*`<xgb.Booster>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.xgb.Booster.md)
  : Extract Node List from XGBoost Model
- [`edgelist(`*`<gbm>`*`)`](https://jesseabrandt.github.io/networkformat/reference/edgelist.gbm.md)
  : Extract Edgelist from GBM Model
- [`nodelist(`*`<gbm>`*`)`](https://jesseabrandt.github.io/networkformat/reference/nodelist.gbm.md)
  : Extract Node List from GBM Model

## Data

Example datasets included with the package.

- [`courses`](https://jesseabrandt.github.io/networkformat/reference/courses.md)
  : Course prerequisite and crosslisting network
