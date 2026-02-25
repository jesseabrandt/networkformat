---
status: done
priority: high
created: 2025-02-20
---

# 001 — Rename `drop_na` to `na.rm` in `edgelist.data.frame()`

## Summary

Rename the `drop_na` parameter to `na.rm` for consistency with base R conventions (`sum()`, `mean()`, `colSums()`, etc.).

## Motivation

User feedback on feature-suggestions.md section 2: "rename to na.rm. this is standard in several packages."

The original proposal used `drop_na` (borrowing from tidyr), but `na.rm` is the idiomatic R parameter name for controlling NA removal. Using `na.rm` makes the API immediately familiar to R users.

## Proposed API

```r
edgelist(courses, source_cols = course,
         target_cols = c(prereq, crosslist),
         na.rm = TRUE)   # default — remove edges with NA source/target
```

## Acceptance Criteria

- [x] Parameter named `na.rm` (not `drop_na`)
- [x] Default is `TRUE` — removes rows where source or target is NA
- [x] `na.rm = FALSE` preserves all rows including NAs
- [x] Documentation updated with examples showing both behaviors
- [x] Tests cover `na.rm = TRUE` (default) and `na.rm = FALSE`
- [x] R CMD check clean

## Affected Files

- `R/edgelist.data.frame.R` — parameter name and logic
- `man/edgelist.data.frame.Rd` — regenerated
- `tests/testthat/test-edgelist.R` — tests for NA handling

## Testing Requirements

- Test that default behavior removes NA rows from multi-target edgelists
- Test that `na.rm = FALSE` preserves NA rows
- Test with data that has NAs in both source and target columns

## Notes / Constraints

- `na.rm` is conventional in base R; `drop_na` is tidyr's convention. Since this package minimizes tidyverse dependencies, `na.rm` is the right choice.

---

## Implementation Notes

Implemented as part of the initial `edgelist.data.frame()` method. The parameter uses `isTRUE(na.rm)` to filter rows where `source` or `target` is `NA` after building the complete edge block. Row names are reset after filtering.
