# Chill Mode Launcher (Clean return to floating Windows)
$wpEngine = "C:\Program Files (x86)\Steam\steamapps\common\wallpaper_engine\wallpaper64.exe"
$closeScript = "$HOME\scripts\close-all-apps.ps1"
$iconsScript = "$HOME\scripts\toggle-icons.ps1"

# 1. Отключение тайлинга GlazeWM, Zebar и Flow Launcher (возврат к стандартным плавающим окнам Windows)
& "C:\Program Files\glzr.io\GlazeWM\cli\glazewm.exe" command wm-exit 2>$null | Out-Null
Get-Process glazewm*, zebar*, Flow.Launcher* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Возврат значков на рабочем столе (сразу восстанавливаем!)
if (Test-Path $iconsScript) {
    & $iconsScript -Action Show
}

# 3. Обои Wallpaper Engine (профиль 'chill')
if (Test-Path $wpEngine) {
    Start-Process $wpEngine -ArgumentList "-control openProfile -profile chill" -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# 4. Закрытие лишних программ (кроме оболочки)
if (Test-Path $closeScript) {
    & $closeScript
}

# 5. В самом конце закрываем терминал, если был открыт
Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

exit 0
