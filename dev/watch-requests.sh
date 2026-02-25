#!/usr/bin/env bash
# File watcher for dev/requests/ — polls for new .md files and processes them.
# Usage:
#   bash dev/watch-requests.sh           # watch for new files only
#   bash dev/watch-requests.sh --all     # also process existing pending on startup

set -euo pipefail

# --- Config ---
POLL_INTERVAL=3    # seconds between checks
SETTLE_DELAY=2     # seconds to wait after detecting a new file

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

REQUESTS_DIR="dev/requests"
RUNNER="dev/run-request.sh"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

timestamp() {
  date '+%H:%M:%S'
}

log() {
  echo -e "${CYAN}[$(timestamp)]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[$(timestamp)]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[$(timestamp)]${NC} $*"
}

log_error() {
  echo -e "${RED}[$(timestamp)]${NC} $*"
}

# --- Helpers ---

# Parse status from YAML frontmatter
get_status() {
  awk '
    /^---$/ { count++; if (count == 2) exit }
    count == 1 && /^status:/ { sub(/^status:[[:space:]]*/, ""); print; exit }
  ' "$1"
}

# List .md files in requests dir (excluding README.md), one per line
list_request_files() {
  for f in "$REQUESTS_DIR"/*.md; do
    [ -f "$f" ] || continue
    local base
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    echo "$base"
  done
}

# Snapshot current files as a sorted list
snapshot() {
  list_request_files | sort
}

# --- Startup ---

log "Watching ${REQUESTS_DIR}/ for new requests (poll every ${POLL_INTERVAL}s)"
log "Press Ctrl+C to stop."
echo ""

PREV_SNAPSHOT="$(snapshot)"

# --all flag: process existing pending requests at startup
if [ "${1:-}" = "--all" ]; then
  log "Scanning for pre-existing pending requests..."
  found=0
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    status="$(get_status "$REQUESTS_DIR/$file")"
    if [ "$status" = "pending" ]; then
      log "Found pending: $file"
      log "Processing $file..."
      if bash "$RUNNER" "$file"; then
        log_success "Finished: $file"
      else
        log_error "Failed: $file (exit code $?)"
      fi
      found=1
    fi
  done <<< "$PREV_SNAPSHOT"
  if [ "$found" -eq 0 ]; then
    log "No pre-existing pending requests."
  fi
  echo ""
  # Re-snapshot after processing (statuses may have changed)
  PREV_SNAPSHOT="$(snapshot)"
fi

# --- Main polling loop ---

cleanup() {
  echo ""
  log "Watcher stopped."
  exit 0
}
trap cleanup INT TERM

while true; do
  sleep "$POLL_INTERVAL"

  CURR_SNAPSHOT="$(snapshot)"

  # Find new files (in current but not in previous)
  NEW_FILES="$(comm -13 <(echo "$PREV_SNAPSHOT") <(echo "$CURR_SNAPSHOT"))" || true

  if [ -n "$NEW_FILES" ]; then
    while IFS= read -r file; do
      [ -z "$file" ] && continue

      log "Detected new file: $file"
      log "Waiting ${SETTLE_DELAY}s for file to finish writing..."
      sleep "$SETTLE_DELAY"

      # Validate status
      status="$(get_status "$REQUESTS_DIR/$file")"
      if [ "$status" != "pending" ]; then
        log_warn "Skipping $file — status is '${status:-<none>}', not 'pending'"
        continue
      fi

      log "Processing $file..."
      if bash "$RUNNER" "$file"; then
        log_success "Finished: $file"
      else
        log_error "Failed: $file (exit code $?)"
      fi

    done <<< "$NEW_FILES"
  fi

  PREV_SNAPSHOT="$CURR_SNAPSHOT"
done
