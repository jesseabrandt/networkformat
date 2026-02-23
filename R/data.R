#' Course prerequisite and crosslisting network
#'
#' A small dataset of six university courses with prerequisite and
#' crosslisting relationships, suitable for demonstrating \code{edgelist()}
#' and \code{nodelist()}.
#'
#' @format A data.frame with 6 rows and 6 columns:
#' \describe{
#'   \item{dept}{Department code (STAT, MATH, DATA)}
#'   \item{course}{Course identifier, used as node ID}
#'   \item{prereq}{Prerequisite course (NA if none)}
#'   \item{crosslist}{Crosslisted equivalent course (NA if none)}
#'   \item{credits}{Number of credit hours (integer)}
#'   \item{level}{Course level: 100 or 200 (integer)}
#' }
#'
#' @examples
#' # Prerequisite edgelist (course -> prereq)
#' edgelist(courses, source_cols = course, target_cols = prereq)
#'
#' # Node list with course as ID column
#' nodelist(courses, id_col = course)
"courses"
