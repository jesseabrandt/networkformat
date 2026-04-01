#' Extract Node List from XGBoost Model
#'
#' Extracts node-level attributes from an xgboost model via
#' \code{xgb.model.dt.tree()}.  Node IDs are globally unique strings
#' in \code{"Tree-Node"} format and match the \code{from}/\code{to}
#' columns produced by \code{\link{edgelist.xgb.Booster}}.
#'
#' @param input_object An xgboost model object (\code{xgb.Booster})
#' @param treenum Integer vector of 1-based tree numbers to extract
#'   (default: \code{NULL} extracts all trees).
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with one row per node and the following columns:
#'   \describe{
#'     \item{name}{Node ID string (\code{"Tree-Node"} format, matches
#'       edgelist from/to)}
#'     \item{is_leaf}{Logical: \code{TRUE} for leaf nodes}
#'     \item{feature}{Split variable name (\code{NA} for leaves)}
#'     \item{split}{Split threshold (\code{NA} for leaves)}
#'     \item{quality}{Information gain for splits, leaf score for leaves}
#'     \item{cover}{Cover (sum of second-order gradient)}
#'     \item{missing}{Node ID (\code{"Tree-Node"} format) where observations
#'       with missing values are routed; \code{NA} for leaves}
#'     \item{treenum}{1-based tree number}
#'     \item{label}{Display label: \code{"<feature>\\n< <threshold>"} for
#'       splits, rounded leaf score for leaves}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("xgboost", quietly = TRUE)) {
#'   data(agaricus.train, package = "xgboost")
#'   bst <- xgboost::xgboost(
#'     x = agaricus.train$data,
#'     y = factor(agaricus.train$label),
#'     max_depth = 2, nrounds = 2, nthreads = 1
#'   )
#'   nl <- nodelist(bst)
#'   head(nl)
#' }
nodelist.xgb.Booster <- function(input_object, treenum = NULL, ...) {
  if (!requireNamespace("xgboost", quietly = TRUE)) {
    stop("Package 'xgboost' is required. Install it with install.packages('xgboost').")
  }

  dt <- xgboost::xgb.model.dt.tree(model = input_object)

  # xgboost >= 2.0 renamed "Quality" to "Gain"
  if (is.null(dt$Quality) && !is.null(dt$Gain)) {
    dt$Quality <- dt$Gain
  }
  if (is.null(dt$Quality)) {
    stop("xgb.model.dt.tree() returned neither 'Quality' nor 'Gain' column; ",
         "check your xgboost version.")
  }

  if (nrow(dt) == 0L) {
    stop("xgb.model.dt.tree() returned no rows; the model may have no trees.")
  }

  # xgboost uses 0-based tree indices; our treenum is 1-based
  if (!is.null(treenum)) {
    n_trees <- max(dt$Tree) + 1L
    treenum_int <- .validate_treenum(treenum, n_trees)
    dt <- dt[dt$Tree %in% (treenum_int - 1L), ]
  }

  is_leaf <- dt$Feature == "Leaf"

  data.frame(
    name    = dt$ID,
    is_leaf = is_leaf,
    feature = ifelse(is_leaf, NA_character_, dt$Feature),
    split   = ifelse(is_leaf, NA_real_, dt$Split),
    quality = dt$Quality,
    cover   = dt$Cover,
    missing = if (!is.null(dt$Missing)) ifelse(is_leaf, NA_character_, dt$Missing) else NA_character_,
    treenum = dt$Tree + 1L,
    label   = ifelse(is_leaf,
                     as.character(round(dt$Quality, 4)),
                     paste0(dt$Feature, "\n< ", round(dt$Split, 2))),
    stringsAsFactors = FALSE
  )
}
