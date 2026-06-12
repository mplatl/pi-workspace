# Konzept: Generelle Import-Schnittstelle für Buchblätter

> **Status:** Konzeptphase — keine Programmierung  
> **Ziel:** Flexible, mehrfach konfigurierbare Import-Schnittstelle für Buchblätter in Business Central  
> **Inspiration:** Konfigurationspakete (mehrere Setups, CSV/XML-Datenhaltung, Mapping-Logik)

---

## 1. Überblick

Business Central-Anwender sollen wiederkehrende Importaufgaben (z. B. CSV-Dateien aus Fremdsystemen) über eine zentrale, konfigurierbare Oberfläche in Buchblätter einspielen können — ohne jedes Mal eine individuelle Codeunit schreiben zu müssen.

**Phase 1:** Nur Buchblätter (General Journal, Item Journal, Resource Journal, …)  
**Spätere Phasen:** Direkter Import in beliebige Tabellen (ähnlich Konfigurationspakete)

---

## 2. Kernanforderungen

| # | Anforderung | Priorität |
|---|-------------|-----------|
| A1 | Mehrere Import-Setups anlegbar (wie Konfigurationspakete) | Muss |
| A2 | Buchblatt (Vorlagenname + Name) pro Setup fix vordefinierbar | Muss |
| A3 | Buchblatt dynamisch pro importierter Zeile wählbar (abhängig von Daten) | Kann |
| A4 | Datei einlesen: Spalten automatisch erkennen, Überschriften als Spaltenname nutzen | Muss |
| A5 | Manuelles Anlegen der Spalten ohne Datei-Upload möglich | Muss |
| A6 | Spalten-Mapping auf Buchblattfelder | Muss |
| A7 | Validate (OnValidate-Trigger) pro Spalte ein-/ausschaltbar | Muss |
| A8 | Felder abhängig von importierten Werten bedingt setzen | Kann |
| A9 | Wert-Transformation (z. B. „Istmeldung" → „1") | Muss |
| A10 | Cloud-tauglich: keine Dateipfade, Dateien als BLOB in eigener Tabelle | Muss |
| A11 | Dubletten-Erkennung: gleiche Datei darf nicht doppelt gebucht werden | Muss |

---

## 3. Architektur

### 3.1 Verarbeitungspipeline

```
┌──────────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────────┐    ┌────────────┐
│  Datei-Upload│    │ Dubletten│    │  CSV parsen  │    │  Mapping +   │    │  Buchblatt │
│  → Import    │──▶│ -Prüfung │──▶│  → Import    │──▶│  Validate    │──▶│  einfügen  │
│  File Table  │    │ (Hash)   │    │  Data Buffer │    │              │    │  + Buchen  │
└──────────────┘    └──────────┘    └──────────────┘    └──────────────┘    └────────────┘
       │                  │                  │                   │
       ▼                  ▼                  ▼                   ▼
┌──────────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────────┐
│ Import File  │    │ Content  │    │ Import Data  │    │ Import Setup │
│ (BLOB+Status)│    │ Hash     │    │ Buffer       │    │ Column       │
└──────────────┘    └──────────┘    └──────────────┘    └──────────────┘
```

### 3.2 Schichten

```
┌─────────────────────────────────────┐
│          Pages (UI)                 │  ← Import Setup Card/List, Import Vorschau
├─────────────────────────────────────┤
│       Codeunits (Logik)             │  ← Import Processor, Mapping Engine
├─────────────────────────────────────┤
│        Tables (Daten)               │  ← Import Setup Header/Line, Data Buffer
└─────────────────────────────────────┘
```

---

## 4. Datenmodell (Tabellen)

### 4.1 Import File — `"MIP Import File"`

Zentrale Ablagetabelle für alle zu importierenden Dateien. Quelle der Datei ist bewusst abstrahiert —
der Upload kann später per API, Drag & Drop, E-Mail-Anhang oder andere Kanäle erfolgen.

| Feldname | Typ | Beschreibung |
|----------|-----|-------------|
| **Entry No.** | Integer | Primärschlüssel (AutoIncrement) |
| **Setup Code** | Code[20] | FK → Import Setup Header (welches Setup soll diese Datei verarbeiten) |
| **File Name** | Text[250] | Original-Dateiname (zur Anzeige) |
| **File Extension** | Text[10] | Dateiendung (.csv, .txt) |
| **File Content** | BLOB | Binärer Dateiinhalt |
| **Content Hash** | Text[64] | SHA-256-Hash des Dateiinhalts (Dubletten-Erkennung) |
| **Status** | Option | Pending, Processing, Processed, Error, Skipped |
| **Lines Total** | Integer | Anzahl Zeilen in der Datei |
| **Lines Processed** | Integer | Erfolgreich verarbeitete Zeilen |
| **Lines Error** | Integer | Zeilen mit Fehler |
| **Error Message** | Text[250] | Globaler Fehlertext (z. B. wenn Hash-Dublette) |
| **Uploaded At** | DateTime | Zeitpunkt des Uploads |
| **Processed At** | DateTime | Zeitpunkt der Verarbeitung |
| **Uploaded By** | GUID | User Security ID |

**Status-Übergänge:**
```
Pending ──▶ Processing ──▶ Processed
  │                          │
  └──────▶ Error             │
  └──────▶ Skipped (Dublette)│
```

**Dubletten-Erkennung:**
- Vor der Verarbeitung wird `Content Hash` gegen alle bereits `Processed`-Einträge mit demselben `Setup Code` geprüft
- Treffer → Status = `Skipped`, Error Message = "Datei wurde bereits am {Datum} importiert (Entry {Nr})"
- Der Hash wird beim Upload berechnet (vor dem Parsing), nicht erst nach erfolgreicher Buchung

> **Design-Entscheidung:** Der Hash wird beim Upload berechnet. Wenn die Datei bereits existiert, wird sie sofort als Skipped markiert — ohne ins Parsing zu gehen. Das spart Rechenzeit und verhindert unnötige Fehler.

### 4.2 Import Setup Header — `"MIP Import Setup Header"`

| Feldname | Typ | Beschreibung |
|----------|-----|-------------|
| **Code** | Code[20] | Primärschlüssel, eindeutige Setup-ID |
| **Description** | Text[100] | Bezeichnung |
| **Journal Template Name** | Code[10] | Buchblattvorlage (optional) |
| **Journal Batch Name** | Code[10] | Buchblattname (optional) |
| **File Encoding** | Option (UTF-8, ANSI, …) | Encoding der Quelldatei |
| **Column Separator** | Text[5] | Trennzeichen (`,` `;` `\t` etc.) |
| **First Row Is Header** | Boolean | Erste Zeile = Spaltenüberschriften? |
| **Auto Post** | Boolean | Nach Import automatisch buchen? |
| **Posting Date Formula** | Text[20] | Datumsformel für Buchungsdatum (z. B. `0D` = heute) |
| **Document No. Series** | Code[10] | Nummernserie für Belegnummer (optional) |

> **Design-Entscheidung:** Journal Template/Batch *können* leer bleiben — dann *muss* das Mapping dies pro Zeile übersteuern (siehe 4.3).

### 4.3 Import Setup Column — `"MIP Import Setup Column"`

| Feldname | Typ | Beschreibung |
|----------|-----|-------------|
| **Setup Code** | Code[20] | FK → Import Setup Header |
| **Line No.** | Integer | Zeilennummer |
| **Source Column Name** | Text[50] | Spaltenname in der Quelldatei |
| **Source Column No.** | Integer | Spaltenposition (1-basiert, Fallback wenn Name nicht gefunden) |
| **Target Field No.** | Integer | Feldnummer in der Ziel-Tabelle (Buchblattzeile) |
| **Target Field Name** | Text[50] | Anzeigename (Read-only, aus Field Ref) |
| **Validate** | Boolean | OnValidate nach Setzen des Werts ausführen? |
| **Skip Empty** | Boolean | Leere Quellwerte ignorieren? |
| **Default Value** | Text[250] | Fallback-Wert wenn Quelle leer |
| **Mapping Type** | Option | Mapping-Typ (siehe unten) |
| **Condition Expression** | Text[250] | Bedingung für bedingtes Setzen (optional) |

**Mapping Type (Option):**
- `Direct` — Wert direkt übernehmen
- `Value Map` — Umwandlung über Tabelle „Import Column Value Map" 
- `Date Formula` — Datumsformel interpretieren
- `Fixed` — Immer den Default Value setzen (Quellspalte ignorieren)

### 4.4 Import Column Value Map — `"MIP Import Column Value Map"`

Pro Spalte können beliebig viele Quell→Ziel-Transformationen hinterlegt werden.

| Feldname | Typ | Beschreibung |
|----------|-----|-------------|
| **Setup Code** | Code[20] | FK → Setup Header |
| **Column Line No.** | Integer | FK → Setup Column |
| **Source Value** | Text[100] | Wert aus der Quelldatei |
| **Target Value** | Text[100] | Zielwert im Buchblatt |

> **Beispiel:** Quelle `"Istmeldung"` → Ziel `"1"`  // Quelle `"Verbrauch"` → Ziel `"0"`

### 4.5 Import Data Buffer — `"MIP Import Data Buffer"`

Temporäre Tabelle für die Rohdaten einer Import-Datei. Referenziert den `Import File`-Eintrag.

| Feldname | Typ | Beschreibung |
|----------|-----|-------------|
| **Import File Entry No.** | Integer | FK → Import File |
| **Row No.** | Integer | Zeilennummer aus Quelldatei |
| **Raw Data JSON** | BLOB / Text | Alle Spaltenwerte als JSON (`{"SpalteA":"Wert",…}`) |
| **Status** | Option (Pending, Validated, Error, Transferred) | Verarbeitungsstatus |
| **Error Message** | Text[250] | Fehlertext bei Validate-Fehler |

> **Alternative zu JSON:** Eigene Tabelle mit flexiblen Spalten (Spalte 1..50 als Text), aber JSON ist flexibler und einfacher erweiterbar.  
> **Design-Entscheidung:** Pro Import File, nicht pro Session. Über `Import File Entry No.` ist die Zuordnung zur Quelldatei immer gegeben.

### 4.6 Ziel: Buchblatt-Zeilen

Das Ziel ist die Standard-Buchblattzeile. Über `Target Field No.` und `Validate` wird das Standard-Record-Setup von BC genutzt, d. h.:
- `Rec."Posting Date" := …` → löst `OnValidate` aus wenn `Validate = true`
- Fehler via `Error()` fangen und in `Import Data Buffer.Status = Error` schreiben

---

## 5. Seiten (Pages)

### 5.1 Import Setup List — Seite `"MIP Import Setup List"`

ListPage über alle Import Setups. Aktionen:
- **Neu** — Setup Card öffnen
- **Bearbeiten** — Setup Card öffnen
- **Import starten** — Datei-Dialog → Pipeline starten
- **Löschen**

### 5.2 Import Setup Card — Seite `"MIP Import Setup Card"`

CardPage mit:
- Reiter **Allgemein:** Code, Description, Journal Template/Batch, File Settings
- Reiter **Spalten:** Subpage (ListPart) → Import Setup Columns
  - Pro Zeile: Quellspalte, Zielfeld (AssistEdit auf Tabelle 81 „Gen. Journal Line"), Validate, Default Value
  - Action: **Wert-Mappings** → öffnet Subpage mit Value-Map-Einträgen
- Reiter **Vorschau:** Subpage für Import Data Buffer der letzten Session

### 5.3 Import Preview — Seite `"MIP Import Preview"`

Wird nach Datei-Upload angezeigt:
- Oben: Rohdaten (Read-only Grid mit erkannten Spalten)
- Aktion: **Spalten automatisch anlegen** → Erzeugt Setup Columns aus Datei-Headern
- Aktion: **Import durchführen** → Startet die Mapping-Engine
- Aktion: **In Buchblatt übernehmen** → Überträgt validierte Zeilen ins Buchblatt

---

## 6. Verarbeitungslogik (Codeunits)

### 6.1 Codeunit `"MIP Import Engine"`

Zentrale Codeunit. Aufruf aus der Page heraus.

```
procedure ImportFile(ImportFileEntryNo: Integer)
```

**Ablauf:**

```
1.  Import File laden (GET ImportFileEntryNo)
2.  DATEI-DUBLETTEN-PRÜFUNG (Content Hash):
    a) Content Hash mit allen Processed-Einträgen desselben Setup Code vergleichen
    b) Treffer → Status = Skipped, Error Message setzen, EXIT
3.  Status = Processing
4.  Setup Header über Setup Code laden
5.  CSV parsen:
    a) Encoding + Separator aus Setup Header lesen
    b) Import File.Content als Text-Stream öffnen
    c) Erste Zeile = Header? → Spaltennamen extrahieren
    d) Alle weiteren Zeilen als JSON → Import Data Buffer schreiben
6.  Spalten-Mapping prüfen:
    a) Gibt es bereits Setup Columns für diesen Setup Code?
    b) Wenn nein: Automatisch aus Datei-Headern anlegen (ohne Target-Feld)
       → User muss Target-Felder manuell setzen
    c) Wenn ja: Mapping anwenden (Schritt 7)
7.  Business Key berechnen (Spalten mit IsBusinessKey = true)
    → Format: SetupCode + "|" + Wert1 + "|" + Wert2 + …
8.  DATENSATZ-DUBLETTEN-PRÜFUNG (Business Key):
    FOR EACH Import Data Buffer DO
      Business Key berechnen
      Prüfen ob dieser Key bereits in gebuchten Posten existiert
      Wenn ja → Status = Error, "Datensatz bereits gebucht am {Datum}"
      Wenn nein → weiter mit Schritt 9
    END
9.  Mapping pro Zeile:
    FOR EACH Import Data Buffer WHERE Status <> Error DO
      Ziel-Record initialisieren (Buchblattzeile)
      MIP-Felder setzen (Setup Code, File Entry No., Row No., Source ID)
      FOR EACH Setup Column DO
        Quellwert aus JSON extrahieren
        Mapping-Type prüfen:
          - Direct: Wert setzen, bei Validate = true → VALIDATE
          - Value Map: Transformieren, dann setzen
          - Date Formula: Formel evaluieren, dann setzen
          - Fixed: Default Value setzen
      END
      Buchblattzeile INSERT
      Status = Validated (oder Error bei Validate-Fail)
    END
10. Nach Buchung: Import File.Lines Processed/Error aktualisieren
11. Status = Processed (oder Error wenn alle Zeilen fehlschlugen)
12. Event: Beim Buchen MIP-Felder in Posten übertragen
```

### 6.2 Dynamische Buchblattwahl (Anforderung A3)

Wenn Setup Header *kein* Journal Template/Batch definiert, prüft die Engine pro Datenzeile:
- Eine Setup Column kann auf das Feld „Journal Template Name" oder „Journal Batch Name" gemappt sein
- Der Wert aus der Datei bestimmt dann das Ziel-Buchblatt pro Zeile
- Ermöglicht Szenario: „Wenn Verbrauch → Buchblatt A, Istmeldung → Buchblatt B"

### 6.3 Bedingtes Setzen von Feldern (Anforderung A8)

Jede Setup Column hat ein optionales Feld `Condition Expression`. Syntax-Vorschlag:
- `[Quellspalte] = 'Wert'` — einfache Gleichheit
- `[Quellspalte] <> ''` — nicht leer

Bei Nichterfüllung der Bedingung wird die Spalte für diese Zeile übersprungen.

> **Alternative:** Eigene AL-Ausdrücke, die zur Laufzeit evaluiert werden (komplexer, aber mächtiger).  
> **Empfehlung Phase 1:** Nur einfache Gleichheit + ungleich leer.

---

## 7. Fehlerbehandlung

| Phase | Fehler | Behandlung |
|-------|--------|-----------|
| Upload | Datei zu groß (>50 MB) | `Error()` → Abbruch |
| Dubletten-Prüfung | Content Hash bereits vorhanden | Status = Skipped → Abbruch |
| Datei einlesen | Separator falsch, Encoding falsch | Status = Error, Message speichern |
| Spalten-Mapping | Zielfeld existiert nicht | `Error()` → Abbruch |
| Zeilen-Validierung | `OnValidate` wirft `Error` | Status = Error, Message speichern, nächste Zeile |
| Buchblatt einfügen | Insert fehlgeschlagen | Rollback? Oder Error pro Zeile? |
| Buchen | Buchungsfehler | Buchblatt bleibt erhalten, manuelle Korrektur |

> **Design-Entscheidung:** Zeilenweise Fehlerbehandlung (nicht alles oder nichts). Fehlerhafte Zeilen bleiben im Puffer und können korrigiert werden.

---

## 8. Benötigte BC-Objekte (Übersicht)

| Typ | Name | ID-Vorschlag | Beschreibung |
|-----|------|-------------|-------------|
| Table | MIP Import File | 50000 | Eingehende Dateien (BLOB + Status) |
| Table | MIP Import Setup Header | 50001 | Import-Setup Kopf |
| Table | MIP Import Setup Column | 50002 | Spalten-Mapping |
| Table | MIP Import Column Value Map | 50003 | Wert-Transformationen |
| Table | MIP Import Data Buffer | 50004 | Temporäre Rohdaten |
| TableExt | Gen. Journal Line | — | MIP-Felder (Setup, File, Row, Source ID) |
| TableExt | Gen. Ledger Entry | — | MIP-Felder (Rückverfolgbarkeit) |
| TableExt | Item Journal Line | — | MIP-Felder |
| TableExt | Item Ledger Entry | — | MIP-Felder (Rückverfolgbarkeit) |
| Page | MIP Import File List | 50000 | Liste aller Import-Dateien |
| Page | MIP Import Setup List | 50001 | Liste aller Setups |
| Page | MIP Import Setup Card | 50002 | Setup bearbeiten |
| Page | MIP Import Preview | 50003 | Vorschau + Import starten |
| Codeunit | MIP Import Engine | 50000 | Verarbeitungslogik |
| Codeunit | MIP Import Posting Handler | 50001 | Event-Subscriptions für Posten-Übertragung |
| Codeunit | MIP Import Test | 50002 | Test-Codeunit |

> IDs prüfen gegen `app.json`-Range vor Umsetzung.

---

## 9. Offene Fragen / Entscheidungen

| # | Frage | Vorschlag |
|---|-------|-----------|
| Q1 | JSON-Blob vs. flexible Spalten-Tabelle? | **JSON** — flexibler, keine 50-Spalten-Limitierung |
| Q2 | Condition Expression: einfacher String-Vergleich oder AL-Ausdrücke? | **Phase 1:** einfacher String-Vergleich. Phase 2: AL-Expressions |
| Q3 | Datenbuffer: pro Session oder persistent? | **Pro Session** — `Session ID` Guid, Cleanup nach Import |
| Q4 | Unterstützte Dateiformate: Nur CSV? | **Phase 1:** CSV. Später: Excel, XML, JSON |
| Q5 | Mehrere Buchblätter in einer Session? | Ja — wenn dynamische Buchblattwahl genutzt wird |
| Q6 | Soll der Import direkt buchen können? | Optional via `Auto Post`-Flag im Setup Header |
| Q7 | Nummernserien für Belegnummer? | Optional im Setup Header, sonst manuell oder aus Datei |
| Q8 | Woher kommt die Datei (Upload-Kanal)? | Später: API, Drag & Drop, E-Mail, … — Tabelle ist kanal-agnostisch |
| Q9 | Hash-Dublette: pro Setup oder global? | **Pro Setup** — dieselbe Datei kann in unterschiedlichen Setups verarbeitet werden |
| Q10 | Was passiert mit Skipped/Error-Dateien? | Bleiben in der Tabelle, können manuell zurückgesetzt und erneut verarbeitet werden |
| Q11 | Business Key: eine Spalte oder mehrere? | **Mehrere** — alle Spalten mit `IsBusinessKey = true` werden konkateniert |
| Q12 | Wo werden die MIP-Felder in der Buchblatt-UI angezeigt? | **Nicht** — unsichtbar, nur per Personalisierung einblendbar. Keine FieldGroup |

---

## 10. Nächste Schritte

1. **Konzept reviewen** → Feedback einholen, Entscheidungen zu offenen Fragen treffen
2. **Objekt-IDs festlegen** → Range aus `app.json` prüfen
3. **Tabellen implementieren** → Felder, Keys, FieldGroups
4. **Pages implementieren** → List, Card, Preview
5. **Codeunit implementieren** → Import Engine mit CSV-Parsing + Mapping
6. **Test-Codeunit schreiben** → Alle Mapping-Typen, Fehlerfälle, dynamische Buchblattwahl
7. **Integrationstest** → Echte CSV-Datei in echtes Buchblatt

---

> **Erstellt:** 2026-06-13  
> **Autor:** Michael Platl (mplatl)  
> **Repository:** pi-workspace / BCWebAccess
