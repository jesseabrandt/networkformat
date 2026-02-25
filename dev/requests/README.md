# Development Requests

Structured feature/bug-fix requests for the networkformat R package.

## Writing a Request

1. Copy `dev/prompt-template.md` to `dev/requests/NNN-short-name.md`
2. Fill in all sections. Be specific in Acceptance Criteria.
3. Set `status: pending`.

### Naming Convention

`NNN-short-name.md` — zero-padded 3-digit prefix, lowercase kebab-case name.

```
001-na-rm.md
002-node-labels.md
003-extract-tree.md
```

### Lifecycle

```
pending → in-progress → done → completed/
```

- **pending** — ready to be picked up
- **in-progress** — Claude is actively working on it
- **done** — implemented, tested, committed; automatically moved to `completed/`

## Processing Requests

### Interactive (recommended)

Start a Claude Code session in the package directory, then:

```
/dev-request 001-na-rm.md
```

Or just the prefix:

```
/dev-request 001
```

The `/dev-request` skill will:
1. Read the request file
2. Implement the feature
3. Run the quality gate (tests, NAMESPACE, R CMD check) on stop
4. Iterate until all checks pass
5. Mark the request as done

### Headless

Process requests without an interactive session:

```bash
# Single request
bash dev/run-request.sh 001-na-rm.md

# Prefix match
bash dev/run-request.sh 001

# All pending requests
bash dev/run-request.sh --all
```

The headless runner pipes the request to `claude -p` with explicit instructions to iterate until tests pass.

### Watch Mode

Start a watcher that automatically processes new requests as you drop them in:

```bash
bash dev/watch-requests.sh
```

The watcher polls `dev/requests/` every few seconds. When a new `.md` file appears with `status: pending`, it runs the headless runner automatically. Stop with Ctrl+C.

To also process any pre-existing pending requests on startup:

```bash
bash dev/watch-requests.sh --all
```

## Tips

- Keep requests focused — one feature per file.
- Write acceptance criteria as checkboxes so completion is unambiguous.
- List affected files so Claude knows where to look.
- The quality gate checks tests, NAMESPACE staleness, and R CMD check errors.
