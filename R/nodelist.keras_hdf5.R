#' Extract Node List from a Keras HDF5 Neural Network
#'
#' Returns one row per neuron from a \code{keras_hdf5} model, with
#' layer membership, bias values, and activation functions.  Node IDs
#' match the \code{from}/\code{to} columns of
#' \code{\link{edgelist.keras_hdf5}}.
#'
#' @param input_object A \code{"keras_hdf5"} object from
#'   \code{\link{read_keras_hdf5}}.
#' @param layer Integer vector of layer indices to include (default
#'   \code{NULL} = all layers, including the input layer at index 0).
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with columns:
#'   \describe{
#'     \item{name}{Neuron ID (\code{"L\{layer\}_N\{index\}"})}
#'     \item{layer_name}{Name of the layer}
#'     \item{layer_index}{Integer layer position (0 = input)}
#'     \item{neuron_index}{Position within the layer (1-based)}
#'     \item{type}{\code{"input"}, \code{"hidden"}, or
#'       \code{"output"}}
#'     \item{bias}{Bias value (\code{NA} for input neurons)}
#'     \item{activation}{Activation function name (\code{NA} for input
#'       neurons)}
#'     \item{label}{Display label: layer name and neuron index}
#'   }
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_keras_hdf5("my_model.h5")
#' nodes <- nodelist(model)
#' head(nodes)
#' }
nodelist.keras_hdf5 <- function(input_object, layer = NULL, ...) {
  .nn_nodelist(input_object$layers, input_object$input_dim, layer = layer)
}
