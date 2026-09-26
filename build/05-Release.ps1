# =====================================================================
# FILE: C:\Users\HP\Desktop\minmax\build\05-Release.ps1
# PURPOSE: Local fallback release helper. Runs 04-Build.ps1, then
#          zips dist\MinMax.exe into a versioned zip under
#          build\output\. Useful when you want to hand out a build
#          without touching GitHub.
# RELATES TO: build\04-Build.ps1 (called first), build\version.txt.
# =====================================================================

$ErrorActionPreference = 'Stop'

$root        = 'C:\Users\HP\Desktop\minmax'
$buildScript = Join-Path $root 'build\04-Build.ps1'
$versionFile = Join-Path $root 'build\version.txt'
$distExe     = Join-Path $root 'dist\MinMax.exe'
$outputDir   = Join-Path $root 'build\output'

Write-Host "=== MinMax Local Release ===" -ForegroundColor Cyan

# 1. Run the standard build.
& powershell -ExecutionPolicy Bypass -File $buildScript
if ($LASTEXITCODE -ne 0) { throw "Build failed." }

# 2. Read version.
$version = (Get-Content $versionFile -Raw).Trim()

# 3. Ensure output directory.
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# 4. Zip the artifact.
$zipPath = Join-Path $outputDir "MinMax-v$version-win-x64.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path $distExe -DestinationPath $zipPath -CompressionLevel Optimal

$sizeMB = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Host ""
Write-Host "=== RELEASE READY ===" -ForegroundColor Green
Write-Host "Version : $version" -ForegroundColor Green
Write-Host "Zip     : $zipPath" -ForegroundColor Green
Write-Host "Size    : $sizeMB MB" -ForegroundColor Green
# END OF SCRIPT
