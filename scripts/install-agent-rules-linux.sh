#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_FILE="$REPO_ROOT/docs/ALL_AGENTS_INSTALL.md"
BLOCK_START="<!-- CURSOR_COVENANT_RULE_START -->"
BLOCK_END="<!-- CURSOR_COVENANT_RULE_END -->"

read -r -d '' BLOCK <<'BLOCK' || true
<!-- CURSOR_COVENANT_RULE_START -->

## Cursor Covenant — hard mouse/keyboard control rule

Before any agent moves the mouse, clicks, types, pastes, sends hotkeys, uses Computer Use/RPA/UI automation, or otherwise competes with the human for interactive desktop control:

1. Display a visible, topmost warning on the human's primary screen.
2. State exactly what control is needed and for how long.
3. Give at least a 5-second countdown; default to 10 seconds.
4. During the countdown, do not move the pointer, click, type, paste, or send hotkeys.
5. The warning dialog must have a visible **CANCEL MOUSE CONTROL** button that cancels before control is taken; double-clicking the dialog remains a backup cancel gesture.
6. Use Cursor Covenant `-Mode Click` before mouse control and `-Mode Keyboard` before typing/pasting/hotkeys.
7. Perform only the announced action.
8. Release control immediately and report the action/result.
9. If the human moves the mouse, types, clicks cancel, double-clicks cancel, or says stop/cancel, abort and reacquire a new cursor lease before trying again.

Windows helper:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor-covenant\cursor-covenant.ps1" -Seconds 10 -Mode Keyboard -Message "Agent needs keyboard control. Please do not touch mouse/keyboard."
```

Repo: https://github.com/five0nit/cursor-covenant

<!-- CURSOR_COVENANT_RULE_END -->
BLOCK

if [[ $# -eq 0 ]]; then
  TARGETS=(
    "$HOME/.openclaw/workspace/AGENTS.md"
    "$HOME/.openclaw/workspace/coordination/AGENTS.md"
    "$HOME/.codex/AGENTS.md"
    "$HOME/.claude/CLAUDE.md"
  )
else
  TARGETS=("$@")
fi

for target in "${TARGETS[@]}"; do
  [[ -e "$target" ]] || { echo "skip_missing $target"; continue; }
  python3 - "$target" "$BLOCK_START" "$BLOCK_END" "$BLOCK" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
start, end, block = sys.argv[2], sys.argv[3], sys.argv[4]
text = path.read_text(encoding='utf-8', errors='replace')
if start in text and end in text:
    pre = text.split(start, 1)[0].rstrip()
    post = text.split(end, 1)[1].lstrip()
    new = pre + "\n\n" + block.strip() + "\n\n" + post
else:
    new = text.rstrip() + "\n\n" + block.strip() + "\n"
if new != text:
    path.write_text(new, encoding='utf-8')
    print(f"updated {path}")
else:
    print(f"unchanged {path}")
PY
done
