#Requires -Version 7
#Requires -RunAsAdministrator
#
# win-key-to-f13 — make the left Win key send F13, the Mod key for
# leopardwm/config.toml and autohotkey/hotkeys.ahk.
#
#   .\win-key-to-f13.ps1          remap, from the next reboot
#   .\win-key-to-f13.ps1 -Undo    take it back out, from the next reboot
#
# Mod can't be Win itself: Windows acts on Win+L below every keyboard hook, so no
# hotkey tool can bind it, and Mod+L is focus-right. A Scancode Map rewrites the
# key inside the keyboard driver, before Windows ever sees a Win key. It covers
# every keyboard; on the Keychron, mapping left GUI to F13 in QMK does the same
# without admin. Start is still on Ctrl+Esc.

param([switch]$Undo)

$ErrorActionPreference = 'Stop'

$Layout = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$F13 = [byte[]](0x64, 0x00)
$LeftWin = [byte[]](0x5B, 0xE0)
$Header = [byte[]](0, 0, 0, 0, 0, 0, 0, 0)
$OneMappingPlusTerminator = [byte[]](2, 0, 0, 0)
$Terminator = [byte[]](0, 0, 0, 0)
$LeftWinToF13 = [byte[]]($Header + $OneMappingPlusTerminator + $F13 + $LeftWin + $Terminator)

$current = (Get-ItemProperty $Layout -ErrorAction Ignore).'Scancode Map'
$isOurs = $current -and [Convert]::ToHexString($current) -eq [Convert]::ToHexString($LeftWinToF13)

if ($Undo) {
    if ($isOurs) {
        Remove-ItemProperty $Layout -Name 'Scancode Map'
        Write-Host 'removed — reboot to get the Win key back'
    } elseif ($current) {
        throw "the Scancode Map there isn't this one — remove it by hand: $([Convert]::ToHexString($current))"
    } else {
        Write-Host 'nothing to undo'
    }
} elseif ($isOurs) {
    Write-Host 'already remapped'
} elseif ($current) {
    throw "a different Scancode Map is already set — merge by hand: $([Convert]::ToHexString($current))"
} else {
    New-ItemProperty $Layout -Name 'Scancode Map' -PropertyType Binary -Value $LeftWinToF13 | Out-Null
    Write-Host 'left Win -> F13 — reboot for it to take effect'
}
