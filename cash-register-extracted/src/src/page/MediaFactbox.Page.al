page 1070587 "CCS CASH Media Factbox"
{
    ApplicationArea = All;
    Caption = 'Logo';
    PageType = CardPart;
    SourceTable = "CCS CASH Store";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(Media1; Rec.Logo)
            {
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportPicture)
            {
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a new logo.';

                trigger OnAction()
                begin
                    Rec.ImportPicture();
                end;
            }

            action(DeletePicture)
            {
                Caption = 'Delete';
                Image = Delete;
                ToolTip = 'Deletes the current logo.';

                trigger OnAction()
                begin
                    Rec.DeletePicture();
                end;
            }
        }
    }
}