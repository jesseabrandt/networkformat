# cran-comments

## Test environments

* local: Ubuntu 24.04.4 LTS (Linux 6.8), R 4.3.3

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

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
