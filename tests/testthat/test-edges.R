# Test suite for edges() generic and methods

test_that("edges.randomForest produces data frame with expected structure", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(Species ~ ., data = iris, ntree = 3)
  edgelist <- edges(rf)

  expect_s3_class(edgelist, "data.frame")
  expect_true(nrow(edgelist) > 0)
  expect_true(all(c("source", "target", "treenum") %in% names(edgelist)))
  expect_equal(length(unique(edgelist$treenum)), 3)
})

test_that("edges.randomForest includes split variable names", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(mpg ~ cyl + disp + hp, data = mtcars, ntree = 2)
  edgelist <- edges(rf)

  expect_true("split_var_name" %in% names(edgelist))
  expect_s3_class(edgelist$split_var_name, "factor")
})

test_that("edges.data.frame method returns data frame with source and target", {
  df <- data.frame(
    course = c("stat101", "stat102", "stat202", "math102", "data202", "math101"),
    prereq = c("math101", "stat101", "stat101", NA, NA, NA),
    crosslist = c(NA, "math102", "data202", "stat102", "stat202", NA)
  )
  edgelist <- edges(df)

  expect_s3_class(edgelist, "data.frame")
  expect_true(all(c("source", "target") %in% names(edgelist)))
  expect_equal(nrow(edgelist), 6)
})

test_that("edges.data.frame handles custom source and target columns", {
  df <- data.frame(
    from = c("A", "B", "C"),
    to = c("B", "C", "D")
  )
  edgelist <- edges(df, source_cols = 1, target_cols = 2)

  expect_s3_class(edgelist, "data.frame")
  expect_equal(edgelist$source, c("A", "B", "C"))
  expect_equal(edgelist$target, c("B", "C", "D"))
})

test_that("edges.tree produces data frame with from, to, label columns", {
  skip_if_not_installed("tree")
  library(tree)

  tr <- tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  edgelist <- edges(tr)

  expect_s3_class(edgelist, "data.frame")
  expect_true(all(c("from", "to", "label") %in% names(edgelist)))
  expect_true(nrow(edgelist) > 0)
})

test_that("edges.default returns NULL with message for unsupported types", {
  expect_message(
    result <- edges(list(a = 1, b = 2)),
    "edges\\(\\) method not implemented"
  )
  expect_null(result)
})

test_that("edges generic dispatches to correct method", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(Species ~ ., data = iris, ntree = 1)
  df <- data.frame(from = 1:3, to = 2:4)

  # Should dispatch to edges.randomForest
  rf_result <- edges(rf)
  expect_true("treenum" %in% names(rf_result))

  # Should dispatch to edges.data.frame
  df_result <- edges(df)
  expect_true("source" %in% names(df_result))
})

test_that("edges.randomForest handles single tree forest", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf_single <- randomForest(Species ~ ., data = iris, ntree = 1)
  edgelist <- edges(rf_single)

  expect_s3_class(edgelist, "data.frame")
  expect_equal(unique(edgelist$treenum), 1)
  expect_true(all(edgelist$source < edgelist$target | edgelist$source == edgelist$target))
})

test_that("edges.randomForest validates model structure", {
  skip_if_not_installed("randomForest")
  library(randomForest)

  rf <- randomForest(mpg ~ ., data = mtcars, ntree = 2)
  edgelist <- edges(rf)

  # Check all edges have valid source and target
  expect_true(all(!is.na(edgelist$source)))
  expect_true(all(!is.na(edgelist$target)))
  expect_true(all(edgelist$source > 0))
  expect_true(all(edgelist$target > 0))
})

test_that("edges.tree validates tree structure", {
  skip_if_not_installed("tree")
  library(tree)

  tr <- tree(Species ~ ., data = iris)
  edgelist <- edges(tr)

  # Edges should form a valid tree (n_nodes = n_edges + 1)
  n_nodes <- length(unique(c(edgelist$from, edgelist$to)))
  n_edges <- nrow(edgelist)
  expect_equal(n_nodes, n_edges + 1)

  # All labels should be non-empty
  expect_true(all(nchar(edgelist$label) > 0))
})

test_that("edges.data.frame handles NA values appropriately", {
  df_with_na <- data.frame(
    source = c("A", "B", NA, "D"),
    target = c("B", "C", "D", NA)
  )
  edgelist <- edges(df_with_na)

  expect_s3_class(edgelist, "data.frame")
  expect_equal(nrow(edgelist), 4)
  # NAs should be preserved in the output
  expect_true(any(is.na(edgelist$source)))
  expect_true(any(is.na(edgelist$target)))
})

test_that("edges.data.frame handles multiple target columns", {
  df_multi <- data.frame(
    course = c("stat101", "stat102"),
    prereq1 = c("math101", "stat101"),
    prereq2 = c("comp101", "math102")
  )
  edgelist <- edges(df_multi, source_cols = 1, target_cols = c(2, 3))

  expect_s3_class(edgelist, "data.frame")
  expect_equal(nrow(edgelist), 4) # 2 courses * 2 prerequisites each
  expect_true(all(c("source", "target") %in% names(edgelist)))
})
