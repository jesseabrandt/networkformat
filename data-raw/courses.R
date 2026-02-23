## code to prepare `courses` dataset

courses <- data.frame(
  dept      = c("STAT",    "STAT",    "STAT",    "MATH",    "MATH",    "DATA"),
  course    = c("stat101", "stat102", "stat202", "math101", "math102", "data202"),
  prereq    = c("math101", "stat101", "stat101", NA,        "stat101", "stat101"),
  crosslist = c(NA,        "math102", "data202", NA,        "stat102", "stat202"),
  credits   = c(3L,        4L,        3L,        3L,        4L,        3L),
  level     = c(100L,      100L,      200L,      100L,      100L,      200L),
  stringsAsFactors = FALSE
)

save(courses, file = "data/courses.rda")
