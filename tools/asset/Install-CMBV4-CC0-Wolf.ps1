# CMB-V4-VP01 CC0 animation proof only (no VLTK1 copyrighted art).
# Download one independently licensed wolf_run.png, five horizontal 66x66 frames.
# Windows PowerShell: powershell -ExecutionPolicy Bypass -File tools/asset/Install-CMBV4-CC0-Wolf.ps1
[CmdletBinding()]
param([switch]$NoDownload)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$stage = Join-Path $repoRoot 'godot\assets\labs\combat_v4\cc0_wolf'
$target = Join-Path $stage 'wolf_run.png'
$source = 'https://opengameart.org/sites/default/files/wolf_run.png'
$landing = 'https://opengameart.org/content/pixel-wolf'
$author = 'alizard'
if (!(Test-Path -LiteralPath $stage)) { New-Item -ItemType Directory -Force -Path $stage | Out-Null }
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('cmb_v4_wolf_' + [guid]::NewGuid().ToString('N') + '.png')
try {
    if ($NoDownload) {
        if (!(Test-Path -LiteralPath $target)) { throw "No staged source PNG: $target" }
        Copy-Item -LiteralPath $target -Destination $tmp
    } else {
        Invoke-WebRequest -Uri $source -UseBasicParsing -OutFile $tmp -TimeoutSec 50
    }
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 50) { throw 'Source PNG too short' }
    $pngSig = [byte[]](137,80,78,71,13,10,26,10)
    for($i=0; $i -lt $pngSig.Length; $i++) {
        if($bytes[$i] -ne $pngSig[$i]) { throw 'Source is not PNG' }
    }
    $w = ([int]$bytes[16] * 16777216) + ([int]$bytes[17] * 65536) + ([int]$bytes[18] * 256) + [int]$bytes[19]
    $h = ([int]$bytes[20] * 16777216) + ([int]$bytes[21] * 65536) + ([int]$bytes[22] * 256) + [int]$bytes[23]
    if ($w -ne 330 -or $h -ne 66) { throw ("Unexpected wolf atlas {0}x{1}, expected 330x66 (5x66)." -f $w,$h) }
    $sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $tmp).Hash.ToLowerInvariant()
    if (Test-Path -LiteralPath $target) {
        $existing = (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash.ToLowerInvariant()
        if ($existing -ne $sha) { throw 'Target exists with DIFFERENT SHA256. Refusing to overwrite.' }
    } else {
        Move-Item -LiteralPath $tmp -Destination $target
    }
    Write-Host "CMB-V4 CC0 WOLF VERIFIED: $target"
    Write-Host "Size: 330x66; frames: 5x66x66; SHA256: $sha"
    Write-Host "License: CC0; author: $author; $landing"
    Write-Host "No asset inserted into GitHub automatically. Isolated visual lab only."
} finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
}
