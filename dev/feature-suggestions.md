# Feature Suggestions

Draft requirements for future networkformat features derived from pain points
visible in the getting-started vignette. Each proposal is a self-contained
unit of work. Priorities are subjective and based on how much boilerplate
the feature would eliminate.

---

## 1. `as_igraph()` / `as_tbl_graph()` --- direct graph construction

**Priority:** High
**Pain point (vignette lines 44-46, 72-74):** Every workflow ends with the
same manual glue code:

```r
g <- graph_from_data_frame(edges, directed = TRUE,
       vertices = data.frame(name = nodes$node, nodes[-1]))
```

Users must remember which column is the node ID, strip it from the
`vertices` frame, and pass it as `name`. For randomForest the column
mapping is different again (`source`/`target` vs `from`/`to`).

**Proposal:** Generic `as_igraph(x, ...)` and `as_tbl_graph(x, ...)` that
accept any object networkformat already knows how to convert. Each method
calls `edgelist()` + `nodelist()` internally, reconciles column names,
and returns a ready-to-use graph object.

```r
# Desired API
g <- as_igraph(tr)
tg <- as_tbl_graph(rf, treenum = 1)
g <- as_igraph(courses, source_cols = course,
               target_cols = c(prereq, crosslist))
```

**Scope:**

- Methods for `tree`, `randomForest`, `data.frame` (mirror existing edgelist methods)
- igraph and tidygraph listed in Suggests (soft dependency)
- For randomForest, default to all trees; `treenum` arg filters to one

## **Feedback:** Yes. Also consider whether the node column should be named node or name by default? Maybe?

## 2. `drop_na` argument for `edgelist.data.frame()`

**Priority:** High
**Pain point (vignette line 150):**

```r
all_edges <- all_edges[complete.cases(all_edges), ]
```

When a data.frame has multiple target columns and some cells are `NA`,
the resulting edgelist contains rows with `NA` targets. Users must always
strip these manually.

**Proposal:** Add a `drop_na` argument (default `TRUE`) to
`edgelist.data.frame()` that removes rows where `source` or `target` is
`NA` before returning.

**Feedback** rename to na.rm. this is standard in several packages. You can check.

```r
edgelist(courses, source_cols = course,
         target_cols = c(prereq, crosslist),
         na.rm = TRUE)   # default
```

**Scope:**

- Single argument addition to one method
- Default `TRUE` matches the most common intent (you rarely want NA edges)
- Mention in docs that `drop_na = FALSE` preserves the old behavior

---

## 3. `dedupe_symmetric` argument for symmetric/crosslist edges

**Priority:** Medium
**Pain point (vignette lines 156-158):**

```r
all_edges <- all_edges[!(all_edges$type == "crosslist" &
                         as.character(all_edges$source) >=
                         as.character(all_edges$target)), ]
```

Symmetric relationships (crosslists, co-authorships, friendships) produce
duplicate edges (A->B and B->A). Users must manually deduplicate with
lexicographic comparison.

**Proposal:** Add a `symmetric_cols` argument to `edgelist.data.frame()`
that identifies which target columns represent undirected relationships.
For those columns, keep only one edge per pair (smaller node ID first).

```r
edgelist(courses, source_cols = course,
         target_cols = c(prereq, crosslist),
         symmetric_cols = crosslist)
```

**Scope:**

- Applies only to `edgelist.data.frame()`
- Accepts tidyselect; matched against `target_cols`
- Canonical ordering: sort the pair lexicographically, keep first occurrence

**Feedback:** Consider generalizing. Or adding additional information, like a Directed or Undirected column in the result.
Are symmetric edges always bad? will they break in tidygraph?

---

## 4. Node label helpers for tree models

**Priority:** Medium
**Pain point (vignette lines 65-68):**

```r
nodes$node_label <- ifelse(nodes$is_leaf,
  paste0(nodes$yval, "\nn=", nodes$n),
  paste0(nodes$var,  "\nn=", nodes$n))
```

Building display labels is a manual, model-specific step that everyone
repeats.

**Proposal:** A `node_labels()` generic (or a `labels` column added to
`nodelist()` output) that produces sensible default display strings.

```r
node_labels(tr)
# [1] "Sepal.Length\nn=150" "Sepal.Width\nn=62" "setosa\nn=50" ...
```

**Feedback:** a label column in the output.

**Scope:**

- Methods for `tree` and `randomForest` (where `is_leaf`, `var`/`split_var_name`,
  `yval`/`prediction`, and `n` are available)
- Default format: `"<variable>\nn=<n>"` for internal nodes,
  `"<predicted>\nn=<n>"` for leaves
- A `fmt` argument for custom `sprintf`-style templates

---

**Feedback:** a label column in the output. What does sprintf mean? not looking it up rn.

## 5. Edge label parsing for `tree` edgelists

**Priority:** Low
**Pain point (vignette line 70):**

```r
edges$threshold <- gsub("^\\S+\\s+", "", edges$label)
```

The `label` column from `edgelist.tree()` contains strings like
`"Sepal.Length < 5.45"`. Users who want just the threshold (or just the
variable name) must regex-parse it.

**Proposal:** Return the label already split into component columns:

| Column        | Example                           |
| ------------- | --------------------------------- |
| `label`       | `Sepal.Length < 5.45` (unchanged) |
| `split_var`   | `Sepal.Length`                    |
| `split_op`    | `<`                               |
| `split_point` | `5.45`                            |

**Scope:**

- Change to `edgelist.tree()` output only
- Non-breaking: `label` stays; new columns are additive
- Aligns tree output more closely with randomForest output (which already
  has `split_var` and `split_point`)

---

**Feedback:** Yes

## 6. `extract_tree()` helper for randomForest

**Priority:** Low
**Pain point (vignette lines 116-118):**

```r
t1_edges <- subset(rf_edges, treenum == 1)
t1_nodes <- subset(rf_nodes, treenum == 1)
```

Extracting a single tree from a forest requires subsetting both the
edgelist and the nodelist separately and keeping them in sync.

**Proposal:** An `extract_tree()` function that returns a matched pair
(or a small list/S3 object) for one tree.

```r
t1 <- extract_tree(rf, treenum = 1)
t1$edges
t1$nodes

# Or combined with as_igraph:
as_igraph(rf, treenum = 1)
```

**Scope:**

- Works on a randomForest object directly (calls edgelist + nodelist
  internally and filters)
- Returns a named list with `edges` and `nodes` data.frames
- If `as_igraph()` (feature 1) is implemented, this becomes less critical
  since `treenum` can be an argument there

**Feedback:** NO. not at this time. treenum should be an argument in as_igraph sure. But extract_tree is the wrong approach here. that could be an argument in edgelist and nodelist - these should largely be catchall functions that are the only thing for the user to remember. Also does random forest already have extract_tree of some kind? Also, this is a tiny forest, change the vignette so it shows at least three trees (all of them?)
