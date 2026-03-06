#' Read a Keras HDF5 Model File
#'
#' Reads a Keras \code{.h5} model file and returns a structured
#' representation of the neural network's architecture and learned
#' parameters (weights and biases).  The returned object can be passed
#' to \code{\link{edgelist}} and \code{\link{nodelist}} to extract
#' neuron-level connectivity.
#'
#' @param path Path to a Keras HDF5 (\code{.h5}) model file.
#'
#' @returns An object of class \code{"keras_hdf5"} containing:
#'   \describe{
#'     \item{layers}{A list of layer descriptions, each with fields
#'       \code{name}, \code{units}, \code{activation}, \code{kernel}
#'       (weight matrix), and \code{bias} (bias vector).}
#'     \item{input_dim}{Integer dimension of the input layer.}
#'     \item{path}{The file path used.}
#'   }
#'
#' @details
#' Only Dense (fully connected) layers with kernel/bias weights are
#' extracted.  Layers without weights (e.g.\ Dropout, BatchNorm) are
#' skipped.  The function requires the \pkg{hdf5r} package and
#' optionally \pkg{jsonlite} (for parsing model config).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_keras_hdf5("my_model.h5")
#' edgelist(model)
#' nodelist(model)
#' }
read_keras_hdf5 <- function(path) {
  if (!requireNamespace("hdf5r", quietly = TRUE)) {
    stop("Package 'hdf5r' is required. Install it with install.packages('hdf5r').")
  }
  if (!file.exists(path)) {
    stop("File not found: ", path)
  }

  h5 <- hdf5r::H5File$new(path, mode = "r")
  on.exit(h5$close_all(), add = TRUE)

  # Determine weight group: Keras 2 uses "model_weights", Keras 1 uses root
  if (h5$exists("model_weights")) {
    weight_group <- h5[["model_weights"]]
  } else {
    weight_group <- h5
  }

  # Try to parse model config for activation functions
  activations <- list()
  if (h5$attr_exists("model_config")) {
    config_json <- h5$attr_open("model_config")$read()
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      config <- jsonlite::fromJSON(config_json, simplifyVector = FALSE)
      cfg <- config$config %||% config
      layer_cfgs <- cfg$layers %||% list()
      for (lc in layer_cfgs) {
        lconf <- lc$config %||% list()
        if (!is.null(lconf$name) && !is.null(lconf$activation)) {
          activations[[lconf$name]] <- lconf$activation
        }
      }
    }
  }

  # Extract Dense layers with kernel and bias
  layer_names <- weight_group$names
  layers <- list()

  for (lname in layer_names) {
    layer_grp <- weight_group[[lname]]
    if (!inherits(layer_grp, "H5Group")) next

    # Keras stores weights under <layer_name>/<layer_name>/kernel:0
    # or directly under <layer_name>/kernel:0
    kernel <- NULL
    bias <- NULL

    kernel <- .h5_find_dataset(layer_grp, "kernel")
    bias   <- .h5_find_dataset(layer_grp, "bias")

    if (is.null(kernel)) next

    # HDF5 stores in row-major (C) order; R reads column-major, so the
    # Keras kernel shape [in_features, out_features] appears transposed.
    kernel_mat <- t(kernel$read())
    bias_vec   <- if (!is.null(bias)) bias$read() else rep(0, ncol(kernel_mat))

    layers[[length(layers) + 1L]] <- list(
      name       = lname,
      units      = ncol(kernel_mat),
      input_dim  = nrow(kernel_mat),
      activation = activations[[lname]] %||% "unknown",
      kernel     = kernel_mat,
      bias       = bias_vec
    )
  }

  if (length(layers) == 0L) {
    stop("No Dense layers with kernel weights found in ", path)
  }

  input_dim <- layers[[1L]]$input_dim

  structure(
    list(layers = layers, input_dim = input_dim, path = path),
    class = "keras_hdf5"
  )
}

#' Read an ONNX Model File
#'
#' Reads an ONNX (\code{.onnx}) model file and returns a structured
#' representation of the neural network's layers and learned
#' parameters.  The returned object can be passed to
#' \code{\link{edgelist}} and \code{\link{nodelist}}.
#'
#' @param path Path to an ONNX (\code{.onnx}) model file.
#'
#' @returns An object of class \code{"onnx_model"} containing:
#'   \describe{
#'     \item{layers}{A list of layer descriptions (same structure as
#'       \code{\link{read_keras_hdf5}}).}
#'     \item{input_dim}{Integer dimension of the input layer.}
#'     \item{path}{The file path used.}
#'   }
#'
#' @details
#' Requires the \pkg{reticulate} package and a Python environment with
#' the \code{onnx} and \code{numpy} packages installed.  Only
#' matrix-multiply (Gemm/MatMul) operations with associated weight
#' initializers are extracted as Dense layers.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_onnx("my_model.onnx")
#' edgelist(model)
#' nodelist(model)
#' }
read_onnx <- function(path) {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("Package 'reticulate' is required. Install it with install.packages('reticulate').")
  }
  if (!file.exists(path)) {
    stop("File not found: ", path)
  }

  # Parse the ONNX graph entirely in Python to avoid protobuf

  # RepeatedCompositeContainer iteration issues in reticulate.
  py_code <- sprintf('
import onnx
from onnx import numpy_helper

_model = onnx.load(%s)
_graph = _model.graph

# Collect initializers as numpy arrays
_inits = {}
for init in _graph.initializer:
    _inits[init.name] = numpy_helper.to_array(init)

# Walk nodes and extract Dense (Gemm/MatMul) layers
_layers = []
_nodes = list(_graph.node)
for i, node in enumerate(_nodes):
    if node.op_type not in ("Gemm", "MatMul"):
        continue

    # Find weight tensor (2-D initializer)
    kernel = None
    for inp in node.input:
        if inp in _inits and _inits[inp].ndim == 2:
            kernel = _inits[inp].copy()
            break
    if kernel is None:
        continue

    # Gemm transB=1: transpose kernel
    if node.op_type == "Gemm":
        for attr in node.attribute:
            if attr.name == "transB" and attr.i == 1:
                kernel = kernel.T
                break

    # Bias: Gemm 3rd input, or subsequent Add node
    bias = None
    if node.op_type == "Gemm" and len(node.input) >= 3:
        bname = node.input[2]
        if bname in _inits:
            bias = _inits[bname].flatten()
    if bias is None and i + 1 < len(_nodes):
        nxt = _nodes[i + 1]
        if nxt.op_type == "Add":
            for inp in nxt.input:
                if inp in _inits and _inits[inp].ndim <= 1:
                    bias = _inits[inp].flatten()
                    break
    if bias is None:
        import numpy as np
        bias = np.zeros(kernel.shape[1])

    # Activation from following node
    activation = "linear"
    check_idx = i + 1 if node.op_type == "Gemm" else i + 2
    if check_idx < len(_nodes):
        act_op = _nodes[check_idx].op_type.lower()
        if act_op in ("relu", "sigmoid", "tanh", "softmax", "leakyrelu"):
            activation = act_op

    name = node.name if node.name else "dense_" + str(len(_layers) + 1)
    _layers.append({
        "name": name,
        "units": int(kernel.shape[1]),
        "input_dim": int(kernel.shape[0]),
        "activation": activation,
        "kernel": kernel,
        "bias": bias,
    })
', deparse(normalizePath(path)))

  reticulate::py_run_string(py_code)
  py_layers <- reticulate::py_eval("_layers")

  if (length(py_layers) == 0L) {
    stop("No Dense (Gemm/MatMul) layers found in ", path)
  }

  layers <- lapply(py_layers, function(pl) {
    list(
      name       = pl$name,
      units      = as.integer(pl$units),
      input_dim  = as.integer(pl$input_dim),
      activation = pl$activation,
      kernel     = as.matrix(pl$kernel),
      bias       = as.vector(pl$bias)
    )
  })

  input_dim <- layers[[1L]]$input_dim

  structure(
    list(layers = layers, input_dim = input_dim, path = path),
    class = "onnx_model"
  )
}

#' @export
print.keras_hdf5 <- function(x, ...) {
  n_layers <- length(x$layers)
  n_params <- sum(vapply(x$layers, function(l) {
    length(l$kernel) + length(l$bias)
  }, numeric(1)))
  cat(sprintf("Keras HDF5 model: %d dense layer(s), %s parameters\n",
              n_layers, format(n_params, big.mark = ",")))
  cat(sprintf("  Input dimension: %d\n", x$input_dim))
  for (i in seq_along(x$layers)) {
    l <- x$layers[[i]]
    cat(sprintf("  [%d] %s: %d -> %d (%s)\n",
                i, l$name, l$input_dim, l$units, l$activation))
  }
  invisible(x)
}

#' @export
print.onnx_model <- function(x, ...) {
  n_layers <- length(x$layers)
  n_params <- sum(vapply(x$layers, function(l) {
    length(l$kernel) + length(l$bias)
  }, numeric(1)))
  cat(sprintf("ONNX model: %d dense layer(s), %s parameters\n",
              n_layers, format(n_params, big.mark = ",")))
  cat(sprintf("  Input dimension: %d\n", x$input_dim))
  for (i in seq_along(x$layers)) {
    l <- x$layers[[i]]
    cat(sprintf("  [%d] %s: %d -> %d (%s)\n",
                i, l$name, l$input_dim, l$units, l$activation))
  }
  invisible(x)
}

# Internal: recursively search an HDF5 group for a dataset matching a name
.h5_find_dataset <- function(group, name) {
  for (n in group$names) {
    obj <- group[[n]]
    if (inherits(obj, "H5D") && grepl(name, n, fixed = TRUE)) {
      return(obj)
    }
    if (inherits(obj, "H5Group")) {
      result <- .h5_find_dataset(obj, name)
      if (!is.null(result)) return(result)
    }
  }
  NULL
}
