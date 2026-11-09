param(
    [string] $GodotExe = 'E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe',
    [string] $OutputRoot = 'E:\TongMonBaDaoWorkspace\03_QA_Logs\PoisonV3Video',
    [string] $FfmpegExe = ''
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$project = Join-Path $repo 'godot'
$manifest = Join-Path $project 'labs\combat_lab\assets\poison_vfx\poison_vfx_manifest.json'
$captureScript = Join-Path $project 'tests\labs\combat_lab\poison_v3_video_capture.gd'
function Get-VerifiedSHA256([string] $Path) {
    $stream = $null; $sha = $null
    try {
        $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        $sha = [Security.Cryptography.SHA256]::Create()
        if ($null -eq $sha) { throw 'SHA-256 provider missing' }
        return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant()
    } finally {
        if ($null -ne $sha) { $sha.Dispose() }
        if ($null -ne $stream) { $stream.Dispose() }
    }
}
function Assert-NoGodotProcesses {
    $existing = @(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue)
    if ($existing.Count -gt 0) { throw ('Godot is already running; no PID will be killed: ' + (($existing | ForEach-Object Id) -join ',')) }
}
function Run-Checked([string] $Exe, [string] $Arguments, [string] $Prefix) {
    $stdout = $Prefix + '.stdout.log'; $stderr = $Prefix + '.stderr.log'
    $process = Start-Process -FilePath $Exe -ArgumentList $Arguments -WorkingDirectory $project -PassThru -Wait -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    if ($null -eq $process -or $process.ExitCode -ne 0) {
        throw ('Process failed. See: ' + $stdout + ' and ' + $stderr)
    }
    return $stdout
}
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) { throw "Official Godot missing: $GodotExe" }
if (-not (Test-Path -LiteralPath $manifest -PathType Leaf) -or -not (Test-Path -LiteralPath $captureScript -PathType Leaf)) {
    throw 'Capture script or Poison V3 manifest missing. Use a safely updated PR #72 QA worktree; do not reset dirty files.'
}
Assert-NoGodotProcesses
$version = (& $GodotExe --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2\.stable\.official') { throw "Wrong engine version: $version" }
$data = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
if ([int]$data.schema_version -ne 1 -or @($data.assets).Count -ne 4 -or @($data.preserved_source_actor_atlases).Count -ne 6) {
    throw 'Expected exactly 4 VFX masters and 6 preserved actor atlases'
}
foreach ($item in (@($data.assets) + @($data.preserved_source_actor_atlases))) {
    $uri = [string]$item.path; $expected = ([string]$item.sha256).ToLowerInvariant()
    if (-not $uri.StartsWith('res://') -or $expected -notmatch '^[0-9a-f]{64}$') { throw "Invalid manifest entry: $uri" }
    $relative = $uri.Substring(6)
    if ($relative.Contains(':') -or $relative.Contains('..') -or $relative.StartsWith('/') -or $relative.Contains('\')) { throw "Unsafe asset path: $uri" }
    $file = Join-Path $project ($relative.Replace('/', '\'))
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Asset missing: $file" }
    if ((Get-VerifiedSHA256 $file) -ne $expected) { throw "SHA-256 mismatch: $file" }
}
if (-not $FfmpegExe) {
    $cmd = Get-Command 'ffmpeg.exe' -ErrorAction SilentlyContinue
    if (-not $cmd) { $cmd = Get-Command 'ffmpeg' -ErrorAction SilentlyContinue }
    if ($cmd) { $FfmpegExe = $cmd.Source }
}
if (-not $FfmpegExe -or -not (Test-Path -LiteralPath $FfmpegExe -PathType Leaf)) {
    throw 'FFmpeg executable required to deliver MP4; no fake video fallback.'
}
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
if (([double]$osInfo.FreePhysicalMemory / 1024.0) -lt 1024.0) { throw 'Available RAM below 1024 MiB; aborted before Godot.' }
$outDir = Join-Path $OutputRoot ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ'))
[void][IO.Directory]::CreateDirectory($outDir)
$git = Get-Command 'git.exe' -ErrorAction SilentlyContinue
if (-not $git) { $git = Get-Command 'git' -ErrorAction SilentlyContinue }
if ($git) {
    (& $git.Source -C $repo rev-parse HEAD | Out-String) | Out-File -LiteralPath (Join-Path $outDir 'source_HEAD.txt') -Encoding UTF8
    (& $git.Source -C $repo status --short | Out-String) | Out-File -LiteralPath (Join-Path $outDir 'worktree_dirty_before.txt') -Encoding UTF8
}
Write-Host "SHA-256 VERIFIED 10/10. Godot $version. Output: $outDir"
[void](Run-Checked $GodotExe ('--headless --path "{0}" --import' -f $project) (Join-Path $outDir 'import'))
[void](Run-Checked $GodotExe ('--headless --path "{0}" --check-only --script res://tests/labs/combat_lab/poison_v3_video_capture.gd' -f $project) (Join-Path $outDir 'parse'))
try {
    foreach ($branch in @('doc_cham', 'co_doc', 'duoc_doc')) {
        Assert-NoGodotProcesses
        $env:TMB_POISON_VIDEO_BRANCH = $branch
        $avi = Join-Path $outDir ($branch + '.avi')
        $mp4 = Join-Path $outDir ($branch + '.mp4')
        $log = Run-Checked $GodotExe ('--path "{0}" --resolution 1280x720 --fixed-fps 24 --write-movie "{1}" --script res://tests/labs/combat_lab/poison_v3_video_capture.gd' -f $project,$avi) (Join-Path $outDir $branch)
        $evidence = Get-Content -LiteralPath $log -Raw
        if ($evidence -notmatch 'POISON_V3_VIDEO_RESULT=PASS_EVENTS_ONLY' -or $evidence -notmatch 'cast=[1-9][0-9]*' -or $evidence -notmatch 'release=[1-9][0-9]*') {
            throw "No matching real skill cast/release; rejected video for $branch"
        }
        if (-not (Test-Path -LiteralPath $avi -PathType Leaf) -or (Get-Item -LiteralPath $avi).Length -eq 0) { throw "Godot AVI missing: $avi" }
        [void](Run-Checked $FfmpegExe ('-y -i "{0}" -vf "fps=24,scale=1280:720" -c:v libx264 -preset fast -pix_fmt yuv420p "{1}"' -f $avi,$mp4) (Join-Path $outDir ($branch + '_encoding')))
        if (-not (Test-Path -LiteralPath $mp4 -PathType Leaf) -or (Get-Item -LiteralPath $mp4).Length -eq 0) { throw "MP4 missing: $mp4" }
        Write-Host ("REAL_GODOT_MP4 branch={0} path={1} sha256={2}" -f $branch,$mp4,(Get-VerifiedSHA256 $mp4))
    }
} finally {
    Remove-Item Env:\TMB_POISON_VIDEO_BRANCH -ErrorAction SilentlyContinue
}
Write-Host "POISON_V3_ALL_VIDEOS_CREATED: $outDir (scripted GUI capture; not physical user acceptance)"
