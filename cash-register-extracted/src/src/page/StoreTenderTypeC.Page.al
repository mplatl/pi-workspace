page 1070552 "CCS CASH Store Tender Type C."
{
    Caption = 'Store Payment Type';
    DelayedInsert = true;
    PageType = Card;
    PopulateAllFields = true;
    SourceTable = "CCS CASH Store Tender Type";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(TenderFunction; Rec.TenderFunction)
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Function field.';

                    trigger OnValidate()
                    begin
                        ToggleFieldVisibility();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Usable; Rec.Usable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the May be Used field.';
                }
                field("Cash Drawer Opens"; Rec."Cash Drawer Opens")
                {
                    ApplicationArea = All;
                    Editable = DrawerOpensEditable;
                    ToolTip = 'Opens Cash Drawer after posting.';
                }
            }
            group(Properties)
            {
                Caption = 'Properties';
                Visible = PropertiesVisible;

                field(Cash; Rec.Cash)
                {
                    ApplicationArea = All;
                    Enabled = CashEnabled;
                    ToolTip = 'Specifies the value of the Cash Money field.';
                }
                field("Counting Required"; Rec."Counting Required")
                {
                    ApplicationArea = All;
                    Enabled = CountRequiredEnabled;
                    ToolTip = 'Specifies the value of the Counting required field.';
                }
                field("Overtender allowed"; Rec."Overtender allowed")
                {
                    ApplicationArea = All;
                    Enabled = OvertenderAllowedEnabled;
                    ToolTip = 'Specifies the value of the Overtender allowed field.';
                }
                field("Float Allowed"; Rec."Float Allowed")
                {
                    ApplicationArea = All;
                    Enabled = FloatAllowedEnabled;
                    ToolTip = 'Specifies the value of the Change allowed field.';
                }
                field("Use in Returns"; Rec."Use in Returns")
                {
                    ApplicationArea = All;
                    Enabled = UseInReturnEnabled;
                    ToolTip = 'Specifies the value of the Use in returns field.';
                }
                field("Voucher Info required"; Rec."Voucher Info required")
                {
                    ApplicationArea = All;
                    Enabled = VoucherInfoEnabled;
                    ToolTip = 'Specifies the value of the Voucher Info required field.';
                }
                group(Control1100004020)
                {
                    ShowCaption = false;
                    field("Tender Remove"; Rec."Tender Remove")
                    {
                        ApplicationArea = All;
                        Enabled = TenderRemoveEnabled;
                        ToolTip = 'Specifies the value of the Tender Remove field.';
                    }
                    field("Tender Remove Description"; Rec."Tender Remove Description")
                    {
                        ApplicationArea = All;
                        Enabled = TenderRemoveEnabled;
                        ToolTip = 'Specifies the value of the Tender Remove Description field.';
                    }
                }
            }
            group(Post)
            {
                Caption = 'Post';
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field.';
                }
                field("Account Description"; Rec."Account Description")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Account Description field.';
                }
                field("Diff. Acc. Type"; Rec."Diff. Acc. Type")
                {
                    ApplicationArea = All;
                    Enabled = DiffAccEnabled;
                    ToolTip = 'Specifies the value of the Difference Account Type field.';
                }
                field("Diff. Account"; Rec."Diff. Account")
                {
                    ApplicationArea = All;
                    Enabled = DiffAccEnabled;
                    ToolTip = 'Specifies the value of the Difference Account field.';
                }
                field("Diff Account Description"; Rec."Diff Account Description")
                {
                    ApplicationArea = All;
                    Enabled = DiffAccEnabled;
                    ToolTip = 'Specifies the value of the Difference Account Description field.';
                }
            }
            group("Bank Account")
            {
                Caption = 'Bank Account';
                field("Bank Account Type"; Rec."Bank Account Type")
                {
                    ApplicationArea = All;
                    Enabled = BankEnabled;
                    ToolTip = 'Specifies the value of the Bank Account Type field.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    Enabled = BankEnabled;
                    ToolTip = 'Specifies the value of the Bank Account No. field.';
                }
                field("Bank Account Description"; Rec."Bank Account Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bank Account Description field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Tender Types")
            {
                Caption = 'Payment Types';
                action("Card Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Card Setup';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "CCS CASH Tendertype C. setup";
                    RunPageLink = "Store No" = FIELD("Store No"),
                                  "Tender Type" = FIELD(Code);
                    ToolTip = 'Executes the Card Setup action.';
                }
            }
        }
    }

    // toggle visibility of function fields according to selected function
    local procedure ToggleFieldVisibility()
    begin
        case Rec.TenderFunction of
            Rec.TenderFunction::Normal:
                begin
                    PropertiesVisible := true;
                    CashEnabled := true;
                    CountRequiredEnabled := true;
                    OvertenderAllowedEnabled := true;
                    FloatAllowedEnabled := true;
                    UseInReturnEnabled := true;
                    VoucherInfoEnabled := false;
                    TenderRemoveEnabled := true;
                    DrawerOpensEditable := true;
                    DiffAccEnabled := true;
                    BankEnabled := true;
                end;
            Rec.TenderFunction::Voucher:
                begin
                    PropertiesVisible := true;
                    CashEnabled := false;
                    CountRequiredEnabled := false;
                    OvertenderAllowedEnabled := false;
                    FloatAllowedEnabled := false;
                    UseInReturnEnabled := false;
                    VoucherInfoEnabled := true;
                    TenderRemoveEnabled := false;
                    DrawerOpensEditable := false;
                    DiffAccEnabled := false;
                    BankEnabled := false;
                end;
            Rec.TenderFunction::Card,
            Rec.TenderFunction::Customer,
            Rec.TenderFunction::"Tender Remove/Float",
            Rec.TenderFunction::Expense,
            Rec.TenderFunction::Deposit:
                begin
                    PropertiesVisible := false;
                end;
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        ToggleFieldVisibility();
    end;

 
    var
        DrawerOpensEditable: Boolean;
        PropertiesVisible: Boolean;
        CashEnabled: Boolean;
        CountRequiredEnabled: Boolean;
        OvertenderAllowedEnabled: Boolean;
        FloatAllowedEnabled: Boolean;
        UseInReturnEnabled: Boolean;
        VoucherInfoEnabled: Boolean;
        TenderRemoveEnabled: Boolean;
        DiffAccEnabled: Boolean;
        BankEnabled: Boolean;
}