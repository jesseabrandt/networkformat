#' Extract Edgelist from GBM Model
#'
#' Converts a gbm model object into a network edgelist representation
#' using \code{pretty.gbm.tree()}.  Missing-sentinel nodes (the phantom
#' routing nodes gbm creates for NA handling) are excluded — only real
#' \code{LeftNode}/\code{RightNode} edges are returned.
#'
#' Node IDs are 0-based integers per tree.  For models with
#' \code{num.classes > 1} (multinomial), physical trees are stored as
#' \code{n.trees * num.classes} entries; \code{treenum} indexes into
#' this flat sequence.
#'
#' @param input_object A gbm model object from the \pkg{gbm} package
#' @param treenum Integer vector of 1-based tree numbers to extract
#'   (default: \code{NULL} extracts all trees).  For multinomial models,
#'   this indexes physical trees (not boosting iterations).
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node ID (0-based integer)}
#'     \item{to}{Child node ID (0-based integer)}
#'     \item{split_var}{0-based variable index}
#'     \item{split_point}{Split threshold for continuous variables, or
#'       \code{c.splits} index for categorical variables}
#'     \item{prediction}{Prediction value at the child node}
#'     \item{treenum}{1-based tree number}
#'     \item{split_var_name}{Human-readable variable name}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("gbm", quietly = TRUE)) {
#'   set.seed(1)
#'   fit <- gbm::gbm(mpg ~ ., data = mtcars,
#'                    distribution = "gaussian", n.trees = 5,
#'                    interaction.depth = 3, n.minobsinnode = 3)
#'   el <- edgelist(fit)
#'   head(el)
#'
#'   # Single tree
#'   el1 <- edgelist(fit, treenum = 1)
#' }
edgelist.gbm <- function(input_object, treenum = NULL, ...) {
  if (!requireNamespace("gbm", quietly = TRUE)) {
    stop("Package 'gbm' is required. Install it with install.packages('gbm').")
  }

  n_physical <- length(input_object$trees)

  tree_indices <- .validate_treenum(treenum, n_physical)

  convert_tree <- function(tn) {
    pt <- gbm::pretty.gbm.tree(input_object, i.tree = tn)

    # Filter to internal (split) nodes
    internal <- pt[pt$SplitVar != -1, ]
    if (nrow(internal) == 0L) {
      return(data.frame(
        from = integer(0), to = integer(0),
        split_var = integer(0), split_point = numeric(0),
        prediction = numeric(0), treenum = integer(0),
        split_var_name = character(0),
        stringsAsFactors = FALSE
      ))
    }

    from_ids <- as.integer(rownames(internal))

    # Map node IDs (from rownames) to their prediction values to avoid
    # assuming any particular row ordering in pretty.gbm.tree().
    pred_by_node <- setNames(pt$Prediction, rownames(pt))
    left_pred  <- pred_by_node[as.character(internal$LeftNode)]
    right_pred <- pred_by_node[as.character(internal$RightNode)]

    edges <- data.frame(
      from           = c(from_ids, from_ids),
      to             = c(internal$LeftNode, internal$RightNode),
      split_var      = c(internal$SplitVar, internal$SplitVar),
      split_point    = c(internal$SplitCodePred, internal$SplitCodePred),
      prediction     = c(left_pred, right_pred),
      treenum        = tn,
      split_var_name = input_object$var.names[
        c(internal$SplitVar, internal$SplitVar) + 1L
      ],
      stringsAsFactors = FALSE
    )

    # Exclude edges pointing to missing-sentinel nodes
    real_ids <- sort(unique(c(from_ids, internal$LeftNode, internal$RightNode)))
    edges <- edges[edges$to %in% real_ids, ]
    edges
  }

  edge_list <- lapply(tree_indices, convert_tree)
  result <- do.call(rbind, edge_list)
  rownames(result) <- NULL
  result
}
