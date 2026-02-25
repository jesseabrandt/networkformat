
<!-- README.md is generated from README.Rmd. Please edit that file -->

# networkformat

<!-- badges: start -->
[![R-CMD-check](https://github.com/jesseabrandt/networkformat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jesseabrandt/networkformat/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/jesseabrandt/networkformat/branch/main/graph/badge.svg)](https://codecov.io/gh/jesseabrandt/networkformat?branch=main)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of **networkformat** is to convert machine learning tree models
into network edgelist format, enabling network-based visualization and
analysis of decision tree structures. The package provides S3 methods
for popular tree-based models including `randomForest`, `tree`, and
(planned) `xgboost`.

## Installation

You can install the development version of networkformat from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("jesseabrandt/networkformat")
```

## Core Concepts

Tree-based machine learning models have an inherent hierarchical
structure that can be represented as a network:

- **Nodes** represent decision points (internal nodes) or predictions
  (leaf nodes)
- **Edges** represent parent-child relationships between nodes
- **Edge attributes** capture split conditions, variable names, and
  thresholds

This representation enables:

- Network visualization using `igraph` or `ggraph`
- Network analysis metrics (centrality, depth, branching patterns)
- Comparative analysis across different models or tree types

## Usage

### RandomForest Models

``` r
library(networkformat)
library(randomForest)

# Fit a random forest model
rf_model <- randomForest(Species ~ ., data = iris, ntree = 5, maxnodes = 10)

# Extract edgelist
rf_edges <- edgelist(rf_model)
head(rf_edges)

# Examine structure
str(rf_edges)
table(rf_edges$treenum)         # Number of edges per tree
table(rf_edges$split_var_name)  # Most important variables
```

The edgelist contains:

- `from` and `to`: Node indices within each tree
- `split_var` and `split_var_name`: Variable used for splitting
- `split_point`: Threshold value for the split
- `treenum`: Tree identifier within the forest
- `prediction`: Value at the child node

### Tree Models

``` r
library(tree)

# Fit a classification tree
tree_model <- tree(Species ~ Sepal.Length + Sepal.Width + Petal.Length, data = iris)

# Extract edgelist
tree_edges <- edgelist(tree_model)
head(tree_edges)

# View split conditions
tree_edges$label
```

The edgelist contains:

- `from` and `to`: Parent and child node indices
- `label`: Human-readable split condition (e.g., "Petal.Length \< 2.5")

### Data Frame Conversion

``` r
# Create a course prerequisite network
courses <- data.frame(
  course = c("STAT101", "STAT102", "STAT202", "MATH101", "MATH102"),
  prereq = c(NA, "STAT101", "STAT102", NA, "MATH101")
)

# Convert to edgelist
course_edges <- edgelist(courses, source_cols = 2, target_cols = 1)
head(course_edges)
```

## Network Visualization

### Using igraph

``` r
library(igraph)

# Create graph from edgelist
rf_edges_tree1 <- subset(rf_edges, treenum == 1)
g <- graph_from_data_frame(rf_edges_tree1[, c("from", "to")], directed = TRUE)

# Add attributes
V(g)$label <- V(g)$name
E(g)$split_var <- rf_edges_tree1$split_var_name

# Plot
plot(g,
     layout = layout_as_tree(g, root = 1),
     vertex.size = 20,
     vertex.color = "lightblue",
     edge.arrow.size = 0.5,
     main = "RandomForest Tree 1 Structure")
```

### Using ggraph

``` r
library(ggraph)
library(tidygraph)

# Convert to tbl_graph
tree_graph <- as_tbl_graph(g) %>%
  mutate(depth = node_distance_from(node_is_root()))

# Create visualization
ggraph(tree_graph, layout = 'tree') +
  geom_edge_link(arrow = arrow(length = unit(2, 'mm')),
                 end_cap = circle(3, 'mm')) +
  geom_node_point(aes(color = depth), size = 5) +
  geom_node_text(aes(label = name), vjust = -0.5) +
  scale_color_viridis_c() +
  theme_graph() +
  labs(title = "Decision Tree Network Structure")
```

## Extending the Package

### Adding New Model Types

To add support for a new tree-based model class:

1.  Create a new file `R/edgelist.newmodel.R`
2.  Implement the S3 method `edgelist.newmodel()`
3.  Extract tree structure into data.frame with `from`/`to` columns
4.  Add tests in `tests/testthat/test-edgelist.R`

See `R/edgelist.randomForest.R` as a reference implementation.

## Related Packages

- **[randomForest](https://cran.r-project.org/package=randomForest)**:
  Random forest classification and regression
- **[tree](https://cran.r-project.org/package=tree)**: Classification
  and regression trees
- **[igraph](https://cran.r-project.org/package=igraph)**: Network
  analysis and visualization
- **[tidygraph](https://cran.r-project.org/package=tidygraph)**: Tidy
  interface for graph manipulation
- **[ggraph](https://cran.r-project.org/package=ggraph)**: Grammar of
  graphics for networks

## Citation

``` r
citation("networkformat")
```

## License

MIT © Jesse Brandt

------------------------------------------------------------------------

**Note**: This package is in experimental development. APIs may change.
Feedback and contributions welcome\!
