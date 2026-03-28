#' Extract Node List from rpart Model
#'
#' Extracts node-level attributes from an \code{rpart} model object.
#' Node IDs are the binary heap indices from \code{rownames(input_object$frame)}
#' and match the \code{from}/\code{to} values produced by
#' \code{\link{edgelist.rpart}}, so the two outputs can be passed directly to
#' \code{igraph::graph_from_data_frame()}.
#'
#' @param input_object An rpart model object from the \pkg{rpart} package
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with one row per node and the following columns:
#'   \describe{
#'     \item{name}{Integer node ID (binary heap index, matches edgelist from/to)}
#'     \item{var}{Split variable name, or \code{"<leaf>"} for terminal nodes}
#'     \item{n}{Number of observations routed to this node}
#'     \item{dev}{Deviance (impurity) at this node}
#'     \item{yval}{Predicted value (numeric for regression, character class label
#'       for classification)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{label}{Display label: \code{"<var>\\nn=<n>"} for internal nodes,
#'       \code{"<yval>\\nn=<n>"} for leaves}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("rpart", quietly = TRUE)) {
#'   fit <- rpart::rpart(Species ~ Sepal.Length + Sepal.Width, data = iris)
#'   nodelist(fit)
#'
#'   # Labels ready for plotting
#'   nodelist(fit)$label
#' }
nodelist.rpart <- function(input_object, ...) {
  if (!requireNamespace("rpart", quietly = TRUE)) {
    stop("Package 'rpart' is required. Install it with install.packages('rpart').")
  }

  frame <- input_object$frame
  is_leaf <- frame$var == "<leaf>"
  ids <- as.integer(rownames(frame))

  # For classification trees, decode yval to class name
  ylevels <- attr(input_object, "ylevels")
  if (!is.null(ylevels)) {
    yval <- ylevels[as.integer(frame$yval)]
  } else {
    yval <- frame$yval
  }

  result <- data.frame(
    name        = ids,
    var         = as.character(frame$var),
    n           = frame$n,
    dev         = frame$dev,
    yval        = yval,
    is_leaf     = is_leaf,
    depth       = .compute_depth(ids),
    wt          = frame$wt,
    complexity  = frame$complexity,
    ncompete    = frame$ncompete,
    nsurrogate  = frame$nsurrogate,
    dev_improvement = .compute_dev_improvement(ids, frame$dev, is_leaf),
    stringsAsFactors = FALSE
  )

  # Classification trees have yval2 matrix with counts, probs, nodeprob
  if (!is.null(ylevels) && !is.null(frame$yval2)) {
    yval2 <- frame$yval2
    n_classes <- length(ylevels)
    class_names_clean <- tolower(make.names(ylevels))

    # yval2 layout: yval | counts (n_classes) | probs (n_classes) | nodeprob
    # Column 1 is predicted class (already used above as yval)
    count_cols <- seq(2, 1 + n_classes)
    prob_cols  <- seq(2 + n_classes, 1 + 2 * n_classes)
    nodeprob_col <- 2 + 2 * n_classes

    for (i in seq_len(n_classes)) {
      result[[paste0("n_", class_names_clean[i])]] <- yval2[, count_cols[i]]
    }
    for (i in seq_len(n_classes)) {
      result[[paste0("prob_", class_names_clean[i])]] <- yval2[, prob_cols[i]]
    }
    result$nodeprob <- yval2[, nodeprob_col]
  }

  # Label stays last
  result$label <- ifelse(is_leaf,
                         paste0(yval, "\nn=", frame$n),
                         paste0(as.character(frame$var), "\nn=", frame$n))

  result
}
