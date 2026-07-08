---
title: "EDIFACT App - Implementierungs-Richtlinien und AL-Code Patterns"
confluence_id: "320569345"
space: "BCEDI"
url: "https://mip-dev.atlassian.net/wiki/spaces/BCEDI/pages/320569345/EDIFACT+App+-+Implementierungs-Richtlinien+und+AL-Code+Patterns"
last_modified: "2026-03-02T07:55:15.138Z"
author: "Michael Platl"
fetched_at: "2026-06-24T22:00:38.088Z"
---

# EDIFACT App - Implementierungs-Richtlinien und AL-Code Patterns

# EDIFACT App - Implementierungs-Richtlinien

## AL-Code Struktur und Best Practices

---

## 📁 Dateistruktur und Ordnerorganisation

### Base App Struktur

```
EDIFACT-Base/
├── src/
│   ├── Codeunits/
│   │   ├── EdifactParser.al (50000)
│   │   ├── EdifactEncoder.al (50001)
│   │   ├── EdifactValidator.al (50002)
│   │   ├── EdifactFileManager.al (50003)
│   │   └── EdifactErrorHandler.al (50004)
│   ├── Tables/
│   │   ├── EdifactSetup.al (50000)
│   │   ├── EdifactMessageTypeSetup.al (50001)
│   │   ├── EdifactPartnerSetup.al (50002)
│   │   ├── EdifactImportHeader.al (50010)
│   │   └── EdifactErrorLog.al (50050)
│   └── Pages/
│       ├── EdifactSetupCard.al (50020)
│       ├── EdifactPartnerList.al (50021)
│       └── EdifactErrorLogList.al (50025)
├── app.json
└── README.md
```

### D96 App Struktur

```
EDIFACT-D96/
├── src/
│   ├── Codeunits/
│   │   ├── OrdersMapper.al (50100)
│   │   ├── OrdrspMapper.al (50101)
│   │   ├── DesadvMapper.al (50102)
│   │   ├── InvoicMapper.al (50103)
│   │   ├── OrdersProcessor.al (50200)
│   │   ├── OrdrspProcessor.al (50201)
│   │   ├── DesadvProcessor.al (50202)
│   │   └── InvoicProcessor.al (50203)
│   ├── Tables/
│   │   ├── OrdersStagingHeader.al (50020)
│   │   ├── OrdersStagingLine.al (50021)
│   │   ├── DesadvStagingHeader.al (50030)
│   │   ├── DesadvStagingLine.al (50031)
│   │   ├── InvoicStagingHeader.al (50040)
│   │   └── InvoicStagingLine.al (50041)
│   └── Pages/
│       ├── OrdersStagingList.al (50010)
│       ├── OrdersStagingCard.al (50011)
│       ├── DesadvStagingList.al (50012)
│       └── InvoicStagingList.al (50013)
├── app.json (mit Abhängigkeit auf EDIFACT Base)
└── README.md
```

---

## 🔧 Codeunit-Template Struktur

### Parser Codeunit Template

```
codeunit 50000 "EDIFACT Parser"
{
    procedure ParseMessage(MessageText: Text): Dictionary of [Text, List of [Text]]
    begin
        // 1. Validate message format
        // 2. Split by segment terminator
        // 3. Extract UNA (optional)
        // 4. Parse UNH-UNT structure
        // 5. Return dictionary with segment tag -> list of segments
    end;

    procedure ExtractSegment(MessageText: Text; SegmentTag: Code[20]): List of [Text]
    begin
        // Find all segments matching SegmentTag
        // Return as list
    end;

    procedure ValidateUNA(UNAText: Text): Boolean
    begin
        // Check format: UNA:+.? '
        // Validate character positions
        // Return success
    end;

    local procedure SplitSegmentElements(SegmentText: Text; Separator: Code[1]): List of [Text]
    begin
        // Split segment into elements
    end;
}
```

### Validator Codeunit Template

```
codeunit 50002 "EDIFACT Validator"
{
    procedure ValidateMessage(MessageHeader: Record "EDIFACT Import Header"): Boolean
    var
        Errors: List of [Text];
    begin
        Errors := ValidateStructure(MessageHeader);
        Errors.AddRange(ValidateBusinessRules(MessageHeader));
        
        if Errors.Count > 0 then begin
            LogErrors(MessageHeader."Import ID", Errors);
            exit(false);
        end;
        exit(true);
    end;

    local procedure ValidateStructure(MessageHeader: Record "EDIFACT Import Header"): List of [Text]
    begin
        // Validate UNH-UNT matching
        // Validate segment sequence
        // Validate mandatory segments
    end;

    local procedure ValidateBusinessRules(MessageHeader: Record "EDIFACT Import Header"): List of [Text]
    begin
        // Partner exists
        // Message type supported
        // Quantities > 0
        // Prices valid
    end;

    local procedure LogErrors(ImportID: Integer; Errors: List of [Text])
    begin
        // Write errors to EDIFACT Error Log
    end;
}
```

---

## 📊 Mapper Codeunit Pattern

### ORDERS Mapper Template

```
codeunit 50100 "ORDERS Mapper"
{
    var
        Parser: Codeunit "EDIFACT Parser";
        ErrorHandler: Codeunit "EDIFACT Error Handler";

    procedure MapFromEDIFACT(ParsedSegments: Dictionary of [Text, List of [Text]]; ImportID: Integer): Boolean
    var
        StagingHeader: Record "ORDERS Staging Header";
        StagingLine: Record "ORDERS Staging Line";
        LineNo: Integer;
    begin
        // Create Header
        StagingHeader.Init();
        StagingHeader."Staging ID" := 0; // AutoInc
        StagingHeader."Import ID" := ImportID;
        
        if not ExtractHeaderData(ParsedSegments, StagingHeader) then
            exit(false);
        
        StagingHeader.Insert(true);
        
        // Create Lines
        LineNo := 10000;
        if not ExtractLineData(ParsedSegments, StagingHeader."Staging ID", LineNo) then
            exit(false);
        
        StagingHeader.Status := StagingHeader.Status::New;
        StagingHeader.Modify();
        exit(true);
    end;

    procedure MapToEDIFACT(SalesOrderHeader: Record "Sales Header"): Text
    var
        SegmentLines: List of [Text];
    begin
        // Extract from Sales Order
        // Build EDIFACT segments
        // Combine to message
        // Return EDIFACT format string
    end;

    local procedure ExtractHeaderData(Segments: Dictionary of [Text, List of [Text]]; var StagingHeader: Record "ORDERS Staging Header"): Boolean
    begin
        // BGM: Order number, type, date
        // NAD: Buyer, Supplier, Delivery
        // DTM: Order date, delivery date
        // TOD: Terms
        // MOA: Totals
    end;

    local procedure ExtractLineData(Segments: Dictionary of [Text, List of [Text]]; StagingID: Integer; var LineNo: Integer): Boolean
    begin
        // Loop through LIN segments
        // For each: QTY, PRI, IMD, DTM
        // Create ORDERS Staging Line
    end;
}
```

---

## ✅ Processor Codeunit Pattern

### ORDERS Processor Template

```
codeunit 50200 "ORDERS Processor"
{
    var
        ErrorHandler: Codeunit "EDIFACT Error Handler";

    procedure ProcessStagingData(var StagingHeader: Record "ORDERS Staging Header"): Boolean
    begin
        if not ValidateStagingData(StagingHeader) then
            exit(false);
        
        if not CreateSalesOrder(StagingHeader) then
            exit(false);
        
        StagingHeader.Status := StagingHeader.Status::Processed;
        StagingHeader."Processed DateTime" := CurrentDateTime;
        StagingHeader.Modify();
        exit(true);
    end;

    local procedure ValidateStagingData(var StagingHeader: Record "ORDERS Staging Header"): Boolean
    var
        StagingLine: Record "ORDERS Staging Line";
        ErrorMsg: Text;
    begin
        // Validate header fields
        // Validate each line
        StagingLine.SetRange("Staging ID", StagingHeader."Staging ID");
        if StagingLine.FindSet() then
            repeat
                if not ValidateLineData(StagingLine, ErrorMsg) then begin
                    StagingLine."Status" := StagingLine.Status::Invalid;
                    StagingLine."Validation Errors" := CopyStr(ErrorMsg, 1, 500);
                    StagingLine.Modify();
                    exit(false);
                end;
            until StagingLine.Next() = 0;
        
        exit(true);
    end;

    local procedure ValidateLineData(var StagingLine: Record "ORDERS Staging Line"; var ErrorMsg: Text): Boolean
    var
        Item: Record Item;
    begin
        // Check item exists
        if not Item.Get(StagingLine."Item Number") then begin
            ErrorMsg := StrSubstNo('Item %1 not found', StagingLine."Item Number");
            exit(false);
        end;
        
        // Check quantity > 0
        if StagingLine."Order Quantity"  0';
            exit(false);
        end;
        
        exit(true);
    end;

    local procedure CreateSalesOrder(var StagingHeader: Record "ORDERS Staging Header"): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        StagingLine: Record "ORDERS Staging Line";
        LineNo: Integer;
    begin
        // Create Sales Order header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        
        // Map header fields
        SalesHeader."Sell-to Customer No." := GetCustomerNo(StagingHeader);
        SalesHeader."Order Date" := StagingHeader."Order Date";
        SalesHeader."Requested Delivery Date" := StagingHeader."Requested Delivery Date";
        SalesHeader.Modify();
        
        // Create lines
        LineNo := 10000;
        StagingLine.SetRange("Staging ID", StagingHeader."Staging ID");
        if StagingLine.FindSet() then
            repeat
                CreateSalesLine(SalesHeader, StagingLine, LineNo);
                LineNo += 10000;
            until StagingLine.Next() = 0;
        
        StagingHeader."Created Sales Order No" := SalesHeader."No.";
        exit(true);
    end;

    local procedure GetCustomerNo(StagingHeader: Record "ORDERS Staging Header"): Code[20]
    var
        Customer: Record Customer;
    begin
        // Map EDI Partner to Customer
        // If not found: create customer from staging data
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header"; StagingLine: Record "ORDERS Staging Line"; LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := StagingLine."Item Number";
        SalesLine.Quantity := StagingLine."Order Quantity";
        SalesLine."Unit Price" := StagingLine."Unit Price";
        SalesLine."Requested Delivery Date" := StagingLine."Requested Delivery Date";
        SalesLine.Insert(true);
    end;
}
```

---

## 🛡️ Error Handling Best Practices

### Error Handler Pattern

```
codeunit 50004 "EDIFACT Error Handler"
{
    procedure LogError(ImportID: Integer; ErrorMsg: Text; Severity: Text; SegmentTag: Code[20])
    var
        ErrorLog: Record "EDIFACT Error Log";
    begin
        ErrorLog.Init();
        ErrorLog."Error ID" := 0; // AutoInc
        ErrorLog."Import ID" := ImportID;
        ErrorLog."Error Message" := CopyStr(ErrorMsg, 1, 1000);
        ErrorLog.Severity := Severity; // Info, Warning, Error, Critical
        ErrorLog."Segment Tag" := SegmentTag;
        ErrorLog."Logged DateTime" := CurrentDateTime;
        ErrorLog.Insert(true);
        
        // Update Import Header status
        UpdateImportStatus(ImportID, Severity);
    end;

    local procedure UpdateImportStatus(ImportID: Integer; Severity: Text)
    var
        ImportHeader: Record "EDIFACT Import Header";
    begin
        if ImportHeader.Get(ImportID) then begin
            if Severity = 'Error' then begin
                ImportHeader.Status := ImportHeader.Status::Error;
                ImportHeader.Modify();
            end else if Severity = 'Warning' then begin
                if ImportHeader.Status <> ImportHeader.Status::Error then begin
                    ImportHeader.Status := ImportHeader.Status::Partial;
                    ImportHeader.Modify();
                end;
            end;
        end;
    end;

    procedure RetryProcessing(ImportID: Integer): Boolean
    var
        ImportHeader: Record "EDIFACT Import Header";
    begin
        if ImportHeader.Get(ImportID) then begin
            ImportHeader.Status := ImportHeader.Status::Pending;
            ImportHeader.Modify();
            exit(true);
        end;
        exit(false);
    end;
}
```

---

## 📋 Tabellen-Design Richtlinien

### Wichtige &Uuml;berlegungen
1. 
**Keys**
- 
Prim&auml;rschl&uuml;ssel: Eindeutigkeit sicherstellen

- 
Foreign Keys: Datenintegrit&auml;t

- 
Sekund&auml;rschl&uuml;ssel: Filterm&ouml;glichkeiten

2. 
**Data Types**
- 
Code[20]: Partner IDs, Message Codes

- 
Text[...]: Beschreibungen, Adressen

- 
Decimal: Mengen, Preise (exakte Berechnung)

- 
Option: Status, Type (begrenzte Werte)

3. 
**Relationships**

```
field(10; "Import ID"; Integer)
{
    TableRelation = "EDIFACT Import Header"."Import ID";
    ValidateTableRelation = true;
}
```

---

## 🔄 Data Flow Diagramm

```
1. FILE IMPORT
   File Manager → Read File → Raw Text

2. PARSING
   Parser → Extract Segments → Dictionary[Tag -> List[Segments]]

3. VALIDATION
   Validator → Check Structure + Business Rules → Error Log

4. MAPPING
   Mapper (Type-specific) → Parse to Staging Tables

5. USER REVIEW
   Staging List → User edits/corrects data

6. PROCESSING
   Processor → Validate → Create BC Document → Update Status

7. ARCHIVE
   File Manager → Archive original file
```

---

## 🧪 Unit Test-Struktur

```
codeunit 50900 "EDIFACT Parser Tests"
{
    Subtype = Test;

    [Test]
    procedure TestParseOrdersMessage()
    var
        Parser: Codeunit "EDIFACT Parser";
        ParsedSegments: Dictionary of [Text, List of [Text]];
        MessageText: Text;
    begin
        // Arrange
        MessageText := GetSampleOrdersMessage();
        
        // Act
        ParsedSegments := Parser.ParseMessage(MessageText);
        
        // Assert
        Assert.AreEqual(1, ParsedSegments.Count(), 'Should parse message');
    end;

    local procedure GetSampleOrdersMessage(): Text
    begin
        exit('UNA:+.? ''UNH+1+ORDERS:D:96A:UN:1.1...UNT+5+1');
    end;
}
```

---

## 🚀 Deployment Checklist

1
cc4a2e1d-a7bb-45ee-9986-5a051991b78d
incomplete
Base App komplett und getestet

2
116bb8e5-a3bb-4dfa-807b-80b61f5b7344
incomplete
D96 App implementiert und getestet

3
78eebe5c-8473-4c62-b883-117d3d5dd5b5
incomplete
All Staging Tables mit Keys und Relations

4
77568782-0e1f-427e-8524-e64d6767f318
incomplete
All Codeunits mit Error Handling

5
f0553c0c-7456-439d-bd21-1b24f3fd15ad
incomplete
Pages/UI f&uuml;r Benutzer-Interfaces

6
2c5b7d1a-0a06-4d83-ac30-dd1cca4d9448
incomplete
Unit Tests (mind. 80% Coverage)

7
d65339e2-4fa0-4cd7-b01e-00f5b9e059bc
incomplete
Documentation aktualisiert

8
35fb48d3-eeb5-4a7f-b701-84bd5b072f7c
incomplete
Performance-Testing f&uuml;r gro&szlig;e Files

9
6df10efe-ffad-4efb-93ff-a93e7ebbabf1
incomplete
Security Review (Table Permissions)

10
04736640-4011-4701-a1c8-3ff2cdb409b6
incomplete
Partner UAT durchgef&uuml;hrt
