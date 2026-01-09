#' Title
#'
#' @param input_object
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
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
