# networkformat: Convert R Objects to Network Edgelists and Nodelists

Converts R objects into network edgelist and nodelist format for
visualization and analysis with packages like 'igraph', 'tidygraph', and
'ggraph'. Works with atomic vectors (sequential edges), data frames
(column-pair edges with tidyselect), and tree-based model objects
('randomForest', 'tree', 'rpart', 'xgboost', 'gbm'). Also provides
one-step graph construction via as.igraph() and as_tbl_graph() methods
for tree models.

## See also

Vignettes:

- [`vignette("networkformat")`](https://jesseabrandt.github.io/networkformat/articles/networkformat.md)
  — package overview

- [`vignette("edgelist-nodelist")`](https://jesseabrandt.github.io/networkformat/articles/edgelist-nodelist.md)
  — edgelist and nodelist usage

- [`vignette("visualization")`](https://jesseabrandt.github.io/networkformat/articles/visualization.md)
  — ggraph visualization examples

## Author

**Maintainer**: Jesse Brandt <jesseabrandt@users.noreply.github.com>
([ORCID](https://orcid.org/0009-0005-7462-075X))
