# Tests for neural network edgelist/nodelist methods.
# These test the shared internal helpers (.nn_edgelist / .nn_nodelist)
# by constructing mock keras_hdf5 and onnx_model objects directly,
# bypassing the file-reading functions that require hdf5r/reticulate.

# --- Helper: build a fake keras_hdf5 or onnx_model object ---
make_nn <- function(class_name = "keras_hdf5") {
  # Simple network: 3 inputs -> 4 hidden (relu) -> 2 output (softmax)
  set.seed(42)
  kernel1 <- matrix(rnorm(12), nrow = 3, ncol = 4)
  bias1   <- rnorm(4)
  kernel2 <- matrix(rnorm(8),  nrow = 4, ncol = 2)
  bias2   <- rnorm(2)

  structure(
    list(
      layers = list(
        list(name = "dense_1", units = 4L, input_dim = 3L,
             activation = "relu", kernel = kernel1, bias = bias1),
        list(name = "dense_2", units = 2L, input_dim = 4L,
             activation = "softmax", kernel = kernel2, bias = bias2)
      ),
      input_dim = 3L,
      path = "mock.h5"
    ),
    class = class_name
  )
}

# ---- edgelist tests ----

test_that("edgelist returns correct structure for keras_hdf5", {
  model <- make_nn("keras_hdf5")
  edges <- edgelist(model)

  expect_s3_class(edges, "data.frame")
  expect_named(edges, c("from", "to", "weight", "from_layer", "to_layer", "layer_index"))

  # 3*4 + 4*2 = 20 edges total

  expect_equal(nrow(edges), 20L)
})

test_that("edgelist returns correct structure for onnx_model", {
  model <- make_nn("onnx_model")
  edges <- edgelist(model)

  expect_s3_class(edges, "data.frame")
  expect_equal(nrow(edges), 20L)
})

test_that("edgelist layer filter works", {
  model <- make_nn("keras_hdf5")

  edges1 <- edgelist(model, layer = 1)
  expect_equal(nrow(edges1), 12L)  # 3 * 4
  expect_true(all(edges1$layer_index == 1))

  edges2 <- edgelist(model, layer = 2)
  expect_equal(nrow(edges2), 8L)   # 4 * 2
  expect_true(all(edges2$layer_index == 2))
})

test_that("edgelist threshold filter works", {
  model <- make_nn("keras_hdf5")

  edges_all <- edgelist(model, threshold = 0)
  edges_strong <- edgelist(model, threshold = 1.0)

  expect_true(nrow(edges_strong) < nrow(edges_all))
  expect_true(all(abs(edges_strong$weight) >= 1.0))
})

test_that("edgelist node IDs follow L{layer}_N{index} format", {
  model <- make_nn("keras_hdf5")
  edges <- edgelist(model)

  expect_true(all(grepl("^L[0-9]+_N[0-9]+$", edges$from)))
  expect_true(all(grepl("^L[0-9]+_N[0-9]+$", edges$to)))
})

test_that("edgelist invalid layer errors", {
  model <- make_nn("keras_hdf5")
  expect_error(edgelist(model, layer = 0), "layer must be between")
  expect_error(edgelist(model, layer = 3), "layer must be between")
  expect_error(edgelist(model, layer = integer(0)), "layer must not be empty")
  expect_error(nodelist(model, layer = integer(0)), "layer must not be empty")
})

# ---- nodelist tests ----

test_that("nodelist returns correct structure for keras_hdf5", {
  model <- make_nn("keras_hdf5")
  nodes <- nodelist(model)

  expect_s3_class(nodes, "data.frame")
  expect_named(nodes, c("name", "layer_name", "layer_index", "neuron_index",
                         "type", "bias", "activation", "label"))

  # 3 input + 4 hidden + 2 output = 9 neurons
  expect_equal(nrow(nodes), 9L)
})

test_that("nodelist returns correct structure for onnx_model", {
  model <- make_nn("onnx_model")
  nodes <- nodelist(model)
  expect_equal(nrow(nodes), 9L)
})

test_that("nodelist has correct neuron types", {
  model <- make_nn("keras_hdf5")
  nodes <- nodelist(model)

  expect_equal(sum(nodes$type == "input"), 3L)
  expect_equal(sum(nodes$type == "hidden"), 4L)
  expect_equal(sum(nodes$type == "output"), 2L)
})

test_that("nodelist input neurons have NA bias and activation", {
  model <- make_nn("keras_hdf5")
  nodes <- nodelist(model)

  input_nodes <- nodes[nodes$type == "input", ]
  expect_true(all(is.na(input_nodes$bias)))
  expect_true(all(is.na(input_nodes$activation)))
})

test_that("nodelist hidden/output neurons have bias values", {
  model <- make_nn("keras_hdf5")
  nodes <- nodelist(model)

  non_input <- nodes[nodes$type != "input", ]
  expect_true(all(!is.na(non_input$bias)))
})

test_that("nodelist layer filter works", {
  model <- make_nn("keras_hdf5")

  # Layer 0 = input only
  nodes0 <- nodelist(model, layer = 0)
  expect_equal(nrow(nodes0), 3L)
  expect_true(all(nodes0$type == "input"))

  # Layer 1 = hidden
  nodes1 <- nodelist(model, layer = 1)
  expect_equal(nrow(nodes1), 4L)

  # Layer 2 = output
  nodes2 <- nodelist(model, layer = 2)
  expect_equal(nrow(nodes2), 2L)
  expect_true(all(nodes2$type == "output"))
})

test_that("nodelist activations are correct", {
  model <- make_nn("keras_hdf5")
  nodes <- nodelist(model)

  hidden <- nodes[nodes$layer_name == "dense_1", ]
  expect_true(all(hidden$activation == "relu"))

  output <- nodes[nodes$layer_name == "dense_2", ]
  expect_true(all(output$activation == "softmax"))
})

# ---- Node ID consistency between edgelist and nodelist ----

test_that("edgelist from/to IDs are a subset of nodelist names", {
  model <- make_nn("keras_hdf5")
  edges <- edgelist(model)
  nodes <- nodelist(model)

  all_edge_ids <- unique(c(edges$from, edges$to))
  expect_true(all(all_edge_ids %in% nodes$name))
})

# ---- print methods ----

test_that("print.keras_hdf5 runs without error", {
  model <- make_nn("keras_hdf5")
  expect_output(print(model), "Keras HDF5 model")
  expect_output(print(model), "dense_1")
})

test_that("print.onnx_model runs without error", {
  model <- make_nn("onnx_model")
  expect_output(print(model), "ONNX model")
})

# ---- Weights are faithfully represented ----

test_that("edgelist weights match kernel matrix values", {
  model <- make_nn("keras_hdf5")
  edges <- edgelist(model, layer = 1)

  kernel <- model$layers[[1]]$kernel
  # The kernel is [3, 4]. Column-major vectorization means
  # from_idx cycles 1..3 for each to_idx 1..4
  expect_equal(edges$weight, as.vector(kernel))
})

# ---- as.igraph / as_tbl_graph tests ----

test_that("as.igraph works for keras_hdf5", {
  skip_if_not_installed("igraph")
  model <- make_nn("keras_hdf5")

  g <- igraph::as.igraph(model)
  expect_s3_class(g, "igraph")
  expect_equal(igraph::vcount(g), 9L)   # 3 + 4 + 2
  expect_equal(igraph::ecount(g), 20L)  # 12 + 8
})

test_that("as.igraph with layer filter includes source neurons", {
  skip_if_not_installed("igraph")
  model <- make_nn("keras_hdf5")

  # Layer 1 edges connect L0 (input) -> L1 (hidden)
  g <- igraph::as.igraph(model, layer = 1)
  vnames <- igraph::V(g)$name
  expect_true(any(grepl("^L0_N", vnames)))  # source layer included
  expect_true(any(grepl("^L1_N", vnames)))  # target layer included
})

test_that("as.igraph works for onnx_model", {
  skip_if_not_installed("igraph")
  model <- make_nn("onnx_model")

  g <- igraph::as.igraph(model)
  expect_s3_class(g, "igraph")
  expect_equal(igraph::vcount(g), 9L)
})

test_that("as_tbl_graph works for keras_hdf5", {
  skip_if_not_installed("igraph")
  skip_if_not_installed("tidygraph")
  model <- make_nn("keras_hdf5")

  tg <- tidygraph::as_tbl_graph(model)
  expect_s3_class(tg, "tbl_graph")
})

test_that("as_tbl_graph works for onnx_model", {
  skip_if_not_installed("igraph")
  skip_if_not_installed("tidygraph")
  model <- make_nn("onnx_model")

  tg <- tidygraph::as_tbl_graph(model)
  expect_s3_class(tg, "tbl_graph")
})
