#' Extract Node List from an ONNX Neural Network
#'
#' Returns one row per neuron from an \code{onnx_model}, with layer
#' membership, bias values, and activation functions.  Node IDs match
#' the \code{from}/\code{to} columns of
#' \code{\link{edgelist.onnx_model}}.
#'
#' @param input_object An \code{"onnx_model"} object from
#'   \code{\link{read_onnx}}.
#' @param layer Integer vector of layer indices to include (default
#'   \code{NULL} = all layers).
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with the same columns as
#'   \code{\link{nodelist.keras_hdf5}}: \code{name},
#'   \code{layer_name}, \code{layer_index}, \code{neuron_index},
#'   \code{type}, \code{bias}, \code{activation}, \code{label}.
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_onnx("my_model.onnx")
#' nodes <- nodelist(model)
#' head(nodes)
#' }
nodelist.onnx_model <- function(input_object, layer = NULL, ...) {
  .nn_nodelist(input_object$layers, input_object$input_dim, layer = layer)
}
