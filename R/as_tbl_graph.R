#' Convert to tbl_graph
#'
#' S3 methods for converting tree-based model objects into
#' \code{\link[tidygraph]{tbl_graph}} objects.  Each method wraps the
#' corresponding \code{\link{as.igraph}} method.  These methods are
#' registered against the
#' \code{\link[tidygraph:as_tbl_graph]{as_tbl_graph}} generic from
#' \pkg{tidygraph} via delayed S3 registration and are available
#' whenever \pkg{tidygraph} is loaded.
#'
#' @param x An object to convert (currently \code{tree},
#'   \code{randomForest}, \code{rpart}, \code{xgb.Booster}, or
#'   \code{gbm}).
#' @param ... Additional arguments passed to \code{\link[igraph:as.igraph]{as.igraph}}.
#'
#' @returns A \code{\link[tidygraph]{tbl_graph}} object.
#' @name as_tbl_graph
NULL

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.tree <- function(x, ...) {
  tidygraph::as_tbl_graph(igraph::as.igraph(x, ...))
}

#' @rdname as_tbl_graph
#' @param treenum Integer vector of tree numbers to extract. Default
#'   \code{NULL} returns all trees combined into one graph with
#'   disconnected components.  Pass a single integer (e.g. \code{1})
#'   to extract one tree.
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.randomForest <- function(x, treenum = NULL, ...) {
  tidygraph::as_tbl_graph(igraph::as.igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.rpart <- function(x, ...) {
  tidygraph::as_tbl_graph(igraph::as.igraph(x, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.xgb.Booster <- function(x, treenum = NULL, ...) {
  tidygraph::as_tbl_graph(igraph::as.igraph(x, treenum = treenum, ...))
}

#' @rdname as_tbl_graph
#' @exportS3Method tidygraph::as_tbl_graph
as_tbl_graph.gbm <- function(x, treenum = NULL, ...) {
  tidygraph::as_tbl_graph(igraph::as.igraph(x, treenum = treenum, ...))
}
