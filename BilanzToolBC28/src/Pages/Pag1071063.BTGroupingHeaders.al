namespace S_W.BilanzTool;

/// <summary>List of all account grouping headers.</summary>
page 62031 "BT Grouping Headers"
{
    Caption = 'Account Groupings';
    PageType = List;
    SourceTable = "BT Acc. Grouping Header";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Editable; Rec.Editable) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditGrouping)
            {
                Caption = 'Edit Grouping';
                Image = Edit;
                ApplicationArea = All;
                RunObject = Page "BT Account Grouping";
            }
            action(Print)
            {
                Caption = 'Print';
                Image = Report;
                ApplicationArea = All;
            }
        }
    }
}
