# Extract Edgelist from a Vector or Unsupported Object

When called on an atomic vector (character, numeric, integer, logical,
factor), creates a sequential edgelist connecting each element to the
next: element `i` is connected to element `i + 1`. For all other
unsupported types, an informative error is raised.

## Usage

``` r
# Default S3 method
edgelist(input_object, weights = FALSE, ...)
```

## Arguments

- input_object:

  An atomic vector, or an object for which no specific edgelist method
  exists.

- weights:

  Logical; if `TRUE`, duplicate edges are collapsed and a `weight`
  column is added with the count of each unique `(from, to)` pair.
  Defaults to `FALSE`.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with columns `from` and `to` (and `weight` when
`weights = TRUE`). For unsupported types, an error is raised.

## Examples

``` r
# Character vector
edgelist(c("A", "B", "C", "D"))
#>   from to
#> 1    A  B
#> 2    B  C
#> 3    C  D

# Numeric vector
edgelist(1:5)
#>   from to
#> 1    1  2
#> 2    2  3
#> 3    3  4
#> 4    4  5

# With duplicate counting
edgelist(c("A", "B", "A", "B", "C"), weights = TRUE)
#>   from to weight
#> 1    A  B      2
#> 2    B  A      1
#> 3    B  C      1

# Unsupported type
try(edgelist(as.formula(y ~ x)))
#> Error in edgelist.default(as.formula(y ~ x)) : 
#>   edgelist() does not support objects of class 'formula'. Supported classes: vector, data.frame, list, randomForest, tree, rpart, xgb.Booster, gbm.
```
