#' Title
#'
#' @param input_object
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
nodes <- function(input_object, ...){UseMethod("nodes")}

#' Title
#'
#' @param input_object
#' @param id_col
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
nodes.data.frame <- function(input_object, id_col = 1, ...){
  # make id_col the first column
  input_object[,c(id_col, setdiff(1:ncol(input_object), id_col))]
  #works for number rn - make work for string


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
nodes.random.foret <- function(input_object, ...){

}
