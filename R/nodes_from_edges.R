#' Extract Unique Nodes from an Edgelist
#'
#' Returns a data.frame of unique node IDs extracted from the
#' \code{from} and \code{to} columns of an edgelist.  This closes the
#' common workflow gap where \code{\link{edgelist}} produces edges but
#' \code{igraph::graph_from_data_frame()} also needs a vertex table.
#'
#' @param edges A data.frame with at least \code{from} and \code{to}
#'   columns (typically the output of \code{\link{edgelist}}).
#'
#' @returns A data.frame with a single column \code{name} containing
#'   the sorted unique node IDs from both endpoints.
#'
#' @export
#'
#' @examples
#' el <- edgelist(c("A", "B", "C", "D"))
#' nodes_from_edges(el)
#'
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
#'   el <- edgelist(rf, treenum = 1)
#'   nodes_from_edges(el)
#' }
nodes_from_edges <- function(edges) {
  if (!is.data.frame(edges) || !all(c("from", "to") %in% names(edges))) {
    stop("edges must be a data.frame with 'from' and 'to' columns")
  }
  ids <- unique(c(as.character(edges$from), as.character(edges$to)))
  ids <- sort(ids[!is.na(ids)])
  data.frame(name = ids, stringsAsFactors = FALSE)
}
