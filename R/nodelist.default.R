#' Default Node List Extraction Method
#'
#' Default method that is called when no specific method is implemented for
#' the input object type. Raises an error with the supported class list.
#'
#' @param input_object An object for which no specific nodelist method exists
#' @param ... Additional arguments (currently unused)
#'
#' @returns Never returns; always raises an error.
#' @export
#'
#' @examples
#' # Attempting to extract nodelist from unsupported object type
#' try(nodelist(list(a = 1, b = 2)))
nodelist.default <- function(input_object, ...){
  stop("nodelist() does not support objects of class '",
       paste(class(input_object), collapse = "', '"),
       "'. Supported classes: data.frame, randomForest, tree.")
}
