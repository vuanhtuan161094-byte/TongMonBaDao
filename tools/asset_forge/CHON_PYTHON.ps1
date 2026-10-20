# A guided one-time choice for Python installed in an unusual location.
$ErrorActionPreference='Stop'
$selected=$null
try {
  Add-Type -AssemblyName System.Windows.Forms
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = 'Select your installed Python 3.10+ executable (python.exe)'
  $dlg.Filter = 'Python interpreter (python.exe)|python.exe|Executables (*.exe)|*.exe'
  $dlg.CheckFileExists = $true
  if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $selected=$dlg.FileName }
} catch { }
if (-not $selected) { $selected = Read-Host 'Enter full path to your python.exe (or press Enter to cancel)' }
if (-not $selected) { Write-Output '[INFO] Cancelled.'; exit 3 }
$selected = $selected.Trim().Trim('"')
if (-not (Test-Path -LiteralPath $selected -PathType Leaf)) { Write-Output '[ERROR] File not found.'; exit 3 }
if ($selected -like '*\Microsoft\WindowsApps\*') { Write-Output '[ERROR] Microsoft Store alias is not a Python runtime.'; exit 3 }
& $selected -I -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 2)' 2>$null
if ($LASTEXITCODE -ne 0) { Write-Output '[ERROR] Interpreter failed or version is below Python 3.10.'; exit 3 }
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot 'python.local.txt'), $selected + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ('[PASS] Saved local Python interpreter path: ' + $selected)
Write-Output '[INFO] Now run MO_ASSET_FORGE_STUDIO.cmd.'
exit 0
