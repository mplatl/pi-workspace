---
name: bc-linux-setup
description: Business Central development setup on Linux with BcContainerHelper. Covers Linux-specific workarounds (sudo wrapper for altool), artifact download, AL compilation with alc, and SaaS sandbox deployment via Dev Endpoint. Use this skill for any BC/Linux toolchain issues, BcContainerHelper errors on Linux, or deployment pipeline configuration on Linux hosts.
---

# BC Linux Setup — BcContainerHelper unter Linux

BcContainerHelper läuft auf Linux **eingeschränkt** — das Ausführen von BC Docker-Containern (Windows-basiert) ist nicht möglich, aber der gesamte Compile- und Deploy-Workflow für SaaS-Sandboxen funktioniert.

## Quick Reference

| Aufgabe | Befehl |
|---------|--------|
| Artifact-URL holen | `Get-BCArtifactUrl -type sandbox -country at -select latest` |
| Artifacts downloaden | `Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/` |
| Kompilieren | `alc` (automatisch von BcContainerHelper installiert) |
| Deployen (SaaS Sandbox) | Device-Login + `Publish-PerTenantExtensionApps` |
| Deployen (lokaler Container) | `curl` → Dev Endpoint `:7049/BC/dev/apps` |
| pwsh-Start | `/home/michael/powershell/pwsh -NoProfile` |
| sudo-Workaround | `PATH="/home/michael/.local/bin:$PATH" pwsh ...` |

## 1. Voraussetzungen

- BcContainerHelper (`6.1.14`) installiert unter `~/.local/share/powershell/Modules/BcContainerHelper/6.1.14/`
- AL Compiler (`alc`) — von BcContainerHelper automatisch installiert unter `~/.bccontainerhelper/`
- S2S-App-Registrierung mit Zugriff auf BC Automation API (für Deployment in SaaS-Sandbox)
- `sudo`-Wrapper unter `/home/michael/.local/bin/sudo`

## 2. Linux-Spezifische Workarounds

### `sudo chmod` auf `altool` umgehen

BcContainerHelper ruft auf Linux bei `Get-AppJsonFromAppFile` / `RunAlTool` immer `sudo chmod +x` auf den altool-Binary auf:

```powershell
# HelperFunctions.ps1 / GetAppInfo:
if (Test-Path $command) {
    & /usr/bin/env sudo pwsh -command "& chmod +x $command"
    $alToolExists = $true
}
```

Der Binary unter `~/.bccontainerhelper/alLanguageExtension/*/extension/bin/linux/altool` hat bereits `-rwxr-xr-x`, aber ohne passwortloses sudo schlägt der Aufruf fehl.

**Workaround:** Ein lokaler sudo-Wrapper, der `exit 0` zurückgibt:

```bash
cat > /home/michael/.local/bin/sudo << 'EOF'
#!/bin/bash
exit 0
EOF
chmod +x /home/michael/.local/bin/sudo
```

Vor **jedem** pwsh-Aufruf muss der PATH angepasst werden:

```bash
PATH="/home/michael/.local/bin:$PATH" pwsh ...
```

## 3. BC Artifacts & BcContainerHelper

> **⚠️ Hinweis:** Der `Get-BCArtifactUrl`-Aufruf für OnPrem kann gelegentlich mit einem JSON-Parse-Fehler (`ConvertFrom-Json`, `HelperFunctions.ps1:1756`) fehlschlagen, wenn Microsofts CDN eine fehlerhafte `platform.json` ausliefert. Dies ist transient — einfach erneut versuchen oder auf Sandbox-Artifacts ausweichen.

### Get-BCArtifactUrl

```powershell
# Sandbox (SaaS)
Get-BCArtifactUrl -type sandbox -country at -version 28 -select all
Get-BCArtifactUrl -type sandbox -country at -select latest

# OnPrem
Get-BCArtifactUrl -type onprem -country at -version 28 -select all
Get-BCArtifactUrl -type onprem -country at -select latest

# Insider (nächste Version)
Get-BCArtifactUrl -type sandbox -country at -select nextminor -accept_insiderEula
Get-BCArtifactUrl -type sandbox -country at -select nextmajor -accept_insiderEula

# Aktuelle Version
Get-BCArtifactUrl -type sandbox -country at -select current

# Nächstliegende Version zu einer Buildnummer
Get-BCArtifactUrl -type sandbox -country at -version 28.0.46665.0 -select closest
```

| Parameter | Werte |
|-----------|-------|
| `-type` | `Sandbox`, `OnPrem` |
| `-country` | `at`, `de`, `w1`, `us`, … |
| `-version` | `28`, `28.0`, `28.0.46665.0`, … (Präfix-Suche) |
| `-select` | `All`, `Latest`, `Closest`, `Current`, `NextMinor`, `NextMajor`, `Daily`, `Weekly` |

### pwsh starten

```bash
/home/michael/powershell/pwsh -NoProfile -Command 'Import-Module BcContainerHelper; Get-BCArtifactUrl -type sandbox -country at -select latest'
```

### Download-Artifacts

```powershell
# OnPrem (651 MB Applications + 772 MB database)
$url = Get-BCArtifactUrl -type onprem -country at -version 28 -select Latest
Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/

# Sandbox (ca. 1 GB gepackt, ca. 5-8 GB entpackt)
$url = Get-BCArtifactUrl -type sandbox -country at -select Latest
Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/

# Mit Platform (enthält System.app, ModernDev, ServiceTier-DLLs)
$paths = Download-Artifacts -artifactUrl $url -includePlatform
# $paths[0] = App-Artifact-Pfad, $paths[1] = Platform-Artifact-Pfad

# Force re-download
Download-Artifacts -artifactUrl $url -basePath ~/Dokumente/development/ai/ -force
```

| Parameter | Beschreibung |
|-----------|-------------|
| `-artifactUrl` | URL von `Get-BCArtifactUrl` |
| `-basePath` | Zielverzeichnis (Standard: `~/bcartifacts.cache`) |
| `-includePlatform` | Lädt auch Platform (System.app, ModernDev, DLLs) |
| `-force` | Erzwingt Neu-Download trotz vorhandenem Cache |
| `-timeout` | Timeout in Sekunden pro Download |

**Ergebnisstruktur** (unter `basePath/onprem/<version>/<country>/`):

```
Applications/          # Alle .app-Dateien + .Source.zip (Source + Test)
  Application/Source/Microsoft_Application.app
  Application/Source/Application.Source.zip
  BaseApp/Source/Microsoft_Base Application.app
  ...
database/              # BC-Datenbank-Backup (.bak)
manifest.json          # Versions-Manifest
lastused               # Cache-Timestamp
```

### Source-Extraktion

```bash
cd ~/Dokumente/development/ai/bc
./extract_sources.sh ~/Dokumente/development/ai/onprem
```

## 4. Compile & Deployment

### Deployment (vollautomatisch, zero user interaction)

```bash
cd /home/michael/Dokumente/development/BCPurchaseRequest
PATH="/home/michael/.local/bin:$PATH" pwsh -NoProfile -File ./Publish-BPR.ps1 -Environment Sandbox
```

**Ablauf:**
1. Build-Nummer in `app.json` verringern (Versionskonflikt vermeiden)
2. App mit `alc` kompilieren
3. Device-Login (`New-BcAuthContext -IncludeDeviceLogin`) — Browser öffnen, Code eingeben
4. App mit `Publish-PerTenantExtensionApps` deployen

### Deployment in lokalen BC Container (Linux)

Für den lokalen BC-on-Linux Container (`msdyn365bconlinux`) wird der **Dev Endpoint** auf Port 7049 verwendet:

```bash
# Container starten (falls nicht bereits aktiv)
cd ~/Dokumente/development/MsDyn365Bc.On.Linux
docker compose up -d

# Healthcheck abwarten
./scripts/wait-for-bc-healthy.sh

# App publizieren
curl -u BCRUNNER:Admin123! \
  -X POST \
  -F "file=@<app-file.app>;type=application/octet-stream" \
  "http://localhost:7049/BC/dev/apps?SchemaUpdateMode=forcesync"
```

**Ergebnisse:**
- **HTTP 200** → App erfolgreich installiert
- **HTTP 422** mit `"already"` im Body → App bereits installiert (kein Fehler)
- **HTTP 422** ohne `"already"` → Fehler (z.B. fehlende Abhängigkeit, Schema-Konflikt)

**Container-Details:**

| Eigenschaft | Wert |
|---|---|
| Projekt | `~/Dokumente/development/MsDyn365Bc.On.Linux/` |
| Container | `msdyn365bconlinux-bc-1` |
| Dev Port | 7049 |
| OData Port | 7048 |
| Benutzer | `BCRUNNER` / `Admin123!` |
| Publizierte Apps prüfen | `curl -u BCRUNNER:Admin123! "http://localhost:7049/BC/dev/apps"` |

## 5. Dev Endpoint vs. Automation API

Für Sandbox-Umgebungen den **Dev Endpoint** verwenden:

```powershell
# ✅ RICHTIG für Sandbox:
Publish-BcContainerApp -bcAuthContext $auth -environment Sandbox `
    -appFile $appFile -useDevEndpoint -checkAlreadyInstalled -excludeRuntimePackages

# ❌ FALSCH für Sandbox (Automation API):
Publish-PerTenantExtensionApps -bcAuthContext $auth -environment Sandbox -appFiles @($appFile)
```

Der Dev Endpoint erlaubt mehrfaches Deployment derselben Version ohne Versions-Bump.

## 6. Deployment-Status bei Fehlern prüfen

```powershell
$headers = @{ "Authorization" = "Bearer $($auth.AccessToken)" }
$apiUrl = "$($bcContainerHelperConfig.apiBaseUrl)/v2.0/$env/api/microsoft/automation/v2.0"
$companies = Invoke-RestMethod -Headers $headers -Uri "$apiUrl/companies"
$companyId = $companies.value[0].id
$status = Invoke-WebRequest -Headers $headers `
    -Uri "$apiUrl/companies($companyId)/extensionDeploymentStatus"
($status.Content | ConvertFrom-Json).value | Where-Object Name -like "*Hello*"
```

## 7. ID-Range-Konflikte vermeiden

BC lehnt Apps ab, die Objekt-IDs verwenden, die bereits von anderen installierten Apps belegt sind.

> *The application object of type 'Table' with the ID '50102' is defined in multiple apps.*

**Vor dem Deployment prüfen:**

```powershell
$apps = Get-BcInstalledExtensions -bcAuthContext $auth -environment Sandbox `
    | Where-Object { $_.Scope -eq 'PTE' -or $_.Scope -eq 'Dev' }
```

PTE-Apps (Per-Tenant-Extension) dürfen IDs zwischen 50000–99999 verwenden.

## 8. Tenant-Informationen

| Feld | Wert |
|------|------|
| **Organisation** | Contoso |
| **Tenant ID** | `ead083dd-f7cb-4a4f-9016-9dca1135a9d3` |
| **Domain** | `M365x83021272.onmicrosoft.com` |
| **Admin** | `admin@M365x83021272.onmicrosoft.com` |
| **Typ** | Microsoft 365 Developer Tenant |

### App-Registrierung

| Feld | Wert |
|------|------|
| **Name** | BC-Automation-PI |
| **Client ID** | `ad9c1ff5-dcbb-4852-b4bc-b21df9a64b1f` |
| **Tenant ID** | `ead083dd-f7cb-4a4f-9016-9dca1135a9d3` |

Client Secret steht in `.env`.

## 9. Authentifizierung (Client Credentials)

```bash
ACCESS_TOKEN=$(curl -s -X POST "https://login.microsoftonline.com/ead083dd-f7cb-4a4f-9016-9dca1135a9d3/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=ad9c1ff5-dcbb-4852-b4bc-b21df9a64b1f" \
  -d "client_secret=<CLIENT_SECRET>" \
  -d "scope=https://graph.microsoft.com/.default" \
  -d "grant_type=client_credentials" | jq -r '.access_token')
```
