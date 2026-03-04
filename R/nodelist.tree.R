#' Extract Node List from Tree Model
#'
#' Extracts node-level attributes from a \code{tree} model object.
#' Node IDs are the binary heap indices from \code{rownames(input_object$frame)}
#' and match the \code{from}/\code{to} values produced by
#' \code{\link{edgelist.tree}}, so the two outputs can be passed directly to
#' \code{igraph::graph_from_data_frame()}.
#'
#' @param input_object A tree model object from the \pkg{tree} package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with one row per node and the following columns:
#'   \describe{
#'     \item{name}{Integer node ID (binary heap index, matches edgelist from/to)}
#'     \item{var}{Split variable name, or \code{"<leaf>"} for terminal nodes}
#'     \item{n}{Number of observations routed to this node}
#'     \item{dev}{Deviance (impurity) at this node}
#'     \item{yval}{Predicted value (numeric for regression, character for
#'       classification)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{label}{Display label: \code{"<var>\\nn=<n>"} for internal nodes,
#'       \code{"<yval>\\nn=<n>"} for leaves}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("tree", quietly = TRUE)) {
#'   tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
#'   nodelist(tr)
#'
#'   # Labels ready for plotting
#'   nodelist(tr)$label
#' }
nodelist.tree <- function(input_object, ...) {
  if (!requireNamespace("tree", quietly = TRUE)) {
    stop("Package 'tree' is required. Install it with install.packages('tree').")
  }

  frame <- input_object$frame
  is_leaf <- frame$var == "<leaf>"
  yval <- if (is.factor(frame$yval)) as.character(frame$yval) else frame$yval

  data.frame(
    name    = as.integer(rownames(frame)),
    var     = as.character(frame$var),
    n       = frame$n,
    dev     = frame$dev,
    yval    = yval,
    is_leaf = is_leaf,
    label   = ifelse(is_leaf,
                     paste0(yval, "\nn=", frame$n),
                     paste0(as.character(frame$var), "\nn=", frame$n)),
    stringsAsFactors = FALSE
  )
}
