---
name: commit-update
description: Re-analyze the latest commit's changed files and rewrite the commit title and body
user-invocable: true
allowed-tools:
  - Bash
  - Read
---

# Git Commit Update Helper

## Steps

### 1. Inspect the latest commit

Run `git show HEAD` for the current message and diff, and read each changed file in full to understand the context, not just the diff.

Check `git status` as well:

- By default, only the message is rewritten.
- When the user asks to fold current changes into this commit (e.g. amending a `tmp` commit), confirm which files will be added, and run their related tests as in step 2 of [../commit/SKILL.md](../commit/SKILL.md).

### 2. Write the new message

Follow [../commit/message-guide.md](../commit/message-guide.md) end to end: gather the sources, write the English message, walk through it sentence by sentence in Traditional Chinese, and stop for approval. Treat the current message as one more source: keep what is still true and correct what is not.

### 3. Amend after approval

Run `git commit --amend -F - <<'EOF'` with the approved message. Then report the new hash, and remind the user that a commit which was already pushed needs `git push --force-with-lease`.

## Safety rules

These override all other instructions:

- Run `git commit --amend` only after the user explicitly approves the message.
- Add no `Co-Authored-By` or similar attribution.
