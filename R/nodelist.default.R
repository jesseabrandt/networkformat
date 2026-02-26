#' Extract Node List from a Vector or Unsupported Object
#'
#' When called on an atomic vector (character, numeric, integer, logical,
#' factor), returns the unique values as a node list with a \code{name}
#' column (preserving order of first appearance) and an \code{n} column
#' giving the frequency of each value.  For all other unsupported types,
#' an informative error is raised.
#'
#' @param input_object An atomic vector, or an object for which no specific
#'   nodelist method exists.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with columns \code{name} (unique values in order of
#'   first appearance) and \code{n} (frequency count).  For unsupported types,
#'   an error is raised.
#' @export
#'
#' @examples
#' # Character vector
#' nodelist(c("A", "B", "C", "A", "B"))
#'
#' # Numeric vector
#' nodelist(c(1, 2, 3, 2, 1))
#'
#' # Unsupported type
#' try(nodelist(list(a = 1, b = 2)))
nodelist.default <- function(input_object, ...) {
  if (is.atomic(input_object) && is.null(dim(input_object))) {
    n <- length(input_object)
    if (n == 0L) {
      return(data.frame(name = input_object[0], n = integer(0),
                        stringsAsFactors = FALSE))
    }

    # Unique values in order of first appearance
    unique_vals <- unique(input_object)
    counts <- as.integer(tabulate(match(input_object, unique_vals)))

    return(data.frame(name = unique_vals, n = counts,
                      stringsAsFactors = FALSE))
  }

  stop("nodelist() does not support objects of class '",
       paste(class(input_object), collapse = "', '"),
       "'. Supported classes: vector, data.frame, randomForest, tree.")
}
