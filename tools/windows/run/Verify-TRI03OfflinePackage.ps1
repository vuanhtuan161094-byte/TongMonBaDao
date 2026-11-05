param(
    [Parameter(Mandatory = $true)][string] $GameRoot,
    [string] $ProfileRoot = ''
)
$ErrorActionPreference = 'Stop'

function Fail([string] $Message, [int] $Code = 1) {
    [Console]::Error.WriteLine("TRI03_OFFLINE_VERIFY_FAIL: $Message")
    exit $Code
}
function Get-Sha256Hex([string] $Path) {
    $stream = [IO.File]::OpenRead($Path)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose(); $stream.Dispose() }
}
function Get-GitBlobSha1([string] $Path) {
    $data = [IO.File]::ReadAllBytes($Path)
    # .gitattributes keeps Windows scripts as CRLF in worktrees; Git blob IDs use LF.
    if ([IO.Path]::GetExtension($Path).ToLowerInvariant() -in @('.cmd', '.bat', '.ps1')) {
        $normalized = [System.Collections.Generic.List[byte]]::new($data.Length)
        for ($index = 0; $index -lt $data.Length; $index++) {
            if ($data[$index] -eq 13 -and $index + 1 -lt $data.Length -and $data[$index + 1] -eq 10) {
                $normalized.Add([byte]10)
                $index++
            } else {
                $normalized.Add($data[$index])
            }
        }
        $data = $normalized.ToArray()
    }
    $header = [Text.Encoding]::ASCII.GetBytes(('blob {0}' -f $data.Length) + [char]0)
    $payload = New-Object byte[] ($header.Length + $data.Length)
    [Buffer]::BlockCopy($header, 0, $payload, 0, $header.Length)
    [Buffer]::BlockCopy($data, 0, $payload, $header.Length, $data.Length)
    $sha = [Security.Cryptography.SHA1]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($payload))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Get-Fingerprint([string[]] $Lines) {
    [Array]::Sort($Lines, [StringComparer]::Ordinal)
    $payload = [Text.Encoding]::UTF8.GetBytes(($Lines -join [char]10) + [char]10)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($payload))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Assert-SafePath([string] $Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path.Contains('\') -or $Path.StartsWith('/') -or $Path.Contains(':') -or $Path -match '[\x00-\x1f]') {
        Fail "Unsafe or non-canonical package path: $Path" 8
    }
    foreach ($segment in $Path.Split('/')) {
        if ([string]::IsNullOrWhiteSpace($segment) -or $segment -eq '.' -or $segment -eq '..') {
            Fail "Unsafe path segment: $Path" 8
        }
    }
}
try {
    $root = [IO.Path]::GetFullPath($GameRoot).TrimEnd('\')
    if (-not (Test-Path -LiteralPath (Join-Path $root 'godot\project.godot') -PathType Leaf)) { Fail 'Godot project.godot is missing.' 2 }
    if (Test-Path -LiteralPath (Join-Path $root '.git')) { Fail 'Offline package must not masquerade as a Git checkout.' 3 }
    if ([string]::IsNullOrWhiteSpace($ProfileRoot)) { $ProfileRoot = Join-Path $env:TEMP 'TMB-OfflinePackage-Logs' }
    $profile = [IO.Path]::GetFullPath($ProfileRoot).TrimEnd('\')
    if ($profile.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or $profile.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Fail 'Verification logs must be outside the immutable package.' 4
    }
    $manifestPath = Join-Path $root 'tri03_offline_package_manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { Fail 'Offline package manifest is missing.' 5 }
    try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json }
    catch { Fail "Offline package manifest JSON is invalid: $($_.Exception.Message)" 6 }
    if ($manifest.schema_version -ne 1 -or $manifest.package_kind -ne 'tmb_verified_offline') { Fail 'Unsupported manifest schema or kind.' 7 }
    foreach ($field in @('source_head', 'base_sha', 'upstream_pr_source')) {
        if ([string]$manifest.$field -notmatch '^[0-9a-f]{40}$') { Fail "Invalid $field in package manifest." 7 }
    }
    if ($manifest.source_branch -ne 'integration/pve-p0-playable-ui-20261103' -or @($manifest.files).Count -lt 10) {
        Fail 'Package branch or file pin count is invalid.' 7
    }

    $expected = @{}
    foreach ($entry in $manifest.files) {
        $path = [string]$entry.path
        Assert-SafePath $path
        if ($expected.ContainsKey($path)) { Fail "Duplicate package path: $path" 8 }
        if ([string]$entry.sha256 -notmatch '^[0-9a-f]{64}$' -or [long]$entry.length -lt 0) { Fail "Malformed SHA/length: $path" 8 }
        $expected[$path] = $entry
    }
    $actual = @{}
    foreach ($item in Get-ChildItem -LiteralPath $root -Force -Recurse -ErrorAction Stop) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { Fail "Reparse point in package: $($item.FullName)" 9 }
        if ($item.PSIsContainer) { continue }
        $path = $item.FullName.Substring($root.Length).TrimStart('\').Replace('\', '/')
        if ($path -eq 'tri03_offline_package_manifest.json' -or $path.StartsWith('godot/.godot/', [StringComparison]::OrdinalIgnoreCase)) { continue }
        if (-not $expected.ContainsKey($path)) { Fail "Unpinned extra file: $path" 10 }
        $actual[$path] = $item.FullName
    }
    foreach ($path in $expected.Keys) {
        if (-not $actual.ContainsKey($path)) { Fail "Pinned file is missing: $path" 11 }
        $item = Get-Item -LiteralPath $actual[$path]
        if ([long]$item.Length -ne [long]$expected[$path].length -or (Get-Sha256Hex $actual[$path]) -ne [string]$expected[$path].sha256) {
            Fail "File length or SHA-256 mismatch: $path" 12
        }
    }
    if ([int]$manifest.file_count -ne $expected.Count) { Fail 'Manifest file_count mismatch.' 12 }
    $packageLines = @($manifest.files | ForEach-Object { '{0}={1}' -f $_.path, $_.sha256 })
    $packageFingerprint = Get-Fingerprint $packageLines
    if ($packageFingerprint -ne [string]$manifest.package_fingerprint) { Fail 'Package fingerprint mismatch.' 13 }

    $runtimePath = Join-Path $root 'tools\windows\run\tri03_runtime_source_manifest.json'
    if (-not (Test-Path -LiteralPath $runtimePath -PathType Leaf)) { Fail 'Runtime source manifest is missing.' 14 }
    try { $runtime = Get-Content -LiteralPath $runtimePath -Raw | ConvertFrom-Json }
    catch { Fail 'Runtime source manifest JSON is invalid.' 14 }
    if ($runtime.schema_version -ne 2 -or $runtime.branch -ne $manifest.source_branch -or
        $runtime.base_sha -ne $manifest.base_sha -or $runtime.upstream_pr_sha -ne $manifest.upstream_pr_source) {
        Fail 'Runtime source provenance differs from the package.' 14
    }
    $runtimeLines = @($runtime.files | ForEach-Object { '{0}={1}' -f $_.path, ([string]$_.git_blob_sha).ToLowerInvariant() })
    $runtimeFingerprint = Get-Fingerprint $runtimeLines
    if ($runtimeFingerprint -ne [string]$runtime.source_fingerprint -or $runtimeFingerprint -ne [string]$manifest.runtime_source_fingerprint) {
        Fail 'Runtime source pin fingerprint mismatch.' 15
    }
    foreach ($pin in $runtime.files) {
        $path = [string]$pin.path
        Assert-SafePath $path
        if (-not $actual.ContainsKey($path)) { Fail "Pinned runtime source is missing: $path" 16 }
        if ((Get-GitBlobSha1 $actual[$path]) -ne ([string]$pin.git_blob_sha).ToLowerInvariant()) { Fail "Runtime Git blob mismatch: $path" 16 }
    }

    $femaleRoot = Join-Path $root 'godot\assets\p3\character_creator\parts\female_normal_v1'
    $femaleCount = if (Test-Path -LiteralPath $femaleRoot) { @(Get-ChildItem -LiteralPath $femaleRoot -Recurse -File -Filter '*.png').Count } else { 0 }
    if ($femaleCount -ne 42) { Fail "Female Stage A contains $femaleCount PNGs; expected 42." 17 }
    $logRoot = Join-Path $profile 'Logs'
    New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
    $report = "TRI03_OFFLINE_VERIFY_PASS source_method=verified_offline_package source_head=$($manifest.source_head) source_branch=$($manifest.source_branch) source_fingerprint=$packageFingerprint runtime_source_fingerprint=$runtimeFingerprint files=$($expected.Count) female_stage_a_pngs=$femaleCount"
    $reportLines = @(
        "source_fingerprint=$packageFingerprint",
        "checkout_head=offline:$($manifest.source_head)",
        "upstream_pr_source=$($manifest.upstream_pr_source)",
        'source_method=verified_offline_package',
        "package_fingerprint=$packageFingerprint",
        "runtime_source_fingerprint=$runtimeFingerprint",
        $report
    )
    [IO.File]::WriteAllText((Join-Path $logRoot 'source_verify.txt'), (($reportLines -join [Environment]::NewLine) + [Environment]::NewLine), [Text.UTF8Encoding]::new($false))
    Write-Output $report
    exit 0
} catch {
    Fail "Unexpected verifier error: $($_.Exception.Message)" 1
}