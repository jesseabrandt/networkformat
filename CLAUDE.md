# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## What This Package Does

**networkformat** is an R package that converts R objects — vectors,
data frames, lists, and tree-based ML models — into network
edgelist/nodelist format for visualization and analysis with
igraph/tidygraph/ggraph. Version 0.0.0.9000 (experimental).

## Development Commands

``` r
# Load package for interactive development
devtools::load_all()

# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-edgelist.R")

# Regenerate documentation (man/ pages and NAMESPACE) after changing roxygen2 comments
devtools::document()

# Render README
rmarkdown::render("README.Rmd")

# Full package check
devtools::check()
```

- `README.md` is generated from `README.Rmd` — do not edit `README.md`
  directly
- Documentation is roxygen2-generated — edit roxygen comments in
  `R/*.R`, then run `devtools::document()`

## Architecture

The package uses **S3 method dispatch** with four groups of functions:

### `edgelist()` — extract edges

| Method                  | Input         | Key Parameters                                                                            | Output Columns                                                        | Status   |
|-------------------------|---------------|-------------------------------------------------------------------------------------------|-----------------------------------------------------------------------|----------|
| `edgelist.default`      | atomic vector | `weights`                                                                                 | from, to, \[weight\]                                                  | Complete |
| `edgelist.list`         | list          | `name_root`, `max_depth`                                                                  | from, to, depth                                                       | Complete |
| `edgelist.data.frame`   | data.frame    | `source_cols`, `target_cols`, `attr_cols`, `na.rm`, `symmetric_cols`, `dedupe`, `weights` | from, to, from_col, to_col, \[directed\], \[weight\], \<attrs\>       | Complete |
| `edgelist.randomForest` | randomForest  | `treenum`                                                                                 | from, to, split_var, split_point, prediction, treenum, split_var_name | Complete |
| `edgelist.tree`         | tree          |                                                                                           | from, to, label, split_var, split_op, split_point                     | Complete |
| `edgelist.rpart`        | rpart         |                                                                                           | from, to, label, split_var, split_op, split_point                     | Complete |
| `edgelist.xgb.Booster`  | xgb.Booster   | `treenum`                                                                                 | from, to, feature, split, quality, cover, treenum                     | Complete |
| `edgelist.gbm`          | gbm           | `treenum`                                                                                 | from, to, split_var, split_point, prediction, treenum, split_var_name | Complete |

### `nodelist()` — extract node attributes

| Method                  | Input         | Key Parameters           | Output Columns                                                                    | Status   |
|-------------------------|---------------|--------------------------|-----------------------------------------------------------------------------------|----------|
| `nodelist.default`      | atomic vector |                          | name, n                                                                           | Complete |
| `nodelist.list`         | list          | `name_root`, `max_depth` | name, depth, type, n_children, label                                              | Complete |
| `nodelist.data.frame`   | data.frame    | `id_col`                 | (reordered input, id_col first)                                                   | Complete |
| `nodelist.randomForest` | randomForest  | `treenum`                | name, is_leaf, split_var, split_var_name, split_point, prediction, treenum, label | Complete |
| `nodelist.tree`         | tree          |                          | name, var, n, dev, yval, is_leaf, label                                           | Complete |
| `nodelist.rpart`        | rpart         |                          | name, var, n, dev, yval, is_leaf, label                                           | Complete |
| `nodelist.xgb.Booster`  | xgb.Booster   | `treenum`                | name, is_leaf, feature, split, quality, cover, treenum, label                     | Complete |
| `nodelist.gbm`          | gbm           | `treenum`                | name, is_leaf, split_var, split_var_name, split_point, prediction, treenum, label | Complete |

### `as.igraph()` / `as_tbl_graph()` — direct graph construction

| Method                      | Input        | Key Parameters                   | Returns                                           |
|-----------------------------|--------------|----------------------------------|---------------------------------------------------|
| `as.igraph.tree`            | tree         |                                  | igraph                                            |
| `as.igraph.randomForest`    | randomForest | `treenum` (default `NULL` = all) | igraph (multiple trees = disconnected components) |
| `as.igraph.rpart`           | rpart        |                                  | igraph                                            |
| `as.igraph.xgb.Booster`     | xgb.Booster  | `treenum` (default `NULL` = all) | igraph (string IDs, globally unique)              |
| `as.igraph.gbm`             | gbm          | `treenum` (default `NULL` = all) | igraph (multi-tree: prefixed IDs)                 |
| `as_tbl_graph.tree`         | tree         |                                  | tbl_graph                                         |
| `as_tbl_graph.randomForest` | randomForest | `treenum` (default `NULL` = all) | tbl_graph                                         |
| `as_tbl_graph.rpart`        | rpart        |                                  | tbl_graph                                         |
| `as_tbl_graph.xgb.Booster`  | xgb.Booster  | `treenum` (default `NULL` = all) | tbl_graph                                         |
| `as_tbl_graph.gbm`          | gbm          | `treenum` (default `NULL` = all) | tbl_graph                                         |

**Both `as.igraph` and `as_tbl_graph` use delayed S3 registration** —
the generics belong to igraph and tidygraph respectively, not this
package. The methods are registered via
`S3method(igraph::as.igraph, class)` and
`S3method(tidygraph::as_tbl_graph, class)` in NAMESPACE (R \>= 3.6.0
feature), with `@exportS3Method igraph::as.igraph` and
`@exportS3Method tidygraph::as_tbl_graph` in roxygen. Do NOT add an
`as.igraph` or `as_tbl_graph` generic (`UseMethod`) or `export()` to
this package — that creates a competing generic that masks the external
package’s.

Node IDs in nodelist outputs match the from/to columns in the
corresponding edgelist, so they can be passed directly to
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html).

### Duplicate handling

- **vector**: `weights = TRUE` collapses duplicate `(from, to)` pairs
  with a count.
  [`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
  always returns unique values with frequency in the `n` column.
- **data.frame**: `weights = TRUE` collapses fully identical rows (all
  columns must match, not just from/to) and adds a `weight` column. This
  is separate from `symmetric_cols` + `dedupe`, which normalizes edge
  direction.
- **list**: Edges are structurally unique (one edge per parent-child
  pair); duplicates cannot occur.
- **randomForest / tree / rpart / xgboost / gbm**: Edges are
  structurally unique (tree topology); duplicates cannot occur.

### File organization

Each S3 method lives in its own file: `R/edgelist.R` (generic),
`R/edgelist.data.frame.R`, `R/edgelist.randomForest.R`, etc. Same
pattern for `nodelist.*`. Graph conversion methods live in
`R/as.igraph.R` (methods for
[`igraph::as.igraph`](https://r.igraph.org/reference/as.igraph.html))
and `R/as_tbl_graph.R` (methods for
[`tidygraph::as_tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)).

### Key algorithms

- **vector (default)**: Sequential edges: element `i` connects to
  element `i + 1`, producing `n - 1` edges from a length-`n` vector.
- **list**: Recursive traversal of nested list structure. Each element
  produces a parent-child edge. Path-style IDs (`root/a/b`) ensure
  uniqueness. Named elements use their names; unnamed elements use
  positional indices (`[[1]]`). `max_depth` limits recursion. S3 objects
  without a dedicated method fall through from `edgelist.default` via
  [`is.list()`](https://rdrr.io/r/base/list.html) check and are
  unclassed before traversal.
- **randomForest**: Iterates trees via
  [`randomForest::getTree()`](https://rdrr.io/pkg/randomForest/man/getTree.html),
  identifies parent nodes (`left_daughter != 0`), creates edges to both
  children. `treenum` filters to specific trees.
- **tree**: Binary heap node IDs from `rownames(frame)` (root=1,
  left=2k, right=2k+1). Parent-child edges derived via `id %/% 2`. Split
  labels and parsed components (`split_var`, `split_op`, `split_point`)
  from the `splits` matrix.
- **data.frame**: Cartesian product of source/target column pairs.
  Builds edge blocks with `na.rm` filtering, optional `directed` column
  from `symmetric_cols`, direction-based dedup, and row-level dedup via
  `weights`.
- **rpart**: Same binary heap approach as tree (root=1, left=2k,
  right=2k+1). Edge labels from `labels(input_object, collapse = TRUE)`
  which handles `ncat` sign correctly. Uses `<` and `>=` operators
  (unlike tree’s `<`/`>`).
- **xgboost**: Uses `xgb.model.dt.tree()` data.table. Split nodes have
  explicit `Yes`/`No` ID columns (string format `"Tree-Node"`). No
  phantom nodes.
- **gbm**: Uses `pretty.gbm.tree()`. Must exclude missing-sentinel nodes
  (phantom routing nodes for NA handling). Node IDs are 0-based
  integers. Multinomial models store `n.trees * num.classes` physical
  trees.

### Dependencies

- **Imports**: `rlang`, `tidyselect` (used by `edgelist.data.frame` and
  `nodelist.data.frame` for column selection)
- **Suggests**: `randomForest`, `tree`, `xgboost`, `gbm`, `rpart`,
  `testthat`, `covr`, `igraph`, `tidygraph`, `ggraph`, `knitr`,
  `rmarkdown`

### Data

- `courses` — 13-row data.frame of university courses with
  prereq/crosslist/dept/credits/level columns. Used in examples and
  tests. Source: `data-raw/courses.R`.

## Adding a New Model Type

1.  Create `R/edgelist.newclass.R` with
    `edgelist.newclass(input_object, ...)`
2.  Optionally create `R/nodelist.newclass.R`
3.  Add `@export` roxygen tag and run `devtools::document()`
4.  Add tests in `tests/testthat/test-edgelist.R`
5.  Use `R/edgelist.randomForest.R` as reference

## Testing

- Framework: testthat 3rd edition
- Test files: `test-edgelist.R` (~220 tests), `test-nodelist.R` (~171
  tests), `test-as.igraph.R` (tests `as.igraph()` and `as_tbl_graph()`
  methods)
- Tests for randomForest/tree use `skip_if_not_installed()`
- The overlap warning in `test-edgelist.R` is expected (tests that
  `attr_cols` overlap triggers a warning)

## Comments and Documentation Style

- Comments should describe what code does, not how it differs from a
  previous version. Avoid words like “now”, “already”, “instead”, “no
  longer”, or “changed to” that frame current behavior relative to past
  behavior.
- Vignette prose should read as a standalone guide for the user, not a
  changelog.

## Vignettes and Articles

- `vignettes/networkformat.Rmd` — package introduction
- `vignettes/edgelist-nodelist.Rmd` — edgelist/nodelist usage guide
- `vignettes/visualization.Rmd` — ggraph visualization examples
- `vignettes/articles/complete-method-reference.Rmd` — pkgdown-only
  article covering every method (not shipped with the package)
- `vignettes/articles/visual-qa.Rmd` — pkgdown-only article plotting
  every model type

The pkgdown site is configured via `_pkgdown.yml`. The site is deployed
to GitHub Pages via `.github/workflows/pkgdown.yml`.

## Dev Request Workflow

Structured system for queuing feature/bug-fix requests. Write a request
doc using `dev/prompt-template.md` as a template, drop it in
`dev/requests/`, and process it:

- **Interactive**: `/dev-request 001`
- **Headless**: `bash dev/run-request.sh 001`
- **Watch**: `bash dev/watch-requests.sh`

See `dev/requests/README.md` for details.
