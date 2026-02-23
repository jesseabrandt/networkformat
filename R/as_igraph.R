#' Convert to igraph
#'
#' Generic function to convert tree-based model objects into
#' \code{\link[igraph]{igraph}} graph objects.  Methods call
#' \code{\link{edgelist}} and \code{\link{nodelist}} internally and
#' handle column reconciliation so you get a ready-to-use graph.
#'
#' @param x An object to convert (currently \code{tree} or
#'   \code{randomForest}).
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
  vertices <- data.frame(name = nodes$node, nodes[setdiff(names(nodes), "node")],
                         stringsAsFactors = FALSE)
  igraph::graph_from_data_frame(edges, directed = TRUE, vertices = vertices)
}

#' @rdname as_igraph
#' @param treenum Integer vector of tree numbers to extract. Default
#'   \code{1} returns a single graph for the first tree.  Use
#'   \code{NULL} to get all trees combined into one graph with
#'   disconnected components.
#' @export
as_igraph.randomForest <- function(x, treenum = 1L, ...) {
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
    vertices <- data.frame(name = n$node, n[setdiff(names(n), c("node", "treenum"))],
                           stringsAsFactors = FALSE)
    e$treenum <- NULL
    return(igraph::graph_from_data_frame(e, directed = TRUE, vertices = vertices))
  }

  # Multiple trees: combine into single graph with disconnected components
  all_edges <- edgelist(x, treenum = tree_indices)
  all_nodes <- nodelist(x, treenum = tree_indices)

  # Make node IDs unique across trees by prefixing with treenum
  all_edges$source <- paste0(all_edges$treenum, ".", all_edges$source)
  all_edges$target <- paste0(all_edges$treenum, ".", all_edges$target)

  vertices <- data.frame(
    name = paste0(all_nodes$treenum, ".", all_nodes$node),
    all_nodes[setdiff(names(all_nodes), "node")],
    stringsAsFactors = FALSE
  )

  igraph::graph_from_data_frame(all_edges, directed = TRUE, vertices = vertices)
}
