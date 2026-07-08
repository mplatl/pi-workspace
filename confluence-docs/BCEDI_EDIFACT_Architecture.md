---
title: "EDIFACT Base App - Interface-Based Parser/Encoder/Validator Architecture"
confluence_id: "320831490"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/320831490/EDIFACT+Base+App+-+Interface-Based+Parser+Encoder+Validator+Architecture"
last_modified: "2026-03-02T08:47:28.187Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:38.125Z"
---

# EDIFACT Base App - Interface-Based Parser/Encoder/Validator Architecture

# EDIFACT Base App - Interface-Based Architecture

## 🎯 Core Konzept: Parser/Encoder/Validator als Interface-Standard

---

## 1. Warum Interfaces f&uuml;r Parser?

### ✅ Standardisierung
- 
**Alle Parser** (D96, D99, Custom) folgen gleicher **EDIFACT Parser Interface**

- 
Base App kennt **nur** die Interface, nicht die Implementierung

- 
Neue Standards k&ouml;nnen hinzugef&uuml;gt werden **ohne Base App zu &auml;ndern**

### ✅ Erweiterbarkeit

```
Parser Interface
  ├─ D96 Parser (implementiert Interface)
  ├─ D99 Parser (implementiert Interface)
  ├─ Custom Parser (implementiert Interface)
  └─ Mock Parser (für Testing)
```

### ✅ Austauschbarkeit
- 
Parser k&ouml;nnen zur **Laufzeit gewechselt** werden

- 
z.B. Standard D96 Parser vs. Custom Third-Party Parser

- 
**Factory Pattern** w&auml;hlt automatisch richtige Implementierung

### ✅ Testbarkeit
- 
Mock-Parser f&uuml;r Unit Tests

- 
Keine Abh&auml;ngigkeit auf externe Files/APIs

### ✅ Entkopplung
- 
Base App hat **KEINE Abh&auml;ngigkeit** auf D96 oder D99 App

- 
D96 App ist **optional** - Base App funktioniert auch ohne

---

## 2. Base App: Interface Definitionen

### 2.1 EDIFACT Parser Interface

```
interface "EDIFACT Parser Interface"
{
  // Parse Blob into Structured Format
  procedure ParseMessage(var FileContent: Blob): JsonObject;
  
  // Validate Parsed Structure
  procedure ValidateMessage(var ParsedSegments: JsonObject): Boolean;
  
  // Get Validation Errors
  procedure GetValidationErrors(var ParsedSegments: JsonObject): List of [Text];
  
  // Extract Metadata (MessageType, Date, Version, etc.)
  procedure GetMessageMetadata(var ParsedSegments: JsonObject): JsonObject;
}
```

**Input**: Blob (Raw EDIFACT File)  
**Output**: JsonObject (Structured Segments)

### 2.2 EDIFACT Encoder Interface

```
interface "EDIFACT Encoder Interface"
{
  // Convert BC Data to EDIFACT
  procedure EncodeMessage(var DataObject: JsonObject): Blob;
  
  // Validate Data Before Encoding
  procedure ValidateBeforeEncode(var DataObject: JsonObject): Boolean;
}
```

**Input**: JsonObject (Staging Data)  
**Output**: Blob (EDIFACT File)

### 2.3 EDIFACT Mapper Interface

```
interface "EDIFACT Mapper Interface"
{
  // Map EDIFACT Segments to Staging
  procedure MapFromEDIFACT(var Segments: JsonObject; var TransferID: Integer): Integer;
  
  // Map BC Data to EDIFACT
  procedure MapToEDIFACT(var StagingID: Integer): JsonObject;
  
  // Apply Dynamic Mapping (Tab 50007)
  procedure ApplyDynamicMapping(var Data: JsonObject; MappingType: Code[30]): JsonObject;
}
```

### 2.4 EDIFACT Processor Interface

```
interface "EDIFACT Processor Interface"
{
  // Process Staging Data to BC Documents
  procedure ProcessStagingData(var StagingID: Integer): Boolean;
  
  // Validate Staging Before Processing
  procedure ValidateStagingData(var StagingID: Integer): List of [Text];
}
```

---

## 3. Base App: Orchestrator

### 3.1 EDIFACT Transfer Manager (Codeunit 50000)

**Zentrale Coordination ohne Standard-spezifische Details:**

```
codeunit 50000 "EDIFACT Transfer Manager"
{
  procedure ProcessTransfer(TransferID: Integer)
  var
    Transfer: Record "EDIFACT Transfer";
    ParserFactory: Codeunit "EDIFACT Parser Factory";
    ParserInterface: Interface "EDIFACT Parser Interface";
    ParsedSegments: JsonObject;
    Errors: List of [Text];
  begin
    // 1. Get Transfer from Tab 50005
    Transfer.Get(TransferID);
    Transfer.Status := Transfer.Status::Processing;
    Transfer.Modify();
    
    // 2. Get right Parser (Factory pattern)
    ParserInterface := ParserFactory.GetParser(Transfer."Standard Version");
    
    // 3. Parse File
    ParsedSegments := ParserInterface.ParseMessage(Transfer."File Content");
    
    // 4. Validate Structure
    if not ParserInterface.ValidateMessage(ParsedSegments) then
    begin
      Errors := ParserInterface.GetValidationErrors(ParsedSegments);
      LogErrors(TransferID, Errors);
      Transfer.Status := Transfer.Status::Error;
      Transfer.Modify();
      exit;
    end;
    
    // 5. Map & Process
    if MapAndProcess(ParsedSegments, Transfer."Message Type", TransferID) then
    begin
      Transfer.Status := Transfer.Status::Processed;
      Transfer."Processed DateTime" := CurrentDateTime;
    end else
    begin
      Transfer.Status := Transfer.Status::Error;
    end;
    
    Transfer.Modify();
  end;
  
  local procedure MapAndProcess(var ParsedSegments: JsonObject; MessageType: Code[20]; TransferID: Integer): Boolean
  var
    MapperFactory: Codeunit "EDIFACT Mapper Factory";
    ProcessorFactory: Codeunit "EDIFACT Processor Factory";
    MapperInterface: Interface "EDIFACT Mapper Interface";
    ProcessorInterface: Interface "EDIFACT Processor Interface";
    StagingID: Integer;
  begin
    // Get right Mapper & Processor for Message Type
    MapperInterface := MapperFactory.GetMapper(MessageType);
    ProcessorInterface := ProcessorFactory.GetProcessor(MessageType);
    
    // Map EDIFACT to Staging
    StagingID := MapperInterface.MapFromEDIFACT(ParsedSegments, TransferID);
    
    // Process Staging to BC Document
    exit(ProcessorInterface.ProcessStagingData(StagingID));
  end;
}
```

### 3.2 EDIFACT Parser Factory (Codeunit 50001)

**Dynamic Dispatch: W&auml;hlt richtigen Parser basierend auf Standard**

```
codeunit 50001 "EDIFACT Parser Factory"
{
  procedure GetParser(Standard: Code[10]): Interface "EDIFACT Parser Interface"
  var
    ParserImpl: Codeunit;
  begin
    case Standard of
      'D96A', 'D96B':
        ParserImpl := Codeunit::"EDIFACT D96 Parser";
      'D99A', 'D99B':
        ParserImpl := Codeunit::"EDIFACT D99 Parser";
      'D03A', 'D07A':
        ParserImpl := Codeunit::"EDIFACT D03+ Parser";
      else
        Error('Unknown EDIFACT Standard: ' + Standard);
    end;
    
    exit(ParserImpl);
  end;
}
```

**Vorteile:**
- 
✅ Base App kennt Parser nicht &rarr; Keine Abh&auml;ngigkeit auf D96/D99

- 
✅ Parser werden nur geladen wenn n&ouml;tig (Performance)

- 
✅ Neue Parser k&ouml;nnen hinzugef&uuml;gt werden ohne Base Code zu &auml;ndern

---

## 4. Standard-spezifische Apps: Implementierung

### 4.1 D96 App - Parser Implementation

**Konkrete Implementierung der Interface:**

```
codeunit 50100 "EDIFACT D96 Parser" 
  implements "EDIFACT Parser Interface"
{
  procedure ParseMessage(var FileContent: Blob): JsonObject
  var
    SeparatorChars: Code[6];
    Segments: List of [Text];
    SegmentLines: JsonObject;
    Segment: Text;
  begin
    // 1. Extract UNA (or use defaults)
    SeparatorChars := ExtractUNA(FileContent);
    
    // 2. Split File into Segments
    Segments := SplitBySegmentTerminator(FileContent, SeparatorChars);
    
    // 3. Parse each Segment
    SegmentLines := CreateJsonObject();
    foreach Segment in Segments do
      ParseSegment(Segment, SeparatorChars, SegmentLines);
    
    exit(SegmentLines);
  end;
  
  procedure ValidateMessage(var ParsedSegments: JsonObject): Boolean
  begin
    // Validate UNH-UNT matching
    // Validate segment sequence
    // Validate mandatory segments
    // Validate separators consistency
    exit(true); // or false if invalid
  end;
  
  procedure GetValidationErrors(var ParsedSegments: JsonObject): List of [Text]
  var
    Errors: List of [Text];
  begin
    // Return validation error messages
    exit(Errors);
  end;
  
  procedure GetMessageMetadata(var ParsedSegments: JsonObject): JsonObject
  var
    Metadata: JsonObject;
  begin
    // Extract MessageType from UNH
    // Extract Date from DTM
    // Extract Version from UNH
    exit(Metadata);
  end;
  
  local procedure ParseSegment(Segment: Text; Separators: Code[6]; var SegmentLines: JsonObject)
  begin
    // D96 specific parsing logic
  end;
}
```

### 4.2 D96 App - Mapper Implementation

```
codeunit 50101 "EDIFACT D96 Mapper" 
  implements "EDIFACT Mapper Interface"
{
  procedure MapFromEDIFACT(var Segments: JsonObject; var TransferID: Integer): Integer
  var
    StagingHeader: Record "D96 Staging Header";
  begin
    // Create Staging Header
    StagingHeader.Init();
    StagingHeader."Staging ID" := 0; // Auto
    StagingHeader."Transfer ID" := TransferID;
    StagingHeader."Message Type" := DetermineMessageType(Segments);
    StagingHeader."Standard Version" := 'D96A';
    
    // Map EDIFACT to Staging
    MapHeaderData(Segments, StagingHeader);
    MapLineData(Segments, StagingHeader);
    
    StagingHeader.Insert(true);
    exit(StagingHeader."Staging ID");
  end;
  
  procedure ApplyDynamicMapping(var Data: JsonObject; MappingType: Code[30]): JsonObject
  var
    MappingConfig: Record "EDIFACT Mapping Configuration";
    SourceValue: Code[50];
  begin
    // Apply Tab 50007 mappings
    // e.g., UoM_D96: PC → STK
    exit(Data);
  end;
}
```

### 4.3 D96 App - Processor Implementation

```
codeunit 50102 "EDIFACT D96 Processor" 
  implements "EDIFACT Processor Interface"
{
  procedure ProcessStagingData(var StagingID: Integer): Boolean
  var
    StagingHeader: Record "D96 Staging Header";
  begin
    StagingHeader.Get(StagingID);
    
    case StagingHeader."Message Type" of
      'ORDERS':
        exit(ProcessORDERS(StagingHeader));
      'DESADV':
        exit(ProcessDESADV(StagingHeader));
      'INVOIC':
        exit(ProcessINVOIC(StagingHeader));
    end;
  end;
  
  local procedure ProcessORDERS(var StagingHeader: Record "D96 Staging Header"): Boolean
  var
    SalesHeader: Record "Sales Header";
  begin
    // Create Sales Order from Staging
    SalesHeader.Init();
    // ... map fields
    SalesHeader.Insert(true);
    
    // Update Staging Status
    StagingHeader.Status := StagingHeader.Status::Processed;
    StagingHeader."Processed DateTime" := CurrentDateTime;
    StagingHeader.Modify();
    
    exit(true);
  end;
}
```

---

## 5. Architecture Diagram

```
┌────────────────────────────────────────────────┐
│         EDIFACT Transfer Manager               │
│  (Codeunit 50000 - uses Interfaces only)      │
└────────────────────┬─────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌──────────┐
    │ Parser  │ │ Mapper  │ │Processor │
    │ Factory │ │ Factory │ │ Factory  │
    └──┬──────┘ └────┬────┘ └────┬─────┘
       │             │           │
    ┌──┴──┬──────┐  ┌┴─────┐  ┌──┴──┐
    │     │      │  │      │  │     │
    ▼     ▼      ▼  ▼      ▼  ▼     ▼
  D96   D99   D03A D96   D96  D96   D99
 Parser Parser Parser Mapper Map Proc Proc
(Impl) (Impl) (Impl)(Impl)(Impl)(Impl)(Impl)

All implement Base App Interfaces!
```

---

## 6. Vorteile der Interface-Architektur

| Vorteil | Beschreibung |
| --- | --- |
| **Standardisierung** | Alle Parser/Mapper/Processor folgen gleicher Schnittstelle |
| **Erweiterbarkeit** | Neue Standards k&ouml;nnen ohne Base-App-&Auml;nderungen hinzugef&uuml;gt werden |
| **Austauschbarkeit** | Parser k&ouml;nnen zur Laufzeit gewechselt werden |
| **Testbarkeit** | Mock-Implementierungen f&uuml;r Unit Tests m&ouml;glich |
| **Entkopplung** | Base App hat keine Abh&auml;ngigkeit auf Standard-Apps |
| **Performance** | Parser werden nur geladen wenn n&ouml;tig (Lazy Loading) |
| **Wartbarkeit** | Klar definierte Schnittstellen = einfacher zu debuggen |
| **Dokumentation** | Interface definiert exakt welche Procedures implementiert sein m&uuml;ssen |

---

## 7. Implementation Roadmap

### Phase 1: Base App (Interfaces + Orchestrator)

1
089a0940-6c90-461b-b757-37ed1ddf31c7
incomplete
EDIFACT Parser Interface definieren

2
9a1a640a-da47-4aa4-affc-ce11a19b5b6d
incomplete
EDIFACT Encoder Interface definieren

3
299966e4-e276-4c15-bff4-39330ea448d4
incomplete
EDIFACT Mapper Interface definieren

4
17329dc3-10bb-499a-8e6b-40626907cd1f
incomplete
EDIFACT Processor Interface definieren

5
ccf43d15-d632-4bea-b903-824011102acf
incomplete
EDIFACT Transfer Manager (Codeunit 50000)

6
cc6c75ef-3a4e-473e-bf16-cbcd42eb16ae
incomplete
Parser Factory (Codeunit 50001)

7
328dbe1b-c5a4-4bf2-8f92-be11847c30b7
incomplete
Mapper Factory (Codeunit 50002)

8
d5acd17d-3b72-4631-8866-29a05f2327b3
incomplete
Processor Factory (Codeunit 50003)

### Phase 2: D96 App (Parser Implementation)

9
f4865c5f-6301-474b-966c-1e6b62efe4f5
incomplete
D96 Parser implementiert EDIFACT Parser Interface

10
8f99860e-f44a-4626-93f4-e222fcca7269
incomplete
D96 Encoder implementiert EDIFACT Encoder Interface

11
306b24a7-00e8-4206-9f2d-0a65c7b845fb
incomplete
D96 Mapper implementiert EDIFACT Mapper Interface

12
e3660610-f6fd-4269-8248-c8392b6cb7c8
incomplete
D96 Processor implementiert EDIFACT Processor Interface

### Phase 3: D99+ App (analoge Struktur)

13
a60b2186-f500-4415-bee0-69ae3235bb6c
incomplete
D99 Parser (implements Interface)

14
b6dd6b5a-0173-482e-9d4e-45570c5d5806
incomplete
D99 Encoder (implements Interface)

15
f2f0b330-c881-4f64-bdd9-26cd344b105a
incomplete
etc.

---

## 8. Testing mit Interfaces

### 8.1 Mock Parser f&uuml;r Testing

```
codeunit 50900 "EDIFACT Mock Parser" 
  implements "EDIFACT Parser Interface"
{
  procedure ParseMessage(var FileContent: Blob): JsonObject
  var
    MockData: JsonObject;
  begin
    // Return hardcoded test data
    MockData.Add('MessageType', 'ORDERS');
    MockData.Add('Date', '20260302');
    exit(MockData);
  end;
  
  // Implement other procedures...
}
```

### 8.2 Unit Test mit Mock

```
[Test]
procedure TestTransferManagerWithMockParser()
var
  TransferManager: Codeunit "EDIFACT Transfer Manager";
  MockParser: Codeunit "EDIFACT Mock Parser";
  ParserInterface: Interface "EDIFACT Parser Interface";
begin
  // Setup
  ParserInterface := MockParser;
  
  // Execute
  TransferManager.ProcessTransfer(1);
  
  // Assert
  Assert.IsTrue(true); // Check actual conditions
end;
```

---

## ✅ Zusammenfassung

**Interface-based Architecture erm&ouml;glicht:**
1. 
✅ **Base App bleibt Standard-agnostisch**

2. 
✅ **Neue Standards sind einfach hinzuf&uuml;gbar** (D99, D03A, etc.)

3. 
✅ **Parser/Mapper/Processor sind austauschbar**

4. 
✅ **Klare Schnittstellen = klare Dokumentation**

5. 
✅ **Unit Tests mit Mock-Implementierungen**

6. 
✅ **Zero Abh&auml;ngigkeiten zwischen Standard-Apps**

---

**Status**: Interface Architecture Ready for Implementation  
**Version**: 3.0  
**Datum**: 2. M&auml;rz 2026
