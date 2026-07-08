page 1070595 "CCS CASH Signa. Srv. Set List"
{
    // fs-soft
    // 
    // Vers.      Date       ID Description
    // _____________________________________________________________________
    // EFSTA2.00  16.08.2016 MK Object created
    // EFSTA2.01  26.01.2017 MK Added new Field "Signature Dev. Broken MT"
    // EFSTA2.03  07.02.2017 MK Changed Object Name and Object Caption and some FieldCaptions
    // EFSTA2.05  21.02.2017 MK Added Option to not Save Picture in Log and Recreate Picture when needed
    // EFSTA2.07  29.03.2017 MK Changed Field "WebService Active" to not be editable.
    //                          No more Delete allowed in the Setup
    // EFSTA2.08  26.04.2017 MK Added Field for Export Path
    //                          Added Action for Export

    AdditionalSearchTerms = 'CASH Signature Service Setup', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Signature Service Setup - Cash Register';
    CardPageID = "CCS CASH Signa. Srv. Set Card";
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "CCS CASH Signa. Service Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "CCS CASH Store List";
                    ToolTip = 'Specifies the value of the Store No. field.';
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                    LookupPageId = "CCS CASH POS Terminals";
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                }
                field("WebService Main Path"; Rec."WebService Main Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Main Path field.';
                }
                field("WebService QR Path"; Rec."WebService QR Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service QR-Path field.';
                }
                field("WebService State Path"; Rec."WebService State Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service State Path field.';
                }
                field("WebService Export Path"; Rec."WebService Export Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Export Path field.';
                }
                field("WebService Active"; Rec."WebService Active")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Web Service Active field.';
                }
                field("Web Service Timeout ms"; Rec."Web Service Timeout ms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Timeout (ms) field.';
                }
                field("Print Picture"; Rec."Print Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Picture field.';
                }
                field("Picture Print Position"; Rec."Picture Print Position")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Print Position field.';
                }
                field("Picture Print Option"; Rec."Picture Print Option")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture for Print field.';
                }
                field("Picture Reduction Factor"; Rec."Picture Reduction Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Reduction Factor field.';
                }
                field("Picture Enlarge Factor"; Rec."Picture Enlarge Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Enlarge Factor field.';
                }
                field("QR Picture Save Option"; Rec."QR Picture Save Option")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the QR-Picture Save Option field.';
                }
                field("Sign. Failure Message Type"; Rec."Sign. Failure Message Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Signature Failure Message Type field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CallExport)
            {
                ApplicationArea = All;
                Caption = 'Call Export';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Executes the Call Export action.';

                trigger OnAction()
                var
                    WebServiceEFSTA: Codeunit "CCS CASH Reg. Webserv. EFSTA";
                begin
                    WebServiceEFSTA.GetExportFile(Rec);
                end;
            }
        }
    }
}