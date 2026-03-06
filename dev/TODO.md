# TODO — feature/neural-network-onnx-hdf5 branch

## Needs review

### Neural network support (ONNX / Keras HDF5)
- [ ] `read_keras_hdf5()` and `read_onnx()` in `R/read_nn.R`
- [ ] Shared helpers in `R/nn_helpers.R` (`.nn_edgelist()`, `.nn_nodelist()`)
- [ ] `edgelist.keras_hdf5` / `edgelist.onnx_model`
- [ ] `nodelist.keras_hdf5` / `nodelist.onnx_model`
- [ ] `as.igraph` / `as_tbl_graph` methods for both classes
- [ ] Example model files in `inst/extdata/` (iris_nn.h5, iris_nn.onnx)
- [ ] 37 tests in `test-nn.R` (mock objects, no hdf5r/reticulate needed)
- [ ] ONNX parser does all protobuf iteration in Python via `py_run_string()` (reticulate can't iterate `RepeatedCompositeContainer`)
- [ ] HDF5 reader transposes kernel after read (row-major → column-major)
- [ ] `hdf5r`, `reticulate`, `jsonlite` added to Suggests

### data.frame method improvements
- [ ] `nodelist.data.frame`: `attr_cols` parameter for column selection
- [ ] `nodelist.data.frame`: `unique` parameter to deduplicate on id_col
- [ ] `nodelist.data.frame`: docs clarify it's a thin wrapper for pipeline consistency
- [ ] `edgelist.data.frame`: factor → character coercion on from/to columns
- [ ] `nodes_from_edges()` utility — decide if worth keeping (own commit, easy to revert)

## Not yet done

- [ ] Man pages — need `devtools::document()` (roxygen2 not in this container)
- [ ] Update CLAUDE.md architecture tables with new methods
- [ ] Vignette or article for neural network visualization workflow
- [ ] README.Rmd example for neural network usage
- [ ] CI: add hdf5r/reticulate to GitHub Actions workflow (or skip gracefully)
- [ ] Integration tests for `read_keras_hdf5()` / `read_onnx()` against real files (currently only tested manually)
- [ ] Consider: `layer` parameter on `nodelist` for NN — when filtering edges by layer, the nodelist should include nodes from the adjacent input layer too (currently includes only requested layer indices)

## Decided against (for now)
- Suppress `from_col`/`to_col` toggle — adds parameter clutter for minor convenience
- Self-loop filter — too niche, users can filter after
- Bipartite pair control in Cartesian product — bind two calls instead
- Weight normalization — out of scope for a format-conversion package
