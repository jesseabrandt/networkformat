test_that("placeholder", {
  expect_equal(2 * 2, 4)
})

test_that("edges on randomForest produces data frame", {
  # skip_if_not_installed("randomForest")
  library(randomForest)#simplify?
  rf <- randomForest(mpg ~ ., data = mtcars)
  edgelist <- edges(rf)
  expect_s3_class(edgelist, "data.frame")
})

test_that("edges data.frame method returns df", {
  df <- data.frame(course = c("stat101", "stat102", "stat202", "math102", "data202", "math101"),
                   prereq = c("math101", "stat101", "stat101", NA, NA, NA),
                   crosslist = c(NA, "math102", "data202", "stat102", "stat202", NA))
  edgelist <- edges.data.frame(df)
  # expect_null(result)
  expect_s3_class(edgelist, "data.frame")
})
