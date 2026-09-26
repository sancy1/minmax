# =====================================================================
# FILE: build\04-Build.ps1
# PURPOSE: Full release build for MinMax. Produces ONE self-contained,
#          single-file MinMax.exe with the icon dynamically resolved
#          from assets\, the version pulled from build\version.txt,
#          and everything compressed + ReadyToRun for fast startup.
#          PATH-INDEPENDENT: works on any machine or CI runner because
#          the project root is derived from this script's own location.
# RELATES TO:
#   - build\version.txt        : single source of truth for the version
#   - assets\*.ico             : dynamic icon resolution (priority below)
#   - src\MinMax\MinMax.csproj : the project being published
#   - dist\ (output)           : final shipping artifact goes here
#
# ICON RESOLUTION PRIORITY:
#   1) assets\logo.ico
#   2) assets\app.ico
#   3) any *.ico in assets\
# Only ONE icon is embedded at build time.
# =====================================================================

$ErrorActionPreference = 'Stop'

# ---------------------------- CONFIG --------------------------------
# The project root is the PARENT of this script's folder.
# This script lives at  <root>\build\04-Build.ps1
# So $PSScriptRoot is       <root>\build
# And Split-Path -Parent gives <root>
# Works locally AND on GitHub Actions runners with no changes.
$root        = Split-Path -Parent $PSScriptRoot
$projectDir  = Join-Path $root 'src\MinMax'
$csproj      = Join-Path $projectDir 'MinMax.csproj'
$assetsDir   = Join-Path $root 'assets'
$versionFile = Join-Path $root 'build\version.txt'
$distDir     = Join-Path $root 'dist'
# --------------------------------------------------------------------

Write-Host "=== MinMax Release Build ===" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# STEP 1 - Read version.
# ---------------------------------------------------------------------
if (-not (Test-Path $versionFile)) { throw "Missing version file: $versionFile" }
$version = (Get-Content $versionFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($version)) { throw "version.txt is empty." }
Write-Host "[1/4] Version: $version" -ForegroundColor Green

# ---------------------------------------------------------------------
# STEP 2 - Resolve icon dynamically (priority order).
# ---------------------------------------------------------------------
$iconPath = $null
$candidates = @(
    (Join-Path $assetsDir 'logo.ico'),
    (Join-Path $assetsDir 'app.ico')
)
foreach ($c in $candidates) {
    if (Test-Path $c) { $iconPath = $c; break }
}
if (-not $iconPath) {
    $anyIco = Get-ChildItem -Path $assetsDir -Filter *.ico -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($anyIco) { $iconPath = $anyIco.FullName }
}
if (-not $iconPath) { throw "No .ico found in $assetsDir. Run setup\02-Create-Assets.ps1." }
Write-Host "[2/4] Icon resolved: $iconPath" -ForegroundColor Green

# ---------------------------------------------------------------------
# STEP 3 - Clean previous dist output.
# ---------------------------------------------------------------------
if (Test-Path $distDir) {
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir -Force | Out-Null
Write-Host "[3/4] Cleaned dist\ and ready to publish." -ForegroundColor Green

# ---------------------------------------------------------------------
# STEP 4 - Publish self-contained, single-file, compressed, R2R.
#          Passes the icon and version via MSBuild properties so the
#          csproj does not need to be edited per build.
# ---------------------------------------------------------------------
Write-Host "[4/4] Publishing..." -ForegroundColor Yellow

Set-Location $projectDir

$publishArgs = @(
    'publish',
    $csproj,
    '-c', 'Release',
    '-r', 'win-x64',
    '--self-contained', 'true',
    '-o', $distDir,
    '--nologo',
    "/p:PublishSingleFile=true",
    "/p:PublishReadyToRun=true",
    "/p:EnableCompressionInSingleFile=true",
    "/p:IncludeNativeLibrariesForSelfExtract=true",
    "/p:DebugType=None",
    "/p:DebugSymbols=false",
    "/p:Version=$version",
    "/p:FileVersion=$version",
    "/p:AssemblyVersion=$version",
    "/p:ApplicationIcon=$iconPath"
)

& dotnet @publishArgs
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed." }

# ---------------------------------------------------------------------
# Report the final artifact.
# ---------------------------------------------------------------------
$exe = Join-Path $distDir 'MinMax.exe'
if (-not (Test-Path $exe)) { throw "Publish finished but MinMax.exe not found in $distDir." }

$sizeMB = [math]::Round((Get-Item $exe).Length / 1MB, 2)
Write-Host ""
Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Green
Write-Host "Version : $version" -ForegroundColor Green
Write-Host "Icon    : $iconPath" -ForegroundColor Green
Write-Host "Exe     : $exe" -ForegroundColor Green
Write-Host "Size    : $sizeMB MB" -ForegroundColor Green
# END OF SCRIPT
