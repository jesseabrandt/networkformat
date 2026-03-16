# Test suite for nodelist() generic and methods

test_that("nodelist.data.frame returns data.frame with reordered columns", {
  nl <- nodelist(courses)

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "dept")
  expect_equal(ncol(nl), 7)
})

test_that("nodelist.data.frame respects id_col parameter", {
  nl <- nodelist(courses, id_col = 2)

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "course")
  expect_equal(names(nl), c("course", "dept", "prereq", "prereq2", "crosslist", "credits", "level"))
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

# --- nodelist.tree tests ---

test_that("nodelist.tree returns expected columns", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "var", "n", "dev", "yval", "is_leaf", "label") %in% names(nl)))
})

test_that("nodelist.tree node IDs match edgelist from/to", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)
  el <- edgelist(tr)

  edge_nodes <- sort(unique(c(el$from, el$to)))
  expect_true(all(edge_nodes %in% nl$name))
  expect_equal(nl$name, as.integer(rownames(tr$frame)))
})

test_that("nodelist.tree identifies leaves correctly", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_true(all(nl$var[nl$is_leaf] == "<leaf>"))
  expect_true(all(nl$var[!nl$is_leaf] != "<leaf>"))
})

test_that("nodelist.tree root node contains all observations", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_equal(nl$n[1], 150)  # iris has 150 rows
})

test_that("nodelist.tree works for regression trees", {
  skip_if_not_installed("tree")

  tr <- tree::tree(mpg ~ cyl + disp + hp, data = mtcars)
  nl <- nodelist(tr)

  expect_s3_class(nl, "data.frame")
  expect_type(nl$yval, "double")
  expect_equal(nl$n[1], 32)  # mtcars has 32 rows
})

test_that("nodelist.tree yval is character for classification", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ ., data = iris)
  nl <- nodelist(tr)

  expect_type(nl$yval, "character")
  expect_true(all(nl$yval %in% c("setosa", "versicolor", "virginica")))
})

# --- nodelist.tree label tests ---

test_that("nodelist.tree label column has correct format", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_true("label" %in% names(nl))
  expect_type(nl$label, "character")

  # Internal nodes should show "var\nn=count"
  internal <- nl[!nl$is_leaf, ]
  for (i in seq_len(nrow(internal))) {
    expect_true(grepl(paste0("\\nn=", internal$n[i]), internal$label[i]))
    expect_true(startsWith(internal$label[i], internal$var[i]))
  }

  # Leaf nodes should show "yval\nn=count"
  leaves <- nl[nl$is_leaf, ]
  for (i in seq_len(nrow(leaves))) {
    expect_true(grepl(paste0("\\nn=", leaves$n[i]), leaves$label[i]))
    expect_true(startsWith(leaves$label[i], as.character(leaves$yval[i])))
  }
})

# --- nodelist.randomForest tests ---

test_that("nodelist.randomForest returns expected columns", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "is_leaf", "split_var", "split_var_name",
                     "split_point", "prediction", "treenum", "label") %in% names(nl)))
})

test_that("nodelist.randomForest has correct number of trees", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  nl <- nodelist(rf)

  expect_equal(length(unique(nl$treenum)), 3)
})

test_that("nodelist.randomForest node IDs match edgelist per tree", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)
  el <- edgelist(rf)

  for (tn in unique(nl$treenum)) {
    el_nodes <- sort(unique(c(
      el$from[el$treenum == tn],
      el$to[el$treenum == tn]
    )))
    nl_nodes <- nl$name[nl$treenum == tn]
    expect_true(all(el_nodes %in% nl_nodes))
  }
})

test_that("nodelist.randomForest leaves have NA split attributes", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  leaves <- nl[nl$is_leaf, ]
  expect_true(all(is.na(leaves$split_var)))
  expect_true(all(is.na(leaves$split_var_name)))
  expect_true(all(is.na(leaves$split_point)))
})

test_that("nodelist.randomForest works for regression", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(mpg ~ cyl + disp + hp, data = mtcars, ntree = 2)
  nl <- nodelist(rf)

  expect_s3_class(nl, "data.frame")
  expect_type(nl$prediction, "double")
  expect_true(all(na.omit(nl$split_var_name) %in% c("cyl", "disp", "hp")))
})

# --- nodelist.randomForest label tests ---

test_that("nodelist.randomForest label column exists", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  expect_true("label" %in% names(nl))
  expect_type(nl$label, "character")

  # Internal node labels include variable name and threshold
  internal <- nl[!nl$is_leaf, ]
  expect_true(all(grepl("\n< ", internal$label)))
  expect_true(all(startsWith(internal$label, internal$split_var_name)))

  # Leaf nodes should have class name as label (not numeric index)
  leaves <- nl[nl$is_leaf, ]
  expect_true(all(leaves$label %in% levels(iris$Species)))
})

# --- nodelist.randomForest treenum tests ---

test_that("nodelist.randomForest treenum extracts specific trees", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)

  nl1 <- nodelist(rf, treenum = 1)
  expect_equal(unique(nl1$treenum), 1)

  nl13 <- nodelist(rf, treenum = c(1, 3))
  expect_equal(sort(unique(nl13$treenum)), c(1, 3))
})

test_that("nodelist.randomForest treenum NULL returns all trees", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  nl_all <- nodelist(rf, treenum = NULL)
  nl_default <- nodelist(rf)
  expect_equal(nl_all, nl_default)
})

test_that("nodelist.randomForest treenum validates range", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  expect_error(nodelist(rf, treenum = 0), "treenum must be between")
  expect_error(nodelist(rf, treenum = 4), "treenum must be between")
  expect_error(nodelist(rf, treenum = integer(0)), "treenum must be between")
  expect_error(nodelist(rf, treenum = NA), "treenum must be between")
})

# --- nodelist.default tests ---

test_that("nodelist.default raises error for unsupported types", {
  expect_error(
    nodelist(as.formula(y ~ x)),
    "does not support"
  )
})

# --- nodelist.data.frame tests ---

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

# --- tidyselect tests ---

test_that("nodelist.data.frame accepts bare column name", {
  nl <- nodelist(courses, id_col = course)

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "course")
  expect_equal(names(nl), c("course", "dept", "prereq", "prereq2", "crosslist", "credits", "level"))
})

test_that("nodelist.data.frame accepts string column name", {
  nl <- nodelist(courses, id_col = "course")

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl)[1], "course")
})

test_that("nodelist.data.frame errors when id_col selects multiple columns", {
  expect_error(
    nodelist(courses, id_col = c(course, prereq)),
    "id_col must select exactly one column"
  )
})

# --- vector nodelist tests ---

test_that("nodelist on character vector returns unique values with counts", {
  nl <- nodelist(c("A", "B", "C", "A", "B"))

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl), c("name", "n"))
  expect_equal(nl$name, c("A", "B", "C"))
  expect_equal(nl$n, c(2L, 2L, 1L))
})

test_that("nodelist on numeric vector returns unique values with counts", {
  nl <- nodelist(c(1, 2, 3, 2, 1))

  expect_equal(nl$name, c(1, 2, 3))
  expect_equal(nl$n, c(2L, 2L, 1L))
})

test_that("nodelist on integer vector works", {
  nl <- nodelist(c(10L, 20L, 10L))

  expect_equal(nl$name, c(10L, 20L))
  expect_equal(nl$n, c(2L, 1L))
})

test_that("nodelist on vector preserves first-appearance order", {
  nl <- nodelist(c("C", "A", "B", "A", "C"))

  expect_equal(nl$name, c("C", "A", "B"))
})

test_that("nodelist on vector with all unique values has n = 1", {
  nl <- nodelist(c("X", "Y", "Z"))

  expect_equal(nl$n, c(1L, 1L, 1L))
})

test_that("nodelist on single-element vector works", {
  nl <- nodelist(c("A"))

  expect_equal(nrow(nl), 1)
  expect_equal(nl$name, "A")
  expect_equal(nl$n, 1L)
})

test_that("nodelist on empty vector returns zero-row data.frame", {
  nl <- nodelist(character(0))

  expect_s3_class(nl, "data.frame")
  expect_equal(nrow(nl), 0)
  expect_equal(names(nl), c("name", "n"))
})

test_that("nodelist on factor vector works", {
  nl <- nodelist(factor(c("a", "b", "a")))

  expect_equal(nrow(nl), 2)
  expect_equal(nl$n, c(2L, 1L))
})

test_that("nodelist on logical vector works", {
  nl <- nodelist(c(TRUE, FALSE, TRUE, TRUE))

  expect_equal(nl$name, c(TRUE, FALSE))
  expect_equal(nl$n, c(3L, 1L))
})

# --- nodelist.rpart tests ---

test_that("nodelist.rpart returns expected columns", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "var", "n", "dev", "yval", "is_leaf",
                     "label") %in% names(nl)))
})

test_that("nodelist.rpart node IDs match edgelist from/to", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)
  el <- edgelist(fit)

  edge_nodes <- sort(unique(c(el$from, el$to)))
  expect_true(all(edge_nodes %in% nl$name))
  expect_equal(nl$name, as.integer(rownames(fit$frame)))
})

test_that("nodelist.rpart identifies leaves correctly", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_true(all(nl$var[nl$is_leaf] == "<leaf>"))
  expect_true(all(nl$var[!nl$is_leaf] != "<leaf>"))
})

test_that("nodelist.rpart root node contains all observations", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_equal(nl$n[1], 150)
})

test_that("nodelist.rpart classification yval is character", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_type(nl$yval, "character")
  expect_true(all(nl$yval %in% c("setosa", "versicolor", "virginica")))
})

test_that("nodelist.rpart regression yval is numeric", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(mpg ~ cyl + disp + hp, data = mtcars)
  nl <- nodelist(fit)

  expect_type(nl$yval, "double")
  expect_equal(nl$n[1], 32)
})

test_that("nodelist.rpart label column has correct format", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  # Internal nodes: "var\nn=count"
  internal <- nl[!nl$is_leaf, ]
  for (i in seq_len(nrow(internal))) {
    expect_true(grepl(paste0("\\nn=", internal$n[i]), internal$label[i]))
    expect_true(startsWith(internal$label[i], internal$var[i]))
  }

  # Leaf nodes: "yval\nn=count"
  leaves <- nl[nl$is_leaf, ]
  for (i in seq_len(nrow(leaves))) {
    expect_true(grepl(paste0("\\nn=", leaves$n[i]), leaves$label[i]))
    expect_true(startsWith(leaves$label[i], as.character(leaves$yval[i])))
  }
})

test_that("nodelist.rpart stump returns single node", {
  skip_if_not_installed("rpart")

  stump <- rpart::rpart(Species ~ ., data = iris,
                         control = rpart::rpart.control(cp = 1))
  nl <- nodelist(stump)

  expect_equal(nrow(nl), 1)
  expect_true(nl$is_leaf)
})

# --- nodelist.xgb.Booster tests ---

test_that("nodelist.xgb.Booster returns expected columns", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)
  nl <- nodelist(bst)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "is_leaf", "feature", "split", "quality",
                     "cover", "treenum", "label") %in% names(nl)))
})

test_that("nodelist.xgb.Booster leaves have NA feature and split", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)
  nl <- nodelist(bst)

  leaves <- nl[nl$is_leaf, ]
  expect_true(all(is.na(leaves$feature)))
  expect_true(all(is.na(leaves$split)))
})

test_that("nodelist.xgb.Booster treenum filters correctly", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 5, verbose = 0)

  nl1 <- nodelist(bst, treenum = 1)
  expect_equal(unique(nl1$treenum), 1L)

  nl13 <- nodelist(bst, treenum = c(1, 3))
  expect_equal(sort(unique(nl13$treenum)), c(1L, 3L))
})

test_that("nodelist.xgb.Booster treenum validates range", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)

  expect_error(nodelist(bst, treenum = 0), "treenum must be between")
  expect_error(nodelist(bst, treenum = 10), "treenum must be between")
  expect_error(nodelist(bst, treenum = integer(0)), "treenum must be between")
  expect_error(nodelist(bst, treenum = NA), "treenum must be between")
})

test_that("nodelist.xgb.Booster node IDs match edgelist", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 3, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)

  nl <- nodelist(bst, treenum = 1)
  el <- edgelist(bst, treenum = 1)
  edge_nodes <- sort(unique(c(el$from, el$to)))
  expect_true(all(edge_nodes %in% nl$name))
})

test_that("nodelist.xgb.Booster label column exists", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)
  nl <- nodelist(bst)

  expect_true("label" %in% names(nl))
  expect_type(nl$label, "character")

  # Internal node labels include feature name and threshold
  internal <- nl[!nl$is_leaf, ]
  expect_true(all(grepl("\n< ", internal$label)))
  expect_true(all(startsWith(internal$label, internal$feature)))
})

test_that("nodelist.xgb.Booster leaf labels show rounded quality scores", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 2, verbose = 0)
  nl <- nodelist(bst)
  leaves <- nl[nl$is_leaf, ]

  # Leaf labels should be the rounded quality score as a string
  expected <- as.character(round(leaves$quality, 4))
  expect_equal(leaves$label, expected)
})

test_that("nodelist.xgb.Booster treenum NULL returns all trees", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  dtrain <- xgboost::xgb.DMatrix(data = agaricus.train$data,
                                   label = agaricus.train$label)
  bst <- xgboost::xgb.train(
    params = list(max_depth = 2, objective = "binary:logistic"),
    data = dtrain, nrounds = 3, verbose = 0)

  nl_all <- nodelist(bst)
  nl_1 <- nodelist(bst, treenum = 1)
  nl_2 <- nodelist(bst, treenum = 2)
  nl_3 <- nodelist(bst, treenum = 3)

  expect_equal(nrow(nl_all), nrow(nl_1) + nrow(nl_2) + nrow(nl_3))
  expect_equal(sort(unique(nl_all$treenum)), c(1L, 2L, 3L))
})

# --- nodelist.gbm tests ---

test_that("nodelist.gbm returns expected columns", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )
  nl <- nodelist(fit)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "is_leaf", "split_var", "split_var_name",
                     "split_point", "prediction", "treenum",
                     "label") %in% names(nl)))
})

test_that("nodelist.gbm excludes missing-sentinel nodes", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 3, n.minobsinnode = 3)
  )

  for (tn in 1:3) {
    nl_t <- nodelist(fit, treenum = tn)
    el_t <- edgelist(fit, treenum = tn)
    n_internal <- nrow(el_t) / 2
    # Real nodes = 2 * internal + 1
    expect_equal(nrow(nl_t), 2 * n_internal + 1)
  }
})

test_that("nodelist.gbm leaves have NA split attributes", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )
  nl <- nodelist(fit)

  leaves <- nl[nl$is_leaf, ]
  expect_true(all(is.na(leaves$split_var)))
  expect_true(all(is.na(leaves$split_var_name)))
  expect_true(all(is.na(leaves$split_point)))
})

test_that("nodelist.gbm treenum filters correctly", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 5, interaction.depth = 2, n.minobsinnode = 3)
  )

  nl1 <- nodelist(fit, treenum = 1)
  expect_equal(unique(nl1$treenum), 1L)

  nl13 <- nodelist(fit, treenum = c(1, 3))
  expect_equal(sort(unique(nl13$treenum)), c(1L, 3L))
})

test_that("nodelist.gbm treenum validates range", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )

  expect_error(nodelist(fit, treenum = 0), "treenum must be between")
  expect_error(nodelist(fit, treenum = 10), "treenum must be between")
  expect_error(nodelist(fit, treenum = integer(0)), "treenum must be between")
  expect_error(nodelist(fit, treenum = NA), "treenum must be between")
})

test_that("nodelist.gbm label column exists", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )
  nl <- nodelist(fit)

  expect_true("label" %in% names(nl))
  expect_type(nl$label, "character")

  # Internal node labels include variable name and threshold
  internal <- nl[!nl$is_leaf, ]
  expect_true(all(grepl("\n< ", internal$label)))
  expect_true(all(startsWith(internal$label, internal$split_var_name)))
})

test_that("nodelist.gbm leaf labels show rounded prediction values", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )
  nl <- nodelist(fit)
  leaves <- nl[nl$is_leaf, ]

  # Leaf labels should be the rounded prediction as a string
  expected <- as.character(round(leaves$prediction, 4))
  expect_equal(leaves$label, expected)
})

test_that("nodelist.gbm node IDs match edgelist", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 3, n.minobsinnode = 3)
  )

  for (tn in 1:3) {
    nl_t <- nodelist(fit, treenum = tn)
    el_t <- edgelist(fit, treenum = tn)
    edge_nodes <- sort(unique(c(el_t$from, el_t$to)))
    expect_true(all(edge_nodes %in% nl_t$name))
  }
})

test_that("nodelist.gbm treenum NULL returns all trees", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )

  nl_all <- nodelist(fit)
  nl_1 <- nodelist(fit, treenum = 1)
  nl_2 <- nodelist(fit, treenum = 2)
  nl_3 <- nodelist(fit, treenum = 3)

  expect_equal(nrow(nl_all), nrow(nl_1) + nrow(nl_2) + nrow(nl_3))
  expect_equal(sort(unique(nl_all$treenum)), c(1L, 2L, 3L))
})

# --- nodelist.list tests ---

test_that("nodelist.list simple named list returns correct nodes", {
  nl <- nodelist(list(a = 1, b = 2))

  expect_s3_class(nl, "data.frame")
  expect_equal(names(nl), c("name", "depth", "type", "n_children", "label"))
  # root + 2 children = 3

  expect_equal(nrow(nl), 3)
  expect_equal(nl$name[1], "root")
  expect_equal(nl$depth[1], 0L)
  expect_equal(nl$n_children[1], 2L)
  expect_equal(nl$type[2], "numeric")
  expect_equal(nl$n_children[2], 0L)
})

test_that("nodelist.list nested list counts nodes correctly", {
  nl <- nodelist(list(a = list(b = 1, c = 2), d = 3))

  # root, a, b, c, d = 5
  expect_equal(nrow(nl), 5)
  expect_equal(nl$type[nl$name == "root/a"], "list")
  expect_equal(nl$n_children[nl$name == "root/a"], 2L)
  expect_equal(nl$n_children[nl$name == "root/d"], 0L)
})

test_that("nodelist.list deeply nested verifies depth", {
  nl <- nodelist(list(a = list(b = list(c = 1))))

  expect_equal(nrow(nl), 4)
  expect_equal(nl$depth, 0:3)
})

test_that("nodelist.list unnamed elements use positional labels", {
  nl <- nodelist(list(1, 2))

  expect_equal(nl$label[2], "[[1]]")
  expect_equal(nl$label[3], "[[2]]")
})

test_that("nodelist.list empty list returns root-only row", {
  nl <- nodelist(list())

  expect_equal(nrow(nl), 1)
  expect_equal(nl$name, "root")
  expect_equal(nl$n_children, 0L)
})

test_that("nodelist.list reports correct type for varied elements", {
  nl <- nodelist(list(a = 1L, b = "text", c = TRUE, d = NULL, e = list()))

  types <- nl$type[nl$depth == 1L]
  expect_equal(types, c("integer", "character", "logical", "NULL", "list"))
})

test_that("nodelist.list max_depth limits node depth", {
  # list: root(0) -> a(1) -> b(2) -> c(3)
  x <- list(a = list(b = list(c = 1)))

  # max_depth = 0: root only
  nl0 <- nodelist(x, max_depth = 0)
  expect_equal(nrow(nl0), 1)
  expect_equal(nl0$name, "root")

  # max_depth = 1: root + depth-1 children
  nl1 <- nodelist(x, max_depth = 1)
  expect_equal(nrow(nl1), 2)
  expect_equal(max(nl1$depth), 1L)

  # max_depth = 2: root + depth 1 + depth 2
  nl2 <- nodelist(x, max_depth = 2)
  expect_equal(nrow(nl2), 3)
  expect_equal(max(nl2$depth), 2L)

  # max_depth = NULL (unlimited): all 4 nodes
  nl_all <- nodelist(x)
  expect_equal(nrow(nl_all), 4)
})

test_that("nodelist.list custom name_root", {
  nl <- nodelist(list(a = 1), name_root = "top")

  expect_equal(nl$name[1], "top")
  expect_equal(nl$name[2], "top/a")
})

test_that("nodelist.list S3 object emits fallthrough message", {
  fit <- lm(Sepal.Length ~ Sepal.Width, data = iris)

  expect_message(nodelist(fit), "No nodelist method for class")
  nl <- suppressMessages(nodelist(fit))
  expect_s3_class(nl, "data.frame")
  expect_true(nrow(nl) > 1)
})

test_that("nodelist.list plain list produces no message", {
  expect_silent(nodelist(list(a = 1, b = 2)))
})

test_that("nodelist.list escapes / in element names", {
  nl <- nodelist(list("a/b" = 1))

  # Path uses %2F, display label keeps original
  expect_equal(nl$name[2], "root/a%2Fb")
  expect_equal(nl$label[2], "a/b")
})
