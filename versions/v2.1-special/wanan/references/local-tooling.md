# Local tooling and Windows session preflight

Run this preflight once per root task in the main controller. Branches inherit the result and must not scan again.

## Capability manifest

Record five capabilities: `read`, `glob`, `grep`, `bash`, and `replace`.

| Capability | Native preference | Bundled fallback |
|---|---|---|
| `read` | Dedicated bounded read with line and encoding controls | `python scripts/file_ops.py read --path FILE --start 1 --end 200 --encoding auto` |
| `glob` | Dedicated glob tool | `python scripts/file_ops.py glob --root ROOT --pattern=**/*.md` |
| `grep` | Dedicated grep/search tool; prefer `rg` when shell-backed | `python scripts/file_ops.py grep --root ROOT --glob=**/*.md --pattern REGEX` |
| `bash` | Git Bash on Windows; normal Bash elsewhere | Resolve `bash` from PATH, then `C:/Program Files/Git/bin/bash.exe` and `C:/Program Files/Git/usr/bin/bash.exe` |
| `replace` | Dedicated replace tool for mechanical edits; precise patch for small edits | Dry-run then apply `python scripts/file_ops.py replace ... --expected N --apply` |

Do not repeat capability discovery in branches. Copy the controller manifest into their initial task contract.

## Safe file behavior

- Read only the required line range. Use `--encoding auto` for UTF-8 BOM, UTF-16, UTF-8, and GB18030 fallback detection.
- Scope glob and grep to the smallest project root and patterns. Return paths and line numbers.
- Use a precise patch for small edits. Use bulk replace only for literal, mechanical changes.
- Run replace without `--apply` first. Inspect paths and counts, then require the exact total with `--expected` when applying. Pass wildcard arguments as `--glob=PATTERN` or `--pattern=PATTERN` so the shell cannot expand them before the adapter receives them.
- The adapter skips symlinks and writes each changed file atomically in place while preserving its mode and detected encoding.

## Windows shell and UTF-8

Invoke Git Bash explicitly when `bash` is not on PATH:

```text
C:\Program Files\Git\bin\bash.exe -lc "<command>"
```

Choose one stable root task ID and source the preflight:

```bash
source scripts/windows-session-preflight.sh "$ROOT_TASK_ID"
```

The first call writes a cached environment file and report under `~/.wanan/state/<root-task-id>/`. Later controller or branch shells source the cache without rescanning. It sets only child-process variables: `TEMP`, `TMP`, `TMPDIR`, `LANG`, `LC_ALL`, `PYTHONUTF8`, and `PYTHONIOENCODING`.

The first run creates a new empty directory from `~/.wanan/temp/<root-task-id>.XXXXXX/` with `mktemp -d`; it never reuses a pre-existing same-name directory. Do not delete or modify the user's system `%TEMP%`. At final completion, the controller may remove only the exact generated task directory recorded in the manifest after resolving the path and proving it is below `~/.wanan/temp/`; retain it when a branch or resumable handoff still needs it.

Prefer Git Bash for ordinary terminal work. If a `.ps1` or Windows-only operation is required, use PowerShell 7 with `-NoLogo -NoProfile` and process-local UTF-8. Do not use Windows PowerShell 5 as a silent fallback for text mutation. If `pwsh` is missing, use an equivalent bundled adapter or request authorization for an official PowerShell 7 installation. Never edit the user's PowerShell profile unless explicitly requested.

## One-time scan boundary

The preflight performs one bounded, top-level count of the original temp directory and stops at the warning threshold. It does not recurse, calculate full size, or clean anything. Cache the finding even when crowded; the solution is the dedicated task temp, not repeated diagnosis.

Re-run only for a new root task or when direct evidence shows the manifest is stale, such as a missing executable that the cached path claimed was present.
