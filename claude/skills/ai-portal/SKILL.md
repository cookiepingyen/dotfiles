---
name: ai-portal
description: Read files (PDF / Excel / images) that the user placed in their Mac's Downloads/ai_portals folder — bank corporate-action advices, CA event spreadsheets, etc. Converts the Mac path to the container path and reads the file.
user-invocable: true
allowed-tools:
  - Read
  - Bash
---

# Read ai_portals files (Mac path → container path)

The user works in a container. Files they place in the Mac folder
`Downloads/ai_portals/` (bank advices, CA event spreadsheets, buy/sell PDFs,
screenshots) are not at the Mac path inside this container — the host
`Downloads` folder is bind-mounted at `/download` (singular, no trailing `s`).

So the target folder inside the container is:

```
/download/ai_portals/
```

## Path conversion rule

```
/Users/<any-username>/Downloads/<rest...>  →  /download/<rest...>
```

The mapping is anchored on the `Downloads/` segment, not the username.
For this skill the `<rest...>` is normally under `ai_portals/`.

- If given a path already starting with `/download/`, use it as-is.
- If given just a filename (no path), assume it lives in `/download/ai_portals/`.

## Steps

### 1. Work out what to read

- If the user invoked `/ai-portal <arg>`:
  - `<arg>` is a Mac path → convert it (rule above).
  - `<arg>` is a bare filename → `/download/ai_portals/<arg>`.
  - No `<arg>` → list the folder (step 2) and read everything, or ask which file
    if the user's intent is narrower.
- If a Mac-style path appears earlier in the conversation, use that.

### 2. List the folder first

```
ls -la /download/ai_portals/
```

If the folder is missing, try `find /download -iname 'ai_portal*' -maxdepth 3`
and report what you find. Ignore noise like `.DS_Store`.

### 3. Read each file by type

- **PDF** → `Read` tool directly (it renders pages; use the `pages` arg for
  long PDFs). Bank advices here are usually 1–2 pages each.
- **Image** (png/jpg) → `Read` tool directly.
- **Excel (.xlsx)** → it is a zip of XML, the `Read` tool cannot show its cells.
  Unzip to a scratch dir and parse the sheets, resolving shared strings. Dump
  every sheet (the useful data is often in a later tab). Example:

  ```bash
  cd "$SCRATCH" && rm -rf x && mkdir x && cd x && unzip -o -q "/download/ai_portals/<file>.xlsx"
  python3 - <<'EOF'
  import re, xml.etree.ElementTree as ET
  NS='{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
  ss=[''.join(t.text or '' for t in si.iter(f'{NS}t'))
      for si in ET.parse('xl/sharedStrings.xml').getroot().findall(f'{NS}si')]
  names=[s.get('name') for s in ET.parse('xl/workbook.xml').getroot().iter(f'{NS}sheet')]
  print("SHEETS:", names)
  for i, nm in enumerate(names, 1):
      print(f"\n===== {nm} (sheet{i}.xml) =====")
      for row in ET.parse(f'xl/worksheets/sheet{i}.xml').getroot().iter(f'{NS}row'):
          out=[]
          for c in row.findall(f'{NS}c'):
              ref=c.get('r'); t=c.get('t'); v=c.find(f'{NS}v'); isn=c.find(f'{NS}is')
              if v is not None: val=ss[int(v.text)] if t=='s' else v.text
              elif isn is not None: val=''.join(x.text or '' for x in isn.iter(f'{NS}t'))
              else: continue
              out.append(f"{re.match(r'([A-Z]+)', ref).group(1)}={val}")
          if out: print(' | '.join(out))
  EOF
  ```

  Use the session scratchpad dir for `$SCRATCH`, not `/tmp`.

### 4. Report

Summarise what each file contains. For spreadsheets, name the tabs and pull out
the figures the user cares about. Don't dump raw XML at the user.

## Important notes

- Never read the literal `/Users/...` path — it doesn't exist in the container.
- The real folder is `ai_portals` (plural). Accept `ai_portal` / `ai-portal`
  loosely and resolve to the actual folder found by `ls` / `find`.
- Filenames here can mislead (e.g. a "Buy_BR63S" PDF may also contain BR62S) —
  read the content, don't trust the name.
