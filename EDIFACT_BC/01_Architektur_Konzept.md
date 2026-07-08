# Universal EDI Framework - Konzept für Business Central 28

> **Geschäftsprozess-orientiertes Konzept**
> Einrichtung · Kundenabsprache · Empfang · Korrektur · Versand
> EDIFACT · CSV · TXT · XML · JSON · Custom

---

## Inhaltsverzeichnis

1. [Was macht die App?](#1-was-macht-die-app)
2. [Unterstützte Formate & Nachrichtentypen](#2-unterstützte-formate--nachrichtentypen)
3. [Wie wird eingerichtet?](#3-wie-wird-eingerichtet)
4. [Automatische BC-Logik in der No-Code-Verarbeitung](#4-automatische-bc-logik-in-der-no-code-verarbeitung)
5. [Was wird mit dem Kunden vereinbart?](#5-was-wird-mit-dem-kunden-vereinbart)
6. [Wie wird empfangen?](#6-wie-wird-empfangen)
7. [Wie kann ich korrigieren?](#7-wie-kann-ich-korrigieren)
8. [Wie wird versendet?](#8-wie-wird-versendet)
9. [Sonderfälle & Fehlerbehandlung](#9-sonderfälle--fehlerbehandlung)
10. [Rollen & Berechtigungen](#10-rollen--berechtigungen)
11. [Einführungsprozess](#11-einführungsprozess)

---

## 1. Was macht die App?

### 1.1 Das Problem

Jeder Kunde schickt seine Daten anders:

| Kunde | Format | Beispiel |
|---|---|---|
| Großhändler A | EDIFACT D.97A | `UNH+1+ORDERS:D:97A:UN:...` |
| Baumarkt B | CSV mit Semikolon | `BestellNr;Datum;Artikel;Menge` |
| Online-Shop C | JSON per API | `{"order": {"id": "...` |
| Filiale D | TXT mit festen Spalten | Position 1-10 = Artikel, 11-20 = Menge |
| Konzern E | XML nach SAP-IDoc | `<IDOC><EDI_DC40>...` |

Bisher: Für jedes Format eigener Code, eigene Entwicklung, eigene Wartung.

### 1.2 Die Lösung

**Eine App, die alle Formate kann.** Konfiguriert wird alles ohne Programmierung - direkt in Business Central.

```
           ┌─────────────────────────────────────────┐
           │         UNIVERSAL EDI FRAMEWORK         │
           │                                         │
Beliebiges │  ┌──────┐  ┌──────┐  ┌──────┐  ┌────┐ │  Business
 Format ───┼─▶│PARSE │─▶│ MAP  │─▶│VALID.│─▶│BC  │─┼──▶ Central
           │  └──────┘  └──────┘  └──────┘  └────┘ │   Dokument
           │                                         │
           │  EDIFACT ∙ CSV ∙ TXT ∙ XML ∙ JSON       │
           └─────────────────────────────────────────┘
```

### 1.3 Kernversprechen

> **Jedes Feld aus einer beliebigen Quelldatei kann auf jedes Feld in einer beliebigen Business-Central-Tabelle gemappt werden - ohne eine Zeile Code zu schreiben.**

---

## 2. Unterstützte Formate & Nachrichtentypen

### 2.1 Format-Typen

| Format | Typische Nutzung | Was der Kunde liefern muss |
|---|---|---|
| **EDIFACT** | Großhandel, Automotive | UN/EDIFACT-Datei (UNB...UNZ) |
| **CSV** | Mittelstand, Excel-Export | Textdatei mit Trennzeichen |
| **TXT** | Legacy-Systeme, Waagen | Textdatei mit festen Spaltenbreiten |
| **XML** | SAP, Konzern-Umgebungen | XML-Datei mit Schema |
| **JSON** | Webshops, APIs, moderne Systeme | JSON-Dokument (REST-API) |
| **Custom** | Proprietäre Formate | Plugin-Codeunit (einmalig) |

### 2.2 Nachrichtentypen im Verkauf (Inbound = Kunde → BC)

| Message | Was kommt an? | Was entsteht in BC? |
|---|---|---|
| **ORDERS** | Bestellung des Kunden | Verkaufsauftrag (Sales Order) |
| **ORDCHG** | Änderung/Storno einer Bestellung | Änderung des Verkaufsauftrags |
| **DELFOR** | Lieferplan-Vorschau | Planungszeilen (optional) |
| **CREADV** | Gutschrift des Kunden (Reklamation) | Verkaufsgutschrift |
| **REMADV** | Zahlungsavise | Zahlungsabgleich |

### 2.3 Nachrichtentypen im Verkauf (Outbound = BC → Kunde)

| Message | Was wird versendet? | Auslöser in BC |
|---|---|---|
| **ORDRSP** | Auftragsbestätigung | Nach Anlage/Freigabe Verkaufsauftrag |
| **DESADV** | Lieferavis | Nach Buchen Warenausgang |
| **INVOIC** | Elektronische Rechnung | Nach Buchen Verkaufsrechnung |

### 2.4 Nicht nur Verkauf

Das Framework kann auf **jede BC-Tabelle** schreiben - Beispiele:

| Bereich | Inbound-Beispiel | Ziel-Tabelle |
|---|---|---|
| Einkauf | Lieferantenbestätigung (ORDRSP inbound) | Purchase Header |
| Artikelstamm | Artikelkatalog-Import (CSV/XML) | Item |
| Fibu | Buchungssätze-Import (CSV) | G/L Entry |
| Bank | Kontoauszug (CSV/CAMT) | Bank Account Ledger Entry |

---

## 3. Wie wird eingerichtet?

Die Einrichtung erfolgt in **sechs Schritten** - einmal pro Format/Kunde:

### Schritt 1: Format definieren

> *"Wie sieht die Datei des Kunden aus?"*

| Einstellung | Beispiel EDIFACT | Beispiel CSV |
|---|---|---|
| Format-Typ | EDIFACT | CSV |
| Version | D.97A | - |
| Trennzeichen | `:+.? '` | `;` |
| Kodierung | UTF-8 | UTF-8 |
| Datumsformat | YYYYMMDD | DD.MM.YYYY |
| Dezimaltrennzeichen | `.` | `,` |

### Schritt 2: Felder benennen

> *"Welche Informationen stecken in der Datei - und wo?"*

Jedes Feld bekommt einen Namen und einen **Pfad** - die "Adresse" im Quelldatenstrom:

| Format | Pfad-Beispiel | Bedeutung |
|---|---|---|
| EDIFACT | `BGM[1].C106.1004` | BGM-Segment, erstes Vorkommen, Composite 106, Element 1004 |
| CSV | `COL[0]` | Erste Spalte |
| TXT | `POS:4..13` | Position 4 bis 13 |
| XML | `/IDOC/E1EDK01/DOCNUM` | XPath zum Element |
| JSON | `$.order.id` | JSONPath zum Feld |

**Beispiel: Eine EDIFACT-Bestellung zerlegen:**

```
UNA:+.? '
UNH+1+ORDERS:D:97A:UN:1.1'
BGM+220+PO-2026-0042+9'
DTM+137:20260624:102'
NAD+BY+4012345123456::9'
LIN+1++ART-001:SA'
QTY+21:100'
PRI+AAA:12.50'

→ Diese Datei enthält folgende Felder:

┌────────────────┬────────────────────────┬──────────┐
│ Feldname       │ Pfad                   │ Wert     │
├────────────────┼────────────────────────┼──────────┤
│ Bestellnummer  │ BGM[1].C106.1004       │ PO-2026-0042 │
│ Bestelldatum   │ DTM[137].C507.2380     │ 20260624  │
│ Kunden-GLN     │ NAD[BY].C082.3039      │ 4012345123456 │
│ Artikelnummer  │ LIN[1].C212.7140       │ ART-001   │
│ Menge          │ QTY[21].C186.6060      │ 100       │
│ Einzelpreis    │ PRI[AAA].C509.5118     │ 12.50     │
└────────────────┴────────────────────────┴──────────┘
```

### Schritt 3: Zieltabelle und Mapping festlegen

> *"Aus der Bestellung des Kunden soll ein Verkaufsauftrag werden."*

Jedes Format-Feld wird mit einem BC-Feld verknüpft:

```
┌─── Quelldatei ───┐          ┌─── Business Central ───┐
│                   │          │                         │
│ Bestellnummer ────┼──────────┼─▶ Externe Belegnummer  │
│ Bestelldatum ─────┼──Format──┼─▶ Auftragsdatum        │
│ Kunden-GLN ───────┼──Lookup──┼─▶ Verkauf an Kunde     │
│ Artikelnummer ────┼──Mapping─┼─▶ Artikelnummer (Zeile)│
│ Menge ────────────┼──────────┼─▶ Menge (Zeile)        │
│ Einzelpreis ──────┼──────────┼─▶ VK-Preis (Zeile)     │
│                   │          │                         │
│ (Konstante Wert) ─┼──────────┼─▶ Belegart = Auftrag   │
└───────────────────┘          └─────────────────────────┘
```

> **Mapping-Typen (ohne Code konfigurierbar):**

| Typ | Bedeutung | Beispiel |
|---|---|---|
| **Direkt** | 1:1 übernehmen | Bestellnummer → Externe Belegnr. |
| **Format** | Umwandeln | `20260624` → `24.06.2026` |
| **Lookup** | In BC-Tabelle suchen | GLN `40123...` → Kunde `K-10042` |
| **Dynamisch** | Aus Mapping-Tabelle | `PC` → `STK` (Mengeneinheit) |
| **Konstante** | Fester Wert | Belegart = immer "Auftrag" |
| **Bedingung** | Wenn-Dann | Wenn Menge > 100 → Rabatt 5% |

### Schritt 4: Validierungsregeln festlegen

> *"Was muss geprüft werden, bevor der Auftrag angelegt wird?"*

| Regel-Typ | Beispiel | Fehlermeldung |
|---|---|---|
| **Pflichtfeld** | Bestellnummer darf nicht leer sein | "Bestellnummer fehlt" |
| **Datentyp** | Menge muss eine Zahl sein | "Menge 'ABC' ist ungültig" |
| **Wertebereich** | Menge muss > 0 sein | "Menge muss größer 0 sein" |
| **Existenzprüfung** | Artikel muss im Stamm sein | "Artikel 'X' nicht gefunden" |
| **Format** | USt-ID: DE + 9 Ziffern | "Ungültige USt-ID" |

### Schritt 5: Partner zuordnen

> *"Für welchen Kunden gilt diese Konfiguration?"*

- Kunde in BC auswählen (Debitor)
- Format zuweisen
- Aktive Nachrichtentypen festlegen (ORDERS ja, DELFOR nein)
- Partner-spezifische Abweichungen konfigurieren

### Schritt 6: Zielverhalten definieren

> *"Was soll beim Erstellen/Ändern des BC-Dokuments automatisch passieren?"*

Jetzt wird festgelegt, wie das System beim Anlegen oder Ändern eines Dokuments mit BC-Logik umgeht:

- Wie werden neue Zeilen nummeriert?
- Bei Änderungen: Wie wird die existierende Zeile gefunden?
- Welche Systemfelder bekommen automatisch Werte?

Dieser Schritt wird im Detail in [Kapitel 4](#4-automatische-bc-logik-in-der-no-code-verarbeitung) beschrieben.

---

## 4. Automatische BC-Logik in der No-Code-Verarbeitung

> **"No-Code" bedeutet nicht "keine Logik".**
> Das System führt beim Erstellen und Ändern von BC-Dokumenten automatisch Standard-Logik aus -
> aber **konfigurierbar** statt hart verdrahtet.

### 4.1 Übersicht: Was passiert automatisch?

```
STAGING-DATEN
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│              PROCESSOR (generisch)                       │
│                                                          │
│  ┌──────────────────┐   ┌────────────────────────────┐  │
│  │ ZIELVERHALTEN    │   │ DATENSATZ-IDENTIFIKATION   │  │
│  │                  │   │                            │  │
│  │ · Zeilennummern  │   │ · Header finden?           │  │
│  │ · Journal-Vorlagen│  │ · Zeilen finden?           │  │
│  │ · Standardwerte  │   │ · Match-Strategie          │  │
│  │ · Dimensionen    │   │ · Was bei keinem Treffer?  │  │
│  └──────────────────┘   └────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │ SYSTEM-AUTOMATISMEN (BC-Standard)                 │   │
│  │ · Nummernkreise  · Buchungsdatum  · Lagerort      │   │
│  │ · Preisfindung   · Steuerermittlung · Prüfungen   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
     │
     ▼
  BC-DOKUMENT (Sales Order / Item Journal / Purchase Header / ...)
```

---

### 4.2 Zielverhalten: Wie werden neue Zeilen nummeriert?

Wenn eine eingehende Datei mehrere Positionen enthält, muss jede Zeile im BC-Dokument eine **eindeutige Zeilennummer** bekommen. Das System unterstützt mehrere Strategien:

| Strategie | Beschreibung | Beispiel |
|---|---|---|
| **Aus Quelle übernehmen** | Die Zeilennummer aus der Quelldatei wird direkt als `Line No.` verwendet | LIN+1 → Line 10000<br>LIN+2 → Line 20000<br>LIN+3 → Line 30000 |
| **Ab Quelle hochzählen** | Start bei der ersten Quell-Zeilennummer, dann +10000 | LIN+1 → 10000<br>LIN+2 → 20000<br>LIN+3 → 30000 |
| **Immer +10000** | Erste Zeile = 10000, jede weitere +10000 - unabhängig von der Quelle | Position 1 → 10000<br>Position 2 → 20000<br>Position 3 → 30000 |
| **Freies Intervall** | Schrittweite konfigurierbar | +5000, +1000, +1 |
| **Ab BC-Standard** | Nächste freie Zeilennummer gemäß letzter vorhandener Zeile | Bestand: max 40000 → Neue: 50000, 60000, ... |

> **Konfiguration pro Message-Type:**
> `Line Number Strategy = Always +10000`

---

### 4.3 Zielverhalten: Journal-Vorlagen (Item Journal, G/L Journal, ...)

Wenn das Ziel ein **Journal** ist (Item Journal, G/L Journal, Cash Receipt Journal, ...), muss das System wissen, **welche Vorlage und welcher Name** verwendet werden soll:

```
Ziel-Tabelle: Item Journal Line (83)
──────────────────────────────────────
Journal Template:   ITEM          ← konfigurierbar
Journal Batch:      EDI-IMPORT    ← konfigurierbar
Posting Date:       Aus Quelle    ← konfigurierbar
Auto-Posten:        Nein          ← konfigurierbar
```

**Weitere Journal-spezifische Einstellungen:**

| Einstellung | Beschreibung | Beispiel |
|---|---|---|
| **Journal Template Name** | Vorlage (z.B. ITEM, CASH, GENERAL) | `ITEM` |
| **Journal Batch Name** | Batch-Name innerhalb der Vorlage | `EDI-IMPORT` |
| **Auto-Posten** | Soll das Journal nach Import automatisch gebucht werden? | Ja / Nein / Nur wenn fehlerfrei |
| **Posten-Prüfung vor Buchung** | Vor dem Buchen Validierung durchführen | Ja |
| **Buchungsdatum** | Woher kommt das Buchungsdatum? | Aus Quelle / Arbeitsdatum / Heute / Fixes Datum |
| **Belegnummer** | Woher kommt die Belegnummer? | Aus Quelle / Nummernkreis / Manuell vergeben |

> **Das ist relevant für:**
> - Artikel-Import → Item Journal
> - Fibu-Buchungen → General Journal
> - Zahlungseingänge → Cash Receipt Journal
> - Lagerumbuchungen → Item Journal (Umlagerung)

---

### 4.4 Zielverhalten: Standardwerte & Systemfelder

Pro Message-Type können **Default-Werte** und **Systemfeld-Strategien** festgelegt werden, die immer greifen - unabhängig vom Quell-Mapping:

| Feld | Mögliche Quellen | Beispiel-Konfiguration |
|---|---|---|
| **Posting Date** | Aus Quelle / Arbeitsdatum / Heute / Fix | `DTM[137]` aus Quelle, Fallback: `WORKDATE` |
| **Document Date** | Aus Quelle / Heute | Aus Quelle |
| **Location Code** | Aus Quelle / Partner-Default / Global-Default / Fix | Partner-Default: `BLAU`, Fallback: `GRÜN` |
| **Currency Code** | Aus Quelle / Kunden-Standard / Mandantenwährung | Kunden-Standard (aus Debitor) |
| **Dimensions** | Aus Quelle / Partner-Default / Fix / Keine | `SHORTCUTDIM 1-8` konfigurierbar |
| **External Document No.** | Aus Quelle / Leer lassen | Aus Quelle (`BGM.1004`) |
| **Responsibility Center** | Aus Quelle / Partner / Fix | Partner: `NORD` |
| **Shipment Method** | Aus Quelle / Partner-Default | Partner-Default |
| **Language Code** | Aus Quelle / Partner / Mandant | Partner: `DEU` |
| **VAT Bus. Posting Group** | Aus Kunde / Artikel / Fix / Mapping | Aus Kundenstamm |

---

### 4.5 Datensatz-Identifikation: Wie wird der richtige Datensatz gefunden?

> **Nicht jede Nachricht erstellt einen neuen Datensatz.**
> Bei Änderungen (ORDCHG), Stornierungen oder wiederholten Importen muss das System
> **existierende Datensätze finden** - sowohl Header als auch Zeilen.

#### 4.5.1 Header-Identifikation

Wie findet das System den existierenden Verkaufsauftrag, der geändert werden soll?

```
Message-Type: ORDCHG_EDIFACT_IN
Direction:    Inbound
Mode:         Update Existing

HEADER-IDENTIFIKATION:
┌─────────────────────────────────────────────────────────┐
│ Suchstrategie: Exact Match                               │
│                                                          │
│ 1️⃣  Externe Belegnummer                                  │
│     └─ RFF+ON:PO-2026-0042 → Sales Header."External     │
│        Document No." = 'PO-2026-0042'                    │
│                                                          │
│ 2️⃣  (Fallback) Kunde + Bestelldatum                      │
│     └─ Kombination aus Sell-to Customer + Order Date     │
│                                                          │
│ 3️⃣  (Fallback) Partner-Referenz                          │
│     └─ NAD+BY... + RFF+CR...                             │
└─────────────────────────────────────────────────────────┘
```

**Konfigurierbare Suchstrategien:**

| Strategie | Beschreibung | Wann sinnvoll? |
|---|---|---|
| **Externe Belegnummer** | `Sales Header."External Document No."` = Quellwert | ORDCHG, ORDRSP (Inbound) |
| **BC-Belegnummer** | `Sales Header."No."` = Quellwert | Wenn Kunde die BC-Nummer kennt |
| **Primärschlüssel** | Direkt auf den PK der Zieltabelle | Nur bei system-internen Prozessen |
| **Partner-Referenz + Datum** | Kombination aus zwei Quellfeldern | Wenn keine eindeutige Nummer existiert |
| **Mehrere Felder** | Freie Kombination aus N Quellfeldern | Komplexe Matching-Logik |

**Was passiert, wenn...**

| Situation | Konfigurierbare Reaktion |
|---|---|
| Kein Treffer | Fehler ("Originalauftrag nicht gefunden") / Neuen anlegen / Warnung + manuelle Prüfung |
| Mehrere Treffer | Fehler ("Nicht eindeutig") / Ersten nehmen / Neuesten nehmen / Manuelle Auswahl |
| Auftrag bereits gebucht | Fehler ("Auftrag ist bereits fakturiert") / Nur lesbar öffnen |

---

#### 4.5.2 Zeilen-Identifikation

Wenn eine Änderungsdatei kommt - wie findet das System die **richtige Zeile** im existierenden Auftrag?

```
ORDCHG kommt an:
  LIN+1++ART-001:SA'     ← Zeile 1: Artikel ändern
  QTY+21:80'             ← Neue Menge: 80 statt 100
  LIN+3++ART-003:SA'     ← Zeile 3: Artikel ändern
  QTY+21:200'            ← Neue Menge: 200 statt 150

Welche BC-Zeile ist gemeint?
```

**Konfigurierbare Zeilen-Suchstrategien:**

| Strategie | Beschreibung | Beispiel |
|---|---|---|
| **Quell-Zeilennummer** | Die Zeilennummer aus der Quelldatei = `Sales Line."Line No."` | LIN+1 → Line 10000<br>LIN+3 → Line 30000 |
| **Artikelnummer** | `Sales Line."No."` = Artikel aus Quelle | LIN+...+ART-001 → Zeile mit Artikel ART-001 |
| **Artikel + Variante** | Kombination aus Artikel und Variantencode | ART-001 + BLAU |
| **Externe Zeilenreferenz** | `Sales Line."External Line No."` oder ähnliches Feld | RFF+LI:5 → Zeile mit externer Referenz 5 |
| **Position im Quell-Dokument** | Reihenfolge in der Datei = Reihenfolge in BC | 1. Zeile in Datei = 1. Zeile in BC |
| **Mehrere Felder** | Freie Kombination: z.B. Artikel + Lagerort | ART-001 + BLAU |

**Konfiguration pro Message-Type (Beispiel ORDCHG):**

```
ZEILEN-IDENTIFIKATION:
┌─────────────────────────────────────────────────────────┐
│ Primäre Strategie:   Quell-Zeilennummer                  │
│                                                          │
│ LIN+1 → Sales Line."Line No." = 10000                   │
│ LIN+2 → Sales Line."Line No." = 20000                   │
│                                                          │
│ Fallback-Strategie:  Artikelnummer                       │
│ (wenn Zeile nicht existiert)                              │
│                                                          │
│ Kein Treffer:         Neue Zeile anlegen                  │
│ Mehrfach-Treffer:     Fehler: "Artikel mehrfach im        │
│                       Auftrag - bitte prüfen"             │
└─────────────────────────────────────────────────────────┘
```

---

### 4.6 Verarbeitungsmodi: Create, Update, Delete?

Pro Message-Type wird definiert, **welche Operationen** erlaubt sind:

| Modus | Beschreibung | Typisches Beispiel |
|---|---|---|
| **Create Only** | Nur neue Datensätze anlegen | ORDERS (Neubestellung) |
| **Update Only** | Nur bestehende ändern | ORDCHG (Auftragsänderung) |
| **Create or Update** | Neuanlage wenn nicht vorhanden, sonst ändern | Artikel-Import (Katalog-Update) |
| **Delete** | Datensätze löschen | Bereinigung veralteter Daten |
| **Sync** | Vollabgleich: Nicht mehr in Datei = löschen | Komplett-Import eines Artikelkatalogs |

### 4.7 Beispiel: Item Journal Line als Ziel

Eine typische Konfiguration für einen Artikel-Import:

```
MESSAGE-TYPE: ITEM_IMPORT_CSV
─────────────────────────────────────────────────────────
Ziel-Tabelle:     Item Journal Line (83)
Journal Template: ITEM
Journal Batch:    EDI-MONAT-IMPORT
Mode:             Create Only

Zeilen-Nummerierung:      Immer +10000
Posting Date:             Aus Quelle (Spalte 2), Fallback: WORKDATE
Location Code:            Partner-Default: LAGER-NORD
Document No.:             Nummernkreis: ITEM-JRNL
Auto-Posten:              Nein (manuelle Prüfung)

MAPPING (Auszug):
┌──────────────┬───────────────┬──────────────────────┐
│ Quelle        │ BC-Feld        │ Transform            │
├──────────────┼───────────────┼──────────────────────┤
│ COL[0]        │ Item No.       │ Lookup: Item         │
│ COL[1]        │ Posting Date   │ Format: DD.MM.YYYY   │
│ COL[2]        │ Quantity       │ Direct               │
│ COL[3]        │ Unit Cost      │ Direct               │
│ (const)       │ Entry Type     │ Const: Pos. Adjmt.   │
│ (const)       │ Gen. Bus. PG.  │ Const: INLAND        │
│ (const)       │ Gen. Prod. PG. │ Const: HANDEL        │
└──────────────┴───────────────┴──────────────────────┘
```

### 4.8 Beispiel: ORDCHG - Änderung einer bestehenden Bestellung

```
MESSAGE-TYPE: ORDCHG_D97A_IN
─────────────────────────────────────────────────────────
Ziel-Tabelle:     Sales Header (36)
Sub-Tabelle:      Sales Line (37)
Mode:             Update Only

HEADER-FINDUNG:
  Primär:   Sales Header."External Document No." = RFF+ON
  Kein Treffer → Fehler
  Mehrere Treffer → Ersten nehmen (nach Order Date DESC)

ZEILEN-FINDUNG:
  Strategie: Position im Quell-Dokument
  LIN+1 → Sales Line mit Line No. 10000
  LIN+3 → Sales Line mit Line No. 30000

  Kein Treffer → Neue Zeile anfügen

  Aktion pro Zeile:
  · QTY ändert sich → Menge in Sales Line überschreiben
  · DTM ändert sich → Lieferdatum überschreiben
  · LIN ohne QTY/DTM → Zeile STORNIEREN

  Wenn Position in Datei fehlt:
  · Zeile war LIN+2 → Fehlt in Datei → Auf Storno-Flag setzen
```

---

## 5. Was wird mit dem Kunden vereinbart?

Bevor der EDI-Austausch startet, müssen diese Fragen geklärt sein:

### 4.1 Technische Vereinbarung

| Frage | Beispiel-Antworten |
|---|---|
| **Welches Format?** | EDIFACT D.97A / CSV mit Semikolon / XML / JSON |
| **Welche Kodierung?** | UTF-8 / ISO-8859-1 / Windows-1252 |
| **Wie wird übertragen?** | E-Mail-Anhang / SFTP / REST-API / Kundenportal-Download |
| **Welche Nachrichtentypen?** | ORDERS (Eingang), ORDRSP (Ausgang), DESADV (Ausgang), INVOIC (Ausgang) |
| **Welche Dateiendung?** | `.edi` / `.csv` / `.xml` / `.json` |
| **Testphase?** | 2 Wochen Parallelbetrieb mit Testdaten |

### 4.2 Inhaltliche Vereinbarung (ORDERS Beispiel)

| Frage | Beispiel-Antwort |
|---|---|
| **Welche Felder liefert der Kunde?** | Bestellnummer, Datum, GLN, Artikelnummer (Lieferant), Menge, Preis |
| **Artikelreferenz?** | Kunde verwendet **seine** Artikelnummern → Mapping-Tabelle nötig |
| **Mengeneinheit?** | Kunde bestellt in `PC` (Piece) → BC verwendet `STK` (Stück) |
| **Preise?** | Kunde schickt Preis mit / BC-Preis gilt / Abweichung prüfen |
| **Lieferadresse?** | Aus GLN / NAD-Segment / Immer Hauptadresse? |
| **Teillieferungen?** | Erlaubt? Maximal wie viele? |
| **Auftragsänderung?** | ORDCHG unterstützt? Nur vor Warenausgang? |
| **Rückmeldung?** | Immer ORDRSP? Nur bei Abweichung? Innerhalb 1 Stunde? |

### 4.3 Mapping-Tabelle absprechen

Wenn der Kunde eigene Artikelnummern verwendet, wird eine **Mapping-Tabelle** benötigt:

```
┌─── Was der Kunde schickt ───┐    ┌─── Was in BC steht ───┐
│                              │    │                        │
│ PC              (Menge)      │───▶│ STK (Stück)            │
│ CS              (Menge)      │───▶│ KAR (Karton)           │
│ PAL             (Menge)      │───▶│ PAL (Palette)          │
│                              │    │                        │
│ ART-001         (Artikel)    │───▶│ ITEM-0001              │
│ EAN-4001234567890 (Artikel)  │───▶│ ITEM-0002              │
│                              │    │                        │
│ 14T3%30T        (Zahlung)    │───▶│ 14 TAGE 3% 30 NETTO    │
│ VST             (Steuer)     │───▶│ MWST-19                │
└──────────────────────────────┘    └────────────────────────┘
```

> Diese Tabelle wird **einmal pro Kunde** gepflegt - danach läuft alles automatisch.

### 4.4 Test-Szenario vereinbaren

1. Kunde sendet **1 Test-Bestellung** mit allen möglichen Varianten
2. BC importiert → Staging → Prüfung durch Sachbearbeiter
3. Korrekturen dokumentieren → Mapping anpassen
4. Kunde sendet **5 Test-Bestellungen** über 3 Tage verteilt
5. Nach erfolgreichem Test: Produktiv-Schaltung

---

## 6. Wie wird empfangen?

### 5.1 Der Empfangsweg

Drei mögliche Wege - wählbar pro Partner:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     EMPFANGSWEGE                                     │
│                                                                      │
│  1 REST-API                                                         │
│     Externes System → POST /api/edi-transfer → BC (sofort)          │
│                                                                      │
│  2 Automatischer Abruf (Job)                                        │
│     BC Job läuft alle X Minuten → Holt Dateien vom SFTP/FTP        │
│                                                                      │
│  3 Manueller Upload                                                 │
│     Sachbearbeiter → Datei hochladen in BC                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 Was passiert mit der eingehenden Datei? (7 Schritte)

```
SCHRITT 1 ─ EINGANG
──────────────
  Die Datei erscheint in der EDI-Transfer-Liste.
  Status: Neu
  Der Sachbearbeiter sieht: Datum, Partner, Dateiname, Format.

SCHRITT 2 ─ PARSING
──────────────
  Das System erkennt automatisch das Format
  und zerlegt die Datei in ihre Einzelfelder.
  Status: In Verarbeitung

SCHRITT 3 ─ MAPPING
──────────────
  Die Felder werden gemäß der Mapping-Konfiguration
  in die Staging-Tabelle übertragen.
  Ergebnis: Eine Vorschau des zukünftigen Verkaufsauftrags.

SCHRITT 4 ─ VALIDIERUNG
──────────────
  Alle Validierungsregeln werden angewendet:
  · Pflichtfelder vorhanden?    ✓
  · Artikel existiert?          ✓
  · Mengen > 0?                 ✓
  · Kunde bekannt?              ✓

  Bei Fehlern: Staging-Status = Fehlerhaft

SCHRITT 5 ─ PRÜFUNG (optional, konfigurierbar)
──────────────
  Der Sachbearbeiter öffnet die Staging-Liste:
  · Alle fehlerfreien Importe → grün
  · Importe mit Warnungen → gelb
  · Importe mit Fehlern → rot

  Er kann:
  · Daten korrigieren (z.B. Artikelnummer anpassen)
  · Import ablehnen (zurück an Kunde)
  · Import freigeben (→ weiter zu Schritt 6)

SCHRITT 6 ─ VERARBEITUNG
──────────────
  Aus dem Staging-Eintrag wird ein BC-Dokument erstellt:
  · Sales Header + Sales Lines
  · Oder: Item, Purchase Order, G/L Entry, ...
  Das Original bleibt im Staging erhalten.

SCHRITT 7 ─ RÜCKMELDUNG
──────────────
  Bei Erfolg:
  · APERAK/Statusmeldung an Kunden (wenn vereinbart)
  · Outbound ORDRSP wird getriggert

  Bei Fehler:
  · Fehlerprotokoll für Sachbearbeiter
  · Ggf. E-Mail-Benachrichtigung
```

### 5.3 Automatische vs. manuelle Verarbeitung

Pro Nachrichtentyp einstellbar:

| Modus | Beschreibung | Wann sinnvoll? |
|---|---|---|
| **Vollautomatisch** | Datei kommt an → direkt BC-Dokument | Langjähriger Partner, hohe Datenqualität |
| **Halbautomatisch** | Datei kommt an → bei Fehlern manuelle Prüfung | Neue Partner, gelegentliche Abweichungen |
| **Manuell** | Jede Datei muss freigegeben werden | Neueinrichtung, Testphase, kritische Vorgänge |

---

## 7. Wie kann ich korrigieren?

### 6.1 Korrekturmöglichkeiten im Überblick

```
┌───────────────────────────────────────────────────────────────────────┐
│                     KORREKTUR-MÖGLICHKEITEN                           │
│                                                                       │
│  EBENE 1: Staging-Daten korrigieren                                   │
│  ┌─────────────────────────────────────────────────────────────┐     │
│  │ Der Sachbearbeiter öffnet den Staging-Eintrag und überschreibt│     │
│  │ einzelne Felder:                                             │     │
│  │                                                              │     │
│  │  Artikel:  ART-001  →  ART-001-BLAU  (falsche Variante)     │     │
│  │  Menge:    100      →  80            (zu viel bestellt)      │     │
│  │  Lieferdat:15.07.   →  22.07.       (realistischer)         │     │
│  │                                                              │     │
│  │  [Erneut prüfen]  [Verwerfen]  [Freigeben]                  │     │
│  └─────────────────────────────────────────────────────────────┘     │
│                                                                       │
│  EBENE 2: Mapping-Konfiguration anpassen                              │
│  ┌─────────────────────────────────────────────────────────────┐     │
│  │ Wenn ein Fehler systematisch auftritt (z.B. Kunde liefert   │     │
│  │ Artikel immer in Spalte 4 statt 3), wird das Mapping        │     │
│  │ einmalig korrigiert - alle zukünftigen Importe sind richtig. │     │
│  └─────────────────────────────────────────────────────────────┘     │
│                                                                       │
│  EBENE 3: Mapping-Tabelle ergänzen                                    │
│  ┌─────────────────────────────────────────────────────────────┐     │
│  │ Neue Artikel, neue Mengeneinheiten:                          │     │
│  │                                                              │     │
│  │  Kunde schickt:  PAL2  →  Nicht gefunden → Fehler           │     │
│  │  Lösung: PAL2 → PAL in Mapping-Tabelle eintragen             │     │
│  │  → Alle zukünftigen PAL2 werden richtig erkannt              │     │
│  └─────────────────────────────────────────────────────────────┘     │
│                                                                       │
│  EBENE 4: Bereits erstellten BC-Beleg korrigieren                     │
│  ┌─────────────────────────────────────────────────────────────┐     │
│  │ Wenn der Auftrag schon angelegt wurde, aber falsch ist:      │     │
│  │  → Direkt im Verkaufsauftrag korrigieren (BC-Standard)      │     │
│  │  → Verkaufsauftrag stornieren + neuer manueller Auftrag      │     │
│  └─────────────────────────────────────────────────────────────┘     │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

### 6.2 Typische Korrektur-Szenarien

| Situation | Was der Sachbearbeiter tut |
|---|---|
| **Artikel nicht gefunden** | Staging öffnen → Artikelnummer korrigieren → Erneut prüfen |
| **Falscher Kunde** | Staging öffnen → abweichenden Debitor auswählen → Erneut prüfen |
| **Mengeneinheit passt nicht** | Mapping-Tabelle ergänzen: `CS` → `KAR` → Alle zukünftigen CS werden richtig gemappt |
| **Liefertermin in Vergangenheit** | Staging öffnen → Datum korrigieren → Erneut prüfen |
| **Kunde hat Bestellung storniert** | Staging-Eintrag verwerfen → Nicht verarbeiten |
| **Duplikat** | System erkennt Duplikat (gleiche Bestellnummer) → Warnung |
| **Kunde will ursprüngliche Bestellung ändern** | ORDCHG kommt an → bestehender Auftrag wird geändert |

### 6.3 Das Staging-Prinzip

> **Jede eingehende Datei landet zuerst im Staging - nicht direkt im BC-Beleg.**

Das Staging ist der **Sicherheitspuffer** zwischen Kundendaten und BC-Dokument:

```
Kundendatei    →    STAGING    →    BC-Verarbeitung
                     │
                     ├─ Daten einsehbar
                     ├─ Daten änderbar
                     ├─ Fehler markiert
                     ├─ Historie erhalten
                     └─ Manuelle Freigabe möglich
```

Vorteile:
- Keine "halbfertigen" Verkaufsaufträge
- Fehler werden vor der Verarbeitung gefunden
- Der Original-Dateninhalt bleibt erhalten
- Nachvollziehbar: Wer hat was wann geändert?

---

## 8. Wie wird versendet?

### 7.1 Der Versandweg

```
┌─────────────────────────────────────────────────────────────────────┐
│                     VERSANDWEGE                                      │
│                                                                      │
│  A Automatisch (Business Event)                                     │
│     BC bucht Warenausgang → DESADV automatisch erzeugen & senden   │
│                                                                      │
│  B Automatisch (Job-gesteuert)                                      │
│     BC Job läuft stündlich → Holt offene Outbound-Einträge         │
│     → Erzeugt Datei → Stellt sie auf SFTP/FTP bereit                │
│                                                                      │
│  C Manuell                                                         │
│     Sachbearbeiter → "Jetzt senden" → Datei wird erzeugt            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 Was passiert beim Versand? (4 Schritte)

```
SCHRITT 1 ─ AUSLÖSER
──────────────
  Ein BC-Ereignis stößt die Outbound-Erzeugung an:

  ┌──────────────────────────────┬────────────────────┐
  │ BC-Ereignis                  │ Erzeugt             │
  ├──────────────────────────────┼────────────────────┤
  │ Verkaufsauftrag freigegeben  │ ORDRSP (Bestätigung)│
  │ Warenausgang gebucht         │ DESADV (Lieferavis) │
  │ Verkaufsrechnung gebucht     │ INVOIC (Rechnung)   │
  └──────────────────────────────┴────────────────────┘

SCHRITT 2 ─ REVERSE MAPPING
──────────────
  BC-Dokument → Staging-Tabelle (rückwärts gemappt):
  · Sales Header → Header-Daten
  · Sales Lines → Positionsdaten
  · Dynamische Mappings werden umgekehrt (STK → PC)

SCHRITT 3 ─ ENCODIERUNG
──────────────
  Staging-Daten → Zielformat:
  · EDIFACT: Encoder erzeugt UNB...UNH...Segmente...UNT...UNZ
  · CSV: Spalten mit konfiguriertem Trennzeichen
  · XML: XML-Dokument nach konfigurierter Struktur
  · JSON: JSON-Objekt nach konfigurierter Struktur
  · TXT: Feste Spaltenbreiten

SCHRITT 4 ─ AUSGANG
──────────────
  Datei wird bereitgestellt:
  · Per REST: GET /api/edi-transfer → Kunde holt Datei ab
  · Per SFTP: Datei liegt auf vereinbartem Server
  · Per E-Mail: Datei wird als Anhang versendet

  Status: Gesendet
```

### 7.3 Was wird wann versendet?

```
KUNDE                                    BUSINESS CENTRAL
─────                                    ───────────────

1 Sendet ORDERS ──────────────────────────▶ Sales Order wird angelegt
                                            │
2 ◀─────────────────────────────────────── ORDRSP wird versendet
   ("Bestellung bestätigt,                 (sofort nach Freigabe)
    lieferbar in KW 28")

                                            │ Warenausgang gebucht
3 ◀─────────────────────────────────────── DESADV wird versendet
   ("Lieferung unterwegs:                  (nach Warenausgang)
    2 Paletten, Tracking: DHL-123")

                                            │ Rechnung gebucht
4 ◀─────────────────────────────────────── INVOIC wird versendet
   ("Rechnung Nr. RG-2026-0042             (nach Rechnungsstellung)
    über 2.500,00 €, fällig 30 Tage")
```

---

## 9. Sonderfälle & Fehlerbehandlung

### 8.1 Was passiert wenn...

| Situation | Verhalten |
|---|---|
| **Datei ist beschädigt** | Parsing-Fehler → Staging-Status = Fehler → Sachbearbeiter wird benachrichtigt → Kunde sendet erneut |
| **Artikel existiert nicht** | Validierungs-Fehler → Staging zeigt fehlenden Artikel → Sachbearbeiter klärt: Neuanlage oder Korrektur |
| **Gleiche Bestellnummer kommt zweimal** | Duplikats-Prüfung → Warnung "Bereits importiert" → Manuelle Entscheidung: Überspringen oder trotzdem verarbeiten |
| **Kunde widerruft Bestellung** | Je nach Konfiguration: ORDCHG mit Storno / Manuelle Stornierung im Staging / E-Mail an Sachbearbeiter |
| **Kreditlimit überschritten** | Business-Validierung → Warnung → Manuelle Freigabe durch Vertriebsleitung nötig |
| **Kunde sendet falsches Format** | Format-Engine erkennt Abweichung → "Datei entspricht nicht dem erwarteten Format" → Keine Verarbeitung |
| **Netzwerk-Fehler beim Senden** | Outbound bleibt auf Status "Bereit" → Nächster Job-Lauf wiederholt automatisch |
| **Kunde hat Mapping-Tabelle nicht** | Staging zeigt "Nicht zugeordnet" → Sachbearbeiter pflegt Mapping-Tabelle nach → Erneut validieren |

### 8.2 Benachrichtigungen

Konfigurierbar pro Fehlertyp:

| Ereignis | Benachrichtigung |
|---|---|
| Datei erfolgreich verarbeitet | Keine (nur Log) |
| Datei mit Warnungen | Hinweis im Role Center |
| Datei mit Fehlern | E-Mail an EDI-Verantwortlichen |
| Kritischer Fehler (z.B. doppelte Datei) | E-Mail + Aufgabe im Team-Bereich |
| Kunde antwortet nicht auf Klärung | Eskalation nach X Tagen |

---

## 10. Rollen & Berechtigungen

| Rolle | Darf |
|---|---|
| **EDI-Administrator** | Formate einrichten, Mappings konfigurieren, Partner anlegen, Validierungsregeln definieren |
| **EDI-Sachbearbeiter** | Staging-Einträge prüfen, korrigieren, freigeben, ablehnen |
| **Vertrieb** | Nur lesend auf fertige BC-Belege, keine Staging-Ansicht |
| **Geschäftsleitung** | Dashboards: Wie viele Importe? Fehlerquote? Welcher Partner macht Probleme? |

---

## 11. Einführungsprozess

### 10.1 Übersicht: Von der Anfrage zum produktiven Betrieb

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  1. ANFRAGE         Kunde will EDI → Erstgespräch                   │
│       │                                                              │
│       ▼                                                              │
│  2. ANALYSE         Format analysieren, Felder identifizieren        │
│       │              Beispiel-Datei vom Kunden anfordern              │
│       ▼                                                              │
│  3. VEREINBARUNG    Format, Nachrichtentypen, Felder, Mapping       │
│       │              Übertragungsweg, Test-Szenario                  │
│       ▼                                                              │
│  4. KONFIGURATION   Format anlegen → Felder definieren              │
│       │              → Mappings einrichten → Partner anlegen         │
│       ▼                                                              │
│  5. TEST            Kunde sendet Test-Datei(en)                     │
│       │              → Verarbeitung prüfen → Mapping korrigieren     │
│       │              → Iterativ bis alles passt                      │
│       ▼                                                              │
│  6. ABNAHME         Kunde und BC-Seite bestätigen: Alles korrekt    │
│       │                                                              │
│       ▼                                                              │
│  7. GO-LIVE         Produktiv-Schaltung                              │
│       │              · 2 Wochen Parallel-Monitoring                  │
│       │              · Danach: Regelbetrieb                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 Aufwands-Schätzung pro Kunde (Richtwerte)

| Phase | Aufwand | Wer? |
|---|---|---|
| Analyse & Vereinbarung | 2-4 Stunden | Berater + Kunde |
| Konfiguration (Standardformat) | 1-2 Stunden | EDI-Administrator |
| Konfiguration (Custom-Format) | 4-8 Stunden | EDI-Administrator + Entwickler |
| Mapping-Tabelle pflegen | 0,5-2 Stunden | EDI-Sachbearbeiter |
| Testphase begleiten | 2-4 Stunden | EDI-Sachbearbeiter verteilt über Testphase |
| Go-Live & Monitoring | 1 Stunde | EDI-Administrator |

> **Ziel:** Neuer Kunde mit Standardformat (EDIFACT D.97A ORDERS) soll in **unter 4 Stunden** eingerichtet sein - komplett ohne Entwickler.

---

## Zusammenfassung

| Aspekt | Beschreibung |
|---|---|
| **Formate** | EDIFACT, CSV, TXT, XML, JSON, Custom - alle über eine Pipeline |
| **Einrichtung** | Format definieren → Felder benennen → Zieltabelle + Mapping → Validierung → Partner |
| **Kundenvereinbarung** | Format, Nachrichtentypen, Felder, Mapping-Tabelle, Übertragungsweg, Test-Szenario |
| **Empfang** | API / SFTP-Abruf / Manueller Upload → 7-Schritte-Pipeline → BC-Dokument |
| **Korrektur** | 4 Ebenen: Staging-Felder korrigieren / Mapping anpassen / Mapping-Tabelle ergänzen / BC-Beleg korrigieren |
| **Versand** | BC-Event → Reverse-Mapping → Encodierung → API/SFTP/E-Mail-Ausgang |
| **Fehler** | Staging-Puffer verhindert Datenmüll; klar definierte Eskalation pro Fehlertyp |
| **Rollen** | Administrator (Einrichtung) vs. Sachbearbeiter (Betrieb) |
| **Einführung** | 7 Phasen von Anfrage bis Go-Live, Ziel: < 4h pro Standard-Kunde |

---

> **Version:** 3.0 — Geschäftsprozess-Konzept mit No-Code-Logik
> **Status:** Brainstorming / Design
> **Neu in v3.0:** Kapitel 4 — Automatische BC-Logik (Zeilennummern, Journals, Datensatz-Identifikation)
> **Referenz:** EDIFACTD97_BC.md, BCEDI Confluence Space
