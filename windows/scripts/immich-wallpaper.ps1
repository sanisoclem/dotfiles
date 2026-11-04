#Requires -Version 7
#
# immich-wallpaper — cachyos/scripts/immich-wallpaper for Windows: pull 5 cats
# and 5 landscapes via immich's smart (CLIP) search, replace the previous pool
# with them, and set one at random. Run daily by the immich-wallpaper scheduled
# task, and by F15 (autohotkey/hotkeys.ahk).
#
# The api key lives outside the repo, at %LOCALAPPDATA%\immich-wallpaper\api-key;
# scripts-manual/setup.ps1 asks for it.

$ErrorActionPreference = 'Stop'

$ImmichUrl = $env:IMMICH_URL ?? 'https://photos.131broadway.place'
$KeyFile = Join-Path $env:LOCALAPPDATA 'immich-wallpaper\api-key'
$DestDir = $env:WALLPAPER_DIR ?? (Join-Path ([Environment]::GetFolderPath('MyPictures')) 'wallpapers')

$Wanted = @(
    @{ Count = 5; Query = 'cat' }
    @{ Count = 5; Query = 'landscape' }
)

$PoolSize = 60 # fetched per query, then shuffled — keeps day-to-day variety
$MinWidth = 1920

# A key copied out of a coloured terminal can carry ANSI escape sequences, and ESC
# is illegal in an HTTP header: every request then fails with a bare 400.
function Read-ApiKey {
    if (-not (Test-Path $KeyFile)) { throw "no api key at $KeyFile — run scripts-manual/setup.ps1" }
    $key = (Get-Content -Raw $KeyFile) -replace '\x1b\[[0-9;]*[A-Za-z]', '' -replace '[\p{Cc}\s]', ''
    if (-not $key) { throw "$KeyFile is empty once cleaned of control characters" }
    $key
}

function Find-Wallpaper($Query, $Count) {
    $search = @{ query = $Query; size = $PoolSize; type = 'IMAGE'; withExif = $true; visibility = 'timeline' }
    $assets = (Invoke-RestMethod -Method Post -Uri "$ImmichUrl/api/search/smart" -Headers $Headers `
            -ContentType 'application/json' -Body ($search | ConvertTo-Json) `
            -TimeoutSec 60 -MaximumRetryCount 3 -RetryIntervalSec 5).assets.items

    $landscape = @($assets | Where-Object { $_.exifInfo.exifImageWidth -ge ($_.exifInfo.exifImageHeight ?? 0) })
    $sharp = @($landscape | Where-Object { $_.exifInfo.exifImageWidth -ge $MinWidth })
    ($sharp.Count ? $sharp : $landscape) | Get-Random -Count $Count
}

# Windows only takes jpeg/png/bmp as a wallpaper, so anything else (HEIC off a
# phone, RAW off a camera, webp) is converted rather than set unreadable.
function Save-Wallpaper($Asset, $Query) {
    $native = $Asset.originalMimeType -in 'image/jpeg', 'image/png'
    $ext = $native ? [IO.Path]::GetExtension($Asset.originalFileName).ToLowerInvariant() : '.jpg'
    $dest = Join-Path $DestDir "immich-$($Asset.id)$ext"

    if (Test-Path $dest) {
        Write-Host "have    ${Query}: $($Asset.originalFileName)"
        return $dest
    }

    Write-Host "fetch   ${Query}: $($Asset.originalFileName)"
    $tmp = Join-Path $DestDir ".immich-$([guid]::NewGuid())"
    try {
        Invoke-WebRequest -Uri "$ImmichUrl/api/assets/$($Asset.id)/original" -Headers $Headers -OutFile $tmp `
            -TimeoutSec 120 -MaximumRetryCount 3 -RetryIntervalSec 5
        if ($native) {
            Move-Item $tmp $dest
        } else {
            Write-Host "  converting $($Asset.originalMimeType) -> jpeg"
            magick $tmp -quality 95 $dest
            if ($LASTEXITCODE) { throw "magick exited $LASTEXITCODE" }
        }
        $dest
    } catch {
        Write-Warning "  $($Asset.originalFileName) skipped: $_"
    } finally {
        Remove-Item $tmp -ErrorAction Ignore
    }
}

function Remove-StaleWallpaper($Keep) {
    $stale = @(Get-ChildItem $DestDir -Filter 'immich-*' -File | Where-Object FullName -NotIn $Keep)
    $stale | Remove-Item
    $stale.Count
}

function Set-Wallpaper($Path) {
    Add-Type -Namespace Win32 -Name Desktop -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, string path, uint flags);
'@
    $SPI_SETDESKWALLPAPER = 0x14
    $SPIF_UPDATEINIFILE_SENDCHANGE = 3
    $FILL = '10'

    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value $FILL
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    if (-not [Win32.Desktop]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Path, $SPIF_UPDATEINIFILE_SENDCHANGE)) {
        throw "SystemParametersInfo refused $Path"
    }
}

$Headers = @{ 'x-api-key' = Read-ApiKey }
New-Item -ItemType Directory -Force $DestDir | Out-Null

$keep = @(
    foreach ($want in $Wanted) {
        $found = @(Find-Wallpaper $want.Query $want.Count)
        if (-not $found) { Write-Warning "no results for '$($want.Query)'" }
        foreach ($asset in $found) { Save-Wallpaper $asset $want.Query }
    }
) | Where-Object { $_ }

if (-not $keep) { throw 'nothing downloaded — leaving the current pool alone' }

$removed = Remove-StaleWallpaper $keep
$pick = $keep | Get-Random
Set-Wallpaper $pick

Write-Host "pool: $(@($keep).Count) wallpapers, $removed removed"
Write-Host "set:  $pick"
