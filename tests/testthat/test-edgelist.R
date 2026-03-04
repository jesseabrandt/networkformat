# Test suite for edgelist() generic and methods

test_that("edgelist.randomForest produces data frame with expected structure", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  el <- edgelist(rf)

  expect_s3_class(el, "data.frame")
  expect_true(nrow(el) > 0)
  expect_true(all(c("from", "to", "treenum") %in% names(el)))
  expect_equal(length(unique(el$treenum)), 3)
})

test_that("edgelist.randomForest includes split variable names", {
  skip_if_not_installed("randomForest")

  set.seed(42)
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

  set.seed(42)
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

  set.seed(42)
  rf_single <- randomForest::randomForest(Species ~ ., data = iris, ntree = 1)
  el <- edgelist(rf_single)

  expect_s3_class(el, "data.frame")
  expect_equal(unique(el$treenum), 1)
  expect_true(all(el$from > 0L))
  expect_true(all(el$to > 0L))
})

test_that("edgelist.randomForest validates model structure", {
  skip_if_not_installed("randomForest")

  set.seed(42)
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

test_that("edgelist.data.frame symmetric_cols errors for non-target columns", {
  expect_error(
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

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)

  el1 <- edgelist(rf, treenum = 1)
  expect_equal(unique(el1$treenum), 1)

  el13 <- edgelist(rf, treenum = c(1, 3))
  expect_equal(sort(unique(el13$treenum)), c(1, 3))
})

test_that("edgelist.randomForest treenum NULL returns all trees", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  el_all <- edgelist(rf, treenum = NULL)
  el_default <- edgelist(rf)
  expect_equal(el_all, el_default)
})

test_that("edgelist.randomForest treenum validates range", {
  skip_if_not_installed("randomForest")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  expect_error(edgelist(rf, treenum = 0), "treenum must be between")
  expect_error(edgelist(rf, treenum = 4), "treenum must be between")
  expect_error(edgelist(rf, treenum = integer(0)), "treenum must be between")
  expect_error(edgelist(rf, treenum = NA), "treenum must be between")
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
  expect_true(all(el$split_op[numeric_rows] %in% c("<", ">")))
  expect_true(all(!is.na(el$split_point[numeric_rows])))
  expect_true(all(!is.na(el$split_point[numeric_rows])))
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

test_that("edgelist.tree categorical splits have NA split_op and split_point", {
  skip_if_not_installed("tree")

  # Use a factor predictor to produce categorical splits
  dat <- data.frame(
    y = c(1, 1, 1, 2, 2, 2, 3, 3, 3, 1, 2, 3),
    x = factor(c("a", "a", "a", "b", "b", "b", "c", "c", "c", "a", "b", "c"))
  )
  tr <- tryCatch(tree::tree(y ~ x, data = dat), error = function(e) NULL)
  skip_if(is.null(tr), "tree could not fit a categorical split")

  el <- edgelist(tr)
  cat_rows <- grepl("^:", el$label)

  if (any(cat_rows)) {
    expect_true(all(is.na(el$split_op[cat_rows])))
    expect_true(all(is.na(el$split_point[cat_rows])))
  }
})

test_that("edgelist.tree returns 0 rows for stump (single root node)", {
  skip_if_not_installed("tree")

  # Constant response produces a stump (root only, no splits)
  dat <- data.frame(y = rep(1, 20), x = seq_len(20))
  tr <- tryCatch(tree::tree(y ~ x, data = dat), error = function(e) NULL)
  skip_if(is.null(tr), "tree could not fit a stump")

  el <- edgelist(tr)
  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 0)
  expect_true(all(c("from", "to", "label", "split_var",
                     "split_op", "split_point") %in% names(el)))
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

# --- weights tests (data.frame) ---

test_that("edgelist.data.frame weights = FALSE (default) has no weight column", {
  el <- edgelist(courses)
  expect_false("weight" %in% names(el))
})

test_that("edgelist.data.frame weights = TRUE adds weight column", {
  df <- data.frame(
    a = c("X", "X", "Y", "X"),
    b = c("Y", "Y", "Z", "Z")
  )
  el <- edgelist(df, weights = TRUE)

  expect_true("weight" %in% names(el))
  expect_type(el$weight, "integer")
  # X->Y appears twice, Y->Z once, X->Z once
  expect_equal(nrow(el), 3)
  expect_equal(el$weight[el$from == "X" & el$to == "Y"], 2L)
  expect_equal(el$weight[el$from == "Y" & el$to == "Z"], 1L)
})

test_that("edgelist.data.frame weights applied after na.rm", {
  df <- data.frame(
    a = c("X", "X", NA),
    b = c("Y", "Y", "Z")
  )
  el <- edgelist(df, weights = TRUE)

  # NA row removed first, then X->Y collapsed
  expect_equal(nrow(el), 1)
  expect_equal(el$weight, 2L)
})

test_that("edgelist.data.frame weights applied after symmetric dedupe", {
  df <- data.frame(
    a = c("X", "Y", "X"),
    b = c("Y", "X", "Y")
  )
  # Symmetric dedupe drops Y->X (Y > X), leaving 2 X->Y rows; weights collapses
  el <- edgelist(df, symmetric_cols = b, weights = TRUE, attr_cols = c())

  undirected <- el[!el$directed, ]
  expect_equal(nrow(undirected), 1)
  expect_equal(undirected$weight, 2L)
})

test_that("edgelist.data.frame weights keeps rows with different attributes", {
  df <- data.frame(
    a = c("X", "X"),
    b = c("Y", "Y"),
    w = c(10, 20)
  )
  el <- edgelist(df, weights = TRUE)

  # Different w values -> distinct rows, each with weight 1
  expect_equal(nrow(el), 2)
  expect_equal(el$weight, c(1L, 1L))
})

test_that("edgelist.data.frame weights collapses fully identical rows", {
  df <- data.frame(
    a = c("X", "X", "X"),
    b = c("Y", "Y", "Y"),
    w = c(10, 10, 20)
  )
  el <- edgelist(df, weights = TRUE)

  # Two identical rows (w=10) collapse; the w=20 row stays separate
  expect_equal(nrow(el), 2)
  expect_equal(el$weight[el$w == 10], 2L)
  expect_equal(el$weight[el$w == 20], 1L)
})

# --- vector edgelist tests ---

test_that("edgelist on character vector creates sequential edges", {
  el <- edgelist(c("A", "B", "C", "D"))

  expect_s3_class(el, "data.frame")
  expect_equal(el$from, c("A", "B", "C"))
  expect_equal(el$to, c("B", "C", "D"))
  expect_equal(nrow(el), 3)
})

test_that("edgelist on numeric vector creates sequential edges", {
  el <- edgelist(1:5)

  expect_s3_class(el, "data.frame")
  expect_equal(el$from, 1:4)
  expect_equal(el$to, 2:5)
})

test_that("edgelist on integer vector works", {
  el <- edgelist(c(10L, 20L, 30L))

  expect_equal(el$from, c(10L, 20L))
  expect_equal(el$to, c(20L, 30L))
})

test_that("edgelist on factor vector works", {
  el <- edgelist(factor(c("a", "b", "c")))

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 2)
})

test_that("edgelist on length-2 vector returns one edge", {
  el <- edgelist(c("A", "B"))

  expect_equal(nrow(el), 1)
  expect_equal(el$from, "A")
  expect_equal(el$to, "B")
})

test_that("edgelist on length-1 vector errors", {
  expect_error(edgelist(c("A")), "at least 2 elements")
})

test_that("edgelist on empty vector errors", {
  expect_error(edgelist(character(0)), "at least 2 elements")
})

test_that("edgelist vector with weights collapses duplicates", {
  el <- edgelist(c("A", "B", "A", "B", "C"), weights = TRUE)

  expect_true("weight" %in% names(el))
  # Edges: A->B, B->A, A->B, B->C; A->B appears 2x, B->A 1x, B->C 1x
  expect_equal(nrow(el), 3)
  expect_equal(el$weight[el$from == "A" & el$to == "B"], 2L)
  expect_equal(el$weight[el$from == "B" & el$to == "A"], 1L)
  expect_equal(el$weight[el$from == "B" & el$to == "C"], 1L)
})

test_that("edgelist vector without weights has no weight column", {
  el <- edgelist(c("A", "B", "A", "B"))
  expect_false("weight" %in% names(el))
})

test_that("edgelist vector with repeated adjacent pair and weights", {
  el <- edgelist(c(1, 2, 1, 2, 1, 2), weights = TRUE)

  # Edges: 1->2, 2->1, 1->2, 2->1, 1->2
  # 1->2 appears 3x, 2->1 appears 2x
  expect_equal(nrow(el), 2)
  expect_equal(el$weight[el$from == 1 & el$to == 2], 3L)
  expect_equal(el$weight[el$from == 2 & el$to == 1], 2L)
})

# --- edgelist.rpart tests ---

test_that("edgelist.rpart produces data frame with expected columns", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  el <- edgelist(fit)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to", "label", "split_var", "split_op",
                     "split_point") %in% names(el)))
  expect_true(nrow(el) > 0)
})

test_that("edgelist.rpart forms a valid tree", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  el <- edgelist(fit)

  # n_nodes = n_edges + 1
  n_nodes <- length(unique(c(el$from, el$to)))
  expect_equal(n_nodes, nrow(el) + 1)
})

test_that("edgelist.rpart node IDs match nodelist", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  el <- edgelist(fit)
  nl <- nodelist(fit)

  edge_nodes <- sort(unique(c(el$from, el$to)))
  expect_true(all(edge_nodes %in% nl$name))
})

test_that("edgelist.rpart split_op values are < or >=", {
  skip_if_not_installed("rpart")

  # Use all-numeric predictors to ensure numeric splits
  fit <- rpart::rpart(mpg ~ cyl + disp + hp, data = mtcars)
  el <- edgelist(fit)

  numeric_rows <- !is.na(el$split_op)
  expect_true(any(numeric_rows))
  expect_true(all(el$split_op[numeric_rows] %in% c("<", ">=")))
  expect_true(all(!is.na(el$split_point[numeric_rows])))
})

test_that("edgelist.rpart stump returns empty data.frame", {
  skip_if_not_installed("rpart")

  stump <- rpart::rpart(Species ~ ., data = iris,
                         control = rpart::rpart.control(cp = 1))
  el <- edgelist(stump)

  expect_s3_class(el, "data.frame")
  expect_equal(nrow(el), 0)
  expect_true(all(c("from", "to", "label", "split_var", "split_op",
                     "split_point") %in% names(el)))
})

test_that("edgelist.rpart regression tree works", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(mpg ~ ., data = mtcars)
  el <- edgelist(fit)

  expect_s3_class(el, "data.frame")
  expect_true(nrow(el) > 0)
  expect_type(el$split_point, "double")
})

test_that("edgelist.rpart label contains split_var", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  el <- edgelist(fit)

  # Each numeric-split label should contain the variable name
  numeric_rows <- !is.na(el$split_op)
  for (i in which(numeric_rows)) {
    expect_true(grepl(el$split_var[i], el$label[i], fixed = TRUE))
  }
})

test_that("edgelist.rpart handles categorical splits", {
  skip_if_not_installed("rpart")

  # Build dataset with a strong categorical predictor
  set.seed(42)
  n <- 200
  df <- data.frame(
    y = factor(c(rep("A", 100), rep("B", 100))),
    color = factor(c(rep("red", 50), rep("green", 50),
                     rep("blue", 50), rep("yellow", 50))),
    score = rnorm(n)
  )
  fit <- rpart::rpart(y ~ color + score, data = df,
                       control = rpart::rpart.control(cp = 0.001))
  el <- edgelist(fit)

  # If there are categorical splits, split_op and split_point should be NA
  cat_rows <- is.na(el$split_op)
  if (any(cat_rows)) {
    expect_true(all(is.na(el$split_point[cat_rows])))
  }
})

# --- edgelist.xgb.Booster tests ---

test_that("edgelist.xgb.Booster produces data frame with expected columns", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(data = agaricus.train$data,
                            label = agaricus.train$label,
                            max_depth = 2, nrounds = 2,
                            objective = "binary:logistic", verbose = 0)
  el <- edgelist(bst)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to", "feature", "split", "quality",
                     "cover", "treenum") %in% names(el)))
  expect_true(nrow(el) > 0)
})

test_that("edgelist.xgb.Booster string IDs are globally unique", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(data = agaricus.train$data,
                            label = agaricus.train$label,
                            max_depth = 3, nrounds = 3,
                            objective = "binary:logistic", verbose = 0)
  el <- edgelist(bst)

  # All to-nodes should be unique (each child has exactly one parent)
  expect_equal(length(unique(el$to)), length(el$to))
})

test_that("edgelist.xgb.Booster treenum filters correctly", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(data = agaricus.train$data,
                            label = agaricus.train$label,
                            max_depth = 2, nrounds = 5,
                            objective = "binary:logistic", verbose = 0)

  el1 <- edgelist(bst, treenum = 1)
  expect_equal(unique(el1$treenum), 1L)

  el13 <- edgelist(bst, treenum = c(1, 3))
  expect_equal(sort(unique(el13$treenum)), c(1L, 3L))
})

test_that("edgelist.xgb.Booster treenum NULL returns all trees", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(data = agaricus.train$data,
                            label = agaricus.train$label,
                            max_depth = 2, nrounds = 3,
                            objective = "binary:logistic", verbose = 0)

  el_null <- edgelist(bst, treenum = NULL)
  el_default <- edgelist(bst)
  expect_equal(el_null, el_default)
})

test_that("edgelist.xgb.Booster treenum validates range", {
  skip_if_not_installed("xgboost")

  data(agaricus.train, package = "xgboost")
  bst <- xgboost::xgboost(data = agaricus.train$data,
                            label = agaricus.train$label,
                            max_depth = 2, nrounds = 2,
                            objective = "binary:logistic", verbose = 0)

  expect_error(edgelist(bst, treenum = 0), "treenum must be between")
  expect_error(edgelist(bst, treenum = 10), "treenum must be between")
  expect_error(edgelist(bst, treenum = integer(0)), "treenum must be between")
  expect_error(edgelist(bst, treenum = NA), "treenum must be between")
})

test_that("edgelist.xgb.Booster multi-class model works", {
  skip_if_not_installed("xgboost")

  X <- as.matrix(iris[, 1:4])
  y <- as.integer(iris$Species) - 1L
  bst <- xgboost::xgboost(data = X, label = y,
                            objective = "multi:softmax", num_class = 3,
                            nrounds = 2, max_depth = 3, verbose = 0)
  el <- edgelist(bst)

  # 3 classes * 2 rounds = 6 trees
  expect_equal(length(unique(el$treenum)), 6)
})

# --- edgelist.gbm tests ---

test_that("edgelist.gbm produces data frame with expected columns", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )
  el <- edgelist(fit)

  expect_s3_class(el, "data.frame")
  expect_true(all(c("from", "to", "split_var", "split_point", "prediction",
                     "treenum", "split_var_name") %in% names(el)))
  expect_true(nrow(el) > 0)
})

test_that("edgelist.gbm excludes missing-sentinel nodes", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 5, interaction.depth = 3, n.minobsinnode = 3)
  )

  for (tn in 1:5) {
    el_t <- edgelist(fit, treenum = tn)
    nl_t <- nodelist(fit, treenum = tn)
    n_internal <- nrow(el_t) / 2
    expected_real <- 2 * n_internal + 1
    expect_equal(nrow(nl_t), expected_real)
  }
})

test_that("edgelist.gbm treenum filters correctly", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 5, interaction.depth = 2, n.minobsinnode = 3)
  )

  el1 <- edgelist(fit, treenum = 1)
  expect_equal(unique(el1$treenum), 1L)

  el13 <- edgelist(fit, treenum = c(1, 3))
  expect_equal(sort(unique(el13$treenum)), c(1L, 3L))
})

test_that("edgelist.gbm treenum NULL returns all trees", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )

  el_null <- edgelist(fit, treenum = NULL)
  el_default <- edgelist(fit)
  expect_equal(el_null, el_default)
})

test_that("edgelist.gbm treenum validates range", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 3)
  )

  expect_error(edgelist(fit, treenum = 0), "treenum must be between")
  expect_error(edgelist(fit, treenum = 10), "treenum must be between")
  expect_error(edgelist(fit, treenum = integer(0)), "treenum must be between")
  expect_error(edgelist(fit, treenum = NA), "treenum must be between")
})

test_that("edgelist.gbm node IDs match nodelist", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars, distribution = "gaussian",
                     n.trees = 3, interaction.depth = 3, n.minobsinnode = 3)
  )

  for (tn in 1:3) {
    el_t <- edgelist(fit, treenum = tn)
    nl_t <- nodelist(fit, treenum = tn)
    edge_nodes <- sort(unique(c(el_t$from, el_t$to)))
    expect_true(all(edge_nodes %in% nl_t$name))
  }
})

test_that("edgelist.gbm classification works", {
  skip_if_not_installed("gbm")

  set.seed(42)
  df <- data.frame(y = as.numeric(iris$Species == "setosa"),
                   x1 = iris$Sepal.Length, x2 = iris$Petal.Length)
  suppressWarnings(
    fit <- gbm::gbm(y ~ ., data = df, distribution = "bernoulli",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 5)
  )
  el <- edgelist(fit)

  expect_s3_class(el, "data.frame")
  expect_true(nrow(el) > 0)
})

test_that("edgelist.gbm multinomial creates K trees per round", {
  skip_if_not_installed("gbm")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(Species ~ ., data = iris, distribution = "multinomial",
                     n.trees = 3, interaction.depth = 2, n.minobsinnode = 5)
  )

  # 3 classes * 3 rounds = 9 physical trees
  n_physical <- length(fit$trees)
  expect_equal(n_physical, 9)

  el <- edgelist(fit)
  expect_equal(length(unique(el$treenum)), 9)
})
