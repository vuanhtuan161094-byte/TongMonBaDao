# QA of the actual SHA-256 function embedded in OPEN_POISON_LAB.ps1.
# Does not launch Godot, alter a checkout, or weaken the manifest comparison.
$ErrorActionPreference = 'Stop'
$launcherPath = Join-Path $PSScriptRoot '..\run\OPEN_POISON_LAB.ps1'
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($launcherPath, [ref]$tokens, [ref]$parseErrors)
if (@($parseErrors).Count -ne 0) { throw "POISON_HASH_QA_FAIL launcher syntax error" }
$functionAst = $ast.Find({
    param($node)
    $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-PoisonLabFileSha256'
}, $true)
if ($null -eq $functionAst) { throw 'POISON_HASH_QA_FAIL SHA-256 implementation missing' }
. ([scriptblock]::Create($functionAst.Extent.Text))
$source = [IO.File]::ReadAllText([IO.Path]::GetFullPath($launcherPath))
if ($source.Contains('Get-FileHash -LiteralPath')) { throw 'POISON_HASH_QA_FAIL obsolete cmdlet still required' }
if (-not $source.Contains('if ($actualHash -ne $expectedHash)')) { throw 'POISON_HASH_QA_FAIL mismatch gate removed' }
$checks = 2
$root = Join-Path ([IO.Path]::GetTempPath()) ('TMB-Poison-Sha-' + [Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($root)
try {
    $file = Join-Path $root 'poison[asset].png'
    [IO.File]::WriteAllBytes($file, [Text.Encoding]::ASCII.GetBytes('abc'))
    if ((Get-PoisonLabFileSha256 $file) -cne 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad') {
        throw 'POISON_HASH_QA_FAIL SHA256(abc) != known NIST vector'
    }
    $checks++
    [IO.File]::WriteAllBytes($file, [byte[]]@())
    if ((Get-PoisonLabFileSha256 $file) -cne 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855') {
        throw 'POISON_HASH_QA_FAIL SHA256(empty) != known vector'
    }
    $checks++
    [IO.File]::WriteAllBytes($file, [Text.Encoding]::ASCII.GetBytes('abd'))
    if ((Get-PoisonLabFileSha256 $file) -ceq 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad') {
        throw 'POISON_HASH_QA_FAIL modified asset accepted as original'
    }
    $checks++
    $failedClosed = $false
    try { [void](Get-PoisonLabFileSha256 (Join-Path $root 'missing.png')) } catch { $failedClosed = $true }
    if (-not $failedClosed) { throw 'POISON_HASH_QA_FAIL missing file did not fail closed' }
    $checks++
    Write-Output ('POISON_HASH_COMPAT_TEST_PASS checks={0} native_sha256=1' -f $checks)
} finally {
    if ([IO.Directory]::Exists($root)) { [IO.Directory]::Delete($root, $true) }
}
