#' Convert to tbl_graph
#'
#' S3 methods for the \code{\link[tidygraph]{as_tbl_graph}} generic
#' from the \pkg{tidygraph} package.  Each method wraps the
#' corresponding \code{\link{as_igraph}} method.
#'
#' @param x An object to convert (currently \code{tree} or
#'   \code{randomForest}).
#' @param ... Additional arguments passed to \code{as_igraph}.
#'
#' @returns A \code{\link[tidygraph]{tbl_graph}} object.
#'
#' @name as_tbl_graph

#' @rdname as_tbl_graph
#' @export
as_tbl_graph.tree <- function(x, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, ...))
}

#' @rdname as_tbl_graph
#' @param treenum Integer vector of tree numbers to extract. Default
#'   \code{1} returns a single tbl_graph for the first tree.  Use
#'   \code{NULL} to get all trees combined into one graph.
#' @export
as_tbl_graph.randomForest <- function(x, treenum = 1L, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}
