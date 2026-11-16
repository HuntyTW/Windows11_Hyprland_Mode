param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Show", "Hide", "Toggle")]
    [string]$Action = "Toggle"
)

$logFile = "$env:TEMP\toggle-icons.log"

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class ShellIconManager {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

    [DllImport("user32.dll")]
    public static extern IntPtr GetDesktopWindow();

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);

    public const uint WM_COMMAND = 0x0111;
    public const int TOGGLE_ICONS = 0x7402;
    public const int SW_HIDE = 0;
    public const int SW_SHOW = 5;

    public static IntPtr FindDefView() {
        // 1. Try under Progman
        IntPtr hProgman = FindWindow("Progman", null);
        if (hProgman != IntPtr.Zero) {
            IntPtr hView = FindWindowEx(hProgman, IntPtr.Zero, "SHELLDLL_DefView", null);
            if (hView != IntPtr.Zero) return hView;
        }

        // 2. Try under WorkerW via GetDesktopWindow
        IntPtr hDesktop = GetDesktopWindow();
        IntPtr hWorkerW = IntPtr.Zero;
        while ((hWorkerW = FindWindowEx(hDesktop, hWorkerW, "WorkerW", null)) != IntPtr.Zero) {
            IntPtr hView = FindWindowEx(hWorkerW, IntPtr.Zero, "SHELLDLL_DefView", null);
            if (hView != IntPtr.Zero) return hView;
        }

        // 3. Fallback search anywhere
        hWorkerW = IntPtr.Zero;
        while ((hWorkerW = FindWindowEx(IntPtr.Zero, hWorkerW, "WorkerW", null)) != IntPtr.Zero) {
            IntPtr hView = FindWindowEx(hWorkerW, IntPtr.Zero, "SHELLDLL_DefView", null);
            if (hView != IntPtr.Zero) return hView;
        }

        return IntPtr.Zero;
    }

    public static IntPtr FindFolderView() {
        IntPtr hView = FindDefView();
        if (hView != IntPtr.Zero) {
            return FindWindowEx(hView, IntPtr.Zero, "SysListView32", null);
        }
        return IntPtr.Zero;
    }

    public static string SetIcons(string action) {
        IntPtr hView = FindDefView();
        IntPtr hList = FindFolderView();

        bool isVisible = true;
        if (hList != IntPtr.Zero) {
            isVisible = IsWindowVisible(hList);
        }

        if (action == "Hide") {
            if (hList != IntPtr.Zero) {
                ShowWindow(hList, SW_HIDE);
            }
            if (hView != IntPtr.Zero && isVisible) {
                SendMessage(hView, WM_COMMAND, (IntPtr)TOGGLE_ICONS, IntPtr.Zero);
            }
            SHChangeNotify(0x08000000, 0, IntPtr.Zero, IntPtr.Zero);
            return "Hidden";
        } else if (action == "Show") {
            if (hList != IntPtr.Zero) {
                ShowWindow(hList, SW_SHOW);
            }
            if (hView != IntPtr.Zero && !isVisible) {
                SendMessage(hView, WM_COMMAND, (IntPtr)TOGGLE_ICONS, IntPtr.Zero);
            }
            SHChangeNotify(0x08000000, 0, IntPtr.Zero, IntPtr.Zero);
            return "Shown";
        } else {
            if (hView != IntPtr.Zero) {
                SendMessage(hView, WM_COMMAND, (IntPtr)TOGGLE_ICONS, IntPtr.Zero);
            }
            SHChangeNotify(0x08000000, 0, IntPtr.Zero, IntPtr.Zero);
            return "Toggled";
        }
    }
}
"@ -ErrorAction SilentlyContinue

# Set registry as well
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if ($Action -eq "Hide") {
    Set-ItemProperty -Path $regPath -Name "HideIcons" -Value 1 -ErrorAction SilentlyContinue
} elseif ($Action -eq "Show") {
    Set-ItemProperty -Path $regPath -Name "HideIcons" -Value 0 -ErrorAction SilentlyContinue
}

$result = [ShellIconManager]::SetIcons($Action)
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Action: $Action, Result: $result" | Out-File -FilePath $logFile -Append -Encoding UTF8
