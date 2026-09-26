# =====================================================================
# FILE: C:\Users\HP\Desktop\minmax\setup\00-Check-Prerequisites.ps1
# PURPOSE: Verify the developer machine has required tooling
#          (.NET SDK, Git) before we create any project files.
#          This is the FIRST script to run.
# RELATES TO: 01, 02, 03 - all later setup scripts assume this passed.
# =====================================================================

$ErrorActionPreference = 'Stop'

Write-Host "=== minmax Prerequisite Check ===" -ForegroundColor Cyan

# ---------------------------------------------------------------------
# FUNCTION: Test-DotNetSdk
# WHAT: Confirms the .NET SDK is installed and prints the version.
# WHY : We target net10.0-windows (user has SDK 10). Without the SDK
#       we cannot build.
# ---------------------------------------------------------------------
function Test-DotNetSdk {
    try {
        $ver = & dotnet --version
        Write-Host "[OK] .NET SDK version: $ver" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] .NET SDK not found. Install .NET SDK." -ForegroundColor Red
        return $false
    }
}

# ---------------------------------------------------------------------
# FUNCTION: Test-Git
# WHAT: Confirms Git is installed (needed later for GitHub release).
# WHY : We will not push yet, but Git must be ready.
# ---------------------------------------------------------------------
function Test-Git {
    try {
        $ver = & git --version
        Write-Host "[OK] $ver" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] Git not found. Install Git for Windows." -ForegroundColor Red
        return $false
    }
}

$dotnetOk = Test-DotNetSdk
$gitOk    = Test-Git

if (-not ($dotnetOk -and $gitOk)) {
    Write-Host "`nPrerequisites missing. Fix the [FAIL] items and re-run." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nAll prerequisites satisfied." -ForegroundColor Green
# END OF SCRIPT
