# Extract Edgelist from Data Frame

Converts a data.frame to network edgelist format by specifying which
columns represent source and target nodes. This is useful for creating
edgelists from tabular data where node relationships are stored in
columns.

## Usage

``` r
# S3 method for class 'data.frame'
edgelist(
  input_object,
  source_cols = 1,
  target_cols = 2,
  attr_cols = NULL,
  na.rm = TRUE,
  symmetric_cols = NULL,
  dedupe = TRUE,
  weights = FALSE,
  ...
)
```

## Arguments

- input_object:

  A data.frame containing network information

- source_cols:

  Column(s) for source nodes (default: 1). Accepts
  [tidyselect](https://tidyselect.r-lib.org/reference/language.html)
  expressions: bare names, strings, numeric indices, or helpers like
  [`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html).

- target_cols:

  Column(s) for target nodes (default: 2). Same syntax as `source_cols`.

- attr_cols:

  Columns to carry as edge attributes (default: `NULL` keeps all columns
  not used as source or target). Pass an empty
  [`c()`](https://rdrr.io/r/base/c.html) to keep only from, to, and
  metadata columns. Accepts the same
  [tidyselect](https://tidyselect.r-lib.org/reference/language.html)
  syntax as `source_cols`.

- na.rm:

  Logical; if `TRUE` (the default), rows where `from` or `to` is `NA`
  are removed from the result. Set to `FALSE` to keep all rows including
  those with `NA` endpoints.

- symmetric_cols:

  Target column names that represent undirected (symmetric)
  relationships. When non-`NULL`, a `directed` column is added: `FALSE`
  for edges from target columns named in `symmetric_cols`, `TRUE`
  otherwise. Accepts the same tidyselect syntax as `target_cols`; names
  must be a subset of `target_cols`.

- dedupe:

  Logical; if `TRUE` (the default) and `symmetric_cols` is non-`NULL`,
  duplicate undirected edges are removed by keeping only rows where
  `from <= to` (lexicographic comparison). Set to `FALSE` to preserve
  both directions.

- weights:

  Logical; if `TRUE`, fully identical rows (same `from`, `to`, and all
  attribute columns) are collapsed and a `weight` column is added with
  the count. Rows that share `(from, to)` but differ in any attribute
  are kept separate. Applied after NA removal and symmetric
  deduplication. Defaults to `FALSE`.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with columns:

- from:

  Source node values

- to:

  Target node values

- from_col:

  Name of the original column each source value came from

- to_col:

  Name of the original column each target value came from

- directed:

  (only when `symmetric_cols` is provided) Logical: `FALSE` for edges
  from symmetric target columns, `TRUE` otherwise

- weight:

  (only when `weights = TRUE`) Integer count of how many times each
  unique `(from, to)` pair occurred

- ...:

  Additional attribute columns selected by `attr_cols`

## Examples

``` r
# Basic usage --- all non-source/target columns kept by default
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

# Multiple target columns --- to_col identifies the relationship type
edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))
#>       from      to from_col    to_col dept prereq2 credits level
#> 1  stat101 math101   course    prereq STAT    <NA>       3   100
#> 2  stat102 stat101   course    prereq STAT    <NA>       4   100
#> 3  stat202 stat101   course    prereq STAT    <NA>       3   200
#> 4  math102 stat101   course    prereq MATH    <NA>       4   100
#> 5  data202 stat101   course    prereq DATA    <NA>       3   200
#> 6    cs201   cs101   course    prereq   CS    <NA>       4   200
#> 7    cs301   cs201   course    prereq   CS math201       3   300
#> 8  math201 math101   course    prereq MATH    <NA>       3   200
#> 9  math301   cs201   course    prereq MATH math201       4   300
#> 10 data301 stat202   course    prereq DATA   cs201       3   300
#> 11 stat301 stat202   course    prereq STAT   cs201       4   300
#> 12 stat102 math102   course crosslist STAT    <NA>       4   100
#> 13 stat202 data202   course crosslist STAT    <NA>       3   200
#> 14 math102 stat102   course crosslist MATH    <NA>       4   100
#> 15 data202 stat202   course crosslist DATA    <NA>       3   200
#> 16   cs301 math301   course crosslist   CS math201       3   300
#> 17 math301   cs301   course crosslist MATH math201       4   300
#> 18 data301 stat301   course crosslist DATA   cs201       3   300
#> 19 stat301 data301   course crosslist STAT   cs201       4   300

# Keep only the edgelist (no attribute columns)
edgelist(courses, source_cols = course, target_cols = prereq, attr_cols = c())
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

# Select specific attribute columns
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

# NA removal (default) vs preservation
edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist))
#>       from      to from_col    to_col dept prereq2 credits level
#> 1  stat101 math101   course    prereq STAT    <NA>       3   100
#> 2  stat102 stat101   course    prereq STAT    <NA>       4   100
#> 3  stat202 stat101   course    prereq STAT    <NA>       3   200
#> 4  math102 stat101   course    prereq MATH    <NA>       4   100
#> 5  data202 stat101   course    prereq DATA    <NA>       3   200
#> 6    cs201   cs101   course    prereq   CS    <NA>       4   200
#> 7    cs301   cs201   course    prereq   CS math201       3   300
#> 8  math201 math101   course    prereq MATH    <NA>       3   200
#> 9  math301   cs201   course    prereq MATH math201       4   300
#> 10 data301 stat202   course    prereq DATA   cs201       3   300
#> 11 stat301 stat202   course    prereq STAT   cs201       4   300
#> 12 stat102 math102   course crosslist STAT    <NA>       4   100
#> 13 stat202 data202   course crosslist STAT    <NA>       3   200
#> 14 math102 stat102   course crosslist MATH    <NA>       4   100
#> 15 data202 stat202   course crosslist DATA    <NA>       3   200
#> 16   cs301 math301   course crosslist   CS math201       3   300
#> 17 math301   cs301   course crosslist MATH math201       4   300
#> 18 data301 stat301   course crosslist DATA   cs201       3   300
#> 19 stat301 data301   course crosslist STAT   cs201       4   300
edgelist(courses, source_cols = course, target_cols = c(prereq, crosslist),
         na.rm = FALSE)
#>       from      to from_col    to_col dept prereq2 credits level
#> 1  stat101 math101   course    prereq STAT    <NA>       3   100
#> 2  stat102 stat101   course    prereq STAT    <NA>       4   100
#> 3  stat202 stat101   course    prereq STAT    <NA>       3   200
#> 4  math101    <NA>   course    prereq MATH    <NA>       3   100
#> 5  math102 stat101   course    prereq MATH    <NA>       4   100
#> 6  data202 stat101   course    prereq DATA    <NA>       3   200
#> 7    cs101    <NA>   course    prereq   CS    <NA>       3   100
#> 8    cs201   cs101   course    prereq   CS    <NA>       4   200
#> 9    cs301   cs201   course    prereq   CS math201       3   300
#> 10 math201 math101   course    prereq MATH    <NA>       3   200
#> 11 math301   cs201   course    prereq MATH math201       4   300
#> 12 data301 stat202   course    prereq DATA   cs201       3   300
#> 13 stat301 stat202   course    prereq STAT   cs201       4   300
#> 14 stat101    <NA>   course crosslist STAT    <NA>       3   100
#> 15 stat102 math102   course crosslist STAT    <NA>       4   100
#> 16 stat202 data202   course crosslist STAT    <NA>       3   200
#> 17 math101    <NA>   course crosslist MATH    <NA>       3   100
#> 18 math102 stat102   course crosslist MATH    <NA>       4   100
#> 19 data202 stat202   course crosslist DATA    <NA>       3   200
#> 20   cs101    <NA>   course crosslist   CS    <NA>       3   100
#> 21   cs201    <NA>   course crosslist   CS    <NA>       4   200
#> 22   cs301 math301   course crosslist   CS math201       3   300
#> 23 math201    <NA>   course crosslist MATH    <NA>       3   200
#> 24 math301   cs301   course crosslist MATH math201       4   300
#> 25 data301 stat301   course crosslist DATA   cs201       3   300
#> 26 stat301 data301   course crosslist STAT   cs201       4   300

# Mark symmetric (undirected) target columns
edgelist(courses, source_cols = course,
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
