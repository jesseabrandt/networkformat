#' Convert to igraph
#'
#' Generic function to convert tree-based model objects into
#' \code{\link[igraph]{igraph}} graph objects.  Methods call
#' \code{\link{edgelist}} and \code{\link{nodelist}} internally and
#' handle column reconciliation so you get a ready-to-use graph.
#'
#' @param x An object to convert (\code{tree}, \code{randomForest},
#'   \code{rpart}, \code{xgb.Booster}, or \code{gbm}).
#' @param ... Additional arguments passed to methods.
#'
#' @returns An \code{\link[igraph]{igraph}} object.  For
#'   \code{randomForest} with multiple trees, the graph contains
#'   disconnected components (one per tree) and a \code{treenum}
#'   vertex/edge attribute.
#' @export
as_igraph <- function(x, ...) UseMethod("as_igraph")

#' @rdname as_igraph
#' @export
as_igraph.tree <- function(x, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with install.packages('igraph').")
  }
  edges <- edgelist(x)
  nodes <- nodelist(x)
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
}

#' @rdname as_igraph
#' @param treenum Integer vector of tree numbers to extract. Default
#'   \code{NULL} returns all trees combined into one graph with
#'   disconnected components.  Pass a single integer (e.g. \code{1})
#'   to extract one tree.
#' @export
as_igraph.randomForest <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with install.packages('igraph').")
  }

  tree_indices <- if (is.null(treenum)) {
    seq_len(x$ntree)
  } else {
    as.integer(treenum)
  }

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

#' @rdname as_igraph
#' @export
as_igraph.rpart <- function(x, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with install.packages('igraph').")
  }
  edges <- edgelist(x)
  nodes <- nodelist(x)
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
}

#' @rdname as_igraph
#' @export
as_igraph.xgb.Booster <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with install.packages('igraph').")
  }

  # String IDs from xgboost are already globally unique across trees
  e <- edgelist(x, treenum = treenum)
  n <- nodelist(x, treenum = treenum)
  igraph::graph_from_data_frame(e, directed = TRUE, vertices = n)
}

#' @rdname as_igraph
#' @export
as_igraph.gbm <- function(x, treenum = NULL, ...) {
  if (!requireNamespace("igraph", quietly = TRUE)) {
    stop("Package 'igraph' is required. Install it with install.packages('igraph').")
  }

  tree_indices <- if (is.null(treenum)) {
    seq_len(length(x$trees))
  } else {
    as.integer(treenum)
  }

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
