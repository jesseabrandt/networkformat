# Extract Node List from Various Objects

Generic function to extract a node list (with attributes) from various
object types including atomic vectors (unique values with frequencies),
data frames, lists (recursive node decomposition), and tree models
(`randomForest`, `tree`, `rpart`, `xgb.Booster`, `gbm`). The node list
provides metadata about each node in the network.

## Usage

``` r
nodelist(input_object, ...)
```

## Arguments

- input_object:

  An object containing node information (vector, data.frame, tree model,
  etc.)

- ...:

  Additional arguments passed to specific methods

## Value

A data.frame where the first column is the node ID and subsequent
columns contain node attributes

## Examples

``` r
# Vector --- unique values with frequency counts
nodelist(c("A", "B", "A", "C"))
#>   name n
#> 1    A 2
#> 2    B 1
#> 3    C 1

# Node list with course as ID (column 2)
nodelist(courses, id_col = 2)
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
