# Cursor Covenant hard rule for agents

When operating on a human-visible desktop, every agent must treat the mouse/keyboard as a shared physical resource.

## Mandatory rule

Before any action that moves the pointer, clicks, types, sends hotkeys, pastes into a foreground app, uses Computer Use, uses RPA/UI automation, or otherwise competes with the human for interactive control:

1. Display a visible topmost warning on the human's primary screen.
2. State exactly what control is needed and for how long.
3. Give at least a 5-second countdown; default to 10 seconds.
4. During the countdown, do not move the pointer, click, type, paste, or send hotkeys.
5. The warning dialog must be cancellable: double-clicking it cancels the pending mouse/keyboard action.
6. Perform only the announced action.
7. Release control immediately and report the action/result.
8. If the human moves the mouse, types, double-clicks cancel, or says stop/cancel, abort and reacquire a new cursor lease before trying again.

Exception: emergency action to prevent active destructive/unwanted execution. If used, report immediately afterward.

## Preferred Windows implementation

Use Cursor Covenant:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor-covenant\cursor-covenant.ps1" -Seconds 10 -Mode WarnOnly
```

For a click:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor-covenant\cursor-covenant.ps1" -Seconds 10 -Mode Click -X <x> -Y <y> -Message "Agent needs the mouse for <task>. Please do not touch mouse/keyboard."
```

## Operator-facing phrase

"I need the mouse for 10 seconds. A red warning box will appear first. Please keep hands off until it closes."
