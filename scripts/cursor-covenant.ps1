param(
  [ValidateSet('WarnOnly','Click','Keyboard')]
  [string]$Mode = 'WarnOnly',
  [int]$Seconds = 10,
  [int]$X = 0,
  [int]$Y = 0,
  [string]$Message = 'AI agent needs mouse control. Please do not touch mouse/keyboard.',
  [switch]$UseVirtualScreenCenter
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CursorCovenantNative {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);
  public const uint LEFTDOWN = 0x0002;
  public const uint LEFTUP = 0x0004;
}
"@

if ($Seconds -lt 1) { $Seconds = 1 }

if ($UseVirtualScreenCenter) {
  $area = [System.Windows.Forms.SystemInformation]::VirtualScreen
} else {
  $area = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Cursor Covenant - mouse control warning'
$form.TopMost = $true
$form.StartPosition = 'Manual'
$form.Size = New-Object System.Drawing.Size(980,360)
$form.Location = New-Object System.Drawing.Point(
  [int]($area.Left + ($area.Width - $form.Width) / 2),
  [int]($area.Top + ($area.Height - $form.Height) / 2)
)
$form.BackColor = [System.Drawing.Color]::FromArgb(180,20,20)
$form.ForeColor = [System.Drawing.Color]::White
$form.FormBorderStyle = 'FixedDialog'
$form.ShowInTaskbar = $true

$script:Cancelled = $false
$cancelAction = {
  $script:Cancelled = $true
}
$form.Add_DoubleClick($cancelAction)
$form.Add_MouseDoubleClick($cancelAction)

$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $false
$label.Dock = 'Fill'
$label.Font = New-Object System.Drawing.Font('Segoe UI',22,[System.Drawing.FontStyle]::Bold)
$label.TextAlign = 'MiddleCenter'
$label.Add_DoubleClick($cancelAction)
$label.Add_MouseDoubleClick($cancelAction)

$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Dock = 'Bottom'
$buttonPanel.Height = 86
$buttonPanel.BackColor = [System.Drawing.Color]::FromArgb(80,10,10)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = 'CANCEL MOUSE CONTROL'
$cancelButton.Font = New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold)
$cancelButton.Width = 420
$cancelButton.Height = 56
$cancelButton.BackColor = [System.Drawing.Color]::White
$cancelButton.ForeColor = [System.Drawing.Color]::FromArgb(160,0,0)
$cancelButton.FlatStyle = 'Flat'
$centerCancelButton = {
  $cancelButton.Left = [int](($buttonPanel.ClientSize.Width - $cancelButton.Width) / 2)
  $cancelButton.Top = [int](($buttonPanel.ClientSize.Height - $cancelButton.Height) / 2)
}
$buttonPanel.Add_Resize($centerCancelButton)
$cancelButton.Anchor = 'None'
$cancelButton.Add_Click($cancelAction)
$buttonPanel.Controls.Add($cancelButton)
& $centerCancelButton

$form.Controls.Add($label)
$form.Controls.Add($buttonPanel)
$form.CancelButton = $cancelButton
$form.Show()
$form.Activate()

$verb = if ($Mode -eq 'Click') { "Clicking at $X,$Y" } elseif ($Mode -eq 'Keyboard') { 'Keyboard/hotkey/paste control will be used after countdown.' } else { 'Warning-only test. No mouse or keyboard action will happen.' }
for ($i=$Seconds; $i -ge 1; $i--) {
  if ($script:Cancelled) { break }
  $label.Text = "$Message`n`n$verb`n`nCountdown: $i seconds`n`nClick CANCEL MOUSE CONTROL or double-click this box to abort."
  [System.Windows.Forms.Application]::DoEvents()
  for ($tick=0; $tick -lt 10; $tick++) {
    if ($script:Cancelled) { break }
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Application]::DoEvents()
  }
}

if ($script:Cancelled) {
  $label.Text = 'CANCELLED - no mouse or keyboard action happened. Closing...'
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Seconds 2
  $result = "cursor_covenant_cancelled mode=$Mode seconds=$Seconds"
} elseif ($Mode -eq 'Click') {
  $label.Text = "Cursor claimed. Clicking now.`nKeep hands off for 2 more seconds."
  [System.Windows.Forms.Application]::DoEvents()
  [CursorCovenantNative]::SetCursorPos($X,$Y) | Out-Null
  Start-Sleep -Milliseconds 150
  [CursorCovenantNative]::mouse_event([CursorCovenantNative]::LEFTDOWN,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Milliseconds 80
  [CursorCovenantNative]::mouse_event([CursorCovenantNative]::LEFTUP,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Seconds 2
  $result = "cursor_covenant_clicked x=$X y=$Y seconds=$Seconds"
} elseif ($Mode -eq 'Keyboard') {
  $label.Text = "Keyboard control claimed.`nAgent may now type/paste/send hotkeys. Closing..."
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Seconds 2
  $result = "cursor_covenant_keyboard_claimed seconds=$Seconds"
} else {
  $label.Text = 'Cursor Covenant test complete - no mouse or keyboard action happened. Closing...'
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Seconds 2
  $result = "cursor_covenant_warn_only seconds=$Seconds"
}

$form.Close()
Write-Output $result
