# bc-documentation

Business Central 28 — technische Dokumentation mit RAG-Quellcode-Referenz und User-Story-Beispielen.

## Wann verwenden

- "dokumentiere BC28", "schreib Dokumentation für Kapitel X"
- "beschreibe Tabelle/Field X in BC28"
- "erkläre Fibu-Einrichtung / Sales Setup / etc."
- Immer wenn ein Kapitel der `bc28-documentation` (GitHub Pages) geschrieben wird

## Regeln

### 1. Quelle: RAG-Collection `28.1.49838.49886.at`

Alle technischen Inhalte (Felder, Prozeduren, Events, Namespaces) aus der RAG-Collection beziehen.
Bei Setup-Tabellen das vollständige `.Table.al`-File über `read` einlesen.

```bash
rag_query --collection "28.1.49838.49886.at" --query "<suchbegriffe>" --limit 15
```

Quellcode-Pfade sind unter `/home/michael/Dokumente/development/ai/onprem/28.1.49838.49886/at/`.

### 2. Sprache: Deutsch

Die gesamte Dokumentation wird auf Deutsch geführt.

- Feldbeschreibungen: Deutsch
- Beispiele: Deutsch
- Technische Begriffe: eingedeutscht wo üblich (Ereignis, Namensraum, Buchungsblatt, Auftragswarteschlange...)
- **Ausnahme:** AL-Code-Zitate und Quellcode-Ausschnitte bleiben im englischen Original

### 3. Beispiele: User-Story-Stil

Jedes Feld einer Setup-Tabelle bekommt **3 unterschiedliche Beispiele** im Stil:

> "Das Unternehmen möchte ..."
> "Ein Buchhalter benötigt ..."
> "Die Konzernmutter verlangt ..."

Keine abstrakten Szenarien. Jedes Beispiel muss:
- Eine konkrete Person oder Organisation nennen
- Deren Bedürfnis beschreiben
- Die exakten Feldwerte angeben (z.B. `Allow Posting From = 01.01.2026`)
- Das Ergebnis beschreiben („Ergebnis: ...")

### 4. Entwickler-Referenz

Jeder Abschnitt muss enthalten:
- Namespace der Tabelle
- Wichtige Prozeduren mit AL-Signatur
- Integrationsereignisse (`[IntegrationEvent]`) mit Parametern
- Abhängige Tabellen/Codeunits mit IDs

### 5. Struktur pro Kapitel

```markdown
---
title: "Kapiteltitel"
---
# X. Kapiteltitel

> **Tabelle XYZ:** `Dateiname.al`
> **Namensraum:** `Microsoft.Bereich.Modul`
> **Seite:** `Seitenname.al`
> **Typ:** Singleton / Multi-Record

Kurze Einleitung (2–3 Sätze).

## X.1 Themengruppe

### Feld N: `Feldname` — Deutsche Kurzbeschreibung

Einleitender Satz.

```al
(code-auszug aus dem original)
```

**Beispiel 1 — Überschrift als User-Story:**
> Kontext...
> ➜ Werte
> **Ergebnis:** ...

**Beispiel 2 — ...**
**Beispiel 3 — ...**

**Wichtige Codestellen:**
- `Prozedurname()` — Beschreibung
- ...

## X.N Integrationsereignisse (für Entwickler)

Tabelle der [IntegrationEvent]-Prozeduren mit Parametern.
AL-Abonnenten-Beispiel.

## X.N+1 Abhängige Tabellen & Codeunits

Tabelle mit ID und Verwendung.
```

## GitHub Pages

Die Doku wird als Jekyll-Site im Repo `MPSWIT/bc28-documentation` gehostet:
- Theme: `jekyll-theme-hacker` (dunkel, Terminal-Look)
- `noindex, nofollow` für Suchmaschinen (`robots.txt` + Meta-Tag)
- 18 Kapitel-Ordner mit je `index.md`

Arbeitsverzeichnis: `/home/michael/Dokumente/development/pi-workspace/bc28-documentation/`

Commit und Push:
```bash
cd /home/michael/Dokumente/development/pi-workspace/bc28-documentation
git add -A
git -c user.name="mplatl" -c user.email="michael.platl@hotmail.com" commit -m "docs: ..."
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_private" git push origin main
```

## TODO-Verfolgung

Nach jedem geschriebenen Kapitel die `TODO.md` aktualisieren:
- `[ ]` → `[x]` für erledigte Unterpunkte
- Status-Zeile am Ende aktualisieren
