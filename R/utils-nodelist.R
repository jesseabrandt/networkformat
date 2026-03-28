# Internal helpers for nodelist enrichment
# Not exported — used by nodelist.tree() and nodelist.rpart()

#' Compute tree depth from binary heap node IDs
#' @param ids Integer vector of binary heap node IDs (root = 1)
#' @returns Integer vector of depths (root = 0)
#' @noRd
.compute_depth <- function(ids) {
  as.integer(floor(log2(ids)))
}

#' Compute deviance improvement for each internal node
#'
#' For internal nodes: node_dev - left_child_dev - right_child_dev.
#' Leaves get NA.
#'
#' @param ids Integer vector of binary heap node IDs
#' @param devs Numeric vector of deviance values (same order as ids)
#' @param is_leaf Logical vector (same order as ids)
#' @returns Numeric vector (NA for leaves)
#' @noRd
.compute_dev_improvement <- function(ids, devs, is_leaf) {
  # Build lookup: id -> deviance
  dev_lookup <- stats::setNames(devs, as.character(ids))

  result <- rep(NA_real_, length(ids))
  for (i in seq_along(ids)) {
    if (!is_leaf[i]) {
      left_id  <- as.character(2L * ids[i])
      right_id <- as.character(2L * ids[i] + 1L)
      left_dev  <- dev_lookup[left_id]
      right_dev <- dev_lookup[right_id]
      if (!is.na(left_dev) && !is.na(right_dev)) {
        result[i] <- devs[i] - left_dev - right_dev
      }
    }
  }
  result
}
