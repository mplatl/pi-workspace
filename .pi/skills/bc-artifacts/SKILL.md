---
name: bc-artifacts
description: >
  Download and extract Business Central artifacts (apps and platform) for
  on-premise and sandbox environments. USE FOR: "download BC artifacts",
  "get BC app source", "extract BC sources", "BC artifact URL", "BcContainerHelper",
  or when needing Microsoft base app source code for reference.
---

# Business Central Artifacts

Download BC artifacts and extract AL source code from Microsoft base apps and platform.

## Prerequisites

BcContainerHelper PowerShell module at:
`/home/michael/.local/share/powershell/Modules/BcContainerHelper/6.1.14/`

## Getting Artifact URLs

Use `Get-BCArtifactUrl` to discover available builds:

```powershell
# Sandbox (SaaS) — recommended for app source
Get-BCArtifactUrl -type sandbox -country at -version 28 -select all
Get-BCArtifactUrl -type sandbox -country at -select latest

# OnPrem
Get-BCArtifactUrl -type onprem -country at -version 28 -select latest
Get-BCArtifactUrl -type onprem -country at -version 28 -select all

# Insider (next version)
Get-BCArtifactUrl -type sandbox -country at -select nextminor -accept_insiderEula

# Current version
Get-BCArtifactUrl -type sandbox -country at -select current

# Closest to a specific build
Get-BCArtifactUrl -type sandbox -country at -version 28.0.46665.0 -select closest
```

**Parameters:**

| Parameter   | Values                                                              |
|-------------|---------------------------------------------------------------------|
| `-type`     | `Sandbox`, `OnPrem`                                                 |
| `-country`  | `at`, `de`, `w1`, `us`, …                                           |
| `-version`  | `28`, `28.0`, `28.0.46665.0` (prefix search)                       |
| `-select`   | `All`, `Latest`, `Closest`, `Current`, `NextMinor`, `NextMajor`, `Daily`, `Weekly` |

## Running PowerShell Commands

Always use the local pwsh binary with these flags:

```bash
/home/michael/powershell/pwsh -NoProfile -Command 'Import-Module BcContainerHelper; <command>'
```

Example:

```bash
/home/michael/powershell/pwsh -NoProfile -Command 'Import-Module BcContainerHelper; Get-BCArtifactUrl -type sandbox -country at -select latest'
```

## Downloading Artifacts

`Download-Artifacts` downloads and extracts artifacts to a local cache.

```powershell
# Sandbox (approx. 5-8 GB extracted)
$url = Get-BCArtifactUrl -type sandbox -country at -select latest
Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/

# With platform (System.app, ModernDev, ServiceTier DLLs)
$paths = Download-Artifacts -artifactUrl $url -includePlatform
# $paths[0] = app artifact path, $paths[1] = platform artifact path

# Force re-download
Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/ -force
```

**Parameters:**

| Parameter            | Description                                        |
|----------------------|----------------------------------------------------|
| `-artifactUrl`       | URL from `Get-BCArtifactUrl`                       |
| `-basePath`          | Target directory (default: `~/bcartifacts.cache`)  |
| `-includePlatform`   | Also download platform (System.app, DLLs)          |
| `-force`             | Force re-download despite cache                    |
| `-timeout`           | Timeout in seconds per download                    |

## Output Structure

After download under `basePath/onprem/<version>/<country>/`:

```
Applications/                     # All .app files + .Source.zip
  Application/Source/
    Microsoft_Application.app
    Application.Source.zip
  BaseApp/Source/
    Microsoft_Base Application.app
    BaseApp.Source.zip
  ...
database/                         # BC database backup (.bak)
manifest.json                     # Version manifest
lastused                          # Cache timestamp
```

## Extracting AL Source Code

After download, each app folder contains `.app` and `.Source.zip` files. Use the extraction script to unpack all source code and remove archives:

```bash
cd ~/Dokumente/development/ai/bc
./extract_sources.sh ~/Dokumente/development/ai
```

This extracts all `.Source.zip` files and removes `.zip` and `.app` files — only AL source code remains.
