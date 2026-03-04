#' Extract Edgelist from rpart Model
#'
#' Converts an rpart model object into a network edgelist representation.
#' The rpart package uses binary heap numbering for node IDs
#' (root = 1, left child of k = 2k, right child of k = 2k + 1), so
#' parent-child edges are derived directly from the node IDs in
#' \code{rownames(input_object$frame)}.
#'
#' Edge labels come from \code{labels(input_object, collapse = TRUE)},
#' which correctly handles the \code{ncat} sign that controls split
#' direction (left child does not always get \code{"<"}).
#'
#' @param input_object An rpart model object from the rpart package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node ID (binary heap index)}
#'     \item{to}{Child node ID (binary heap index)}
#'     \item{label}{Split condition label from \code{labels()}}
#'     \item{split_var}{Variable name used for the split}
#'     \item{split_op}{Operator: \code{"<"} or \code{">="} for numeric splits,
#'       \code{NA} for categorical splits}
#'     \item{split_point}{Numeric threshold for the split (\code{NA} for
#'       categorical splits)}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("rpart", quietly = TRUE)) {
#'   fit <- rpart::rpart(Species ~ ., data = iris)
#'   el <- edgelist(fit)
#'   head(el)
#'
#'   # Parsed split components
#'   el[, c("split_var", "split_op", "split_point")]
#' }
edgelist.rpart <- function(input_object, ...) {
  if (!requireNamespace("rpart", quietly = TRUE)) {
    stop("Package 'rpart' is required. Install it with install.packages('rpart').")
  }

  frame <- input_object$frame

  # rpart uses binary heap node IDs: root = 1, left = 2k, right = 2k + 1
  node_ids <- as.integer(rownames(frame))

  # Stump (root only, no splits) → return 0-row data.frame
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

  # Get edge labels from labels() — handles ncat sign correctly
  lbl_all <- labels(input_object, collapse = TRUE)
  names(lbl_all) <- as.character(node_ids)
  label <- lbl_all[as.character(child_ids)]

  # Parent's split variable from frame$var
  row_lookup <- match(parent_ids, node_ids)
  split_var <- as.character(frame$var[row_lookup])

  # Parse split_op and split_point from the label string
  # Numeric splits look like "Start>=14.5" or "Start< 9.5"
  # Categorical splits look like "color=a,b,c"
  split_op <- rep(NA_character_, length(label))
  split_point <- rep(NA_real_, length(label))

  is_ge <- grepl(">=", label, fixed = TRUE)
  is_lt <- grepl("<", label, fixed = TRUE) & !is_ge
  split_op[is_lt] <- "<"
  split_op[is_ge] <- ">="
  split_point[is_lt] <- as.numeric(sub(".*< *", "", label[is_lt]))
  split_point[is_ge] <- as.numeric(sub(".*>= *", "", label[is_ge]))

  data.frame(
    from = parent_ids,
    to = child_ids,
    label = unname(label),
    split_var = split_var,
    split_op = split_op,
    split_point = split_point,
    stringsAsFactors = FALSE
  )
}
