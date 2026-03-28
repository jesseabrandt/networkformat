# Nodelist Enrichment: tree + rpart

**Date:** 2026-03-27
**Scope:** Enrich `nodelist.tree()` and `nodelist.rpart()` with additional node attributes from frame data, enabling ggparty-like visualizations through ggraph.

## Motivation

The `tree$frame` and `rpart$frame` slots contain rich node-level metadata (class probabilities, pruning parameters, surrogate split counts) that the current nodelist methods don't surface. Exposing these as tidy columns lets users map them to ggraph aesthetics directly — getting 80% of ggparty's functionality through a general-purpose graph viz pipeline.

## Design

### Approach

Surface everything available in each model's frame, plus computed attributes. Wide format for matrix columns (one column per class). Purely additive — no existing columns change.

### `nodelist.tree()` — new columns

| Column | Type | All trees? | Description |
|--------|------|-----------|-------------|
| `depth` | integer | yes | `floor(log2(name))`, 0-based (root = 0) |
| `dev_improvement` | numeric | yes | Internal nodes: `node_dev - left_child_dev - right_child_dev`. NA for leaves. |
| `prob_<classname>` | numeric | classification only | One column per class from `yprob` matrix |

### `nodelist.rpart()` — new columns

| Column | Type | All trees? | Description |
|--------|------|-----------|-------------|
| `depth` | integer | yes | `floor(log2(name))`, 0-based (root = 0) |
| `wt` | numeric | yes | Weighted observation count |
| `complexity` | numeric | yes | CP pruning parameter at each node |
| `ncompete` | integer | yes | Number of competing splits considered |
| `nsurrogate` | integer | yes | Number of surrogate splits used |
| `dev_improvement` | numeric | yes | Internal nodes: `node_dev - left_child_dev - right_child_dev`. NA for leaves. |
| `n_<classname>` | numeric | classification only | Class counts per node from `yval2` |
| `prob_<classname>` | numeric | classification only | Class probabilities from `yval2` |
| `nodeprob` | numeric | classification only | Proportion of training data reaching node |

### Column ordering

Existing columns remain in place. New columns are inserted after `is_leaf`, before `label` (label stays last as the display column):

**tree (classification):** name, var, n, dev, yval, is_leaf, depth, dev_improvement, prob_setosa, prob_versicolor, ..., label

**tree (regression):** name, var, n, dev, yval, is_leaf, depth, dev_improvement, label

**rpart (classification):** name, var, n, dev, yval, is_leaf, depth, wt, complexity, ncompete, nsurrogate, dev_improvement, n_setosa, ..., prob_setosa, ..., nodeprob, label

**rpart (regression):** name, var, n, dev, yval, is_leaf, depth, wt, complexity, ncompete, nsurrogate, dev_improvement, label

### Naming convention

- Class probability columns: `prob_` prefix + `tolower(make.names(classname))`
- Class count columns (rpart): `n_` prefix + `tolower(make.names(classname))`
- This ensures valid R column names regardless of class label content

### `dev_improvement` computation

For each internal node with binary heap ID `k`:
- Left child: `2 * k`, right child: `2 * k + 1`
- `dev_improvement = dev[k] - dev[2k] - dev[2k+1]`
- Leaves: NA (no split to evaluate)
- This measures how much deviance the node's own split reduced

### No breaking changes

All existing columns, types, and ordering are preserved. Existing code that reads `nodelist(tr)$var` or similar continues to work unchanged.

## Tests

- Classification trees: prob columns exist, sum to ~1 per row, match class names
- Regression trees: prob/count columns absent, no errors
- `depth`: root = 0, monotonically increases down tree
- `dev_improvement`: non-negative for internal nodes, NA for leaves
- rpart-specific: `wt`, `complexity`, `ncompete`, `nsurrogate` present and reasonable
- rpart classification: `n_` count columns sum to `n` per row, `nodeprob` in [0, 1]
- Existing test assertions still pass (no regressions)

## Future work

- Audit randomForest, xgboost, and gbm for unsurfaced node attributes (separate effort)
- Potential: deviance improvement for ensemble models where computable
