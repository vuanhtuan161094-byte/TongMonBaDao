param(
    [string]$SourceRoot = $env:TMB_JXQY2_ASSET_ROOT,
    [string]$GodotBin = $env:GODOT_BIN,
    [string]$SandboxRoot = (Join-Path $env:TEMP 'tmb-jxqy2-sandbox')
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$project = Join-Path $repoRoot 'godot'
if ([string]::IsNullOrWhiteSpace($SourceRoot) -or -not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw 'Thiếu thư mục nguồn JXQY2 đã đối chiếu manifest. Truyền -SourceRoot; chương trình không tự tải asset.'
}
if ([string]::IsNullOrWhiteSpace($GodotBin)) { $GodotBin = 'E:\Godot_v4.7.2-stable_win64_console.exe' }
if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) { throw 'Không tìm thấy Godot. Truyền -GodotBin với Godot 4.7.2.' }
$version = (& $GodotBin --headless --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2') { throw ('Yêu cầu Godot 4.7.2; kết quả: ' + $version) }
$env:APPDATA = Join-Path $SandboxRoot 'appdata'
$env:LOCALAPPDATA = Join-Path $SandboxRoot 'localdata'
$env:TMB_JXQY2_ASSET_ROOT = (Resolve-Path -LiteralPath $SourceRoot).Path
New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$classCache = Join-Path $project '.godot\global_script_class_cache.cfg'
$needsImport = -not (Test-Path -LiteralPath $classCache)
if (-not $needsImport) { $needsImport = -not ([IO.File]::ReadAllText($classCache).Contains('Jxqy2DemoProfileV1')) }
if ($needsImport) {
    & $GodotBin --headless --path $project --editor --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot chưa nhập được project JXQY2.' }
}
Write-Host ('JXQY2 DEMO | Godot ' + $version + ' | sandbox: ' + $SandboxRoot)
Write-Host 'Nguồn được kiểm tra lại đủ 44 hash trước khi chơi. Save JXQY2 có tên riêng và được tiếp tục khi đã tồn tại.'
& $GodotBin --path $project --script 'res://src/presentation/demo/jxqy2_playable_demo_v1.gd'
exit $LASTEXITCODE
