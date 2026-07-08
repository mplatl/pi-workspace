page 1070563 "CCS CASH Customer E. Selection"
{
    // POS0029 07.02.17 Changed Object Name, Deleted notused code in Function GetSelectedEntries and Changed SourceTableView

    Caption = 'Cust. Entry Selection';
    DataCaptionExpression = DataCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    RefreshOnActivate = true;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = SORTING("Customer No.", "Posting Date", "Currency Code")
                      WHERE(Open = CONST(true),
                            "Document Type" = FILTER("Credit Memo" | Invoice));
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(EntryFilter; AnyFilterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Customer No. / Name Filter';
                    ToolTip = 'Specifies the value of the Customer No. / Name Filter field.';
                    QuickEntry = true;

                    trigger OnValidate()
                    begin
                        FilterEntries();
                    end;
                }
            }
#pragma warning disable AW0008
            repeater(Lines)
#pragma warning restore AW0008
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    HideValue = "Customer No. Hide Value";
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the customer account number that the entry is linked to.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the document type that the customer entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the customer entry''s posting date.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies a description of the customer entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount that remains to be applied to before the entry has been completely applied.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the amount on the entry has been fully paid or there is still a remaining amount that must be applied to.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        "Customer No. Hide Value" := false;
        CustomerNoOnFormat();
    end;

    trigger OnOpenPage()
    begin
        TempCustLedgEntry.SetCurrentKey("Customer No.", "Currency Code", "Posting Date");
    end;

    var
        AnyFilterValue: Text[150];
        TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        "Customer No. Hide Value": Boolean;

    local procedure FilterEntries()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgEntryLine: Record "Cust. Ledger Entry";
    begin
        Rec.MarkedOnly(false);
        Rec.ClearMarks();
        TempCustLedgEntry.Reset();
        TempCustLedgEntry.DeleteAll();

        if AnyFilterValue = '' then begin
            CurrPage.Update(false);
            exit;
        end;

        // filter customerno:
        CustLedgEntry.SetCurrentKey("Customer No.");
        CustLedgEntry.SetFilter("Customer No.", AnyFilterValue);
        //CustLedgEntry.SETRANGE(Open,TRUE);
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        if CustLedgEntry.FindSet() then
            repeat
                Rec.Get(CustLedgEntry."Entry No.");
                Rec.Mark(true);
                TempCustLedgEntry.SetRange("Customer No.", CustLedgEntry."Customer No.");
                if not TempCustLedgEntry.FindFirst() then begin
                    TempCustLedgEntry := CustLedgEntry;
                    TempCustLedgEntry.Insert();
                end;
            until CustLedgEntry.Next() = 0;

        CustLedgEntry.SetRange("Customer No.");
        CustLedgEntry.SetCurrentKey("Document No.");
        CustLedgEntry.SetFilter("Document No.", AnyFilterValue);
        if CustLedgEntry.FindSet() then
            repeat
                Rec.Get(CustLedgEntry."Entry No.");
                Rec.Mark(true);
                TempCustLedgEntry.SetRange("Customer No.", CustLedgEntry."Customer No.");
                if not TempCustLedgEntry.FindFirst() then begin
                    TempCustLedgEntry := CustLedgEntry;
                    TempCustLedgEntry.Insert();
                end;
            until CustLedgEntry.Next() = 0;

        Rec.MarkedOnly(true);
        CustLedgEntryLine := Rec;
        //IF FIND('-') THEN;
        CurrPage.UPDATE(FALSE);
        CurrPage.SetRecord(CustLedgEntryLine);
        CurrPage.Activate();
    end;

    local procedure IsFirstLine(): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.SetCurrentKey("Customer No.", "Currency Code", "Posting Date");
        TempCustLedgEntry.Reset();
        if not Rec.MarkedOnly then
            TempCustLedgEntry.CopyFilters(Rec);
        TempCustLedgEntry.SetRange("Customer No.", Rec."Customer No.");
        if not TempCustLedgEntry.FindFirst() then begin
            CustLedgEntry.CopyFilters(Rec);
            CustLedgEntry.SetRange("Customer No.", Rec."Customer No.");
            if CustLedgEntry.FindFirst() then begin
                TempCustLedgEntry := CustLedgEntry;
                TempCustLedgEntry.Insert();
            end;
        end;
        if Rec."Entry No." = TempCustLedgEntry."Entry No." then
            exit(true);
    end;

    local procedure CustomerNoOnFormat()
    begin
        if not IsFirstLine() then
            "Customer No. Hide Value" := true;
    end;

    procedure GetSelectedEntries(var pCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        pCustLedgEntry.Copy(Rec);
        CurrPage.SetSelectionFilter(pCustLedgEntry);
        pCustLedgEntry.Mark(true);
    end;

    local procedure DataCaption(): Text
    var
        Cust: Record Customer;
    begin
        Cust.Get(Rec."Customer No.");
#pragma warning disable AA0217
        exit(StrSubstNo('%1 %2', Cust.Name, Rec."Document No."));
#pragma warning restore AA0217
    end;
}