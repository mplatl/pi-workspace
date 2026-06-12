// ----------------------------------------------------------------------------
// Page: MIP Import Setup List
// ----------------------------------------------------------------------------
// ListPage für Import-Setups.
// ----------------------------------------------------------------------------

page 50001 "MIP Import Setup List"
{
    Caption = 'Import Setups';
    PageType = List;
    SourceTable = "MIP Import Setup Header";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Record := newRecord;
                end;
            }

            action(Edit)
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Page.Run(Page::"MIP Import Setup Card", Rec);
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    SetupColumn: Record "MIP Import Setup Column";
                    ValueMap: Record "MIP Import Column Value Map";
                begin
                    SetupColumn.SetRange("Setup Code", Rec.Code);
                    SetupColumn.DeleteAll();
                    ValueMap.SetRange("Setup Code", Rec.Code);
                    ValueMap.DeleteAll();
                    Rec.Delete(true);
                end;
            }
        }
    }
}
