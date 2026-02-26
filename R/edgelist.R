#' Extract Edgelist from Various Object Types
#'
#' Generic function to extract a network edgelist from various object types.
#' Methods exist for atomic vectors (sequential edges), data frames
#' (column-pair edges), and tree-based model objects (\code{randomForest},
#' \code{tree}).  The specific columns returned depend on the input type.
#'
#' @param input_object An object to extract an edgelist from
#' @param ... Additional arguments passed to specific methods
#'
#' @returns A data.frame representing an edgelist. The specific columns depend
#'   on the input object type.
#' @export
#'
#' @examples
#' # Vector --- sequential edges
#' edgelist(c("A", "B", "C", "D"))
#'
#' # Data.frame example using bundled dataset
#' edgelist(courses)
#'
#' # RandomForest example
#' if (requireNamespace("randomForest", quietly = TRUE)) {
#'   rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 10)
#'   edges_rf <- edgelist(rf)
#'   head(edges_rf)
#' }
#'
#' # Tree example
#' if (requireNamespace("tree", quietly = TRUE)) {
#'   tr <- tree::tree(Species ~ ., data = iris)
#'   edges_tr <- edgelist(tr)
#'   head(edges_tr)
#' }
edgelist <- function(input_object, ...) {UseMethod("edgelist")}
