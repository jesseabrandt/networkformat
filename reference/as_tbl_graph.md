# Convert to tbl_graph

S3 methods for converting tree-based model objects into
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
objects. Each method wraps the corresponding
[`as.igraph`](https://jesseabrandt.github.io/networkformat/reference/as.igraph.md)
method. These methods are registered against the
[`as_tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
generic from tidygraph via delayed S3 registration and are available
whenever tidygraph is loaded.

## Usage

``` r
# S3 method for class 'tree'
as_tbl_graph(x, ...)

# S3 method for class 'randomForest'
as_tbl_graph(x, treenum = NULL, ...)

# S3 method for class 'rpart'
as_tbl_graph(x, ...)

# S3 method for class 'xgb.Booster'
as_tbl_graph(x, treenum = NULL, ...)

# S3 method for class 'gbm'
as_tbl_graph(x, treenum = NULL, ...)
```

## Arguments

- x:

  An object to convert (currently `tree`, `randomForest`, `rpart`,
  `xgb.Booster`, or `gbm`).

- ...:

  Additional arguments passed to
  [`as.igraph`](https://r.igraph.org/reference/as.igraph.html).

- treenum:

  Integer vector of tree numbers to extract. Default `NULL` returns all
  trees combined into one graph with disconnected components. Pass a
  single integer (e.g. `1`) to extract one tree.

## Value

A
[`tbl_graph`](https://tidygraph.data-imaginist.com/reference/tbl_graph.html)
object.

## Examples

``` r
if (requireNamespace("rpart", quietly = TRUE) &&
    requireNamespace("tidygraph", quietly = TRUE) &&
    requireNamespace("igraph", quietly = TRUE)) {
  fit <- rpart::rpart(Sepal.Length ~ ., data = iris)
  tg <- tidygraph::as_tbl_graph(fit)
  tg
}
#> # A tbl_graph: 13 nodes and 12 edges
#> #
#> # A rooted tree
#> #
#> # Node Data: 13 × 13 (active)
#>    name  var             n     dev  yval is_leaf depth    wt complexity ncompete
#>    <chr> <chr>       <int>   <dbl> <dbl> <lgl>   <int> <dbl>      <dbl>    <int>
#>  1 1     Petal.Leng…   150 102.     5.84 FALSE       0   150    0.613          3
#>  2 2     Petal.Leng…    73  13.1    5.18 FALSE       1    73    0.0572         3
#>  3 4     Sepal.Width    53   6.11   5.01 FALSE       2    53    0.0230         2
#>  4 8     <leaf>         20   1.09   4.73 TRUE        3    20    0.00327        0
#>  5 9     <leaf>         33   2.67   5.17 TRUE        3    33    0.00836        0
#>  6 5     <leaf>         20   1.19   5.64 TRUE        2    20    0.00304        0
#>  7 3     Petal.Leng…    77  26.4    6.47 FALSE       1    77    0.122          3
#>  8 6     Petal.Leng…    68  13.5    6.33 FALSE       2    68    0.0298         3
#>  9 12    Sepal.Width    43   8.26   6.17 FALSE       3    43    0.0170         3
#> 10 24    <leaf>         33   5.22   6.05 TRUE        4    33    0.00517        0
#> 11 25    <leaf>         10   1.30   6.53 TRUE        4    10    0.01           0
#> 12 13    <leaf>         25   2.19   6.60 TRUE        3    25    0.00692        0
#> 13 7     <leaf>          9   0.416  7.58 TRUE        2     9    0.01           0
#> # ℹ 3 more variables: nsurrogate <int>, dev_improvement <dbl>, label <chr>
#> #
#> # Edge Data: 12 × 6
#>    from    to label              split_var    split_op split_point
#>   <int> <int> <chr>              <chr>        <chr>          <dbl>
#> 1     1     2 Petal.Length< 4.25 Petal.Length <               4.25
#> 2     2     3 Petal.Length< 3.4  Petal.Length <               3.4 
#> 3     3     4 Sepal.Width< 3.25  Sepal.Width  <               3.25
#> # ℹ 9 more rows
```
