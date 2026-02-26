#' Extract Edgelist from Tree Model
#'
#' Converts a tree model object (from the tree package) into a network edgelist
#' representation. Uses a parent-stack algorithm to traverse the binary tree
#' structure and construct parent-child relationships. Each edge is labeled
#' with the split condition and parsed into component columns.
#'
#' @param input_object A tree model object from the tree package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node index}
#'     \item{to}{Child node index}
#'     \item{label}{Split condition label (variable and threshold)}
#'     \item{split_var}{Variable name used for the split}
#'     \item{split_op}{Operator: \code{"<"} or \code{">="} for numeric splits,
#'       \code{NA} for categorical splits}
#'     \item{split_point}{Numeric threshold for the split (\code{NA} for
#'       categorical splits)}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("tree", quietly = TRUE)) {
#'   # Fit a classification tree
#'   tree_model <- tree::tree(Species ~ ., data = iris)
#'
#'   # Extract edgelist
#'   tree_edges <- edgelist(tree_model)
#'   head(tree_edges)
#'
#'   # Parsed split components
#'   tree_edges[, c("split_var", "split_op", "split_point")]
#' }
edgelist.tree <- function(input_object, ...){
  df <- input_object$frame
  n <- nrow(df)

  # Pre-allocate edge vectors (a binary tree with n nodes has n-1 edges)
  n_edges <- n - 1L
  edge_from <- integer(n_edges)
  edge_to   <- integer(n_edges)
  edge_idx  <- 0L

  df$index <- seq_len(n)
  is_leaf <- df$var == "<leaf>"

  parent_stack <- c()
  children_count <- c()

  for (i in seq_len(n)){
    # If we have a parent waiting for children
    if (length(parent_stack) > 0) {
      parent_row <- parent_stack[length(parent_stack)]
      parent_idx <- df$index[parent_row]

      edge_idx <- edge_idx + 1L
      edge_from[edge_idx] <- parent_idx
      edge_to[edge_idx]   <- i

      # Increment children count for this parent
      children_count[length(children_count)] <- children_count[length(children_count)] + 1

      # If parent has both children, pop it from stack
      if (children_count[length(children_count)] == 2) {
        parent_stack <- parent_stack[-length(parent_stack)]
        children_count <- children_count[-length(children_count)]
      }
    }

    #add current node to parent stack and indicate 0 children
    if(!is_leaf[i]){
      parent_stack <- c(parent_stack, i)
      children_count <- c(children_count, 0)
    }
  }

  edges <- data.frame(from = edge_from, to = edge_to)

  ### NOW add labels and parsed split columns
  edges$label <- NA_character_
  edges$split_var <- NA_character_
  edges$split_op <- NA_character_
  edges$split_point <- NA_real_

  for (i in seq_len(nrow(edges))) {
    parent_node <- edges$from[i]
    child_node <- edges$to[i]
    var <- as.character(df$var[parent_node])

    # Left child (even index) gets column 1, right child (odd) gets column 2
    split_str <- ifelse(child_node %% 2 == 0,
                        df$splits[parent_node, 1],
                        df$splits[parent_node, 2])

    # Categorical splits start with ":" — use paste0 to avoid extra space
    if (grepl("^:", split_str)) {
      edges$label[i] <- paste0(var, split_str)
    } else {
      edges$label[i] <- paste(var, split_str)
    }
    edges$split_var[i] <- var

    # Parse operator and threshold from the split string
    # Numeric splits look like "<5.45" or ">=3.35"
    # Categorical splits look like ":abc" or ":adf"
    if (grepl("^<", split_str)) {
      edges$split_op[i] <- "<"
      edges$split_point[i] <- as.numeric(sub("^<", "", split_str))
    } else if (grepl("^>=", split_str)) {
      edges$split_op[i] <- ">="
      edges$split_point[i] <- as.numeric(sub("^>=", "", split_str))
    }
    # else: categorical split — op and point remain NA
  }
  return(edges)
}
