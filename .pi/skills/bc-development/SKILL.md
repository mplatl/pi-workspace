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
- **In Page-Feldern immer `Rec.`-Präfix verwenden** — direkte Feldnamen wie `SourceExpr = "My Field"` erzeugen AL0118. Stattdessen: `SourceExpr = Rec."My Field"`. Bei Feldern ohne Sonderzeichen: `Rec.MyField`. Dies gilt für alle Page-Typen (List, ListPart, Card, …) und sowohl im `repeater` als auch in `group`-Bereichen.
- **`ListPart` für Rollencenter-Einbettung** — Pages, die in ein RoleCenter eingebettet werden (AL0269), müssen `PageType = ListPart` (oder `CardPart`) sein, nicht `List`/`Card`.
- **Page-Element-Reihenfolge** — In Page-Objekten muss `actions` **vor** `trigger` stehen. Vertauschte Reihenfolge ergibt AL0104 (Syntax error). Gültige Reihenfolge: `properties` → `layout` → `actions` → `trigger` → `var`.
- **Use `.gitignore`** for `.alpackages/`, `.vscode/` (selective), `*.app`, and output folders.

## 7. Setup-Tabellen (Microsoft-Standard-Pattern)

Setup-Tabellen in Business Central sind **Singleton-Tabellen** — es gibt immer genau einen Datensatz pro App/Modul. Das Pattern stammt direkt aus Microsofts Base Application (z. B. `Sales & Receivables Setup`, `General Ledger Setup`).

### 7.1 Table-Definition

```al
table 70000 "BC Gen.IF Setup"
{
    Caption = 'BC Gen.IF Setup';
    DrillDownPageID = "BC Gen.IF Setup";   // Verlinkt Table → Page
    LookupPageID = "BC Gen.IF Setup";       // Für Lookup-Trigger
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
```

**Wichtige Eigenschaften:**

| Eigenschaft | Wert | Begründung |
|-------------|------|------------|
| `DrillDownPageID` | Setup-Page | Ermöglicht Sprung von Tabelle zur Einrichtungsseite |
| `LookupPageID` | Setup-Page | Für Lookup-Aktionen auf das Setup |
| `DataClassification` | `CustomerContent` | Wie Microsoft-Standard (Setup-Daten = Kundendaten) |
| `field(1)` | `"Primary Key"` Code[10] | Der eine Singleton-Schlüssel |

### 7.2 Page-Definition (Card)

```al
page 70002 "BC Gen.IF Setup"
{
    Caption = 'BC Gen.Interface Setup';
    PageType = Card;
    SourceTable = "BC Gen.IF Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    DeleteAllowed = false;      // Verhindert Löschen des Setup-Datensatzes
    InsertAllowed = false;      // Verhindert manuelles Einfügen

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                // Setup-Felder hier
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
```

**⚠️ Kritisch: `OnOpenPage()`-Pattern**

```al
// ✅ RICHTIG — Microsoft-Standard:
Rec.Reset();
if not Rec.Get() then begin
    Rec.Init();
    Rec.Insert();
end;

// ❌ FALSCH — kein Reset(), kein Init():
if not Rec.Get() then begin
    Rec."Primary Key" := 'MYAPP';
    Rec.Insert(true);
end;
```

`Rec.Reset()` löscht alle Filter und setzt den Record zurück. `Rec.Init()` initialisiert Felder mit Default-Werten. `Rec.Insert()` ohne Parameter ist der Standard.

### 7.3 Setup-Status prüfen

Ob Setup bereits ausgeführt wurde, prüft man mit `Get()` auf die Setup-Tabelle:

```al
local procedure CheckSetupDone(): Boolean
var
    Setup: Record "My Setup";
begin
    Setup.Reset();
    exit(Setup.Get());  // true = Setup existiert, false = noch nicht ausgeführt
end;
```

### 7.4 Headline mit Setup-Erinnerung

Typisches Muster: Headline-Part zeigt einen Link zur Setup-Seite, solange Setup noch nicht ausgeführt wurde.
Nach dem ersten Öffnen der Setup-Seite (→ `Rec.Insert()`) verschwindet die Erinnerung automatisch.

```al
page 70003 "My Headline"
{
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
            group(SetupHeadline)
            {
                Visible = SetupNotDoneVisible;
                field(SetupText; SetupNotDoneTxt)
                {
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"My Setup");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "My Setup";
    begin
        Setup.Reset();
        SetupNotDoneVisible := not Setup.Get();
    end;

    var
        SetupNotDoneVisible: Boolean;
        SetupNotDoneTxt: Label '<qualifier>Setup erforderlich</qualifier><payload>Bitte <emphasize>Setup ausführen</emphasize></payload>';
}
```

### 7.5 CueGroups — Kacheln im Rollencenter

CueGroups sind das Standard-Pattern für Status-Kacheln in BC-Rollencentern. Sie bestehen aus drei Komponenten:

1. **Cue-Tabelle** — Singleton mit FlowFields für Zähler
2. **Activities-Page** — CardPart mit `cuegroup`-Layout
3. **Role Center** — bindet die Activities-Page als `part` ein

#### 7.5.1 Cue-Tabelle

```al
table 70014 "My Cue"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Open Count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("My Entry Table" where(Status = const(Open)));
            Editable = false;
        }
        field(3; "Error Count"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("My Entry Table" where(Status = const(Error)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
```

**Regeln für Cue-Tabellen:**
- `FieldClass = FlowField` — die Werte werden vom Server berechnet, nicht gespeichert
- `Editable = false` — Kacheln sind nicht editierbar
- Singleton-Pattern: `Rec.Reset(); if not Rec.Get() then Rec.Insert();` wie bei Setup-Tabellen
- `CalcFormula` mit `where`-Filter für Status-basierte Zähler

#### 7.5.2 Activities-Page (CardPart)

```al
page 70015 "My Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "My Cue";
    RefreshOnActivate = true;  // ← FlowFields neu berechnen bei Aktivierung

    layout
    {
        area(Content)
        {
            cuegroup(MyGroup)
            {
                Caption = 'My Group';

                field("Open Count"; Rec."Open Count")
                {
                    DrillDownPageID = "My List";
                }
                field("Error Count"; Rec."Error Count")
                {
                    Style = Attention;      // Rot/orange-Hervorhebung
                    DrillDownPageID = "My List";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
```

**Wichtige Eigenschaften:**
- `PageType = CardPart` — Wird als Part in ein RoleCenter eingebettet
- `RefreshOnActivate = true` — FlowFields werden beim Fokussieren aktualisiert (kein Page-Refresh nötig)
- `DrillDownPageID` — Klick auf die Kachel öffnet die verlinkte Seite
- `Style = Attention` — Hebt Problem-Kacheln visuell hervor (rot/orange)

#### 7.5.3 Einbindung ins Role Center

```al
page 70001 "My Role Center"
{
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(MyActivities; "My Activities")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
```

#### 7.5.4 CueGroups vs. direkte ListParts

| Ansatz | Verwendung |
|--------|-----------|
| **CueGroup (CardPart)** | Status-Kacheln mit Zählern, DrillDown zu Liste ✅ |
| **Part (ListPart direkt)** | Liste ohne Kacheln, dauerhaft sichtbare Tabelle |

> ⚠️ `group` mit `part` in `area(rolecenter)` wird in "Einblicke" einsortiert, nicht als Kachel/Stapel gerendert.

## 8. Building & CI/CD Integration

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
