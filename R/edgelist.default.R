#' Extract Edgelist from a Vector or Unsupported Object
#'
#' When called on an atomic vector (character, numeric, integer, logical,
#' factor), creates a sequential edgelist connecting each element to the next:
#' element \code{i} is connected to element \code{i + 1}.  For all other
#' unsupported types, an informative error is raised.
#'
#' @param input_object An atomic vector, or an object for which no specific
#'   edgelist method exists.
#' @param weights Logical; if \code{TRUE}, duplicate edges are collapsed and a
#'   \code{weight} column is added with the count of each unique
#'   \code{(from, to)} pair.  Defaults to \code{FALSE}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with columns \code{from} and \code{to} (and
#'   \code{weight} when \code{weights = TRUE}).  For unsupported types, an
#'   error is raised.
#' @export
#'
#' @examples
#' # Character vector
#' edgelist(c("A", "B", "C", "D"))
#'
#' # Numeric vector
#' edgelist(1:5)
#'
#' # With duplicate counting
#' edgelist(c("A", "B", "A", "B", "C"), weights = TRUE)
#'
#' # Unsupported type
#' try(edgelist(list(a = 1, b = 2)))
edgelist.default <- function(input_object, weights = FALSE, ...) {
  if (is.atomic(input_object) && is.null(dim(input_object))) {
    n <- length(input_object)
    if (n < 2L) {
      stop("Vector must have at least 2 elements to form edges; got ", n)
    }

    df <- data.frame(
      from = input_object[seq_len(n - 1L)],
      to   = input_object[seq(2L, n)],
      stringsAsFactors = FALSE
    )

    if (isTRUE(weights)) {
      keys <- paste(df$from, df$to, sep = "\x1f")
      tab <- table(keys)
      first_idx <- !duplicated(keys)
      df <- df[first_idx, , drop = FALSE]
      df$weight <- as.integer(tab[keys[first_idx]])
      rownames(df) <- NULL
    }

    return(df)
  }

  stop("edgelist() does not support objects of class '",
       paste(class(input_object), collapse = "', '"),
       "'. Supported classes: vector, data.frame, randomForest, tree.")
}
