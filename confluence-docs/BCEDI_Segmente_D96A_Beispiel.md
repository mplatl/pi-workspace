---
title: "Segmente D96A Beispiel"
confluence_id: "168329220"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/168329220/Segmente+D96A+Beispiel"
last_modified: "2025-11-18T22:44:39.831Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.300Z"
---

# Segmente D96A Beispiel

Hier ist eine **vollst&auml;ndige Erkl&auml;rung f&uuml;r Confluence** basierend auf **UN/EDIFACT DESADV D.96A**. Du kannst den Text direkt kopieren und in Confluence einf&uuml;gen:

---

## **UN/EDIFACT DESADV D.96A &ndash; Segmentgruppen (SG1&ndash;SG23)**

### **&Uuml;berblick**

Die Nachricht **DESADV (Dispatch Advice)** dient zur &Uuml;bermittlung von Versandinformationen. Sie ist hierarchisch aufgebaut:

```
Nachricht → Segmentgruppen (SG) → Segmente → Datenelemente

```

---

### **Segmentgruppen im Detail**

#### **SG1 &ndash; Referenzen**
- 
**Segmente:** `RFF`, `DTM`

- 
**Beschreibung:** Enth&auml;lt Referenznummern (z. B. Bestellnummer) und zugeh&ouml;rige Datumsangaben.

---

#### **SG2 &ndash; Parteien und Adressen**
- 
**Segmente:** `NAD`

- 
**Beschreibung:** Identifiziert beteiligte Parteien (Lieferant, Kunde, Spediteur).

---

#### **SG3 &ndash; Referenzen zu Partei**
- 
**Segmente:** `RFF`

- 
**Beschreibung:** Zus&auml;tzliche Referenzen f&uuml;r die in SG2 genannte Partei.

---

#### **SG4 &ndash; Kontaktinformationen**
- 
**Segmente:** `CTA`, `COM`

- 
**Beschreibung:** Ansprechpartner und Kommunikationsdaten.

---

#### **SG5 &ndash; Lieferbedingungen**
- 
**Segmente:** `TOD`, `FTX`

- 
**Beschreibung:** Transport- und Lieferbedingungen, optionale Freitexte.

---

#### **SG6 &ndash; Transportdetails**
- 
**Segmente:** `TDT`

- 
**Beschreibung:** Angaben zum Transportmittel und -weg.

---

#### **SG7 &ndash; Ort und Datum**
- 
**Segmente:** `LOC`, `DTM`

- 
**Beschreibung:** Versand- und Lieferorte mit Datum.

---

#### **SG8 &ndash; Ausr&uuml;stung**
- 
**Segmente:** `EQD`, `MEA`, `SEL`

- 
**Beschreibung:** Angaben zu Ger&auml;ten oder Beh&auml;ltern.

---

#### **SG10 &ndash; Konsignationsstruktur**
- 
**Segmente:** `CPS`, `FTX`

- 
**Beschreibung:** Hierarchische Struktur der Lieferung (z. B. Paletten, Kartons).

---

#### **SG11 &ndash; Verpackung**
- 
**Segmente:** `PAC`

- 
**Beschreibung:** Verpackungsdetails (Art, Anzahl).

---

#### **SG13 &ndash; Packkennzeichnung**
- 
**Segmente:** `PCI`, `QTY`

- 
**Beschreibung:** Kennzeichnung und Mengenangaben f&uuml;r Verpackungseinheiten.

---

#### **SG14 &ndash; Identnummern**
- 
**Segmente:** `GIN`

- 
**Beschreibung:** Seriennummern, SSCC-Codes.

---

#### **SG15 &ndash; Artikelposition**
- 
**Segmente:**
`LIN` (Pflicht), `PIA`, `IMD`, `MEA`, `QTY`, `ALI`, `GIN`, `DTM`, `FTX`, `RFF`, `DOC`

- 
**Beschreibung:** Alle Details zu einer Artikelposition (Nummern, Beschreibung, Mengen, Referenzen).

---

#### **SG16&ndash;SG21 &ndash; Untergruppen**
- 
**Beschreibung:** Zus&auml;tzliche Details wie Chargen, Komponenten, Verpackung auf Artikelebene.

---

#### **SG23 &ndash; Zusammenfassung**
- 
**Segmente:** `QVR`, `CNT`

- 
**Beschreibung:** Mengenabweichungen und Summen.

---

### **Hierarchie-Beispiel**

```
UNH – Nachrichtenkopf
BGM – Nachrichtentyp
DTM – Datum/Zeit
SG1 – Referenzen
SG2 – Parteien
SG10 – Konsignationsstruktur
   SG11 – Verpackung
      SG13 – Packkennzeichnung
      SG15 – Artikelposition
UNT – Nachrichtenende

```

---

### **Hinweise**
- 
Die Segmentgruppen sind **nachrichtenspezifisch**. DESADV D.96A hat **SG1 bis SG23**.

- 
Jede SG kann optionale oder wiederholbare Segmente enthalten.

- 
F&uuml;r Implementierungen: Siehe **UN/EDIFACT Directory D.96A**.

---

✅ Soll ich dir zus&auml;tzlich eine **grafische &Uuml;bersicht (Diagramm) der Hierarchie f&uuml;r Confluence** erstellen oder eine **Tabelle mit allen SG und Segmenten als Markdown**?
