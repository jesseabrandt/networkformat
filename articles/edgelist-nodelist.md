# Working with edgelists and nodelists

``` r
library(networkformat)
```

[`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
and
[`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
are the core functions of **networkformat**. They extract network
structure from vectors, data frames, and tree models as plain data
frames, giving you full control over filtering, transforming, and
passing the results to igraph or any other tool.

For quick visualization without touching the raw data, see
[`vignette("visualization")`](https://jesseabrandt.github.io/networkformat/articles/visualization.md).

## Decision tree

### edgelist()

``` r
tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
edges <- edgelist(tr)
edges
#>    from to              label    split_var split_op split_point
#> 1     1  2 Sepal.Length <5.55 Sepal.Length        <        5.55
#> 2     2  4   Sepal.Width <2.8  Sepal.Width        <        2.80
#> 3     4  8 Sepal.Length <5.05 Sepal.Length        <        5.05
#> 4     4  9 Sepal.Length >5.05 Sepal.Length        >        5.05
#> 5     2  5   Sepal.Width >2.8  Sepal.Width        >        2.80
#> 6     5 10 Sepal.Length <5.35 Sepal.Length        <        5.35
#> 7     5 11 Sepal.Length >5.35 Sepal.Length        >        5.35
#> 8     1  3 Sepal.Length >5.55 Sepal.Length        >        5.55
#> 9     3  6   Sepal.Width <3.7  Sepal.Width        <        3.70
#> 10    6 12 Sepal.Length <6.25 Sepal.Length        <        6.25
#> 11    6 13 Sepal.Length >6.25 Sepal.Length        >        6.25
#> 12   13 26 Sepal.Length <7.05 Sepal.Length        <        7.05
#> 13   13 27 Sepal.Length >7.05 Sepal.Length        >        7.05
#> 14    3  7   Sepal.Width >3.7  Sepal.Width        >        3.70
```

Columns:

| Column        | Description                                        |
|---------------|----------------------------------------------------|
| `from`        | Parent node ID (binary heap index)                 |
| `to`          | Child node ID (binary heap index)                  |
| `label`       | Full split condition (e.g. `"Sepal.Length <5.45"`) |
| `split_var`   | Variable name                                      |
| `split_op`    | `"<"` or `">"` (NA for categorical splits)         |
| `split_point` | Numeric threshold (NA for categorical)             |

The parsed columns let you filter or restyle without regex:

``` r
# All edges that split on Sepal.Length
edges[edges$split_var == "Sepal.Length", ]
#>    from to              label    split_var split_op split_point
#> 1     1  2 Sepal.Length <5.55 Sepal.Length        <        5.55
#> 3     4  8 Sepal.Length <5.05 Sepal.Length        <        5.05
#> 4     4  9 Sepal.Length >5.05 Sepal.Length        >        5.05
#> 6     5 10 Sepal.Length <5.35 Sepal.Length        <        5.35
#> 7     5 11 Sepal.Length >5.35 Sepal.Length        >        5.35
#> 8     1  3 Sepal.Length >5.55 Sepal.Length        >        5.55
#> 10    6 12 Sepal.Length <6.25 Sepal.Length        <        6.25
#> 11    6 13 Sepal.Length >6.25 Sepal.Length        >        6.25
#> 12   13 26 Sepal.Length <7.05 Sepal.Length        <        7.05
#> 13   13 27 Sepal.Length >7.05 Sepal.Length        >        7.05

# Thresholds above 5
edges[!is.na(edges$split_point) & edges$split_point > 5, ]
#>    from to              label    split_var split_op split_point
#> 1     1  2 Sepal.Length <5.55 Sepal.Length        <        5.55
#> 3     4  8 Sepal.Length <5.05 Sepal.Length        <        5.05
#> 4     4  9 Sepal.Length >5.05 Sepal.Length        >        5.05
#> 6     5 10 Sepal.Length <5.35 Sepal.Length        <        5.35
#> 7     5 11 Sepal.Length >5.35 Sepal.Length        >        5.35
#> 8     1  3 Sepal.Length >5.55 Sepal.Length        >        5.55
#> 10    6 12 Sepal.Length <6.25 Sepal.Length        <        6.25
#> 11    6 13 Sepal.Length >6.25 Sepal.Length        >        6.25
#> 12   13 26 Sepal.Length <7.05 Sepal.Length        <        7.05
#> 13   13 27 Sepal.Length >7.05 Sepal.Length        >        7.05
```

### nodelist()

``` r
nodes <- nodelist(tr)
nodes
#>    name          var   n        dev       yval is_leaf               label
#> 1     1 Sepal.Length 150 329.583687     setosa   FALSE Sepal.Length\nn=150
#> 2     2  Sepal.Width  59  66.481848     setosa   FALSE   Sepal.Width\nn=59
#> 3     4 Sepal.Length  12  13.586058 versicolor   FALSE  Sepal.Length\nn=12
#> 4     8       <leaf>   5   9.502705 versicolor    TRUE     versicolor\nn=5
#> 5     9       <leaf>   7   0.000000 versicolor    TRUE     versicolor\nn=7
#> 6     5 Sepal.Length  47   9.678866     setosa   FALSE  Sepal.Length\nn=47
#> 7    10       <leaf>  39   0.000000     setosa    TRUE        setosa\nn=39
#> 8    11       <leaf>   8   6.028323     setosa    TRUE         setosa\nn=8
#> 9     3  Sepal.Width  91 147.228559  virginica   FALSE   Sepal.Width\nn=91
#> 10    6 Sepal.Length  86 118.476052  virginica   FALSE  Sepal.Length\nn=86
#> 11   12       <leaf>  37  46.626375 versicolor    TRUE    versicolor\nn=37
#> 12   13 Sepal.Length  49  58.630420  virginica   FALSE  Sepal.Length\nn=49
#> 13   26       <leaf>  39  50.920412  virginica    TRUE     virginica\nn=39
#> 14   27       <leaf>  10   0.000000  virginica    TRUE     virginica\nn=10
#> 15    7       <leaf>   5   6.730117     setosa    TRUE         setosa\nn=5
```

Columns:

| Column    | Description                                          |
|-----------|------------------------------------------------------|
| `name`    | Node ID (matches edgelist `from`/`to`)               |
| `var`     | Split variable, or `"<leaf>"`                        |
| `n`       | Observation count                                    |
| `dev`     | Deviance                                             |
| `yval`    | Predicted value                                      |
| `is_leaf` | Logical                                              |
| `label`   | Display label: `"<var>\nn=<n>"` or `"<yval>\nn=<n>"` |

The `label` column is ready for plotting — no manual
[`ifelse()`](https://rdrr.io/r/base/ifelse.html) needed.

### Pairing edges and nodes for igraph

Node IDs line up, so you can pass them straight to
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html):

``` r
library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
g <- graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
cat("Nodes:", vcount(g), " Edges:", ecount(g), "\n")
#> Nodes: 15  Edges: 14
```

Or use `as.igraph(tr)` for the same result in one step.

### Visualizing the edgelist pipeline

The full workflow —
[`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
-\>
[`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
-\>
[`graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html)
-\> ggraph — gives you control at every step. For a complete
visualization example, see
[`vignette("visualization")`](https://jesseabrandt.github.io/networkformat/articles/visualization.md).

## Random forest

### edgelist()

``` r
rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 3, maxnodes = 5)

# All trees
rf_edges <- edgelist(rf)
head(rf_edges)
#>   from to split_var split_point prediction treenum split_var_name
#> 1    1  2         3        2.60          1       1   Petal.Length
#> 2    3  4         4        1.65          0       1    Petal.Width
#> 3    4  6         3        5.00          2       1   Petal.Length
#> 4    5  8         4        1.75          2       1    Petal.Width
#> 5    1  3         3        2.60          0       1   Petal.Length
#> 6    3  5         4        1.65          0       1    Petal.Width
```

Columns:

| Column           | Description                   |
|------------------|-------------------------------|
| `from`           | Parent node index             |
| `to`             | Child node index              |
| `split_var`      | Numeric variable index        |
| `split_point`    | Split threshold               |
| `prediction`     | Predicted value at child node |
| `treenum`        | Tree number                   |
| `split_var_name` | Human-readable variable name  |

#### The `treenum` argument

Extract specific trees without subsetting:

``` r
# Single tree
t1 <- edgelist(rf, treenum = 1)
nrow(t1)
#> [1] 8

# Trees 1 and 3
t13 <- edgelist(rf, treenum = c(1, 3))
table(t13$treenum)
#> 
#> 1 3 
#> 8 8
```

### nodelist()

``` r
rf_nodes <- nodelist(rf, treenum = 1)
rf_nodes
#>   name is_leaf split_var split_var_name split_point prediction treenum
#> 1    1   FALSE         3   Petal.Length        2.60          0       1
#> 2    2    TRUE        NA           <NA>          NA          1       1
#> 3    3   FALSE         4   Petal.Length        1.65          0       1
#> 4    4   FALSE         3    Petal.Width        5.00          0       1
#> 5    5   FALSE         4   Petal.Length        1.75          0       1
#> 6    6    TRUE        NA           <NA>          NA          2       1
#> 7    7    TRUE        NA           <NA>          NA          3       1
#> 8    8    TRUE        NA           <NA>          NA          2       1
#> 9    9    TRUE        NA           <NA>          NA          3       1
#>          label
#> 1 Petal.Length
#> 2       setosa
#> 3 Petal.Length
#> 4  Petal.Width
#> 5 Petal.Length
#> 6   versicolor
#> 7    virginica
#> 8   versicolor
#> 9    virginica
```

Columns:

| Column           | Description                                                  |
|------------------|--------------------------------------------------------------|
| `name`           | Node ID (matches edgelist `from`/`to`)                       |
| `is_leaf`        | Logical                                                      |
| `split_var`      | Numeric variable index (NA for leaves)                       |
| `split_var_name` | Variable name (NA for leaves)                                |
| `split_point`    | Split threshold (NA for leaves)                              |
| `prediction`     | Predicted value                                              |
| `treenum`        | Tree number                                                  |
| `label`          | `split_var_name` for internal nodes, `prediction` for leaves |

## Data frame

### edgelist()

When your data is already tabular,
[`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
reshapes it into from-to format. Columns are specified with
[tidyselect](https://tidyselect.r-lib.org/reference/language.html)
syntax — bare names, strings, numbers, or helpers like
[`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html).

``` r
courses
#>    dept  course  prereq prereq2 crosslist credits level
#> 1  STAT stat101 math101    <NA>      <NA>       3   100
#> 2  STAT stat102 stat101    <NA>   math102       4   100
#> 3  STAT stat202 stat101    <NA>   data202       3   200
#> 4  MATH math101    <NA>    <NA>      <NA>       3   100
#> 5  MATH math102 stat101    <NA>   stat102       4   100
#> 6  DATA data202 stat101    <NA>   stat202       3   200
#> 7    CS   cs101    <NA>    <NA>      <NA>       3   100
#> 8    CS   cs201   cs101    <NA>      <NA>       4   200
#> 9    CS   cs301   cs201 math201   math301       3   300
#> 10 MATH math201 math101    <NA>      <NA>       3   200
#> 11 MATH math301   cs201 math201     cs301       4   300
#> 12 DATA data301 stat202   cs201   stat301       3   300
#> 13 STAT stat301 stat202   cs201   data301       4   300

edgelist(courses, source_cols = course, target_cols = prereq)
#>       from      to from_col to_col dept prereq2 crosslist credits level
#> 1  stat101 math101   course prereq STAT    <NA>      <NA>       3   100
#> 2  stat102 stat101   course prereq STAT    <NA>   math102       4   100
#> 3  stat202 stat101   course prereq STAT    <NA>   data202       3   200
#> 4  math102 stat101   course prereq MATH    <NA>   stat102       4   100
#> 5  data202 stat101   course prereq DATA    <NA>   stat202       3   200
#> 6    cs201   cs101   course prereq   CS    <NA>      <NA>       4   200
#> 7    cs301   cs201   course prereq   CS math201   math301       3   300
#> 8  math201 math101   course prereq MATH    <NA>      <NA>       3   200
#> 9  math301   cs201   course prereq MATH math201     cs301       4   300
#> 10 data301 stat202   course prereq DATA   cs201   stat301       3   300
#> 11 stat301 stat202   course prereq STAT   cs201   data301       4   300
```

#### Multiple target columns

When you pass multiple `target_cols`, each produces a block of edges.
The `to_col` column identifies which relationship each edge came from:

``` r
edgelist(courses, source_cols = course,
         target_cols = c(prereq, prereq2, crosslist))
#>       from      to from_col    to_col dept credits level
#> 1  stat101 math101   course    prereq STAT       3   100
#> 2  stat102 stat101   course    prereq STAT       4   100
#> 3  stat202 stat101   course    prereq STAT       3   200
#> 4  math102 stat101   course    prereq MATH       4   100
#> 5  data202 stat101   course    prereq DATA       3   200
#> 6    cs201   cs101   course    prereq   CS       4   200
#> 7    cs301   cs201   course    prereq   CS       3   300
#> 8  math201 math101   course    prereq MATH       3   200
#> 9  math301   cs201   course    prereq MATH       4   300
#> 10 data301 stat202   course    prereq DATA       3   300
#> 11 stat301 stat202   course    prereq STAT       4   300
#> 12   cs301 math201   course   prereq2   CS       3   300
#> 13 math301 math201   course   prereq2 MATH       4   300
#> 14 data301   cs201   course   prereq2 DATA       3   300
#> 15 stat301   cs201   course   prereq2 STAT       4   300
#> 16 stat102 math102   course crosslist STAT       4   100
#> 17 stat202 data202   course crosslist STAT       3   200
#> 18 math102 stat102   course crosslist MATH       4   100
#> 19 data202 stat202   course crosslist DATA       3   200
#> 20   cs301 math301   course crosslist   CS       3   300
#> 21 math301   cs301   course crosslist MATH       4   300
#> 22 data301 stat301   course crosslist DATA       3   300
#> 23 stat301 data301   course crosslist STAT       4   300
```

#### `na.rm` — handling missing values

By default, rows where from or to is NA are removed. Set `na.rm = FALSE`
to keep them:

``` r
# Default: NAs removed
nrow(edgelist(courses, source_cols = course,
              target_cols = c(prereq, prereq2, crosslist)))
#> [1] 23

# Keep NAs
nrow(edgelist(courses, source_cols = course,
              target_cols = c(prereq, prereq2, crosslist),
              na.rm = FALSE))
#> [1] 39
```

#### `attr_cols` — selecting edge attributes

By default, all columns not used as source or target are carried along.
Use `attr_cols` to select specific columns, or
[`c()`](https://rdrr.io/r/base/c.html) for none:

``` r
# Only from, to, metadata
edgelist(courses, source_cols = course, target_cols = prereq,
         attr_cols = c())
#>       from      to from_col to_col
#> 1  stat101 math101   course prereq
#> 2  stat102 stat101   course prereq
#> 3  stat202 stat101   course prereq
#> 4  math102 stat101   course prereq
#> 5  data202 stat101   course prereq
#> 6    cs201   cs101   course prereq
#> 7    cs301   cs201   course prereq
#> 8  math201 math101   course prereq
#> 9  math301   cs201   course prereq
#> 10 data301 stat202   course prereq
#> 11 stat301 stat202   course prereq

# Specific columns
edgelist(courses, source_cols = course, target_cols = prereq,
         attr_cols = c(dept, credits))
#>       from      to from_col to_col dept credits
#> 1  stat101 math101   course prereq STAT       3
#> 2  stat102 stat101   course prereq STAT       4
#> 3  stat202 stat101   course prereq STAT       3
#> 4  math102 stat101   course prereq MATH       4
#> 5  data202 stat101   course prereq DATA       3
#> 6    cs201   cs101   course prereq   CS       4
#> 7    cs301   cs201   course prereq   CS       3
#> 8  math201 math101   course prereq MATH       3
#> 9  math301   cs201   course prereq MATH       4
#> 10 data301 stat202   course prereq DATA       3
#> 11 stat301 stat202   course prereq STAT       4
```

#### `symmetric_cols` — marking undirected relationships

Some target columns represent symmetric relationships (crosslists,
co-authorships). Use `symmetric_cols` to add a `directed` column and
automatically deduplicate symmetric edges:

``` r
edgelist(courses, source_cols = course,
         target_cols = c(prereq, prereq2, crosslist),
         attr_cols = c(),
         symmetric_cols = crosslist)
#>       from      to from_col    to_col directed
#> 1  stat101 math101   course    prereq     TRUE
#> 2  stat102 stat101   course    prereq     TRUE
#> 3  stat202 stat101   course    prereq     TRUE
#> 4  math102 stat101   course    prereq     TRUE
#> 5  data202 stat101   course    prereq     TRUE
#> 6    cs201   cs101   course    prereq     TRUE
#> 7    cs301   cs201   course    prereq     TRUE
#> 8  math201 math101   course    prereq     TRUE
#> 9  math301   cs201   course    prereq     TRUE
#> 10 data301 stat202   course    prereq     TRUE
#> 11 stat301 stat202   course    prereq     TRUE
#> 12   cs301 math201   course   prereq2     TRUE
#> 13 math301 math201   course   prereq2     TRUE
#> 14 data301   cs201   course   prereq2     TRUE
#> 15 stat301   cs201   course   prereq2     TRUE
#> 16 math102 stat102   course crosslist    FALSE
#> 17 data202 stat202   course crosslist    FALSE
#> 18   cs301 math301   course crosslist    FALSE
#> 19 data301 stat301   course crosslist    FALSE
```

Prerequisite edges get `directed = TRUE`; crosslist edges get
`directed = FALSE`. Symmetric edges are automatically deduped (only
`from <= to` kept). Set `dedupe = FALSE` to preserve both directions.

### nodelist()

For data frames,
[`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md)
simply reorders columns so the ID column comes first — convenient for
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html):

``` r
nodelist(courses, id_col = course)
#>     course dept  prereq prereq2 crosslist credits level
#> 1  stat101 STAT math101    <NA>      <NA>       3   100
#> 2  stat102 STAT stat101    <NA>   math102       4   100
#> 3  stat202 STAT stat101    <NA>   data202       3   200
#> 4  math101 MATH    <NA>    <NA>      <NA>       3   100
#> 5  math102 MATH stat101    <NA>   stat102       4   100
#> 6  data202 DATA stat101    <NA>   stat202       3   200
#> 7    cs101   CS    <NA>    <NA>      <NA>       3   100
#> 8    cs201   CS   cs101    <NA>      <NA>       4   200
#> 9    cs301   CS   cs201 math201   math301       3   300
#> 10 math201 MATH math101    <NA>      <NA>       3   200
#> 11 math301 MATH   cs201 math201     cs301       4   300
#> 12 data301 DATA stat202   cs201   stat301       3   300
#> 13 stat301 STAT stat202   cs201   data301       4   300
```

### Note on tidygraph

tidygraph provides its own `as_tbl_graph.data.frame()` method that
auto-detects edge data frames with `from`/`to` columns. Since
networkformat already uses `from`/`to`, you can pass an edgelist
directly to tidygraph:

``` r
edges <- edgelist(courses, source_cols = course, target_cols = prereq)
tg <- tidygraph::as_tbl_graph(edges)
```

networkformat does not add its own `as_tbl_graph.data.frame()` method
since tidygraph already covers this case.

### Putting it together: course network

For a complete course network visualization, see
[`vignette("visualization")`](https://jesseabrandt.github.io/networkformat/articles/visualization.md).

Here we build the graph and compute statistics:

``` r
library(igraph)

all_edges <- edgelist(courses, source_cols = course,
                      target_cols = c(prereq, prereq2, crosslist),
                      attr_cols = c(),
                      symmetric_cols = crosslist)

# Reverse prereq arrows so they point from prereq -> dependent course
directed_rows <- all_edges$directed
all_edges[directed_rows, c("from", "to")] <- all_edges[directed_rows, c("to", "from")]

nodes <- nodelist(courses, id_col = course)
g <- graph_from_data_frame(all_edges, vertices = nodes)
```

#### Graph statistics

Once the data is in igraph, you can compute standard graph metrics:

``` r
cat("Nodes:", vcount(g), "\n")
#> Nodes: 13
cat("Edges:", ecount(g), "\n")
#> Edges: 19
cat("Components:", count_components(g), "\n")
#> Components: 1

# In-degree: how many prerequisites each course has
deg_in <- degree(g, mode = "in")
cat("\nMost prerequisites:\n")
#> 
#> Most prerequisites:
print(sort(deg_in[deg_in > 0], decreasing = TRUE))
#> math301 stat301 stat102 stat202   cs301 data301 stat101 math102 data202   cs201 
#>       3       3       2       2       2       2       1       1       1       1 
#> math201 
#>       1

# Out-degree: how many courses depend on this one
deg_out <- degree(g, mode = "out")
cat("\nMost depended-on:\n")
#> 
#> Most depended-on:
print(sort(deg_out[deg_out > 0], decreasing = TRUE))
#> stat101   cs201 stat202 math101 math201 math102 data202   cs101   cs301 data301 
#>       4       4       2       2       2       1       1       1       1       1
```

## Output reference

### edgelist()

| Input class    | Columns returned                                                                    |
|----------------|-------------------------------------------------------------------------------------|
| atomic vector  | `from`, `to`, \[`weight`\]                                                          |
| `data.frame`   | `from`, `to`, `from_col`, `to_col`, \[`directed`\], \[`weight`\], `<attr_cols>`     |
| `tree`         | `from`, `to`, `label`, `split_var`, `split_op`, `split_point`                       |
| `randomForest` | `from`, `to`, `split_var`, `split_point`, `prediction`, `treenum`, `split_var_name` |
| `rpart`        | `from`, `to`, `label`, `split_var`, `split_op`, `split_point`                       |
| `xgb.Booster`  | `from`, `to`, `feature`, `split`, `quality`, `cover`, `treenum`                     |
| `gbm`          | `from`, `to`, `split_var`, `split_point`, `prediction`, `treenum`, `split_var_name` |

> **Note:** rpart uses `<` and `>=` for split operators, while tree uses
> `<` and `>`.

### nodelist()

| Input class    | Columns returned                                                                                  |
|----------------|---------------------------------------------------------------------------------------------------|
| atomic vector  | `name`, `n`                                                                                       |
| `data.frame`   | Reordered input (ID column first)                                                                 |
| `tree`         | `name`, `var`, `n`, `dev`, `yval`, `is_leaf`, `label`                                             |
| `randomForest` | `name`, `is_leaf`, `split_var`, `split_var_name`, `split_point`, `prediction`, `treenum`, `label` |
| `rpart`        | `name`, `var`, `n`, `dev`, `yval`, `is_leaf`, `label`                                             |
| `xgb.Booster`  | `name`, `is_leaf`, `feature`, `split`, `quality`, `cover`, `treenum`, `label`                     |
| `gbm`          | `name`, `is_leaf`, `split_var`, `split_var_name`, `split_point`, `prediction`, `treenum`, `label` |

### as.igraph() / as_tbl_graph()

| Input class    | `treenum`        | Returns                                              |
|----------------|------------------|------------------------------------------------------|
| `tree`         | —                | single graph                                         |
| `randomForest` | `NULL` (default) | single graph (all trees as disconnected components)  |
| `randomForest` | `1`              | single graph (one tree)                              |
| `rpart`        | —                | single graph                                         |
| `xgb.Booster`  | `NULL` (default) | single graph (all trees, globally unique string IDs) |
| `xgb.Booster`  | `1`              | single graph (one tree)                              |
| `gbm`          | `NULL` (default) | single graph (all trees as disconnected components)  |
| `gbm`          | `1`              | single graph (one tree)                              |
