# Test suite for nodelist() generic and methods

test_that("nodelist.data.frame returns data.frame with reordered columns", {
  df <- data.frame(
    course = c("stat101", "stat102", "stat202", "math102", "data202", "math101"),
    prereq = c("math101", "stat101", "stat101", NA, NA, NA),
    crosslist = c(NA, "math102", "data202", "stat102", "stat202", NA)
  )
  nl <- nodelist(df)

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "course")
  expect_equal(ncol(nl), 3)
})

test_that("nodelist.data.frame respects id_col parameter", {
  df <- data.frame(
    name = c("Alice", "Bob", "Charlie"),
    id = c(1, 2, 3),
    age = c(25, 30, 35)
  )
  nl <- nodelist(df, id_col = 2)

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "id")
  expect_equal(names(nl), c("id", "name", "age"))
})

test_that("nodelist.data.frame maintains row order and data", {
  df <- data.frame(
    id = c("A", "B", "C"),
    value = c(10, 20, 30)
  )
  nl <- nodelist(df)

  expect_equal(nl$id, c("A", "B", "C"))
  expect_equal(nl$value, c(10, 20, 30))
  expect_equal(nrow(nl), 3)
})

test_that("nodelist.randomForest returns message about implementation", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(Species ~ ., data = iris, ntree = 2)

  expect_message(
    result <- nodelist(rf),
    "not fully implemented"
  )
  expect_null(result)
})

test_that("nodelist.data.frame handles single column data frame", {
  df_single <- data.frame(id = c("A", "B", "C"))
  nl <- nodelist(df_single)

  expect_s3_class(nl, "data.frame")
  expect_equal(ncol(nl), 1)
  expect_equal(names(nl), "id")
})

test_that("nodelist.data.frame preserves all columns", {
  df_multi <- data.frame(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie"),
    age = c(25, 30, 35),
    city = c("NYC", "SF", "LA")
  )
  nl <- nodelist(df_multi)

  expect_equal(ncol(nl), 4)
  expect_equal(names(nl)[1], "id")
  expect_true(all(c("name", "age", "city") %in% names(nl)))
})

test_that("nodelist.data.frame handles NA values in id column", {
  df_na <- data.frame(
    id = c("A", NA, "C"),
    value = c(1, 2, 3)
  )
  nl <- nodelist(df_na)

  expect_s3_class(nl, "data.frame")
  expect_equal(nrow(nl), 3)
  expect_true(any(is.na(nl[[1]])))
})

test_that("nodelist.data.frame with non-default id_col reorders correctly", {
  df <- data.frame(
    attr1 = letters[1:3],
    attr2 = LETTERS[1:3],
    id = 1:3,
    attr3 = c(TRUE, FALSE, TRUE)
  )
  nl <- nodelist(df, id_col = 3)

  expect_equal(names(nl)[1], "id")
  expect_equal(names(nl), c("id", "attr1", "attr2", "attr3"))
  expect_equal(nl$id, 1:3)
})
