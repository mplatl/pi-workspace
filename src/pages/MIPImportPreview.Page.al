// ----------------------------------------------------------------------------
// Page: MIP Import Preview
// ----------------------------------------------------------------------------
// Vorschau-Page nach Datei-Upload.
// Zeigt die geparsten Rohdaten mit Status und ermöglicht den Import-Start.
// ----------------------------------------------------------------------------

page 50003 "MIP Import Preview"
{
    Caption = 'Import Preview';
    PageType = List;
    SourceTable = "MIP Import Data Buffer";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Import File Entry No."; Rec."Import File Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = All;
                }
                field("Raw Data JSON"; Rec."Raw Data JSON")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(AutoCreateColumns)
            // {
            //     Caption = 'Auto-Create Columns';
            //     trigger OnAction()
            //     begin
            //         // Spalten automatisch aus Datei-Headern anlegen
            //     end;
            // }

            // action(StartImport)
            // {
            //     Caption = 'Start Import';
            //     trigger OnAction()
            //     begin
            //         // MIPImportEngine.ImportFile(...)
            //     end;
            // }

            // action(TransferToJournal)
            // {
            //     Caption = 'Transfer to Journal';
            //     trigger OnAction()
            //     begin
            //         // validierte Zeilen ins Buchblatt übernehmen
            //     end;
            // }
        }
    }
}
