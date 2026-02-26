#' Default Edge Extraction Method
#'
#' Default method that is called when no specific method is implemented for
#' the input object type. Raises an error with the supported class list.
#'
#' @param input_object An object for which no specific edgelist method exists
#' @param ... Additional arguments (currently unused)
#'
#' @returns Never returns; always raises an error.
#' @export
#'
#' @examples
#' # Attempting to extract edgelist from unsupported object type
#' try(edgelist(list(a = 1, b = 2)))
edgelist.default <- function(input_object, ...){
  stop("edgelist() does not support objects of class '",
       paste(class(input_object), collapse = "', '"),
       "'. Supported classes: data.frame, randomForest, tree.")
}
