namespace S_W.BilanzTool;

/// <summary>List Values Page.</summary>
page 62036 "BT List Values"
{
    Caption = 'List Values';
    PageType = List;
    SourceTable = "BT List Values";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field("List Value Type"; Rec."List Value Type") { ApplicationArea = All; }
                field("Entry Date"; Rec."Entry Date") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
            }
        }
    }
}
