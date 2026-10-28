---
name: make-plan
description: Create a step-by-step implementation plan from conversation context and save to /project/docs/ (absolute path)
user-invocable: true
allowed-tools:
  - Write
  - Bash
  - Read
  - Grep
  - Glob
---

# Make Implementation Plan

Turn the current investigation into a **forward-looking implementation plan** that
someone can follow with their hands on the keyboard, and save it under `/project/docs/`.

## When to use this vs `/make-markdown`

| | `/make-markdown` | `/make-plan` (this) |
|---|---|---|
| Tense | what already happened | what has **not been done yet** |
| Structure | grouped by topic | **ordered steps** |
| Each unit | a description | **改什麼 / 為什麼 / 怎麼改** |
| File paths | for reference | **must be complete and openable** |

If the user asks to "記錄" / "整理" a finished investigation, use `/make-markdown`.
If the user asks 「規劃」/「怎麼實作」/「要改哪些地方」, use this.

## The one rule that matters most

**Every code block must state which file it goes in, and where in that file.**

A reader must never have to guess. Bad:

```
建議做法：
init() {
  this.fundIds = ...
}
```

Good:

```
**改什麼**：`app/javascript/alpine/views/service_record_item/portfolio_docs.js`

**怎麼改**：把 `init()` 改為：
...
```

Never write a bare filename like `attachment.rb` or `select2.js` — codebases have
many files with the same basename. Always the full repo-relative path, with a line
number when you know it (`app/models/attachment.rb:182`).

## Steps

### 1. Ground the plan in the real codebase

Before writing, verify with Read/Grep/Bash:

- every file path you cite exists
- line numbers are current
- constants, methods and i18n keys are named correctly
- claims about framework behaviour come from reading the source, not memory

State in the doc how each non-obvious claim was verified. If something could not be
verified, say so explicitly rather than asserting it.

### 2. Decide the filename and directory

Same rules as `/make-markdown`:

**A path argument is a DIRECTORY unless it ends in `.md`.**

| Argument | Means | Result |
|---|---|---|
| `foo/bar` | directory | create `/project/docs/foo/bar/<you-name-it>.md` |
| `foo/bar.md` | file | create `/project/docs/foo/bar.md` |
| (none) | — | pick both yourself |

Use a descriptive snake_case name ending in `_plan.md`.

### 3. Structure

```
# <題目> — 實作規劃

> 目的 / 建立日期 / 前置作業（相關 commit）

## 一、需求
   規格來源、適用範圍、不適用的範圍（並說明為何排除）

## 二、技術背景 / 難點
   為什麼這件事不是照抄現有做法就好。
   把查證過的事實放這裡，附行號。

## 三、實作步驟          ← 核心
   步驟 1 … 步驟 N

## 四、不需改動的部分
   哪些地方會自動涵蓋，為什麼

## 五、待確認事項
   表格：# / 問題 / 影響

## 六、相關檔案
   表格：完整路徑 / 本次是否改動

## 附註：驗證方式
   哪些結論是實際查證的，哪些尚未驗證
```

### 4. Write each step in the same shape

```markdown
### 步驟 N：<一句話說明這步達成什麼>

**改什麼**：`完整/檔案/路徑.rb`（新建 / 既有）

**為什麼**：這一步要解決什麼問題，不做會怎樣

**怎麼改**：具體位置 + 程式碼
```

#### Explain non-obvious code line by line

When a step introduces code the reader has not written before — a new framework
API, an event-binding pattern, a chained call, anything with a gotcha — add a
`#### 逐行說明` subsection after the code block.

**A longer document that is understood beats a short one that is copy-pasted
blindly.** Do not compress this away.

For each line or small group of lines, say:

- what it does
- **why it is written this way and not the obvious alternative**
- what breaks if it is omitted or written differently

The "why not the obvious alternative" part is what makes this worth reading.
Examples of the kind of thing to surface:

- `() => {}` vs `function () {}` — which `this` you end up with
- `$(...).map(...).get()` — why `.get()` cannot be dropped
- `.filter(Boolean)` — what values it removes and why they appear
- `x || []` — what throws without it
- a namespaced event (`change.foo`) — why the namespace matters on teardown
- assigning a new array vs mutating one — which one a reactive framework notices
- a property deliberately *not* declared — what it would shadow

Skip this for lines that are genuinely self-evident. Group consecutive trivial
lines together rather than padding one bullet per line.

Rules:

- Order steps by **execution order**, not by file type or layer
- One step = one coherent change; if a step touches three files, list all three
  under 改什麼 and say which does what
- Mark finished steps `✅ 已完成`, and note whether they are committed
- Split phases when the work naturally lands in more than one commit
  (e.g. 第一階段 backend / 第二階段 frontend), and say what is independently
  verifiable after each phase
- Call out the step most likely to be forgotten, and why it matters
- End with a 步驟總覽 table: 步驟 / 檔案 / 新建 or 修改

### 5. Be honest about risk

- Mark the step carrying the most uncertainty, and what would need testing
- When you recommend one of several options, show the alternatives and the
  trade-off — do not silently pick one
- Record decisions already made with the user (and the date), separately from
  what is still open

### 6. Confirm

Tell the user the file path and give a short summary of the steps.

## Length

Do not optimise for brevity. A plan is read while making the change, and the
reader needs enough to act without guessing. Depth that earns its place:

- 逐行說明 for unfamiliar or gotcha-laden code
- the reasoning behind a decision, not just the decision
- what was verified and how

Cut only genuine repetition — the same explanation appearing twice, or a
section restating the step summary table.

## Language

Write in Traditional Chinese (繁體中文). Keep code, file paths, identifiers and
technical terms in their original form.
