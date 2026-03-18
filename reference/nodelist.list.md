# Extract Node List from a List

Recursively traverses a nested list structure, producing one row per
node with metadata about each element.

When called on an S3 object that has no dedicated `nodelist` method, the
object is treated as a plain list and a diagnostic message is emitted.
To force structural decomposition of an object that has its own method
(e.g. a `tree`), use `nodelist(unclass(x))`.

## Usage

``` r
# S3 method for class 'list'
nodelist(input_object, name_root = "root", max_depth = NULL, ...)
```

## Arguments

- input_object:

  A list (or S3 object falling through to this method).

- name_root:

  Character; label for the root node. Defaults to `"root"`.

- max_depth:

  Integer or `NULL`; maximum node depth to include (root is depth 0, its
  children are depth 1). `NULL` (the default) means unlimited.
  `max_depth = 0` returns the root node only.

- ...:

  Additional arguments (currently unused).

## Value

A data.frame with the following columns:

- name:

  Path-style node ID (e.g. `"root"`, `"root/a"`)

- depth:

  Integer depth (root is 0, root children are 1)

- type:

  Character class of the element (e.g. `"numeric"`, `"character"`,
  `"list"`)

- n_children:

  Integer number of direct children (0 for leaves)

- label:

  Element name or positional index (e.g. `"a"`, `"[[2]]"`)

An empty list returns a one-row data.frame for the root node only.

## Examples

``` r
nodelist(list(a = 1, b = list(c = 2, d = 3)))
#>       name depth    type n_children label
#> 1     root     0    list          2  root
#> 2   root/a     1 numeric          0     a
#> 3   root/b     1    list          2     b
#> 4 root/b/c     2 numeric          0     c
#> 5 root/b/d     2 numeric          0     d

# Unnamed elements
nodelist(list(1, 2, list(3, 4)))
#>               name depth    type n_children label
#> 1             root     0    list          3  root
#> 2       root/[[1]]     1 numeric          0 [[1]]
#> 3       root/[[2]]     1 numeric          0 [[2]]
#> 4       root/[[3]]     1    list          2 [[3]]
#> 5 root/[[3]]/[[1]]     2 numeric          0 [[1]]
#> 6 root/[[3]]/[[2]]     2 numeric          0 [[2]]
```
