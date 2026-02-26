# Improvements Draft

Vignette review + full code review findings, organized by priority.
For your review before turning items into dev requests.

---

## Critical — Fix before sharing the package

### 1. Vignettes use `pkgload::load_all()` instead of `library(networkformat)`

All three vignettes (`networkformat.Rmd`, `visualization.Rmd`, `edgelist-nodelist.Rmd`) use `pkgload::load_all()` with the `library()` call commented out. This is a dev convenience that will break for anyone who installs the package — `load_all()` looks for source in the working directory. `pkgload` is also not in Suggests, so R CMD check would flag the undeclared dependency.

**Fix:** Uncomment `library(networkformat)`, remove `pkgload::load_all()`.

**Feedback** I need to make sure the package is installed in whatever environment I'm using, right? As do you. So when there are updates, it needs to be reinstalled? Can you figure out the proper workflow here?

### 2. `1:n` bug in `edgelist.tree` and `edgelist.randomForest`

`for (i in 1:n)` produces `c(1, 0)` when `n = 0`, not an empty sequence. Affects `edgelist.tree.R:53`, `edgelist.tree.R:89`, `edgelist.randomForest.R:54`. Replace with `seq_len()`.

### 3. Missing `@importFrom` roxygen tags

The NAMESPACE has `importFrom(rlang, enquo)` and `importFrom(tidyselect, eval_select)`, but these aren't backed by roxygen `@importFrom` tags in any R file. The next `devtools::document()` call will silently strip them, breaking the package. Also missing: `rlang::quo_is_null`.

**Fix:** Add `@importFrom rlang enquo quo_is_null` and `@importFrom tidyselect eval_select` to `R/networkformat-package.R` (or the relevant method files).

### 4. `courses` dataset documentation is wrong

`R/data.R:7` says `@format A data.frame with 6 rows and 6 columns` — the actual dataset has **13 rows and 7 columns** (missing `prereq2`). The `prereq2` column isn't documented in the `\describe{}` block either.

### 5. Placeholder author/URL metadata

DESCRIPTION and CITATION have `John Doe`, `Jane Smith`, fake ORCIDs, and `yourusername` GitHub URLs. Must be replaced before any public release.

---

Jesse Brandt. github jesseabrandt. https://orcid.org/0009-0005-7462-075X

## High — API consistency and usability

### 6. Standardize edgelist column names: `from`/`to` vs `source`/`target`

`edgelist.tree` returns `from`/`to`. `edgelist.randomForest` and `edgelist.data.frame` return `source`/`target`. This is confusing — users writing code that handles multiple model types must check column names. The edgelist-nodelist vignette even documents this inconsistency in the output reference table.

**Recommendation:** Pick one pair and use it everywhere. `from`/`to` has the advantage that tidygraph auto-detects it. `source`/`target` is what the data.frame method already uses and is arguably more descriptive.

**Feedback:** from/to default. I think also make it easily configurable. Consider if this would be useful and the best way to implement it.

### 7. Replace `stopifnot` with informative error messages

`edgelist.randomForest` and `nodelist.randomForest` use `stopifnot(all(treenum >= 1), all(treenum <= input_object$ntree))`, which produces cryptic errors like `all(treenum >= 1) is not TRUE`. Replace with `stop()` that says what the valid range is.

Sure.

### 8. `edgelist.default` should `stop()`, not `message()` + return `NULL`

Currently returns `invisible(NULL)` with a `message()`. This means `edgelist(unsupported) |> head()` produces a confusing `argument is of length zero` error downstream instead of failing immediately. The stub methods (`xgb.Booster`, `rpart`, `gbm`) already use `stop()` — the default should match.

### 9. Add `nodelist.default` method

`edgelist` has a `.default` fallback but `nodelist` doesn't. Calling `nodelist()` on an unsupported class gives R's generic `no applicable method` error instead of a package-specific message.

---

Make one please.

## Medium — Vignette improvements

### 10. Intro vignette (`networkformat.Rmd`) — add a data.frame quick example

The intro's quick example only shows a `tree` model. Since the data.frame method is a major feature (tabular relational data is arguably the most common use case), a second quick example showing `edgelist(courses, ...)` would better represent the package's scope.

yep sounds good.

### 11. Visualization vignette — duplicated course network code

The course network plot code (edge building, deduplication, ggraph) appears nearly identically in both `visualization.Rmd` (lines 183-224) and `edgelist-nodelist.Rmd` (lines 279-323). When one gets updated, the other will drift. Consider keeping the full version in only one vignette and cross-referencing from the other.

**Feedback:**

### 12. Visualization vignette — crosslist deduplication is unexplained

The pattern `all_edges[!(all_edges$directed == FALSE & as.character(all_edges$source) >= as.character(all_edges$target)), ]` appears without explanation. A brief comment or prose sentence explaining _why_ lexicographic comparison deduplicates symmetric edges would help readers.

**Feedback:** I thought this was fixed earlier by putting this deduplication in the function! can you do that?

### 13. Edgelist-nodelist vignette — tidygraph note suggests manual rename

Lines 267-272 show renaming `source`/`target` to `from`/`to` for tidygraph. But tidygraph already auto-detects `source`/`target` — the rename is unnecessary. This section should either be removed or corrected.

**Feedback:** Don't rename then. But consider how this integrates with the above change.

### 14. Edgelist-nodelist vignette — tree section references `igraph::graph_from_data_frame` but tree uses `from`/`to`

The manual igraph construction at line 89-92 wraps `nodes` in `data.frame(name = nodes$node, nodes[-1])`. This is the boilerplate that `as_igraph()` was built to eliminate. The example should show both approaches — manual for learning, `as_igraph()` for practice — and note that the manual approach is shown for completeness.

**Feedback:** Ok. but is it important that that column is called node? Where does that colname come from? Would it make sense to call it name by default? There's definitely something wrong here but think hard about what the best solution is.

### 15. No vignette shows regression trees

All examples use `iris` classification. A regression example (e.g., `tree(mpg ~ ., data = mtcars)`) would show that the package works for both classification and regression, and would demonstrate numeric `yval` in node labels vs. factor.

---

Not that important. Don't do right now.

## Medium — Code quality

### 16. `edgelist.randomForest` inner variable shadows the generic

Inside `convert_tree()` (edgelist.randomForest.R:57), the local variable `edgelist` shadows the exported generic function. Harmless at runtime but confusing. Rename to `edges_df`.

yep.

### 17. `edgelist.tree` grows data frame via `rbind` in a loop

`edgelist.tree.R:60-63` does `edges <- rbind(edges, data.frame(...))` inside a loop, which is O(n^2). Trees are small so performance is fine, but it's a bad pattern. Pre-allocating vectors and building the data frame after the loop is idiomatic.

Yeah fix it.

### 18. `library()` inside `test_that()` blocks

Tests load `randomForest` and `tree` via `library()` inside test blocks, which attaches to the global search path for the entire test session. Use `::` instead (e.g., `randomForest::randomForest(...)`) to avoid cross-test contamination.

Yes.

### 19. Test magic number for `courses` edgelist

`test-edgelist.R:33` hardcodes `expect_equal(nrow(el), 13)` without explanation. Either add a comment or compute the expected value from the data.

Compute it I think.

### 20. `prediction` column in RF edgelist uses parent's value

`edgelist.randomForest` puts the parent node's prediction on both child edges. The documentation is technically correct (`prediction: Prediction value at the parent node`) but semantically surprising — the child's prediction is more useful. Consider renaming to `parent_prediction` or switching to child predictions.

Switch to child predictions. but also - check all the columns and consider what is best to keep for nodelist and for edgelist.

### 21. `as_igraph.randomForest` silently drops `treenum` for single-tree graphs

When `treenum` is a single value, `e$treenum <- NULL` removes the column. When multiple trees are requested, it's kept. This asymmetry is undocumented and surprising.

---

Weird! Fix?

## Low — Polish

### 22. `stringsAsFactors = FALSE` is unnecessary for R >= 4.0

DESCRIPTION says `R (>= 3.6.0)`, but the code uses modern patterns. Either bump the minimum to `R (>= 4.0.0)` and drop the explicit `stringsAsFactors = FALSE` calls, or keep them for 3.6 compat.

Maybe later

### 23. Missing `gbm` and `rpart` in DESCRIPTION Suggests

NAMESPACE exports stub methods for `gbm` and `rpart`, but neither appears in Suggests. CRAN policy requires all packages referenced (even in stubs) to be declared.

Fix

### 24. `attr_cols` can overlap with source/target columns

`edgelist.data.frame` allows selecting source or target columns in `attr_cols`, producing duplicate data. Should either warn or silently exclude overlap.

warn. the default shouldn't include dupes but warn if they manually include them.

### 25. `edgelist.tree` categorical split label has extra space

For categorical splits, the label becomes `"Species :abc"` (space before colon). Should be `"Species:abc"`.

ok

### 26. README is a stub

Only contains `# networkformat`. Needs installation instructions, a minimal example, and links to vignettes — especially important for GitHub visibility.

Yes

---

## Summary counts

| Priority           | Count  |
| ------------------ | ------ |
| Critical           | 5      |
| High               | 4      |
| Medium (vignettes) | 6      |
| Medium (code)      | 6      |
| Low                | 5      |
| **Total**          | **26** |
