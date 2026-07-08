namespace S_W.BilanzTool;

/// <summary>BilanzTool Word Template List.</summary>
page 62034 "BT Word Templates"
{
    Caption = 'Word Templates';
    PageType = List;
    SourceTable = "BT Word Template";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field("BC Template Code"; Rec."BC Template Code") { ApplicationArea = All; }
            }
        }
    }
}
