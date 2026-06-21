$ErrorActionPreference = 'Stop'
$dest = Join-Path $env:USERPROFILE '.cursor-covenant'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Force -Path (Join-Path $PSScriptRoot 'cursor-covenant.ps1') -Destination (Join-Path $dest 'cursor-covenant.ps1')
Write-Output "Installed Cursor Covenant to $dest\cursor-covenant.ps1"
Write-Output "Example: powershell.exe -NoProfile -ExecutionPolicy Bypass -File $dest\cursor-covenant.ps1 -Seconds 10 -Mode WarnOnly"
