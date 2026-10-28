# Commit message guide

Shared by `/commit` and `/commit-update`, and followed whenever a commit is prepared in conversation. The message records *why* the change exists, so a reader of `git log` understands it without the conversation.

## 1. Gather the sources

The diff says *what* changed. The *why* lives elsewhere; collect it from all of these:

- **The conversation**: the problem as it was reported (the symptom the user or OP saw, with a concrete case such as a plan number or fund code), the rule or decision reached, and alternatives that were rejected along with the reason.
- **Removed code comments**: when comments were trimmed during the work, their reasoning moves into the message.
- **Earlier commits on the branch** (`git log --oneline master..HEAD`): name the ones this change builds on when it depends on them.
- **The code itself**: verify each factual claim before writing it, e.g. "only `save_only` calls this hook" means grepping the callers. Rewrite or drop any claim that does not hold.

The conversation lacks the background when it never mentions the changed files, or mentions them without saying why they changed (typical of a new or compacted session). In that case, stop and ask the user to choose:

- **Search earlier sessions**: grep the recent transcripts in `/root/.claude/projects/-proj-nerv-hk/*.jsonl` for the changed file names and read only the matching excerpts.
- **Give the background directly**: the user explains the reported problem and the reason for the change.

Done when every sentence you plan to write traces to one of these sources.

## 2. Write the message (English)

```
<Subject: the outcome, imperative, capitalized, ≤ 50 chars, no period>

<Problem: what was wrong, as the user saw it, with a concrete example.>

<Rule / decision and its reason — only when the change follows one.>

- <Each change, with its reason. Include non-obvious technical reasons
  (the gotcha that makes the code look odd).>
- <...>
```

- Wrap the body at 72 characters and put a blank line between the subject and the body.
- List multiple changes or reasons as `- ` bullets.
- Use plain, common words (*convert*, not *coerce*). Keep real identifiers, file names and error class names exactly as they appear, since readers search for them.
- Write in English even when the conversation is in another language.
- Add no `Co-Authored-By` or other attribution.

## 3. Walk through it in Traditional Chinese, sentence by sentence

After the English message, explain every sentence in Traditional Chinese:

- Quote the message one sentence at a time in code blocks: the subject, each sentence of each paragraph, and each sentence of each bullet.
- Under each quote, give a **bold Chinese translation**, then tie it back to what it refers to: the file and line, the bug or symptom it describes, or the test that covers it.

Done when every sentence of the message has been quoted, translated and mapped.

## 4. Stop for approval

End by asking whether to use this message. Run `git commit` only after the user approves or edits it.
