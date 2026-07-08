page 1070561 "CCS CASH Tender Operation"
{
    // POS0013 18.08.16 AP call ExitSession() if nothing posted
    // POS0015 19.08.16 FS Prepare Dayend
    // POS0029 07.02.17 FS Changed Property ModifiyAllowed to Yes, Set Group General to Visible False,
    //                     Set Field "Fixed Amount" and "Bank Amount" to Editable,
    //                     TransSafe.SetRange change from "Safe Type" to "Depot Type", Exitsession only when Startday

    Caption = 'Tender Operation';
    DataCaptionExpression = GetPageCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = ListPlus;
    SourceTable = "CCS CASH Trans. Tender Dcl. E.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Generel)
            {
                Visible = false;
                field(InputAmount; InputAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the value of the Amount field.';
                }
            }
#pragma warning disable AW0008
            repeater(Control1100004002)
#pragma warning restore AW0008
            {
                ShowCaption = false;
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Code';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Code field.';
                }
                field("Tender Type Text"; Rec."Tender Type Text")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FixedAmtVisible;
                    ToolTip = 'Specifies the value of the POS Amount field.';
                }
                field("Fixed Amount"; Rec."Fixed Amount")
                {
                    ApplicationArea = All;
                    Visible = FixedAmtVisible;
                    ToolTip = 'Specifies the value of the Cash Counted field.';

                    trigger OnAssistEdit()
                    begin
                        Rec.Validate("Fixed Amount", TenderDecl(Rec."Fixed Amount", Enum::"CCS CASH Payment Safe Type"::"Fixed Float"));
                        CurrPage.Update(true);
                    end;
                }
                field("Bank Amount"; Rec."Bank Amount")
                {
                    ApplicationArea = All;
                    Visible = BankAmtVisible;
                    ToolTip = 'Specifies the value of the Bank Amount field.';

                    trigger OnAssistEdit()
                    begin
                        Rec.Validate("Bank Amount", TenderDecl(Rec."Bank Amount", Enum::"CCS CASH Payment Safe Type"::Bank));
                        CurrPage.Update(true);
                    end;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Visible = FixedAmtVisible;
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
                field("Diff. Amount"; Rec."Diff. Amount")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    Visible = FixedAmtVisible;
                    ToolTip = 'Specifies the value of the Difference Amount field.';
                }
                field("Fiskal Zero Document"; Rec."Fiskal Zero Document")
                {
                    ApplicationArea = All;
                    Visible = ZeroDocVisible;
                    ToolTip = 'Specifies the value of the Zero Document field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(PostTenderop)
            {
                ApplicationArea = All;
                Caption = 'Post (F9)';
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ShortCutKey = 'F9';
                ToolTip = 'Executes the Post action.';

                trigger OnAction()
                var
                    TTDecl: Record "CCS CASH Trans. Tender Dcl. E.";
                    Confirmed: Boolean;
                    MaxDiff: Decimal;
                begin
                    Confirmed := true;
                    if Tender_OP in [Tender_OP::TermEnd, Tender_OP::TermStart] then begin
                        TTDecl.SetRange("Store No.", TransHeader."Store No.");
                        TTDecl.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                        TTDecl.SetRange("Transaction No.", TransHeader."Transaction No.");
                        if TTDecl.FindFirst() then
                            repeat

                                MaxDiff := TTDecl."Cash Amount" * Staff."Max. Cash Amt. Diff %" / 100;

                                if Staff."Max Cash Amt. Diff." > MaxDiff then
                                    MaxDiff := Staff."Max Cash Amt. Diff.";

                                if (Tender_OP = Tender_OP::TermEnd) and (MaxDiff <> 0) and (Abs(MaxDiff) < Abs(TTDecl."Diff. Amount")) then
#pragma warning disable AA0231
                                    Error(Text007 + Text008, CSLFunc.FormatDec(MaxDiff, 2, false));
#pragma warning restore AA0231

                                if Confirmed and (Rec."Diff. Amount" <> 0) then
                                    Confirmed := Confirm(Text007 + Text009, false);
                            until Rec.Next() = 0;
                    end;

                    if Confirmed then
                        TenderOp_Posted := CSLFunc.PostTenderOperation(TransHeader);

                    if TenderOp_Posted then begin
                        Commit();
                        CSLFunc.PrintReport(Print_OP::CashReceipt, TransHeader, true);
                        //++POS0029
                        if (TransHeader."Transaction Type" = TransHeader."Transaction Type"::EndDay) and Rec."Fiskal Zero Document" then
                            CSLFunc.ZeroTransaction(RetailUser, Enum::"CCS CASH Zero Receipt Type"::ZeroReceipt);
                        //--POS0029
                        CurrPage.Close();
                    end;
                end;
            }
            action(FixedEntry)
            {
                ApplicationArea = All;
                Caption = 'Count Amount';
                Image = ExtendedDataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = FixedAmtVisible;
                ToolTip = 'Executes the Count Amount action.';

                trigger OnAction()
                begin
                    Rec.Validate("Fixed Amount", InputAmount);
                    InputAmount := 0;
                    CurrPage.Update(true);
                end;
            }
            action(BankEntry)
            {
                ApplicationArea = All;
                Caption = 'Bank Entry';
                Image = ExtendedDataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = BankAmtVisible;
                ToolTip = 'Executes the Bank Entry action.';

                trigger OnAction()
                begin
                    Rec.Validate("Bank Amount", InputAmount);
                    InputAmount := 0;
                    CurrPage.Update(true);
                end;
            }
            action("Cash Drawer")
            {
                ApplicationArea = All;
                Caption = 'Open Cash Drawer';
                Image = Debug;
                ToolTip = 'Opens the Cash Drawer';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = CashDrawerExist;

                trigger OnAction()
                begin
                    POSTerm.OpenCashDrawer(false);
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        //++POS0013
        if not TenderOp_Posted then begin
            TransHeader.Delete(true);
            //++POS0029
            if TransHeader."Transaction Type" = TransHeader."Transaction Type"::Startday then
                CSLFunc.ExitSession(POSTerm);
            //--POS0029
        end;
        //--POS0013
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if TenderOp_Posted then begin
            if POSTerm."Cash Drawer Connection Code" <> '' then begin
                POSTerm.OpenCashDrawer(true, true, true);
            end;
            exit(true);
        end;
        exit(Confirm(Text001 + Text006, false, Format(Tender_OP)));
    end;

    var
        RetailUser: Record "CCS CASH Retail User";
        TransHeader: Record "CCS CASH POS Transaction Hdr.";
        TenderType: Record "CCS CASH Store Tender Type";
        Staff: Record "CCS CASH Staff";
        POSTerm: Record "CCS CASH POS Terminal";
        CSLFunc: Codeunit "CCS CASH POS Register Func";
        InputAmount: Decimal;
        HeaderText: Text;
        TenderOp_Posted: Boolean;
        Tender_OP: Option Remove,Float,TermStart,TermEnd;
        Text001: Label 'The %1 Operation was not Posted.', Comment = '%1=Value 1';
        Text002: Label 'Change Entry';
        Text003: Label 'Equalisation Levy';
        Text004: Label 'Day Start';
        Text005: Label 'Day End';
        BankAmtVisible: Boolean;
        FixedAmtVisible: Boolean;
        Text006: Label '\Do you really want to close without Posting?';
        Text007: Label 'Cash Amount calcualted and counted is different.';
        Text008: Label '\Your maximum allowed difference is %1', Comment = '%1=Value 1';
        Text009: Label '\Do you really want to Post the difference?';
        ZeroDocVisible: Boolean;
        Print_OP: Option CashReceipt,CashInvoice,CustPayment,StartDay,EndDay,Journal,Tenderdecl;
        CashDrawerExist: Boolean;

    internal procedure SetTerminalOption(var pRetailUser: Record "CCS CASH Retail User"; var pTransHead: Record "CCS CASH POS Transaction Hdr."; pTenderOp: Option Remove,Float,TermStart,TermEnd; pHdrText: Text)
    var
        TransPmt: Record "CCS CASH Trans. Payment Entry";
        TransSafe: Record "CCS CASH Trans. Depot Entry";
        TTenderDecl: Record "CCS CASH Trans. Tender Dcl. E.";
        NextLineno: Integer;
    begin
        RetailUser := pRetailUser;
        TransHeader := pTransHead;
        Tender_OP := pTenderOp;
        Staff.Get(RetailUser."Staff ID");
        POSTerm.Get(pRetailUser."Store No", pRetailUser."POS Terminal No.");
        POSTerm.CalcFields(Balance);

        if POSTerm."Cash Drawer Connection Code" <> '' then begin
            CashDrawerExist := true;
            POSTerm.OpenCashDrawer(true, true, false);
        end;

        Rec.SetRange("Store No.", TransHeader."Store No.");
        Rec.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
        Rec.SetRange("Transaction No.", TransHeader."Transaction No.");

        TenderType.SetRange("Store No", RetailUser."Store No");
        TenderType.SetRange(Cash, true);
        if TenderType.FindSet() then
            repeat
                TTenderDecl.Init();
                NextLineno += 10000;
                TTenderDecl."Store No." := TransHeader."Store No.";
                TTenderDecl."POS Terminal No." := TransHeader."POS Terminal No.";
                TTenderDecl."Transaction No." := TransHeader."Transaction No.";
                TTenderDecl."Line No." := NextLineno;
                TTenderDecl."Tender Type" := TenderType.Code;
                TTenderDecl."Tender Type Text" := TenderType.Description;
                TTenderDecl."Counting Required" := TenderType."Counting Required";

                if pTenderOp <> pTenderOp::Float then begin
                    TransPmt.SetRange("Store No.", TransHeader."Store No.");
                    TransPmt.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                    TransPmt.SetRange("Safe Type", TransPmt."Safe Type"::"Normal");
                    TransPmt.CalcSums(Amount);
                    TTenderDecl."Cash Amount" := POSTerm.Balance;
                end;

                // + POS0015
                case pTenderOp of
                    pTenderOp::TermEnd:
                        TTenderDecl.Validate("Fixed Amount", 0);
                    pTenderOp::TermStart:
                        begin
                            TransSafe.SetRange("Store No.", TransHeader."Store No.");
                            TransSafe.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
                            TransSafe.SetRange("Depot Type", TransPmt."Safe Type"::"Fixed Float");
                            TransSafe.SetRange("Tender Type", TenderType.Code);
                            TransSafe.CalcSums(Amount);
                            TTenderDecl.Validate("Cash Amount", TransSafe.Amount);
                        end;
                end;
                // - POS0015

                TTenderDecl.Insert(true);
            until TenderType.Next() = 0;
        HeaderText := pHdrText;
        Tender_OP := pTenderOp;
        BankAmtVisible := Tender_OP in [Tender_OP::Remove, Tender_OP::TermEnd, Tender_OP::Float];
        FixedAmtVisible := Tender_OP in [Tender_OP::TermEnd, Tender_OP::TermStart];
        ZeroDocVisible := Tender_OP = Tender_OP::TermEnd;
    end;

    internal procedure TenderOpStatus(): Boolean
    begin
        exit(TenderOp_Posted);
    end;

    local procedure GetPageCaption(): Text[80]
    var
        HdrInfo: Text[50];
    begin
        case Tender_OP of
            Tender_OP::Float:
                HdrInfo := Text002;
            Tender_OP::Remove:
                HdrInfo := Text003;
            Tender_OP::TermEnd:
                HdrInfo := Text005;
            Tender_OP::TermStart:
                HdrInfo := Text004;
        end;

        if HeaderText = '' then
#pragma warning disable AA0217
            exit(StrSubstNo('%1', HdrInfo));
        exit(CopyStr(StrSubstNo('%1', HeaderText), 1, 80));
#pragma warning restore AA0217
    end;

    local procedure TenderDecl(ParamInputAmount: Decimal; ParamSafeType: Enum "CCS CASH Payment Safe Type"): Decimal
    var
        TransCashCount: Record "CCS CASH Trans. Cash Decl. E.";
        DeclSetup: Record "CCS Cash Declaration Setup";
        DeclPage: Page "CCS CASH Tender Declaration";
        NextLineNo: Integer;
    begin
        DeclSetup.SetRange("Store No.", TransHeader."Store No.");
        DeclSetup.SetRange("Tender Type", Rec."Tender Type");
        DeclSetup.FindSet();
        repeat
            TransCashCount.Init();
            NextLineNo += 1;
            TransCashCount."Store No." := TransHeader."Store No.";
            TransCashCount."POS Terminal No." := TransHeader."POS Terminal No.";
            TransCashCount."Transaction No." := TransHeader."Transaction No.";
            TransCashCount."Staff ID" := TransHeader."Staff ID";
            TransCashCount."Line No." := NextLineNo;

            TransCashCount."Decl. Key" := ParamSafeType.AsInteger();
            TransCashCount."Tender Type" := DeclSetup."Tender Type";
            TransCashCount.Type := GetCashDeclEntryType(DeclSetup.Type);
            TransCashCount."Base Amount" := DeclSetup.Amount;
            TransCashCount."Creation Date" := Today;
            TransCashCount."Creation Time" := Time;
            if TransCashCount.Insert(true) then;
        until DeclSetup.Next() = 0;
        Commit();

        TransCashCount.SetRange("Store No.", TransHeader."Store No.");
        TransCashCount.SetRange("POS Terminal No.", TransHeader."POS Terminal No.");
        TransCashCount.SetRange("Transaction No.", TransHeader."Transaction No.");
        DeclPage.SetTableView(TransCashCount);
        DeclPage.LookupMode(true);
        if DeclPage.RunModal() = ACTION::LookupOK then begin
            TransCashCount.CalcSums(Amount);
            exit(TransCashCount.Amount);
        end;
        exit(ParamInputAmount);
    end;

    local procedure GetCashDeclEntryType(DeclType: Enum "CCS CASH Decl. Option"): enum "CCS CASH Decl. Option Entry"
    var
        DeclType_Entry: enum "CCS CASH Decl. Option Entry";
    begin
        case DeclType of
            DeclType::Coin:
                exit(DeclType_Entry::Coin);
            DeclType::Note:
                exit(DeclType_Entry::Note);
            DeclType::Roll:
                exit(DeclType_Entry::Roll);
        end;
    end;
}