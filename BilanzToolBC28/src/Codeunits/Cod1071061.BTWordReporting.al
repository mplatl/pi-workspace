namespace S_W.BilanzTool;

using System.Integration.Word;
using System.Utilities;

/// <summary>Word-based financial report generation.</summary>
codeunit 62011 "BT Word Reporting"
{
    var
        WordTemplate: Codeunit "Word Template";
        Logger: Codeunit "BT Logger";

    procedure GenerateByTemplateCode(BCWordTemplateCode: Code[30]; var Dict: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format")
    begin
        WordTemplate.Load(BCWordTemplateCode);
        WordTemplate.Merge(Dict, SaveFormat);
    end;

    procedure DownloadDocument()
    begin
        WordTemplate.DownloadDocument();
    end;

    procedure BuildBalanceMergeData(BalanceDate: Date; GroupingCode: Code[20]; var Dict: Dictionary of [Text, Text])
    var
        DataMgt: Codeunit "BT Data Management";
        TempTree: Record "BT Account Grouping" temporary;
        CleanName: Text;
    begin
        Dict.Add('Bilanzdatum', Format(BalanceDate));
        Dict.Add('Druckdatum', Format(Today()));
        DataMgt.CalculateTree(GroupingCode, BalanceDate, TempTree);
        if TempTree.FindSet() then
            repeat
                CleanName := CopyStr(TempTree.Name, 1, MaxStrLen(TempTree.Name));
                if CleanName <> '' then begin
                    Dict.Add(StrSubstNo('BIL_%1_Amt', CleanName), Format(TempTree."Amt Curr"));
                    Dict.Add(StrSubstNo('BIL_%1_Prev', CleanName), Format(TempTree."Amt Prev"));
                end;
            until TempTree.Next() = 0;
    end;

    procedure BuildPLMergeData(BalanceDate: Date; GroupingCode: Code[20]; var Dict: Dictionary of [Text, Text])
    var
        DataMgt: Codeunit "BT Data Management";
        TempTree: Record "BT Account Grouping" temporary;
        CleanName: Text;
    begin
        Dict.Add('Bilanzdatum', Format(BalanceDate));
        DataMgt.CalculateTree(GroupingCode, BalanceDate, TempTree);
        if TempTree.FindSet() then
            repeat
                CleanName := CopyStr(TempTree.Name, 1, MaxStrLen(TempTree.Name));
                if CleanName <> '' then begin
                    Dict.Add(StrSubstNo('GUV_%1_Amt', CleanName), Format(TempTree."Amt Curr"));
                    Dict.Add(StrSubstNo('GUV_%1_Prev', CleanName), Format(TempTree."Amt Prev"));
                end;
            until TempTree.Next() = 0;
    end;
}
