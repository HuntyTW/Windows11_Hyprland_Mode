# Dev Mode (Hyprland minimal style)
$glazeExe = "C:\Program Files\glzr.io\GlazeWM\glazewm.exe"
$zebarExe = "C:\Program Files\glzr.io\Zebar\zebar.exe"
$wpEngine = "C:\Program Files (x86)\Steam\steamapps\common\wallpaper_engine\wallpaper64.exe"
$closeScript = "$HOME\scripts\close-all-apps.ps1"
$iconsScript = "$HOME\scripts\toggle-icons.ps1"

# 1. Закрываем всё лишнее (игры, браузеры, открытые окна)
if (Test-Path $closeScript) {
    & $closeScript -Keep @("glazewm", "zebar", "Flow.Launcher")
}

# 2. Меняем обои на dev
if (Test-Path $wpEngine) {
    Start-Process $wpEngine -ArgumentList "-control openProfile -profile dev" -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# 3. Скрываем значки на рабочем столе
if (Test-Path $iconsScript) {
    & $iconsScript -Action Hide
}

# 4. Даем DWM, Explorer и Wallpaper Engine стабилизировать рабочий стол
Start-Sleep -Milliseconds 600

# 5. Включаем GlazeWM (тайлинг окон)
if (-not (Get-Process glazewm -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $glazeExe -WorkingDirectory (Split-Path $glazeExe)
    Start-Sleep -Milliseconds 1200
}

# 6. Включаем Zebar (статус-бар)
if (-not (Get-Process zebar -ErrorAction SilentlyContinue)) {
    if (Get-Process glazewm -ErrorAction SilentlyContinue) {
        & "C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe" command shell-exec zebar 2>$null | Out-Null
        Start-Sleep -Milliseconds 600
    }
    if (-not (Get-Process zebar -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $zebarExe -WorkingDirectory (Split-Path $zebarExe)
        Start-Sleep -Milliseconds 400
    }
}

# 7. Включаем Flow Launcher (быстрое меню приложений в стиле rofi)
$flowExe = "$env:LOCALAPPDATA\FlowLauncher\Flow.Launcher.exe"
if (Test-Path $flowExe) {
    if (-not (Get-Process "Flow.Launcher" -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $flowExe -WorkingDirectory (Split-Path $flowExe)
    }
}

# 8. Закрываем все открытые терминалы (чтобы рабочий стол остался чистым)
Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

exit 0
