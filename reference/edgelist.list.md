# Extract Edgelist from a List

Recursively traverses a nested list structure, producing a parent-child
edgelist. Each element of the list becomes a node; nested lists create
deeper edges. Path-style IDs ensure unique node names even when element
names repeat at different levels.

When called on an S3 object that has no dedicated `edgelist` method
(e.g. an `lm` object), the object is treated as a plain list and a
diagnostic message is emitted. To force structural decomposition of an
object that has its own method (e.g. a `tree`), use
`edgelist(unclass(x))`.

## Usage

``` r
# S3 method for class 'list'
edgelist(input_object, name_root = "root", max_depth = NULL, ...)
```

## Arguments

- input_object:

  A list (or S3 object falling through to this method).

- name_root:

  Character; label for the root node. Defaults to `"root"`.

- max_depth:

  Integer or `NULL`; maximum node depth to include (root is depth 0, its
  children are depth 1). `NULL` (the default) means unlimited.
  `max_depth = 0` returns an empty edgelist (root only).

- ...:

  Additional arguments (currently unused).

## Value

A data.frame with the following columns:

- from:

  Parent node path-style ID (e.g. `"root"`, `"root/a"`)

- to:

  Child node path-style ID (e.g. `"root/a"`, `"root/a/b"`)

- depth:

  Integer depth of the child node (root children are depth 1)

An empty list returns a zero-row data.frame with the same columns.

## Examples

``` r
edgelist(list(a = 1, b = list(c = 2, d = 3)))
#>     from       to depth
#> 1   root   root/a     1
#> 2   root   root/b     1
#> 3 root/b root/b/c     2
#> 4 root/b root/b/d     2

# Unnamed elements use positional indices
edgelist(list(1, 2, list(3, 4)))
#>         from               to depth
#> 1       root       root/[[1]]     1
#> 2       root       root/[[2]]     1
#> 3       root       root/[[3]]     1
#> 4 root/[[3]] root/[[3]]/[[1]]     2
#> 5 root/[[3]] root/[[3]]/[[2]]     2

# Limit depth (root = 0, children = 1, ...)
edgelist(list(a = list(b = list(c = 1))), max_depth = 2)
#>     from       to depth
#> 1   root   root/a     1
#> 2 root/a root/a/b     2
```
