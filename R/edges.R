#' Extract Edgelist from Tree Models
#'
#' Generic function to extract network edgelist representation from various
#' tree-based models including randomForest, tree, and xgboost objects.
#' The edgelist represents the hierarchical structure of decision trees
#' with parent-child relationships.
#'
#' @param input_object A tree model object (randomForest, tree, xgboost, or data.frame)
#' @param ... Additional arguments passed to specific methods
#'
#' @returns A data.frame with columns representing edges between nodes in the tree.
#'   The specific columns depend on the input object type.
#' @export
#'
#' @examples
#' # RandomForest example
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 10)
#'   edges_rf <- edges(rf)
#'   head(edges_rf)
#' }
#'
#' # Tree example
#' if (requireNamespace("tree", quietly = TRUE)) {
#'   tr <- tree::tree(Species ~ ., data = iris)
#'   edges_tr <- edges(tr)
#'   head(edges_tr)
#' }
edges <- function(input_object, ...) {UseMethod("edges")}


#' Extract Edgelist from Data Frame
#'
#' Converts a data.frame to network edgelist format by specifying which columns
#' represent source and target nodes. This is useful for creating edgelists from
#' tabular data where node relationships are stored in columns.
#'
#' @param input_object A data.frame containing network information
#' @param source_cols Column index or indices for source nodes (default: 1)
#' @param target_cols Column index or indices for target nodes (default: 2)
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with two columns: 'source' and 'target', representing edges
#' @export
#'
#' @examples
#' # Course prerequisite network
#' courses <- data.frame(
#'   course = c("stat101", "stat102", "stat202"),
#'   prereq = c("math101", "stat101", "stat101")
#' )
#' edges_df <- edges(courses)
#' edges_df
#'
#' # Specify custom columns
#' edges_custom <- edges(courses, source_cols = 2, target_cols = 1)
#' edges_custom
edges.data.frame <- function(input_object, source_cols = c(1), target_cols = c(2), ...){
  df <- data.frame(source = rep(unlist(input_object[,source_cols]), length(target_cols)),
                   target = unlist(input_object[,target_cols]))
  return(df)
}

#' Default Edge Extraction Method
#'
#' Default method that is called when no specific method is implemented for
#' the input object type. Prints an informative message to the user.
#'
#' @param input_object An object for which no specific edges method exists
#' @param ... Additional arguments (currently unused)
#'
#' @returns NULL (invisibly). Prints a message to console.
#' @export
#'
#' @examples
#' # Attempting to extract edges from unsupported object type
#' edges(list(a = 1, b = 2))
edges.default <- function(input_object, ...){
  message("edges() method not implemented for object of class: ",
          paste(class(input_object), collapse = ", "))
  invisible(NULL)
}

