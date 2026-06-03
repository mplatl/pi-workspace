---
name: bc-development
description: Business Central AL development workflow. Compile AL code with alc.exe or BcContainerHelper, run tests, publish apps, download BC artifacts/symbols, and manage versioned builds. Use this skill when working with AL files (.al), app.json, launch.json, or any BC extension development, deployment, or CI/CD task.
---

# Business Central AL Development

Full development lifecycle for Microsoft Dynamics 365 Business Central extensions in AL.

## Quick Reference

| Task | Command / Approach |
|------|--------------------|
| Compile | `alc.exe /project:"." /packagecachepath:".alpackages"` or `Compile-AppInBcContainer` |
| Publish | `Publish-NavContainerApp` or `Publish-BcContainerApp` |
| Test | `Run-TestsInBcContainer` or alc test runner |
| Download symbols | `Download-Artifacts` / `Get-BCArtifactUrl` |
| Index version in Qdrant | Use the `bc-rag-indexing` skill for full workflow |

## 1. Compiling AL Code

### Local compilation with alc.exe
```powershell
# Find alc.exe from installed BC artifact
$alcPath = Join-Path $bcContainerHelperConfig.hostHelperFolder "..\alc.exe"

& $alcPath `
  /project:"C:\path\to\project" `
  /packagecachepath:"C:\path\to\.alpackages" `
  /out:"C:\path\to\output" `
  /symbolfile:"C:\path\to\symbols" `
  /reportProgress
```

### Container-based compilation
```powershell
Compile-AppInBcContainer `
  -containerName "bc-sandbox" `
  -appProjectFolder "C:\src\MyApp" `
  -appSymbolsFolder "C:\src\symbols" `
  -appOutputFolder "C:\src\output"
```

### Troubleshooting compilation
- **Missing symbols**: Run `Download-Artifacts` first to fetch dependencies.
- **AL1042**: App ID already exists in scope — check `app.json` `id` range and uniqueness.
- **AL0433**: Method not found — ensure symbols match target BC version.
- **AL1045**: Package cache outdated — clear `.alpackages` and re-download.

## 2. Publishing Apps

### Publish to BC container
```powershell
Publish-NavContainerApp `
  -containerName "bc-sandbox" `
  -appFile "C:\src\output\MyApp_MainApp_1.0.0.0.app" `
  -skipVerification `
  -sync `
  -install
```

### Publish to SaaS sandbox
```powershell
Publish-BcContainerApp `
  -bcContainer "bc-sandbox" `
  -appFile "output.app" `
  -tenant "default"
```

### Publish-NAVApp (legacy on-prem)
```powershell
Publish-NAVApp `
  -ServerInstance BC `
  -Path "MyApp.app" `
  -SkipVerification
```

## 3. Testing

### Run automated tests in container
```powershell
$testResults = Run-TestsInBcContainer `
  -containerName "bc-sandbox" `
  -tenant "default" `
  -extensionId "12345678-1234-1234-1234-123456789012" `
  -detailed

# Check results
$testResults | Where-Object { $_.result -ne "Success" }
```

### Test best practices
- Name test codeunits with suffix `Test` (e.g., `SalesTest`).
- Use `[Test]` attribute with `[HandlerFunctions]` for setup/teardown.
- Test with `RecordRef`, `FieldRef` for erp table isolation.
- Run isolate tests per feature; avoid cross-module dependencies.
- Always test in a dedicated sandbox container, never in production.

## 4. Downloading Artifacts & Symbols

### Get artifact URL
```powershell
$artifactUrl = Get-BCArtifactUrl `
  -country "de" `
  -version "24" `
  -select "Latest" `
  -type "Sandbox"
```

### Download artifacts
```powershell
$folders = Download-Artifacts `
  -artifactUrl $artifactUrl `
  -includePlatform

# Paths returned:
# $folders[0] - App artifacts (symbols, DLLs)
# $folders[1] - Platform (alc.exe, etc.)
```

### Get all available versions for indexing
```powershell
Get-BCArtifactUrl `
  -country "de" `
  -version "*" `
  -select "All" |
  ForEach-Object { Write-Host "Version: $($_.Split('/')[-1])" }
```

## 5. AL Project Structure Conventions

```
MyApp/
├── app.json                  # App manifest (id, name, version, dependencies)
├── launch.json               # Debug/launch config
├── .alpackages/              # Downloaded symbols (gitignore this)
├── src/
│   ├── Pages/
│   ├── Tables/
│   ├── Codeunits/
│   ├── Reports/
│   └── XmlPorts/
└── test/
    └── Codeunits/            # Test codeunits
```

### app.json best practice
```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "name": "My App",
  "publisher": "My Company",
  "version": "1.0.0.0",
  "brief": "Does something useful",
  "description": "Longer description",
  "privacyStatement": "",
  "EULA": "",
  "help": "",
  "url": "",
  "logo": "",
  "dependencies": [],
  "screenshots": [],
  "platform": "24.0.0.0",
  "application": "24.0.0.0",
  "idRanges": [
    { "from": 50100, "to": 50149 }
  ],
  "contextSensitiveHelpUrl": "",
  "runtime": "14.0",
  "features": ["TranslationFile"],
  "target": "Cloud"
}
```

## 6. AL Coding Best Practices

- **Avoid `OnBeforeDelete`/`OnAfterDelete` side effects** — use events externally.
- **Use `Enum` instead of `Option`** for all new fields.
- **Isolate business logic in codeunits**, keep pages/table extensions thin.
- **Use `Record.LockTable()`** before modifying to avoid write conflicts.
- **`Error(...)` over `Message(...)`** for validation failures; use `TestField()` for field checks.
- **Avoid `CurrPage` in codeunits** unless it's a page-bound codeunit.
- **Follow the standard naming convention**: `<Action><Object>` (e.g., `PostSalesInvoice`).
- **Use `Isolated` storage for temp tables**, explicitly scope data.
- **`ModifyAll` / `DeleteAll`** with filters instead of looping large sets.
- **Prefer `RecordRef`/`FieldRef`** for generic code; keep typed records for known tables.
- **Always document procedures** with `///` XML comments.
- **Use `.gitignore`** for `.alpackages/`, `.vscode/` (selective), `*.app`, and output folders.

## 7. Building & CI/CD Integration

### Simple build script (PowerShell)
```powershell
param([string]$Version = "1.0.0.0")

# Update version in app.json
$appJson = Get-Content "app.json" -Raw | ConvertFrom-Json
$appJson.version = $Version
$appJson | ConvertTo-Json -Depth 10 | Set-Content "app.json"

# Compile
Compile-AppInBcContainer `
  -containerName $env:BC_CONTAINER `
  -appProjectFolder $PSScriptRoot `
  -appOutputFolder "$PSScriptRoot/output"

Write-Host "Build complete: $PSScriptRoot/output/*.app"
```

### Index version in Qdrant (post-build)
After building, index the artifacts + source using the `bc-rag-indexing` skill:
```bash
# Use pi to index the BC artifacts for version-aware search
pi --skill bc-rag-indexing
```
This creates/updates a Qdrant collection named `bc-{version}` with AL source, compiled app metadata, and symbols enabling semantic + BM25 search across BC versions.
