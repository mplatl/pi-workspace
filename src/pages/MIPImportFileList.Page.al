// ----------------------------------------------------------------------------
// Page: MIP Import File List
// ----------------------------------------------------------------------------
// ListPage für Import-Dateien.
// Zeigt alle hochgeladenen Dateien mit Status und Verarbeitungsergebnissen.
// ----------------------------------------------------------------------------

page 50000 "MIP Import File List"
{
    Caption = 'Import Files';
    PageType = List;
    SourceTable = "MIP Import File";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                }
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Lines Total"; Rec."Lines Total")
                {
                    ApplicationArea = All;
                }
                field("Lines Processed"; Rec."Lines Processed")
                {
                    ApplicationArea = All;
                }
                field("Lines Error"; Rec."Lines Error")
                {
                    ApplicationArea = All;
                }
                field("Uploaded At"; Rec."Uploaded At")
                {
                    ApplicationArea = All;
                }
                field("Processed At"; Rec."Processed At")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action("Process")
    //         {
    //             Caption = 'Process';
    //             trigger OnAction()
    //             begin
    //                 // MIPImportEngine.ImportFile(Rec."Entry No.");
    //             end;
    //         }
    //     }
    // }
}
