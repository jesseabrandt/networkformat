# Extract Node List from Data Frame

Reorders a data.frame to place the ID column first, creating a proper
node list format. All other columns are treated as node attributes.

## Usage

``` r
# S3 method for class 'data.frame'
nodelist(input_object, id_col = 1, ...)
```

## Arguments

- input_object:

  A data.frame containing node information

- id_col:

  Column for the node ID (default: 1). Accepts
  [tidyselect](https://tidyselect.r-lib.org/reference/language.html)
  expressions: a bare name, string, or numeric index.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the ID column first, followed by all attribute columns

## Examples

``` r
# Default: first column (dept) is ID
nodelist(courses)
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

# Use bare column name
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

# Numeric index still works
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
