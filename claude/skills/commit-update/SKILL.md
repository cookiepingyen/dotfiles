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

Run `git show HEAD` to get:
- The current commit message (title and body)
- The list of changed files and their diffs

### 2. Read changed files

Read the actual content of each modified file to understand the full context
of the changes, not just the diff.

### 3. Generate an improved commit message

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

### 4. Amend the commit

- Show the proposed new message to the user
- Ask for confirmation before executing `git commit --amend`
- Use a HEREDOC to pass the message to avoid formatting issues

### 5. Important

- **NEVER** add `Co-Authored-By` or any similar attribution
- Only amend the message — do not stage or unstage any files
