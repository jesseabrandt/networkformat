# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Package Does

**networkformat** is an R package that converts R objects — vectors, data frames, and tree-based ML models — into network edgelist/nodelist format for visualization and analysis with igraph/tidygraph/ggraph. Version 0.0.0.9000 (experimental).

## Development Commands

```bash
# Run all tests (sources files manually; no devtools in this environment)
Rscript -e '
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE))
  tryCatch(source(f), error = function(e) message("Skip ", f))
load("data/courses.rda")
testthat::test_file("tests/testthat/test-edgelist.R")
testthat::test_file("tests/testthat/test-nodelist.R")
'

# Run a single test file
Rscript -e '
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE))
  tryCatch(source(f), error = function(e) message("Skip ", f))
load("data/courses.rda")
testthat::test_file("tests/testthat/test-edgelist.R")
'

# Full package check (if devtools available)
Rscript -e 'devtools::check()'

# Build the package
R CMD build .
```

### Environment notes

- R 4.2.2 is available but devtools/roxygen2 are **not installed**
- Man pages and NAMESPACE must be edited by hand (mirror roxygen2 format)
- `README.md` is generated from `README.Rmd` — do not edit `README.md` directly
- Tests source all `R/*.R` files and `load("data/courses.rda")` before running

## Architecture

The package uses **S3 method dispatch** with four groups of functions:

### `edgelist()` — extract edges

| Method | Input | Key Parameters | Output Columns | Status |
|--------|-------|---------------|----------------|--------|
| `edgelist.default` | atomic vector | `weights` | from, to, [weight] | Complete |
| `edgelist.data.frame` | data.frame | `source_cols`, `target_cols`, `attr_cols`, `na.rm`, `symmetric_cols`, `dedupe`, `weights` | from, to, from_col, to_col, [directed], [weight], \<attrs\> | Complete |
| `edgelist.randomForest` | randomForest | `treenum` | from, to, split_var, split_point, prediction, treenum, split_var_name | Complete |
| `edgelist.tree` | tree | | from, to, label, split_var, split_op, split_point | Complete |
| `edgelist.xgb.Booster` | xgb.Booster | | — | Stub |
| `edgelist.gbm` | gbm | | — | Stub |
| `edgelist.rpart` | rpart | | — | Stub |

### `nodelist()` — extract node attributes

| Method | Input | Key Parameters | Output Columns | Status |
|--------|-------|---------------|----------------|--------|
| `nodelist.default` | atomic vector | | name, n | Complete |
| `nodelist.data.frame` | data.frame | `id_col` | (reordered input, id_col first) | Complete |
| `nodelist.randomForest` | randomForest | `treenum` | name, is_leaf, split_var, split_var_name, split_point, prediction, treenum, label | Complete |
| `nodelist.tree` | tree | | name, var, n, dev, yval, is_leaf, label | Complete |
| `nodelist.xgb.Booster` | xgb.Booster | | — | Stub |
| `nodelist.gbm` | gbm | | — | Stub |
| `nodelist.rpart` | rpart | | — | Stub |

### `as_igraph()` / `as_tbl_graph()` — direct graph construction

| Method | Input | Key Parameters | Returns |
|--------|-------|---------------|---------|
| `as_igraph.tree` | tree | | igraph |
| `as_igraph.randomForest` | randomForest | `treenum` (default `1`) | igraph (multiple trees = disconnected components) |
| `as_tbl_graph.tree` | tree | | tbl_graph |
| `as_tbl_graph.randomForest` | randomForest | `treenum` (default `1`) | tbl_graph |

Node IDs in nodelist outputs match the from/to columns in the corresponding edgelist, so they can be passed directly to `igraph::graph_from_data_frame()`.

### Duplicate handling

- **vector**: `weights = TRUE` collapses duplicate `(from, to)` pairs with a count. `nodelist()` always returns unique values with frequency in the `n` column.
- **data.frame**: `weights = TRUE` collapses fully identical rows (all columns must match, not just from/to) and adds a `weight` column. This is separate from `symmetric_cols` + `dedupe`, which normalizes edge direction.
- **randomForest / tree**: Edges are structurally unique (tree topology); duplicates cannot occur.

### File organization

Each S3 method lives in its own file: `R/edgelist.R` (generic), `R/edgelist.data.frame.R`, `R/edgelist.randomForest.R`, etc. Same pattern for `nodelist.*`, `as_igraph.R`, `as_tbl_graph.R`.

### Key algorithms

- **vector (default)**: Sequential edges: element `i` connects to element `i + 1`, producing `n - 1` edges from a length-`n` vector.
- **randomForest**: Iterates trees via `randomForest::getTree()`, identifies parent nodes (`left_daughter != 0`), creates edges to both children. `treenum` filters to specific trees.
- **tree**: Parent-stack algorithm to reconstruct binary tree traversal. Generates human-readable split labels and parsed components (`split_var`, `split_op`, `split_point`).
- **data.frame**: Cartesian product of source/target column pairs. Builds edge blocks with `na.rm` filtering, optional `directed` column from `symmetric_cols`, direction-based dedup, and row-level dedup via `weights`.

### Dependencies

- **Imports**: `rlang`, `tidyselect` (used by `edgelist.data.frame` and `nodelist.data.frame` for column selection)
- **Suggests**: `randomForest`, `tree`, `xgboost`, `gbm`, `rpart`, `testthat`, `covr`, `igraph`, `tidygraph`, `ggraph`, `knitr`, `rmarkdown`

### Data

- `courses` — 13-row data.frame of university courses with prereq/crosslist/dept/credits/level columns. Used in examples and tests. Source: `data-raw/courses.R`.

## Adding a New Model Type

1. Create `R/edgelist.newclass.R` with `edgelist.newclass(input_object, ...)`
2. Optionally create `R/nodelist.newclass.R`
3. Add `S3method(edgelist,newclass)` to `NAMESPACE`
4. Create a man page in `man/edgelist.newclass.Rd`
5. Add tests in `tests/testthat/test-edgelist.R`
6. Use `R/edgelist.randomForest.R` as reference

## Testing

- Framework: testthat 3rd edition
- Test files: `test-edgelist.R` (~165 tests), `test-nodelist.R` (~112 tests), `test-as_igraph.R`
- `test-as_igraph.R` requires the package to be installed (uses `as_igraph` generic); skipped when sourcing manually
- Tests for randomForest/tree use `skip_if_not_installed()`
- The overlap warning in `test-edgelist.R` is expected (tests that `attr_cols` overlap triggers a warning)

## Vignettes

- `vignettes/networkformat.Rmd` — package introduction
- `vignettes/edgelist-nodelist.Rmd` — edgelist/nodelist usage guide
- `vignettes/visualization.Rmd` — ggraph visualization examples

## Dev Request Workflow

Structured system for queuing feature/bug-fix requests. Write a request doc using `dev/prompt-template.md` as a template, drop it in `dev/requests/`, and process it:

- **Interactive**: `/dev-request 001`
- **Headless**: `bash dev/run-request.sh 001`
- **Watch**: `bash dev/watch-requests.sh`

See `dev/requests/README.md` for details.
