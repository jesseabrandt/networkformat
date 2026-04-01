# Nodelist Enrichment (tree + rpart) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enrich `nodelist.tree()` and `nodelist.rpart()` with all available frame attributes — class probabilities, depth, deviance improvement, and rpart-specific metadata — enabling ggparty-like ggraph visualizations.

**Architecture:** Each method is enriched in its own file (`R/nodelist.tree.R`, `R/nodelist.rpart.R`). New columns are inserted after `is_leaf` and before `label`. Classification-only columns (class probabilities, counts) are conditionally added based on the presence of `yprob` (tree) or `yval2` (rpart). A shared helper `.compute_depth()` and `.compute_dev_improvement()` go in a new internal utility file.

**Tech Stack:** R, testthat 3e, roxygen2

**Spec:** `docs/superpowers/specs/2026-03-27-nodelist-enrichment-design.md`

---

### File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `R/utils-nodelist.R` | Create | Internal helpers: `.compute_depth()`, `.compute_dev_improvement()` |
| `R/nodelist.tree.R` | Modify | Add depth, dev_improvement, prob columns |
| `R/nodelist.rpart.R` | Modify | Add depth, wt, complexity, ncompete, nsurrogate, dev_improvement, class count/prob columns, nodeprob |
| `tests/testthat/test-nodelist.R` | Modify | Add tests for all new columns on both methods |

---

### Task 1: Internal helpers (depth + deviance improvement)

**Files:**
- Create: `R/utils-nodelist.R`
- Test: `tests/testthat/test-nodelist.R`

- [ ] **Step 1: Write failing tests for `.compute_depth()`**

Add at the top of the tree test section (after line 32, before the first `test_that`). These tests go in `tests/testthat/test-nodelist.R`:

```r
# --- internal helper tests ---

test_that(".compute_depth returns correct depths from binary heap IDs", {
  # Root=1 -> depth 0, children 2,3 -> depth 1, grandchildren 4-7 -> depth 2
  ids <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L)
  expect_equal(
    networkformat:::.compute_depth(ids),
    c(0L, 1L, 1L, 2L, 2L, 2L, 2L)
  )
})

test_that(".compute_dev_improvement is correct for known topology", {
  # 3-node tree: root (id=1, dev=10), left (id=2, dev=3), right (id=3, dev=4)
  ids <- c(1L, 2L, 3L)
  devs <- c(10, 3, 4)
  is_leaf <- c(FALSE, TRUE, TRUE)
  result <- networkformat:::.compute_dev_improvement(ids, devs, is_leaf)
  # root: 10 - 3 - 4 = 3
  expect_equal(result, c(3, NA_real_, NA_real_))
})
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Rscript -e "testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: 2 failures — `.compute_depth` and `.compute_dev_improvement` not found.

- [ ] **Step 3: Implement helpers in `R/utils-nodelist.R`**

Create `R/utils-nodelist.R`:

```r
# Internal helpers for nodelist enrichment
# Not exported — used by nodelist.tree() and nodelist.rpart()

#' Compute tree depth from binary heap node IDs
#' @param ids Integer vector of binary heap node IDs (root = 1)
#' @returns Integer vector of depths (root = 0)
#' @noRd
.compute_depth <- function(ids) {
  as.integer(floor(log2(ids)))
}

#' Compute deviance improvement for each internal node
#'
#' For internal nodes: node_dev - left_child_dev - right_child_dev.
#' Leaves get NA.
#'
#' @param ids Integer vector of binary heap node IDs
#' @param devs Numeric vector of deviance values (same order as ids)
#' @param is_leaf Logical vector (same order as ids)
#' @returns Numeric vector (NA for leaves)
#' @noRd
.compute_dev_improvement <- function(ids, devs, is_leaf) {
  # Build lookup: id -> deviance
  dev_lookup <- stats::setNames(devs, as.character(ids))

  result <- rep(NA_real_, length(ids))
  for (i in seq_along(ids)) {
    if (!is_leaf[i]) {
      left_id  <- as.character(2L * ids[i])
      right_id <- as.character(2L * ids[i] + 1L)
      left_dev  <- dev_lookup[left_id]
      right_dev <- dev_lookup[right_id]
      if (!is.na(left_dev) && !is.na(right_dev)) {
        result[i] <- devs[i] - left_dev - right_dev
      }
    }
  }
  result
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: Both new tests PASS.

- [ ] **Step 5: Commit**

```bash
git add R/utils-nodelist.R tests/testthat/test-nodelist.R
git commit -m "feat: add internal helpers for depth and deviance improvement"
```

---

### Task 2: Enrich `nodelist.tree()` — classification

**Files:**
- Modify: `R/nodelist.tree.R`
- Modify: `tests/testthat/test-nodelist.R`

- [ ] **Step 1: Write failing tests for tree classification enrichment**

Add after the existing tree tests in `tests/testthat/test-nodelist.R` (after the label format test, before the randomForest section):

```r
test_that("nodelist.tree classification has depth column", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_true("depth" %in% names(nl))
  expect_equal(nl$depth[nl$name == 1L], 0L)  # root
  expect_true(all(nl$depth >= 0L))
  expect_true(all(nl$depth[nl$is_leaf] > 0L))  # leaves are not root
})

test_that("nodelist.tree classification has dev_improvement column", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_true("dev_improvement" %in% names(nl))
  expect_true(all(is.na(nl$dev_improvement[nl$is_leaf])))
  # Internal nodes should have non-negative improvement
  internal_imp <- nl$dev_improvement[!nl$is_leaf]
  expect_true(all(!is.na(internal_imp)))
  expect_true(all(internal_imp >= -1e-10))  # allow float tolerance
})

test_that("nodelist.tree classification has prob columns", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  prob_cols <- grep("^prob_", names(nl), value = TRUE)
  expect_length(prob_cols, 3)  # setosa, versicolor, virginica
  expect_true(all(c("prob_setosa", "prob_versicolor", "prob_virginica") %in% names(nl)))

  # Probabilities sum to ~1 per row
  prob_sums <- rowSums(nl[, prob_cols])
  expect_true(all(abs(prob_sums - 1) < 1e-10))

  # All probabilities in [0, 1]
  for (col in prob_cols) {
    expect_true(all(nl[[col]] >= 0 & nl[[col]] <= 1))
  }
})

test_that("nodelist.tree classification label is last column", {
  skip_if_not_installed("tree")

  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nl <- nodelist(tr)

  expect_equal(names(nl)[ncol(nl)], "label")
})
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: 4 new test failures — missing depth, dev_improvement, prob_ columns.

- [ ] **Step 3: Implement enriched `nodelist.tree()`**

Replace the `data.frame(...)` construction in `R/nodelist.tree.R` (lines 43-54). The full updated function body after `is_leaf` and `yval` lines:

```r
nodelist.tree <- function(input_object, ...) {
  if (!requireNamespace("tree", quietly = TRUE)) {
    stop("Package 'tree' is required. Install it with install.packages('tree').")
  }

  frame <- input_object$frame
  is_leaf <- frame$var == "<leaf>"
  yval <- if (is.factor(frame$yval)) as.character(frame$yval) else frame$yval
  ids <- as.integer(rownames(frame))

  result <- data.frame(
    name    = ids,
    var     = as.character(frame$var),
    n       = frame$n,
    dev     = frame$dev,
    yval    = yval,
    is_leaf = is_leaf,
    depth   = .compute_depth(ids),
    dev_improvement = .compute_dev_improvement(ids, frame$dev, is_leaf),
    stringsAsFactors = FALSE
  )

  # Classification trees have a yprob matrix: one column per class
  if (!is.null(frame$yprob)) {
    class_names <- colnames(frame$yprob)
    prob_names <- paste0("prob_", tolower(make.names(class_names)))
    for (i in seq_along(class_names)) {
      result[[prob_names[i]]] <- frame$yprob[, i]
    }
  }

  # Label stays last
  result$label <- ifelse(is_leaf,
                         paste0(yval, "\nn=", frame$n),
                         paste0(as.character(frame$var), "\nn=", frame$n))

  result
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: All tree tests PASS (old + new).

- [ ] **Step 5: Commit**

```bash
git add R/nodelist.tree.R tests/testthat/test-nodelist.R
git commit -m "feat(tree): add depth, dev_improvement, class probs to nodelist"
```

---

### Task 3: Enrich `nodelist.tree()` — regression

**Files:**
- Modify: `tests/testthat/test-nodelist.R`

No code changes needed — the implementation from Task 2 already handles regression (no yprob = no prob columns). This task just adds tests to confirm.

- [ ] **Step 1: Write tests for tree regression enrichment**

Add after the classification enrichment tests:

```r
test_that("nodelist.tree regression has depth and dev_improvement", {
  skip_if_not_installed("tree")

  tr <- tree::tree(mpg ~ cyl + disp + hp, data = mtcars)
  nl <- nodelist(tr)

  expect_true("depth" %in% names(nl))
  expect_true("dev_improvement" %in% names(nl))
  expect_equal(nl$depth[nl$name == 1L], 0L)
})

test_that("nodelist.tree regression has no prob columns", {
  skip_if_not_installed("tree")

  tr <- tree::tree(mpg ~ cyl + disp + hp, data = mtcars)
  nl <- nodelist(tr)

  prob_cols <- grep("^prob_", names(nl), value = TRUE)
  expect_length(prob_cols, 0)
})
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: All tree tests PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-nodelist.R
git commit -m "test(tree): add regression nodelist enrichment tests"
```

---

### Task 4: Enrich `nodelist.rpart()` — classification

**Files:**
- Modify: `R/nodelist.rpart.R`
- Modify: `tests/testthat/test-nodelist.R`

- [ ] **Step 1: Write failing tests for rpart classification enrichment**

Add after the existing rpart stump test (after line 537), before the xgboost section:

```r
test_that("nodelist.rpart classification has depth column", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_true("depth" %in% names(nl))
  expect_equal(nl$depth[nl$name == 1L], 0L)
  expect_true(all(nl$depth >= 0L))
})

test_that("nodelist.rpart classification has rpart-specific columns", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_true(all(c("wt", "complexity", "ncompete", "nsurrogate") %in% names(nl)))
  expect_true(all(nl$wt > 0))
  expect_true(all(nl$complexity >= 0))
  expect_true(all(nl$ncompete >= 0))
  expect_true(all(nl$nsurrogate >= 0))
})

test_that("nodelist.rpart classification has dev_improvement column", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_true("dev_improvement" %in% names(nl))
  expect_true(all(is.na(nl$dev_improvement[nl$is_leaf])))
  internal_imp <- nl$dev_improvement[!nl$is_leaf]
  expect_true(all(!is.na(internal_imp)))
  expect_true(all(internal_imp >= -1e-10))
})

test_that("nodelist.rpart classification has prob and count columns", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  prob_cols <- grep("^prob_", names(nl), value = TRUE)
  n_cols    <- grep("^n_", names(nl), value = TRUE)
  expect_length(prob_cols, 3)
  expect_length(n_cols, 3)
  expect_true(all(c("prob_setosa", "prob_versicolor", "prob_virginica") %in% names(nl)))
  expect_true(all(c("n_setosa", "n_versicolor", "n_virginica") %in% names(nl)))

  # Probabilities sum to ~1
  prob_sums <- rowSums(nl[, prob_cols])
  expect_true(all(abs(prob_sums - 1) < 1e-10))

  # Class counts sum to n
  count_sums <- rowSums(nl[, n_cols])
  expect_equal(count_sums, nl$n)
})

test_that("nodelist.rpart classification has nodeprob column", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_true("nodeprob" %in% names(nl))
  expect_true(all(nl$nodeprob >= 0 & nl$nodeprob <= 1))
  # Root nodeprob should be 1
  expect_equal(nl$nodeprob[nl$name == 1L], 1)
})

test_that("nodelist.rpart classification label is last column", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(Species ~ ., data = iris)
  nl <- nodelist(fit)

  expect_equal(names(nl)[ncol(nl)], "label")
})
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: 6 new failures — missing new columns.

- [ ] **Step 3: Implement enriched `nodelist.rpart()`**

Replace the full function body in `R/nodelist.rpart.R`:

```r
nodelist.rpart <- function(input_object, ...) {
  if (!requireNamespace("rpart", quietly = TRUE)) {
    stop("Package 'rpart' is required. Install it with install.packages('rpart').")
  }

  frame <- input_object$frame
  is_leaf <- frame$var == "<leaf>"
  ids <- as.integer(rownames(frame))

  # For classification trees, decode yval to class name
  ylevels <- attr(input_object, "ylevels")
  if (!is.null(ylevels)) {
    yval <- ylevels[as.integer(frame$yval)]
  } else {
    yval <- frame$yval
  }

  result <- data.frame(
    name        = ids,
    var         = as.character(frame$var),
    n           = frame$n,
    dev         = frame$dev,
    yval        = yval,
    is_leaf     = is_leaf,
    depth       = .compute_depth(ids),
    wt          = frame$wt,
    complexity  = frame$complexity,
    ncompete    = frame$ncompete,
    nsurrogate  = frame$nsurrogate,
    dev_improvement = .compute_dev_improvement(ids, frame$dev, is_leaf),
    stringsAsFactors = FALSE
  )

  # Classification trees have yval2 matrix with counts, probs, nodeprob
  if (!is.null(ylevels) && !is.null(frame$yval2)) {
    yval2 <- frame$yval2
    n_classes <- length(ylevels)
    class_names_clean <- tolower(make.names(ylevels))

    # yval2 layout: yval | counts (n_classes) | probs (n_classes) | nodeprob
    # Column 1 is predicted class (already used above as yval)
    count_cols <- seq(2, 1 + n_classes)
    prob_cols  <- seq(2 + n_classes, 1 + 2 * n_classes)
    nodeprob_col <- 2 + 2 * n_classes

    for (i in seq_len(n_classes)) {
      result[[paste0("n_", class_names_clean[i])]] <- yval2[, count_cols[i]]
    }
    for (i in seq_len(n_classes)) {
      result[[paste0("prob_", class_names_clean[i])]] <- yval2[, prob_cols[i]]
    }
    result$nodeprob <- yval2[, nodeprob_col]
  }

  # Label stays last
  result$label <- ifelse(is_leaf,
                         paste0(yval, "\nn=", frame$n),
                         paste0(as.character(frame$var), "\nn=", frame$n))

  result
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: All rpart tests PASS (old + new).

- [ ] **Step 5: Commit**

```bash
git add R/nodelist.rpart.R tests/testthat/test-nodelist.R
git commit -m "feat(rpart): add depth, metadata, class probs to nodelist"
```

---

### Task 5: Enrich `nodelist.rpart()` — regression + stump edge cases

**Files:**
- Modify: `tests/testthat/test-nodelist.R`

No code changes — the implementation from Task 4 handles regression (no yval2 = no class columns). This task adds regression and stump tests.

- [ ] **Step 1: Write tests for rpart regression and stump enrichment**

Add after the classification enrichment tests:

```r
test_that("nodelist.rpart regression has depth and rpart columns, no prob columns", {
  skip_if_not_installed("rpart")

  fit <- rpart::rpart(mpg ~ cyl + disp + hp, data = mtcars)
  nl <- nodelist(fit)

  expect_true(all(c("depth", "wt", "complexity", "ncompete", "nsurrogate",
                     "dev_improvement") %in% names(nl)))
  expect_equal(nl$depth[nl$name == 1L], 0L)

  prob_cols <- grep("^prob_", names(nl), value = TRUE)
  n_cols    <- grep("^n_", names(nl), value = TRUE)
  expect_length(prob_cols, 0)
  expect_length(n_cols, 0)
  expect_false("nodeprob" %in% names(nl))
})

test_that("nodelist.rpart stump has enriched columns", {
  skip_if_not_installed("rpart")

  stump <- rpart::rpart(Species ~ ., data = iris,
                         control = rpart::rpart.control(cp = 1))
  nl <- nodelist(stump)

  expect_equal(nrow(nl), 1)
  expect_equal(nl$depth, 0L)
  expect_true(is.na(nl$dev_improvement))  # leaf, no split
})
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `Rscript -e "devtools::load_all(); testthat::test_file('tests/testthat/test-nodelist.R')"`
Expected: All tests PASS.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-nodelist.R
git commit -m "test(rpart): add regression and stump enrichment tests"
```

---

### Task 6: Update roxygen documentation

**Files:**
- Modify: `R/nodelist.tree.R` (roxygen comments)
- Modify: `R/nodelist.rpart.R` (roxygen comments)

- [ ] **Step 1: Update `nodelist.tree` roxygen `@returns`**

Replace the `@returns` block in `R/nodelist.tree.R` with:

```r
#' @returns A data.frame with one row per node and the following columns:
#'   \describe{
#'     \item{name}{Integer node ID (binary heap index, matches edgelist from/to)}
#'     \item{var}{Split variable name, or \code{"<leaf>"} for terminal nodes}
#'     \item{n}{Number of observations routed to this node}
#'     \item{dev}{Deviance (impurity) at this node}
#'     \item{yval}{Predicted value (numeric for regression, character for
#'       classification)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{depth}{Integer tree depth (root = 0)}
#'     \item{dev_improvement}{Numeric deviance reduction from this node's split
#'       (\code{NA} for leaves)}
#'     \item{prob_*}{(Classification only) One column per class with the
#'       class probability at that node, named \code{prob_<classname>}}
#'     \item{label}{Display label: \code{"<var>\\nn=<n>"} for internal nodes,
#'       \code{"<yval>\\nn=<n>"} for leaves}
#'   }
```

- [ ] **Step 2: Update `nodelist.rpart` roxygen `@returns`**

Replace the `@returns` block in `R/nodelist.rpart.R` with:

```r
#' @returns A data.frame with one row per node and the following columns:
#'   \describe{
#'     \item{name}{Integer node ID (binary heap index, matches edgelist from/to)}
#'     \item{var}{Split variable name, or \code{"<leaf>"} for terminal nodes}
#'     \item{n}{Number of observations routed to this node}
#'     \item{dev}{Deviance (impurity) at this node}
#'     \item{yval}{Predicted value (numeric for regression, character class label
#'       for classification)}
#'     \item{is_leaf}{Logical: \code{TRUE} for terminal nodes}
#'     \item{depth}{Integer tree depth (root = 0)}
#'     \item{wt}{Weighted observation count}
#'     \item{complexity}{CP pruning parameter at this node}
#'     \item{ncompete}{Number of competing splits considered}
#'     \item{nsurrogate}{Number of surrogate splits used}
#'     \item{dev_improvement}{Numeric deviance reduction from this node's split
#'       (\code{NA} for leaves)}
#'     \item{n_*}{(Classification only) One column per class with the count of
#'       observations of that class at the node, named \code{n_<classname>}}
#'     \item{prob_*}{(Classification only) One column per class with the
#'       class probability at that node, named \code{prob_<classname>}}
#'     \item{nodeprob}{(Classification only) Proportion of training data
#'       reaching this node}
#'     \item{label}{Display label: \code{"<var>\\nn=<n>"} for internal nodes,
#'       \code{"<yval>\\nn=<n>"} for leaves}
#'   }
```

- [ ] **Step 3: Regenerate man pages**

Run: `Rscript -e "devtools::document()"`
Expected: `man/nodelist.tree.Rd` and `man/nodelist.rpart.Rd` updated.

- [ ] **Step 4: Commit**

```bash
git add R/nodelist.tree.R R/nodelist.rpart.R man/
git commit -m "docs: update roxygen for enriched tree/rpart nodelists"
```

---

### Task 7: Run full test suite + R CMD check

- [ ] **Step 1: Run full test suite**

Run: `Rscript -e "devtools::test()"`
Expected: All tests pass, no regressions.

- [ ] **Step 2: Run R CMD check**

Run: `Rscript -e "devtools::check()"`
Expected: 0 errors, 0 warnings. Notes are acceptable.

- [ ] **Step 3: Fix any issues found**

If check reveals issues (e.g., missing imports, doc mismatches), fix them and re-run.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A && git commit -m "fix: address R CMD check findings"
```

(Skip if no fixes needed.)
