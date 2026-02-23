#' Extract Node List from RandomForest Model
#'
#' Extracts node-level attributes from every tree in a
#' \code{randomForest} model.
#' Node IDs match the \code{source}/\code{target} indices produced by
#' \code{\link{edgelist.randomForest}}, so the two outputs can be
#' passed directly to \code{igraph::graph_from_data_frame()} (after
#' filtering to a single \code{treenum}).
#'
#' @param input_object A randomForest model object from the
#'   \pkg{randomForest} package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with one row per node (across all trees) and the
#'   following columns:
#'   \describe{
#'     \item{node}{Integer node ID within the tree (matches edgelist
#'       source/target)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{split_var}{Numeric index of the split variable (\code{NA} for
#'       leaves)}
#'     \item{split_var_name}{Name of the split variable (\code{NA} for
#'       leaves)}
#'     \item{split_point}{Split threshold (\code{NA} for leaves)}
#'     \item{prediction}{Predicted value (numeric for regression, integer
#'       class index for classification)}
#'     \item{treenum}{Integer identifying which tree the node belongs to}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
#'   nodes <- nodelist(rf)
#'   head(nodes)
#'
#'   # Pair with edgelist for a single tree
#'   edges <- edgelist(rf)
#'   tree1_edges <- subset(edges, treenum == 1)
#'   tree1_nodes <- subset(nodes, treenum == 1)
#' }
nodelist.randomForest <- function(input_object, ...) {
  var_names <- names(input_object$forest$ncat)

  convert_tree <- function(treenum) {
    tree_df <- as.data.frame(randomForest::getTree(input_object, treenum))
    is_leaf <- tree_df$`left daughter` == 0
    split_var <- tree_df$`split var`

    data.frame(
      node           = seq_len(nrow(tree_df)),
      is_leaf        = is_leaf,
      split_var      = ifelse(is_leaf, NA_real_, split_var),
      split_var_name = ifelse(is_leaf, NA_character_, var_names[split_var]),
      split_point    = ifelse(is_leaf, NA_real_, tree_df$`split point`),
      prediction     = tree_df$prediction,
      treenum        = treenum,
      stringsAsFactors = FALSE
    )
  }

  node_list <- lapply(seq_len(input_object$ntree), convert_tree)
  do.call(rbind, node_list)
}
