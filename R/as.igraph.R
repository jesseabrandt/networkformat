#' Convert to igraph
#'
#' S3 methods for converting tree-based model objects into
#' \code{\link[igraph]{igraph}} graph objects.  Each method calls
#' \code{\link{edgelist}} and \code{\link{nodelist}} internally and
#' handles column reconciliation so you get a ready-to-use graph.
#' These methods are registered against the
#' \code{\link[igraph:as.igraph]{as.igraph}} generic from
#' \pkg{igraph} via delayed S3 registration and are available
#' whenever \pkg{igraph} is loaded.
#'
#' @param x An object to convert (\code{tree}, \code{randomForest},
#'   \code{rpart}, \code{xgb.Booster}, or \code{gbm}).
#' @param ... Additional arguments passed to methods.
#'
#' @returns An \code{\link[igraph]{igraph}} object.  For
#'   \code{randomForest} with multiple trees, the graph contains
#'   disconnected components (one per tree) and a \code{treenum}
#'   vertex/edge attribute.
#'
#' @examples
#' if (requireNamespace("rpart", quietly = TRUE) &&
#'     requireNamespace("igraph", quietly = TRUE)) {
#'   fit <- rpart::rpart(Sepal.Length ~ ., data = iris)
#'   g <- igraph::as.igraph(fit)
#'   igraph::vcount(g)
#'   igraph::ecount(g)
#' }
#' @name as.igraph
NULL

#' @rdname as.igraph
#' @exportS3Method igraph::as.igraph
as.igraph.tree <- function(x, ...) {
  edges <- edgelist(x)
  nodes <- nodelist(x)
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
}

#' @rdname as.igraph
#' @param treenum Integer vector of tree numbers to extract. Default
#'   \code{NULL} returns all trees combined into one graph with
#'   disconnected components.  Pass a single integer (e.g. \code{1})
#'   to extract one tree.
#' @exportS3Method igraph::as.igraph
as.igraph.randomForest <- function(x, treenum = NULL, ...) {
  tree_indices <- .validate_treenum(treenum, x$ntree)

  # Single tree: simple case, no prefixing needed
  if (length(tree_indices) == 1L) {
    e <- edgelist(x, treenum = tree_indices)
    n <- nodelist(x, treenum = tree_indices)
    return(igraph::graph_from_data_frame(e, directed = TRUE, vertices = n))
  }

  # Multiple trees: combine into single graph with disconnected components
  all_edges <- edgelist(x, treenum = tree_indices)
  all_nodes <- nodelist(x, treenum = tree_indices)

  # Make node IDs unique across trees by prefixing with treenum
  all_edges$from <- paste0(all_edges$treenum, ".", all_edges$from)
  all_edges$to   <- paste0(all_edges$treenum, ".", all_edges$to)

  all_nodes$name <- paste0(all_nodes$treenum, ".", all_nodes$name)

  igraph::graph_from_data_frame(all_edges, directed = TRUE, vertices = all_nodes)
}

#' @rdname as.igraph
#' @exportS3Method igraph::as.igraph
as.igraph.rpart <- function(x, ...) {
  edges <- edgelist(x)
  nodes <- nodelist(x)
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
}

#' @rdname as.igraph
#' @exportS3Method igraph::as.igraph
as.igraph.xgb.Booster <- function(x, treenum = NULL, ...) {
  # String IDs from xgboost are already globally unique across trees
  e <- edgelist(x, treenum = treenum)
  n <- nodelist(x, treenum = treenum)
  igraph::graph_from_data_frame(e, directed = TRUE, vertices = n)
}

#' @rdname as.igraph
#' @exportS3Method igraph::as.igraph
as.igraph.gbm <- function(x, treenum = NULL, ...) {
  n_physical <- length(x$trees)
  tree_indices <- .validate_treenum(treenum, n_physical)

  # Single tree: no prefixing needed
  if (length(tree_indices) == 1L) {
    e <- edgelist(x, treenum = tree_indices)
    n <- nodelist(x, treenum = tree_indices)
    return(igraph::graph_from_data_frame(e, directed = TRUE, vertices = n))
  }

  # Multiple trees: prefix node IDs with treenum for uniqueness
  all_edges <- edgelist(x, treenum = tree_indices)
  all_nodes <- nodelist(x, treenum = tree_indices)

  all_edges$from <- paste0(all_edges$treenum, ".", all_edges$from)
  all_edges$to   <- paste0(all_edges$treenum, ".", all_edges$to)
  all_nodes$name <- paste0(all_nodes$treenum, ".", all_nodes$name)

  igraph::graph_from_data_frame(all_edges, directed = TRUE, vertices = all_nodes)
}
