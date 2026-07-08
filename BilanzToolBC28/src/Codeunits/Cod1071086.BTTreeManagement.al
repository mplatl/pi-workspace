namespace S_W.BilanzTool;

/// <summary>Tree hierarchy management — grouping, renumbering, indent calculation.</summary>
codeunit 62020 "BT Tree Management"
{
    var Logger: Codeunit "BT Logger";

    /// <summary>Get indent level from grouping code.</summary>
    procedure GetIndent(Grouping: Text[100]): Integer
    begin
        if StrLen(Grouping) = 0 then exit(0);
        exit(Round((StrLen(Grouping) - 1) / 3, 1));
    end;

    /// <summary>Get parent grouping from child.</summary>
    procedure GetParentGrouping(Child: Text[100]): Text[100]
    begin
        if StrLen(Child) <= 3 then exit('');
        exit(CopyStr(Child, 1, StrLen(Child) - 3));
    end;

    /// <summary>Roll up amounts from leaf nodes to parent nodes (bottom-up).</summary>
    procedure RollupTotals(var Tree: Record "BT Account Grouping" temporary)
    var
        TempTree2: Record "BT Account Grouping" temporary;
        CurrentParent: Text[100];
    begin
        TempTree2.Copy(Tree);

        // Process all nodes (default key: Grouping Header, Grouping)
        if TempTree2.FindSet() then
            repeat
                if (TempTree2."Node Type" in [TempTree2."Node Type"::Total, TempTree2."Node Type"::Formula, TempTree2."Node Type"::" "]) then begin
                    CurrentParent := TempTree2.Grouping;
                    TempTree2."Amt Curr" := SumChildren(Tree, CurrentParent, 20);
                    TempTree2."Amt Prev" := SumChildren(Tree, CurrentParent, 21);
                    TempTree2.Modify();

                    if Tree.Get(TempTree2."Grouping Header", TempTree2.Grouping) then begin
                        Tree."Amt Curr" := TempTree2."Amt Curr";
                        Tree."Amt Prev" := TempTree2."Amt Prev";
                        Tree.Modify();
                    end;
                end;
            until TempTree2.Next() = 0;
    end;

    local procedure SumChildren(var Tree: Record "BT Account Grouping" temporary; ParentGrouping: Text[100]; FieldNo: Integer): Decimal
    var Sum: Decimal;
    begin
        Sum := 0;
        if Tree.FindSet() then
            repeat
                if (Tree.Grouping <> ParentGrouping) and (StrLen(Tree.Grouping) > StrLen(ParentGrouping)) then
                    if CopyStr(Tree.Grouping, 1, StrLen(ParentGrouping)) = ParentGrouping then
                        if Tree."Node Type" = Tree."Node Type"::"G/L Account" then
                            case FieldNo of
                                20: Sum += Tree."Amt Curr";
                                21: Sum += Tree."Amt Prev";
                            end;
            until Tree.Next() = 0;
        exit(Sum);
    end;

    /// <summary>Format node numbering based on type.</summary>
    procedure FormatNode(NodeNo: Integer; Name: Text[250]; NumberingType: Enum "BT Numbering Type"): Text
    var
        Letter: Text[1];
    begin
        case NumberingType of
            NumberingType::Numeric:
                exit(Format(NodeNo) + '. ' + Name);
            NumberingType::"A-Z":
                begin
                    if (NodeNo >= 1) and (NodeNo <= 26) then begin
                        Letter := CopyStr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', NodeNo, 1);
                        exit(Letter + '. ' + Name);
                    end;
                    exit(Name);
                end;
            NumberingType::Roman, NumberingType::Lowercase, NumberingType::Manual:
                exit(Name);
            else
                exit(Name);
        end;
    end;
}
