# Windows 11 Hyprland Mode - Installer / Deploy Script
# Sets up GlazeWM, Zebar, Flow Launcher, scripts and PATH for the current user.

$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  🚀 Windows 11 Hyprland Mode - Deployment Setup" -ForegroundColor Cyan
Write-Host "======================================================`n" -ForegroundColor Cyan

# 1. Target Directories
$userHome = $HOME
$scriptsTarget = "$userHome\scripts"
$glzrTarget = "$userHome\.glzr"
$glazeTarget = "$glzrTarget\glazewm"
$zebarTarget = "$glzrTarget\zebar"

# 2. Check / Install Dependencies via winget
function Ensure-Package {
    param([string]$PackageId, [string]$DisplayName)
    Write-Host "[*] Checking dependency: $DisplayName ($PackageId)..." -ForegroundColor Yellow
    $check = winget list --id $PackageId --exact 2>$null
    if ($LASTEXITCODE -ne 0 -or (-not $check)) {
        Write-Host "[+] Installing $DisplayName via winget..." -ForegroundColor Green
        winget install --id $PackageId --exact --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "    [✓] $DisplayName is already installed." -ForegroundColor Green
    }
}

Ensure-Package "glzr-io.glazewm" "GlazeWM"
Ensure-Package "glzr-io.zebar" "Zebar"
Ensure-Package "Flow-Launcher.Flow-Launcher" "Flow Launcher"

# 3. Create folders
New-Item -ItemType Directory -Force -Path $scriptsTarget | Out-Null
New-Item -ItemType Directory -Force -Path $glazeTarget | Out-Null
New-Item -ItemType Directory -Force -Path $zebarTarget | Out-Null

# 4. Copy Configurations
Write-Host "`n[*] Deploying configurations..." -ForegroundColor Yellow
$scriptDir = $PSScriptRoot

if (Test-Path "$scriptDir\config\glazewm\config.yaml") {
    Copy-Item "$scriptDir\config\glazewm\config.yaml" "$glazeTarget\config.yaml" -Force
    Write-Host "    [✓] GlazeWM config deployed to $glazeTarget\config.yaml" -ForegroundColor Green
}

if (Test-Path "$scriptDir\config\zebar\settings.json") {
    Copy-Item "$scriptDir\config\zebar\settings.json" "$zebarTarget\settings.json" -Force
    Write-Host "    [✓] Zebar config deployed to $zebarTarget\settings.json" -ForegroundColor Green
}

# 5. Copy Scripts & Wrappers
Write-Host "`n[*] Deploying scripts..." -ForegroundColor Yellow
Get-ChildItem -Path "$scriptDir\scripts" -File | ForEach-Object {
    Copy-Item $_.FullName "$scriptsTarget\$($_.Name)" -Force
    Write-Host "    [✓] Copied $($_.Name)" -ForegroundColor Green
}

# 6. Ensure ~/scripts is in User PATH for Win+R support
Write-Host "`n[*] Checking User PATH..." -ForegroundColor Yellow
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathList = $userPath -split ';' | Where-Object { $_ -ne '' }
if ($pathList -notcontains $scriptsTarget) {
    Write-Host "[+] Adding $scriptsTarget to User PATH..." -ForegroundColor Green
    $newPath = ($pathList + $scriptsTarget) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = "$env:Path;$scriptsTarget"
    Write-Host "    [✓] User PATH updated! Commands 'dev', 'chill', 'menu' are now globally available." -ForegroundColor Green
} else {
    Write-Host "    [✓] $scriptsTarget is already in User PATH." -ForegroundColor Green
}

Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host "  ✨ Installation Completed Successfully!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Commands available in Win + R or Terminal:" -ForegroundColor Yellow
Write-Host "  • dev   -> Switch to Hyprland-style Tiling Dev Mode" -ForegroundColor White
Write-Host "  • chill -> Return to standard floating Windows mode" -ForegroundColor White
Write-Host "  • menu  -> Show GUI profile selector popup" -ForegroundColor White
Write-Host "  • icons -> Toggle desktop icons manually`n" -ForegroundColor White
