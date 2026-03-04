# Extract Edgelist from Various Object Types

Generic function to extract a network edgelist from various object
types. Methods exist for atomic vectors (sequential edges), data frames
(column-pair edges), and tree-based model objects (`randomForest`,
`tree`, `rpart`, `xgb.Booster`, `gbm`). The specific columns returned
depend on the input type.

## Usage

``` r
edgelist(input_object, ...)
```

## Arguments

- input_object:

  An object to extract an edgelist from

- ...:

  Additional arguments passed to specific methods

## Value

A data.frame representing an edgelist. The specific columns depend on
the input object type.

## Examples

``` r
# Vector --- sequential edges
edgelist(c("A", "B", "C", "D"))
#>   from to
#> 1    A  B
#> 2    B  C
#> 3    C  D

# Data.frame example using bundled dataset
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

# RandomForest example
if (requireNamespace("randomForest", quietly = TRUE)) {
  rf <- randomForest::randomForest(Species ~ ., data = iris, ntree = 5)
  edges_rf <- edgelist(rf)
  head(edges_rf)
}
#>   from to split_var split_point prediction treenum split_var_name
#> 1    1  2         3        2.60          1       1   Petal.Length
#> 2    3  4         3        4.75          0       1   Petal.Length
#> 3    4  6         4        1.65          2       1    Petal.Width
#> 4    5  8         4        1.75          0       1    Petal.Width
#> 5    8 10         1        6.50          0       1   Sepal.Length
#> 6    9 12         1        5.95          0       1   Sepal.Length

# Tree example
if (requireNamespace("tree", quietly = TRUE)) {
  tr <- tree::tree(Species ~ ., data = iris)
  edges_tr <- edgelist(tr)
  head(edges_tr)
}
#>   from to              label    split_var split_op split_point
#> 1    1  2 Petal.Length <2.45 Petal.Length        <        2.45
#> 2    1  3 Petal.Length >2.45 Petal.Length        >        2.45
#> 3    3  6  Petal.Width <1.75  Petal.Width        <        1.75
#> 4    6 12 Petal.Length <4.95 Petal.Length        <        4.95
#> 5   12 24 Sepal.Length <5.15 Sepal.Length        <        5.15
#> 6   12 25 Sepal.Length >5.15 Sepal.Length        >        5.15
```
