param(
  [ValidateSet('WarnOnly','Click')]
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
$form.Size = New-Object System.Drawing.Size(940,280)
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
$label.Font = New-Object System.Drawing.Font('Segoe UI',24,[System.Drawing.FontStyle]::Bold)
$label.TextAlign = 'MiddleCenter'
$label.Add_DoubleClick($cancelAction)
$label.Add_MouseDoubleClick($cancelAction)
$form.Controls.Add($label)
$form.Show()
$form.Activate()

$verb = if ($Mode -eq 'Click') { "Clicking at $X,$Y" } else { 'Warning-only test. No mouse action will happen.' }
for ($i=$Seconds; $i -ge 1; $i--) {
  if ($script:Cancelled) { break }
  $label.Text = "$Message`n`n$verb`n`nCountdown: $i seconds`n`nDOUBLE-CLICK THIS BOX TO CANCEL."
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
} else {
  $label.Text = 'Cursor Covenant test complete - no mouse action happened. Closing...'
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Seconds 2
  $result = "cursor_covenant_warn_only seconds=$Seconds"
}

$form.Close()
Write-Output $result
