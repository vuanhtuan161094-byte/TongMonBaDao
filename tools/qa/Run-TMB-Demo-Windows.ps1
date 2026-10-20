param(
    [ValidateSet("Play", "Focused", "ResetDemo")]
    [string]$Mode = "Play",
    [string]$GodotBin = $env:GODOT_BIN
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$GodotProject = Join-Path $RepoRoot "godot"
$ImportStamp = Join-Path $GodotProject ".godot\tmb_demo_import_fingerprint.txt"
$LogRoot = Join-Path $env:TEMP "tmb-demo-v3"
New-Item -ItemType Directory -Force -Path $LogRoot | Out-Null

if ([string]::IsNullOrWhiteSpace($GodotBin)) {
    $Candidates = @(
        "E:\Godot_v4.7.2-stable_win64.exe",
        (Join-Path $GodotProject "Godot_v4.7.2-stable_win64.exe")
    )
    foreach ($Candidate in $Candidates) {
        if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
            $GodotBin = $Candidate
            break
        }
    }
}
if ([string]::IsNullOrWhiteSpace($GodotBin)) {
    $GodotCommand = Get-Command "godot.exe" -ErrorAction SilentlyContinue
    if ($null -ne $GodotCommand) { $GodotBin = $GodotCommand.Source }
}
if ([string]::IsNullOrWhiteSpace($GodotBin) -or -not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
    throw "Không tìm thấy Godot 4.7.2. Đặt GODOT_BIN hoặc truyền -GodotBin với đường dẫn godot.exe."
}

$GodotCliBin = $GodotBin
$GodotBaseName = [System.IO.Path]::GetFileNameWithoutExtension($GodotBin)
if (-not $GodotBaseName.EndsWith("_console", [System.StringComparison]::OrdinalIgnoreCase)) {
    $ConsoleCandidate = Join-Path (Split-Path -Parent $GodotBin) ($GodotBaseName + "_console.exe")
    if (Test-Path -LiteralPath $ConsoleCandidate -PathType Leaf) { $GodotCliBin = $ConsoleCandidate }
}

$VersionOutput = (& $GodotCliBin --headless --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $VersionOutput -notmatch '^4\.7\.2') {
    throw "Launcher yêu cầu Godot 4.7.2; engine hiện tại trả về: $VersionOutput"
}
Write-Host "Godot $VersionOutput | $Mode"

function Get-ProjectFingerprint {
    $Rows = Get-ChildItem -LiteralPath $GodotProject -File -Recurse |
        Where-Object { $_.FullName -notlike "$GodotProject\.godot\*" -and $_.FullName -notlike "$GodotProject\.git\*" } |
        Sort-Object FullName |
        ForEach-Object {
            $Relative = $_.FullName.Substring($GodotProject.Length).Replace("\", "/")
            $Hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
            "$Relative`t$Hash"
        }
    $Payload = [System.Text.Encoding]::UTF8.GetBytes(($Rows -join "`n"))
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    try {
        $Digest = $Hasher.ComputeHash($Payload)
        return ([BitConverter]::ToString($Digest)).Replace("-", "").ToLowerInvariant()
    }
    finally { $Hasher.Dispose() }
}

if ($Mode -ne "ResetDemo") {
    $Fingerprint = Get-ProjectFingerprint
    $CachedFingerprint = if (Test-Path -LiteralPath $ImportStamp) { (Get-Content -LiteralPath $ImportStamp -Raw).Trim() } else { "" }
    if ($Fingerprint -ne $CachedFingerprint) {
        Write-Host "Import cache thay đổi; chạy Godot import một lần."
        $ImportLog = Join-Path $LogRoot "import.log"
        & $GodotCliBin --headless --editor --path $GodotProject --log-file $ImportLog --import --quit
        if ($LASTEXITCODE -ne 0) { throw "Godot 4.7.2 import thất bại, mã $LASTEXITCODE." }
        if (Test-Path -LiteralPath $ImportLog) { Get-Content -LiteralPath $ImportLog -Tail 40 }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ImportStamp) | Out-Null
        Set-Content -LiteralPath $ImportStamp -Value $Fingerprint -Encoding ascii
    } else {
        Write-Host "Import cache không đổi; dùng lại cache Godot hiện có."
    }
}

switch ($Mode) {
    "Play" {
        $Log = Join-Path $LogRoot "play.log"
        & $GodotBin --path $GodotProject --scene "res://scenes/demo/demo_launcher.tscn" --log-file $Log
        $ExitCode = $LASTEXITCODE
        if (Test-Path -LiteralPath $Log) {
            Get-Content -LiteralPath $Log -Tail 160 | Set-Content -LiteralPath "$Log.trimmed" -Encoding utf8
            Move-Item -LiteralPath "$Log.trimmed" -Destination $Log -Force
        }
        exit $ExitCode
    }
    "Focused" {
        $Log = Join-Path $LogRoot "focused.log"
        & $GodotCliBin --headless --path $GodotProject --log-file $Log -s "res://tests/presentation/pd01_demo_max_playable_test.gd"
        $ExitCode = $LASTEXITCODE
        if (Test-Path -LiteralPath $Log) { Get-Content -LiteralPath $Log -Tail 100 }
        $LogText = if (Test-Path -LiteralPath $Log) { Get-Content -LiteralPath $Log -Raw } else { "" }
        if ($ExitCode -ne 0 -or $LogText -notmatch "DEMO_RESULT=PASS") {
            throw "PD-00/PD-01 focused QA FAIL, mã $ExitCode hoặc thiếu marker DEMO_RESULT=PASS. Log: $Log"
        }
        Write-Host "PD-00/PD-01 focused QA PASS. Log: $Log"
    }
    "ResetDemo" {
        $Log = Join-Path $LogRoot "reset-demo.log"
        & $GodotCliBin --headless --path $GodotProject --log-file $Log -s "res://tools/qa/reset_demo_sandbox.gd"
        if ($LASTEXITCODE -ne 0) { throw "ResetDemo thất bại, mã $LASTEXITCODE. Log: $Log" }
        if (Test-Path -LiteralPath $Log) { Get-Content -LiteralPath $Log -Tail 30 }
    }
}
