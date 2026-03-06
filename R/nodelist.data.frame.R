#' Extract Node List from Data Frame
#'
#' Selects and reorders columns from a data.frame to create a node list
#' suitable for \code{igraph::graph_from_data_frame()}.  The ID column
#' is placed first; remaining columns are node attributes.
#' This is intentionally a thin wrapper (select + reorder) --- it
#' exists so that data frames participate in the same
#' \code{edgelist()} / \code{nodelist()} /
#' \code{graph_from_data_frame()} pipeline as model objects.
#'
#' @param input_object A data.frame containing node information
#' @param id_col Column for the node ID (default: 1). Accepts
#'   \href{https://tidyselect.r-lib.org/reference/language.html}{tidyselect}
#'   expressions: a bare name, string, or numeric index.
#' @param attr_cols Columns to keep as node attributes (default:
#'   \code{NULL} keeps all columns except \code{id_col}).  Pass an
#'   empty \code{c()} to return only the ID column.  Accepts the same
#'   \href{https://tidyselect.r-lib.org/reference/language.html}{tidyselect}
#'   syntax as \code{id_col}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the ID column first, followed by
#'   selected attribute columns
#' @export
#'
#' @examples
#' # Default: first column (dept) is ID, all other columns kept
#' nodelist(courses)
#'
#' # Use bare column name
#' nodelist(courses, id_col = course)
#'
#' # Select specific attribute columns
#' nodelist(courses, id_col = course, attr_cols = c(dept, credits))
#'
#' # ID column only (no attributes)
#' nodelist(courses, id_col = course, attr_cols = c())
#'
#' # Numeric index still works
#' nodelist(courses, id_col = 2)
nodelist.data.frame <- function(input_object, id_col = 1, attr_cols = NULL, ...) {
  id_pos <- tidyselect::eval_select(rlang::enquo(id_col), input_object)
  if (length(id_pos) != 1L) stop("id_col must select exactly one column")
  idx <- unname(id_pos)

  attr_quo <- rlang::enquo(attr_cols)
  if (rlang::quo_is_null(attr_quo)) {
    # NULL default: all columns except id_col
    cols <- c(idx, setdiff(seq_len(ncol(input_object)), idx))
  } else {
    attr_pos <- tidyselect::eval_select(attr_quo, input_object)
    cols <- c(idx, unname(attr_pos))
    # Remove id_col if user accidentally included it in attr_cols
    cols <- unique(cols)
  }

  input_object[, cols, drop = FALSE]
}
