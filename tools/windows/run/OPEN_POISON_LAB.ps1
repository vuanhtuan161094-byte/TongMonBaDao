$ErrorActionPreference = 'Stop'

function Stop-Lab([string]$Message) {
    Write-Host "POISON_LAB_BLOCKED: $Message" -ForegroundColor Red
    exit 1
}

try {
    $repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    $project = Join-Path $repo 'godot'
    $scene = 'res://labs/combat_lab/combat_lab.tscn'
    $sceneFile = Join-Path $project 'labs\combat_lab\combat_lab.tscn'
    $manifest = Join-Path $project 'labs\combat_lab\assets\poison_vfx\poison_vfx_manifest.json'
    $requiredBranch = 'integration/pve-p0-playable-ui-20261103'
    $minimumRevision = '6a19c80a97cdd182c3f35d1b6a164047f8873043'
    $git = Get-Command 'git.exe' -ErrorAction SilentlyContinue
    if (-not $git) { $git = Get-Command 'git' -ErrorAction SilentlyContinue }
    if (-not $git) { Stop-Lab 'Không tìm thấy Git để xác minh nguồn PR #72.' }
    $actualBranch = (& $git.Source -c "safe.directory=$repo" -C $repo branch --show-current 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { Stop-Lab "Không đọc được branch của checkout: $actualBranch" }
    if (-not [string]::IsNullOrWhiteSpace($actualBranch) -and $actualBranch -ne $requiredBranch) {
        Stop-Lab "Sai branch: đang ở '$actualBranch', cần '$requiredBranch'."
    }
    $head = (& $git.Source -c "safe.directory=$repo" -C $repo rev-parse HEAD 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $head -notmatch '^[0-9a-fA-F]{40}$') {
        Stop-Lab "Không đọc được Git HEAD hợp lệ cho project: $repo"
    }
    & $git.Source -c "safe.directory=$repo" -C $repo cat-file -e "$minimumRevision^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Stop-Lab "Checkout cũ: thiếu Poison VFX v3 tối thiểu từ commit $minimumRevision. Hãy đồng bộ PR #72 an toàn."
    }
    & $git.Source -c "safe.directory=$repo" -C $repo merge-base --is-ancestor $minimumRevision $head 2>$null
    if ($LASTEXITCODE -ne 0) {
        Stop-Lab "Checkout cũ: HEAD $($head.Substring(0, 12)) chưa chứa Poison VFX v3 ($minimumRevision)."
    }
    if (-not [string]::IsNullOrWhiteSpace($actualBranch)) {
        $upstream = (& $git.Source -c "safe.directory=$repo" -C $repo rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($upstream)) {
            $divergence = (& $git.Source -c "safe.directory=$repo" -C $repo rev-list --left-right --count "$head...$upstream" 2>&1 | Out-String).Trim()
            if ($LASTEXITCODE -eq 0) {
                $counts = $divergence -split '\s+'
                if ($counts.Count -ge 2 -and [int]$counts[1] -gt 0) {
                    Stop-Lab "Checkout đang sau upstream '$upstream'; hãy cập nhật PR #72 trước khi mở Lab."
                }
            }
        }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $project 'project.godot') -PathType Leaf)) {
        Stop-Lab "Không tìm thấy project.godot tại checkout được suy ra từ launcher: $project"
    }
    if (-not (Test-Path -LiteralPath $sceneFile -PathType Leaf)) {
        Stop-Lab "Checkout này chưa có Combat Lab scene: $sceneFile. Hãy dùng launcher trong worktree PR #72 đã đồng bộ."
    }
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Stop-Lab "Checkout thiếu Poison VFX v3 manifest: $manifest. Đây có thể là checkout cũ."
    }

    try {
        $manifestData = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
    } catch {
        Stop-Lab "Poison VFX manifest không đọc được JSON: $manifest"
    }
    if ([int]$manifestData.schema_version -ne 1) {
        Stop-Lab "Poison VFX manifest sai schema_version; launcher chỉ hỗ trợ schema 1."
    }
    $vfxRows = @($manifestData.assets)
    $atlasRows = @($manifestData.preserved_source_actor_atlases)
    if ($vfxRows.Count -ne 4 -or $atlasRows.Count -ne 6) {
        Stop-Lab "Manifest không liệt kê đủ 4 master VFX và 6 atlas Nữ Độc Tu."
    }
    $sourceFiles = @()
    foreach ($row in ($vfxRows + $atlasRows)) {
        $assetUri = [string]$row.path
        $expectedHash = ([string]$row.sha256).ToLowerInvariant()
        if (-not $assetUri.StartsWith('res://') -or $expectedHash -notmatch '^[0-9a-f]{64}$') {
            Stop-Lab "Manifest có asset path hoặc SHA-256 không hợp lệ: $assetUri"
        }
        $relativeAsset = $assetUri.Substring(6).Replace('/', '\')
        $assetFile = Join-Path $project $relativeAsset
        if (-not (Test-Path -LiteralPath $assetFile -PathType Leaf)) {
            Stop-Lab "Thiếu asset theo manifest: $assetFile"
        }
        $actualHash = (Get-FileHash -LiteralPath $assetFile -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash) {
            Stop-Lab "SHA-256 asset không khớp manifest: $assetFile"
        }
        $sourceFiles += $assetFile
    }

    $godot = $null
    if ($env:GODOT_4_7_2) {
        $candidate = $env:GODOT_4_7_2
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            $candidate = Join-Path $candidate 'Godot_v4.7.2-stable_win64.exe'
        }
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $godot = (Resolve-Path -LiteralPath $candidate).Path }
    }
    if (-not $godot) {
        $candidates = @(
            'E:\TongMonBaDaoWorkspace\04_Tools\Godot\Godot_v4.7.2-stable_win64.exe',
            'E:\Godot_v4.7.2-stable_win64.exe',
            (Join-Path $env:ProgramFiles 'Godot\Godot_v4.7.2-stable_win64.exe')
        )
        foreach ($candidate in $candidates) {
            if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
                $godot = (Resolve-Path -LiteralPath $candidate).Path
                break
            }
        }
    }
    if (-not $godot) {
        $command = Get-Command 'Godot_v4.7.2-stable_win64.exe' -ErrorAction SilentlyContinue
        if ($command) { $godot = $command.Source }
    }
    if (-not $godot) {
        Stop-Lab 'Không tìm thấy Godot 4.7.2. Đặt GODOT_4_7_2 trỏ tới Godot_v4.7.2-stable_win64.exe hoặc cài binary vào E:\.'
    }

    function Get-GodotProcesses {
        try {
            return @(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue)
        } catch {
            Stop-Lab "Không xác minh được tiến trình Godot đang chạy; để tránh mở trùng, launcher dừng lại. $($_.Exception.Message)"
        }
    }
    $existing = Get-GodotProcesses
    if ($existing.Count -gt 0) {
        $details = ($existing | ForEach-Object { "PID $($_.Id) · $($_.ProcessName)" }) -join ([Environment]::NewLine)
        Stop-Lab "Đang có Godot mở. Launcher không đóng tiến trình nào; hãy thoát Godot bình thường rồi bấm lại.$([Environment]::NewLine)$details"
    }

    $version = (& $godot --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $version -notmatch '^4\.7\.2\.stable\.official') {
        Stop-Lab "Binary không đúng Godot 4.7.2 official. Đường dẫn: $godot; version trả về: $version"
    }

    $unimported = @($sourceFiles | Where-Object {
        -not (Test-Path -LiteralPath ($_.ToString() + '.import') -PathType Leaf)
    })
    if ($unimported.Count -gt 0) {
        Write-Host "Đang import các asset Poison VFX/atlas chưa có sidecar..."
        $importLog = Join-Path $env:TEMP ("tmb_poison_lab_import_{0}.stdout.log" -f $PID)
        $importErrorLog = Join-Path $env:TEMP ("tmb_poison_lab_import_{0}.stderr.log" -f $PID)
        $importArgs = '--headless --editor --path "{0}" --quit' -f $project
        $importProcess = Start-Process -FilePath $godot -ArgumentList $importArgs -WorkingDirectory $project -PassThru -RedirectStandardOutput $importLog -RedirectStandardError $importErrorLog
        if (-not $importProcess.WaitForExit(120000)) {
            Stop-Lab "Import quá 120 giây và vẫn chạy ở PID $($importProcess.Id). Launcher không tự đóng tiến trình. Log: $importLog"
        }
        $importProcess.Refresh()
        if ($importProcess.ExitCode -ne 0) {
            $details = ''
            if (Test-Path -LiteralPath $importErrorLog) { $details += Get-Content -LiteralPath $importErrorLog -Raw }
            if (Test-Path -LiteralPath $importLog) { $details += Get-Content -LiteralPath $importLog -Raw }
            if ($details -match 'ig11icd64\.dll|OpenGL|Vulkan') {
                Stop-Lab "BLOCKED_DRIVER: Godot import/render backend báo lỗi driver. Exit $($importProcess.ExitCode). Logs: $importLog; $importErrorLog"
            }
            Stop-Lab "Godot import thất bại (exit $($importProcess.ExitCode)); xem logs: $importLog; $importErrorLog"
        }
    }

    $existing = Get-GodotProcesses
    if ($existing.Count -gt 0) {
        Stop-Lab 'Một tiến trình Godot đang chạy sau bước import; launcher sẽ không mở thêm tiến trình.'
    }
    $argumentLine = '--path "{0}" "{1}"' -f $project, $scene
    $process = Start-Process -FilePath $godot -ArgumentList $argumentLine -WorkingDirectory $project -PassThru
    if (-not $process.WaitForExit(25000)) {
        $process.Refresh()
        if ($process.MainWindowHandle -eq 0) {
            Stop-Lab "BLOCKED_NO_WINDOW: Godot PID $($process.Id) vẫn chạy nhưng chưa tạo GUI sau 25 giây. Không tự đóng PID."
        }
    } else {
        $process.Refresh()
        $driverEvidence = ''
        try {
            $recentErrors = Get-WinEvent -FilterHashtable @{
                LogName = 'Application'
                Id = 1000
                StartTime = (Get-Date).AddMinutes(-5)
            } -MaxEvents 20 -ErrorAction Stop
            foreach ($entry in $recentErrors) {
                $message = [string]$entry.Message
                if ($message -match 'Godot_v4\.7\.2-stable_win64\.exe' -and $message -match 'ig11icd64\.dll') {
                    $driverEvidence = 'Windows Application Error xác nhận ig11icd64.dll'
                    break
                }
                if ($message -match 'Godot_v4\.7\.2-stable_win64\.exe' -and $message -match 'Faulting module name:\s*([^\s]+)') {
                    $driverEvidence = "Windows Application Error · module $($Matches[1])"
                    break
                }
            }
        } catch {}
        if ($driverEvidence -match 'ig11icd64\.dll') {
            Stop-Lab "BLOCKED_DRIVER: $driverEvidence; Godot exit $($process.ExitCode)."
        }
        if ($driverEvidence) {
            Stop-Lab "Godot crash có bằng chứng Windows: $driverEvidence; exit $($process.ExitCode)."
        }
        Stop-Lab "Combat Lab thoát trước khi hiện cửa sổ (exit $($process.ExitCode)); chưa có bằng chứng crash driver trong Event Log."
    }
    Write-Host "Combat Lab đã tạo cửa sổ · Godot $version · PID $($process.Id)"
    Write-Host "Project: $project"
    Write-Host "Scene:   $scene"
} catch {
    Stop-Lab $_.Exception.Message
}
