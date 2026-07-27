---
name: screenshots-read
description: Read a screenshot image the user dragged in from their Mac (path like /Users/<user>/Downloads/Screenshots/...), converting it to the container path and displaying it
user-invocable: true
allowed-tools:
  - Read
  - Bash
---

# Read Screenshot (Mac path → container path)

The user works in a container. When they drag a screenshot file from Finder
into the chat, the path they give (or that appears in the prompt) is the
**host Mac path**, not a path that exists inside this container. This skill
converts that path to the real container path and reads the image.

## Path conversion rule

The host `Downloads` folder is bind-mounted into the container at `/download`
(singular, no trailing `s`). Everything under `Downloads/` on the Mac maps
1:1 to the same relative path under `/download/` in the container.

Conversion:

```
/Users/<any-username>/Downloads/<rest...>  →  /download/<rest...>
```

Example:

```
/Users/wubingyan/Downloads/Screenshots/SCR-20260707-lbcm.png
→ /download/Screenshots/SCR-20260707-lbcm.png
```

## Steps

### 1. Get the path

- If the user invoked `/screenshots-read <path>` with an argument, use that path.
- If no argument was given, look for a Mac-style path (`/Users/.../Downloads/...`)
  mentioned earlier in the conversation. If none is found, ask the user to
  drag the file in or paste the path.

### 2. Convert the path

Apply the rule above: strip everything up to and including `Downloads/`,
and prepend `/download/`.

- If the path given is already a container path (starts with `/download/`
  or otherwise doesn't match the `/Users/.../Downloads/...` pattern), use it
  as-is — don't double-convert.

### 3. Verify the file exists

Run `ls -la "<converted path>"`. If it's not found:
- Double check the conversion (typo in username segment doesn't matter, only
  the `Downloads/` anchor matters).
- Try `find /download -iname "<basename>"` in case of a filename mismatch.
- If still not found, report the resolved path you tried and ask the user to
  confirm the file landed in `/download`.

### 4. Read and display

Use the Read tool on the resolved container path to display the image.

## Important notes

- Never try to read the literal `/Users/...` path directly — it does not
  exist inside the container and will always fail.
- The mapping is anchored on the `Downloads/` segment, not on the username,
  since the Mac username won't necessarily match anything in the container.
