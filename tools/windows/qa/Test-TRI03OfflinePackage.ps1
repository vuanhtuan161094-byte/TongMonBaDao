param([string]$VerifierPath=(Join-Path $PSScriptRoot '..\run\Verify-TRI03OfflinePackage.ps1'),[string]$LauncherPath='',[string]$BuilderPath=(Join-Path $PSScriptRoot '..\run\Build-TRI03OfflinePackage.ps1'))
$ErrorActionPreference='Stop'
$root=Join-Path $env:TEMP ('TMB-TRI03-OFFLINE-TEST-'+[Guid]::NewGuid().ToString('N'))
$pkg=Join-Path $root 'package';$profile=Join-Path $root 'profile';$filesRoot=$pkg
function Hex([byte[]]$b){return([BitConverter]::ToString($b)).Replace('-','').ToLowerInvariant()}
function Sha([string]$p){$a=[Security.Cryptography.SHA256]::Create();try{return Hex $a.ComputeHash([IO.File]::ReadAllBytes($p))}finally{$a.Dispose()}}
function BlobRaw([string]$p){$d=[IO.File]::ReadAllBytes($p);$h=[Text.Encoding]::ASCII.GetBytes(('blob {0}'-f$d.Length)+[char]0);$x=New-Object byte[]($h.Length+$d.Length);[Buffer]::BlockCopy($h,0,$x,0,$h.Length);[Buffer]::BlockCopy($d,0,$x,$h.Length,$d.Length);$a=[Security.Cryptography.SHA1]::Create();try{return Hex $a.ComputeHash($x)}finally{$a.Dispose()}}
function Blob([string]$p){$d=[IO.File]::ReadAllBytes($p);if([IO.Path]::GetExtension($p).ToLowerInvariant()-in @('.cmd','.bat','.ps1')){$n=[System.Collections.Generic.List[byte]]::new($d.Length);for($i=0;$i-lt$d.Length;$i++){if($d[$i]-eq13-and$i+1-lt$d.Length-and$d[$i+1]-eq10){$n.Add([byte]10);$i++}else{$n.Add($d[$i])}};$d=$n.ToArray()};$h=[Text.Encoding]::ASCII.GetBytes(('blob {0}'-f$d.Length)+[char]0);$x=New-Object byte[]($h.Length+$d.Length);[Buffer]::BlockCopy($h,0,$x,0,$h.Length);[Buffer]::BlockCopy($d,0,$x,$h.Length,$d.Length);$a=[Security.Cryptography.SHA1]::Create();try{return Hex $a.ComputeHash($x)}finally{$a.Dispose()}}
function Finger([string[]]$l){[Array]::Sort($l,[StringComparer]::Ordinal);$d=[Text.Encoding]::UTF8.GetBytes(($l-join[char]10)+[char]10);$a=[Security.Cryptography.SHA256]::Create();try{return Hex $a.ComputeHash($d)}finally{$a.Dispose()}}
function WritePackageManifest{
 $list=@();foreach($f in Get-ChildItem -LiteralPath $filesRoot -File -Recurse -Force){$p=$f.FullName.Substring($filesRoot.Length).TrimStart('\').Replace('\','/');if($p-eq'tri03_offline_package_manifest.json'-or$p.StartsWith('godot/.godot/',[StringComparison]::OrdinalIgnoreCase)){continue};$list+=[pscustomobject]@{path=$p;sha256=(Sha $f.FullName);length=[long]$f.Length}}
 $fp=Finger @($list|ForEach-Object{'{0}={1}'-f$_.path,$_.sha256});$rm=Get-Content -LiteralPath (Join-Path $filesRoot 'tools\windows\run\tri03_runtime_source_manifest.json') -Raw|ConvertFrom-Json
 $m=[ordered]@{schema_version=1;package_kind='tmb_verified_offline';source_branch='integration/pve-p0-playable-ui-20261103';source_head=('1'*40);base_sha=('2'*40);upstream_pr_source=('3'*40);runtime_source_fingerprint=$rm.source_fingerprint;file_count=$list.Count;package_fingerprint=$fp;files=$list}
 [IO.File]::WriteAllText((Join-Path $filesRoot 'tri03_offline_package_manifest.json'),($m|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
}
function RunVerifier { $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $VerifierPath -GameRoot $pkg -ProfileRoot $profile 2>&1; $script:Last = $LASTEXITCODE; return ($out | Out-String) }
$checks=0
function Assert([bool]$condition,[string]$name){$script:checks++;if(-not$condition){throw "TRI03_OFFLINE_TEST_FAIL: $name"}}
$builderText=Get-Content -LiteralPath $BuilderPath -Raw
Assert ($builderText.Contains("-split '[\r\n]+'")) 'builder parses Windows CRLF verifier logs'
$reportSample="source_fingerprint="+('a'*64)+"`r`ncheckout_head="+('b'*40)+"`r`nupstream_pr_source="+('c'*40)+"`r`n"
$reportValues=@{}
foreach($line in ($reportSample -split '[\r\n]+')){
 $separator=$line.IndexOf('=')
 if($separator -gt 0){$reportValues[$line.Substring(0,$separator)]=$line.Substring($separator+1).Trim()}
}
Assert ($reportValues['source_fingerprint']-eq('a'*64)-and$reportValues['checkout_head']-eq('b'*40)-and$reportValues['upstream_pr_source']-eq('c'*40)) 'CRLF report preserves all pinned identity fields'
$fingerprintFunction=[regex]::Match($builderText,'(?m)^function Fingerprint\([^\r\n]+' )
Assert ($fingerprintFunction.Success) 'builder fingerprint function is present'
Invoke-Expression $fingerprintFunction.Value
$fingerprintLines=@('z=2','a=1')
Assert ((Fingerprint $fingerprintLines)-eq(Finger $fingerprintLines)) 'builder uses verifier LF canonicalization'
Assert ($builderText.Contains('--path $godotProject --import --quit')) 'builder imports the Godot project subdirectory'
Assert ($builderText.Contains("Error: Can''t run project:")) 'builder rejects a no-main-scene import error'
Assert ($builderText.Contains('$env:APPDATA=$importAppData;$env:LOCALAPPDATA=$importLocalAppData')) 'Godot import uses QA-isolated Windows profile paths'
Assert ($builderText.Contains('$env:APPDATA=$oldAppData;$env:LOCALAPPDATA=$oldLocalAppData')) 'Godot import restores inherited Windows profile environment'
Assert ($builderText.Contains('godot_import_profile')) 'Godot import editor data is isolated under the QA profile'
Assert ($builderText.Contains('TRI03_IMPORT_METADATA_SETTLED')) 'builder records when generated Godot sidecars settle'
Assert ($builderText.Contains('Godot import metadata did not settle within 120 seconds.')) 'builder fails closed if Godot sidecars keep changing'
Assert ($builderText.Contains('RedirectStandardOutput $verifyStdout -RedirectStandardError $verifyStderr')) 'offline verifier output and errors are retained in logs'
New-Item -ItemType Directory -Force -Path (Join-Path $pkg 'godot'),(Join-Path $pkg 'tools\windows\run'),(Join-Path $pkg 'godot\assets\p3\character_creator\parts\female_normal_v1')|Out-Null
[IO.File]::WriteAllText((Join-Path $pkg 'godot\project.godot'),'config_version=5',[Text.UTF8Encoding]::new($false))
$cmdFixture=Join-Path $pkg 'CHOI-GAME.cmd';[IO.File]::WriteAllText($cmdFixture,("echo game"+[char]13+[char]10),[Text.UTF8Encoding]::new($false));Assert ((Blob $cmdFixture)-ne(BlobRaw $cmdFixture)) 'Windows CRLF script uses canonical Git blob LF for runtime pin'
$verifyDest=Join-Path $pkg 'tools\windows\run\Verify-TRI03OfflinePackage.ps1';Copy-Item -LiteralPath $VerifierPath -Destination $verifyDest
for($i=0;$i-lt42;$i++){[IO.File]::WriteAllBytes((Join-Path $pkg ("godot\assets\p3\character_creator\parts\female_normal_v1\asset{0:D2}.png"-f$i)),[byte[]]@(0,1,2))}
$sourceFiles=@();foreach($p in @('CHOI-GAME.cmd','tools/windows/run/Verify-TRI03OfflinePackage.ps1')){$sourceFiles+=[pscustomobject]@{path=$p;git_blob_sha=(Blob (Join-Path $pkg $p.Replace('/','\')))}}
$runtimeFP=Finger @($sourceFiles|ForEach-Object{'{0}={1}'-f$_.path,$_.git_blob_sha})
$rm=[ordered]@{schema_version=2;branch='integration/pve-p0-playable-ui-20261103';base_sha=('2'*40);upstream_pr_sha=('3'*40);source_fingerprint=$runtimeFP;files=$sourceFiles}
[IO.File]::WriteAllText((Join-Path $pkg 'tools\windows\run\tri03_runtime_source_manifest.json'),($rm|ConvertTo-Json -Depth 6),[Text.UTF8Encoding]::new($false))
WritePackageManifest
$valid=RunVerifier;Assert ($script:Last-eq0-and$valid-match'TRI03_OFFLINE_VERIFY_PASS') 'valid package rejected'
New-Item -ItemType Directory -Force -Path (Join-Path $pkg 'godot\.godot')|Out-Null;[IO.File]::WriteAllText((Join-Path $pkg 'godot\.godot\cache.tmp'),'cache',[Text.UTF8Encoding]::new($false))
$cache=RunVerifier;Assert ($script:Last-eq0-and$cache-match'TRI03_OFFLINE_VERIFY_PASS') 'mutable Godot cache rejected'
[IO.File]::WriteAllText((Join-Path $pkg 'surprise.txt'),'extra',[Text.UTF8Encoding]::new($false));$extra=RunVerifier;Assert ($script:Last-ne0-and$extra-match'Unpinned extra file') 'extra package file accepted'
Remove-Item -LiteralPath (Join-Path $pkg 'surprise.txt') -Force
[IO.File]::WriteAllText((Join-Path $pkg 'godot\project.godot'),'tampered',[Text.UTF8Encoding]::new($false));$tamper=RunVerifier;Assert ($script:Last-ne0-and$tamper-match'SHA-256 mismatch') 'modified pinned source accepted'
[IO.File]::WriteAllText((Join-Path $pkg 'godot\project.godot'),'config_version=5',[Text.UTF8Encoding]::new($false))
$rmPath=Join-Path $pkg 'tools\windows\run\tri03_runtime_source_manifest.json';$badRuntime=Get-Content -LiteralPath $rmPath -Raw|ConvertFrom-Json;$badRuntime.base_sha=('4'*40);[IO.File]::WriteAllText($rmPath,($badRuntime|ConvertTo-Json -Depth 6),[Text.UTF8Encoding]::new($false));WritePackageManifest
$manifestTamper=RunVerifier;Assert ($script:Last-ne0-and$manifestTamper-match'Runtime source provenance') 'mismatched pinned source identity accepted'
if(-not $LauncherPath){$LauncherPath=Join-Path $PSScriptRoot '..\..\..\CHOI-GAME.cmd'}
$launcher=Get-Content -LiteralPath $LauncherPath -Raw
Assert ($launcher.Contains('goto :git_checkout')) 'Git checkout route missing'
Assert ($launcher.Contains('goto :offline_package')) 'offline manifest route missing'
Assert ($launcher -match 'Verify-TRI03OfflinePackage.ps1') 'offline verifier route missing'
Assert ($launcher -match 'Git is required to verify this checkout') 'Git checkout source verification must remain enabled'
$badDest=Join-Path $env:TEMP ('TMB-OFFLINE-BUILD-MUST-NOT-EXIST-'+[Guid]::NewGuid().ToString('N'))
$buildOut=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $BuilderPath -GameRoot $pkg -PackagePath $badDest -ProfileRoot $profile 2>&1
$buildCode=$LASTEXITCODE
Assert ($buildCode-ne0-and-not(Test-Path -LiteralPath $badDest)) 'detached fixture was exported as verified source'
Write-Output "TRI03_OFFLINE_PACKAGE_TEST_PASS checks=$checks fixture=$root"; exit 0
