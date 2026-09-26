<!--
=====================================================================
FILE: C:\Users\HP\Desktop\minmax\README.md
PURPOSE: Project README shown on GitHub. Explains what MinMax is,
         how to install, and how to build from source.
RELATES TO: build\04-Build.ps1 (build instructions),
            .github\workflows\release.yml (release pipeline).
=====================================================================
-->

# MinMax

A tiny Windows utility that toggles the desktop from the taskbar.

Click once  ->  all open windows minimize, desktop is shown.
Click again ->  all previously minimized windows restore.

No settings. No UI. No tray icon. Just a toggle.

---

## Install (for end users)

1. Go to the [Releases](../../releases) page.
2. Download the latest `MinMax.exe`.
3. Place it anywhere on your PC (e.g., `C:\Tools\MinMax.exe`).
4. Right-click the file -> **Pin to taskbar**.

> No installer. No .NET runtime required. One file.

---

## Behavior

- Left-click the pinned icon -> toggle desktop.
- The same call as the built-in "Show Desktop" button on the Windows taskbar.
- Windows itself remembers which windows were minimized, so restoring is exact.

---

## Build from source

Requires the .NET SDK (10 or later) and Git.

```powershell
# 1. Clone
git clone https://github.com/<you>/minmax.git
cd minmax

# 2. Bump the version if you want
#    edit build\version.txt

# 3. Build the release exe
powershell -ExecutionPolicy Bypass -File build\04-Build.ps1
```

The final artifact appears at dist\MinMax.exe.

---

## How releases work

Pushing a git tag like `v1.0.0` triggers the GitHub Actions workflow in
`.github/workflows/release.yml`. That workflow:

1. Checks out the code.
2. Runs `build\04-Build.ps1`.
3. Attaches `MinMax.exe` to a new GitHub Release.

The version in `build\version.txt` is what lands in the exe metadata.

---

## License

MIT (adjust as needed).
