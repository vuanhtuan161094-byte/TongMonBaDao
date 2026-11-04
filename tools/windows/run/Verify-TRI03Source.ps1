param(
    [Parameter(Mandatory = $true)]
    [string] $GameRoot,
    [string] $ProfileRoot = ""
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ProfileRoot)) {
    $ProfileRoot = 'E:\TongMonBaDaoWorkspace\03_QA_Logs\TRI03_OWNER_FINAL_20261103\one_game_playtest_profile'
}
$qaRoot = [IO.Path]::GetFullPath('E:\TongMonBaDaoWorkspace\03_QA_Logs').TrimEnd('\')
$profileFull = [IO.Path]::GetFullPath($ProfileRoot).TrimEnd('\')
if (-not $profileFull.StartsWith($qaRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    [Console]::Error.WriteLine('TRI03_SOURCE_VERIFY_FAIL: QA profile must be under E:\TongMonBaDaoWorkspace\03_QA_Logs.')
    exit 5
}
$git = 'C:\Program Files\Git\cmd\git.exe'
$manifestPath = Join-Path $GameRoot 'tools\windows\run\tri03_runtime_source_manifest.json'
$profile = $profileFull
$verifyLog = Join-Path $profile 'Logs\source_verify.txt'
$safeRoot = [IO.Path]::GetFullPath($GameRoot).TrimEnd('\')
$safeDirectory = $safeRoot.Replace('\', '/')

function Stop-Verification([string] $Message, [int] $Code = 1) {
    [Console]::Error.WriteLine("TRI03_SOURCE_VERIFY_FAIL: $Message")
    exit $Code
}

if (-not (Test-Path -LiteralPath $git -PathType Leaf)) {
    Stop-Verification 'Git executable is missing.' 2
}
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Stop-Verification "Source manifest is missing: $manifestPath" 3
}

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
} catch {
    Stop-Verification "Source manifest is not valid JSON: $($_.Exception.Message)" 4
}
if ($manifest.schema_version -ne 2 -or $manifest.branch -notin @(
        'integration/tri-facility-a-b-playable-20261102',
        'integration/pve-p0-playable-ui-20261103')) {
    Stop-Verification 'Manifest schema or supported integrated-game branch does not match.' 5
}
$upstreamSha = [string]$manifest.upstream_pr_sha
if ($upstreamSha -notmatch '^[0-9a-fA-F]{40}$') {
    Stop-Verification 'Manifest must pin the verified PR source commit SHA.' 5
}

$head = (& $git -c "safe.directory=$safeDirectory" -C $safeRoot rev-parse HEAD 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { Stop-Verification 'Could not read the local checkout HEAD.' 6 }
$branch = (& $git -c "safe.directory=$safeDirectory" -C $safeRoot branch --show-current 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne $manifest.branch) {
    Stop-Verification "Checkout branch is not the PR 67 feature branch (found '$branch')." 7
}
& $git -c "safe.directory=$safeDirectory" -C $safeRoot merge-base --is-ancestor $manifest.base_sha $head *> $null
if ($LASTEXITCODE -ne 0) {
    Stop-Verification "Checkout HEAD $head is not based on the verified PR source base $($manifest.base_sha)." 8
}
& $git -c "safe.directory=$safeDirectory" -C $safeRoot merge-base --is-ancestor $upstreamSha $head *> $null
if ($LASTEXITCODE -ne 0) {
    Stop-Verification "Checkout HEAD $head does not contain the pinned upstream source commit $upstreamSha." 8
}

$pins = @{}
foreach ($entry in $manifest.files) {
    $path = [string]$entry.path
    if ([IO.Path]::IsPathRooted($path) -or $path.Contains('..')) {
        Stop-Verification "Unsafe source path in manifest: $path" 9
    }
    $pins[$path] = ([string]$entry.git_blob_sha).ToLowerInvariant()
}
if ($pins.Count -lt 10) { Stop-Verification 'Manifest contains too few pinned source files.' 10 }
if (-not $pins.ContainsKey('CHOI-GAME.cmd') -or -not $pins.ContainsKey('tools/windows/run/Verify-TRI03Source.ps1')) {
    Stop-Verification 'Manifest must pin the user launcher and source verifier.' 10
}

$fingerprintLines = @(
    $manifest.files | ForEach-Object {
        '{0}={1}' -f $_.path, ([string]$_.git_blob_sha).ToLowerInvariant()
    }
)
[Array]::Sort($fingerprintLines, [StringComparer]::Ordinal)
$fingerprintPayload = [Text.Encoding]::UTF8.GetBytes(($fingerprintLines -join "`n") + "`n")
$sha = [Security.Cryptography.SHA256]::Create()
try {
    $actualFingerprint = [BitConverter]::ToString($sha.ComputeHash($fingerprintPayload)).Replace('-', '').ToLowerInvariant()
} finally {
    $sha.Dispose()
}
if ($actualFingerprint -ne ([string]$manifest.source_fingerprint).ToLowerInvariant()) {
    Stop-Verification "Manifest source fingerprint does not match its pinned file list (expected $($manifest.source_fingerprint), actual $actualFingerprint, entries $($fingerprintLines.Count))." 11
}

foreach ($path in $pins.Keys) {
    $fullPath = Join-Path $safeRoot $path
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Stop-Verification "Pinned runtime source is missing: $path" 12
    }
    $actualBlob = (& $git -c "safe.directory=$safeDirectory" -C $safeRoot hash-object -- $path 2>&1 | Out-String).Trim().ToLowerInvariant()
    if ($LASTEXITCODE -ne 0 -or $actualBlob -ne $pins[$path]) {
        Stop-Verification "Runtime source fingerprint mismatch: $path (expected $($pins[$path]), found $actualBlob)." 13
    }
}

# Any changed/new Godot source, scene, or production art must be pinned. Godot
# .import/cache and outputs are intentionally excluded: they are generated QA
# data, not the source payload used to identify this build.
$changedPaths = @(& $git -c "safe.directory=$safeDirectory" -C $safeRoot diff --name-only $manifest.base_sha $head)
$statusLines = @(& $git -c "safe.directory=$safeDirectory" -C $safeRoot status --porcelain --untracked-files=all -- 'godot')
foreach ($line in $statusLines) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $path = $line.Substring(3).Trim().Trim('"')
    $changedPaths += $path
}
$sourceExtensions = @('.gd', '.tscn', '.tres', '.gdshader', '.svg', '.png', '.json', '.cfg')
foreach ($path in ($changedPaths | Sort-Object -Unique)) {
    if ($path -eq 'tools/windows/run/tri03_runtime_source_manifest.json') { continue }
    if ($path.EndsWith('.import')) { continue }
    if ($path.StartsWith('godot/outputs/') -or $path.StartsWith('godot/.godot/')) { continue }
    $extension = [IO.Path]::GetExtension($path).ToLowerInvariant()
    if ($path.StartsWith('godot/') -and $sourceExtensions -contains $extension -and -not $pins.ContainsKey($path)) {
        Stop-Verification "Unpinned changed Godot source would create a mixed runtime: $path" 14
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $verifyLog) | Out-Null
$report = "TRI03_SOURCE_VERIFY_PASS checkout_base=$($manifest.base_sha) checkout_head=$head branch=$branch upstream_pr_source=$upstreamSha source_fingerprint=$actualFingerprint files=$($pins.Count)"
[IO.File]::WriteAllText($verifyLog,"source_fingerprint=$actualFingerprint`r`ncheckout_head=$head`r`nupstream_pr_source=$upstreamSha`r`n$report`r`n",[Text.UTF8Encoding]::new($false))
Write-Output $report
exit 0
