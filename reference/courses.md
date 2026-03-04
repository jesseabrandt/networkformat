# Course prerequisite and crosslisting network

A small dataset of university courses with prerequisite and crosslisting
relationships, suitable for demonstrating
[`edgelist()`](https://jesseabrandt.github.io/networkformat/reference/edgelist.md)
and
[`nodelist()`](https://jesseabrandt.github.io/networkformat/reference/nodelist.md).

## Usage

``` r
courses
```

## Format

A data.frame with 13 rows and 7 columns:

- dept:

  Department code (STAT, MATH, DATA, CS)

- course:

  Course identifier, used as node ID

- prereq:

  Prerequisite course (NA if none)

- prereq2:

  Second prerequisite course (NA if none)

- crosslist:

  Crosslisted equivalent course (NA if none)

- credits:

  Number of credit hours (integer)

- level:

  Course level: 100, 200, or 300 (integer)

## Examples

``` r
# Prerequisite edgelist (course -> prereq)
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

# Node list with course as ID column
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
