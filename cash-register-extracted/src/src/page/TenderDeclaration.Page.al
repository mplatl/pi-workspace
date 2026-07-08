page 1070558 "CCS CASH Tender Declaration"
{
    Caption = 'Tender Operation';
    PageType = ListPlus;
    SourceTable = "CCS CASH Trans. Cash Decl. E.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
#pragma warning disable AW0008
            repeater(General)
#pragma warning restore AW0008
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Base Amount"; Rec."Base Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Base Amount field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
            }
            group(Control1100004006)
            {
                ShowCaption = false;
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies the value of the Total Amount field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        Clear(TotalAmount);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if xRec.Quantity < Rec.Quantity then
            TotalAmount := TotalAmount + ((Rec.Quantity - xRec.Quantity) * Rec."Base Amount");
        if xRec.Quantity > Rec.Quantity then
            TotalAmount := TotalAmount - ((xRec.Quantity - Rec.Quantity) * Rec."Base Amount");
        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    begin
        if Rec.FindSet() then
            repeat
                TotalAmount += Rec.Amount;
            until Rec.Next() = 0;
    end;

    var
        TotalAmount: Decimal;
}