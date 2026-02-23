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
#' @param attr_cols Columns to carry as edge attributes (default: \code{NULL}
#'   keeps all columns not used as source or target). Pass an empty \code{c()}
#'   to keep only source, target, and metadata columns. Accepts the same
#'   \href{https://tidyselect.r-lib.org/reference/language.html}{tidyselect}
#'   syntax as \code{source_cols}.
#' @param na.rm Logical; if \code{TRUE} (the default), rows where
#'   \code{source} or \code{target} is \code{NA} are removed from the
#'   result.  Set to \code{FALSE} to preserve the old behavior of
#'   keeping all rows.
#' @param symmetric_cols Target column names that represent undirected
#'   (symmetric) relationships.  When non-\code{NULL}, a \code{directed}
#'   column is added: \code{FALSE} for edges from target columns named
#'   in \code{symmetric_cols}, \code{TRUE} otherwise.  Accepts the same
#'   tidyselect syntax as \code{target_cols}; names must be a subset of
#'   \code{target_cols}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with columns:
#' \describe{
#'   \item{source}{Source node values}
#'   \item{target}{Target node values}
#'   \item{source_col}{Name of the original column each source value came from}
#'   \item{target_col}{Name of the original column each target value came from}
#'   \item{directed}{(only when \code{symmetric_cols} is provided) Logical:
#'     \code{FALSE} for edges from symmetric target columns, \code{TRUE}
#'     otherwise}
#'   \item{...}{Additional attribute columns selected by \code{attr_cols}}
#' }
#' @export
#'
#' @examples
#' # Basic usage --- all non-source/target columns kept by default
#' edgelist(courses, source_cols = course, target_cols = prereq)
#'
#' # Multiple target columns --- target_col identifies the relationship type
#' edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))
#'
#' # Keep only the edgelist (no attribute columns)
#' edgelist(courses, source_cols = course, target_cols = prereq, attr_cols = c())
#'
#' # Select specific attribute columns
#' edgelist(courses, source_cols = course, target_cols = prereq,
#'          attr_cols = c(dept, credits))
#'
#' # NA removal (default) vs preservation
#' edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))
#' edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist),
#'          na.rm = FALSE)
#'
#' # Mark symmetric (undirected) target columns
#' edgelist(courses, source_cols = course,
#'          target_cols = c(prereq, crosslist),
#'          symmetric_cols = crosslist)
edgelist.data.frame <- function(input_object, source_cols = 1, target_cols = 2,
                                 attr_cols = NULL, na.rm = TRUE,
                                 symmetric_cols = NULL, ...) {
  source_pos <- tidyselect::eval_select(rlang::enquo(source_cols), input_object)
  target_pos <- tidyselect::eval_select(rlang::enquo(target_cols), input_object)

  # Determine which attribute columns to keep
  attr_quo <- rlang::enquo(attr_cols)
  used_pos <- c(source_pos, target_pos)

  if (rlang::quo_is_null(attr_quo)) {
    # NULL default: keep all columns not used as source/target
    all_pos <- seq_along(input_object)
    attr_pos <- setdiff(all_pos, used_pos)
  } else {
    # Explicit selection (may be empty via c())
    attr_pos <- tidyselect::eval_select(attr_quo, input_object)
  }

  # Resolve symmetric_cols
  sym_quo <- rlang::enquo(symmetric_cols)
  has_symmetric <- !rlang::quo_is_null(sym_quo)
  sym_names <- character(0)

  if (has_symmetric) {
    sym_pos <- tidyselect::eval_select(sym_quo, input_object)
    sym_names <- names(sym_pos)
    target_names_set <- names(target_pos)
    bad <- setdiff(sym_names, target_names_set)
    if (length(bad) > 0) {
      warning("symmetric_cols not found in target_cols: ",
              paste(bad, collapse = ", "))
    }
  }

  attr_names <- names(input_object)[attr_pos]
  source_names <- names(source_pos)
  target_names <- names(target_pos)

  # Build result by iterating over all (source_col, target_col) pairs
  n <- nrow(input_object)
  blocks <- vector("list", length(source_pos) * length(target_pos))
  k <- 0L
  for (si in seq_along(source_pos)) {
    for (ti in seq_along(target_pos)) {
      k <- k + 1L
      block <- data.frame(
        source     = input_object[[source_pos[si]]],
        target     = input_object[[target_pos[ti]]],
        source_col = rep(source_names[si], n),
        target_col = rep(target_names[ti], n),
        stringsAsFactors = FALSE
      )
      # Add directed column when symmetric_cols is provided
      if (has_symmetric) {
        block$directed <- !(target_names[ti] %in% sym_names)
      }
      # Append attribute columns
      for (a in attr_pos) {
        block[[names(input_object)[a]]] <- input_object[[a]]
      }
      blocks[[k]] <- block
    }
  }

  df <- do.call(rbind, blocks)
  rownames(df) <- NULL

  # Remove rows with NA source or target
  if (isTRUE(na.rm)) {
    df <- df[!is.na(df$source) & !is.na(df$target), , drop = FALSE]
    rownames(df) <- NULL
  }

  return(df)
}
