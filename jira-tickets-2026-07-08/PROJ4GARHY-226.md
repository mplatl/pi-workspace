# PROJ4GARHY-226: Fehlende Fehlermeldungen bei Buchungen ohne Kostenstelle (FIBU Prio 1)

| Feld | Wert |
|------|------|
| Status | Garant Test notwendig |
| Priorität | Medium |
| Typ | Support |
| Projekt | null - null |
| Assignee | Thomas Vesely |
| Reporter | null |
| Erstellt | 2026-04-23T06:27:22.000+0200 |
| Aktualisiert | 2026-07-07T08:56:58.000+0200 |

## Beschreibung

Zu- und Abschläge können in Einkaufsrechnungen fälschlicherweise ohne hinterlegter Kostenstelle gebucht werden - es wird keine Fehlermeldung erzeugt, wenn keine Kostenstelle eingegeben wird.

Das Problem ist bisher nur bei Agromed aufgetreten:

 !screenshot-1.png|thumbnail! 

Zusätzlich ist zu prüfen, ob die Dimensionen bei bereits gebuchten Posten gesammelt nachträglich hinterlegt werden können. Mit der Funktion Dimensionskorrektur können nur Sachposten korrigiert werden, aber nicht z.B. Wertposten.


## Verknüpfte Issues


## Kommentare (7)

### Denise Hochegger — 2026-04-23T07:09:35.000+0200

[~Michael.Platl@cegeka.com]l: wie gestern kurz besprochen, hat die Buchhaltung diesen Punkt hoch priorisiert.

### Roland Haunschmied — 2026-06-11T14:29:38.000+0200

Hallo Marlene, Angela  

  

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

### Roland Haunschmied — 2026-06-11T15:46:10.000+0200

Eben gemeinsam mit Herrn Grois nach dem Rollout getestet.

*Ergebnis:*
Beim Erfassen erscheint keine Fehlermeldung  → *n. i. O.*

Allerdings können wir derzeit nicht mit Sicherheit sagen, ob die Fehlermeldung erst beim Buchen auftritt. 

Leider steht uns heute keine passende Rechnung zum Testen zur Verfügung (Rechnung mit Fracht, bei der eine Kostenstelle erforderlich ist).

Der vollständige Test wird daher auf morgen verschoben.



!image.png|thumbnail!

[^Aufzeichnung 2026-06-11 153457.mp4] _(13.80 MB)_

### Roland Haunschmied — 2026-06-15T11:58:01.000+0200

Getestet im LIVE : nIO

Es kommt keine Fehlermeldung beim Buchen 



[^Aufzeichnung 2026-06-15 114307.mp4] _(3.43 MB)_

### Lisa Kühlinger — 2026-07-01T15:08:42.000+0200

Hallo [~Thomas.Vesely@cegeka.com] 

Bitte dieses Garant Ticket übernehmen ...

Betrifft nur den Mandanten AGROMED!

Vielen lieben Dank Lisa

### Thomas Vesely — 2026-07-06T12:54:01.000+0200

Sehr geehrter Herr Haunschmied,
das Problem lässt sich insofern lösen, indem entsprechend Vorgabedimension hinterlegt werden.
Dies kann an den unterschiedlichsten Stellen im BC gemacht werden; z.Bsp. beim Artikel, beim Lagerort und eben auch bei den Zu-/Abschlägen.

Bei meiner Analyse Eurer LIVE-DB ist mir allerdings aufgefallen, dass zumindest am 1.Juli bereits neue Vorgabedimension von Benutzer Rapolter bei Zu-/Abschlägen hinterlegt/geändert worden sind, allerdings ohne festen Vorgabewert. Um Ihnen das im Detail zu zeigen schlage ich ein kurzes Teams-Meeting vor; hätten Sie (oder Fr. Rapolter) heute dafür Zeit?

Mit besten Grüßen
Thomas Vesely 

### hinterndorfer@garant.co.at — 2026-07-06T16:36:46.000+0200

Info an Fr. Rapolter gesandt, mit der Bitte um Terminvorschlag mit Hr. Vesely

---

