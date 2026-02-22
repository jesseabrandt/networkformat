#' Extract Edgelist from Tree Model
#'
#' Converts a tree model object (from the tree package) into a network edgelist
#' representation. Uses a parent-stack algorithm to traverse the binary tree
#' structure and construct parent-child relationships. Each edge is labeled
#' with the split condition.
#'
#' @param input_object A tree model object from the tree package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node index}
#'     \item{to}{Child node index}
#'     \item{label}{Split condition label (variable and threshold)}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("tree", quietly = TRUE)) {
#'   # Fit a classification tree
#'   tree_model <- tree::tree(Species ~ ., data = iris)
#'
#'   # Extract edgelist
#'   tree_edges <- edges(tree_model)
#'   head(tree_edges)
#'
#'   # View edge labels (split conditions)
#'   tree_edges$label
#'
#'   # Visualize with base R (if desired)
#'   # plot(tree_model)
#'   # text(tree_model)
#' }
edges.tree <- function(input_object, ...){
  df <- input_object$frame

  #initialize empty edge list
  edges <- data.frame(from = integer(0), to = integer(0))#efficiency?
  n <- nrow(df)


  # construct edges labelled w rownums

  df$index <- c(1:n)

  is_leaf <- df$var == "<leaf>"

  parent_stack <- c()
  children_count <- c()

  for (i in 1:n){
    # If we have a parent waiting for children
    if (length(parent_stack) > 0) {
      parent_row <- parent_stack[length(parent_stack)]
      parent_idx <- df$index[parent_row]


      edges <- rbind(edges, data.frame(
        from = parent_idx,
        to = i
      ))

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


  ### NOW add labels
  edges$label <- NA
  for (i in 1:nrow(edges)) {
    parent_node <- edges$from[i]
    child_node <- edges$to[i]
    var <- df$var[parent_node]
    split <- df$splits[parent_node]

    edges$label[i] <- ifelse(child_node %% 2 == 0,
                             paste(var, df$splits[parent_node,1]),
                             paste(var, df$splits[parent_node,2]))

  }
  return(edges)
}
