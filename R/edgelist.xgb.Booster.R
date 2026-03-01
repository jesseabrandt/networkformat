#' Extract Edgelist from XGBoost Model
#'
#' Converts an xgboost model object into a network edgelist representation
#' using \code{xgb.model.dt.tree()}.  Each edge connects a split node to
#' one of its two children (yes/no branches).  Node IDs are globally unique
#' strings in \code{"Tree-Node"} format (e.g., \code{"0-3"}).
#'
#' @param input_object An xgboost model object (\code{xgb.Booster})
#' @param treenum Integer vector of 1-based tree numbers to extract
#'   (default: \code{NULL} extracts all trees).
#' @param ... Additional arguments (currently unused)
#'
#' @returns A data.frame with the following columns:
#'   \describe{
#'     \item{from}{Parent node ID string (\code{"Tree-Node"} format)}
#'     \item{to}{Child node ID string}
#'     \item{feature}{Name of the split variable (or 0-based index string
#'       when feature names are absent)}
#'     \item{split}{Numeric split threshold}
#'     \item{quality}{Information gain at the split}
#'     \item{cover}{Number of observations covered}
#'     \item{treenum}{1-based tree number}
#'   }
#' @export
#'
#' @examples
#' if (requireNamespace("xgboost", quietly = TRUE)) {
#'   data(agaricus.train, package = "xgboost")
#'   bst <- xgboost::xgboost(
#'     data = agaricus.train$data,
#'     label = agaricus.train$label,
#'     max_depth = 2, nrounds = 2,
#'     objective = "binary:logistic", verbose = 0
#'   )
#'   el <- edgelist(bst)
#'   head(el)
#' }
edgelist.xgb.Booster <- function(input_object, treenum = NULL, ...) {
  if (!requireNamespace("xgboost", quietly = TRUE)) {
    stop("Package 'xgboost' is required. Install it with install.packages('xgboost').")
  }

  dt <- xgboost::xgb.model.dt.tree(model = input_object)

  # xgboost uses 0-based tree indices; our treenum is 1-based
  if (!is.null(treenum)) {
    treenum_int <- as.integer(treenum)
    n_trees <- max(dt$Tree) + 1L
    if (!all(treenum_int >= 1L & treenum_int <= n_trees)) {
      stop("treenum must be between 1 and ", n_trees,
           "; got: ", paste(treenum, collapse = ", "))
    }
    dt <- dt[dt$Tree %in% (treenum_int - 1L), ]
  }

  # Filter to split (internal) nodes
  splits <- dt[dt$Feature != "Leaf", ]

  if (nrow(splits) == 0L) {
    return(data.frame(
      from = character(0), to = character(0),
      feature = character(0), split = numeric(0),
      quality = numeric(0), cover = numeric(0),
      treenum = integer(0),
      stringsAsFactors = FALSE
    ))
  }

  # Build edges: each split node produces two edges (yes and no)
  data.frame(
    from    = c(splits$ID, splits$ID),
    to      = c(splits$Yes, splits$No),
    feature = c(splits$Feature, splits$Feature),
    split   = c(splits$Split, splits$Split),
    quality = c(splits$Quality, splits$Quality),
    cover   = c(splits$Cover, splits$Cover),
    treenum = c(splits$Tree + 1L, splits$Tree + 1L),
    stringsAsFactors = FALSE
  )
}
