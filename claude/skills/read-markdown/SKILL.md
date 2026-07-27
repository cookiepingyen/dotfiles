---
name: read-markdown
description: Read a markdown documentation file from /project/docs/ (absolute path) and display its content
user-invocable: true
allowed-tools:
  - Read
  - Bash
---

# Read Markdown Documentation

Read and display a markdown documentation file from the `/project/docs/` directory (absolute path, not relative to current working directory).

## Steps

### 1. Parse the argument

The user may invoke this skill with or without arguments:
- **With filename**: `/read-markdown <filename>` — read the specified file directly
- **Without argument**: list all available markdown files in `/project/docs/` and ask the user which one to read

### 2. List available files (if no argument given)

If no filename is provided:
- Run `find /project/docs -name "*.md" | sort` to list all markdown files
- Display the list clearly to the user
- Ask which file they want to read

### 3. Resolve the file path

Always use the **absolute path** `/project/docs/` as the base directory. Never use relative paths.

**Mac drag-and-drop path conversion**: the user's local Mac checkout has this project's docs under `proj/docs/`, bind-mounted into the container at `/project/docs/`. When a dragged-in path matches `/Users/<any-username>/.../proj/docs/<rest...>`, convert it by stripping everything up to and including `proj/docs/` and prepending `/project/docs/`:

```
/Users/<any-username>/.../proj/docs/<rest...>  →  /project/docs/<rest...>
```

Example:

```
/Users/wubingyan/proj/docs/application_form_heic/document_upload_file_type_frontend_validation_investigation.md
→ /project/docs/application_form_heic/document_upload_file_type_frontend_validation_investigation.md
```

The mapping is anchored on the `proj/docs/` segment, not on the username or the exact prefix before it — the Mac-side path to that folder may vary, only the `proj/docs/` anchor matters. Never try to read the literal `/Users/...` path directly — it does not exist inside the container.

Resolution rules:
- If the argument matches the Mac drag-and-drop pattern above (`/Users/.../proj/docs/...`), apply the conversion first, then use the converted path as-is
- Else if the argument is already an absolute path (starts with `/`), use it as-is
- If the argument is a bare filename (e.g., `feature_investigation`), try in order:
  1. `/project/docs/<argument>.md`
  2. `/project/docs/<argument>`
  3. Search under `/project/docs/` with `find /project/docs -name "<argument>*" -name "*.md"`
- If the file is not found, report clearly (showing both the original and converted path you tried) and show the available files

### 4. Read and display the file

- Use the Read tool with the resolved absolute path
- Display the full content to the user

### 5. Confirm and offer next steps

After displaying the content, briefly confirm:
- The file path that was read
- Offer to read another file or search for related documents if helpful

## Important notes

- **Always use absolute path** `/project/docs/` — never resolve relative to the current working directory
- If the file does not exist at the resolved path, do not guess or fabricate content — report the error
- Subdirectories under `/project/docs/` are valid (e.g., `/project/docs/adr/`, `/project/docs/domain/`)
- If the user passes a subdirectory path like `adr/INDEX`, resolve to `/project/docs/adr/INDEX.md`
- If the user drags in a file and gives a Mac-style `/Users/.../proj/docs/...` path, convert it per the rule in step 3 — don't ask them to retype it as a relative path

## Examples

| User input | Resolved path |
|---|---|
| `/read-markdown feature_investigation` | `/project/docs/feature_investigation.md` |
| `/read-markdown adr/INDEX` | `/project/docs/adr/INDEX.md` |
| `/read-markdown /project/docs/bug_analysis.md` | `/project/docs/bug_analysis.md` |
| `/read-markdown /Users/wubingyan/proj/docs/application_form_heic/document_upload_file_type_frontend_validation_investigation.md` | `/project/docs/application_form_heic/document_upload_file_type_frontend_validation_investigation.md` |
| `/read-markdown` (no argument) | list all `.md` files under `/project/docs/` |
