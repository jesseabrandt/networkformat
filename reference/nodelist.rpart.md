# Extract Node List from rpart Model

Extracts node-level attributes from an `rpart` model object. Node IDs
are the binary heap indices from `rownames(input_object$frame)` and
match the `from`/`to` values produced by
[`edgelist.rpart`](https://jesseabrandt.github.io/networkformat/reference/edgelist.rpart.md),
so the two outputs can be passed directly to
[`igraph::graph_from_data_frame()`](https://r.igraph.org/reference/graph_from_data_frame.html).

## Usage

``` r
# S3 method for class 'rpart'
nodelist(input_object, ...)
```

## Arguments

- input_object:

  An rpart model object from the rpart package

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

  Predicted value (numeric for regression, character class label for
  classification)

- is_leaf:

  Logical: `TRUE` for terminal nodes

- label:

  Display label: `"<var>\nn=<n>"` for internal nodes, `"<yval>\nn=<n>"`
  for leaves

## Examples

``` r
if (requireNamespace("rpart", quietly = TRUE)) {
  fit <- rpart::rpart(Species ~ Sepal.Length + Sepal.Width, data = iris)
  nodelist(fit)

  # Labels ready for plotting
  nodelist(fit)$label
}
#> [1] "Sepal.Length\nn=150" "Sepal.Width\nn=52"   "setosa\nn=45"       
#> [4] "versicolor\nn=7"     "Sepal.Length\nn=98"  "Sepal.Width\nn=43"  
#> [7] "setosa\nn=7"         "versicolor\nn=36"    "virginica\nn=55"    
```
