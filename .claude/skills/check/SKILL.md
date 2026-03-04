---
name: check
description: Run tests, update docs to reflect current code, render README, and commit.
allowed-tools: Read, Grep, Glob, Bash, Edit, MultiEdit, Write
argument-hint: "[commit message]"
---

# /check — Test, update docs, and commit

Run after making code changes to ensure everything is consistent.

## Step 1: Run tests

```bash
Rscript --no-save -e "
for (f in list.files('R', pattern = '\\\\.R$', full.names = TRUE))
  tryCatch(source(f), error = function(e) message('Skip ', f))
load('data/courses.rda')
testthat::test_file('tests/testthat/test-edgelist.R')
testthat::test_file('tests/testthat/test-nodelist.R')
"
```

If any tests fail, fix the code and re-run until they pass. Do not proceed with docs until tests are green.

## Step 2: Update docs

Think about what a user of this package needs to know, then review these files:

1. **Man pages** (`man/*.Rd`) — Do the `@returns` column descriptions match actual output? Are parameter docs accurate? Would a user reading this understand what they get back?
2. **Vignettes** (`vignettes/*.Rmd`) — Do column tables, operator values, and examples reflect current behavior? Would the examples actually run and produce what the prose claims?
3. **CLAUDE.md** — Does the Architecture section (algorithms, output columns, status table) match reality? This is for developers working on the package.
4. **README.Rmd** — Do example output comments match what the functions actually return? Would a new user get an accurate first impression?

For each file, read it and fix anything factually wrong or misleading. Only touch lines that need it.

**What to focus on:**
- Column names, types, and descriptions that a user relies on to write code against
- Gotchas or edge cases that would surprise a user (e.g., node ID format, NA behavior)
- Examples that would fail or produce unexpected output

**Writing style rules:**
- Describe the current behavior only. Never reference what it "used to" do or what "changed".
- No before/after comparisons. No "previously", "now", "updated to", "was changed from".
- State facts: "Node IDs are binary heap indices" not "Node IDs were changed from sequential to binary heap indices".

## Step 3: Render README

```bash
Rscript -e 'rmarkdown::render("README.Rmd", quiet = TRUE)'
```

## Step 4: Commit

Stage all modified tracked files and the rendered README.md. Use the argument as the commit message if provided, otherwise write a short one based on what changed.

```bash
git add -u
git add README.md  # in case it was regenerated
git status
```

Then commit. Do not push.

## Important

- **Never skip failing tests.** Fix them first.
- **Do not rewrite docs for style.** Only fix factual inaccuracies.
- **Do not add docstrings or comments to code you didn't change.**
- **Do not describe history in docs.** Only describe current state.
