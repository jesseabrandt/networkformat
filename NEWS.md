# networkformat 0.1.0

## Features

* `edgelist()` generic with methods for:
  - Atomic vectors --- sequential edges connecting element `i` to `i + 1`
  - `data.frame` --- column-pair edges with tidyselect, `na.rm`, `symmetric_cols`, `dedupe`, and `weights`
  - `randomForest` --- parent-child splits with `treenum` filtering
  - `tree` --- parent-child splits with parsed split components
  - `rpart` --- parent-child splits with parsed split components
  - `xgb.Booster` --- parent-child splits with feature/split/quality/cover
  - `gbm` --- parent-child splits with `treenum` filtering
* `nodelist()` generic with methods for:
  - Atomic vectors --- unique values with frequency counts
  - `data.frame` --- reorder with `id_col` first
  - `randomForest` --- node attributes per tree
  - `tree` --- node attributes with labels
  - `rpart` --- node attributes with labels
  - `xgb.Booster` --- node attributes with labels
  - `gbm` --- node attributes per tree
* `as.igraph()` methods for one-step igraph construction from `tree`,
  `randomForest`, `rpart`, `xgb.Booster`, and `gbm` models --- registered
  against igraph's `as.igraph()` generic via delayed S3 registration
* `as_tbl_graph()` methods for one-step tbl_graph construction from the same
  model types --- registered against tidygraph's `as_tbl_graph()` generic
  via delayed S3 registration
* `weights` parameter for `edgelist.data.frame` and vector method --- collapses duplicate rows and adds a `weight` count column
* Bundled `courses` dataset for examples
* 3 vignettes: package introduction, edgelist/nodelist guide, visualization
* Comprehensive test suite (275+ tests)
