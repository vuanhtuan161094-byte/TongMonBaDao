# AS-CHAR-39 | Free portable pixel editor for Codex Local.
# Windows PowerShell 5.1+, 64-bit. No admin. Installs only on E:.
# This installs a tool; it does NOT generate an approved character animation.
param([string]$Base = 'E:\TongMonBaDaoWorkspace\Tools\PixelArt')
$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$Url='https://github.com/LibreSprite/LibreSprite/releases/download/v1.3/libresprite-v1.3-windows-x86_64.zip'
$Expected='8408d2f962121948e9fbee053756b5e1e7e88d6d645120574d13fca66d475874'
if (-not (Test-Path 'E:\')) { throw 'E: drive not found; will NOT install on C:.' }
if (-not $Base.StartsWith('E:\',[StringComparison]::OrdinalIgnoreCase)) { throw 'E: is required.' }
$App=Join-Path $Base 'LibreSprite-v1.3'
$Dl=Join-Path $Base 'downloads'
New-Item -ItemType Directory -Force -Path $Base,$Dl | Out-Null
$Zip=Join-Path $Dl 'libresprite-v1.3-windows-x86_64.zip'
$Exe=Get-ChildItem -LiteralPath $App -Filter 'libresprite.exe' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $Exe) {
  $ok=$false
  if (Test-Path $Zip) { $ok=((Get-FileHash -LiteralPath $Zip -Algorithm SHA256).Hash.ToLowerInvariant() -eq $Expected) }
  if (-not $ok) {
    if (Test-Path $Zip) { Remove-Item -LiteralPath $Zip -Force }
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Zip -MaximumRedirection 8
  }
  $Actual=(Get-FileHash -LiteralPath $Zip -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($Actual -ne $Expected) { throw ('Unsafe or corrupt download. SHA256: '+$Actual) }
  if (Test-Path $App) { throw 'Existing app directory is incomplete; refusing to overwrite it.' }
  New-Item -ItemType Directory -Path $App | Out-Null
  Expand-Archive -LiteralPath $Zip -DestinationPath $App
  $Exe=Get-ChildItem -LiteralPath $App -Filter 'libresprite.exe' -File -Recurse | Select-Object -First 1
}
if (-not $Exe) { throw 'No libresprite.exe after extraction.' }
$Version=(& $Exe.FullName --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $Version -notmatch '1\.3') { throw ('CLI verification failed: '+$Version) }
$Report=[ordered]@{
  status='TOOL_INSTALLED_CLI_CHECKED'
  executable=$Exe.FullName
  version=$Version
  source='GitHub LibreSprite/LibreSprite official v1.3'
  downloaded_zip_sha256=$Expected
  destination=$Base
  native_pixel_art_approved=$false
  animation_48_clip_complete=$false
  godot_472_tested=$false
}
$Report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $Base 'INSTALL_STATUS.json') -Encoding UTF8
Write-Host ('OK LibreSprite: '+$Version)
Write-Host ('EXE: '+$Exe.FullName)
Write-Host ('STATUS FILE: '+(Join-Path $Base 'INSTALL_STATUS.json'))
Write-Host 'NOTICE: Installed software is not a pixel art or animation QA pass.'
