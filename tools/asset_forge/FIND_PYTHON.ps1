# Discover Python 3.10+ WITHOUT installing software, changing PATH or scanning entire disks.
# Source: registry, conventional local installations, Conda, uv-managed interpreters,
# and a deliberately bounded set of top-level directories across mounted drives.
param([switch]$Report)
$ErrorActionPreference = 'SilentlyContinue'
$tested = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$candidates = New-Object 'System.Collections.Generic.List[string]'

function Add-Path([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return }
  $p = [Environment]::ExpandEnvironmentVariables($p.Trim().Trim('"'))
  if (Test-Path -LiteralPath $p -PathType Container) { $p = Join-Path $p 'python.exe' }
  if (-not $p.EndsWith('.exe', [StringComparison]::OrdinalIgnoreCase)) { return }
  if ($p -like '*\Microsoft\WindowsApps\*') { return }
  if (-not $tested.Add($p)) { return }
  if (Test-Path -LiteralPath $p -PathType Leaf) { [void]$candidates.Add($p) }
}
function Add-DirMatches([string]$base, [string]$pattern, [string]$suffix) {
  if (-not (Test-Path -LiteralPath $base -PathType Container)) { return }
  foreach($d in (Get-ChildItem -LiteralPath $base -Directory -Filter $pattern -ErrorAction SilentlyContinue)) {
    Add-Path (Join-Path $d.FullName $suffix)
  }
}
function Add-RegistryCandidates([string]$hive) {
  if (-not (Test-Path -LiteralPath $hive)) { return }
  foreach($vendor in (Get-ChildItem -LiteralPath $hive -ErrorAction SilentlyContinue)) {
    foreach($version in (Get-ChildItem -LiteralPath $vendor.PSPath -ErrorAction SilentlyContinue)) {
      $key = Join-Path $version.PSPath 'InstallPath'
      if (Test-Path -LiteralPath $key) {
        $reg = Get-Item -LiteralPath $key -ErrorAction SilentlyContinue
        if ($reg) {
          Add-Path ([string]$reg.GetValue('ExecutablePath'))
          Add-Path ([string]$reg.GetValue(''))
        }
      }
    }
  }
}
function Test-Interpreter([string]$file) {
  try {
    & $file -I -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 2)' *> $null
    return ($LASTEXITCODE -eq 0)
  } catch { return $false }
}

# Official Python PEP 514 registry keys + common distribution registries.
foreach($regbase in @('HKCU:\Software\Python','HKLM:\SOFTWARE\Python','HKLM:\SOFTWARE\WOW6432Node\Python')) {
  Add-RegistryCandidates $regbase
}

foreach($e in @($env:VIRTUAL_ENV, $env:CONDA_PREFIX)) {
  if ($e) { Add-Path (Join-Path $e 'Scripts\python.exe'); Add-Path (Join-Path $e 'python.exe') }
}

# Python installs at user and system locations even if PATH is incorrect.
foreach ($base in @(
    "$env:LOCALAPPDATA\Programs\Python", "$env:LOCALAPPDATA\Programs",
    "$env:ProgramFiles", "${env:ProgramFiles(x86)}", $env:ProgramData,
    $env:USERPROFILE, "$env:USERPROFILE\AppData\Local", "$env:USERPROFILE\AppData\Roaming")) {
  if (-not $base) { continue }
  Add-DirMatches $base 'Python*' 'python.exe'
  Add-DirMatches $base '*conda*' 'python.exe'
  Add-DirMatches $base 'WinPython*' 'python.exe'
  Add-DirMatches $base 'WPy*' 'python.exe'
}
foreach($exact in @(
   "$env:USERPROFILE\miniconda3\python.exe", "$env:USERPROFILE\anaconda3\python.exe",
   "$env:LOCALAPPDATA\miniconda3\python.exe", "$env:ProgramData\miniconda3\python.exe",
   "$env:ProgramData\Anaconda3\python.exe", "$env:USERPROFILE\.venv\Scripts\python.exe",
   "$env:USERPROFILE\venv\Scripts\python.exe")) { Add-Path $exact }

# uv managed runtime; bounded two-level search, NOT entire profile recursion.
foreach($base in @("$env:APPDATA\uv\python", "$env:LOCALAPPDATA\uv\python", "$env:USERPROFILE\.local\share\uv\python")) {
  if (-not (Test-Path -LiteralPath $base -PathType Container)) { continue }
  foreach($d in (Get-ChildItem -LiteralPath $base -Directory -ErrorAction SilentlyContinue)) {
    Add-Path (Join-Path $d.FullName 'python.exe')
    Add-Path (Join-Path $d.FullName 'install\python.exe')
  }
}

# User may have installed Python to D: or E:. Check likely ROOT/tool subpaths only.
foreach($drive in (Get-PSDrive -PSProvider FileSystem)) {
  if (-not $drive.Root -or $drive.Root.StartsWith('\\')) { continue }
  $root = $drive.Root
  foreach ($sub in @('','Tools','Apps','Programs','Dev','Software')) {
    $folder = if ($sub) { Join-Path $root $sub } else { $root }
    Add-DirMatches $folder 'Python3*' 'python.exe'
    Add-DirMatches $folder 'Python*' 'python.exe'
    Add-DirMatches $folder '*conda*' 'python.exe'
    Add-DirMatches $folder 'WinPython*' 'python.exe'
  }
}

foreach ($file in $candidates) {
  $ok = Test-Interpreter $file
  if ($Report) {
    $tag=if ($ok) {'PASS'} else {'NOT_RUNNABLE_OR_OLD'}
    Write-Output "[$tag] $file"
  } elseif ($ok) {
    Write-Output $file
    exit 0
  }
}
if ($Report) {
  if ($candidates.Count -eq 0) { Write-Output '[INFO] No python.exe found in registry, standard directories, or common install paths on mounted drives.' }
  Write-Output '[INFO] Full-disk scan intentionally disabled to keep diagnosis fast.'
  Write-Output '[INFO] If Python was installed inside a project folder, use CHON_PYTHON.cmd to select its exact python.exe.'
}
exit 1
