# Extract Node List from a Vector or Unsupported Object

When called on an atomic vector (character, numeric, integer, logical,
factor), returns the unique values as a node list with a `name` column
(preserving order of first appearance) and an `n` column giving the
frequency of each value. For all other unsupported types, an informative
error is raised.

## Usage

``` r
# Default S3 method
nodelist(input_object, ...)
```

## Arguments

- input_object:

  An atomic vector, or an object for which no specific nodelist method
  exists.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with columns `name` (unique values in order of first
appearance) and `n` (frequency count). For unsupported types, an error
is raised.

## Examples

``` r
# Character vector
nodelist(c("A", "B", "C", "A", "B"))
#>   name n
#> 1    A 2
#> 2    B 2
#> 3    C 1

# Numeric vector
nodelist(c(1, 2, 3, 2, 1))
#>   name n
#> 1    1 2
#> 2    2 2
#> 3    3 1

# Unsupported type
try(nodelist(list(a = 1, b = 2)))
#> Error in nodelist.default(list(a = 1, b = 2)) : 
#>   nodelist() does not support objects of class 'list'. Supported classes: vector, data.frame, randomForest, tree, rpart, xgb.Booster, gbm.
```
