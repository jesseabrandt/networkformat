#' Extract Edgelist from Tree Model
#'
#' Converts a tree model object (from the tree package) into a network edgelist
#' representation. The tree package uses binary heap numbering for node IDs
#' (root = 1, left child of k = 2k, right child of k = 2k + 1), so
#' parent-child edges are derived directly from the node IDs in
#' \code{rownames(input_object$frame)}.
#'
#' @param input_object A tree model object from the tree package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node ID (binary heap index)}
#'     \item{to}{Child node ID (binary heap index)}
#'     \item{label}{Split condition label (variable and threshold)}
#'     \item{split_var}{Variable name used for the split}
#'     \item{split_op}{Operator: \code{"<"} or \code{">"} for numeric splits,
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
  if (!requireNamespace("tree", quietly = TRUE)) {
    stop("Package 'tree' is required. Install it with install.packages('tree').")
  }

  df <- input_object$frame

  # tree uses binary heap node IDs: root = 1, left = 2k, right = 2k + 1
  node_ids <- as.integer(rownames(df))

  # Stump: single root node with no children
  if (length(node_ids) <= 1L) {
    return(data.frame(
      from = integer(0), to = integer(0),
      label = character(0), split_var = character(0),
      split_op = character(0), split_point = numeric(0),
      stringsAsFactors = FALSE
    ))
  }

  # Every non-root node's parent is node_id %/% 2
  child_ids <- node_ids[node_ids != 1L]
  parent_ids <- child_ids %/% 2L
  is_left <- child_ids %% 2L == 0L

  # Build a lookup: node_id -> row index in df
  row_lookup <- match(parent_ids, node_ids)

  # Build label and parsed split columns
  split_var <- as.character(df$var[row_lookup])

  # Left child (even) gets cutleft (col 1), right child (odd) gets cutright (col 2)
  split_str <- ifelse(is_left,
                      df$splits[row_lookup, 1],
                      df$splits[row_lookup, 2])

  # Categorical splits start with ":"
  is_cat <- grepl("^:", split_str)
  label <- ifelse(is_cat,
                  paste0(split_var, split_str),
                  paste(split_var, split_str))

  # Parse operator and threshold from the split string
  # Numeric splits look like "<5.45" or ">3.35"
  # Categorical splits look like ":abc"
  split_op <- rep(NA_character_, length(split_str))
  split_point <- rep(NA_real_, length(split_str))

  is_lt <- grepl("^<", split_str)
  is_gt <- grepl("^>", split_str)
  split_op[is_lt] <- "<"
  split_op[is_gt] <- ">"
  split_point[is_lt] <- as.numeric(sub("^<", "", split_str[is_lt]))
  split_point[is_gt] <- as.numeric(sub("^>", "", split_str[is_gt]))

  data.frame(
    from = parent_ids,
    to = child_ids,
    label = label,
    split_var = split_var,
    split_op = split_op,
    split_point = split_point,
    stringsAsFactors = FALSE
  )
}
