---
title: "ORDERS"
confluence_id: "163708948"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/163708948/ORDERS"
last_modified: "2025-11-15T09:30:57.404Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:48.236Z"
---

# ORDERS

```
UNA:+.? '
```

# UNA

| Position | Bedeutung | Wert in `UNA:+.? '` |
| --- | --- | --- |
| 1 | Komponententrennzeichen (Component data element separator) | `:` |
| 2 | Daten-Element-Trennzeichen (Data element separator) | `+` |
| 3 | Dezimalzeichen (Decimal mark) | `.` |
| 4 | Release-Zeichen (Release character / Escape) | `?` |
| 5 | Repetitions-Trennzeichen (Repetition separator) | **leer / Standard **`n.a.` |
| 6 | Segment-Ende (Segment terminator) | `'` (Apostroph) |
| 7 | optional &ndash; Reserve / wird normalerweise nicht verwendet | n.a. |

### Bedeutung der einzelnen Zeichen
- 
`:` &rarr; Trennt Unterelemente innerhalb eines Datenelements (z. B. `LIN+1++70000:IN`)

- 
`+` &rarr; Trennt einzelne Datenelemente innerhalb eines Segments

- 
`.` &rarr; Dezimaltrennzeichen f&uuml;r numerische Werte (`MOA+203:5000.50:EUR`)

- 
`?` &rarr; Erm&ouml;glicht das Maskieren eines Trennzeichens, wenn es als normaler Text vorkommt

- 
`'` &rarr; Segmentende

Beispiel:

```
LIN+1++70000:IN'

```
- 
`LIN` = Segmenttag

- 
`1` = Line Number

- 
`70000:IN` = Datenelement mit Unterelement `70000` und `IN`

- 
`'` = Ende des Segments

---

### Unterschiede zu anderen Versionen
- 
**UNA ist optional:**

Viele &auml;ltere Nachrichten verzichten auf UNA, wenn Standardtrennzeichen `:+.? '` verwendet werden.

**Unterschiedliche Directory-Versionen (D.97A, D.98A, D.99A, etc.)**:
- 
Die Definition von UNA **selbst &auml;ndert sich nicht** zwischen Versionen.

- 
Unterschiedlich kann sein, **ob der UNA-Satz wirklich in einer Nachricht steht** &ndash; manche Implementierungen lassen ihn weg, weil der Parser die Standardtrennzeichen annimmt.

- 
Neuere Versionen unterst&uuml;tzen **Repetitions-Trennzeichen** (`*` oder `:` in D.01A, D.02B, etc.), &auml;ltere Versionen nicht.
