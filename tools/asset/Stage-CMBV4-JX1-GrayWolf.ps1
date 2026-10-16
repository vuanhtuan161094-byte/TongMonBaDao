# CMB-V4: LOCAL-ONLY JX1 sprite preflight. Never commit third-party binary art.
# Origin: https://github.com/hudy9x/jx1-idle-web (Soi xam -> ani009).
# Usage: powershell -ExecutionPolicy Bypass -File tools/asset/Stage-CMBV4-JX1-GrayWolf.ps1
[CmdletBinding()]
param([switch]$VerifyOnly)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$manifestPath = Join-Path $root 'labs\combat_v4_pilot\jx1_gray_wolf_manifest.json'
$manifest = Get-Content -Raw -LiteralPath $manifestPath -Encoding UTF8 | ConvertFrom-Json
$targetRoot = Join-Path $root 'godot\assets\labs\combat_v4\jx1_private'
if (!(Test-Path -LiteralPath $targetRoot)) {
    New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
}
$sourceRepo = 'https://raw.githubusercontent.com/hudy9x/jx1-idle-web/main/'
function Get-GitBlobSha1([string]$file) {
    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($file)
    [byte[]]$header = [System.Text.Encoding]::ASCII.GetBytes('blob ' + $bytes.Length + [char]0)
    [byte[]]$full = New-Object byte[] ($header.Length + $bytes.Length)
    [Array]::Copy($header, 0, $full, 0, $header.Length)
    [Array]::Copy($bytes, 0, $full, $header.Length, $bytes.Length)
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    try { return ([BitConverter]::ToString($sha1.ComputeHash($full))).Replace('-', '').ToLowerInvariant() }
    finally { $sha1.Dispose() }
}
foreach ($item in $manifest.files) {
    $leaf = [System.IO.Path]::GetFileName([string]$item.path)
    $dest = Join-Path $targetRoot $leaf
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("cmb-v4-jx1-" + [guid]::NewGuid().ToString('N') + '.webp')
    try {
        if (Test-Path -LiteralPath $dest) {
            $file = $dest
        } else {
            if ($VerifyOnly) { throw "Asset NOT STAGED: $dest" }
            $url = $sourceRepo + [string]$item.path
            Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $temp -TimeoutSec 50
            $file = $temp
        }
        [byte[]]$bytes = [System.IO.File]::ReadAllBytes($file)
        if ($bytes.Length -lt 16) { throw "Invalid/empty WebP: $leaf" }
        if ([System.Text.Encoding]::ASCII.GetString($bytes,0,4) -ne 'RIFF' -or
            [System.Text.Encoding]::ASCII.GetString($bytes,8,4) -ne 'WEBP') {
            throw "Unexpected file format: $leaf"
        }
        $actual = Get-GitBlobSha1 $file
        if ($actual -ne [string]$item.git_blob_sha1) {
            throw "Repository blob SHA mismatch for $leaf (received $actual)"
        }
        if (-not (Test-Path -LiteralPath $dest)) {
            Move-Item -LiteralPath $temp -Destination $dest
        }
        Write-Host ("VERIFIED {0}: frames={1}; dirs={2}; cell={3}x{4}; interval={5}ms; git_sha={6}" -f
            $leaf, $item.frames, $item.dirs, $item.w, $item.h, $item.ms, $actual)
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
}
Write-Host "CMB-V4 local art stage ready: $targetRoot"
Write-Host 'ORIGINAL JX1 ART: external rights not confirmed; NOT FOR PUBLIC ASSET COMMIT.'
