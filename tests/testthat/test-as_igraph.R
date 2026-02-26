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

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)
  g <- as_igraph(rf, treenum = c(2, 4))

  expect_true(igraph::is_igraph(g))
  expect_equal(igraph::components(g)$no, 2)
  expect_equal(sort(unique(igraph::V(g)$treenum)), c(2, 4))
})

test_that("as_igraph.randomForest has vertex attributes", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("igraph")

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

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  tg <- tidygraph::as_tbl_graph(rf, treenum = 1)

  expect_s3_class(tg, "tbl_graph")
})

test_that("as_tbl_graph.randomForest treenum=NULL returns combined tbl_graph", {
  skip_if_not_installed("randomForest")
  skip_if_not_installed("tidygraph")

  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 2)
  tg <- tidygraph::as_tbl_graph(rf, treenum = NULL)

  expect_s3_class(tg, "tbl_graph")
})
