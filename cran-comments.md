# cran-comments

## Test environments

* local: Ubuntu 24.04.4 LTS (Linux 6.8), R 4.3.3
* win-builder: Windows, R 4.6.1 (R-release)
* win-builder: Windows, R Under development (unstable) (2026-08-27 r90452)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Both win-builder runs return the same single NOTE, from "checking CRAN
incoming feasibility": the expected "New submission", plus possibly
misspelled words in DESCRIPTION --- "Edgelists", "Nodelists", "edgelist",
"nodelist" and "tidyselect". All five are correct. The first four are the
standard network-analysis terms for the two data structures this package
produces, and 'tidyselect' is the name of a package listed under Imports.

The local check additionally reports two items that are artifacts of the check
environment rather than of the package:

* WARNING: 'qpdf' is needed for checks on size reduction of PDFs --- qpdf is
  not installed on the local machine.
* NOTE: unable to verify current time --- the local machine has no access to
  the network time service the check consults.

All suggested packages (including 'xgboost' and 'gbm') are installed locally,
so the model-specific methods and their tests are exercised rather than
skipped.

## Downstream dependencies

There are no downstream dependencies; this is a first submission.
