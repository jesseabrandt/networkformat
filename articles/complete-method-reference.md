# Complete method reference

This article demonstrates every
[`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md),
[`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md),
[`as.igraph()`](https://r.igraph.org/reference/as.igraph.html), and
[`as_tbl_graph()`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
method in the package. For a gentler introduction, see
[`vignette("networkformat")`](https://jesseabrandt.github.io/networkformat/articles/networkformat.md).

## Atomic vectors

Vectors produce sequential edges: element *i* connects to element *i +
1*.

### edgelist

``` r
edgelist(c("A", "B", "C", "D"))
#>   from to
#> 1    A  B
#> 2    B  C
#> 3    C  D
```

Numeric vectors work the same way:

``` r
edgelist(c(1, 2, 3))
#>   from to
#> 1    1  2
#> 2    2  3
```

Duplicate edges can be collapsed with `weights = TRUE`:

``` r
edgelist(c("A", "B", "A", "B", "C"), weights = TRUE)
#>   from to weight
#> 1    A  B      2
#> 2    B  A      1
#> 3    B  C      1
```

### nodelist

Returns unique values with frequency counts:

``` r
nodelist(c("A", "B", "A", "B", "C"))
#>   name n
#> 1    A 2
#> 2    B 2
#> 3    C 1
```

------------------------------------------------------------------------

## Lists

Lists produce recursive parent-child edges. Each element becomes a node
with a path-style ID.

### edgelist

``` r
edgelist(list(a = list(b = 1, c = 2), d = 3))
#>     from       to depth
#> 1   root   root/a     1
#> 2 root/a root/a/b     2
#> 3 root/a root/a/c     2
#> 4   root   root/d     1
```

Unnamed elements use positional indices:

``` r
edgelist(list(1, 2, list(3, 4)))
#>         from               to depth
#> 1       root       root/[[1]]     1
#> 2       root       root/[[2]]     1
#> 3       root       root/[[3]]     1
#> 4 root/[[3]] root/[[3]]/[[1]]     2
#> 5 root/[[3]] root/[[3]]/[[2]]     2
```

Limit depth (root = 0, children = 1, …):

``` r
edgelist(list(a = list(b = list(c = 1))), max_depth = 2)
#>     from       to depth
#> 1   root   root/a     1
#> 2 root/a root/a/b     2
```

### nodelist

``` r
nodelist(list(a = list(b = 1, c = 2), d = 3))
#>       name depth    type n_children label
#> 1     root     0    list          2  root
#> 2   root/a     1    list          2     a
#> 3 root/a/b     2 numeric          0     b
#> 4 root/a/c     2 numeric          0     c
#> 5   root/d     1 numeric          0     d
```

### S3 object fallthrough

S3 objects without a dedicated method are decomposed as plain lists:

``` r
fit <- lm(Sepal.Length ~ Sepal.Width, data = iris)
edgelist(fit)
#> No edgelist method for class 'lm'; treating as a plain list.
```

------------------------------------------------------------------------

## Data frames

Data frame methods use tidyselect to specify which columns form edges.

### edgelist

**Basic usage** with the bundled `courses` dataset:

``` r
data(courses)
edgelist(courses, source_cols = prereq, target_cols = course)
#>       from      to from_col to_col dept prereq2 crosslist credits level
#> 1  math101 stat101   prereq course STAT    <NA>      <NA>       3   100
#> 2  stat101 stat102   prereq course STAT    <NA>   math102       4   100
#> 3  stat101 stat202   prereq course STAT    <NA>   data202       3   200
#> 4  stat101 math102   prereq course MATH    <NA>   stat102       4   100
#> 5  stat101 data202   prereq course DATA    <NA>   stat202       3   200
#> 6    cs101   cs201   prereq course   CS    <NA>      <NA>       4   200
#> 7    cs201   cs301   prereq course   CS math201   math301       3   300
#> 8  math101 math201   prereq course MATH    <NA>      <NA>       3   200
#> 9    cs201 math301   prereq course MATH math201     cs301       4   300
#> 10 stat202 data301   prereq course DATA   cs201   stat301       3   300
#> 11 stat202 stat301   prereq course STAT   cs201   data301       4   300
```

**Multiple source columns** — each source column produces a block of
edges, identified by `from_col`:

``` r
edgelist(courses, source_cols = c(prereq, prereq2), target_cols = course)
#>       from      to from_col to_col dept crosslist credits level
#> 1  math101 stat101   prereq course STAT      <NA>       3   100
#> 2  stat101 stat102   prereq course STAT   math102       4   100
#> 3  stat101 stat202   prereq course STAT   data202       3   200
#> 4  stat101 math102   prereq course MATH   stat102       4   100
#> 5  stat101 data202   prereq course DATA   stat202       3   200
#> 6    cs101   cs201   prereq course   CS      <NA>       4   200
#> 7    cs201   cs301   prereq course   CS   math301       3   300
#> 8  math101 math201   prereq course MATH      <NA>       3   200
#> 9    cs201 math301   prereq course MATH     cs301       4   300
#> 10 stat202 data301   prereq course DATA   stat301       3   300
#> 11 stat202 stat301   prereq course STAT   data301       4   300
#> 12 math201   cs301  prereq2 course   CS   math301       3   300
#> 13 math201 math301  prereq2 course MATH     cs301       4   300
#> 14   cs201 data301  prereq2 course DATA   stat301       3   300
#> 15   cs201 stat301  prereq2 course STAT   data301       4   300
```

**Keeping NAs** (default is `na.rm = TRUE`):

``` r
edgelist(courses, source_cols = prereq, target_cols = course, na.rm = FALSE)
#>       from      to from_col to_col dept prereq2 crosslist credits level
#> 1  math101 stat101   prereq course STAT    <NA>      <NA>       3   100
#> 2  stat101 stat102   prereq course STAT    <NA>   math102       4   100
#> 3  stat101 stat202   prereq course STAT    <NA>   data202       3   200
#> 4     <NA> math101   prereq course MATH    <NA>      <NA>       3   100
#> 5  stat101 math102   prereq course MATH    <NA>   stat102       4   100
#> 6  stat101 data202   prereq course DATA    <NA>   stat202       3   200
#> 7     <NA>   cs101   prereq course   CS    <NA>      <NA>       3   100
#> 8    cs101   cs201   prereq course   CS    <NA>      <NA>       4   200
#> 9    cs201   cs301   prereq course   CS math201   math301       3   300
#> 10 math101 math201   prereq course MATH    <NA>      <NA>       3   200
#> 11   cs201 math301   prereq course MATH math201     cs301       4   300
#> 12 stat202 data301   prereq course DATA   cs201   stat301       3   300
#> 13 stat202 stat301   prereq course STAT   cs201   data301       4   300
```

**Controlling attribute columns** — by default all non-edge columns are
carried through. Use `attr_cols` to select specific ones:

``` r
edgelist(courses, source_cols = prereq, target_cols = course,
         attr_cols = c(dept, credits))
#>       from      to from_col to_col dept credits
#> 1  math101 stat101   prereq course STAT       3
#> 2  stat101 stat102   prereq course STAT       4
#> 3  stat101 stat202   prereq course STAT       3
#> 4  stat101 math102   prereq course MATH       4
#> 5  stat101 data202   prereq course DATA       3
#> 6    cs101   cs201   prereq course   CS       4
#> 7    cs201   cs301   prereq course   CS       3
#> 8  math101 math201   prereq course MATH       3
#> 9    cs201 math301   prereq course MATH       4
#> 10 stat202 data301   prereq course DATA       3
#> 11 stat202 stat301   prereq course STAT       4
```

Or pass [`c()`](https://rdrr.io/r/base/c.html) to drop all attributes:

``` r
edgelist(courses, source_cols = prereq, target_cols = course, attr_cols = c())
#>       from      to from_col to_col
#> 1  math101 stat101   prereq course
#> 2  stat101 stat102   prereq course
#> 3  stat101 stat202   prereq course
#> 4  stat101 math102   prereq course
#> 5  stat101 data202   prereq course
#> 6    cs101   cs201   prereq course
#> 7    cs201   cs301   prereq course
#> 8  math101 math201   prereq course
#> 9    cs201 math301   prereq course
#> 10 stat202 data301   prereq course
#> 11 stat202 stat301   prereq course
```

**Symmetric (undirected) edges** with automatic deduplication:

``` r
edgelist(courses, source_cols = course, target_cols = crosslist,
         symmetric_cols = crosslist, dedupe = TRUE)
#>      from      to from_col    to_col directed dept  prereq prereq2 credits
#> 1 math102 stat102   course crosslist    FALSE MATH stat101    <NA>       4
#> 2 data202 stat202   course crosslist    FALSE DATA stat101    <NA>       3
#> 3   cs301 math301   course crosslist    FALSE   CS   cs201 math201       3
#> 4 data301 stat301   course crosslist    FALSE DATA stat202   cs201       3
#>   level
#> 1   100
#> 2   200
#> 3   300
#> 4   300
```

**Edge weights** — collapse identical rows and count:

``` r
edgelist(courses, source_cols = prereq, target_cols = course, weights = TRUE)
#>       from      to from_col to_col dept prereq2 crosslist credits level weight
#> 1  math101 stat101   prereq course STAT    <NA>      <NA>       3   100      1
#> 2  stat101 stat102   prereq course STAT    <NA>   math102       4   100      1
#> 3  stat101 stat202   prereq course STAT    <NA>   data202       3   200      1
#> 4  stat101 math102   prereq course MATH    <NA>   stat102       4   100      1
#> 5  stat101 data202   prereq course DATA    <NA>   stat202       3   200      1
#> 6    cs101   cs201   prereq course   CS    <NA>      <NA>       4   200      1
#> 7    cs201   cs301   prereq course   CS math201   math301       3   300      1
#> 8  math101 math201   prereq course MATH    <NA>      <NA>       3   200      1
#> 9    cs201 math301   prereq course MATH math201     cs301       4   300      1
#> 10 stat202 data301   prereq course DATA   cs201   stat301       3   300      1
#> 11 stat202 stat301   prereq course STAT   cs201   data301       4   300      1
```

**Mixed directed and undirected edges:**

``` r
edgelist(courses,
         source_cols = course,
         target_cols = c(prereq, crosslist),
         symmetric_cols = crosslist)
#>       from      to from_col    to_col directed dept prereq2 credits level
#> 1  stat101 math101   course    prereq     TRUE STAT    <NA>       3   100
#> 2  stat102 stat101   course    prereq     TRUE STAT    <NA>       4   100
#> 3  stat202 stat101   course    prereq     TRUE STAT    <NA>       3   200
#> 4  math102 stat101   course    prereq     TRUE MATH    <NA>       4   100
#> 5  data202 stat101   course    prereq     TRUE DATA    <NA>       3   200
#> 6    cs201   cs101   course    prereq     TRUE   CS    <NA>       4   200
#> 7    cs301   cs201   course    prereq     TRUE   CS math201       3   300
#> 8  math201 math101   course    prereq     TRUE MATH    <NA>       3   200
#> 9  math301   cs201   course    prereq     TRUE MATH math201       4   300
#> 10 data301 stat202   course    prereq     TRUE DATA   cs201       3   300
#> 11 stat301 stat202   course    prereq     TRUE STAT   cs201       4   300
#> 12 math102 stat102   course crosslist    FALSE MATH    <NA>       4   100
#> 13 data202 stat202   course crosslist    FALSE DATA    <NA>       3   200
#> 14   cs301 math301   course crosslist    FALSE   CS math201       3   300
#> 15 data301 stat301   course crosslist    FALSE DATA   cs201       3   300
```

### nodelist

Reorders the data frame so the ID column comes first:

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

------------------------------------------------------------------------

## Decision trees (tree)

``` r
library(tree)
tr <- tree(Species ~ ., iris)
```

### edgelist

``` r
edgelist(tr)
#>    from to              label    split_var split_op split_point
#> 1     1  2 Petal.Length <2.45 Petal.Length        <        2.45
#> 2     1  3 Petal.Length >2.45 Petal.Length        >        2.45
#> 3     3  6  Petal.Width <1.75  Petal.Width        <        1.75
#> 4     6 12 Petal.Length <4.95 Petal.Length        <        4.95
#> 5    12 24 Sepal.Length <5.15 Sepal.Length        <        5.15
#> 6    12 25 Sepal.Length >5.15 Sepal.Length        >        5.15
#> 7     6 13 Petal.Length >4.95 Petal.Length        >        4.95
#> 8     3  7  Petal.Width >1.75  Petal.Width        >        1.75
#> 9     7 14 Petal.Length <4.95 Petal.Length        <        4.95
#> 10    7 15 Petal.Length >4.95 Petal.Length        >        4.95
```

### nodelist

``` r
nodelist(tr)
#>    name          var   n        dev       yval is_leaf               label
#> 1     1 Petal.Length 150 329.583687     setosa   FALSE Petal.Length\nn=150
#> 2     2       <leaf>  50   0.000000     setosa    TRUE        setosa\nn=50
#> 3     3  Petal.Width 100 138.629436 versicolor   FALSE  Petal.Width\nn=100
#> 4     6 Petal.Length  54  33.317509 versicolor   FALSE  Petal.Length\nn=54
#> 5    12 Sepal.Length  48   9.721422 versicolor   FALSE  Sepal.Length\nn=48
#> 6    24       <leaf>   5   5.004024 versicolor    TRUE     versicolor\nn=5
#> 7    25       <leaf>  43   0.000000 versicolor    TRUE    versicolor\nn=43
#> 8    13       <leaf>   6   7.638170  virginica    TRUE      virginica\nn=6
#> 9     7 Petal.Length  46   9.635384  virginica   FALSE  Petal.Length\nn=46
#> 10   14       <leaf>   6   5.406735  virginica    TRUE      virginica\nn=6
#> 11   15       <leaf>  40   0.000000  virginica    TRUE     virginica\nn=40
```

### as.igraph

``` r
library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following object is masked from 'package:tree':
#> 
#>     tree
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
g <- as.igraph(tr)
g
#> IGRAPH 90a0906 DN-- 11 10 -- 
#> + attr: name (v/c), var (v/c), n (v/n), dev (v/n), yval (v/c), is_leaf
#> | (v/l), label (v/c), label (e/c), split_var (e/c), split_op (e/c),
#> | split_point (e/n)
#> + edges from 90a0906 (vertex names):
#>  [1] 1 ->2  1 ->3  3 ->6  6 ->12 12->24 12->25 6 ->13 3 ->7  7 ->14 7 ->15
```

``` r
vcount(g)
#> [1] 11
ecount(g)
#> [1] 10
```

### as_tbl_graph

``` r
library(tidygraph)
#> 
#> Attaching package: 'tidygraph'
#> The following object is masked from 'package:igraph':
#> 
#>     groups
#> The following object is masked from 'package:stats':
#> 
#>     filter
as_tbl_graph(tr)
#> # A tbl_graph: 11 nodes and 10 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 11 × 7 (active)
#>    name  var              n    dev yval       is_leaf label                
#>    <chr> <chr>        <dbl>  <dbl> <chr>      <lgl>   <chr>                
#>  1 1     Petal.Length   150 330.   setosa     FALSE   "Petal.Length\nn=150"
#>  2 2     <leaf>          50   0    setosa     TRUE    "setosa\nn=50"       
#>  3 3     Petal.Width    100 139.   versicolor FALSE   "Petal.Width\nn=100" 
#>  4 6     Petal.Length    54  33.3  versicolor FALSE   "Petal.Length\nn=54" 
#>  5 12    Sepal.Length    48   9.72 versicolor FALSE   "Sepal.Length\nn=48" 
#>  6 24    <leaf>           5   5.00 versicolor TRUE    "versicolor\nn=5"    
#>  7 25    <leaf>          43   0    versicolor TRUE    "versicolor\nn=43"   
#>  8 13    <leaf>           6   7.64 virginica  TRUE    "virginica\nn=6"     
#>  9 7     Petal.Length    46   9.64 virginica  FALSE   "Petal.Length\nn=46" 
#> 10 14    <leaf>           6   5.41 virginica  TRUE    "virginica\nn=6"     
#> 11 15    <leaf>          40   0    virginica  TRUE    "virginica\nn=40"    
#> #
#> # Edge Data: 10 × 6
#>    from    to label              split_var    split_op split_point
#>   <int> <int> <chr>              <chr>        <chr>          <dbl>
#> 1     1     2 Petal.Length <2.45 Petal.Length <               2.45
#> 2     1     3 Petal.Length >2.45 Petal.Length >               2.45
#> 3     3     4 Petal.Width <1.75  Petal.Width  <               1.75
#> # ℹ 7 more rows
```

------------------------------------------------------------------------

## Random forests (randomForest)

``` r
library(randomForest)
#> randomForest 4.7-1.2
#> Type rfNews() to see new features/changes/bug fixes.
set.seed(42)
rf <- randomForest(Species ~ ., iris, ntree = 3)
```

### edgelist

All trees:

``` r
edgelist(rf)
#>    from to split_var split_point prediction treenum split_var_name
#> 1     1  2         3        4.75          0       1   Petal.Length
#> 2     2  4         3        2.45          1       1   Petal.Length
#> 3     3  6         3        5.05          0       1   Petal.Length
#> 4     6  8         4        1.75          2       1    Petal.Width
#> 5     1  3         3        4.75          0       1   Petal.Length
#> 6     2  5         3        2.45          2       1   Petal.Length
#> 7     3  7         3        5.05          3       1   Petal.Length
#> 8     6  9         4        1.75          3       1    Petal.Width
#> 9     1  2         4        0.80          1       2    Petal.Width
#> 10    3  4         4        1.75          0       2    Petal.Width
#> 11    4  6         3        5.30          0       2   Petal.Length
#> 12    5  8         3        4.85          0       2   Petal.Length
#> 13    6 10         3        4.95          0       2   Petal.Length
#> 14    8 12         1        5.95          2       2   Sepal.Length
#> 15   10 14         1        5.00          0       2   Sepal.Length
#> 16   11 16         2        2.60          3       2    Sepal.Width
#> 17   14 18         4        1.35          2       2    Petal.Width
#> 18    1  3         4        0.80          0       2    Petal.Width
#> 19    3  5         4        1.75          0       2    Petal.Width
#> 20    4  7         3        5.30          3       2   Petal.Length
#> 21    5  9         3        4.85          3       2   Petal.Length
#> 22    6 11         3        4.95          0       2   Petal.Length
#> 23    8 13         1        5.95          3       2   Sepal.Length
#> 24   10 15         1        5.00          2       2   Sepal.Length
#> 25   11 17         2        2.60          2       2    Sepal.Width
#> 26   14 19         4        1.35          3       2    Petal.Width
#> 27    1  2         4        0.80          1       3    Petal.Width
#> 28    3  4         4        1.75          0       3    Petal.Width
#> 29    4  6         3        5.05          2       3   Petal.Length
#> 30    1  3         4        0.80          0       3    Petal.Width
#> 31    3  5         4        1.75          3       3    Petal.Width
#> 32    4  7         3        5.05          3       3   Petal.Length
```

A single tree:

``` r
edgelist(rf, treenum = 1)
#>   from to split_var split_point prediction treenum split_var_name
#> 1    1  2         3        4.75          0       1   Petal.Length
#> 2    2  4         3        2.45          1       1   Petal.Length
#> 3    3  6         3        5.05          0       1   Petal.Length
#> 4    6  8         4        1.75          2       1    Petal.Width
#> 5    1  3         3        4.75          0       1   Petal.Length
#> 6    2  5         3        2.45          2       1   Petal.Length
#> 7    3  7         3        5.05          3       1   Petal.Length
#> 8    6  9         4        1.75          3       1    Petal.Width
```

Multiple specific trees:

``` r
edgelist(rf, treenum = c(1, 3))
#>    from to split_var split_point prediction treenum split_var_name
#> 1     1  2         3        4.75          0       1   Petal.Length
#> 2     2  4         3        2.45          1       1   Petal.Length
#> 3     3  6         3        5.05          0       1   Petal.Length
#> 4     6  8         4        1.75          2       1    Petal.Width
#> 5     1  3         3        4.75          0       1   Petal.Length
#> 6     2  5         3        2.45          2       1   Petal.Length
#> 7     3  7         3        5.05          3       1   Petal.Length
#> 8     6  9         4        1.75          3       1    Petal.Width
#> 9     1  2         4        0.80          1       3    Petal.Width
#> 10    3  4         4        1.75          0       3    Petal.Width
#> 11    4  6         3        5.05          2       3   Petal.Length
#> 12    1  3         4        0.80          0       3    Petal.Width
#> 13    3  5         4        1.75          3       3    Petal.Width
#> 14    4  7         3        5.05          3       3   Petal.Length
```

### nodelist

``` r
nodelist(rf, treenum = 1)
#>   name is_leaf split_var split_var_name split_point prediction treenum
#> 1    1   FALSE         3   Petal.Length        4.75          0       1
#> 2    2   FALSE         3   Petal.Length        2.45          0       1
#> 3    3   FALSE         3   Petal.Length        5.05          0       1
#> 4    4    TRUE        NA           <NA>          NA          1       1
#> 5    5    TRUE        NA           <NA>          NA          2       1
#> 6    6   FALSE         4    Petal.Width        1.75          0       1
#> 7    7    TRUE        NA           <NA>          NA          3       1
#> 8    8    TRUE        NA           <NA>          NA          2       1
#> 9    9    TRUE        NA           <NA>          NA          3       1
#>                  label
#> 1 Petal.Length\n< 4.75
#> 2 Petal.Length\n< 2.45
#> 3 Petal.Length\n< 5.05
#> 4               setosa
#> 5           versicolor
#> 6  Petal.Width\n< 1.75
#> 7            virginica
#> 8           versicolor
#> 9            virginica
```

### as.igraph

Single tree:

``` r
g <- as.igraph(rf, treenum = 1)
g
#> IGRAPH feb3b25 DN-- 9 8 -- 
#> + attr: name (v/c), is_leaf (v/l), split_var (v/n), split_var_name
#> | (v/c), split_point (v/n), prediction (v/n), treenum (v/n), label
#> | (v/c), split_var (e/n), split_point (e/n), prediction (e/n), treenum
#> | (e/n), split_var_name (e/c)
#> + edges from feb3b25 (vertex names):
#> [1] 1->2 2->4 3->6 6->8 1->3 2->5 3->7 6->9
```

Multiple trees produce disconnected components:

``` r
g_all <- as.igraph(rf)
components(g_all)$no
#> [1] 3
```

### as_tbl_graph

``` r
as_tbl_graph(rf, treenum = 1)
#> # A tbl_graph: 9 nodes and 8 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 9 × 8 (active)
#>   name  is_leaf split_var split_var_name split_point prediction treenum label   
#>   <chr> <lgl>       <dbl> <chr>                <dbl>      <dbl>   <int> <chr>   
#> 1 1     FALSE           3 Petal.Length          4.75          0       1 "Petal.…
#> 2 2     FALSE           3 Petal.Length          2.45          0       1 "Petal.…
#> 3 3     FALSE           3 Petal.Length          5.05          0       1 "Petal.…
#> 4 4     TRUE           NA NA                   NA             1       1 "setosa"
#> 5 5     TRUE           NA NA                   NA             2       1 "versic…
#> 6 6     FALSE           4 Petal.Width           1.75          0       1 "Petal.…
#> 7 7     TRUE           NA NA                   NA             3       1 "virgin…
#> 8 8     TRUE           NA NA                   NA             2       1 "versic…
#> 9 9     TRUE           NA NA                   NA             3       1 "virgin…
#> #
#> # Edge Data: 8 × 7
#>    from    to split_var split_point prediction treenum split_var_name
#>   <int> <int>     <dbl>       <dbl>      <dbl>   <int> <chr>         
#> 1     1     2         3        4.75          0       1 Petal.Length  
#> 2     2     4         3        2.45          1       1 Petal.Length  
#> 3     3     6         3        5.05          0       1 Petal.Length  
#> # ℹ 5 more rows
```

------------------------------------------------------------------------

## Recursive partitioning (rpart)

``` r
library(rpart)
rp <- rpart(Species ~ ., iris)
```

### edgelist

``` r
edgelist(rp)
#>   from to              label    split_var split_op split_point
#> 1    1  2 Petal.Length< 2.45 Petal.Length        <        2.45
#> 2    1  3 Petal.Length>=2.45 Petal.Length       >=        2.45
#> 3    3  6  Petal.Width< 1.75  Petal.Width        <        1.75
#> 4    3  7  Petal.Width>=1.75  Petal.Width       >=        1.75
```

### nodelist

``` r
nodelist(rp)
#>   name          var   n dev       yval is_leaf               label
#> 1    1 Petal.Length 150 100     setosa   FALSE Petal.Length\nn=150
#> 2    2       <leaf>  50   0     setosa    TRUE        setosa\nn=50
#> 3    3  Petal.Width 100  50 versicolor   FALSE  Petal.Width\nn=100
#> 4    6       <leaf>  54   5 versicolor    TRUE    versicolor\nn=54
#> 5    7       <leaf>  46   1  virginica    TRUE     virginica\nn=46
```

### as.igraph

``` r
g <- as.igraph(rp)
g
#> IGRAPH 21f01db DN-- 5 4 -- 
#> + attr: name (v/c), var (v/c), n (v/n), dev (v/n), yval (v/c), is_leaf
#> | (v/l), label (v/c), label (e/c), split_var (e/c), split_op (e/c),
#> | split_point (e/n)
#> + edges from 21f01db (vertex names):
#> [1] 1->2 1->3 3->6 3->7
```

### as_tbl_graph

``` r
as_tbl_graph(rp)
#> # A tbl_graph: 5 nodes and 4 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 5 × 7 (active)
#>   name  var              n   dev yval       is_leaf label                
#>   <chr> <chr>        <int> <dbl> <chr>      <lgl>   <chr>                
#> 1 1     Petal.Length   150   100 setosa     FALSE   "Petal.Length\nn=150"
#> 2 2     <leaf>          50     0 setosa     TRUE    "setosa\nn=50"       
#> 3 3     Petal.Width    100    50 versicolor FALSE   "Petal.Width\nn=100" 
#> 4 6     <leaf>          54     5 versicolor TRUE    "versicolor\nn=54"   
#> 5 7     <leaf>          46     1 virginica  TRUE    "virginica\nn=46"    
#> #
#> # Edge Data: 4 × 6
#>    from    to label              split_var    split_op split_point
#>   <int> <int> <chr>              <chr>        <chr>          <dbl>
#> 1     1     2 Petal.Length< 2.45 Petal.Length <               2.45
#> 2     1     3 Petal.Length>=2.45 Petal.Length >=              2.45
#> 3     3     4 Petal.Width< 1.75  Petal.Width  <               1.75
#> # ℹ 1 more row
```

------------------------------------------------------------------------

## Gradient boosted models (gbm)

``` r
library(gbm)
#> Loaded gbm 2.2.3
#> This version of gbm is no longer under development. Consider transitioning to gbm3, https://github.com/gbm-developers/gbm3
set.seed(42)
gb <- gbm(as.numeric(Species == "setosa") ~ ., data = iris,
           distribution = "bernoulli", n.trees = 3, interaction.depth = 3)
```

### edgelist

All trees:

``` r
edgelist(gb)
#>    from to split_var split_point prediction treenum split_var_name
#> 1     0  1         2        2.60  0.3000000       1   Petal.Length
#> 2     2  3         2        4.65 -0.1500000       1   Petal.Length
#> 3     4  5         0        6.75 -0.1500000       1   Sepal.Length
#> 4     0  2         2        2.60 -0.1500000       1   Petal.Length
#> 5     2  4         2        4.65 -0.1500000       1   Petal.Length
#> 6     4  6         0        6.75 -0.1500000       1   Sepal.Length
#> 7     0  1         2        2.60  0.2481636       2   Petal.Length
#> 8     2  3         1        2.65 -0.1430354       2    Sepal.Width
#> 9     4  5         0        6.75 -0.1430354       2   Sepal.Length
#> 10    0  2         2        2.60 -0.1430354       2   Petal.Length
#> 11    2  4         1        2.65 -0.1430354       2    Sepal.Width
#> 12    4  6         0        6.75 -0.1430354       2   Sepal.Length
#> 13    0  1         2        2.60  0.2156021       3   Petal.Length
#> 14    2  3         1        3.15 -0.1372998       3    Sepal.Width
#> 15    3  4         1        2.95 -0.1372998       3    Sepal.Width
#> 16    0  2         2        2.60 -0.1372998       3   Petal.Length
#> 17    2  7         1        3.15 -0.1372998       3    Sepal.Width
#> 18    3  5         1        2.95 -0.1372998       3    Sepal.Width
```

A single tree:

``` r
edgelist(gb, treenum = 1)
#>   from to split_var split_point prediction treenum split_var_name
#> 1    0  1         2        2.60       0.30       1   Petal.Length
#> 2    2  3         2        4.65      -0.15       1   Petal.Length
#> 3    4  5         0        6.75      -0.15       1   Sepal.Length
#> 4    0  2         2        2.60      -0.15       1   Petal.Length
#> 5    2  4         2        4.65      -0.15       1   Petal.Length
#> 6    4  6         0        6.75      -0.15       1   Sepal.Length
```

### nodelist

``` r
nodelist(gb, treenum = 1)
#>   name is_leaf split_var split_var_name split_point prediction treenum
#> 1    0   FALSE         2   Petal.Length        2.60      -0.03       1
#> 2    1    TRUE        NA           <NA>          NA       0.30       1
#> 3    2   FALSE         2   Sepal.Length        4.65      -0.15       1
#> 4    3    TRUE        NA           <NA>          NA      -0.15       1
#> 5    4   FALSE         0   Petal.Length        6.75      -0.15       1
#> 6    5    TRUE        NA           <NA>          NA      -0.15       1
#> 7    6    TRUE        NA           <NA>          NA      -0.15       1
#>                  label
#> 1  Petal.Length\n< 2.6
#> 2                  0.3
#> 3 Sepal.Length\n< 4.65
#> 4                -0.15
#> 5 Petal.Length\n< 6.75
#> 6                -0.15
#> 7                -0.15
```

### as.igraph

``` r
g <- as.igraph(gb, treenum = 1)
g
#> IGRAPH 20f5952 DN-- 7 6 -- 
#> + attr: name (v/c), is_leaf (v/l), split_var (v/n), split_var_name
#> | (v/c), split_point (v/n), prediction (v/n), treenum (v/n), label
#> | (v/c), split_var (e/n), split_point (e/n), prediction (e/n), treenum
#> | (e/n), split_var_name (e/c)
#> + edges from 20f5952 (vertex names):
#> [1] 0->1 2->3 4->5 0->2 2->4 4->6
```

### as_tbl_graph

``` r
as_tbl_graph(gb, treenum = 1)
#> # A tbl_graph: 7 nodes and 6 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 7 × 8 (active)
#>   name  is_leaf split_var split_var_name split_point prediction treenum label   
#>   <chr> <lgl>       <int> <chr>                <dbl>      <dbl>   <int> <chr>   
#> 1 0     FALSE           2 Petal.Length          2.6     -0.0300       1 "Petal.…
#> 2 1     TRUE           NA NA                   NA        0.3          1 "0.3"   
#> 3 2     FALSE           2 Sepal.Length          4.65    -0.150        1 "Sepal.…
#> 4 3     TRUE           NA NA                   NA       -0.150        1 "-0.15" 
#> 5 4     FALSE           0 Petal.Length          6.75    -0.150        1 "Petal.…
#> 6 5     TRUE           NA NA                   NA       -0.150        1 "-0.15" 
#> 7 6     TRUE           NA NA                   NA       -0.15         1 "-0.15" 
#> #
#> # Edge Data: 6 × 7
#>    from    to split_var split_point prediction treenum split_var_name
#>   <int> <int>     <int>       <dbl>      <dbl>   <int> <chr>         
#> 1     1     2         2        2.6       0.3         1 Petal.Length  
#> 2     3     4         2        4.65     -0.150       1 Petal.Length  
#> 3     5     6         0        6.75     -0.150       1 Sepal.Length  
#> # ℹ 3 more rows
```

------------------------------------------------------------------------

## XGBoost (xgb.Booster)

``` r
library(xgboost)
set.seed(42)
xg <- xgboost(
  x = as.matrix(iris[, 1:4]),
  y = iris$Species,
  max_depth = 3, nrounds = 3, nthreads = 1
)
```

### edgelist

All trees:

``` r
edgelist(xg)
#>    from   to      feature split    quality     cover treenum
#> 1   0-0  0-1 Petal.Length   3.0 72.2967682 66.666664       1
#> 2   1-0  1-1 Petal.Length   3.0 18.0741920 66.666664       2
#> 3   1-2  1-3  Petal.Width   1.8 41.9078407 44.444443       2
#> 4   1-3  1-5 Petal.Length   5.0  4.5898476 23.999998       2
#> 5   1-4  1-7 Petal.Length   4.9  0.6351576 20.444443       2
#> 6   2-0  2-1  Petal.Width   1.7 59.7229652 66.666664       3
#> 7   2-1  2-3 Petal.Length   5.0  5.9654484 45.333332       3
#> 8   3-0  3-1 Petal.Length   3.0 41.9914627 63.163574       4
#> 9   4-0  4-1 Petal.Length   3.0 11.7548246 63.456448       5
#> 10  4-2  4-3  Petal.Width   1.8 23.5355282 44.400250       5
#> 11  4-3  4-5 Petal.Length   5.0  2.0623436 26.588076       5
#> 12  4-4  4-7 Petal.Length   4.9  0.5906615 17.812176       5
#> 13  5-0  5-1 Petal.Length   4.8 34.7396088 63.299583       6
#> 14  5-1  5-3  Petal.Width   1.6  0.6339808 36.284084       6
#> 15  5-2  5-5  Petal.Width   1.8  2.0621681 27.015499       6
#> 16  5-5  5-7 Petal.Length   5.0  0.7504075  4.057225       6
#> 17  5-6  5-9 Petal.Length   4.9  0.3299580 22.958273       6
#> 18  6-0  6-1 Petal.Length   3.0 27.3392334 55.527676       7
#> 19  7-0  7-1 Petal.Length   3.0  8.0142965 56.421551       8
#> 20  7-2  7-3  Petal.Width   1.8 14.7380676 40.646343       8
#> 21  7-3  7-5 Petal.Length   5.1  1.3865748 25.626188       8
#> 22  7-4  7-7 Petal.Length   4.9  0.4830818 15.020156       8
#> 23  8-0  8-1 Petal.Length   4.8 22.4315434 56.237896       9
#> 24  8-1  8-3  Petal.Width   1.6  0.6217213 30.168503       9
#> 25  8-2  8-5  Petal.Width   1.8  1.2727337 26.069391       9
#> 26  8-5  8-7 Petal.Length   5.1  0.5133693  3.983250       9
#> 27  8-6  8-9 Petal.Length   4.9  0.1985664 22.086142       9
#> 28  0-0  0-2 Petal.Length   3.0 72.2967682 66.666664       1
#> 29  1-0  1-2 Petal.Length   3.0 18.0741920 66.666664       2
#> 30  1-2  1-4  Petal.Width   1.8 41.9078407 44.444443       2
#> 31  1-3  1-6 Petal.Length   5.0  4.5898476 23.999998       2
#> 32  1-4  1-8 Petal.Length   4.9  0.6351576 20.444443       2
#> 33  2-0  2-2  Petal.Width   1.7 59.7229652 66.666664       3
#> 34  2-1  2-4 Petal.Length   5.0  5.9654484 45.333332       3
#> 35  3-0  3-2 Petal.Length   3.0 41.9914627 63.163574       4
#> 36  4-0  4-2 Petal.Length   3.0 11.7548246 63.456448       5
#> 37  4-2  4-4  Petal.Width   1.8 23.5355282 44.400250       5
#> 38  4-3  4-6 Petal.Length   5.0  2.0623436 26.588076       5
#> 39  4-4  4-8 Petal.Length   4.9  0.5906615 17.812176       5
#> 40  5-0  5-2 Petal.Length   4.8 34.7396088 63.299583       6
#> 41  5-1  5-4  Petal.Width   1.6  0.6339808 36.284084       6
#> 42  5-2  5-6  Petal.Width   1.8  2.0621681 27.015499       6
#> 43  5-5  5-8 Petal.Length   5.0  0.7504075  4.057225       6
#> 44  5-6 5-10 Petal.Length   4.9  0.3299580 22.958273       6
#> 45  6-0  6-2 Petal.Length   3.0 27.3392334 55.527676       7
#> 46  7-0  7-2 Petal.Length   3.0  8.0142965 56.421551       8
#> 47  7-2  7-4  Petal.Width   1.8 14.7380676 40.646343       8
#> 48  7-3  7-6 Petal.Length   5.1  1.3865748 25.626188       8
#> 49  7-4  7-8 Petal.Length   4.9  0.4830818 15.020156       8
#> 50  8-0  8-2 Petal.Length   4.8 22.4315434 56.237896       9
#> 51  8-1  8-4  Petal.Width   1.6  0.6217213 30.168503       9
#> 52  8-2  8-6  Petal.Width   1.8  1.2727337 26.069391       9
#> 53  8-5  8-8 Petal.Length   5.1  0.5133693  3.983250       9
#> 54  8-6 8-10 Petal.Length   4.9  0.1985664 22.086142       9
```

A single tree:

``` r
edgelist(xg, treenum = 1)
#>   from  to      feature split  quality    cover treenum
#> 1  0-0 0-1 Petal.Length     3 72.29677 66.66666       1
#> 2  0-0 0-2 Petal.Length     3 72.29677 66.66666       1
```

### nodelist

``` r
nodelist(xg, treenum = 1)
#>   name is_leaf      feature split    quality    cover treenum             label
#> 1  0-0   FALSE Petal.Length     3 72.2967682 66.66666       1 Petal.Length\n< 3
#> 2  0-1    TRUE         <NA>    NA  0.4306220 22.22222       1            0.4306
#> 3  0-2    TRUE         <NA>    NA -0.2200489 44.44444       1             -0.22
```

### as.igraph

``` r
g <- as.igraph(xg, treenum = 1)
g
#> IGRAPH 1b626b2 DN-- 3 2 -- 
#> + attr: name (v/c), is_leaf (v/l), feature (v/c), split (v/n), quality
#> | (v/n), cover (v/n), treenum (v/n), label (v/c), feature (e/c), split
#> | (e/n), quality (e/n), cover (e/n), treenum (e/n)
#> + edges from 1b626b2 (vertex names):
#> [1] 0-0->0-1 0-0->0-2
```

### as_tbl_graph

``` r
as_tbl_graph(xg, treenum = 1)
#> # A tbl_graph: 3 nodes and 2 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 3 × 8 (active)
#>   name  is_leaf feature      split quality cover treenum label              
#>   <chr> <lgl>   <chr>        <dbl>   <dbl> <dbl>   <int> <chr>              
#> 1 0-0   FALSE   Petal.Length     3  72.3    66.7       1 "Petal.Length\n< 3"
#> 2 0-1   TRUE    NA              NA   0.431  22.2       1 "0.4306"           
#> 3 0-2   TRUE    NA              NA  -0.220  44.4       1 "-0.22"            
#> #
#> # Edge Data: 2 × 7
#>    from    to feature      split quality cover treenum
#>   <int> <int> <chr>        <dbl>   <dbl> <dbl>   <int>
#> 1     1     2 Petal.Length     3    72.3  66.7       1
#> 2     1     3 Petal.Length     3    72.3  66.7       1
```

------------------------------------------------------------------------

## Output column reference

### edgelist columns by input type

| Input        | Columns                                                                             |
|--------------|-------------------------------------------------------------------------------------|
| vector       | `from`, `to`, \[`weight`\]                                                          |
| list         | `from`, `to`, `depth`                                                               |
| data.frame   | `from`, `to`, `from_col`, `to_col`, \[`directed`\], \[`weight`\], \<attrs\>         |
| tree         | `from`, `to`, `label`, `split_var`, `split_op`, `split_point`                       |
| rpart        | `from`, `to`, `label`, `split_var`, `split_op`, `split_point`                       |
| randomForest | `from`, `to`, `split_var`, `split_point`, `prediction`, `treenum`, `split_var_name` |
| gbm          | `from`, `to`, `split_var`, `split_point`, `prediction`, `treenum`, `split_var_name` |
| xgb.Booster  | `from`, `to`, `feature`, `split`, `quality`, `cover`, `treenum`                     |

### nodelist columns by input type

| Input        | Columns                                                                                           |
|--------------|---------------------------------------------------------------------------------------------------|
| vector       | `name`, `n`                                                                                       |
| list         | `name`, `depth`, `type`, `n_children`, `label`                                                    |
| data.frame   | (input columns reordered, `id_col` first)                                                         |
| tree         | `name`, `var`, `n`, `dev`, `yval`, `is_leaf`, `label`                                             |
| rpart        | `name`, `var`, `n`, `dev`, `yval`, `is_leaf`, `label`                                             |
| randomForest | `name`, `is_leaf`, `split_var`, `split_var_name`, `split_point`, `prediction`, `treenum`, `label` |
| gbm          | `name`, `is_leaf`, `split_var`, `split_var_name`, `split_point`, `prediction`, `treenum`, `label` |
| xgb.Booster  | `name`, `is_leaf`, `feature`, `split`, `quality`, `cover`, `treenum`, `label`                     |
