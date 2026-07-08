table 1070540 "CCS CASH Cash Sales Setup"
{
    Caption = 'Cash Sales Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key', Locked = true;
        }
        field(10; Version; Code[10])
        {
            Caption = 'Version', Locked = true;
            Editable = false;
        }
        field(11; "Version Build"; Integer)
        {
            Caption = 'Version Build', Locked = true;
            Editable = false;
        }
        field(100; "Default Customer"; Code[20])
        {
            Caption = 'Default Customer';
            TableRelation = Customer;
        }
        field(101; "Default Quantity at POS"; Decimal)
        {
            Caption = 'Default Qty. at POS';
            DecimalPlaces = 0 : 4;
        }
        field(102; "Merge Pmt to Document"; Boolean)
        {
            Caption = 'Merge Pmt. to Document';
        }
        field(103; "No Dialog on Receipt Print"; Boolean)
        {
            Caption = 'No Dialog on Receipt Print';

            trigger OnValidate()
            begin
                if "No Dialog on Receipt Print" then
                    if "Cash Receipt Invoice Report ID" <> 0 then
                        if Confirm(Text001 + Text002, false) then begin
                            PrinterSelect.SetRange("Report ID", "Cash Receipt Invoice Report ID");
                            PAGE.RunModal(0, PrinterSelect);
                        end;
            end;
        }
        field(104; "No Display on Standard Pages"; Boolean)
        {
            Caption = 'No Display on Standard Pages';
        }
        field(115; "Deposit VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'Deposit VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(116; "Expense VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'Expense VAT Bus. Posting Group';
            Description = 'POS0030';
            TableRelation = "VAT Business Posting Group";
        }
        field(117; "Use Document No. As Pst Desc."; Boolean)
        {
            Caption = 'Use Receipt No. for Posting Description';
            DataClassification = CustomerContent;
        }
        field(118; "PMT. Meth. in Descr. of Rct."; Boolean)
        {
            Caption = 'Payment Method in Description of Receipt';
            DataClassification = CustomerContent;
        }
        field(119; "Pmt. Disc. Tolerance Date"; Boolean)
        {
            Caption = 'Allow Payment Discount Tolerance Date';
            DataClassification = CustomerContent;
        }
        field(190; "Autovoid Open Transactions"; Boolean)
        {
            Caption = 'Autovoid Open Transactions';
        }
        field(191; "Use Posting Descr. on Pmt"; Boolean)
        {
            Caption = 'Use Transaction Posting Description for Payment';
            DataClassification = CustomerContent;
        }
        field(200; "Akku Sumline"; enum "CCS CASH Akku Sumline")
        {
            Caption = 'Akku Sumline';
        }
        field(201; "Reset Akku"; Boolean)
        {
            Caption = 'Reset Akku';
        }
        field(202; "Akku Sumline Trans. required"; Boolean)
        {
            Caption = 'Akku Sumline Trans. required';
        }
        field(300; CSLDialogPosting; Boolean)
        {
            Caption = 'Use Cash Sales Dialog on Order Posting';
            Description = 'POS0036';
        }
        field(500; "Store Nos."; Code[20])
        {
            Caption = 'Store Nos.';
            TableRelation = "No. Series";
        }
        field(501; "POS Terminal Nos."; Code[20])
        {
            Caption = 'POS Terminal Nos.';
            TableRelation = "No. Series";
        }
        field(502; "Staff Nos."; Code[20])
        {
            Caption = 'Staff Nos.';
            TableRelation = "No. Series";
        }
        field(503; "Receipt Nos."; Code[20])
        {
            Caption = 'POS Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(504; "Posted Receipt Nos."; Code[20])
        {
            Caption = 'Posted POS Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(600; "Cash Receipt Invoice Report ID"; Integer)
        {
            Caption = 'POS Receipt Invoice Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(601; "Dayend Report ID"; Integer)
        {
            Caption = 'Day End Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(602; "Cash Invoice Report ID"; Integer)
        {
            Caption = 'POS Invoice Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(603; "Daystart Report ID"; Integer)
        {
            Caption = 'Day Start Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(604; "TenderDecl Report ID"; Integer)
        {
            Caption = 'Tender Operation Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(605; "Cash Journal Report ID"; Integer)
        {
            Caption = 'Trans. Log Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(606; "Cust. Payment Report ID"; Integer)
        {
            Caption = 'Cust. Payment Report-ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(607; "Cash Receipt CrMemo Report ID"; Integer)
        {
            Caption = 'POS Receipt Cr. Memo Report-ID';
            Description = 'POS0003';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(608; "Cash CrMemo Report ID"; Integer)
        {
            Caption = 'POS Cr. Memo Report-ID';
            Description = 'POS0003';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(609; "Voucher Report ID"; Integer)
        {
            Caption = 'Voucher Report-ID';
            Description = 'POS0007';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(620; "Cash Receipt Inv. Report Cap"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cash Receipt Invoice Report ID")));
            Caption = 'POS Receipt Invoice Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(621; "Dayend Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Dayend Report ID")));
            Caption = 'Day End Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(622; "Cash Invoice Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cash Invoice Report ID")));
            Caption = 'POS Invoice Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(623; "Daystart Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Daystart Report ID")));
            Caption = 'Day Start Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(624; "TenderDecl Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("TenderDecl Report ID")));
            Caption = 'Tender Operation Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(625; "Cash Journal Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cash Journal Report ID")));
            Caption = 'Trans. Log Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(626; "Cust. Payment Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cust. Payment Report ID")));
            Caption = 'Cust. Payment Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(627; "Cash Receipt CrMem Report Cap"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cash Receipt CrMemo Report ID")));
            Caption = 'POS Receipt Cr. Memo Report Caption';
            Description = 'POS0003';
            Editable = false;
            FieldClass = FlowField;
        }
        field(628; "Cash CrMemo Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Cash CrMemo Report ID")));
            Caption = 'POS Cr. Memo Report Caption';
            Description = 'POS0003';
            Editable = false;
            FieldClass = FlowField;
        }
        field(629; "Voucher Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Voucher Report ID")));
            Caption = 'Voucher Report Caption';
            Description = 'POS0007';
            Editable = false;
            FieldClass = FlowField;
        }
        field(640; "Cash Receipt Invoice Copies"; Integer)
        {
            Caption = 'POS Receipt Invoice Copies';
        }
        field(641; "Dayend Copies"; Integer)
        {
            Caption = 'Day End Copies';
        }
        field(642; "Cash Invoice Copies"; Integer)
        {
            Caption = 'POS Invoice Copies';
        }
        field(643; "Daystart Copies"; Integer)
        {
            Caption = 'Day Start Copies';
        }
        field(644; "TenderDecl Copies"; Integer)
        {
            Caption = 'Tender Operation Copies';
        }
        field(645; "Cash Journal Copies"; Integer)
        {
            Caption = 'POS Log Copies';
        }
        field(646; "Cust. Payment Copies"; Integer)
        {
            Caption = 'Cust. Payment Copies';
        }
        field(647; "Cash Receipt CrMemo Copies"; Integer)
        {
            Caption = 'POS Receipt Cr. Memo Copies';
        }
        field(648; "Cash CrMemo Copies"; Integer)
        {
            Caption = 'POS Cr. Memo Copies';
        }
        field(649; "Voucher Copies"; Integer)
        {
            Caption = 'Voucher Copies';
        }
        field(1000; "Journale Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
        }
        field(1001; "Signature Service"; Boolean)
        {
            Caption = 'Use Signature Service';
        }
        field(1002; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Journale Template Name"));
        }
        field(1500; "Automatic Demo License"; Boolean)
        {
            Caption = 'Automatic Demo License';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'The POS Receipt is printed on the standard printer, a different printer can be set in "Printer Setup".';
        PrinterSelect: Record "Printer Selection";
        Text002: Label '\Do you want to set a printer now?';

    internal procedure GetVersion(): Text[30]
    begin
#pragma warning disable AA0217
        exit(StrSubstNo('%1 Build(%2)', Version, "Version Build"));
#pragma warning restore AA0217
    end;

    internal procedure RefreshApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}