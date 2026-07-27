---
name: mr-read
description: Read a GitLab MR by number and display a structured summary with diffs
user-invocable: true
allowed-tools:
  - Bash
---

# MR Read

Read a GitLab MR and summarize its content including file diffs.

## Known environment

- GitLab host: `gitlab.abagile.com`
- Project ID: `1` (metis/nerv)
- Auth token: `$GITLAB_TOKEN` (already set in environment — no need to detect or prompt)

## Steps

### 1. Parse argument

The user provides the MR number as the argument (e.g. `/mr-read 11418`). Use it directly.

### 2. Fetch MR metadata

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.abagile.com/api/v4/projects/1/merge_requests/{iid}"
```

Extract: title, description, state, author, merged_by, created_at, merged_at, source_branch, target_branch.

### 3. Fetch file changes

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.abagile.com/api/v4/projects/1/merge_requests/{iid}/changes"
```

Extract: list of changed files and their diffs. Truncate individual diffs longer than 3000 characters.

### 4. Output summary

Format the response in Traditional Chinese with the following structure:

- **標題、作者、Merge by、狀態、日期、分支**
- 每個變更檔案：路徑 + diff 內容（截斷超長部分）
