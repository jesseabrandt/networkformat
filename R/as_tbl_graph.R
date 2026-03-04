#' Convert to tbl_graph
#'
#' Generic function and S3 methods for converting tree-based model
#' objects into \code{\link[tidygraph]{tbl_graph}} objects.  Each
#' method wraps the corresponding \code{\link{as_igraph}} method.
#'
#' @param x An object to convert (currently \code{tree},
#'   \code{randomForest}, \code{rpart}, \code{xgb.Booster}, or
#'   \code{gbm}).
#' @param ... Additional arguments passed to \code{as_igraph}.
#'
#' @returns A \code{\link[tidygraph]{tbl_graph}} object.
#' @export
as_tbl_graph <- function(x, ...) UseMethod("as_tbl_graph")

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
#'   \code{NULL} returns all trees combined into one graph with
#'   disconnected components.  Pass a single integer (e.g. \code{1})
#'   to extract one tree.
#' @export
as_tbl_graph.randomForest <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @export
as_tbl_graph.rpart <- function(x, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, ...))
}

#' @rdname as_tbl_graph
#' @export
as_tbl_graph.xgb.Booster <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @export
as_tbl_graph.gbm <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("tidygraph", quietly = TRUE)) {
    stop("Package 'tidygraph' is required. Install it with install.packages('tidygraph').")
  }
  tidygraph::as_tbl_graph(as_igraph(x, treenum = treenum, ...))
}
