#' Extract Edgelist from a List
#'
#' Recursively traverses a nested list structure, producing a parent-child
#' edgelist.  Each element of the list becomes a node; nested lists create
#' deeper edges.  Path-style IDs ensure unique node names even when element
#' names repeat at different levels.
#'
#' When called on an S3 object that has no dedicated \code{edgelist} method
#' (e.g. an \code{lm} object), the object is treated as a plain list and a
#' diagnostic message is emitted.  To force structural decomposition of an
#' object that has its own method (e.g. a \code{tree}), use
#' \code{edgelist(unclass(x))}.
#'
#' @param input_object A list (or S3 object falling through to this method).
#' @param name_root Character; label for the root node.
#'   Defaults to \code{"root"}.
#' @param max_depth Integer or \code{NULL}; maximum node depth to include
#'   (root is depth 0, its children are depth 1).  \code{NULL} (the default)
#'   means unlimited.  \code{max_depth = 0} returns an empty edgelist (root
#'   only).
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with columns \code{from}, \code{to}, and \code{depth}
#'   (integer depth of the child node, root children are depth 1).
#'   An empty list returns a zero-row data.frame with the same columns.
#' @export
#'
#' @examples
#' edgelist(list(a = 1, b = list(c = 2, d = 3)))
#'
#' # Unnamed elements use positional indices
#' edgelist(list(1, 2, list(3, 4)))
#'
#' # Limit depth (root = 0, children = 1, ...)
#' edgelist(list(a = list(b = list(c = 1))), max_depth = 2)
edgelist.list <- function(input_object, name_root = "root", max_depth = NULL, ...) {
  if (!identical(class(input_object), "list")) {
    message("No edgelist method for class '",
            paste(class(input_object), collapse = "', '"),
            "'; treating as a plain list.")
    input_object <- unclass(input_object)
  }

  empty <- data.frame(from = character(0), to = character(0),
                      depth = integer(0), stringsAsFactors = FALSE)

  if (length(input_object) == 0L || (!is.null(max_depth) && max_depth < 1L)) {
    return(empty)
  }

  edges <- .list_edges(input_object, parent_name = name_root,
                       depth = 1L, max_depth = max_depth)
  result <- do.call(rbind, edges)
  if (is.null(result)) empty else result
}

#' Recursive helper to collect edges from a nested list
#' @noRd
.list_edges <- function(obj, parent_name, depth, max_depth) {
  if (!is.null(max_depth) && depth > max_depth) return(list())

  nms <- names(obj)
  edges <- vector("list", length(obj))

  for (i in seq_along(obj)) {
    label <- if (!is.null(nms) && nzchar(nms[i])) nms[i] else paste0("[[", i, "]]")
    child_name <- paste0(parent_name, "/", label)

    edge <- data.frame(from = parent_name, to = child_name, depth = depth,
                       stringsAsFactors = FALSE)

    child <- obj[[i]]
    if (is.list(child) && length(child) > 0L &&
        (is.null(max_depth) || depth < max_depth)) {
      sub_edges <- .list_edges(child, parent_name = child_name,
                               depth = depth + 1L, max_depth = max_depth)
      edges[[i]] <- do.call(rbind, c(list(edge), sub_edges))
    } else {
      edges[[i]] <- edge
    }
  }

  edges
}
