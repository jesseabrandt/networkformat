# Changelog

## networkformat 0.0.0.9000 (Development version)

### Features

- [`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
  generic with methods for:
  - Atomic vectors — sequential edges connecting element `i` to `i + 1`
  - `data.frame` — column-pair edges with tidyselect, `na.rm`,
    `symmetric_cols`, `dedupe`, and `weights`
  - `randomForest` — parent-child splits with `treenum` filtering
  - `tree` — parent-child splits with parsed split components
- [`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
  generic with methods for:
  - Atomic vectors — unique values with frequency counts
  - `data.frame` — reorder with `id_col` first
  - `randomForest` — node attributes per tree
  - `tree` — node attributes with labels
- [`as_igraph()`](https://jesseabrandt.github.io/networkformat/reference/as_igraph.md)
  and
  [`as_tbl_graph()`](https://jesseabrandt.github.io/networkformat/reference/as_tbl_graph.md)
  for one-step graph construction from `tree` and `randomForest` models
- `weights` parameter for `edgelist.data.frame` and vector method —
  collapses duplicate rows and adds a `weight` count column
- Bundled `courses` dataset for examples
- 3 vignettes: package introduction, edgelist/nodelist guide,
  visualization
- Comprehensive test suite (275+ tests)

### Stubs (not yet implemented)

- [`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
  /
  [`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
  for `xgb.Booster`, `gbm`, `rpart`
