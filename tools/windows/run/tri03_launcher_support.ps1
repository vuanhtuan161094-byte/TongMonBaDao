function Get-TRI03ProjectMutexName {
    param([Parameter(Mandatory = $true)][string] $ProjectPath)
    $normalized = [IO.Path]::GetFullPath($ProjectPath).TrimEnd([char[]]@('\', '/')).ToLowerInvariant()
    $bytes = [Text.Encoding]::UTF8.GetBytes($normalized)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $digest = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
    return 'Local\TMB.OneGame.' + $digest.Substring(0, 24)
}
function New-TRI03RunId {
    return ('{0}_{1}' -f [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ'), [Guid]::NewGuid().ToString('N').Substring(0, 8))
}
function Get-TRI03RunLogPaths {
    param([Parameter(Mandatory = $true)][string] $PlayLog,[Parameter(Mandatory = $true)][string] $RunId)
    $fullPath = [IO.Path]::GetFullPath($PlayLog)
    $directory = [IO.Path]::GetDirectoryName($fullPath)
    $stem = [IO.Path]::GetFileNameWithoutExtension($fullPath)
    $runLog = Join-Path $directory ('{0}_{1}.log' -f $stem, $RunId)
    return [pscustomobject]@{ RunId=$RunId; PlayLog=$runLog; Stdout=($runLog + '.stdout.log'); Stderr=($runLog + '.stderr.log') }
}
function Get-TRI03ExistingGodotProcesses {
    param(
        [Parameter(Mandatory = $true)][string] $GodotPath,
        [Parameter(Mandatory = $true)][string] $ProjectPath,
        [Parameter()][int] $CurrentSessionId = [Diagnostics.Process]::GetCurrentProcess().SessionId,
        [Parameter()][object[]] $ProcessSnapshot
    )
    $processName = [IO.Path]::GetFileNameWithoutExtension($GodotPath)
    if ($PSBoundParameters.ContainsKey('ProcessSnapshot')) {
        $candidates = @($ProcessSnapshot)
    } else {
        try {
            # A process basename does not establish project ownership. Query
            # only the matching image and classify it by Windows session and
            # the actual --path argument when the OS exposes command line data.
            $escapedName = ($processName + '.exe').Replace("'", "''")
            $candidates = @(Get-CimInstance -ClassName Win32_Process -Filter ("Name='{0}'" -f $escapedName) -ErrorAction Stop)
        } catch {
            # The project mutex is still authoritative for launches through
            # this launcher. An inaccessible process inventory is diagnostic,
            # not proof that a different user's session owns this project.
            return @([pscustomobject]@{
                Id = -1; ProcessName = $processName; SessionId = -1
                CommandLine = $null; Identity = 'unknown'; Reason = 'process_inventory_unavailable'
                BlocksLaunch = $false
            })
        }
    }

    $normalizedProject = [IO.Path]::GetFullPath($ProjectPath).TrimEnd([char[]]@('\', '/'))
    $results = @()
    foreach ($candidate in ($candidates | Where-Object {
        $_.ProcessName -eq $processName -or $_.Name -eq ($processName + '.exe')
    } | Sort-Object Id)) {
        $id = [int]$candidate.Id
        $sessionId = -1
        $commandLine = $null
        try { $sessionId = [int]$candidate.SessionId } catch {}
        try { $commandLine = [string]$candidate.CommandLine } catch {}
        $hasProjectPath = $false
        $sameProject = $false
        if (-not [string]::IsNullOrWhiteSpace($commandLine)) {
            $pathMatch = [regex]::Match($commandLine,
                '(?i)(?:^|\s)--path(?:=|\s+)(?:"([^"]+)"|([^\s]+))')
            if ($pathMatch.Success) {
                $runningProject = $pathMatch.Groups[1].Value
                if ([string]::IsNullOrWhiteSpace($runningProject)) { $runningProject = $pathMatch.Groups[2].Value }
                try {
                    $runningProject = [IO.Path]::GetFullPath($runningProject).TrimEnd([char[]]@('\', '/'))
                    $hasProjectPath = $true
                    $sameProject = [string]::Equals($normalizedProject, $runningProject, [StringComparison]::OrdinalIgnoreCase)
                } catch {}
            }
        }
        $foreignSession = $sessionId -ge 0 -and $sessionId -ne $CurrentSessionId
        if ($foreignSession -and -not $sameProject) {
            $foreignReason = 'foreign_session_not_project_collision'
            if ([string]::IsNullOrWhiteSpace($commandLine) -or -not $hasProjectPath) {
                $foreignReason = 'foreign_unknown_identity'
            }
            $results += [pscustomobject]@{
                Id = $id; ProcessName = $processName; SessionId = $sessionId
                CommandLine = $commandLine; Identity = 'foreign_session'
                Reason = $foreignReason; BlocksLaunch = $false
            }
            continue
        }
        if (-not $hasProjectPath) {
            $unknownReason = 'same_session_unknown_process_identity'
            if (-not [string]::IsNullOrWhiteSpace($commandLine)) {
                $unknownReason = 'same_session_missing_project_argument'
            }
            if ($foreignSession) { $unknownReason = 'foreign_unknown_identity' }
            $results += [pscustomobject]@{
                Id = $id; ProcessName = $processName; SessionId = $sessionId
                CommandLine = $commandLine; Identity = 'unknown'
                Reason = $unknownReason; BlocksLaunch = -not $foreignSession
            }
            continue
        }
        $results += [pscustomobject]@{
            Id = $id; ProcessName = $processName; SessionId = $sessionId
            CommandLine = $commandLine
            Identity = $(if ($sameProject) { 'same_project' } else { 'different_project' })
            Reason = $(if ($foreignSession) { 'foreign_session_same_project' } elseif ($sameProject) { 'same_session_same_project' } else { 'same_session_different_project' })
            BlocksLaunch = $sameProject
        }
    }
    return $results
}
