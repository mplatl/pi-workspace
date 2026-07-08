page 1070542 "CCS CASH Store Card"
{
    Caption = 'Store Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Money Mgt.';
    SourceTable = "CCS CASH Store";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store No. field.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit() then
                            CurrPage.Update();
                    end;
                }
                field("Respons. Center Code"; Rec."Respons. Center Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsibility Center Code field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Name 2"; Rec."Name 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Name 2 field.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Address 2 field.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Country/Region Code field.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field.';
                }
                field("Home Page"; Rec."Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Home Page field.';
                }
                field("Text After Text"; Rec."Aftertext Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the After Text value for the Sales Invoice Receipt';
                }
                field("Aftertext Payment Conf."; Rec."Aftertext Payment Conf.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the After Text value for the Payment Confirmation Receipt';
                }
                field("Pre-Text Person in Charge for Sales Invoice Receipt"; Rec."Pre-Text Person in Charge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pre-Text in Front of the Person in Charge which will be printed above Text for the Sales Invoice Receipt';
                }
                field("Logo Position on Documents"; Rec."Logo Position on Documents")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Logo Position on Documents field.';
                }
                field(Picture; HasLogo)
                {
                    Caption = 'Logo available';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Picture field.';
                }
            }
            group("Cash Register")
            {
                Caption = 'Cash Register';
                field("Default Customer"; Rec."Default Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Customer field.';
                }
                field("Default Qty. at POS"; Rec."Default Qty. at POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Quantity at POS field.';
                }
                field("Daily Statement necessary"; Rec."Daily Statement necessary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Daily Statement necessary field.';
                }
            }
            group("No. Series")
            {
                Caption = 'No. Series';
                field("Receipt Nos."; Rec."Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Receipt No. Series field.';
                }
                field("Posted Receipt Nos."; Rec."Posted Receipt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posted POS Receipt No. Series field.';
                }
            }
            part("Store Terminals"; "CCS CASH Store Terminals")
            {
                ApplicationArea = All;
                Caption = 'Store Terminals';
                SubPageLink = "Store No" = FIELD("No.");
                Editable = true;
            }
        }
        area(factboxes)
        {
            part(MediaFactbox; "CCS CASH Media Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
            systempart(Control1100004024; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control1100004025; Links)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(PromotedGroup)
            {
                action("Tender Types")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Types Setup';
                    Image = CashFlowSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = Page "CCS CASH Tender Type List";
                    RunPageLink = "Store No" = FIELD("No.");
                    ToolTip = 'Executes the Payment Types Setup action.';
                }
                action("Cash Declaration Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Tender Operation Setup';
                    Image = CashFlowSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = Page "CCS CASH Cash Decl. Setup";
                    RunPageLink = "Store No." = FIELD("No.");
                    ToolTip = 'Executes the Tender Operation Setup action.';
                }
                action("Copy Tender Types")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Payment Types';
                    Image = CopyToTask;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    RunObject = Report "CCS CASH Copy Tendertypes";
                    ToolTip = 'Executes the Copy Payment Types action.';
                }
                action("Import Pictrue")
                {
                    ApplicationArea = All;
                    Caption = 'Import Logo';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Import Logo action.';

                    trigger OnAction()
                    begin
                        Rec.ImportPicture();
                        SetHasLogo();
                    end;
                }
                action("Delete Pictrue")
                {
                    ApplicationArea = All;
                    Caption = 'Delete Logo';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Delete Logo action.';

                    trigger OnAction()
                    begin
                        Rec.DeletePicture();
                        SetHasLogo();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetHasLogo();
    end;

    local procedure SetHasLogo()
    begin
        if rec.Logo.HasValue then
            HasLogo := true
        else
            HasLogo := false;
    end;

    var
        HasLogo: Boolean;
}