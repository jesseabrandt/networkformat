#' Title
#'
#' @param input_object
#' @param ...
#'
#' @returns
#' @export
#'
#' @examples
nodelist <- function(input_object, ...){UseMethod("nodelist")}

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
#' @importFrom dplyr relocate
nodelist.data.frame <- function(input_object, id_col = 1){

  relocate(input_object, {{id_col}})

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
nodelist.random.forest <- function(input_object, ...){

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
nodelist.default <- function(input_object, ...){
  print("nodelist method not implemented for this object type")
}
