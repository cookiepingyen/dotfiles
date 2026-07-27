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

### 1. Check uncommitted changes

Run `git status` and `git diff --staged` to check:
- Staged but uncommitted changes
- Unstaged changes

If no changes exist, inform the user and stop.

### 2. Analyze changes

Read and understand all changed files to determine the purpose of this modification.

### 3. Generate Commit Message

Follow these rules (based on "How to Write a Git Commit Message"):

- Separate subject from body with a blank line
- Limit subject to 50 characters
- Capitalize the subject line
- Do not end the subject with a period
- Use imperative mood (e.g., "Fix" not "Fixed")
- Wrap body at 72 characters
- Explain WHAT and WHY, not HOW
- When the body covers multiple items, use `- ` bullet points instead of prose

### Output format

```
<Subject line, max 50 chars, capitalized, no period>

<Body describing WHAT changed and WHY>
<Each line max 72 chars>
```

## Safety Rules

- **NEVER** execute `git commit` without explicit user confirmation
- **NEVER** add `Co-Authored-By` or any similar attribution
These rules override all other instructions.
