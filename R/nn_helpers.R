# Internal helpers shared by keras_hdf5 and onnx_model methods.
# Not exported.

# Build an edgelist from a list of Dense layer descriptions.
# Each layer must have: name, units, input_dim, kernel (matrix).
.nn_edgelist <- function(layers, input_dim, layer = NULL, threshold = 0) {
  n_layers <- length(layers)
  if (!is.null(layer)) {
    layer <- as.integer(layer)
    if (length(layer) == 0L) stop("layer must not be empty")
    if (any(layer < 1L | layer > n_layers)) {
      stop("layer must be between 1 and ", n_layers)
    }
  } else {
    layer <- seq_len(n_layers)
  }

  # Build layer name lookup: index 0 = input, 1..n = Dense layers
  layer_names <- c("input", vapply(layers, `[[`, character(1), "name"))

  edge_blocks <- vector("list", length(layer))
  bi <- 0L

  for (li in layer) {
    bi <- bi + 1L
    l <- layers[[li]]
    kernel <- l$kernel  # matrix: [in_features, out_features]
    n_in  <- nrow(kernel)
    n_out <- ncol(kernel)

    # Source layer index: layer before this one
    src_layer_idx <- li - 1L
    # Target layer index: this layer
    tgt_layer_idx <- li

    # Create all n_in * n_out edges
    from_idx <- rep(seq_len(n_in), times = n_out)
    to_idx   <- rep(seq_len(n_out), each = n_in)
    w        <- as.vector(kernel)  # column-major: cycles from_idx within each to_idx

    # Apply threshold filter
    keep <- abs(w) >= threshold
    if (!all(keep)) {
      from_idx <- from_idx[keep]
      to_idx   <- to_idx[keep]
      w        <- w[keep]
    }

    edge_blocks[[bi]] <- data.frame(
      from        = paste0("L", src_layer_idx, "_N", from_idx),
      to          = paste0("L", tgt_layer_idx, "_N", to_idx),
      weight      = w,
      from_layer  = layer_names[src_layer_idx + 1L],
      to_layer    = layer_names[tgt_layer_idx + 1L],
      layer_index = tgt_layer_idx,
      stringsAsFactors = FALSE
    )
  }

  result <- do.call(rbind, edge_blocks)
  rownames(result) <- NULL
  result
}

# Build a nodelist from a list of Dense layer descriptions.
.nn_nodelist <- function(layers, input_dim, layer = NULL) {
  n_layers <- length(layers)

  # Determine which layers to include (0 = input layer)
  if (!is.null(layer)) {
    layer <- as.integer(layer)
    if (length(layer) == 0L) stop("layer must not be empty")
    if (any(layer < 0L | layer > n_layers)) {
      stop("layer must be between 0 and ", n_layers)
    }
    include_layers <- layer
  } else {
    include_layers <- 0L:n_layers
  }

  node_blocks <- vector("list", length(include_layers))
  bi <- 0L

  for (li in include_layers) {
    bi <- bi + 1L

    if (li == 0L) {
      # Input layer
      node_blocks[[bi]] <- data.frame(
        name         = paste0("L0_N", seq_len(input_dim)),
        layer_name   = "input",
        layer_index  = 0L,
        neuron_index = seq_len(input_dim),
        type         = "input",
        bias         = NA_real_,
        activation   = NA_character_,
        label        = paste0("input_", seq_len(input_dim)),
        stringsAsFactors = FALSE
      )
    } else {
      l <- layers[[li]]
      n_units <- l$units
      is_output <- (li == n_layers)

      node_blocks[[bi]] <- data.frame(
        name         = paste0("L", li, "_N", seq_len(n_units)),
        layer_name   = l$name,
        layer_index  = li,
        neuron_index = seq_len(n_units),
        type         = if (is_output) "output" else "hidden",
        bias         = l$bias,
        activation   = l$activation,
        label        = paste0(l$name, "_", seq_len(n_units)),
        stringsAsFactors = FALSE
      )
    }
  }

  result <- do.call(rbind, node_blocks)
  rownames(result) <- NULL
  result
}
