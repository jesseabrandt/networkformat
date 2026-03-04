# Test suite for as_igraph() and as_tbl_graph() methods

# --- as_igraph.tree tests ---

test_that("as_igraph.tree returns igraph object", {
  skip_if_not_installed("tree")
  skip_if_not_installed("igraph")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  g <- as_igraph(tr)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
})

test_that("as_igraph.tree has correct vertex and edge count", {
  skip_if_not_installed("tree")
  skip_if_not_installed("igraph")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  g <- as_igraph(tr)
  nl <- nodelist(tr)
  el <- edgelist(tr)

  expect_equal(igraph::vcount(g), nrow(nl))
  expect_equal(igraph::ecount(g), nrow(el))
})

test_that("as_igraph.tree has vertex attributes from nodelist", {
  skip_if_not_installed("tree")
  skip_if_not_installed("igraph")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  g <- as_igraph(tr)

  vattrs <- igraph::vertex_attr_names(g)
  expect_true("var" %in% vattrs)
  expect_true("is_leaf" %in% vattrs)
  expect_true("label" %in% vattrs)
  expect_true("n" %in% vattrs)
})

test_that("as_igraph.tree has edge attributes from edgelist", {
  skip_if_not_installed("tree")
  skip_if_not_installed("igraph")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  g <- as_igraph(tr)

  eattrs <- igraph::edge_attr_names(g)
  expect_true("label" %in% eattrs)
  expect_true("split_var" %in% eattrs)
  expect_true("split_op" %in% eattrs)
})

# --- as_igraph.randomForest tests ---

test_that("as_igraph.randomForest treenum=1 returns single igraph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  g <- as_igraph(rf, treenum = 1)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
  # Single tree should have treenum attribute on vertices
  expect_true("treenum" %in% igraph::vertex_attr_names(g))
})

test_that("as_igraph.randomForest treenum=NULL returns combined graph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  g <- as_igraph(rf, treenum = NULL)

  expect_true(igraph::is_igraph(g))
  # Should have 3 disconnected components
  expect_equal(igraph::components(g)$no, 3)
  # treenum attribute should be present on vertices
  expect_true("treenum" %in% igraph::vertex_attr_names(g))
  expect_equal(sort(unique(igraph::V(g)$treenum)), c(1, 2, 3))
})

test_that("as_igraph.randomForest multiple treenum returns combined graph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)
  g <- as_igraph(rf, treenum = c(2, 4))

  expect_true(igraph::is_igraph(g))
  expect_equal(igraph::components(g)$no, 2)
  expect_equal(sort(unique(igraph::V(g)$treenum)), c(2, 4))
})

test_that("as_igraph.randomForest has vertex attributes", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  g <- as_igraph(rf, treenum = 1)

  vattrs <- igraph::vertex_attr_names(g)
  expect_true("is_leaf" %in% vattrs)
  expect_true("label" %in% vattrs)
  expect_true("prediction" %in% vattrs)
})

test_that("as_igraph.randomForest combined graph has correct total nodes", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  # Count nodes per tree
  n1 <- nrow(nodelist(rf, treenum = 1))
  n2 <- nrow(nodelist(rf, treenum = 2))
  n3 <- nrow(nodelist(rf, treenum = 3))

  g <- as_igraph(rf, treenum = NULL)
  expect_equal(igraph::vcount(g), n1 + n2 + n3)
})

# --- as_tbl_graph tests ---

test_that("as_tbl_graph.tree returns tbl_graph", {
  skip_if_not_installed("tree")
  skip_if_not_installed("tidygraph")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  tg <- tidygraph::as_tbl_graph(tr)

  expect_s3_class(tg, "tbl_graph")
})

test_that("as_tbl_graph.randomForest returns tbl_graph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("tidygraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  tg <- tidygraph::as_tbl_graph(rf, treenum = 1)

  expect_s3_class(tg, "tbl_graph")
})

test_that("as_tbl_graph.randomForest treenum=NULL returns combined tbl_graph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("tidygraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  tg <- tidygraph::as_tbl_graph(rf, treenum = NULL)

  expect_s3_class(tg, "tbl_graph")
})

# --- as_igraph.rpart tests ---

test_that("as_igraph.rpart returns igraph with correct counts", {
  skip_if_not_installed("rpart")
  skip_if_not_installed("igraph")

  fit <- rpart::rpart(Species ~ ., data = iris)
  g <- as_igraph(fit)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
  expect_equal(igraph::vcount(g), nrow(nodelist(fit)))
  expect_equal(igraph::ecount(g), nrow(edgelist(fit)))
})

test_that("as_igraph.rpart has vertex attributes from nodelist", {
  skip_if_not_installed("rpart")
  skip_if_not_installed("igraph")

  fit <- rpart::rpart(Species ~ ., data = iris)
  g <- as_igraph(fit)

  vattrs <- igraph::vertex_attr_names(g)
  expect_true("var" %in% vattrs)
  expect_true("is_leaf" %in% vattrs)
  expect_true("label" %in% vattrs)
})

test_that("as_tbl_graph.rpart returns tbl_graph", {
  skip_if_not_installed("rpart")
  skip_if_not_installed("tidygraph")

  fit <- rpart::rpart(Species ~ ., data = iris)
  tg <- tidygraph::as_tbl_graph(fit)

  expect_s3_class(tg, "tbl_graph")
})

# --- as_igraph.xgb.Booster tests ---

test_that("as_igraph.xgb.Booster treenum=1 returns igraph", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("igraph")

  set.seed(42)
  dm <- xgboost::xgb.DMatrix(as.matrix(iris[, 1:4]),
                               label = as.integer(iris$Species) - 1)
  bst <- xgboost::xgb.train(list(max_depth = 2, num_class = 3,
                                   objective = "multi:softmax"),
                              dm, nrounds = 2, verbose = 0)
  g <- as_igraph(bst, treenum = 1)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
  expect_equal(igraph::vcount(g), nrow(nodelist(bst, treenum = 1)))
  expect_equal(igraph::ecount(g), nrow(edgelist(bst, treenum = 1)))
})

test_that("as_igraph.xgb.Booster treenum=NULL returns combined graph", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("igraph")

  set.seed(42)
  dm <- xgboost::xgb.DMatrix(as.matrix(iris[, 1:4]),
                               label = as.integer(iris$Species) - 1)
  bst <- xgboost::xgb.train(list(max_depth = 2, num_class = 3,
                                   objective = "multi:softmax"),
                              dm, nrounds = 1, verbose = 0)
  g <- as_igraph(bst, treenum = NULL)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::vcount(g) > 0)
})

test_that("as_tbl_graph.xgb.Booster returns tbl_graph", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("tidygraph")

  set.seed(42)
  dm <- xgboost::xgb.DMatrix(as.matrix(iris[, 1:4]),
                               label = as.integer(iris$Species) - 1)
  bst <- xgboost::xgb.train(list(max_depth = 2, num_class = 3,
                                   objective = "multi:softmax"),
                              dm, nrounds = 1, verbose = 0)
  tg <- tidygraph::as_tbl_graph(bst, treenum = 1)

  expect_s3_class(tg, "tbl_graph")
})

# --- as_igraph.gbm tests ---

test_that("as_igraph.gbm treenum=1 returns igraph", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("igraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 3,
                     interaction.depth = 2, n.minobsinnode = 3)
  )
  g <- as_igraph(fit, treenum = 1)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
  expect_equal(igraph::vcount(g), nrow(nodelist(fit, treenum = 1)))
  expect_equal(igraph::ecount(g), nrow(edgelist(fit, treenum = 1)))
})

test_that("as_igraph.gbm treenum=NULL returns combined graph", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("igraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 3,
                     interaction.depth = 2, n.minobsinnode = 3)
  )
  g <- as_igraph(fit, treenum = NULL)

  expect_true(igraph::is_igraph(g))
  expect_equal(igraph::components(g)$no, 3)
})

test_that("as_tbl_graph.gbm returns tbl_graph", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("tidygraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 2,
                     interaction.depth = 2, n.minobsinnode = 3)
  )
  tg <- tidygraph::as_tbl_graph(fit, treenum = 1)

  expect_s3_class(tg, "tbl_graph")
})

# --- treenum validation tests ---

test_that("as_igraph.randomForest validates treenum range", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)

  expect_error(as_igraph(rf, treenum = 0), "treenum must be between")
  expect_error(as_igraph(rf, treenum = 10), "treenum must be between")
})

test_that("as_igraph.xgb.Booster validates treenum range", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("igraph")

  set.seed(42)
  dm <- xgboost::xgb.DMatrix(as.matrix(iris[, 1:4]),
                               label = as.integer(iris$Species) - 1)
  bst <- xgboost::xgb.train(list(max_depth = 2, num_class = 3,
                                   objective = "multi:softmax"),
                              dm, nrounds = 1, verbose = 0)

  expect_error(as_igraph(bst, treenum = 0), "treenum must be between")
  expect_error(as_igraph(bst, treenum = 100), "treenum must be between")
})

test_that("as_igraph.gbm validates treenum range", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("igraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 3,
                     interaction.depth = 2, n.minobsinnode = 3)
  )

  expect_error(as_igraph(fit, treenum = 0), "treenum must be between")
  expect_error(as_igraph(fit, treenum = 10), "treenum must be between")
})

# --- edge-attribute tests ---

test_that("as_igraph.randomForest has edge attributes", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  g <- as_igraph(rf, treenum = 1)

  eattrs <- igraph::edge_attr_names(g)
  expect_true("split_var" %in% eattrs)
  expect_true("split_point" %in% eattrs)
  expect_true("prediction" %in% eattrs)
})

test_that("as_igraph.rpart has edge attributes", {
  skip_if_not_installed("rpart")
  skip_if_not_installed("igraph")

  fit <- rpart::rpart(Species ~ ., data = iris)
  g <- as_igraph(fit)

  eattrs <- igraph::edge_attr_names(g)
  expect_true("label" %in% eattrs)
  expect_true("split_var" %in% eattrs)
  expect_true("split_op" %in% eattrs)
})

test_that("as_igraph.xgb.Booster has edge attributes", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("igraph")

  set.seed(42)
  dm <- xgboost::xgb.DMatrix(as.matrix(iris[, 1:4]),
                               label = as.integer(iris$Species) - 1)
  bst <- xgboost::xgb.train(list(max_depth = 2, num_class = 3,
                                   objective = "multi:softmax"),
                              dm, nrounds = 1, verbose = 0)
  g <- as_igraph(bst, treenum = 1)

  eattrs <- igraph::edge_attr_names(g)
  expect_true("feature" %in% eattrs)
  expect_true("split" %in% eattrs)
  expect_true("quality" %in% eattrs)
})

test_that("as_igraph.gbm has edge attributes", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("igraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 2,
                     interaction.depth = 2, n.minobsinnode = 3)
  )
  g <- as_igraph(fit, treenum = 1)

  eattrs <- igraph::edge_attr_names(g)
  expect_true("split_var" %in% eattrs)
  expect_true("split_point" %in% eattrs)
  expect_true("prediction" %in% eattrs)
})

# --- ecount cross-check tests ---

test_that("as_igraph.randomForest combined ecount matches sum of per-tree edgelists", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

  set.seed(42)
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3)
  g <- as_igraph(rf, treenum = NULL)

  total_edges <- sum(vapply(1:3, function(tn) nrow(edgelist(rf, treenum = tn)),
                            integer(1)))
  expect_equal(igraph::ecount(g), total_edges)
})

test_that("as_igraph.gbm combined ecount matches sum of per-tree edgelists", {
  skip_if_not_installed("gbm")
  skip_if_not_installed("igraph")

  set.seed(42)
  suppressWarnings(
    fit <- gbm::gbm(mpg ~ ., data = mtcars,
                     distribution = "gaussian", n.trees = 3,
                     interaction.depth = 2, n.minobsinnode = 3)
  )
  g <- as_igraph(fit, treenum = NULL)

  total_edges <- sum(vapply(1:3, function(tn) nrow(edgelist(fit, treenum = tn)),
                            integer(1)))
  expect_equal(igraph::ecount(g), total_edges)
})
