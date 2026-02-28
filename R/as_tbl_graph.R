#' Convert to tbl_graph
#'
#' S3 methods for the \code{\link[tidygraph]{as_tbl_graph}} generic
#' from the \pkg{tidygraph} package.  Each method wraps the
#' corresponding \code{\link{as_igraph}} method.
#'
#' @param x An object to convert (currently \code{tree},
#'   \code{randomForest}, \code{rpart}, \code{xgb.Booster}, or
#'   \code{gbm}).
#' @param ... Additional arguments passed to \code{as_igraph}.
#'
#' @returns A \code{\link[tidygraph]{tbl_graph}} object.
#'
#' @name as_tbl_graph

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
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
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.randomForest <- function(x, treenum = 1L, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.rpart <- function(x, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.xgb.Booster <- function(x, treenum = 1L, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.gbm <- function(x, treenum = 1L, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}
