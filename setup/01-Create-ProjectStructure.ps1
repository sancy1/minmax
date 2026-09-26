# =====================================================================
# FILE: C:\Users\HP\Desktop\minmax\setup\01-Create-ProjectStructure.ps1
# PURPOSE: Creates the entire folder tree for minmax so every later
#          script writes into a known location. Idempotent - safe to
#          run many times without breaking anything.
# RELATES TO: 00-Check-Prerequisites.ps1 (must run first).
#             Consumed by 02-Create-Assets.ps1 and 03-Verify-Setup.ps1.
# =====================================================================

$ErrorActionPreference = 'Stop'

# Root of the whole solution (as specified by the user).
$root = 'C:\Users\HP\Desktop\minmax'

# Every folder we need, in creation order.
$folders = @(
    "$root\setup",                 # PowerShell setup scripts
    "$root\src",                   # source code container
    "$root\src\ToggleDesk",        # the .NET project folder
    "$root\assets",                # icon / logo files (png, ico)
    "$root\build",                 # build + publish scripts
    "$root\.github\workflows"      # GitHub Actions (added later)
)

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f -Force | Out-Null
        Write-Host "[CREATED] $f" -ForegroundColor Green
    } else {
        Write-Host "[EXISTS ] $f" -ForegroundColor DarkGray
    }
}

Write-Host "`nProject structure ready at $root" -ForegroundColor Cyan
# END OF SCRIPT
