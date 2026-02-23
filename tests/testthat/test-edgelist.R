# Test suite for edgelist() generic and methods

test_that("edgelist.randomForest produces data frame with expected structure", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(Species ~ ., data = iris, ntree = 3)
  el <- edgelist(rf)

  expect_s3_class(el, "data.frame")
  expect_true(nrow(el) > 0)
  expect_true(all(c("source", "target", "treenum") %in% names(el)))
  expect_equal(length(unique(el$treenum)), 3)
})

test_that("edgelist.randomForest includes split variable names", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(mpg ~ cyl + disp + hp, data = mtcars, ntree = 2)
  el <- edgelist(rf)

  expect_true("split_var_name" %in% names(el))
  expect_type(el$split_var_name, "character")
  expect_true(all(el$split_var_name %in% c("cyl", "disp", "hp")))
})

test_that("edgelist.data.frame method returns data frame with source and target", {
  el <- edgelist(courses)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("source", "target") %in% names(el)))
  expect_equal(nrow(el), 6)
})

test_that("edgelist.data.frame handles custom source and target columns", {
  df <- data.frame(
    from = c("A", "B", "C"),
    to = c("B", "C", "D")
  )
  el <- edgelist(df, source_cols = 1, target_cols = 2)

  expect_s3_class(el, "data.frame")
  expect_equal(el$source, c("A", "B", "C"))
  expect_equal(el$target, c("B", "C", "D"))
})

test_that("edgelist.tree produces data frame with from, to, label columns", {
  skip_if_not_installed("tree")
  library(tree)

  tr <- tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  el <- edgelist(tr)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to", "label") %in% names(el)))
  expect_true(nrow(el) > 0)
})

test_that("edgelist.default returns NULL with message for unsupported types", {
  expect_message(
    result <- edgelist(list(a = 1, b = 2)),
    "edgelist\\(\\) method not implemented"
  )
  expect_null(result)
})

test_that("edgelist generic dispatches to correct method", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(Species ~ ., data = iris, ntree = 1)
  df <- data.frame(from = 1:3, to = 2:4)

  # Should dispatch to edgelist.randomForest
  rf_result <- edgelist(rf)
  expect_true("treenum" %in% names(rf_result))

  # Should dispatch to edgelist.data.frame
  df_result <- edgelist(df)
  expect_true("source" %in% names(df_result))
})

test_that("edgelist.randomForest handles single tree forest", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf_single <- randomForest(Species ~ ., data = iris, ntree = 1)
  el <- edgelist(rf_single)

  expect_s3_class(el, "data.frame")
  expect_equal(unique(el$treenum), 1)
  expect_true(all(el$source < el$target | el$source == el$target))
})

test_that("edgelist.randomForest validates model structure", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(mpg ~ ., data = mtcars, ntree = 2)
  el <- edgelist(rf)

  # Check all edges have valid source and target
  expect_true(all(!is.na(el$source)))
  expect_true(all(!is.na(el$target)))
  expect_true(all(el$source > 0))
  expect_true(all(el$target > 0))
})

test_that("edgelist.tree validates tree structure", {
  skip_if_not_installed("tree")
  library(tree)

  tr <- tree(Species ~ ., data = iris)
  el <- edgelist(tr)

  # Edges should form a valid tree (n_nodes = n_edges + 1)
  n_nodes <- length(unique(c(el$from, el$to)))
  n_edges <- nrow(el)
  expect_equal(n_nodes, n_edges + 1)

  # All labels should be non-empty
  expect_true(all(nchar(el$label) > 0))
})

test_that("edgelist.data.frame handles NA values appropriately", {
  df_with_na <- data.frame(
    source = c("A", "B", NA, "D"),
    target = c("B", "C", "D", NA)
  )
  el <- edgelist(df_with_na)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 4)
  # NAs should be preserved in the output
  expect_true(any(is.na(el$source)))
  expect_true(any(is.na(el$target)))
})

test_that("edgelist.data.frame handles multiple target columns", {
  el <- edgelist(courses, source_cols = 2, target_cols = c(3, 4))

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 12) # 6 courses * 2 target columns
  expect_true(all(c("source", "target") %in% names(el)))
})

# --- tidyselect tests ---

test_that("edgelist.data.frame accepts bare column names", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 6)
  expect_equal(el$source, courses$course)
  expect_equal(el$target, courses$prereq)
})

test_that("edgelist.data.frame accepts string column names", {
  el <- edgelist(courses, source_cols = "course", target_cols = "prereq")

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 6)
  expect_equal(el$source, courses$course)
  expect_equal(el$target, courses$prereq)
})

test_that("edgelist.data.frame accepts multiple bare target columns", {
  el <- edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 12) # 6 courses * 2 target columns
  expect_true(all(c("source", "target") %in% names(el)))
})
