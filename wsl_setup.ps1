# version: 1.0.4
# dandori Windows 設定腳本
# 自動安裝 WSL2 並執行 dandori

# 需要管理員權限
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# 顏色輸出函式
function Write-Info {
    Write-Host "ℹ️  $args" -ForegroundColor Blue
}

function Write-Success {
    Write-Host "✓ $args" -ForegroundColor Green
}

function Write-Warning {
    Write-Host "⚠️  $args" -ForegroundColor Yellow
}

function Write-Error-Custom {
    Write-Host "✗ $args" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  dandori Windows 環境設定" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 檢查 Windows 版本
Write-Info "檢查 Windows 版本..."
$version = [System.Environment]::OSVersion.Version
if ($version.Major -lt 10 -or ($version.Major -eq 10 -and $version.Build -lt 19041)) {
    Write-Error-Custom "需要 Windows 10 版本 2004 (build 19041) 或更新"
    Write-Host ""
    Write-Host "目前版本: $($version.Major).$($version.Minor) (build $($version.Build))"
    Write-Host "請更新 Windows 後再執行此腳本"
    exit 1
}
Write-Success "Windows 版本符合要求"
Write-Host ""

# 檢查是否已安裝 WSL
Write-Info "檢查 WSL 安裝狀態..."
$wslInstalled = $false
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
        Write-Success "WSL 已安裝"
    }
} catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Info "開始安裝 WSL2..."
    Write-Host ""
    Write-Warning "此步驟需要："
    Write-Host "  1. 下載約 1GB 的檔案"
    Write-Host "  2. 重新啟動電腦"
    Write-Host "  3. 重新執行此腳本"
    Write-Host ""

    $confirm = Read-Host "是否繼續? (Y/n)"
    if ($confirm -eq '' -or $confirm -eq 'Y' -or $confirm -eq 'y') {
        try {
            # 安裝 WSL（Windows 10 2004 以上可以用簡化指令）
            Write-Info "執行 wsl --install..."
            wsl --install -d Ubuntu

            Write-Host ""
            Write-Success "WSL 安裝指令已執行"
            Write-Host ""
            Write-Warning "請依照以下步驟："
            Write-Host "  1. 重新啟動電腦"
            Write-Host "  2. 重新開機後，Ubuntu 會自動啟動"
            Write-Host "  3. 設定 Ubuntu 使用者名稱和密碼"
            Write-Host "  4. 再次執行此腳本完成設定"
            Write-Host ""

            $restart = Read-Host "是否立即重新啟動? (y/N)"
            if ($restart -eq 'y' -or $restart -eq 'Y') {
                Restart-Computer
            }
            exit 0

        } catch {
            Write-Error-Custom "WSL 安裝失敗: $_"
            Write-Host ""
            Write-Host "手動安裝步驟："
            Write-Host "  1. 開啟 PowerShell (管理員)"
            Write-Host "  2. 執行: wsl --install"
            Write-Host "  3. 重新啟動電腦"
            Write-Host ""
            exit 1
        }
    } else {
        Write-Info "已取消安裝"
        exit 0
    }
}

# 檢查 WSL 發行版
Write-Info "檢查 Linux 發行版..."
$distros = wsl --list --quiet
if ($distros.Count -eq 0) {
    Write-Warning "尚未安裝任何 Linux 發行版"
    Write-Info "安裝 Ubuntu..."
    wsl --install -d Ubuntu

    Write-Host ""
    Write-Success "Ubuntu 安裝完成"
    Write-Host ""
    Write-Info "請設定 Ubuntu 使用者："
    Write-Host "  1. Ubuntu 視窗會自動開啟"
    Write-Host "  2. 輸入新的使用者名稱"
    Write-Host "  3. 輸入密碼（兩次）"
    Write-Host ""
    Write-Host "設定完成後，在 Ubuntu 終端機中執行："
    Write-Host "  curl -fsSL https://dandori.phx.tw | bash" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

$distro = ($distros | Select-Object -First 1).Trim()
Write-Success "已安裝發行版: $distro"
Write-Host ""

# 檢查 WSL 版本
Write-Info "檢查 WSL 版本..."
$wslInfo = wsl --list --verbose | Select-String $distro
if ($wslInfo -match "VERSION\s+2") {
    Write-Success "已使用 WSL2"
} else {
    Write-Warning "目前使用 WSL1，建議升級到 WSL2"
    $upgrade = Read-Host "是否升級到 WSL2? (Y/n)"
    if ($upgrade -eq '' -or $upgrade -eq 'Y' -or $upgrade -eq 'y') {
        Write-Info "升級到 WSL2..."
        wsl --set-version $distro 2
        Write-Success "已升級到 WSL2"
    }
}
Write-Host ""

# 詢問是否立即執行 dandori
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  準備執行 dandori" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$runNow = Read-Host "是否立即在 WSL 中執行 dandori? (Y/n)"
if ($runNow -eq '' -or $runNow -eq 'Y' -or $runNow -eq 'y') {
    Write-Host ""
    $useInteractive = Read-Host "使用互動模式選擇語言? (y/N)"

    if ($useInteractive -eq 'y' -or $useInteractive -eq 'Y') {
        Write-Info "啟動 WSL 並執行 dandori (互動模式)..."
        Write-Host ""
        wsl bash -c "curl -fsSL https://dandori.phx.tw | bash -s -- --interactive"
    } else {
        Write-Info "啟動 WSL 並執行 dandori (預設配置)..."
        Write-Host ""
        wsl bash -c "curl -fsSL https://dandori.phx.tw | bash"
    }

    Write-Host ""
    Write-Success "設定完成！"
    Write-Host ""
    Write-Info "後續使用方式："
    Write-Host "  1. 開啟 Windows Terminal 或 PowerShell"
    Write-Host "  2. 執行: wsl"
    Write-Host "  3. 開始開發！"
    Write-Host ""
    Write-Info "VS Code 整合："
    Write-Host "  安裝 'Remote - WSL' 擴充功能"
    Write-Host "  在 WSL 中執行: code ."
    Write-Host ""

} else {
    Write-Host ""
    Write-Success "WSL 環境已準備就緒！"
    Write-Host ""
    Write-Info "手動執行 dandori："
    Write-Host "  1. 開啟 Windows Terminal 或執行: wsl"
    Write-Host "  2. 在 WSL 終端機中執行："
    Write-Host "     curl -fsSL https://dandori.phx.tw | bash" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "或使用互動模式："
    Write-Host "     curl -fsSL https://dandori.phx.tw | bash -s -- --interactive" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  享受開發！" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
