#' Extract Node List from a List
#'
#' Recursively traverses a nested list structure, producing one row per node
#' with metadata about each element.
#'
#' When called on an S3 object that has no dedicated \code{nodelist} method,
#' the object is treated as a plain list and a diagnostic message is emitted.
#' To force structural decomposition of an object that has its own method
#' (e.g. a \code{tree}), use \code{nodelist(unclass(x))}.
#'
#' @param input_object A list (or S3 object falling through to this method).
#' @param name_root Character; label for the root node.
#'   Defaults to \code{"root"}.
#' @param max_depth Integer or \code{NULL}; maximum node depth to include
#'   (root is depth 0, its children are depth 1).  \code{NULL} (the default)
#'   means unlimited.  \code{max_depth = 0} returns the root node only.
#' @param ... Additional arguments (currently unused).
#'
#' @returns A data.frame with columns \code{name} (path-style ID),
#'   \code{depth} (integer), \code{type} (character class of the element),
#'   \code{n_children} (integer, 0 for leaves), and \code{label}
#'   (element name or positional index).
#'   An empty list returns a one-row data.frame for the root node only.
#' @export
#'
#' @examples
#' nodelist(list(a = 1, b = list(c = 2, d = 3)))
#'
#' # Unnamed elements
#' nodelist(list(1, 2, list(3, 4)))
nodelist.list <- function(input_object, name_root = "root", max_depth = NULL, ...) {
  if (!identical(class(input_object), "list")) {
    message("No nodelist method for class '",
            paste(class(input_object), collapse = "', '"),
            "'; treating as a plain list.")
    input_object <- unclass(input_object)
  }

  root_type <- "list"
  root <- data.frame(name = name_root, depth = 0L, type = root_type,
                     n_children = length(input_object), label = name_root,
                     stringsAsFactors = FALSE)

  if (length(input_object) == 0L) {
    return(root)
  }

  nodes <- .list_nodes(input_object, parent_name = name_root,
                       depth = 1L, max_depth = max_depth)
  do.call(rbind, c(list(root), nodes))
}

#' Recursive helper to collect nodes from a nested list
#' @noRd
.list_nodes <- function(obj, parent_name, depth, max_depth) {
  if (!is.null(max_depth) && depth > max_depth) return(list())

  nms <- names(obj)
  nodes <- vector("list", length(obj))

  for (i in seq_along(obj)) {
    label <- if (!is.null(nms) && nzchar(nms[i])) nms[i] else paste0("[[", i, "]]")
    child_name <- paste0(parent_name, "/", gsub("/", "%2F", label, fixed = TRUE))
    child <- obj[[i]]

    is_child_list <- is.list(child)
    child_type <- class(child)[1L]
    n_children <- if (is_child_list) length(child) else 0L

    node <- data.frame(name = child_name, depth = depth, type = child_type,
                       n_children = n_children, label = label,
                       stringsAsFactors = FALSE)

    if (is_child_list && length(child) > 0L &&
        (is.null(max_depth) || depth < max_depth)) {
      sub_nodes <- .list_nodes(child, parent_name = child_name,
                               depth = depth + 1L, max_depth = max_depth)
      nodes[[i]] <- do.call(rbind, c(list(node), sub_nodes))
    } else {
      nodes[[i]] <- node
    }
  }

  nodes
}
