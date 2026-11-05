#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

; The launch half of cachyos/niri/cfg/keybinds.kdl. LeopardWM binds the window
; half (leopardwm/config.toml); both use F13 as Mod.
;
; F13 is not a modifier to AutoHotkey, so "Mod+Ctrl+S" is ^s while F13 is held.
; That keeps F13+S itself free for LeopardWM: a bare F13 & s combo would
; swallow the s before LeopardWM's hook saw it.

CSIDL_MYPICTURES := 0x27
WallpaperDir := ComObject("Shell.Application").NameSpace(CSIDL_MYPICTURES).Self.Path "\wallpapers"
; The real exe, not the scoop shim: each process launch costs 200–300 ms here.
ScoopApps := (EnvGet("SCOOP") || EnvGet("USERPROFILE") "\scoop") "\apps"
; The Arch profile from windows-terminal/dotfiles.json, in a new window with no
; tab row or title bar, as ghostty has under niri. Ctrl+Shift+P, "focus mode"
; brings them back.
Terminal := 'wt.exe -w new --focus -p "Arch"'
PowerToys := ScoopApps "\powertoys\current\PowerToys.exe"
Lwm := ScoopApps "\leopardwm\current\lwm.exe"
Caffeinated := false

SessionMenu := Menu()
SessionMenu.Add("Lock", (*) => LockScreen())
SessionMenu.Add("Sleep", (*) => DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0))
SessionMenu.Add("Log out", (*) => Shutdown(0))
SessionMenu.Add("Restart", (*) => Shutdown(2))
SessionMenu.Add("Shut down", (*) => Shutdown(1 | 8))

#HotIf GetKeyState("F13", "P")

Enter:: Run(Terminal)
d:: OpenLauncher()
Space:: OpenLauncher()
e:: Run("explorer.exe")
!l:: LockScreen()

^s:: Send("#a")
n:: Send("#n")
^v:: Send("#v")
vkBC:: Run("ms-settings:")
Backspace:: SessionMenu.Show()
+e:: ConfirmLogOut()
+p:: PowerOffMonitors()

+t:: FocusFloatingOrTiling()
+o:: OpenPomodoro()
^+c:: Run("calc.exe")
+x:: NextWallpaper()
+c:: ToggleCaffeine()

#HotIf

F14:: OpenPomodoro()
F15:: RefreshWallpapers()

; PowerToys Run's own hotkey is Alt+Space. Start PowerToys first if it isn't
; running, since the hotkey does nothing until then.
OpenLauncher() {
    if ProcessExist("PowerToys.exe")
        Send("!{Space}")
    else if FileExist(PowerToys)
        Run(PowerToys)
    else
        TrayTip("No " PowerToys " — run setup.ps1", "Launcher")
}

; niri's switch-focus-between-floating-and-tiling, which LeopardWM lacks. Asks
; lwm which managed windows float, then focuses the topmost visible window of
; the other kind. Two process launches, so about half a second here.
FocusFloatingOrTiling() {
    out := A_Temp "\lwm-windows.json"
    RunWait(A_ComSpec ' /c ""' Lwm '" query all-windows > "' out '""', , "Hide")
    json := FileExist(out) ? FileRead(out) : ""
    ; Flatten the nested rect so every window is one {...} with no braces inside.
    json := RegExReplace(json, '"rect"\s*:\s*\{[^{}]*\}', '"rect":0')

    floating := Map(), tiled := Map()
    pos := 1
    while pos := RegExMatch(json, "\{[^{}]*\}", &win, pos) {
        pos += win.Len
        if !RegExMatch(win[0], '"hwnd"\s*:\s*"?(0x[0-9A-Fa-f]+|\d+)', &hwnd)
            continue
        isFloating := RegExMatch(win[0], '"is_floating"\s*:\s*true')
        (isFloating ? floating : tiled)[Integer(hwnd[1])] := true
    }
    if !floating.Count && !tiled.Count
        return TrayTip("lwm query all-windows gave no windows", "Focus")

    target := floating.Has(WinExist("A")) ? tiled : floating
    for id in WinGetList() {  ; topmost first
        if target.Has(id) && IsOnScreen(id)
            return WinActivate(id)
    }
}

; Windows on other workspaces are cloaked, not hidden.
IsOnScreen(id) {
    static DWMWA_CLOAKED := 14
    cloaked := 0
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", id, "UInt", DWMWA_CLOAKED, "UInt*", &cloaked, "UInt", 4)
    return !cloaked && DllCall("IsWindowVisible", "Ptr", id) && WinGetMinMax(id) != -1
}

LockScreen() => DllCall("LockWorkStation")

ConfirmLogOut() {
    if MsgBox("Log out?", "Session", "OKCancel Icon?") = "OK"
        Shutdown(0)
}

PowerOffMonitors() {
    static WM_SYSCOMMAND := 0x0112, SC_MONITORPOWER := 0xF170, POWER_OFF := 2
    SendMessage(WM_SYSCOMMAND, SC_MONITORPOWER, POWER_OFF, , "Program Manager")
}

; Stand-in until a pomodoro exists here: the Clock app's focus sessions.
OpenPomodoro() => Run("ms-clock:")

NextWallpaper() {
    pool := []
    Loop Files WallpaperDir "\immich-*"
        pool.Push(A_LoopFileFullPath)
    if !pool.Length
        return TrayTip("Nothing in " WallpaperDir " yet", "Wallpaper")
    SetWallpaper(pool[Random(1, pool.Length)])
}

SetWallpaper(path) {
    static SPI_SETDESKWALLPAPER := 0x14, SPIF_UPDATEINIFILE_SENDCHANGE := 3
    DllCall("SystemParametersInfo", "UInt", SPI_SETDESKWALLPAPER, "UInt", 0, "Str", path, "UInt", SPIF_UPDATEINIFILE_SENDCHANGE)
}

RefreshWallpapers() {
    script := A_ScriptDir "\..\scripts\immich-wallpaper.ps1"
    failed := RunWait('pwsh.exe -NoProfile -File "' script '"', , "Hide")
    TrayTip(failed ? "Refresh failed — run " script " by hand to see why" : "Fresh pool from Immich", "Wallpapers")
}

ToggleCaffeine() {
    static ES_CONTINUOUS := 0x80000000, ES_SYSTEM_REQUIRED := 0x1, ES_DISPLAY_REQUIRED := 0x2
    global Caffeinated := !Caffeinated
    DllCall("SetThreadExecutionState", "UInt", Caffeinated ? ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED : ES_CONTINUOUS)
    TrayTip(Caffeinated ? "Idle inhibited" : "Idle allowed", "Caffeine")
}
