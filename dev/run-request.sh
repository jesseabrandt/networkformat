#!/usr/bin/env bash
# Headless runner for dev requests.
# Usage:
#   bash dev/run-request.sh 001-na-rm.md     # process one request
#   bash dev/run-request.sh 001              # prefix match
#   bash dev/run-request.sh --all            # all pending, sequentially

set -euo pipefail

# Resolve project root relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

REQUESTS_DIR="dev/requests"

# --- Helpers ---

find_request() {
  local arg="$1"
  # Exact match
  if [ -f "$REQUESTS_DIR/$arg" ]; then
    echo "$arg"
    return
  fi
  # Prefix match (e.g. "001" matches "001-na-rm.md")
  local matches=()
  for f in "$REQUESTS_DIR"/"$arg"*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "README.md" ] && continue
    matches+=("$(basename "$f")")
  done
  if [ ${#matches[@]} -eq 0 ]; then
    echo "Error: no request matching '$arg' in $REQUESTS_DIR/" >&2
    exit 1
  elif [ ${#matches[@]} -gt 1 ]; then
    echo "Error: ambiguous prefix '$arg' matches: ${matches[*]}" >&2
    exit 1
  fi
  echo "${matches[0]}"
}

# Parse status from YAML frontmatter (first --- block only)
get_status() {
  awk '
    /^---$/ { count++; if (count == 2) exit }
    count == 1 && /^status:/ { sub(/^status:[[:space:]]*/, ""); print; exit }
  ' "$1"
}

is_pending() {
  local status
  status=$(get_status "$1")
  [ "$status" = "pending" ]
}

archive_request() {
  local file="$1"
  local src="$REQUESTS_DIR/$file"
  local dest="$REQUESTS_DIR/completed/$file"
  if [ -f "$src" ]; then
    mv "$src" "$dest"
    echo "Archived $file → completed/"
  fi
}

process_request() {
  local file="$1"
  local filepath="$REQUESTS_DIR/$file"
  echo "=== Processing: $file ==="

  local status
  status=$(get_status "$filepath")
  if [ "$status" = "done" ] || [ "$status" = "completed" ]; then
    echo "Skipping $file — already done."
    archive_request "$file"
    return
  fi
  if [ "$status" = "in-progress" ]; then
    echo "Note: $file is already in-progress — resuming."
  fi

  # Build the prompt. Pass the file path instead of embedding content,
  # so shell-special characters in the request doc ($, `) are not mangled.
  local instructions
  instructions=$(cat <<'INSTRUCTIONS'
You are working on the networkformat R package. Process the following development request.

## Instructions

1. Read the request file specified below.
2. Update the request file's status to "in-progress": edit the `status:` line.
3. Read all Affected Files listed in the request.
4. Implement the changes described in the Acceptance Criteria.
5. Follow existing package conventions (see CLAUDE.md).
6. Add/update roxygen2 documentation for changed functions.
7. Add/update tests as specified in Testing Requirements.
8. Run validation and ITERATE until clean:
   - `Rscript -e "pkgload::load_all(quiet=TRUE); testthat::test_dir('tests/testthat', reporter='check')"`
   - `Rscript -e "roxygen2::roxygenise()"`
   - `R CMD check --no-manual --no-vignettes --no-examples --no-tests . 2>&1 | tail -20`
9. When all checks pass, update the request file:
   - Set `status: done`
   - Fill in the Implementation Notes section
10. Commit with message referencing the request number.

**Do not stop until all tests pass and R CMD check is clean.**

INSTRUCTIONS
  )

  local prompt="${instructions}
## Request File

Read and process: ${filepath}"

  claude -p "$prompt" \
    --output-format stream-json \
    --allowedTools "Read,Grep,Glob,Bash,Edit,MultiEdit,Write"

  # Archive if status is now done
  local final_status
  final_status=$(get_status "$filepath")
  if [ "$final_status" = "done" ] || [ "$final_status" = "completed" ]; then
    archive_request "$file"
  fi
}

# --- Main ---

if [ $# -eq 0 ]; then
  echo "Usage: bash dev/run-request.sh <request-file|prefix|--all>"
  exit 1
fi

if [ "$1" = "--all" ]; then
  found=0
  for f in "$REQUESTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    basename=$(basename "$f")
    [ "$basename" = "README.md" ] && continue
    status=$(get_status "$f")
    if [ "$status" = "in-progress" ]; then
      echo "Skipping $basename — already in-progress (may need manual review)" >&2
      continue
    fi
    if is_pending "$f"; then
      process_request "$basename"
      found=1
    fi
  done
  if [ $found -eq 0 ]; then
    echo "No pending requests found."
  fi
else
  file=$(find_request "$1")
  process_request "$file"
fi
