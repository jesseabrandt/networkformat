# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Package Does

**networkformat** is an R package that converts machine learning tree models (randomForest, tree, xgboost) into network edgelist format for visualization and analysis with igraph/tidygraph/ggraph. Version 0.0.0.9000 (experimental).

## Development Commands

```r
# Load package for interactive development
devtools::load_all()

# Run all tests
devtools::test()
# Or from terminal: Rscript -e 'testthat::test_dir("tests/testthat")'

# Run a single test file
testthat::test_file("tests/testthat/test-edgelist.R")

# Regenerate documentation (man/ pages and NAMESPACE) after changing roxygen2 comments
devtools::document()

# Full package check
devtools::check()
# Or from terminal: R CMD check .

# Build the package
R CMD build .
```

## Architecture

The package uses **S3 method dispatch** with three groups of generic functions:

### `edgelist()` — extract parent-child relationships as edgelists

| Method | Input Class | Parameters | Output Columns | Status |
|--------|-------------|-----------|---------------|--------|
| `edgelist.randomForest` | randomForest | `treenum` | source, target, split_var, split_point, prediction, treenum, split_var_name | Complete |
| `edgelist.tree` | tree | | from, to, label, split_var, split_op, split_point | Complete |
| `edgelist.data.frame` | data.frame | `source_cols`, `target_cols`, `attr_cols`, `na.rm`, `symmetric_cols` | source, target, source_col, target_col, [directed], \<attr_cols\> | Complete |
| `edgelist.xgb.Booster` | xgb.Booster | | — | Stub (not implemented) |
| `edgelist.default` | any other | | — | Fallback error message |

### `nodelist()` — extract node attributes

| Method | Input Class | Parameters | Output Columns | Status |
|--------|-------------|-----------|---------------|--------|
| `nodelist.data.frame` | data.frame | `id_col` | (reordered input, id_col first) | Complete |
| `nodelist.tree` | tree | | node, var, n, dev, yval, is_leaf, label | Complete |
| `nodelist.randomForest` | randomForest | `treenum` | node, is_leaf, split_var, split_var_name, split_point, prediction, treenum, label | Complete |
| `nodelist.gbm` | gbm | | — | Stub (not implemented) |
| `nodelist.xgb.Booster` | xgb.Booster | | — | Stub (not implemented) |

### `as_igraph()` / `as_tbl_graph()` — direct graph construction

| Method | Input Class | Parameters | Returns |
|--------|-------------|-----------|---------|
| `as_igraph.tree` | tree | | single igraph |
| `as_igraph.randomForest` | randomForest | `treenum` (default 1) | single igraph (multiple trees → disconnected components) |
| `as_tbl_graph.tree` | tree | | single tbl_graph |
| `as_tbl_graph.randomForest` | randomForest | `treenum` (default 1) | single tbl_graph |

Node IDs in nodelist outputs match the from/to (tree) or source/target (randomForest) columns in the corresponding edgelist, so the two can be passed directly to `igraph::graph_from_data_frame()`.

### File organization

Each S3 method lives in its own file: `R/edgelist.R` (generic), `R/edgelist.data.frame.R`, `R/edgelist.randomForest.R`, `R/edgelist.tree.R`, `R/nodelist.R` (generic), `R/nodelist.data.frame.R`, `R/nodelist.tree.R`, `R/nodelist.randomForest.R`, `R/as_igraph.R`, `R/as_tbl_graph.R`, etc.

### Key algorithms

- **randomForest**: Iterates trees via `randomForest::getTree()`, identifies parent nodes (left_daughter != 0), creates edges to both children. `treenum` arg filters to specific trees.
- **tree**: Uses a parent-stack approach to reconstruct the binary tree traversal, tracking parent indices and children counts. Generates human-readable split labels and parsed split components.
- **data.frame**: Iterates source/target column pairs (Cartesian product), builds edge blocks with `na.rm` filtering and optional `directed` column from `symmetric_cols`.

## Adding a New Model Type

1. Create `R/edgelist.newclass.R` with `edgelist.newclass(input_object, ...)`
2. Add roxygen2 `@export` tag
3. Run `devtools::document()` to update NAMESPACE
4. Add tests in `tests/testthat/test-edgelist.R`
5. Use `R/edgelist.randomForest.R` as reference

## Testing

- Framework: testthat 3rd edition
- Test files: `tests/testthat/test-edgelist.R`, `tests/testthat/test-nodelist.R`, `tests/testthat/test-as_igraph.R`
- Tests require `randomForest` and `tree` packages (listed in Suggests)
- `as_igraph`/`as_tbl_graph` tests also require `igraph` and `tidygraph`
- Documentation is roxygen2-generated — never edit `man/*.Rd` or `NAMESPACE` by hand

## Dev Request Workflow

Structured system for queuing and processing feature/bug-fix requests. Write a request doc using `dev/prompt-template.md` as a template, drop it in `dev/requests/`, and process it in one of three modes:

- **Interactive**: `/dev-request 001` — runs inside a Claude Code session with full tool access
- **Headless**: `bash dev/run-request.sh 001` — pipes to `claude -p`, no interactive session needed
- **Watch**: `bash dev/watch-requests.sh` — polls `dev/requests/` and auto-processes new pending files

Each mode runs the same quality gate: tests, NAMESPACE regeneration, and R CMD check. See `dev/requests/README.md` for full details on writing requests, naming conventions, and the pending/in-progress/done lifecycle.
