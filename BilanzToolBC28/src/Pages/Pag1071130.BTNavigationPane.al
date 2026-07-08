namespace S_W.BilanzTool;

/// <summary>BilanzTool Navigation Pane — headline section.</summary>
page 62039 "BT Navigation Pane"
{
    Caption = 'BilanzTool';
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
            group(Welcome)
            {
                ShowCaption = false;
                Visible = WelcomeVisible;
                field(WelcomeText; WelcomeText)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = '';
                }
            }
        }
    }

    var
        WelcomeVisible: Boolean;
        WelcomeText: Text;

    trigger OnOpenPage()
    begin
        WelcomeVisible := true;
        WelcomeText := 'BilanzTool — Finanzauswertungen & Jahresabschlüsse';
    end;
}
