#Requires -Version 7
#
# The Windows setup: the desktop here, the shell in Arch on WSL (windows/wsl). Run it from a Windows-side clone of this repo:
#
#   pwsh -ExecutionPolicy Bypass -File .\windows\scripts-manual\setup.ps1

param([string]$WslUser = 'mel')

$ErrorActionPreference = 'Stop'
$env:WSL_UTF8 = '1' # wsl.exe prints UTF-16 otherwise, which PowerShell mangles

$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path
$Win = Join-Path $RepoRoot 'windows'
$Distro = 'archlinux'

function Step($Message) { Write-Host "`n==> $Message" -ForegroundColor Blue }
function Info($Message) { Write-Host "  $Message" }
function Warn($Message) { Write-Host "  ! $Message" -ForegroundColor Yellow }
function Have($Command) { [bool](Get-Command $Command -ErrorAction Ignore) }
function Die($Message) { Write-Host "fatal: $Message" -ForegroundColor Red; exit 1 }

if ($RepoRoot.StartsWith('\\') -or $RepoRoot.StartsWith('Microsoft.PowerShell.Core\FileSystem::')) {
    Die "$RepoRoot is a network path — clone the repo onto a Windows drive and run it from there"
}

function Link($Src, $Dst) {
    $existing = Get-Item $Dst -Force -ErrorAction Ignore
    if ($existing.LinkType) { return Info "$Dst already a link -> $($existing.Target)" }
    if ($existing) { return Warn "$Dst already exists — not touching it" }

    New-Item -ItemType Directory -Force (Split-Path $Dst) | Out-Null
    New-Item -ItemType Junction -Path $Dst -Target $Src | Out-Null
    Info "$Dst -> $Src"
}

function Set-Shortcut($Path, $Target, $Arguments) {
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Path)
    $shortcut.TargetPath = $Target
    $shortcut.Arguments = $Arguments
    $shortcut.Save()
}

function Invoke-Elevated($Script) {
    $pwsh = (Get-Process -Id $PID).Path
    try {
        $process = Start-Process $pwsh -Verb RunAs -Wait -PassThru -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$Script`""
        $process.ExitCode -eq 0
    } catch {
        $false
    }
}

function Invoke-Scoop {
    # scoop's scripts expect PowerShell's default error handling. Under this
    # script's 'Stop', any error inside one ends the whole setup.
    $ErrorActionPreference = 'Continue'
    scoop @args
}

function Test-Font($File) {
    (Test-Path "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\$File") -or (Test-Path "$env:windir\Fonts\$File")
}

function Invoke-Wsl {
    wsl.exe --distribution $Distro @args
    if ($LASTEXITCODE) { Die "wsl $args failed" }
}

# packages

$Packages = @(
    'gh'
    'neovim', 'tree-sitter', 'zig' # zig compiles LazyVim's treesitter parsers
    'ripgrep', 'fd', 'fzf', 'bat', 'delta', 'difftastic', 'jq', 'yq', '7zip'
    'extras/lazygit'
    'imagemagick' # immich-wallpaper converts HEIC/RAW/webp

    'extras/leopardwm', 'extras/autohotkey', 'extras/powertoys'
)

# Each font package, by one file it installs. A copy installed some other way
# stays: scoop can't overwrite a font that's in use, and uninstalling the
# package would delete the original files.
$Fonts = @{
    'nerd-fonts/FiraCode-NF'          = 'FiraCodeNerdFont-Regular.ttf'
    'nerd-fonts/NerdFontsSymbolsOnly' = 'SymbolsNerdFont-Regular.ttf'
}
$Packages += @($Fonts.Keys | Where-Object { -not (Test-Font $Fonts[$_]) })

if (-not (Have scoop)) {
    Step 'scoop'
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
}

Step 'installing packages'
$buckets = @(Invoke-Scoop bucket list | ForEach-Object Name)
foreach ($bucket in 'extras', 'nerd-fonts') {
    if ($bucket -notin $buckets) { Invoke-Scoop bucket add $bucket }
}
Invoke-Scoop update
Invoke-Scoop install @Packages

# config links

Step 'config links'
# A fragment rather than settings.json, which Windows Terminal rewrites itself.
Link "$Win\windows-terminal" "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments\dotfiles"
Link "$Win\leopardwm" "$env:APPDATA\leopardwm\config"
Link "$Win\lazygit" "$env:LOCALAPPDATA\lazygit"
Link "$Win\nvim" "$env:LOCALAPPDATA\nvim"

# window manager

Step 'komorebi'
if (Get-Process komorebi -ErrorAction Ignore) {
    komorebic stop --whkd --bar
    Info 'stopped komorebi, whkd and komorebi-bar'
}
if (Have komorebic) {
    komorebic disable-autostart | Out-Null
    Info 'komorebi no longer starts at login'
}
Get-Process whkd -ErrorAction Ignore | Stop-Process

Step 'leopardwm'
lwm autostart enable
lwm run
Info 'running, and starts at login'

Step 'hotkeys'
$ahk = Join-Path (scoop prefix autohotkey) 'v2\AutoHotkey64.exe'
$hotkeys = "`"$Win\autohotkey\hotkeys.ahk`""
Set-Shortcut (Join-Path ([Environment]::GetFolderPath('Startup')) 'hotkeys.lnk') $ahk $hotkeys
Start-Process $ahk $hotkeys
Info 'running, and starts at login'

Step 'flow launcher'
Get-Process Flow.Launcher -ErrorAction Ignore | Stop-Process
Remove-Item (Join-Path ([Environment]::GetFolderPath('Startup')) 'flow-launcher.lnk') -ErrorAction Ignore
if ('flow-launcher' -in @(Invoke-Scoop list | ForEach-Object Name)) {
    Invoke-Scoop uninstall flow-launcher
    Info 'uninstalled from scoop'
}
$flowSquirrel = "$env:LOCALAPPDATA\FlowLauncher\Update.exe"
if (Test-Path $flowSquirrel) {
    Start-Process $flowSquirrel '--uninstall' -Wait
    Info 'uninstalled the standalone install'
}

Step 'launcher'
$powertoys = Join-Path (scoop prefix powertoys) 'PowerToys.exe'
if (Test-Path $powertoys) {
    Set-Shortcut (Join-Path ([Environment]::GetFolderPath('Startup')) 'powertoys.lnk') $powertoys ''
    if (-not (Get-Process PowerToys -ErrorAction Ignore)) { Start-Process $powertoys }
    Info 'running, and starts at login'
} else {
    Warn "$powertoys is missing — reinstall: scoop uninstall powertoys; scoop install extras/powertoys"
}

Step 'mod key'
$needsReboot = $false
$scancodeMap = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -ErrorAction Ignore).'Scancode Map'
if ($scancodeMap) {
    Info 'a Scancode Map is already set — see scripts-manual\win-key-to-f13.ps1 if Mod does nothing'
} elseif (Invoke-Elevated "$PSScriptRoot\win-key-to-f13.ps1") {
    $needsReboot = $true
    Info 'left Win sends F13 after a reboot'
} else {
    Warn 'not remapped (UAC declined?) — run scripts-manual\win-key-to-f13.ps1 as admin'
}

# desktop

Step 'input'
Add-Type -Namespace Win32 -Name Input -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, int[] value, uint flags);
'@
$SPI_SETMOUSE = 0x4
$SPIF_UPDATEINIFILE_SENDCHANGE = 3
[Win32.Input]::SystemParametersInfo($SPI_SETMOUSE, 0, [int[]](0, 0, 0), $SPIF_UPDATEINIFILE_SENDCHANGE) | Out-Null
Info 'mouse acceleration off'
Set-ItemProperty 'HKCU:\Control Panel\Keyboard' -Name InitialKeyboardIndicators -Value '2'
Info 'numlock on at login'

Step 'theme'
$personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
Set-ItemProperty $personalize -Name AppsUseLightTheme -Value 0
Set-ItemProperty $personalize -Name SystemUsesLightTheme -Value 0
Info 'dark mode'

Step 'idle'
powercfg /change monitor-timeout-ac 15
powercfg /change standby-timeout-ac 240
Info 'on mains: screen off after 15 min, sleep after 4 h'

# immich api key
Step 'immich api key'
$immichKey = Join-Path $env:LOCALAPPDATA 'immich-wallpaper\api-key'

if (Test-Path $immichKey) {
    Info "already set at $immichKey"
} else {
    $key = Read-Host -MaskInput '  immich api key (Account Settings -> API Keys, blank to skip)'
    if ($key) {
        New-Item -ItemType Directory -Force (Split-Path $immichKey) | Out-Null
        Set-Content -NoNewline $immichKey $key
        Info "wrote $immichKey ($($key.Length) chars)"
    } else {
        Warn 'skipped — immich-wallpaper will not run until this exists'
    }
    Remove-Variable key
}

# scheduled tasks
Step 'scheduled tasks'
$immich = New-ScheduledTaskAction -Execute 'conhost.exe' `
    -Argument "--headless pwsh.exe -NoProfile -File `"$Win\scripts\immich-wallpaper.ps1`""
$daily = New-ScheduledTaskTrigger -Daily -At '00:00' -RandomDelay (New-TimeSpan -Minutes 30)
$catchUp = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName 'immich-wallpaper' -Action $immich -Trigger $daily -Settings $catchUp -Force | Out-Null
Info "next run: $((Get-ScheduledTaskInfo -TaskName 'immich-wallpaper').NextRunTime)"

# the shell

Step "$Distro on wsl"
if ($Distro -notin @(wsl.exe --list --quiet)) {
    wsl.exe --install --distribution $Distro --no-launch
}
Invoke-Wsl --user root --cd $Win --exec bash wsl/provision $WslUser
wsl.exe --terminate $Distro | Out-Null # wsl.conf only applies from the next boot
Invoke-Wsl --user $WslUser --cd $Win --exec bash wsl/setup
wsl.exe --set-default $Distro | Out-Null
Info "$Distro is the default distro"

Step 'status'
foreach ($tool in 'nvim', 'gh', 'rg', 'fd', 'fzf', 'bat', 'delta', 'difft', 'jq', 'yq', 'lazygit',
    'magick', 'lwm', 'autohotkey', 'wt', 'pwsh') {
    if (Have $tool) { Write-Host '  ✓' $tool -ForegroundColor Green }
    else { Write-Host '  ✗' $tool -ForegroundColor Red }
}

Write-Host @"

  - PowerToys Run's hotkey has to stay Alt+Space: Mod+D and Mod+Space send it
  - ~/.gitconfig is left alone: this machine commits as work

To go back to komorebi:
  lwm autostart disable; lwm stop
  Remove-Item "$([Environment]::GetFolderPath('Startup'))\hotkeys.lnk"
  komorebic enable-autostart --whkd; komorebic start --whkd
To go back to another distro: wsl --set-default <name>
"@

if ($needsReboot -and (Read-Host '  reboot now for the Mod key? [y/N]') -eq 'y') {
    Restart-Computer
}
