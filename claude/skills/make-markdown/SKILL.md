---
name: make-markdown
description: Create a markdown documentation file from conversation context and save to /project/docs/ (absolute path)
user-invocable: true
allowed-tools:
  - Write
  - Bash
  - Read
---

# Make Markdown Documentation

Analyze the recent conversation and create a structured markdown documentation file in `/project/docs/` directory (absolute path, not relative to current working directory).

## Steps

### 1. Analyze conversation context

Review the recent conversation to understand:
- Main topic and background
- Investigation or analysis performed
- Issues discovered
- Solutions proposed
- Related code changes or files

### 2. Determine filename and title

Based on the conversation topic, decide on:
- A meaningful, descriptive filename (use snake_case, e.g., `feature_investigation.md`)
- A clear document title

If the conversation covers multiple topics, ask the user which aspect to focus on.

### 3. Structure the document

Create a clear markdown structure, typically including:

- **Title and Summary**: Brief description of the document purpose
- **Background/Purpose**: Why this investigation or development was done
- **Investigation/Analysis**: Detailed findings and analysis results
- **Code Examples**: Relevant code snippets (if applicable)
- **Issues Identified**: Problems or limitations discovered (if applicable)
- **Solutions**: Recommended solutions or implementation approaches (if applicable)
- **Related Files/References**: Relevant file paths, commits, links, etc.
- **Date and Author**: Record creation date

### 4. Format content properly

Use appropriate markdown syntax:
- Use heading levels (#, ##, ###) to organize content
- Use code blocks for code snippets (```language)
- Use lists (ordered or unordered) for bullet points
- Use tables for structured data (if applicable)
- Use bold/italic for emphasis
- Use blockquotes for important notes

### 5. Save the file

- Save to `/project/docs/` directory (absolute path: `/project/docs/`, not relative to current working directory)
- Use descriptive filename (snake_case.md)
- Confirm file creation success

### 6. Confirm completion

Inform the user:
- File path where document was created
- Brief summary of the document content

## Important notes

- **Language**: Write documentation in Traditional Chinese (繁體中文) by default. Keep code examples, technical terms, file paths, and method names in their original language (usually English)
- Keep the document objective and technical
- Include enough detail for others to understand the context
- Ensure code examples have correct syntax
- Use full relative or absolute paths for file references
- If conversation lacks enough context, ask the user what they want documented

## Example filenames

- `feature_investigation.md` - Feature investigation report
- `bug_analysis.md` - Bug analysis
- `implementation_plan.md` - Implementation plan
- `code_review_notes.md` - Code review notes
- `api_integration_guide.md` - API integration guide
- `text_uppercase_investigation.md` - CSS class usage investigation
