param(
    [string]$CanonicalRepo = 'E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao',
    [string]$QaWorktree = 'E:\TongMonBaDaoWorkspace\QA_Evidence\AN03\repo',
    [string]$Branch = 'feature/an03-modular-rig-weapon-socket-20261103',
    [string]$GodotConsole = 'E:\Godot_v4.7.2-stable_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
# Non-destructive: no clean/reset/checkout/merge in canonical workspace.
# This script may only create a NEW detached QA worktree.
function Invoke-Git {
    param([string[]]$Args)
    & git @Args
    if ($LASTEXITCODE -ne 0) { throw "git exit $LASTEXITCODE : $($Args -join ' ')" }
}
if (-not (Test-Path -LiteralPath (Join-Path $CanonicalRepo '.git'))) {
    throw "Canonical repository not found: $CanonicalRepo"
}
if (Test-Path -LiteralPath $QaWorktree) {
    throw "QA target already exists: $QaWorktree. Refusing to overwrite/delete existing worktree or user data. Inspect it manually."
}
$parent = Split-Path -Parent $QaWorktree
if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
Write-Host "[AN03] Fetching ONLY the dedicated feature branch, no canonical checkout changes"
Invoke-Git -Args @('-C', $CanonicalRepo, 'fetch', 'origin',
    ('refs/heads/' + $Branch + ':refs/remotes/origin/' + $Branch))
$remoteSha = (& git -C $CanonicalRepo rev-parse ('refs/remotes/origin/' + $Branch)).Trim()
if ($LASTEXITCODE -ne 0 -or $remoteSha -notmatch '^[a-f0-9]{40}$') {
    throw 'Could not verify feature SHA. Worktree not created.'
}
Write-Host "[AN03] Feature SHA: $remoteSha"
Invoke-Git -Args @('-C', $CanonicalRepo, 'worktree', 'add', '--detach',
    $QaWorktree, ('refs/remotes/origin/' + $Branch))
$actualSha = (& git -C $QaWorktree rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $actualSha -ne $remoteSha) {
    throw "Detached worktree SHA mismatch. Expected $remoteSha; got $actualSha"
}
Write-Host "[AN03] Isolated worktree created: $QaWorktree"
if (-not (Test-Path -LiteralPath $GodotConsole)) {
    Write-Warning "Official Godot console exe not found: $GodotConsole"
    Write-Warning 'Install/use Godot 4.7.2 official or set TMB_GODOT and run MO_AN03_RUN_ALL.cmd in the isolated worktree.'
    exit 2
}
$env:TMB_GODOT = $GodotConsole
Write-Host '[AN03] Running import, focused test, 1280x720 GUI capture, 46-frame GPU bake and evidence ZIP'
Push-Location $QaWorktree
try {
    & cmd.exe /d /c (Join-Path $QaWorktree 'MO_AN03_RUN_ALL.cmd')
    $exit = $LASTEXITCODE
} finally {
    Pop-Location
}
$zip = Join-Path $QaWorktree 'godot\outputs\an03_lab\AN03_EVIDENCE.zip'
if (Test-Path -LiteralPath $zip) {
    Write-Host "[AN03] Share this actual evidence ZIP: $zip"
} else {
    Write-Warning '[AN03] Evidence ZIP not created; inspect worktree logs.'
}
if ($exit -ne 0) { throw "AN03 engine QA failed with exit code $exit. Upload evidence ZIP for actual diagnosis." }
Write-Host "[AN03] TECHNICAL guide QA finished. Art acceptance still pending real Shadow model."
