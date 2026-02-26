#' Extract Node List from Data Frame
#'
#' Reorders a data.frame to place the ID column first, creating a proper
#' node list format. All other columns are treated as node attributes.
#'
#' @param input_object A data.frame containing node information
#' @param id_col Column for the node ID (default: 1). Accepts
#'   \href{https://tidyselect.r-lib.org/reference/language.html}{tidyselect}
#'   expressions: a bare name, string, or numeric index.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the ID column first, followed by all attribute columns
#' @export
#'
#' @examples
#' # Default: first column (dept) is ID
#' nodelist(courses)
#'
#' # Use bare column name
#' nodelist(courses, id_col = course)
#'
#' # Numeric index still works
#' nodelist(courses, id_col = 2)
nodelist.data.frame <- function(input_object, id_col = 1, ...) {
  pos <- tidyselect::eval_select(rlang::enquo(id_col), input_object)
  if (length(pos) != 1L) stop("id_col must select exactly one column")
  idx <- unname(pos)
  input_object[, c(idx, setdiff(seq_len(ncol(input_object)), idx)), drop = FALSE]
}
