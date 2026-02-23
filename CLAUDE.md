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

The package uses **S3 method dispatch** with two generic functions that dispatch on the class of `input_object`:

### `edgelist()` — extract parent-child relationships as edgelists

| Method | Input Class | Output Columns | Status |
|--------|-------------|---------------|--------|
| `edgelist.randomForest` | randomForest | source, target, split_var, split_point, prediction, treenum, split_var_name | Complete |
| `edgelist.tree` | tree | from, to, label | Complete |
| `edgelist.data.frame` | data.frame | source, target, source_col, target_col, \<attr_cols\> | Complete |
| `edgelist.xgb.Booster` | xgb.Booster | — | Stub (not implemented) |
| `edgelist.default` | any other | — | Fallback error message |

### `nodelist()` — extract node attributes

| Method | Input Class | Output Columns | Status |
|--------|-------------|---------------|--------|
| `nodelist.data.frame` | data.frame | (reordered input, id_col first) | Complete |
| `nodelist.tree` | tree | node, var, n, dev, yval, is_leaf | Complete |
| `nodelist.randomForest` | randomForest | node, is_leaf, split_var, split_var_name, split_point, prediction, treenum | Complete |
| `nodelist.gbm` | gbm | — | Stub (not implemented) |
| `nodelist.xgb.Booster` | xgb.Booster | — | Stub (not implemented) |

Node IDs in nodelist outputs match the from/to (tree) or source/target (randomForest) columns in the corresponding edgelist, so the two can be passed directly to `igraph::graph_from_data_frame()`.

### File organization

Each S3 method lives in its own file: `R/edgelist.R` (generic), `R/edgelist.data.frame.R`, `R/edgelist.randomForest.R`, `R/edgelist.tree.R`, `R/nodelist.R` (generic), `R/nodelist.data.frame.R`, `R/nodelist.tree.R`, `R/nodelist.randomForest.R`, etc.

### Key algorithms

- **randomForest**: Iterates trees via `randomForest::getTree()`, identifies parent nodes (left_daughter != 0), creates edges to both children. Returns all trees with `treenum` identifier.
- **tree**: Uses a parent-stack approach to reconstruct the binary tree traversal, tracking parent indices and children counts. Generates human-readable split labels.

## Adding a New Model Type

1. Create `R/edgelist.newclass.R` with `edgelist.newclass(input_object, ...)`
2. Add roxygen2 `@export` tag
3. Run `devtools::document()` to update NAMESPACE
4. Add tests in `tests/testthat/test-edgelist.R`
5. Use `R/edgelist.randomForest.R` as reference

## Testing

- Framework: testthat 3rd edition
- Test files: `tests/testthat/test-edgelist.R`, `tests/testthat/test-nodelist.R` (97 tests total)
- Tests require `randomForest` and `tree` packages (listed in Suggests)
- Documentation is roxygen2-generated — never edit `man/*.Rd` or `NAMESPACE` by hand
