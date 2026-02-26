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
  expect_equal(nl$name, seq_len(nrow(nl)))
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

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  expect_s3_class(nl, "data.frame")
  expect_true(all(c("name", "is_leaf", "split_var", "split_var_name",
                     "split_point", "prediction", "treenum", "label") %in% names(nl)))
})

test_that("nodelist.randomForest has correct number of trees", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  nl <- nodelist(rf)

  expect_equal(length(unique(nl$treenum)), 3)
})

test_that("nodelist.randomForest node IDs match edgelist per tree", {
  skip_if_not_installed("randomForest")

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

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  leaves <- nl[nl$is_leaf, ]
  expect_true(all(is.na(leaves$split_var)))
  expect_true(all(is.na(leaves$split_var_name)))
  expect_true(all(is.na(leaves$split_point)))
})

test_that("nodelist.randomForest works for regression", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(mpg ~ cyl + disp + hp, data = mtcars, ntree = 2)
  nl <- nodelist(rf)

  expect_s3_class(nl, "data.frame")
  expect_type(nl$prediction, "double")
  expect_true(all(na.omit(nl$split_var_name) %in% c("cyl", "disp", "hp")))
})

# --- nodelist.randomForest label tests ---

test_that("nodelist.randomForest label column exists", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  nl <- nodelist(rf)

  expect_true("label" %in% names(nl))
  expect_type(nl$label, "character")

  # Internal nodes should have split_var_name as label
  internal <- nl[!nl$is_leaf, ]
  expect_equal(internal$label, internal$split_var_name)

  # Leaf nodes should have prediction as label
  leaves <- nl[nl$is_leaf, ]
  expect_equal(leaves$label, as.character(leaves$prediction))
})

# --- nodelist.randomForest treenum tests ---

test_that("nodelist.randomForest treenum extracts specific trees", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)

  nl1 <- nodelist(rf, treenum = 1)
  expect_equal(unique(nl1$treenum), 1)

  nl13 <- nodelist(rf, treenum = c(1, 3))
  expect_equal(sort(unique(nl13$treenum)), c(1, 3))
})

test_that("nodelist.randomForest treenum NULL returns all trees", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  nl_all <- nodelist(rf, treenum = NULL)
  nl_default <- nodelist(rf)
  expect_equal(nl_all, nl_default)
})

test_that("nodelist.randomForest treenum validates range", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  expect_error(nodelist(rf, treenum = 0), "treenum must be between")
  expect_error(nodelist(rf, treenum = 4), "treenum must be between")
})

# --- nodelist.default tests ---

test_that("nodelist.default raises error for unsupported types", {
  expect_error(
    nodelist(list(a = 1, b = 2)),
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
