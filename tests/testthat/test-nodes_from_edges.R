test_that("nodes_from_edges extracts sorted unique IDs", {
  el <- data.frame(from = c("A", "B", "C"), to = c("B", "C", "D"))
  nodes <- nodes_from_edges(el)

  expect_s3_class(nodes, "data.frame")
  expect_equal(names(nodes), "name")
  expect_equal(nodes$name, c("A", "B", "C", "D"))
})

test_that("nodes_from_edges handles numeric IDs", {
  el <- data.frame(from = c(1, 2, 3), to = c(2, 3, 4))
  nodes <- nodes_from_edges(el)

  expect_equal(nodes$name, c("1", "2", "3", "4"))
})

test_that("nodes_from_edges handles single-edge edgelist", {
  el <- data.frame(from = "A", to = "B")
  nodes <- nodes_from_edges(el)

  expect_equal(nodes$name, c("A", "B"))
})

test_that("nodes_from_edges handles self-loop", {
  el <- data.frame(from = c("A", "B"), to = c("A", "C"))
  nodes <- nodes_from_edges(el)

  expect_equal(nodes$name, c("A", "B", "C"))
})

test_that("nodes_from_edges works on edgelist() output", {
  el <- edgelist(c("X", "Y", "Z"))
  nodes <- nodes_from_edges(el)

  expect_equal(nodes$name, c("X", "Y", "Z"))
})

test_that("nodes_from_edges errors on bad input", {
  expect_error(nodes_from_edges(data.frame(a = 1, b = 2)),
               "from.*to")
  expect_error(nodes_from_edges("not a data frame"),
               "from.*to")
})
