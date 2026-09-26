# =====================================================================
# FILE: C:\Users\HP\Desktop\minmax\setup\02-Create-Assets.ps1
# PURPOSE: Ensures at least one .ico exists in assets\ so the build
#          never fails. If the user has not supplied an icon, this
#          script writes a minimal valid placeholder .ico.
#          DYNAMIC ICON RESOLUTION (used later by 04-Build.ps1):
#            1) assets\logo.ico
#            2) assets\app.ico
#            3) any *.ico in assets\
#          Only ONE icon is embedded at build time - whichever is
#          found first in the priority list above.
# RELATES TO: 04-Build.ps1 (reads whichever icon is present).
#             assets\app.ico is never overwritten if it already exists.
# =====================================================================

$ErrorActionPreference = 'Stop'

$assetsDir = 'C:\Users\HP\Desktop\minmax\assets'

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# ---------------------------------------------------------------------
# Check what already exists so we never overwrite the user's real icon.
# ---------------------------------------------------------------------
$existingIco = Get-ChildItem -Path $assetsDir -Filter *.ico -ErrorAction SilentlyContinue
$existingPng = Get-ChildItem -Path $assetsDir -Filter *.png -ErrorAction SilentlyContinue

if ($existingIco.Count -gt 0) {
    Write-Host "[OK] Found existing .ico: $($existingIco[0].FullName)" -ForegroundColor Green
} else {
    # Build a minimal valid 16x16 32bpp placeholder .ico.
    # Layout: ICONDIR(6) + ICONDIRENTRY(16) + BITMAPINFOHEADER(40) + pixels(1024)
    $icoPath = Join-Path $assetsDir 'app.ico'

    $icoBytes = [byte[]]@(
        0x00,0x00, 0x01,0x00, 0x01,0x00,                     # ICONDIR: reserved=0, type=1, count=1
        0x10,0x10, 0x00,0x00, 0x01,0x00, 0x20,0x00,          # entry: 16x16, 1 plane, 32bpp
        0x68,0x04,0x00,0x00, 0x16,0x00,0x00,0x00,            # bytes in resource=1128, offset=22
        0x28,0x00,0x00,0x00, 0x10,0x00,0x00,0x00,            # BITMAPINFOHEADER: size=40, width=16
        0x20,0x00,0x00,0x00, 0x01,0x00, 0x20,0x00,            # height=32, planes=1, bpp=32
        0x00,0x00,0x00,0x00, 0x40,0x04,0x00,0x00,            # compression=0, imageSize=1088
        0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,            # xPels=0, yPels=0
        0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00             # colorsUsed=0, important=0
    )
    # 16*16 pixels * 4 bytes each = 1024 bytes of transparent (zero) data.
    $pixels = New-Object byte[] 1024
    [System.IO.File]::WriteAllBytes($icoPath, ($icoBytes + $pixels))

    Write-Host "[NEW] Placeholder .ico written: $icoPath" -ForegroundColor Yellow
    Write-Host "      Replace with your real icon when ready." -ForegroundColor Yellow
}

if ($existingPng.Count -gt 0) {
    Write-Host "[OK] Found existing .png: $($existingPng[0].FullName)" -ForegroundColor Green
} else {
    Write-Host "[INFO] No .png found. App will use the .ico." -ForegroundColor DarkGray
}

Write-Host "`nAssets folder ready." -ForegroundColor Cyan
# END OF SCRIPT
