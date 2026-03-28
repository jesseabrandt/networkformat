#' Extract Node List from GBM Model
#'
#' Extracts node-level attributes from a gbm model via
#' \code{pretty.gbm.tree()}.  Missing-sentinel nodes are excluded by
#' keeping only nodes reachable through \code{LeftNode}/\code{RightNode}
#' edges from the root.
#'
#' @param input_object A gbm model object from the \pkg{gbm} package
#' @param treenum Integer vector of 1-based tree numbers to extract
#'   (default: \code{NULL} extracts all trees).
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with one row per real node and the following columns:
#'   \describe{
#'     \item{name}{0-based node ID within the tree}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{split_var}{0-based variable index (\code{NA} for leaves)}
#'     \item{split_var_name}{Variable name (\code{NA} for leaves)}
#'     \item{split_point}{Split threshold (\code{NA} for leaves)}
#'     \item{prediction}{Prediction value at the node}
#'     \item{error_reduction}{Impurity reduction from the split (0 for leaves);
#'       per-node variable importance from \code{ErrorReduction}}
#'     \item{weight}{Number of training observations reaching the node,
#'       from \code{Weight}}
#'     \item{treenum}{1-based tree number}
#'     \item{label}{Display label: \code{"<var>\\n< <threshold>"} for
#'       splits, rounded prediction for leaves}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("gbm", quietly = TRUE)) {
#'   set.seed(1)
#'   fit <- gbm::gbm(mpg ~ ., data = mtcars,
#'                    distribution = "gaussian", n.trees = 5,
#'                    interaction.depth = 3, n.minobsinnode = 3)
#'   nl <- nodelist(fit)
#'   head(nl)
#' }
nodelist.gbm <- function(input_object, treenum = NULL, ...) {
  if (!requireNamespace("gbm", quietly = TRUE)) {
    stop("Package 'gbm' is required. Install it with install.packages('gbm').")
  }

  n_physical <- length(input_object$trees)

  tree_indices <- .validate_treenum(treenum, n_physical)

  convert_tree <- function(tn) {
    pt <- gbm::pretty.gbm.tree(input_object, i.tree = tn)

    # Collect real nodes: internal nodes plus their LeftNode/RightNode children.
    # Missing-sentinel nodes (reached only via MissingNode) are excluded.
    internal <- pt[pt$SplitVar != -1, ]
    if (nrow(internal) == 0L) {
      # Stump: root only
      real_ids <- 0L
    } else {
      real_ids <- sort(unique(c(
        as.integer(rownames(internal)),
        internal$LeftNode,
        internal$RightNode
      )))
    }

    pt_real <- pt[as.character(real_ids), ]
    is_leaf <- pt_real$SplitVar == -1

    split_var <- ifelse(is_leaf, NA_integer_, pt_real$SplitVar)
    # Leaf nodes have SplitVar = -1; adding 1 gives index 0, and R's `[`
    # silently drops 0-indices (returns character(0) instead of NA).  Guard
    # with pmax so the indexed value is harmless — ifelse selects NA for leaves.
    split_var_name <- ifelse(is_leaf, NA_character_,
                             input_object$var.names[pmax(pt_real$SplitVar + 1L, 1L)])

    # Detect categorical splits: var.type > 0 means categorical.
    # For categorical splits, SplitCodePred is a c.splits index, not a threshold.
    var_type <- input_object$var.type
    is_categorical <- !is_leaf & var_type[pmax(pt_real$SplitVar + 1L, 1L)] > 0

    internal_label <- ifelse(
      is_categorical,
      split_var_name,
      paste0(split_var_name, "\n< ", round(pt_real$SplitCodePred, 2))
    )

    data.frame(
      name            = real_ids,
      is_leaf         = is_leaf,
      split_var       = split_var,
      split_var_name  = split_var_name,
      split_point     = ifelse(is_leaf, NA_real_, pt_real$SplitCodePred),
      prediction      = pt_real$Prediction,
      error_reduction = pt_real$ErrorReduction,
      weight          = pt_real$Weight,
      treenum         = tn,
      label           = ifelse(is_leaf,
                               as.character(round(pt_real$Prediction, 4)),
                               internal_label),
      stringsAsFactors = FALSE
    )
  }

  node_list <- lapply(tree_indices, convert_tree)
  result <- do.call(rbind, node_list)
  rownames(result) <- NULL
  result
}
