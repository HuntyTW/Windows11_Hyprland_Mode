param(
    [string[]]$Keep = @()
)

# Whitelist processes that must NEVER be terminated
$whitelist = @(
    # Core Windows OS and Shell
    "explorer", "dwm", "sihost", "taskhostw", "ctfmon", "csrss", "winlogon", "svchost",
    "StartMenuExperienceHost", "SearchHost", "ShellHost", "ShellExperienceHost",
    "TextInputHost", "SystemSettings", "ApplicationFrameHost", "RuntimeBroker",
    "Widgets", "WidgetService", "MoNotificationUx", "SecurityHealthSystray",
    
    # Antigravity IDE (our working environment)
    "Antigravity", "AG_*", "node", "language_server", "browser_assistant",
    
    # Wallpaper Engine & Hardware drivers
    "wallpaper32", "wallpaper64", "wallpaperui", "ui32",
    "nvcontainer", "NVDisplay*", "NVIDIA*", "nvsphelper64", "vgtray",
    
    # Background sync & Daemons
    "syncthing", "FileCoAuth", "OneDrive",
    
    # Current terminal & shell runners
    "powershell", "cmd", "conhost", "WindowsTerminal", "OpenConsole"
) + $Keep

# 1. Terminate elevated apps if registered (e.g. Discord running as Admin)
if ("Discord" -notin $whitelist) {
    schtasks /run /tn "KillElevatedApps" 2>$null | Out-Null
}

# 2. Terminate known heavy user apps with taskkill (/T terminates whole child trees)
$commonApps = @(
    "Discord", "Telegram", "WhatsApp", "Slack",
    "chrome", "msedge", "firefox", "brave", "opera", "vivaldi",
    "steam", "steamwebhelper", "Saudade Launcher", "EpicGamesLauncher", "Battle.net",
    "Spotify"
)

foreach ($name in $commonApps) {
    $shouldKeep = $false
    foreach ($k in $whitelist) {
        if ($name -like $k) { $shouldKeep = $true; break }
    }
    if (-not $shouldKeep) {
        & taskkill.exe /F /T /IM "$name.exe" 2>$null | Out-Null
        Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

# 2. Close all remaining user GUI windows in the current session
$currentSession = (Get-Process -Id $PID).SessionId
$guiProcs = Get-Process | Where-Object {
    $_.SessionId -eq $currentSession -and
    $_.MainWindowHandle -ne 0 -and
    $_.MainWindowTitle -ne ""
}

foreach ($p in $guiProcs) {
    $shouldKeep = $false
    foreach ($w in $whitelist) {
        if ($p.ProcessName -like $w) {
            $shouldKeep = $true
            break
        }
    }
    if (-not $shouldKeep) {
        $p.CloseMainWindow() | Out-Null
        Start-Sleep -Milliseconds 60
        if (-not $p.HasExited) {
            & taskkill.exe /F /T /PID $p.Id 2>$null | Out-Null
            Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        } else {
            # Kill remaining zombie children (especially Electron helper processes)
            & taskkill.exe /F /T /IM "$($p.ProcessName).exe" 2>$null | Out-Null
        }
    }
}
