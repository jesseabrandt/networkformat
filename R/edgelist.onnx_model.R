#' Extract Edgelist from an ONNX Neural Network
#'
#' Converts an \code{onnx_model} (read by \code{\link{read_onnx}})
#' into an edgelist where each row represents a weighted connection
#' between two neurons.
#'
#' @param input_object An \code{"onnx_model"} object from
#'   \code{\link{read_onnx}}.
#' @param layer Integer vector of layer indices to include (default
#'   \code{NULL} = all layers).
#' @param threshold Numeric; only include edges with
#'   \code{abs(weight) >= threshold} (default \code{0}, keeps all).
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with the same columns as
#'   \code{\link{edgelist.keras_hdf5}}: \code{from}, \code{to},
#'   \code{weight}, \code{from_layer}, \code{to_layer},
#'   \code{layer_index}.
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_onnx("my_model.onnx")
#' edges <- edgelist(model)
#' head(edges)
#' }
edgelist.onnx_model <- function(input_object, layer = NULL, threshold = 0, ...) {
  .nn_edgelist(input_object$layers, input_object$input_dim,
               layer = layer, threshold = threshold)
}
