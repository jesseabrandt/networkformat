#' Extract Edgelist from RandomForest Model
#'
#' Converts a randomForest model object into a network edgelist representation
#' by extracting parent-child relationships from one or more trees in the forest. Each
#' edge represents a split in the decision tree, with additional attributes
#' including split variable, split point, and prediction values.
#'
#' @param input_object A randomForest model object from the randomForest package
#' @param treenum Integer vector of tree numbers to extract (default:
#'   \code{NULL} extracts all trees). Values must be between 1 and
#'   \code{input_object$ntree}.
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node index within the tree}
#'     \item{to}{Child node index (left or right daughter)}
#'     \item{split_var}{Numeric index of the variable used for splitting}
#'     \item{split_point}{Threshold value for the split}
#'     \item{prediction}{Prediction value at the child node}
#'     \item{treenum}{Tree number within the forest}
#'     \item{split_var_name}{Character vector with human-readable variable names}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   rf_model <- randomForest::randomForest(
#'     Species ~ .,
#'     data = iris,
#'     ntree = 5,
#'     maxnodes = 10
#'   )
#'
#'   # Extract all trees
#'   rf_edges <- edgelist(rf_model)
#'   head(rf_edges)
#'
#'   # Extract specific trees
#'   rf_edges_1 <- edgelist(rf_model, treenum = 1)
#'   rf_edges_13 <- edgelist(rf_model, treenum = c(1, 3))
#' }
edgelist.randomForest <- function(input_object, treenum = NULL, ...){
  if (!requireNamespace("randomForest", quietly = TRUE)) {
    stop("Package 'randomForest' is required. Install it with install.packages('randomForest').")
  }

  tree_indices <- .validate_treenum(treenum, input_object$ntree)

  convert_tree <- function(tn){
    tree1 <- randomForest::getTree(input_object, tn)
    tree1 <- as.data.frame(tree1)
    tree1$index <- seq_len(nrow(tree1))

    parent_index <- tree1$`left daughter` != 0
    edges_df <- data.frame(
      from        = c(tree1[parent_index, "index"], tree1[parent_index, "index"]),
      to          = c(tree1[parent_index, "left daughter"], tree1[parent_index, "right daughter"]),
      split_var   = c(tree1[parent_index, "split var"], tree1[parent_index, "split var"]),
      split_point = c(tree1[parent_index, "split point"], tree1[parent_index, "split point"]),
      prediction  = c(tree1[tree1[parent_index, "left daughter"], "prediction"],
                       tree1[tree1[parent_index, "right daughter"], "prediction"]),
      treenum     = tn)
    return(edges_df)
  }
  forest_edge <- lapply(tree_indices, convert_tree)
  forest_df <- do.call(rbind, forest_edge)
  rownames(forest_df) <- NULL
  var_names <- names(input_object$forest$ncat)
  forest_df$split_var_name <- var_names[forest_df$split_var]
  return(forest_df)
}
