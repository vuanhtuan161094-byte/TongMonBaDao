param(
    [string]$Destination = (Join-Path $PSScriptRoot "..\..\skills")
)

$ErrorActionPreference = "Stop"

$Repo = "vl4dt/godot-skills"
$Commit = "1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0"
$Selected = @(
    "godot-architecture",
    "godot-headless-workflow",
    "godot-debugging",
    "godot-code-review",
    "godot-ui",
    "godot-animation",
    "godot-shaders-vfx",
    "godot-project-setup",
    "godot-gdscript-patterns",
    "godot-state-management",
    "godot-inventory-economy",
    "godot-save-systems",
    "godot-performance"
)

$Temp = Join-Path $env:TEMP ("tong-mon-godot-skills-" + [guid]::NewGuid().ToString("N"))
$Zip = "$Temp.zip"
$Extract = "$Temp-extract"

try {
    $Uri = "https://github.com/$Repo/archive/$Commit.zip"
    Write-Host "Downloading pinned Godot skills: $Repo@$Commit"
    Invoke-WebRequest -Uri $Uri -OutFile $Zip
    Expand-Archive -Path $Zip -DestinationPath $Extract -Force

    $Root = Get-ChildItem $Extract -Directory | Select-Object -First 1
    if (-not $Root) { throw "Pinned archive did not contain a root directory." }

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null

    foreach ($Skill in $Selected) {
        $Source = Join-Path $Root.FullName "skills\$Skill"
        if (-not (Test-Path $Source)) { throw "Pinned skill missing: $Skill" }

        $Target = Join-Path $Destination $Skill
        if (Test-Path $Target) { Remove-Item -Recurse -Force $Target }
        Copy-Item -Recurse -Force $Source $Target
        Write-Host "Vendored $Skill"
    }

    Write-Host "Godot skill vendoring complete."
}
finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $Zip
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $Extract
}
