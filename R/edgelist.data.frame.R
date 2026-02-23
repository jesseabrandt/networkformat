#' Extract Edgelist from Data Frame
#'
#' Converts a data.frame to network edgelist format by specifying which columns
#' represent source and target nodes. This is useful for creating edgelists from
#' tabular data where node relationships are stored in columns.
#'
#' @param input_object A data.frame containing network information
#' @param source_cols Column(s) for source nodes (default: 1). Accepts
#'   \href{https://tidyselect.r-lib.org/reference/language.html}{tidyselect}
#'   expressions: bare names, strings, numeric indices, or helpers like
#'   \code{starts_with()}.
#' @param target_cols Column(s) for target nodes (default: 2). Same syntax as
#'   \code{source_cols}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with two columns: 'source' and 'target', representing edges
#' @export
#'
#' @examples
#' # Course prerequisite network using bare column names
#' edgelist(courses, source_cols = course, target_cols = prereq)
#'
#' # Multiple target columns
#' edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))
#'
#' # Numeric indices still work (backward compatible)
#' edgelist(courses, source_cols = 2, target_cols = 3)
#'
#' # String column names
#' edgelist(courses, source_cols = "course", target_cols = "prereq")
edgelist.data.frame <- function(input_object, source_cols = 1, target_cols = 2, ...) {
  source_pos <- tidyselect::eval_select(rlang::enquo(source_cols), input_object)
  target_pos <- tidyselect::eval_select(rlang::enquo(target_cols), input_object)
  df <- data.frame(
    source = rep(unlist(input_object[, source_pos, drop = FALSE]), length(target_pos)),
    target = unlist(input_object[, target_pos, drop = FALSE])
  )
  return(df)
}
