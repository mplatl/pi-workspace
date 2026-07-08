page 1070594 "CCS CASH Signa. Srv. Req. Log"
{
    // fs-soft
    // 
    // Vers.      Date       ID Description
    // _____________________________________________________________________
    // EFSTA2.00  12.04.2016 MK Object created
    // EFSTA2.03  07.02.2017 FS Changed Obejct Name and Object Caption and Field Counter->"Entry No."

    AdditionalSearchTerms = 'CASH Signature Service Request Log', Locked = true;
    ApplicationArea = CCSCASH;
    Caption = 'Signature Service Request Log - Cash Register';
    Editable = false;
    PageType = List;
    SourceTable = "CCS CASH Signa. Srv. Req. Log";
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
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Type field.';
                }
                field("Response Error"; Rec."Response Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Error field.';
                }
                field("Response Text"; Rec."Response Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Text field.';
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Code field.';
                }
                field("User Message"; Rec."User Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Message field.';
                }
                field("Tag Label"; Rec."Tag Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tag Label field.';
                }
                // field(Request; Rec.Request) // TODO Change to Media
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Request Sequence field.';
                // }
                // field(Response; Rec.Response) // TODO Change to Media
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the Response Sequence field.';
                // }
                field("QR Code"; Rec."QR Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the QR-Code field.';
                }
                // field("QR Picture"; Rec."QR Picture") // TODO Change to Media
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the QR Picture field.';
                // }
                // field("QR Picture Resized"; Rec."QR Picture Resized") // TODO Change to Media
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the value of the QR Picture Resized field.';
                // }
                field("Request Timestamp"; Rec."Request Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Timestamp field.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("XML-Communication")
            {
                Caption = 'XML-Communication';
                Image = Calculator;
                action("Open Request")
                {
                    ApplicationArea = All;
                    Caption = 'Open Request';
                    Image = CalculateLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunPageMode = View;
                    ToolTip = 'Executes the Open Request action.';

                    trigger OnAction()
                    begin
                        ShowXMLFile(0);
                    end;
                }
                action("Open Response")
                {
                    ApplicationArea = All;
                    Caption = 'Open Response';
                    Image = GetLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunPageMode = View;
                    ToolTip = 'Executes the Open Response action.';

                    trigger OnAction()
                    begin
                        ShowXMLFile(1);
                    end;
                }
                action("Open QR-Picture")
                {
                    ApplicationArea = All;
                    Caption = 'Open QR-Picture';
                    Image = Picture;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Executes the Open QR-Picture action.';

                    trigger OnAction()
                    begin
                        ShowXMLFile(2);
                    end;
                }
            }
        }
    }

    local procedure ShowXMLFile(Which: Option Request,Response,Picture)
    var
        LocInStream: InStream;
        XMLFile: Label 'XML-Files (*.xml)|*.xml';
        ToFile: Text;
        PICFile: Label 'Image-File (*.bmp)|*.bmp';
    begin
        Clear(LocInStream);
        case Which of
            Which::Request:
                begin
                    Rec.CalcFields(Request);
                    Rec.Request.CreateInStream(LocInStream);
                    ToFile := 'Request.xml';
                end;
            Which::Response:
                begin
                    Rec.CalcFields(Response);
                    Rec.Response.CreateInStream(LocInStream);
                    ToFile := 'Response.xml';
                end;
            Which::Picture:
                begin
                    Rec.CalcFields("QR Picture");
                    Rec."QR Picture".CreateInStream(LocInStream);
                    ToFile := 'QR Picture.bmp';
                end;
        end;

        if Which in [Which::Request, Which::Response] then
            DownloadFromStream(LocInStream, 'XML File', '', XMLFile, ToFile);

        if Which = Which::Picture then
            DownloadFromStream(LocInStream, 'QR Picture', '', PICFile, ToFile);
    end;
}