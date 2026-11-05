[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$GameRoot,
    [Parameter(Mandatory=$true)][string]$PackagePath,
    [string]$ProfileRoot='E:\TongMonBaDaoWorkspace\03_QA_Logs\TRI03_OFFLINE_PACKAGE_BUILD'
)
$ErrorActionPreference='Stop'
function Stop-Build([string]$Message,[int]$Code=1){[Console]::Error.WriteLine("TRI03_OFFLINE_BUILD_FAIL: $Message");exit $Code}
function Sha256([string]$Path){$s=[IO.File]::OpenRead($Path);$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($s))).Replace('-','').ToLowerInvariant()}finally{$a.Dispose();$s.Dispose()}}
function Fingerprint([string[]]$Lines){[Array]::Sort($Lines,[StringComparer]::Ordinal);$d=[Text.Encoding]::UTF8.GetBytes(($Lines-join[Environment]::NewLine)+[Environment]::NewLine);$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($d))).Replace('-','').ToLowerInvariant()}finally{$a.Dispose()}}
function QuoteArg([string]$Value){return '"' + $Value.Replace('"','\"') + '"'}
try{
 $root=[IO.Path]::GetFullPath($GameRoot).TrimEnd('\')
 $dest=[IO.Path]::GetFullPath($PackagePath).TrimEnd('\')
 if($dest.Equals($root,[StringComparison]::OrdinalIgnoreCase)-or$dest.StartsWith($root+'\',[StringComparison]::OrdinalIgnoreCase)-or$root.StartsWith($dest+'\',[StringComparison]::OrdinalIgnoreCase)){Stop-Build 'Package path must be separate from the Git source checkout.' 2}
 if(Test-Path -LiteralPath $dest){Stop-Build "Destination already exists; no overwrite attempted: $dest" 3}
 $parent=Split-Path -Parent $dest
 New-Item -ItemType Directory -Force -Path $parent | Out-Null
 $git='C:\Program Files\Git\cmd\git.exe'
 if(-not(Test-Path -LiteralPath $git -PathType Leaf)){Stop-Build 'Git CLI is required only for the verified package build step.' 4}
 $branch=(& $git -c "safe.directory=$($root.Replace('\','/'))" -C $root branch --show-current 2>&1 | Out-String).Trim()
 if($LASTEXITCODE-ne0-or$branch-ne'integration/pve-p0-playable-ui-20261103'){Stop-Build "Expected genuine PR #72 branch; found '$branch'." 5}
 $head=(& $git -c "safe.directory=$($root.Replace('\','/'))" -C $root rev-parse HEAD 2>&1 | Out-String).Trim()
 if($LASTEXITCODE-ne0-or$head-notmatch'^[0-9a-f]{40}$'){Stop-Build 'Could not establish source checkout HEAD.' 5}
 $entries=@(& $git -c "safe.directory=$($root.Replace('\','/'))" -C $root ls-tree -r HEAD 2>&1)
 if($LASTEXITCODE-ne0){Stop-Build 'Could not enumerate Git source tree.' 5}
 if(@($entries|Where-Object{$_-match'^(120000|160000) '}).Count-gt0){Stop-Build 'Symlinks or submodules are not supported in offline package exports.' 6}
  $sourceFemale=Join-Path $root 'godot\assets\p3\character_creator\parts\female_normal_v1'
 $sourcePngCount=if(Test-Path -LiteralPath $sourceFemale){@(Get-ChildItem -LiteralPath $sourceFemale -Recurse -File -Filter '*.png').Count}else{0}
 if($sourcePngCount -eq 0){
  $sourceInstaller=Join-Path $root 'tools\windows\bootstrap\Install-P3-2-Female-StageA.cmd'
  if(-not(Test-Path -LiteralPath $sourceInstaller -PathType Leaf)){Stop-Build 'Stage A installer is missing from source checkout.' 7}
  $oldInstall=$env:STAGE_A_INSTALL_ONLY;$oldPreview=$env:P3_AUTO_PREVIEW
  try{$env:STAGE_A_INSTALL_ONLY='1';$env:P3_AUTO_PREVIEW='1';Push-Location $root;& $sourceInstaller;$sourceInstallCode=$LASTEXITCODE}
  finally{Pop-Location;$env:STAGE_A_INSTALL_ONLY=$oldInstall;$env:P3_AUTO_PREVIEW=$oldPreview}
  if($sourceInstallCode -ne 0){Stop-Build "Stage A restore failed with exit $sourceInstallCode." 7}
 }elseif($sourcePngCount -ne 42){Stop-Build "Source checkout has $sourcePngCount Stage A PNGs; refusing to overwrite a partial set." 7}
$verifier=Join-Path $root 'tools\windows\run\Verify-TRI03Source.ps1'
 $offlineVerifier=Join-Path $root 'tools\windows\run\Verify-TRI03OfflinePackage.ps1'
 $manifestPath=Join-Path $root 'tools\windows\run\tri03_runtime_source_manifest.json'
 foreach($p in @($verifier,$offlineVerifier,$manifestPath, (Join-Path $root 'CHOI-GAME.cmd'))){if(-not(Test-Path -LiteralPath $p -PathType Leaf)){Stop-Build "Required source file missing: $p" 7}}
 $runtime=Get-Content -LiteralPath $manifestPath -Raw|ConvertFrom-Json
 if($runtime.files.path -notcontains 'tools/windows/run/Build-TRI03OfflinePackage.ps1'){Stop-Build 'Builder itself is not pinned by the runtime source manifest.' 7}
 $pwsh=Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
 $verifyArgs='-NoProfile -ExecutionPolicy Bypass -File '+(QuoteArg $verifier)+' -GameRoot '+(QuoteArg $root)+' -ProfileRoot '+(QuoteArg $ProfileRoot)
 $vp=Start-Process -FilePath $pwsh -ArgumentList $verifyArgs -Wait -PassThru -WindowStyle Hidden
 if($vp.ExitCode-ne0){Stop-Build "Git source verifier failed with exit $($vp.ExitCode); no offline package created." 8}
 $verifyLog=Join-Path $ProfileRoot 'Logs\source_verify.txt'
 if(-not(Test-Path -LiteralPath $verifyLog)){Stop-Build 'Git source verifier did not write its evidence.' 8}
 $verifyText=Get-Content -LiteralPath $verifyLog -Raw
 $sourceFingerprint=([regex]::Match($verifyText,'(?m)^source_fingerprint=([0-9a-f]{64})$')).Groups[1].Value
 $verifiedHead=([regex]::Match($verifyText,'(?m)^checkout_head=([0-9a-f]{40})$')).Groups[1].Value
 $upstream=([regex]::Match($verifyText,'(?m)^upstream_pr_source=([0-9a-f]{40})$')).Groups[1].Value
 if($verifiedHead-ne$head-or-not$sourceFingerprint-or-not$upstream){Stop-Build 'Git source report does not identify the expected HEAD/pins.' 8}
 $stage=Join-Path $parent ('.tmb-package-stage-'+[Guid]::NewGuid().ToString('N'))
 New-Item -ItemType Directory -Path $stage|Out-Null
 $archive=Join-Path $parent ('.tmb-package-'+[Guid]::NewGuid().ToString('N')+'.tar')
 & $git -c "safe.directory=$($root.Replace('\','/'))" -C $root archive --format=tar "--output=$archive" HEAD
 if($LASTEXITCODE-ne0){Stop-Build "git archive failed with exit $LASTEXITCODE; staging left at $stage." 9}
 $tar=Get-Command tar.exe -ErrorAction SilentlyContinue
 if(-not$tar){Stop-Build 'Windows tar.exe is required to unpack the verified Git archive.' 9}
 & $tar.Source -xf $archive -C $stage
 if($LASTEXITCODE-ne0){Stop-Build "Archive extraction failed with exit $LASTEXITCODE; staging left at $stage." 9}
 Remove-Item -LiteralPath $archive -Force
 $installer=Join-Path $stage 'tools\windows\bootstrap\Install-P3-2-Female-StageA.cmd'
 if(-not(Test-Path -LiteralPath $installer -PathType Leaf)){Stop-Build 'Female Stage A installer is not in the source archive.' 10}
 $oldInstall=$env:STAGE_A_INSTALL_ONLY;$oldPreview=$env:P3_AUTO_PREVIEW
 try{$env:STAGE_A_INSTALL_ONLY='1';$env:P3_AUTO_PREVIEW='1';Push-Location $stage; & $installer; $installCode=$LASTEXITCODE}
 finally{Pop-Location;$env:STAGE_A_INSTALL_ONLY=$oldInstall;$env:P3_AUTO_PREVIEW=$oldPreview}
 if($installCode-ne0){Stop-Build "Female Stage A installer failed with exit $installCode; staging left at $stage." 10}
 $female=Join-Path $stage 'godot\assets\p3\character_creator\parts\female_normal_v1'
 $femaleCount=if(Test-Path -LiteralPath $female){@(Get-ChildItem -LiteralPath $female -Recurse -File -Filter '*.png').Count}else{0}
 if($femaleCount-ne42){Stop-Build "Stage A installed $femaleCount PNGs; expected 42." 10}
  $godot='E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe'
 if(-not(Test-Path -LiteralPath $godot -PathType Leaf)){Stop-Build 'Official Godot 4.7.2 is missing; cannot pre-import package.' 11}
 $godotVersion=(& $godot --version 2>&1|Out-String).Trim()
 if($LASTEXITCODE-ne0-or$godotVersion-ne'4.7.2.stable.official.ed1daf0bf'){Stop-Build "Unexpected Godot build: $godotVersion" 11}
 $importLog=Join-Path $ProfileRoot 'Logs\offline_package_import.log'
 New-Item -ItemType Directory -Force -Path (Split-Path -Parent $importLog)|Out-Null
 & $godot --headless --editor --path $stage --import --quit --verbose --log-file $importLog
 $importCode=$LASTEXITCODE
 if($importCode-ne0){Stop-Build "Godot import failed with exit $importCode; log=$importLog; staging left at $stage." 11}
 if(Test-Path -LiteralPath $importLog){$bad=Select-String -LiteralPath $importLog -Pattern 'SCRIPT ERROR:|Parse Error:'; if($bad){Stop-Build "Godot import emitted a script/parse error; log=$importLog." 11}}
$files=@()
 foreach($item in Get-ChildItem -LiteralPath $stage -Force -Recurse -ErrorAction Stop){
  if(($item.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){Stop-Build "Reparse point found in export: $($item.FullName)" 11}
  if($item.PSIsContainer){continue}
  $rel=$item.FullName.Substring($stage.Length).TrimStart('\').Replace('\','/')
  if($rel-eq'tri03_offline_package_manifest.json'-or$rel.StartsWith('godot/.godot/',[StringComparison]::OrdinalIgnoreCase)){continue}
  $files+= [pscustomobject]@{path=$rel;sha256=(Sha256 $item.FullName);length=[long]$item.Length}
 }
 $lines=@($files|ForEach-Object{'{0}={1}'-f$_.path,$_.sha256})
 $packageFingerprint=Fingerprint $lines
 $packageManifest=[ordered]@{
  schema_version=1
  package_kind='tmb_verified_offline'
  generated_utc=[DateTime]::UtcNow.ToString('o')
  source_branch=$branch
  source_head=$head
  base_sha=[string]$runtime.base_sha
  upstream_pr_source=$upstream
  runtime_source_fingerprint=$sourceFingerprint
  file_count=$files.Count
  package_fingerprint=$packageFingerprint
  files=$files
 }
 $json=$packageManifest|ConvertTo-Json -Depth 8
 [IO.File]::WriteAllText((Join-Path $stage 'tri03_offline_package_manifest.json'),$json,[Text.UTF8Encoding]::new($false))
 $offlineVerifyArgs='-NoProfile -ExecutionPolicy Bypass -File '+(QuoteArg $offlineVerifier)+' -GameRoot '+(QuoteArg $stage)+' -ProfileRoot '+(QuoteArg $ProfileRoot)
 $op=Start-Process -FilePath $pwsh -ArgumentList $offlineVerifyArgs -Wait -PassThru -WindowStyle Hidden
 if($op.ExitCode-ne0){Stop-Build "Offline package verification failed with exit $($op.ExitCode); staging left at $stage." 12}
 Move-Item -LiteralPath $stage -Destination $dest
 Write-Output "TRI03_OFFLINE_BUILD_PASS source_head=$head package_fingerprint=$packageFingerprint files=$($files.Count) female_stage_a_pngs=$femaleCount path=$dest"
 Write-Output "Offline package SHA-256 manifest: $dest\tri03_offline_package_manifest.json"
 exit 0
}catch{Stop-Build "Unexpected package builder error: $($_.Exception.Message)" 1}