# Test suite for edgelist() generic and methods

test_that("edgelist.randomForest produces data frame with expected structure", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  el <- edgelist(rf)

  expect_s3_class(el, "data.frame")
  expect_true(nrow(el) > 0)
  expect_true(all(c("from", "to", "treenum") %in% names(el)))
  expect_equal(length(unique(el$treenum)), 3)
})

test_that("edgelist.randomForest includes split variable names", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(mpg ~ cyl + disp + hp, data = mtcars, ntree = 2)
  el <- edgelist(rf)

  expect_true("split_var_name" %in% names(el))
  expect_type(el$split_var_name, "character")
  expect_true(all(el$split_var_name %in% c("cyl", "disp", "hp")))
})

test_that("edgelist.data.frame method returns data frame with from and to", {
  el <- edgelist(courses)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to") %in% names(el)))
  expect_equal(nrow(el), nrow(courses))
})

test_that("edgelist.data.frame handles custom source and target columns", {
  df <- data.frame(
    from = c("A", "B", "C"),
    to = c("B", "C", "D")
  )
  el <- edgelist(df, source_cols = 1, target_cols = 2)

  expect_s3_class(el, "data.frame")
  expect_equal(el$from, c("A", "B", "C"))
  expect_equal(el$to, c("B", "C", "D"))
})

test_that("edgelist.tree produces data frame with from, to, label columns", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  el <- edgelist(tr)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to", "label") %in% names(el)))
  expect_true(nrow(el) > 0)
})

test_that("edgelist.default raises error for unsupported types", {
  expect_error(
    edgelist(list(a = 1, b = 2)),
    "does not support"
  )
})

test_that("edgelist generic dispatches to correct method", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 1)
  df <- data.frame(from = 1:3, to = 2:4)

  # Should dispatch to edgelist.randomForest
  rf_result <- edgelist(rf)
  expect_true("treenum" %in% names(rf_result))

  # Should dispatch to edgelist.data.frame
  df_result <- edgelist(df)
  expect_true("from" %in% names(df_result))
})

test_that("edgelist.randomForest handles single tree forest", {
  skip_if_not_installed("randomForest")

  rf_single <- randomForest::randomForest(Species ~ ., data = iris, ntree = 1)
  el <- edgelist(rf_single)

  expect_s3_class(el, "data.frame")
  expect_equal(unique(el$treenum), 1)
  expect_true(all(el$from < el$to | el$from == el$to))
})

test_that("edgelist.randomForest validates model structure", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(mpg ~ ., data = mtcars, ntree = 2)
  el <- edgelist(rf)

  # Check all edges have valid from and to
  expect_true(all(!is.na(el$from)))
  expect_true(all(!is.na(el$to)))
  expect_true(all(el$from > 0))
  expect_true(all(el$to > 0))
})

test_that("edgelist.tree validates tree structure", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ ., data = iris)
  el <- edgelist(tr)

  # Edges should form a valid tree (n_nodes = n_edges + 1)
  n_nodes <- length(unique(c(el$from, el$to)))
  n_edges <- nrow(el)
  expect_equal(n_nodes, n_edges + 1)

  # All labels should be non-empty
  expect_true(all(nchar(el$label) > 0))
})

test_that("edgelist.data.frame removes NAs by default (na.rm = TRUE)", {
  df_with_na <- data.frame(
    source = c("A", "B", NA, "D"),
    target = c("B", "C", "D", NA)
  )
  el <- edgelist(df_with_na)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 2)
  expect_false(any(is.na(el$from)))
  expect_false(any(is.na(el$to)))
})

test_that("edgelist.data.frame preserves NAs with na.rm = FALSE", {
  df_with_na <- data.frame(
    source = c("A", "B", NA, "D"),
    target = c("B", "C", "D", NA)
  )
  el <- edgelist(df_with_na, na.rm = FALSE)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 4)
  expect_true(any(is.na(el$from)))
  expect_true(any(is.na(el$to)))
})

test_that("edgelist.data.frame na.rm works with multiple target columns", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = c(prereq, crosslist))

  # NAs from missing prereqs/crosslists should be dropped
  expect_false(any(is.na(el$from)))
  expect_false(any(is.na(el$to)))
  expect_true(nrow(el) < nrow(courses) * 2) # Some rows have NA crosslists
})

test_that("edgelist.data.frame handles multiple target columns", {
  el <- edgelist(courses, source_cols = 2, target_cols = c(3, 5), na.rm = FALSE)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), nrow(courses) * 2)
  expect_true(all(c("from", "to") %in% names(el)))
})

# --- tidyselect tests ---

test_that("edgelist.data.frame accepts bare column names", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq, na.rm = FALSE)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), nrow(courses))
  expect_equal(el$from, courses$course)
  expect_equal(el$to, courses$prereq)
})

test_that("edgelist.data.frame accepts string column names", {
  el <- edgelist(courses, source_cols = "course", target_cols = "prereq", na.rm = FALSE)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), nrow(courses))
  expect_equal(el$from, courses$course)
  expect_equal(el$to, courses$prereq)
})

test_that("edgelist.data.frame accepts multiple bare target columns", {
  el <- edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist),
                 na.rm = FALSE, dedupe = FALSE)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), nrow(courses) * 2)
  expect_true(all(c("from", "to") %in% names(el)))
})

# --- attr_cols and metadata column tests ---

test_that("edgelist.data.frame includes from_col and to_col metadata", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq, na.rm = FALSE)

  expect_true(all(c("from_col", "to_col") %in% names(el)))
  expect_true(all(el$from_col == "course"))
  expect_true(all(el$to_col == "prereq"))
})

test_that("edgelist.data.frame default attr_cols keeps all remaining columns", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq, na.rm = FALSE)

  # courses has: dept, course, prereq, prereq2, crosslist, credits, level
  # source=course, target=prereq -> remaining: dept, prereq2, crosslist, credits, level
  expect_true(all(c("dept", "prereq2", "crosslist", "credits", "level") %in% names(el)))
  expect_equal(el$dept, courses$dept)
  expect_equal(el$credits, courses$credits)
})

test_that("edgelist.data.frame attr_cols = c() keeps only from, to, metadata", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq,
                 attr_cols = c())

  expect_equal(names(el), c("from", "to", "from_col", "to_col"))
})

test_that("edgelist.data.frame attr_cols selects specific columns", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq,
                 attr_cols = c(dept, credits))

  expect_true("dept" %in% names(el))
  expect_true("credits" %in% names(el))
  expect_false("crosslist" %in% names(el))
  expect_false("level" %in% names(el))
})

test_that("edgelist.data.frame attr_cols works with tidyselect helpers", {
  el <- edgelist(courses, source_cols = course, target_cols = prereq,
                 attr_cols = starts_with("c"))

  # starts_with("c") matches: crosslist, credits
  expect_true("crosslist" %in% names(el))
  expect_true("credits" %in% names(el))
  expect_false("dept" %in% names(el))
  expect_false("level" %in% names(el))
})

test_that("edgelist.data.frame multi-target has correct to_col per block", {
  el <- edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist),
                 na.rm = FALSE, dedupe = FALSE)

  n <- nrow(courses)
  expect_equal(nrow(el), n * 2)
  # First n rows from prereq, next n from crosslist
  expect_true(all(el$to_col[seq_len(n)] == "prereq"))
  expect_true(all(el$to_col[(n + 1):(n * 2)] == "crosslist"))
  # from_col is always "course"
  expect_true(all(el$from_col == "course"))
})

test_that("edgelist.data.frame multi-source x multi-target Cartesian product", {
  df <- data.frame(
    a = c("x", "y"),
    b = c("p", "q"),
    c = c("m", "n"),
    w = c(1, 2)
  )
  el <- edgelist(df, source_cols = c(a, b), target_cols = c(c), attr_cols = w)

  # 2 source cols * 1 target col * 2 rows = 4 rows

  expect_equal(nrow(el), 4)
  expect_equal(el$from_col, c("a", "a", "b", "b"))
  expect_true(all(el$to_col == "c"))
  expect_equal(el$from, c("x", "y", "p", "q"))
  expect_equal(el$to, c("m", "n", "m", "n"))
  expect_equal(el$w, c(1, 2, 1, 2))
})

test_that("edgelist.data.frame handles zero-row input", {
  df <- data.frame(from = character(0), to = character(0), w = numeric(0))
  el <- edgelist(df)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 0)
  expect_true(all(c("from", "to", "from_col", "to_col") %in% names(el)))
})

test_that("edgelist.data.frame all-columns-consumed leaves no attr columns", {
  df <- data.frame(a = 1:3, b = 4:6)
  el <- edgelist(df, source_cols = a, target_cols = b)

  # Both columns consumed --- default attr_cols=NULL yields no extra columns
  expect_equal(names(el), c("from", "to", "from_col", "to_col"))
})

test_that("edgelist.data.frame attributes replicate across multi-target", {
  el <- edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist),
                 attr_cols = credits, na.rm = FALSE, dedupe = FALSE)

  # credits should be replicated identically in both blocks
  n <- nrow(courses)
  expect_equal(el$credits[seq_len(n)], courses$credits)
  expect_equal(el$credits[(n + 1):(n * 2)], courses$credits)
})

# --- symmetric_cols tests ---

test_that("edgelist.data.frame symmetric_cols adds directed column", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = c(prereq, crosslist),
                 symmetric_cols = crosslist, na.rm = FALSE, dedupe = FALSE)

  expect_true("directed" %in% names(el))
  # prereq edges should be directed
  expect_true(all(el$directed[el$to_col == "prereq"]))
  # crosslist edges should be undirected
  expect_false(any(el$directed[el$to_col == "crosslist"]))
})

test_that("edgelist.data.frame no directed column when symmetric_cols omitted", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = c(prereq, crosslist), na.rm = FALSE)

  expect_false("directed" %in% names(el))
})

test_that("edgelist.data.frame symmetric_cols warns for non-target columns", {
  expect_warning(
    edgelist(courses, source_cols = course,
             target_cols = prereq,
             symmetric_cols = crosslist),
    "symmetric_cols not found in target_cols"
  )
})

test_that("edgelist.data.frame symmetric_cols works with na.rm", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = c(prereq, crosslist),
                 symmetric_cols = crosslist, dedupe = FALSE)

  expect_true("directed" %in% names(el))
  # NAs should be removed
  expect_false(any(is.na(el$from)))
  expect_false(any(is.na(el$to)))
})

# --- treenum argument tests ---

test_that("edgelist.randomForest treenum extracts specific trees", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)

  el1 <- edgelist(rf, treenum = 1)
  expect_equal(unique(el1$treenum), 1)

  el13 <- edgelist(rf, treenum = c(1, 3))
  expect_equal(sort(unique(el13$treenum)), c(1, 3))
})

test_that("edgelist.randomForest treenum NULL returns all trees", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  el_all <- edgelist(rf, treenum = NULL)
  el_default <- edgelist(rf)
  expect_equal(el_all, el_default)
})

test_that("edgelist.randomForest treenum validates range", {
  skip_if_not_installed("randomForest")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  expect_error(edgelist(rf, treenum = 0), "treenum must be between")
  expect_error(edgelist(rf, treenum = 4), "treenum must be between")
})

# --- edgelist.tree split parsing tests ---

test_that("edgelist.tree returns parsed split columns", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  el <- edgelist(tr)

  expect_true(all(c("split_var", "split_op", "split_point") %in% names(el)))
  expect_type(el$split_var, "character")
  expect_type(el$split_op, "character")
  expect_type(el$split_point, "double")
})

test_that("edgelist.tree split_var matches variable in label", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  el <- edgelist(tr)

  # Every label should start with the split_var
  for (i in seq_len(nrow(el))) {
    expect_true(startsWith(el$label[i], el$split_var[i]))
  }
})

test_that("edgelist.tree numeric splits have correct op and point", {
  skip_if_not_installed("tree")

  tr <- tree::tree(mpg ~ cyl + disp + hp, data = mtcars)
  el <- edgelist(tr)

  # All splits on numeric data should have op and point
  numeric_rows <- !is.na(el$split_op)
  expect_true(any(numeric_rows))
  expect_true(all(el$split_op[numeric_rows] %in% c("<", ">=")))
  expect_true(all(!is.na(el$split_point[numeric_rows])))
  expect_true(all(el$split_point[numeric_rows] > 0))
})

test_that("edgelist.tree label column is unchanged", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  el <- edgelist(tr)

  # label should still be non-empty strings
  expect_true(all(nchar(el$label) > 0))
  # For numeric splits, label should contain the split var and a space
  numeric_rows <- !is.na(el$split_op)
  expect_true(all(grepl(" ", el$label[numeric_rows])))
})

# --- dedupe tests ---

test_that("edgelist.data.frame symmetric edges auto-deduped by default", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = c(prereq, crosslist),
                 symmetric_cols = crosslist, attr_cols = c())

  # Undirected edges should have from <= to (lexicographic)
  undirected <- el[!el$directed, ]
  expect_true(all(as.character(undirected$from) <= as.character(undirected$to)))
})

test_that("edgelist.data.frame dedupe = FALSE preserves both directions", {
  el <- edgelist(courses, source_cols = course,
                 target_cols = crosslist,
                 symmetric_cols = crosslist, attr_cols = c(),
                 dedupe = FALSE)

  el_deduped <- edgelist(courses, source_cols = course,
                         target_cols = crosslist,
                         symmetric_cols = crosslist, attr_cols = c(),
                         dedupe = TRUE)

  expect_true(nrow(el) >= nrow(el_deduped))
})

# --- attr_cols overlap warning ---

test_that("edgelist.data.frame warns when attr_cols overlaps source/target", {
  expect_warning(
    edgelist(courses, source_cols = course, target_cols = prereq,
             attr_cols = c(course, dept)),
    "attr_cols overlaps with source/target"
  )
})
