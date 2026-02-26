#' Extract Node List from Various Objects
#'
#' Generic function to extract a node list (with attributes) from various
#' object types including data.frames and tree models. The node list provides
#' metadata about each node in the network.
#'
#' @param input_object An object containing node information (data.frame, tree model, etc.)
#' @param ... Additional arguments passed to specific methods
#'
#' @returns A data.frame where the first column is the node ID and subsequent
#'   columns contain node attributes
#' @export
#'
#' @examples
#' # Node list with course as ID (column 2)
#' nodelist(courses, id_col = 2)
nodelist <- function(input_object, ...){UseMethod("nodelist")}
