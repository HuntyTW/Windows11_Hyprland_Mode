# 🚀 Windows 11 Hyprland Mode

> **Turn your Windows 11 desktop into a sleek, minimal, keyboard-driven Hyprland/i3 environment with a single shortcut.**

Switch seamlessly between a focused tiling development workstation (**Dev Mode**) and a clean floating desktop for gaming and entertainment (**Chill Mode**).

---

## ✨ Features

- **Tiling Window Management**: Powered by [GlazeWM](https://github.com/glzr-io/glazewm) (v3) — automatic window tiling, customizable gaps, multi-monitor support, and fluid layout navigation.
- **Top Status Bar**: Powered by [Zebar](https://github.com/glzr-io/zebar) — minimal bar showing active workspaces, battery, network, CPU/RAM, and time.
- **Rofi / Wofi App Launcher**: Integrated with [Flow Launcher](https://www.flowlauncher.com/) — instantaneous fuzzy search for applications, files, commands, and math calculations with `Alt + D` / `Alt + Space`.
- **Desktop Clutter Cleaner**: Instantly closes non-essential windows and hides desktop icons via native Win32 shell calls.
- **Wallpaper Engine Automation**: Automatically activates your `dev` wallpaper profile during coding sessions and reverts to `chill` for downtime.
- **Global Win + R Shortcuts**: Fast, zero-friction commands anywhere in Windows (`dev`, `chill`, `menu`, `icons`).
- **Catppuccin WPF Launcher**: A modern popup dialog (`mode-selector.ps1`) to select your environment with a smooth mouse/keyboard interface.

---

## ⌨️ Keybindings Cheatsheet

All keybindings are configured in `config/glazewm/config.yaml`.

| Hotkey | Action | Description |
| :--- | :--- | :--- |
| **`Alt + Enter`** | Launch Terminal | Opens Windows Terminal |
| **`Alt + D`** / **`Win + D`** | App Launcher | Opens Flow Launcher (rofi / wofi analog) |
| **`Alt + Space`** | App Launcher (Native) | Native Flow Launcher global shortcut |
| **`Alt + H / J / K / L`** | Focus Navigation | Focus Left / Down / Up / Right (Vim style or Arrows) |
| **`Alt + Shift + H / J / K / L`** | Move Window | Move window Left / Down / Up / Right |
| **`Alt + V`** | Split Direction | Toggle horizontal / vertical tiling split |
| **`Alt + W`** / **`Alt + Shift + Space`** | Toggle Floating | Detach window from tiling tree into floating mode |
| **`Alt + F`** | Fullscreen | Toggle fullscreen for active window |
| **`Alt + 1` .. **`9`** | Switch Workspace | Switch to workspace 1–9 |
| **`Alt + Shift + 1` .. **`9`** | Send to Workspace | Move window to workspace 1–9 |
| **`Alt + Shift + Q`** | Close Window | Gracefully close focused window |
| **`Alt + Shift + R`** | Reload Config | Reload GlazeWM configuration on the fly |
| **`Alt + Shift + E`** | Exit WM | Quit GlazeWM tiling |

---

## 🚀 Quick Start

### 1. Clone the repository
```powershell
git clone https://github.com/HuntyTW/Windows11_Hyprland_Mode.git
cd Windows11_Hyprland_Mode
```

### 2. Run the automated installer
Run PowerShell as your user:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

The script will:
1. Verify and install dependencies via `winget` (`GlazeWM`, `Zebar`, `Flow Launcher`).
2. Deploy configs to `~/.glzr/glazewm/config.yaml` and `~/.glzr/zebar/settings.json`.
3. Copy orchestrator scripts to `~/scripts/`.
4. Register `~/scripts` in your user `PATH` environment variable.

---

## 🎮 Usage

Open Windows **Run** dialog (**`Win + R`**) or any terminal:

- **`dev`** — **Activates Dev Mode**:
  - Closes background gaming apps / browsers
  - Switches Wallpaper Engine to profile `dev`
  - Hides desktop icons
  - Starts GlazeWM (tiling), Zebar (bar) and Flow Launcher
  - Closes lingering terminal windows

- **`chill`** — **Returns to Chill Mode**:
  - Stops GlazeWM, Zebar and Flow Launcher
  - Restores floating window behavior
  - Restores all desktop icons
  - Switches Wallpaper Engine to profile `chill`

- **`menu`** — Opens the Catppuccin interactive mode switcher dialog.
- **`icons`** — Manually toggles desktop icons visibility.

---

## 📁 Repository Structure

```
Windows11_Hyprland_Mode/
├── config/
│   ├── glazewm/
│   │   └── config.yaml          # GlazeWM rules, gaps, margins, hotkeys
│   └── zebar/
│       └── settings.json        # Zebar widget & bar configuration
├── scripts/
│   ├── dev-mode.ps1             # Dev mode orchestrator
│   ├── chill-mode.ps1           # Chill mode exit orchestrator
│   ├── close-all-apps.ps1       # Smart window cleanup with whitelist
│   ├── toggle-icons.ps1         # Win32 desktop icon visibility manager
│   ├── mode-selector.ps1        # WPF Catppuccin GUI popup selector
│   ├── setup-admin-task.ps1     # Scheduled task setup for elevated apps
│   ├── dev.cmd                  # Win+R runner for dev mode
│   ├── chill.cmd                # Win+R runner for chill mode
│   ├── menu.cmd                 # Win+R runner for GUI selector
│   └── icons.cmd                # Win+R runner for icon toggling
├── install.ps1                  # One-click deployment script
├── .gitignore
└── README.md
```

---

## ⚙️ Customization & Tips

### Wallpaper Engine Profiles
If you use Steam's **Wallpaper Engine**, create two profiles:
- `dev` — minimal, dark, distraction-free live wallpaper
- `chill` — your favorite animated or gaming theme

If Wallpaper Engine is not installed or running, the scripts automatically skip this step without errors.

### Whitelisting Processes
Edit `scripts/close-all-apps.ps1` to add applications you want to keep open when switching into Dev Mode (e.g., Spotify, Telegram, Obsidian).

---

## 📜 License
MIT License. Feel free to tweak, customize, and rice your setup!
