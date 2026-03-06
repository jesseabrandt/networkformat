#' Extract Edgelist from a Keras HDF5 Neural Network
#'
#' Converts a \code{keras_hdf5} model (read by
#' \code{\link{read_keras_hdf5}}) into an edgelist where each row
#' represents a weighted connection between two neurons.
#'
#' @param input_object A \code{"keras_hdf5"} object from
#'   \code{\link{read_keras_hdf5}}.
#' @param layer Integer vector of layer indices to include (default
#'   \code{NULL} = all layers).  Layer 1 is the first Dense layer.
#' @param threshold Numeric; only include edges with
#'   \code{abs(weight) >= threshold} (default \code{0}, keeps all).
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with columns:
#'   \describe{
#'     \item{from}{Source neuron ID (format
#'       \code{"L\{layer_index\}_N\{neuron_index\}"})}
#'     \item{to}{Target neuron ID}
#'     \item{weight}{Learned weight value for this connection}
#'     \item{from_layer}{Source layer name}
#'     \item{to_layer}{Target layer name}
#'     \item{layer_index}{Integer index of the target (receiving)
#'       layer}
#'   }
#' @export
#'
#' @examples
#' \dontrun{
#' model <- read_keras_hdf5("my_model.h5")
#' edges <- edgelist(model)
#' head(edges)
#'
#' # Only strong connections
#' edges_strong <- edgelist(model, threshold = 0.1)
#' }
edgelist.keras_hdf5 <- function(input_object, layer = NULL, threshold = 0, ...) {
  .nn_edgelist(input_object$layers, input_object$input_dim,
               layer = layer, threshold = threshold)
}
