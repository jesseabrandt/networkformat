#' Default Edge Extraction Method
#'
#' Default method that is called when no specific method is implemented for
#' the input object type. Prints an informative message to the user.
#'
#' @param input_object An object for which no specific edgelist method exists
#' @param ... Additional arguments (currently unused)
#'
#' @returns NULL (invisibly). Prints a message to console.
#' @export
#'
#' @examples
#' # Attempting to extract edgelist from unsupported object type
#' edgelist(list(a = 1, b = 2))
edgelist.default <- function(input_object, ...){
  message("edgelist() method not implemented for object of class: ",
          paste(class(input_object), collapse = ", "))
  invisible(NULL)
}
