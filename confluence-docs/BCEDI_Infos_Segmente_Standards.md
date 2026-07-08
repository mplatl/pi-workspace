---
title: "Infos zu Segmenten und Standards"
confluence_id: "168591362"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/168591362/Infos+zu+Segmenten+und+Standards"
last_modified: "2025-11-18T22:47:47.780Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.182Z"
---

# Infos zu Segmenten und Standards

Hier ist eine **gedruckfertige Tabelle f&uuml;r Confluence**, die die **Unterschiede bei Segments&auml;tzen** zwischen relevanten EDIFACT-Versionen (D.96A, D.99B, D.07A, D.16A, D.21B, D.23A&ndash;D.24A) aufzeigt. Du kannst sie direkt kopieren und bei Bedarf erweitern:

---

## 📊 Segment&auml;nderungen zwischen EDIFACT-Versionen

| Version | Neue/nicht mehr unterst&uuml;tzte Segmente | Kommentar |
| --- | --- | --- |
| **D.96A (1996)** | &ndash; erste umfassende Basis, viele Nachrichten verf&uuml;gbar [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html), [[stedi.com]](https://www.stedi.com/edi/edifact/D96A) | Basis f&uuml;r Automotive, Retail, Logistik [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.99B (1999)** | Automobil-spezifische Erweiterungen | Starker Fokus in Automotive-Branche [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.03A (2003)** | Optimiert f&uuml;r Transport und Zoll | Produktsupport f&uuml;r Transporteintr&auml;ge [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.07A (2007)** | Neue Segmente f&uuml;r Retail & moderne Logistik | Erweiterung f&uuml;r Onlinehandel [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.16A (2016)** | E-Commerce- & API-Support, neue Qualifier | Schnittstellenrelevante Codes erg&auml;nzt [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.21B (2021)** | Healthcare-Nachrichten, neue Segmente, aktualisierte | unter anderem f&uuml;r Gesundheitsbehaviorien, APIs [[edi-facts&hellip;.ogspot.com]](https://edi-facts.blogspot.com/2024/12/different-versions-in-edifact-standard.html) |
| **D.22B (2022)** | Code-Listen und Bezeichneraktualisierungen | Details: [UNECE 2021&ndash;2024 update] citeturn6search28 |
| **D.23A (2023)** | Neue Nachrichten, Segmentfreigaben aktualisiert | siehe UNECE 2021&ndash;2024 [[unece.org]](https://unece.org/uncefact/unedifact/2021-2024) |
| **D.24A (2024)** | Erste Strukturverschiebung f&uuml;r Real-time & Cloud | Segment + Nachrichtenaktualisierungen [[unece.org]](https://unece.org/uncefact/unedifact/2021-2024) |

---

### 🧰 Quellen & Tools zur Detailanalyse
- 
**UN/EDIFACT Directories 2021&ndash;2024** (D.21B&ndash;D.24A): komplette Segment-Verzeichnisse [[unece.org]](https://unece.org/uncefact/unedifact/2021-2024)

- 
**EDIFACTORY**: Nachrichten- & Segmentz&auml;hlung aller Versionen [[edifactory.de]](https://www.edifactory.de/edifact/directories)

- 
**IBM-Datenmapping**: direkte Feld-Ver&auml;nderungen zwischen D.96A&ndash;D.97A [[ibm.com]](https://www.ibm.com/docs/en/b2bis?topic=signing-edifact-data-mapping)

- 
**GEFEG.FX Audit Team**: halbj&auml;hrliche Segment&auml;nderungen protokolliert [[gefeg.com]](https://www.gefeg.com/wp-content/uploads/2023/07/Standards-EDIFACT-Datenpaket-GEFEG.pdf)

---

### 🔹 Auswahlkriterien zum Vergleich
1. 
**Unece‐Kataloge (INSPECT &bdquo;Segment directory Batch EDSD&ldquo;)** halten seit D.21B bis D.24A jeweils:
&ndash; welche Segmente **neu hinzugekommen**,
&ndash; welche **obsolet** sind [[unece.org]](https://unece.org/uncefact/unedifact/2021-2024)

2. 
**IBM-Mapping-Tabellen (D.96A vs D.97A)**
zeigen Feldverschiebungen in **BGM, NAD, RFF, DTM, QTY** etc. [[ibm.com]](https://www.ibm.com/docs/en/b2bis?topic=signing-edifact-data-mapping)

3. 
**EDIFECTORY / XEDI**
enth&auml;lt vollst&auml;ndige **Segmentkataloge** f&uuml;r D.93A &rarr; D.24A;
bietet **segmentweise Filter** und &Auml;nderungen pro Version [[edifactory.de]](https://www.edifactory.de/edifact/directories), [[xedi.com]](https://xedi.com/resources/edifact)

4. 
**GEFEG.FX Directory-Audit-Team**
protokolliert **&Auml;nderungen** in Syntax, Segments&auml;tzen und Unterelementen halbj&auml;hrlich [[gefeg.com]](https://www.gefeg.com/wp-content/uploads/2023/07/Standards-EDIFACT-Datenpaket-GEFEG.pdf)

---

## ✅ Anleitung zur eigenen Vergleichsanalyse
1. 
Lade die **EDSD-Tabellen** der Versionen ab (INSPECT: **Segment directory batch**).

2. 
Extrahiere die **Segment-Tags** jeder Version.

3. 
Erstelle einen **Diff-Vergleich** (z. B. Excel, Confluence‐Tabelle), zeige &bdquo;+ neu&ldquo; / &bdquo;&ndash; entf.&ldquo;.

4. 
Erg&auml;nze **Segment-Anmerkungen** nach Quelle (z. B. DTM-Format&auml;nderung, neue Qualifier-Felder).

5. 
Verteile Tabellenspalten in Confluence:
‑ **Version**, **Segment**, **Status (neu/removed)**, **Kommentar (Begr&uuml;ndung)**.

---

### 🔗 N&uuml;tzliche Links
- 
[UNECE EDIFACT Directories 2021&ndash;2024 (EDSD / EDMD)](https://unece.org/uncefact/unedifact/2021-2024)

- 
[EDIFACTORY: Versionen-Ansicht mit Segment-/Message-Z&auml;hlen](https://www.edifactory.de/edifact/directories)

- 
[XEDI: Vollst&auml;ndige Versionen-Support von D00A bis D.24A](https://xedi.com/resources/edifact)

- 
[IBM Mapping D.96A &harr; D.97A inkl. Segment-Ver&auml;nderungen](https://www.ibm.com/docs/en/b2bis?topic=signing-edifact-data-mapping)

- 
[GEFEG.FX Audit-Protokolle &uuml;ber halbj&auml;hrliche &Auml;nderungen](https://www.gefeg.com/wp-content/uploads/2023/07/Standards-EDIFACT-Datenpaket-GEFEG.pdf)

---

📌 Nun hast du eine **kopierf&auml;hige Tabelle & Recherche-Checkliste**, um gezielt **unterschiedliche EDIFACT-Versionen nach Segment-Abweichungen** zu vergleichen und in Confluence darzustellen. Let me know if you need help automating the diff.

Soll ich dir gleich eine **vollst&auml;ndige Vergleichstabelle mit allen Segmenten und deren Status (neu/entfernt/ge&auml;ndert) f&uuml;r D96A bis D24A** erstellen?
