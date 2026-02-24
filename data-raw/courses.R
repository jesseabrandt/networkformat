## code to prepare `courses` dataset

courses <- data.frame(
  dept      = c("STAT",    "STAT",    "STAT",    "MATH",    "MATH",    "DATA",
                "CS",      "CS",      "CS",      "MATH",    "MATH",    "DATA",    "STAT"),
  course    = c("stat101", "stat102", "stat202", "math101", "math102", "data202",
                "cs101",   "cs201",   "cs301",   "math201", "math301", "data301", "stat301"),
  prereq    = c("math101", "stat101", "stat101", NA,        "stat101", "stat101",
                NA,        "cs101",   "cs201",   "math101", "cs201",   "stat202", "stat202"),
  prereq2   = c(NA,        NA,        NA,        NA,        NA,        NA,
                NA,        NA,        "math201", NA,        "math201", "cs201",   "cs201"),
  crosslist = c(NA,        "math102", "data202", NA,        "stat102", "stat202",
                NA,        NA,        "math301", NA,        "cs301",   "stat301", "data301"),
  credits   = c(3L,        4L,        3L,        3L,        4L,        3L,
                3L,        4L,        3L,        3L,        4L,        3L,        4L),
  level     = c(100L,      100L,      200L,      100L,      100L,      200L,
                100L,      200L,      300L,      200L,      300L,      300L,      300L),
  stringsAsFactors = FALSE
)

save(courses, file = "data/courses.rda")
