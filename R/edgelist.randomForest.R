#' Extract Edgelist from RandomForest Model
#'
#' Converts a randomForest model object into a network edgelist representation
#' by extracting parent-child relationships from all trees in the forest. Each
#' edge represents a split in the decision tree, with additional attributes
#' including split variable, split point, and prediction values.
#'
#' @param input_object A randomForest model object from the randomForest package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{source}{Parent node index within the tree}
#'     \item{target}{Child node index (left or right daughter)}
#'     \item{split_var}{Numeric index of the variable used for splitting}
#'     \item{split_point}{Threshold value for the split}
#'     \item{prediction}{Prediction value at the parent node}
#'     \item{treenum}{Tree number within the forest}
#'     \item{split_var_name}{Factor with human-readable variable names}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   # Fit a small random forest
#'   rf_model <- randomForest::randomForest(
#'     Species ~ .,
#'     data = iris,
#'     ntree = 5,
#'     maxnodes = 10
#'   )
#'
#'   # Extract edgelist
#'   rf_edges <- edgelist(rf_model)
#'   head(rf_edges)
#'
#'   # Examine split variables
#'   table(rf_edges$split_var_name)
#'
#'   # Filter to first tree only
#'   tree1_edges <- subset(rf_edges, treenum == 1)
#'   nrow(tree1_edges)
#' }
edgelist.randomForest <- function(input_object, ...){
  convert_tree <- function(treenum){
    tree1 <- randomForest::getTree(input_object, treenum)
    tree1 <- as.data.frame(tree1)
    tree1$index <- c(1:nrow(tree1))

    parent_index <- tree1$`left daughter` != 0
    edgelist <- data.frame(source = c(tree1[parent_index,"index"], tree1[parent_index,"index"]),
                           target = c(tree1[parent_index,"left daughter"], tree1[parent_index,"right daughter"]),
                           split_var = c(tree1[parent_index,"split var"], tree1[parent_index,"split var"]),
                           split_point = c(tree1[parent_index,"split point"], tree1[parent_index,"split point"]),
                           prediction = c(tree1[parent_index,"prediction"], tree1[parent_index,"prediction"]),
                           treenum = treenum)
    return(edgelist)
  }
  forest_edge <- lapply(c(1:input_object$ntree), \(i)(convert_tree(i)))
  forest_df <- do.call(rbind, forest_edge)
  forest_df$split_var_name <- factor(forest_df$split_var, labels = names(input_object$forest$ncat))
  return(forest_df)
}
