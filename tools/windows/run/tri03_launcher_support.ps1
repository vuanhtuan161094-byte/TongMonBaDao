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
    param([Parameter(Mandatory = $true)][string] $GodotPath,[Parameter()][object[]] $ProcessSnapshot)
    $processName = [IO.Path]::GetFileNameWithoutExtension($GodotPath)
    if ($PSBoundParameters.ContainsKey('ProcessSnapshot')) { $candidates = @($ProcessSnapshot) }
    else { $candidates = @(Get-Process -Name $processName -ErrorAction SilentlyContinue) }
    return @($candidates | Where-Object { $_.ProcessName -eq $processName } | Sort-Object Id)
}
