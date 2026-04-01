# Extract Node List from Tree Model

Extracts node-level attributes from a `tree` model object. Node IDs are
the binary heap indices from `rownames(input_object$frame)` and match
the `from`/`to` values produced by
[`edgelist.tree`](https://jesseabrandt.github.io/networkformat/reference/edgelist.tree.md),
so the two outputs can be passed directly to
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html).

## Usage

``` r
# S3 method for class 'tree'
nodelist(input_object, ...)
```

## Arguments

- input_object:

  A tree model object from the tree package

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with one row per node and the following columns:

- name:

  Integer node ID (binary heap index, matches edgelist from/to)

- var:

  Split variable name, or `"<leaf>"` for terminal nodes

- n:

  Number of observations routed to this node

- dev:

  Deviance (impurity) at this node

- yval:

  Predicted value (numeric for regression, character for classification)

- is_leaf:

  Logical: `TRUE` for terminal nodes

- depth:

  Integer tree depth (root = 0)

- dev_improvement:

  Numeric deviance reduction from this node's split (`NA` for leaves)

- prob\_\*:

  (Classification only) One column per class with the class probability
  at that node, named `prob_<classname>`. Class names are sanitized via
  [`make.names()`](https://rdrr.io/r/base/make.names.html) and
  lowercased.

- label:

  Display label: `"<var>\nn=<n>"` for internal nodes, `"<yval>\nn=<n>"`
  for leaves

## Examples

``` r
if (requireNamespace("tree", quietly = TRUE)) {
  tr <- tree::tree(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nodelist(tr)

  # Labels ready for plotting
  nodelist(tr)$label
}
#>  [1] "Sepal.Length\nn=150" "Sepal.Width\nn=59"   "Sepal.Length\nn=12" 
#>  [4] "versicolor\nn=5"     "versicolor\nn=7"     "Sepal.Length\nn=47" 
#>  [7] "setosa\nn=39"        "setosa\nn=8"         "Sepal.Width\nn=91"  
#> [10] "Sepal.Length\nn=86"  "versicolor\nn=37"    "Sepal.Length\nn=49" 
#> [13] "virginica\nn=39"     "virginica\nn=10"     "setosa\nn=5"        
```
