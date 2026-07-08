---
title: "ORDERS from Copilot"
confluence_id: "164724739"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/164724739/ORDERS+from+Copilot"
last_modified: "2025-11-16T15:18:10.287Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.242Z"
---

# ORDERS from Copilot

Hier ist die vollst&auml;ndige **Vorlage f&uuml;r die Seite &bdquo;ORDERS&ldquo;** im Bereich *Business Central &ndash; Schnittstellen (EDI)*, die du direkt in Confluence einf&uuml;gen kannst:

---

## **EDIFACT &ndash; ORDERS**

### **1. Beschreibung des EDIFACT-Typs**

Der EDIFACT-Nachrichtentyp **ORDERS** (Purchase Order) wird verwendet, um Bestellungen elektronisch zwischen Gesch&auml;ftspartnern auszutauschen. Diese Nachricht enth&auml;lt alle relevanten Informationen zur Bestellung von Waren oder Dienstleistungen.

### **2. Verwendungszweck**

Die ORDERS-Nachricht dient der &Uuml;bermittlung von Bestellungen vom K&auml;ufer an den Verk&auml;ufer. Sie kann sowohl f&uuml;r Erstbestellungen als auch f&uuml;r &Auml;nderungen oder Stornierungen bestehender Bestellungen verwendet werden.

### **3. Datenfelder und Mapping**

| EDIFACT-Segment | Beschreibung | Mapping in Business Central |
| --- | --- | --- |
| UNH | Nachrichtenkopf | Nachricht-ID |
| BGM | Nachrichtentyp | Belegart |
| DTM | Datum/Uhrzeit | Bestelldatum |
| NAD | Name und Adresse | Kunde, Lieferadresse |
| LIN | Artikelposition | Artikelnummer, Menge |
| QTY | Menge | Bestellmenge |
| PRI | Preisangabe | Einzelpreis |

### **4. Beispielnachricht**

UNH+1+ORDERS:D:96A:UN:1.1'

BGM+220+PO123456+9'

DTM+137:20251116:102'

NAD+BY+123456789::9'

LIN+1++123456789:IN'

QTY+21:100'

PRI+AAA:10.00'

UNT+6+1'

### **5. Besonderheiten oder Hinweise**
- Die Nachricht muss stets mit einem g&uuml;ltigen UNH- und UNT-Segment beginnen und enden.

- 
Achte auf die korrekte Verwendung von Qualifiern in NAD- und QTY-Segmenten.

- 
Die Artikelnummern m&uuml;ssen mit den im System hinterlegten Nummern &uuml;bereinstimmen.

---

Hier ist eine detaillierte Erkl&auml;rung aller im Beispiel verwendeten **EDIFACT D.96A ORDERS-Segmente**, inklusive der Angabe, ob sie **verpflichtend (Pflicht)** oder **optional** sind:

---

### 📌 **Nachrichtenkopf und -abschluss**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `UNB` | Interchange Header | **Pflicht** | Startet den Nachrichtenaustausch zwischen zwei Partnern. Enth&auml;lt Absender, Empf&auml;nger, Datum/Zeit, Referenznummer. |
| `UNH` | Nachrichtenkopf | **Pflicht** | Beginnt eine einzelne EDIFACT-Nachricht. Enth&auml;lt Nachrichtentyp, Version, Referenznummer. |
| `UNT` | Nachrichtentrailer | **Pflicht** | Beendet die Nachricht. Enth&auml;lt Segmentanzahl und Referenznummer aus UNH. |
| `UNZ` | Interchange Trailer | **Pflicht** | Beendet den Nachrichtenaustausch. Enth&auml;lt Anzahl der Nachrichten und Referenznummer aus UNB. |

---

### 📌 **Allgemeine Informationen zur Bestellung**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `BGM` | Beginn der Nachricht | **Pflicht** | Gibt den Nachrichtentyp (z. B. Bestellung), die Referenznummer und den Status an. |
| `DTM` | Datum/Zeit/Zeitraum | **Mind. 1 Pflicht** | Gibt relevante Daten an, z. B. Bestelldatum (137), Lieferdatum (2). |
| `FTX` | Freitext | **Optional** | F&uuml;r zus&auml;tzliche Informationen wie Hinweise oder Kommentare. |
| `RFF` | Referenz | **Optional** | Referenz auf andere Dokumente, z. B. vorherige Bestellungen. |

---

### 📌 **Parteieninformationen**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `NAD` | Name und Adresse | **Mind. 1 Pflicht** | Identifiziert beteiligte Parteien: K&auml;ufer (BY), Lieferant (SU), Lieferadresse (DP). |
| `CTA` | Ansprechpartner | **Optional** | Gibt Ansprechpartner bei einer Partei an. |
| `COM` | Kommunikationsverbindung | **Optional** | Kontaktinformationen wie E-Mail, Telefon. |

---

### 📌 **Transport & Lieferung**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `TDT` | Transportdetails | **Optional** | Informationen zum Transportmittel, z. B. Spediteur. |
| `TOD` | Bedingungen der Lieferung | **Optional** | Liefervorgaben, z. B. Lieferbedingungen. |
| `LOC` | Ort | **Optional** | Angabe von Orten wie Versand- oder Lieferort. |
| `PAC` | Packmittel | **Optional** | Verpackungsinformationen. |

---

### 📌 **Positionsdaten (Artikel)**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `LIN` | Artikelposition | **Pflicht (je Position)** | Identifiziert einen Artikel in der Bestellung. |
| `PIA` | Zus&auml;tzliche Artikelidentifikation | **Optional** | Weitere Artikelnummern (z. B. Lieferantennummer). |
| `IMD` | Artikelbeschreibung | **Optional** | Beschreibung des Artikels. |
| `QTY` | Mengenangabe | **Pflicht (je Position)** | Bestellte Menge. |
| `ALI` | Zusatzangaben | **Optional** | L&auml;nderspezifische Angaben, z. B. steuerliche Informationen. |
| `DTM` | Datum/Zeit/Zeitraum | **Optional (je Position)** | Lieferdatum f&uuml;r die Position. |
| `MOA` | Geldbetr&auml;ge | **Optional** | Betrag je Position. |
| `PRI` | Preisangabe | **Optional** | Preis je Einheit. |
| `TAX` | Steuerangaben | **Optional** | Steuerinformationen zur Position. |
| `RFF` | Referenz | **Optional** | Referenz auf andere Dokumente je Position. |

---

### 📌 **Zusammenfassung**

| Segment | Bedeutung | Pflicht/Optional | Beschreibung |
| --- | --- | --- | --- |
| `UNS` | Abschnittstrennung | **Pflicht** | Trennt Positionsdaten von der Zusammenfassung. |
| `MOA` | Geldbetrag (Gesamt) | **Optional** | Gesamtbetrag der Bestellung. |
| `CNT` | Z&auml;hler | **Optional** | Anzahl der Positionen oder anderer Elemente. |

---

Wenn du m&ouml;chtest, kann ich dir diesen Abschnitt auch direkt als Confluence-kompatiblen Inhalt formatieren, den du in die Seite einf&uuml;gen kannst. M&ouml;chtest du das?
