#' Extracts edgelist from various object types
#'
#' @param input_object
#' @param ...
#'
#' @returns data.frame representing edgelist
#' @export
#'
#' @examples
edgelist <- function(input_object, ...) {UseMethod("edgelist")}


#' Title
#'
#' @param input_object
#' @param source_cols contains the column(s) in the input data.frame that represent the source nodes in the edgelist.
#' @param target_cols contains the column(s) in the input data.frame that represent the target nodes in the edgelist.
#' @param ...
#'
#' @details Edges will go from all source nodes to all target nodes. If you have multiple source columns that each have their respective target columns, you'll need to call this function twice and bind the results together.
#'
#' @returns
#' @export
#'
#' @examples
#' @importFrom tidyselect eval_select
#' @importFrom rlang enquo
edgelist.data.frame <- function(input_object, source_cols = c(1), target_cols = c(2), ...){

  source_cols <- eval_select(enquo(source_cols), input_object)
  target_cols <- eval_select(enquo(target_cols), input_object)

  df <- data.frame(source = rep(unlist(input_object[,source_cols]), length(target_cols)),
                   target = unlist(input_object[,target_cols]))
  return(df)
}

#' Default Edgelist Function
#'
#' @param input_object object from which to extract edgelist
#' @param ...
#'
#' @details This function does nothing. If you have an object type you want to extract an edgelist from, maybe write a method or email the package maintainer.
#'
#' @returns input_object, unchanged
#' @export
#'
#' @examples
edgelist.default <- function(input_object, ...){
  print("edgelist method not implemented for this object type")
  return(input_object)
}

