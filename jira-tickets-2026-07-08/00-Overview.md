# Jira Tickets — Planung 08.07.2026

> Quelle: https://erp-jira.cegeka.com/
> Download: 07.07.2026

---

## GARA-188
**Status:** In Progress | **Priorität:** Critical | **Typ:** Support
**Assignee:** Michael Platl | **Reporter:** Roland Haunschmied
**Erstellt:** 2026-06-11T12:12:53.000+0200 | **Aktualisiert:** 2026-07-06T16:43:50.000+0200

### Beschreibung
Hallo,

wir haben hier ein Problem bei der Preisberechnung von Verkaufsaufträgen festgestellt.

Ich habe den Ablauf in der TEST-Umgebung 1 nachgestellt. Ab hier beziehe ich mich daher auf die TEST-Umgebung. Der gleiche Fehler ist jedoch auch in der LIVE-Umgebung am 11.06.2026 aufgetreten.

 

Das bedeutet, dass sich TEST und LIVE am 11.06.2026 um ca. 10:00 Uhr identisch verhalten haben.

 

*Ablauf*

Über den Webshop wurden automatisch zwei Verkaufsaufträge im BC angelegt. Selber Kunde ,selbes Produkt und Beide Aufträge wurden mit einer Sollmenge von 50 t erstellt.

Da wir 50 t nicht auf einmal liefern können, werden solche Aufträge üblicherweise auf 25 t reduziert und für die Restmenge wird ein weiterer Auftrag manuell angelegt.

Der Fehler tritt bei den automatisch angelegten Aufträgen auf.

Zum Zeitpunkt der Auftragserfassung war für diesen Kunden *kein Preis hinterlegt.* Daher musste der Preis manuell eingetragen werden.

Dabei wurden zwei unterschiedliche Vorgehensweisen getestet:

 

*VA26040228*

* Zuerst wurde der Preis eingetragen.
* Anschließend wurde die Sollmenge von 50 t auf 25 t korrigiert.
* Ergebnis: *_Der Gesamtbetrag bleibt auf Basis von 50 t bestehen und wird nicht neu berechnet._*

*VA26040229*

* Zuerst wurde die Sollmenge von 50 t auf 25 t korrigiert.
* Anschließend wurde der Preis eingetragen.
* Ergebnis: Der Gesamtbetrag wird korrekt auf Basis von 25 t berechnet.

 

*Erwartetes Verhalten*

Nach einer Änderung der Sollmenge sollte der Gesamtbetrag unabhängig von der Reihenfolge der Eingaben neu berechnet werden.

Derzeit scheint die Neuberechnung nicht zu erfolgen, wenn zuerst der Preis eingetragen und danach die Menge geändert wird.

 



### Kommentare (4)
**[Roland Haunschmied]** (2026-06-11T12:12:54.000+0200): 

[^VA26040228.mp4] _(15.47 MB)_

[^VA26040229.mp4] _(18.72 MB)_

!image-1.png|thumbnail!

!image.png|thumbnail!
**[Andreas Hargassner]** (2026-06-13T17:25:02.000+0200): [~Michael.Platl@cegeka.com] : Bitte bearbeiten.
**[hinterndorfer@garant.co.at]** (2026-06-17T10:47:12.000+0200): Prio1 Ticket
**[hinterndorfer@garant.co.at]** (2026-07-06T16:43:50.000+0200): Status?

---

## PROJ4GARHY-251
**Status:** In Progress | **Priorität:** Medium | **Typ:** Support
**Assignee:** nicht zugewiesen | **Reporter:** hinterndorfer@garant.co.at
**Erstellt:** 2026-05-20T08:57:43.000+0200 | **Aktualisiert:** 2026-07-01T12:14:35.000+0200

### Beschreibung
Der Export läuft noch nicht, es werden keine Daten ausgegeben  

Mit freundlichen Grüßen 
 

Dipl. Fw. Markus Hinterndorfer
Leitung IT / Head of IT
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 408 | FAX: +43 2757 2281 67408
Hinterndorfer@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7Cb0131948e34547883de208deb63cf88e%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639148570165947133%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=%2BpKcaqWndtUH0YaGkmjqeqhUq72PBrvZ6ub3Gk3Rsyw%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7Cb0131948e34547883de208deb63cf88e%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639148570165986547%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=VviLN26%2BfhxMfbyhJCtRs%2B0FbktdOuiGyPQsC75NCD0%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}

### Kommentare (8)
**[hinterndorfer@garant.co.at]** (2026-06-11T16:53:08.000+0200): Im Test mit Hr. Platl getestet - Bereit zur Übernahme ins Live
**[hinterndorfer@garant.co.at]** (2026-06-23T15:51:36.000+0200): PIM Export Files funktioniert (XLS file für Artikel, Basisprodukte, mediaImport)

Aufgabenwarteschlangenposten für Export Bilder und Dokumente fehlt noch




**[hinterndorfer@garant.co.at]** (2026-06-23T16:09:09.000+0200): Ausgabedateien haben auch Fehler:
alte und neue mittels KI analysiert (zur Sicherheit auch zur Kontrolle an RWA gesandt per Mail)

h1. *Basisprodukte_23_6_2026_13_28_45.xlsx*

h3.  *Codierung / Encoding*

Mir ist sofort aufgefallen:

* 2026 Datei hat viele Zeichen wie:
** {{FÃ¼tterung}}
** {{KÃ¤lber}}
* 2025 Datei hat:
** korrekt {{Fütterung}}, {{Kälber}}

👉 *das ist kein Satzaufbau-Thema, sondern Encoding-Problem (UTF-8 vs. ANSI)*



h1. *Artikel_23_6_2026_13_28_06.xlsx*

h1. *Datenstruktur – Gesamturteil*

👉 *Grundstruktur ist gleich (kompatibel)*
👉 *aber NICHT 1:1 identisch*

h1. *Attributstruktur (wichtigster Punkt)*

h3. ALT (2025)

{noformat}rwaClass/1.0/Class_054211.attribute_064397
{noformat}

h3. NEU (2026)

{noformat}waClass/1.0/Class_054211/Attribute_064397
{noformat}

👉 Unterschiede:

* Prefix geändert: {{rwaClass}} → {{waClass}}
* Trennzeichen: {{.}} → {{/}}
* Schreibweise: {{attribute}} → {{Attribute}}

h1. *Werte / Codierungen*

h3. ALT

* viele Werte wie:
** {{Ja}}

h3. NEU

* teilweise ersetzt durch:
** {{B}}, {{J}}, {{P}}

👉 Bedeutet:

* Bool / Kennzeichen wurden geändert

➡️ *Mapping-Risiko\!*



h1. *mediaImport_23_6_2026_13_28_31.xlsx → dürfte OK sein*




**[hinterndorfer@garant.co.at]** (2026-06-23T16:49:24.000+0200): Dieser Job läuft auch nicht - gehört zu Onfarming → xml Export

vor dem 16.03.2026 täglich gelaufen



!image.png|thumbnail!

!image-1.png|thumbnail!

!image-2.png|thumbnail!
**[hinterndorfer@garant.co.at]** (2026-06-29T14:03:11.000+0200): Aufgabenwarteschlangenpostern für XML Export eingerichtet - XML wird korrekt exportiert
**[hinterndorfer@garant.co.at]** (2026-06-29T16:26:38.000+0200): Artikel_23_6_2026_13_28_06.xlsx - passt lt Hr. Platl
Basisprodukte_23_6_2026_13_28_45.xlsx -> Codierung passt in der Spalte "T" nicht, muss angepasst werden


**[hinterndorfer@garant.co.at]** (2026-06-29T16:30:26.000+0200): zum Artikel xls habe ich noch folgendes in unserem Ticketsystem gefunden
da stand damals schon falsch waClass statt rwaClass im File
dürfte doch jetzt wieder falsch sein
damaliges Ticket: GARA-108: PIM Massendatenpflege per Excel

!image-3.png|thumbnail!
**[hinterndorfer@garant.co.at]** (2026-06-29T16:34:07.000+0200): Hier die Infos aus unserem Ticketsystem zu der Umsetzung von damals

[^Ticket_2024051010000042_2026-06-29_16_31.pdf] _(448 kB)_

---

## PROJ4GARHY-268
**Status:** To Do | **Priorität:** Medium | **Typ:** Support
**Assignee:** Michael Platl | **Reporter:** Roland Haunschmied
**Erstellt:** 2026-06-16T13:08:15.000+0200 | **Aktualisiert:** 2026-06-27T12:15:36.000+0200

### Beschreibung
Mit freundlichen Grüßen 
 

Roland Haunschmied
IT - Automatisierungstechnik / OT Technician
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 407 | FAX: +43 2757 2281 67407
Haunschmied@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580205209%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=BAVrFDEIeQ33%2FW57MNx3j%2BevzNkyCSj6qaJogWAo%2Blo%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580236448%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=uoeLscGtBirbAZPoj4tGh5BS%2B3MFJWu419rpfIRpmng%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}
 

 

  

 

 
  

 *Von:* Hinterndorfer Markus <Hinterndorfer@garant.co.at> 
  *Gesendet:* Dienstag, 16. Juni 2026 13:01
  *An:* Haunschmied Roland <Haunschmied@garant.co.at>
  *Betreff:* AW: Preis passt sich nicht an die Menge an   

  

Schicks als Ticket rein und schreib dazu du lieferst die Infos nächste woche 

  

Mit freundlichen Grüßen  

Dipl. Fw. Markus Hinterndorfer
 Leitung IT / Head of IT 
  

 *Von:* Haunschmied Roland <[Haunschmied@garant.co.at|mailto:Haunschmied@garant.co.at]> 
  *Gesendet:* Dienstag, 16. Juni 2026 12:59
  *An:* Hinterndorfer Markus <[Hinterndorfer@garant.co.at|mailto:Hinterndorfer@garant.co.at]>
  *Betreff:* WG: Preis passt sich nicht an die Menge an   

  

Bearbeite ich heute nicht mehr , keine Zeit  

  

Mit freundlichen Grüßen  

Roland Haunschmied
 IT - Automatisierungstechnik / OT Technician 
  

 *Von:* Zdebor Karin <[zdebor@agromed.at|mailto:zdebor@agromed.at]> 
  *Gesendet:* Dienstag, 16. Juni 2026 12:14
  *An:* Haunschmied Roland <[Haunschmied@garant.co.at|mailto:Haunschmied@garant.co.at]>
  *Cc:* Ahrens-Kaiser Petra <[ahrens-kaiser@agromed.at|mailto:ahrens-kaiser@agromed.at]>
  *Betreff:* Preis passt sich nicht an die Menge an   

  

Hallo Roland, 

  

Folgendes ist uns aufgefallen – im dazugehörigen Einkaufsauftrag hat sich bei der Mengenänderung der Preis angepasst. 

Allerdings macht das das BC live nicht beim Verkaufsauftrag. 

  

So weiß man nicht, ob jetzt die Rechnung mit dem richtigen Betrag dann ausgestellt wird, oder ob der Gesamtpreis so bleibt wie ursprünglich mit der Menge eingegangen. 

  

!image001.png|thumbnail! 

Weder mit Aktualisieren bekommt man das hin, noch wenn man vom Verkauf aussteigt und wieder einsteigt. 

  

Wenn man eine aktuelle AB ausdrucken will, muss man zuvor auf F5 (aktualisieren gehen), dann kommt tatsächlich der richtige abgeänderte Gesamtpreis ersichtlich auf dem Dokument raus. 

Nur im VK-Auftrag bleibt er unverändert mit dem Gesamtpreis der Ursprungsmenge stehen. 

Da sind wir sehr irritiert… kann das bitte wieder so eingestellt werden wie früher, dass der Gesamtpreis zur geänderten Menge automatisch angepasst wird? 

Bei der Rechnung kam schlussendlich, die geänderte Menge mit dem korrekten Gesamtpreis raus, aber man möchte vorher schon wissen, ob der korrekte Preis verrechnet wird und nicht im Nachhinein. 

  

Bitte um Unterstützung. 

Danke 

  

LG Karin 
| 
|
 !image002.png|thumbnail! |   *{color:#4B4B4A} *Karin Zdebor*{color}*{color:#4B4B4A}{color}  {color:#818180}OFFICE MANAGEMENT SUPPLY CHAIN{color}  !image003.jpg|thumbnail!  !image002.png|thumbnail!   *{color:#4B4B4A} *PHONE.*{color}*{color:#4B4B4A}{color} {color:#4B4B4A}+43 7583 5105833{color}   *{color:#4B4B4A} *E-MAIL.*{color}*{color:#818180}{color}{color:#4B4B4A}{color} [{color:#4B4B4A}zdebor@agromed.at{color}|mailto:zdebor@agromed.at]{color:#4B4B4A}{color}{color:#818180}{color}  !image002.png|thumbnail!  {color:#818180}Firmensitz: Kremsmünster | Firmenbuchgericht: Landesgericht Steyr | Firmenbuchnummer: FN 185370 d{color} 
|{color:#818180} Informationen zum Datenschutz (Privacy Information) sowie unsere AGB´s finden Sie unter{color} [https://www.agromed.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580255285%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=Xu8%2BU5qkZ%2FsjlRtuJNzgoMPdnPg4Ggogt9xZxYz9ikY%3D&reserved=0]{color:#818180} bzw.{color} [https://www.agromed.at/impressum|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fimpressum&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580273301%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=okJkCgNPKrGsZcRqWjVmhiLfiEDpxLvK6fxIdczUpns%3D&reserved=0]{color:#818180}{color}{color:#818180} Diese E-Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten.{color}{color:#818180} Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.{color} | 
|{color:#818180} Information about Privacy Information and our General Terms and Conditions can be found at{color} [https://www.agromed.at/en/data-privacy-policy|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fen%2Fdata-privacy-policy&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580290809%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=QOlJ1OS8Syzf1K71FcxGiePUnJLLnIsMkDdgQljovw0%3D&reserved=0]{color:#818180} or{color} [https://www.agromed.at/en/imprint|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fen%2Fimprint&data=05%7C02%7Cgarsd%40cegeka.com%7Ce43a6ef0a4ff4f57ef0b08decb9776e6%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639172048580514080%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=bnGbCpzZSJpyea%2B7mcAcRX3Dzq3c9295Ih1U4kfkjlc%3D&reserved=0]{color:#818180}{color}{color:#818180} The information contained in this message may be CONFIDENTIAL and is intended for the addressee only. 
Any unauthorized use, spreading of the information or copying of this message is prohibited.{color}{color:#818180}{color}{color:#818180}{color} |

### Kommentare (1)
**[Roland Haunschmied]** (2026-06-23T13:36:22.000+0200): Frau Zdebor hat mir das nochmals erklärt.  

  

Hier die einfache Beschreibung des Problems: 

  

Der Preis in  *Abb. 3* wird immer auf Basis der  *Ursprungsmenge aus Abb. 2* angezeigt und nicht auf Basis der  *Menge aus Abb. 1*. 

Dadurch ist die Anzeige sehr irritierend, da ein falscher Preis pro Einheit dargestellt wird. Bei der eigentlichen Rechnungslegung funktioniert die Berechnung jedoch korrekt – dort wird der Preis auf Basis der tatsächlich verwendeten Menge berechnet und der Endbetrag stimmt. Bild 2  

  

Es dürfte sich daher um ein Problem bei der Anzeige bzw. Darstellung handeln. 

  

  

  

  

!image001.png|thumbnail! 

  


 Bild2  

  

!image002.png|thumbnail!  

Mit freundlichen Grüßen 
 

Roland Haunschmied
IT - Automatisierungstechnik / OT Technician
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 407 | FAX: +43 2757 2281 67407
Haunschmied@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7Cb2e8b446c7314660398008ded11b93db%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639178113555779042%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=ZeZM7%2FB5JVnO1xkgR2E4l5CpAByO0nvbstuleUsXn5w%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7Cb2e8b446c7314660398008ded11b93db%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639178113555819994%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=5ADh7ikXjUb1aDZnQTs35JFFiRztfWeZr%2B9qUhYOZyI%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}

!image001-1.png|thumbnail!

!image002-1.png|thumbnail!

---

## PROJ4GARHY-270
**Status:** To Do | **Priorität:** Medium | **Typ:** Support
**Assignee:** Michael Platl | **Reporter:** Roland Haunschmied
**Erstellt:** 2026-06-22T15:48:17.000+0200 | **Aktualisiert:** 2026-06-27T12:15:54.000+0200

### Beschreibung
Hallo zusammen ,  

  

Das Verhalten entspricht grundsätzlich dem bereits in PROJ4GARHY-268 beschriebenen Problem.  

  

Da der Fehler jedoch auch bei Verkaufsreklamationen bzw. Verkaufsgutschriften auftritt und einen eigenen Geschäftsprozess betrifft, wird dieser Sachverhalt in einem separaten Ticket behandelt.  

  

{color:red}Bitte Prio1{color}  

  

  

  

Mit freundlichen Grüßen 
 

Roland Haunschmied
IT - Automatisierungstechnik / OT Technician
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 407 | FAX: +43 2757 2281 67407
Haunschmied@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334717694%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=xG3ZNtlg92AYHYWQdPAzrTCJVmEuSRIWyiq1a2g%2B%2B2w%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334753085%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=LOl65rn2y944zQRXgCYjY50hAf5SlUpB0UB4Jv6CIDA%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}
 

 

  

 

 
  

 *Von:* Zdebor Karin <zdebor@agromed.at> 
  *Gesendet:* Donnerstag, 18. Juni 2026 10:38
  *An:* Haunschmied Roland <Haunschmied@garant.co.at>
  *Betreff:* Verkaufsreklamation/Verkaufsgutschrift - Gesamtpreisanpassung funktioniert auch hier nicht   

  

Hallo Roland, 

  

ich kopiere mir immer die ursprüngliche Verkaufsrechnung in die Gutschrift, damit alles die Steuern, die Preise, die Chargennummern alles korrekt hinterlegt wird. 

Allerdings muss ich nicht immer die komplette Rechnung so stornieren wie sie ursprünglich war, sondern oft nur kleiner Mengen und da haben wir dasselbe Spiel. 

Wenn ich die Menge abändere, dann bleibt der Gesamtpreis von der ursprünglichen Menge in der Verkaufsreklamation stehen. 

So wie unten ersichtlich bleibt der Gesamtpreis je Zeile gleich 

!image001.png|thumbnail! 

Aber das sollte eigentlich rund 100€ betragen – somit kann ich nicht wirklich prüfen, ob die GS richtig ausgestellt wird. 

  

Gottseidank erstellt das BC-Live wenigstens eine richtig berechnete korrekte GS, nur wie gesagt, zu vor kann ich das NIE prüfen und muss darauf hoffen, dass es passt. 

Siehe unten 

!image002.png|thumbnail! 

Auch hier bitte um Problembehebung. 

Danke. 

Freundliche Grüße 

Karin 
| 
|
 !strich_eeab8355-08ee-469f-ad2a-33e0de83dae1.png|thumbnail! |   *{color:#4B4B4A} *Karin Zdebor*{color}*{color:#4B4B4A}{color}  {color:#818180}OFFICE MANAGEMENT SUPPLY CHAIN{color}  !logo-200_8c5c44e9-1449-4875-9440-166c1fc995f2.jpg|thumbnail!  !strich_eeab8355-08ee-469f-ad2a-33e0de83dae1.png|thumbnail!   *{color:#4B4B4A} *PHONE.*{color}*{color:#4B4B4A}{color} {color:#4B4B4A}+43 7583 5105833{color}   *{color:#4B4B4A} *E-MAIL.*{color}*{color:#818180}{color}{color:#4B4B4A}{color} [{color:#4B4B4A}zdebor@agromed.at{color}|mailto:zdebor@agromed.at]{color:#4B4B4A}{color}{color:#818180}{color}  !strich_eeab8355-08ee-469f-ad2a-33e0de83dae1.png|thumbnail!  {color:#818180}Firmensitz: Kremsmünster | Firmenbuchgericht: Landesgericht Steyr | Firmenbuchnummer: FN 185370 d{color} 
|{color:#818180} Informationen zum Datenschutz (Privacy Information) sowie unsere AGB´s finden Sie unter{color} [https://www.agromed.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334777312%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=PYdndQcorhbaYvfynOgnLmzPMM%2BJ7m%2BiOVASKEZKCUA%3D&reserved=0]{color:#818180} bzw.{color} [https://www.agromed.at/impressum|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fimpressum&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334797152%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=UJh2zdiAelVjBI1kYVBBXKiddxrq%2BSpVxCefgXymvTw%3D&reserved=0]{color:#818180}{color}{color:#818180} Diese E-Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten.{color}{color:#818180} Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.{color} | 
|{color:#818180} Information about Privacy Information and our General Terms and Conditions can be found at{color} [https://www.agromed.at/en/data-privacy-policy|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fen%2Fdata-privacy-policy&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334816144%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=yK6Nmpr4e8ghdh1FLFW1qsN2GFtVxXKoeP9RUhBDYEI%3D&reserved=0]{color:#818180} or{color} [https://www.agromed.at/en/imprint|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.agromed.at%2Fen%2Fimprint&data=05%7C02%7Cgarsd%40cegeka.com%7C51edcb66377c487c1fbf08ded064bdde%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639177328334834306%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=JXgrk8f8%2FsaMxm6MbUoy4RhFPtsNcr3cD0nEFROBnUg%3D&reserved=0]{color:#818180}{color}{color:#818180} The information contained in this message may be CONFIDENTIAL and is intended for the addressee only. 
Any unauthorized use, spreading of the information or copying of this message is prohibited.{color}{color:#818180}{color}{color:#818180}{color} |

### Kommentare (0)

---

## PROJ4GARHY-226
**Status:** Garant Test notwendig | **Priorität:** Medium | **Typ:** Support
**Assignee:** Thomas Vesely | **Reporter:** null
**Erstellt:** 2026-04-23T06:27:22.000+0200 | **Aktualisiert:** 2026-07-07T08:56:58.000+0200

### Beschreibung
Zu- und Abschläge können in Einkaufsrechnungen fälschlicherweise ohne hinterlegter Kostenstelle gebucht werden - es wird keine Fehlermeldung erzeugt, wenn keine Kostenstelle eingegeben wird.

Das Problem ist bisher nur bei Agromed aufgetreten:

 !screenshot-1.png|thumbnail! 

Zusätzlich ist zu prüfen, ob die Dimensionen bei bereits gebuchten Posten gesammelt nachträglich hinterlegt werden können. Mit der Funktion Dimensionskorrektur können nur Sachposten korrigiert werden, aber nicht z.B. Wertposten.


### Kommentare (7)
**[Denise Hochegger]** (2026-04-23T07:09:35.000+0200): [~Michael.Platl@cegeka.com]l: wie gestern kurz besprochen, hat die Buchhaltung diesen Punkt hoch priorisiert.
**[Roland Haunschmied]** (2026-06-11T14:29:38.000+0200): Hallo Marlene, Angela  

  

dieses Problem ist ein „Dimension Thema“ -> ist heute im LIVE ausgerollt 11.06.2026  

können wir beobachten  

  

  

  

Mailauszug:  

****************************************************************** 

  

  

  

  

  

Zu- und Abschläge können in Einkaufsrechnungen fälschlicherweise ohne hinterlegter Kostenstelle gebucht werden - es wird keine Fehlermeldung erzeugt, wenn keine Kostenstelle eingegeben wird. 

Das Problem ist bisher nur bei Agromed aufgetreten: 

  

!image001.png|thumbnail! 

  

Zusätzlich ist zu prüfen, ob die Dimensionen bei bereits gebuchten Posten gesammelt nachträglich hinterlegt werden können. Mit der Funktion Dimensionskorrektur können nur Sachposten korrigiert werden, aber nicht z.B. Wertposten.  

Mit freundlichen Grüßen 
 

Roland Haunschmied
IT - Automatisierungstechnik / OT Technician
 


Garant-Tiernahrung Gesellschaft m.b.H.
Raiffeisenstraße 3 | A-3380 Pöchlarn 

Tel: +43 2757 2281 407 | FAX: +43 2757 2281 67407
Haunschmied@garant.co.at | www.garant.co.at

Es gelten die in den Geschäftsräumen der Garant Tiernahrung GmbH ausgehängten und auf der Homepage [https://shop.garant.co.at/agb|https://eur03.safelinks.protection.outlook.com/?url=https%3A%2F%2Fshop.garant.co.at%2Fagb&data=05%7C02%7Cgarsd%40cegeka.com%7C53a34876435a4020378f08dec7b4c839%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639167776486992927%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=Vsng2kGqf3DfjzNoVpoyqA8JUoltiMv3ghmE%2BWdAmbY%3D&reserved=0] veröffentlichten Allgemeinen Geschäftsbedingungen, die dem Kunden auf dessen Verlangen unentgeltlich ausgehändigt werden. 

{color:#222222}{color} 

Firmensitz: Pöchlarn | Firmenbuchgericht: Landesgericht St. Pölten | Firmenbuchnummer: FN 90109p;
Informationen zum Datenschutz (Privacy Information) finden Sie unter [http://www.garant.co.at/datenschutz|https://eur03.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.garant.co.at%2Fdatenschutz&data=05%7C02%7Cgarsd%40cegeka.com%7C53a34876435a4020378f08dec7b4c839%7C42151053019347aa9e81effd81f772cc%7C0%7C0%7C639167776487028398%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=hbPG6tWNE4LmoZRItmGOdDafhdatfvfmMWWC7RTQWkw%3D&reserved=0]
Diese E Mail Mitteilung ist ausschließlich für den Empfänger bestimmt und kann privilegierte Informationen enthalten. Sollten Sie diese Nachricht irrtümlich erhalten, bitten wir Sie, uns zu verständigen und diese Nachricht sofort zu vernichten.


  

 

{color:#222222}{color}
**[Roland Haunschmied]** (2026-06-11T15:46:10.000+0200): Eben gemeinsam mit Herrn Grois nach dem Rollout getestet.

*Ergebnis:*
Beim Erfassen erscheint keine Fehlermeldung  → *n. i. O.*

Allerdings können wir derzeit nicht mit Sicherheit sagen, ob die Fehlermeldung erst beim Buchen auftritt. 

Leider steht uns heute keine passende Rechnung zum Testen zur Verfügung (Rechnung mit Fracht, bei der eine Kostenstelle erforderlich ist).

Der vollständige Test wird daher auf morgen verschoben.



!image.png|thumbnail!

[^Aufzeichnung 2026-06-11 153457.mp4] _(13.80 MB)_
**[Roland Haunschmied]** (2026-06-15T11:58:01.000+0200): Getestet im LIVE : nIO

Es kommt keine Fehlermeldung beim Buchen 



[^Aufzeichnung 2026-06-15 114307.mp4] _(3.43 MB)_
**[Lisa Kühlinger]** (2026-07-01T15:08:42.000+0200): Hallo [~Thomas.Vesely@cegeka.com] 

Bitte dieses Garant Ticket übernehmen ...

Betrifft nur den Mandanten AGROMED!

Vielen lieben Dank Lisa
**[Thomas Vesely]** (2026-07-06T12:54:01.000+0200): Sehr geehrter Herr Haunschmied,
das Problem lässt sich insofern lösen, indem entsprechend Vorgabedimension hinterlegt werden.
Dies kann an den unterschiedlichsten Stellen im BC gemacht werden; z.Bsp. beim Artikel, beim Lagerort und eben auch bei den Zu-/Abschlägen.

Bei meiner Analyse Eurer LIVE-DB ist mir allerdings aufgefallen, dass zumindest am 1.Juli bereits neue Vorgabedimension von Benutzer Rapolter bei Zu-/Abschlägen hinterlegt/geändert worden sind, allerdings ohne festen Vorgabewert. Um Ihnen das im Detail zu zeigen schlage ich ein kurzes Teams-Meeting vor; hätten Sie (oder Fr. Rapolter) heute dafür Zeit?

Mit besten Grüßen
Thomas Vesely 
**[hinterndorfer@garant.co.at]** (2026-07-06T16:36:46.000+0200): Info an Fr. Rapolter gesandt, mit der Bitte um Terminvorschlag mit Hr. Vesely

---

