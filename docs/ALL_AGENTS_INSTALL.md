# Install Cursor Covenant as a machine-wide agent rule

This is the copy/paste rule for any local agent runtime on a shared human desktop.

## Hard rule

Before any agent moves the mouse, clicks, types, pastes, sends hotkeys, uses Computer Use, uses RPA/UI automation, or otherwise competes with the human for interactive desktop control:

1. Display a visible, topmost warning on the human's primary screen.
2. State exactly what control is needed and for how long.
3. Give at least a 5-second countdown; default to 10 seconds.
4. During the countdown, do not move the pointer, click, type, paste, or send hotkeys.
5. The warning dialog must have a visible **CANCEL MOUSE CONTROL** button that cancels before control is taken; double-clicking the dialog remains a backup cancel gesture.
6. Use `-Mode Click` before mouse clicks/movement and `-Mode Keyboard` before typing/pasting/hotkeys.
7. Perform only the announced action.
8. Release control immediately and report the action/result.
9. If the human moves the mouse, types, clicks cancel, double-clicks cancel, or says stop/cancel, abort and reacquire a new cursor lease before trying again.

Exception: emergency action to prevent active destructive/unwanted execution. If used, report immediately afterward.

## Windows helper

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor-covenant\cursor-covenant.ps1" -Seconds 10 -Mode Keyboard -Message "Agent needs keyboard control to paste into an app. Please do not touch mouse/keyboard."
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.cursor-covenant\cursor-covenant.ps1" -Seconds 10 -Mode Click -X <x> -Y <y> -Message "Agent needs mouse control to click <target>. Please do not touch mouse/keyboard."
```
