#' @keywords internal
#' @seealso
#' Vignettes:
#' \itemize{
#'   \item \code{vignette("networkformat")} --- package overview
#'   \item \code{vignette("edgelist-nodelist")} --- edgelist and nodelist usage
#'   \item \code{vignette("visualization")} --- ggraph visualization examples
#' }
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang enquo quo_is_null
#' @importFrom tidyselect eval_select
## usethis namespace: end
NULL

# Internal helper: validate and return integer tree indices.
# Returns seq_len(max_tree) when treenum is NULL; otherwise validates
# that treenum is a non-empty, non-NA integer vector within [1, max_tree].
.validate_treenum <- function(treenum, max_tree) {
  if (is.null(treenum)) return(seq_len(max_tree))
  treenum_int <- as.integer(treenum)
  if (length(treenum_int) == 0L || anyNA(treenum_int) ||
      !all(treenum_int >= 1L & treenum_int <= max_tree)) {
    stop("treenum must be between 1 and ", max_tree,
         "; got: ", paste(treenum, collapse = ", "))
  }
  treenum_int
}
