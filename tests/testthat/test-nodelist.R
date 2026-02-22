test_that("nodelist returns data.frame from data.frame input", {
  df <- data.frame(course = c("stat101", "stat102", "stat202", "math102", "data202", "math101"),
                   prereq = c("math101", "stat101", "stat101", NA, NA, NA),
                   crosslist = c(NA, "math102", "data202", "stat102", "stat202", NA))
  nodelist <- nodelist(df)
  expect_s3_class(nodelist, "data.frame")
})
