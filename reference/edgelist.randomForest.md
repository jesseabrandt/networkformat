# Extract Edgelist from RandomForest Model

Converts a randomForest model object into a network edgelist
representation by extracting parent-child relationships from one or more
trees in the forest. Each edge represents a split in the decision tree,
with additional attributes including split variable, split point, and
prediction values.

## Usage

``` r
# S3 method for class 'randomForest'
edgelist(input_object, treenum = NULL, ...)
```

## Arguments

- input_object:

  A randomForest model object from the randomForest package

- treenum:

  Integer vector of tree numbers to extract (default: `NULL` extracts
  all trees). Values must be between 1 and `input_object$ntree`.

- ...:

  Additional arguments (currently unused)

## Value

A data.frame with the following columns:

- from:

  Parent node index within the tree

- to:

  Child node index (left or right daughter)

- split_var:

  Numeric index of the variable used for splitting

- split_point:

  Threshold value for the split

- prediction:

  Prediction value at the child node

- treenum:

  Tree number within the forest

- split_var_name:

  Character vector with human-readable variable names

## Examples

``` r
if (requireNamespace("randomForest", quietly = TRUE)) {
  rf_model <- randomForest::randomForest(
    Species ~ .,
    data = iris,
    ntree = 5,
    maxnodes = 10
  )

  # Extract all trees
  rf_edges <- edgelist(rf_model)
  head(rf_edges)

  # Extract specific trees
  rf_edges_1 <- edgelist(rf_model, treenum = 1)
  rf_edges_13 <- edgelist(rf_model, treenum = c(1, 3))
}
```
