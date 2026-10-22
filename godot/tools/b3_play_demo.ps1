param([string]$GodotPath = 'E:\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference = 'Stop'
$b3Project = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot official 4.7.2 not found: $GodotPath" }
$b3Version = & $GodotPath --version
if ($b3Version -notlike '4.7.2.stable.official.*') { throw "Expected Godot official 4.7.2; got $b3Version" }
$b3Data = Join-Path $b3Project '.godot\b3_private_demo'
New-Item -ItemType Directory -Path (Join-Path $b3Data 'appdata') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $b3Data 'localdata') -Force | Out-Null
$env:APPDATA = Join-Path $b3Data 'appdata'
$env:LOCALAPPDATA = Join-Path $b3Data 'localdata'
if (-not (Test-Path -LiteralPath (Join-Path $b3Project '.godot\global_script_class_cache.cfg'))) {
    & $GodotPath --headless --editor --path $b3Project --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot project initialization failed' }
}
& $GodotPath --path $b3Project res://scenes/b3_playable_hunt.tscn
exit $LASTEXITCODE
