#' Extracts edgelist from various object types
#'
#' @param input_object
#' @param ...
#'
#' @returns data.frame representing edgelist
#' @export
#'
#' @examples
edges <- function(input_object, ...) {UseMethod("edges")}


#' Title
#'
#' @param input_object
#' @param source_cols
#' @param target_cols
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
edges.data.frame <- function(input_object, source_cols = c(1), target_cols = c(2), ...){
  df <- data.frame(source = rep(unlist(input_object[,source_cols]), length(target_cols)),
                   target = unlist(input_object[,target_cols]))
  return(df)
}

#' Title
#'
#' @param input_object
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
edges.default <- function(input_object, ...){
  print("edges method not implemented for this object type")
}

