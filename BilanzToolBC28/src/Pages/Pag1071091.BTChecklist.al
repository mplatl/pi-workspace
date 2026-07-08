namespace S_W.BilanzTool;

/// <summary>Checklist Page.</summary>
page 62035 "BT Checklist"
{
    Caption = 'Checklist';
    PageType = List;
    SourceTable = "BT Checklist";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Task; Rec.Task) { ApplicationArea = All; }
                field(Finished; Rec.Finished) { ApplicationArea = All; }
            }
        }
    }
}
