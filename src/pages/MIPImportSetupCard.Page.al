// ----------------------------------------------------------------------------
// Page: MIP Import Setup Card
// ----------------------------------------------------------------------------
// CardPage für die Bearbeitung eines Import-Setups.
// Reiter: Allgemein (Setup-Header), Spalten (Mapping), Wert-Mappings, Vorschau.
// ----------------------------------------------------------------------------

page 50002 "MIP Import Setup Card"
{
    Caption = 'Import Setup';
    PageType = Card;
    SourceTable = "MIP Import Setup Header";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    NotBlank = true;
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("File Encoding"; Rec."File Encoding")
                {
                    ApplicationArea = All;
                }
                field("Column Separator"; Rec."Column Separator")
                {
                    ApplicationArea = All;
                }
                field("First Row Is Header"; Rec."First Row Is Header")
                {
                    ApplicationArea = All;
                }
                field("Auto Post"; Rec."Auto Post")
                {
                    ApplicationArea = All;
                }
                field("Posting Date Formula"; Rec."Posting Date Formula")
                {
                    ApplicationArea = All;
                }
                field("Document No. Series"; Rec."Document No. Series")
                {
                    ApplicationArea = All;
                }
            }

            group(Columns)
            {
                Caption = 'Columns';
                repeater(ColumnList)
                {
                    field("Line No."; SetupColumn."Line No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Source Column Name"; SetupColumn."Source Column Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Source Column No."; SetupColumn."Source Column No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Target Field No."; SetupColumn."Target Field No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Target Field Name"; SetupColumn."Target Field Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Mapping Type"; SetupColumn."Mapping Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Validate"; SetupColumn.Validate)
                    {
                        ApplicationArea = All;
                    }
                    field("Skip Empty"; SetupColumn."Skip Empty")
                    {
                        ApplicationArea = All;
                    }
                    field("Default Value"; SetupColumn."Default Value")
                    {
                        ApplicationArea = All;
                    }
                    field("Is Business Key"; SetupColumn."Is Business Key")
                    {
                        ApplicationArea = All;
                    }
                    field("Condition Expression"; SetupColumn."Condition Expression")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action("ValueMaps")
    //         {
    //             Caption = 'Value Maps';
    //             trigger OnAction()
    //             begin
    //             end;
    //         }
    //     }
    // }

    var
        SetupColumn: Record "MIP Import Setup Column";
        ValueMap: Record "MIP Import Column Value Map";

    trigger OnOpenPage()
    begin
        SetupColumn.SetRange("Setup Code", Rec.Code);
    end;
}
