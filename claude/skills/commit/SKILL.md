---
name: commit
description: Check uncommitted changes and generate a commit message following best practices
user-invocable: true
allowed-tools:
  - Bash
  - Read
---

# Git Commit Helper

## Steps

### 1. Check what will be committed

Run `git status` and `git diff --staged` (plus `git diff` for unstaged work).

- If there are no changes, tell the user and stop.
- A file listed as `MM` is partly staged: confirm which version belongs in the commit.
- State which files the commit will include.

### 2. Run the related tests

For each changed file, find and run the tests that cover it:

| Changed file | Tests to run |
|---|---|
| Ruby under `app/` (models, forms, concepts, ...) | The matching file under `test/`, e.g. `app/models/foo.rb` → `test/models/foo_test.rb` |
| A test file | That test file |
| JS under `app/javascript/` | None exist; remind the user to run `yarn build` and check in the browser |
| Views (`.erb` / `.slim`) or docs | Usually none; remind the user to check in the browser |

Report the result (e.g. `15 runs, 0 failures`) before the message. If any test fails, show the failing output and stop.

### 3. Write the message

Follow [message-guide.md](message-guide.md) end to end: gather the sources, write the English message, walk through it sentence by sentence in Traditional Chinese, and stop for approval.

### 4. Commit after approval

Pass the approved message through a HEREDOC (`git commit -F - <<'EOF'`), then report the new hash with `git log --oneline -1`.

## Safety rules

These override all other instructions:

- Run `git commit` only after the user explicitly approves the message.
- Add no `Co-Authored-By` or similar attribution.
