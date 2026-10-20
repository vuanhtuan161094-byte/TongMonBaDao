# Source retrieval only: never executes third-party EXE/DLL, builds, scripts, or installers.
# Usage: powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\GET_JX_TOOL_SOURCE_PINNED.ps1 -Destination 'E:\TongMonBaDao_AssetVault\07_tools_cache\source'
param([Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference = 'Stop'
$repos = @(
  @{ Name='JX1-SourceInit-CXX'; Repo='kiendaotac/SourceInit-JX1'; Sha='b2e251a93f862571221b17cc1e92ceb121fc3069'; Tier='JX1_PLAYER_EQUIPMENT_VISUAL_CODE_REFERENCE_NO_RUNTIME_REUSE' },
  @{ Name='JXQY-all-in-one'; Repo='Upwinded/JXQY-all-in-one'; Sha='6ff516bc1439e2b622a2e0ee4e1433cd98f8ec61'; Tier='PRIMARY_MAP_MAGIC_EDITOR' },
  @{ Name='MapTool'; Repo='mapic91/MapTool'; Sha='512aa56bad69117330d6946435aebe6683b0f6b5'; Tier='MAP_REFERENCE_JXQY_OFFLINE' },
  @{ Name='MpcAsfTool'; Repo='mapic91/MpcAsfTool'; Sha='4b7aa5df0feeac97540ea5f870304d4a61068d42'; Tier='MPC_ASF_REFERENCE' },
  @{ Name='ArtWiz'; Repo='TrdHuy/ArtWiz'; Sha='f4c42f5b13b7de56c6aa90d4727589e462a0001c'; Tier='SPR_PAK_REFERENCE' },
  @{ Name='SPR-Viewer'; Repo='evozi/SPR-Viewer'; Sha='8267e753c2c3073f43f3286f15ad0c8fb4603090'; Tier='SPR_VIEW_REFERENCE' },
  @{ Name='jxtools'; Repo='jxoffline/jxtools'; Sha='47a6198a9215866bdcd0e5f2ea4b730c67a81d5b'; Tier='JX1_TABLE_TOOL_REFERENCE' }
)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git missing; install trusted Git first' }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
foreach ($r in $repos) {
  $dir = Join-Path $Destination $r.Name
  if (Test-Path $dir) {
    Write-Host "EXISTS — skipping (never overwrites): $dir"
    continue
  }
  Write-Host "Retrieving source only: $($r.Repo) @ $($r.Sha)"
  & git -c core.hooksPath=NUL clone --no-checkout --filter=blob:none "https://github.com/$($r.Repo).git" $dir
  if ($LASTEXITCODE -ne 0) { throw "Clone failed: $($r.Repo)" }
  & git -C $dir -c core.hooksPath=NUL checkout --detach $r.Sha
  if ($LASTEXITCODE -ne 0) { throw "Pinned SHA not found: $($r.Sha)" }
  $resolved = (& git -C $dir rev-parse HEAD).Trim()
  if ($resolved -ne $r.Sha) { throw "SHA mismatch: $resolved" }
  Write-Host "PINNED: $($r.Repo) $resolved — $($r.Tier)"
}
Write-Host 'DONE: code source fetched; no third-party tool built or executed. Inspect source/licenses before compilation.'