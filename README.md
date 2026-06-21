# Cursor Covenant

**A tiny safety ritual for AI agents that touch the human's mouse.**

Cursor Covenant gives agents a simple, visible, cross-machine convention:

> Before taking mouse/keyboard control, claim the cursor with a loud countdown overlay. Say what you need, how long you need it, and do nothing until the warning has been visible.

This repo was born after an agent nearly had the workflow right, but kept missing a native app's send button while the human was also moving the mouse. The fix is not just better coordinates. The fix is a covenant: **announce control before taking control.**

## Hard rule for agents

If an agent will move the mouse, click, type into a foreground UI, use UI automation, send hotkeys, or otherwise compete with the human for interactive control:

1. Display a visible topmost warning on the human's primary screen.
2. State what control is needed and for how many seconds.
3. Give at least a 5-second countdown; use 10 seconds for non-urgent actions.
4. During the countdown, do not move or click the mouse.
5. The warning box must be cancellable: double-click the dialog to cancel before control is taken.
6. After the countdown, perform only the announced action.
7. Release control immediately and report what happened.
8. If the human moves the mouse, double-clicks cancel, or says stop, abort and re-request a new cursor lease.

Exception: emergency safety action to stop destructive/unwanted execution. Report immediately afterward.

## Windows quick start

Warning only, no click:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\cursor-covenant.ps1 -Seconds 10 -Mode WarnOnly
```

Claim cursor then click:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\cursor-covenant.ps1 -Seconds 10 -Mode Click -X 1000 -Y 700 -Message "Hermes needs the mouse for Codex SEND. Please do not touch mouse/keyboard."
```

Install helper to a per-user tools folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
```

## Why this exists

Remote/agentic UI automation fails in dumb ways:

- multi-monitor coordinate offsets;
- app windows on non-primary displays;
- screenshots scaled differently from cursor coordinates;
- human nudges the mouse at the same time;
- foreground lock and focus steal behavior;
- invisible or off-screen warning overlays.

Cursor Covenant does not solve all UI automation, but it prevents the worst social failure: silently grabbing the cursor while the human is working.

## Recommended agent phrase

Before running the script, tell the user in chat if possible:

> I need the mouse for 10 seconds. A red warning box will appear first. Please keep hands off until it closes.

Then run the overlay. Do not just say it; display it.

## Files

- `scripts/cursor-covenant.ps1` — warning overlay + optional click.
- `scripts/install-windows.ps1` — installs the script to `%USERPROFILE%\.cursor-covenant`.
- `docs/AGENT_RULE.md` — copy/paste hard rule for AGENTS.md / CLAUDE.md / system runbooks.

## License

MIT
