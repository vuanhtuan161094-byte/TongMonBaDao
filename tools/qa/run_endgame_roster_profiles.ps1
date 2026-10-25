param(
    [ValidateSet(130,200,500)][int[]]$Profiles = @(200,500),
    [switch]$Regenerate,
    [string]$GodotPath = 'E:\Godot_v4.7.2-stable_win64_console.exe'
)
# Sequential official Godot 4.7.2 roster benchmark. Never overwrites mutable
# player/owner saves. Unless Regenerate is explicitly set, existing 200/500
# QA files are loaded read-only. Default 130 QA is excluded from regeneration.
$ErrorActionPreference = 'Stop'

function Get-AvailablePhysicalMemoryGB {
    try {
        $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        return [double]$osInfo.FreePhysicalMemory / 1048576.0
    } catch {
        if (-not ('TmbAvailableMemoryStatus' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class TmbAvailableMemoryStatus {
    [StructLayout(LayoutKind.Sequential)]
    public class MEMORYSTATUSEX {
        public uint dwLength;
        public uint dwMemoryLoad;
        public ulong ullTotalPhys;
        public ulong ullAvailPhys;
        public ulong ullTotalPageFile;
        public ulong ullAvailPageFile;
        public ulong ullTotalVirtual;
        public ulong ullAvailVirtual;
        public ulong ullAvailExtendedVirtual;
        public MEMORYSTATUSEX() { dwLength = (uint)Marshal.SizeOf(typeof(MEMORYSTATUSEX)); }
    }
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GlobalMemoryStatusEx([In, Out] MEMORYSTATUSEX status);
}
'@
        }
        $status = [TmbAvailableMemoryStatus+MEMORYSTATUSEX]::new()
        if (-not [TmbAvailableMemoryStatus]::GlobalMemoryStatusEx($status)) {
            throw 'Windows GlobalMemoryStatusEx failed while reading available RAM.'
        }
        return [double]$status.ullAvailPhys / 1GB
    }
}

function Assert-NoGodotProcess {
    $active = @(Get-Process | Where-Object { $_.ProcessName -match '^Godot' })
    if ($active.Count -gt 0) {
        throw ('Godot single-process gate: another process is active: ' + (($active | ForEach-Object { '{0} ({1})' -f $_.ProcessName,$_.Id }) -join ', '))
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$project = Join-Path $repoRoot 'godot'
$runId = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$logRoot = Join-Path $repoRoot ("outputs\endgame_qa_20261026\logs\roster_profiles_" + $runId)
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Official Godot 4.7.2 not found at $GodotPath"
}
$sourceHash = git -C $repoRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot resolve exact source SHA' }
$rows = [System.Collections.Generic.List[object]]::new()
foreach ($population in $Profiles) {
    $profileName = if ($population -eq 130) { 'endgame_qa_save.json' } else { "endgame_qa_save_$population.json" }
    $savePath = Join-Path $project ("qa\" + $profileName)
    $userdataRoot = Join-Path $logRoot ("userdata_" + $population)
    $env:APPDATA = Join-Path $userdataRoot 'Roaming'
    $env:LOCALAPPDATA = Join-Path $userdataRoot 'Local'
    New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA | Out-Null

    # Low-memory fail-closed gate; prefer CIM, then use the Windows API when
    # restricted desktop sandboxes deny WMI access.
    $freeGb = [math]::Round((Get-AvailablePhysicalMemoryGB),2)
    $minFreeGb = if ($population -ge 500) { 2.50 } else { 1.25 }
    if ($freeGb -lt $minFreeGb) {
        Write-Warning "Skipping roster ${population}: available RAM $freeGb GB is below $minFreeGb GB."
        $rows.Add([pscustomobject]@{Roster=$population;Step='RAM_GATE';Status='BLOCKED';ExitCode=-1;
            AvailableGB=$freeGb;SaveBytes=0;SHA256='';CodeSHA=$sourceHash;Log='' })
        continue
    }

    if ($Regenerate -or -not (Test-Path -LiteralPath $savePath -PathType Leaf)) {
        if ($population -eq 130 -and $Regenerate) {
            Write-Warning 'Regenerating base 130 QA fixture only because -Regenerate was passed explicitly.'
        }
        $log = Join-Path $logRoot ("generate_$population.log")
        Assert-NoGodotProcess
        & $GodotPath --headless --path $project --quit-after 3600 --script res://tools/qa/endgame_fixture_generator.gd -- "--tmb-roster=$population" *>&1 |
            Out-File -LiteralPath $log -Encoding utf8
        $exitCode = $LASTEXITCODE
        $pass = $exitCode -eq 0 -and (Test-Path -LiteralPath $savePath -PathType Leaf) -and
            (Get-Content -LiteralPath $log -Raw).Contains('TMB_ENDGAME_FIXTURE ')
        $rows.Add([pscustomobject]@{Roster=$population;Step='GENERATE';Status= $(if($pass){'PASS'}else{'FAIL'});
            ExitCode=$exitCode;AvailableGB=$freeGb;SaveBytes=0;SHA256='';CodeSHA=$sourceHash;Log=$log})
        if (-not $pass) {
            Write-Warning "Fixture generator failed for $population, log=$log"
            continue
        }
    }

    $testLog = Join-Path $logRoot ("contract_$population.log")
    Assert-NoGodotProcess
    & $GodotPath --headless --path $project --quit-after 360 --script res://tests/presentation/endgame_roster_profiles_contract_test.gd -- "--tmb-roster=$population" *>&1 |
        Out-File -LiteralPath $testLog -Encoding utf8
    $exitCode = $LASTEXITCODE
    $passed = $exitCode -eq 0 -and (Get-Content -LiteralPath $testLog -Raw).Contains('TMB_ENDGAME_ROSTER_PROFILE PASS ')
    $size = if (Test-Path -LiteralPath $savePath -PathType Leaf) {(Get-Item -LiteralPath $savePath).Length} else {0}
    $sha = if ($size -gt 0) {(Get-FileHash -LiteralPath $savePath -Algorithm SHA256).Hash} else {''}
    $rows.Add([pscustomobject]@{Roster=$population;Step='CHECK';Status= $(if($passed){'PASS'}else{'FAIL'});
        ExitCode=$exitCode;AvailableGB=$freeGb;SaveBytes=$size;SHA256=$sha;CodeSHA=$sourceHash;Log=$testLog})
    Write-Output ("roster={0} result={1} size={2} SHA={3}" -f $population,$passed,$size,$sha)
}
$csv = Join-Path $logRoot 'roster_profile_results.csv'
$rows | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
$failed = @($rows | Where-Object Status -eq 'FAIL').Count
$blocked = @($rows | Where-Object Status -eq 'BLOCKED').Count
Write-Output ("RESULTS file={0} failed={1} blocked={2} exact_sha={3}" -f $csv,$failed,$blocked,$sourceHash)
if ($failed -gt 0) { exit 1 }
if ($blocked -gt 0) { exit 2 }
