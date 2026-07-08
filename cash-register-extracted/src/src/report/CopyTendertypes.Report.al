report 1070547 "CCS CASH Copy Tendertypes"
{
    Caption = 'Copy Tender Types';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("Tender Type Setup"; "CCS CASH Tender Type Setup")
        {
            RequestFilterFields = "Code";

            trigger OnPreDataItem()
            begin
                if GToStore = '' then
                    Error(Text002);
                if GToStore <> '' then
                    Store.Get(GToStore);

                if (GFromStore = '') or not Store.Get(GFromStore) then
                    Error(Text001);

                SourceTender.SetRange("Store No", GFromStore);
                SourceTender.SetFilter(Code, GetFilter(Code));
                if SourceTender.FindSet() then
                    repeat
                        CopyTender();

                        SourceTenderCard.SetRange("Store No", SourceTender."Store No");
                        SourceTenderCard.SetRange("Tender Type", SourceTender.Code);
                        if SourceTenderCard.FindSet() then
                            repeat
                                CopyTenderCard();
                            until SourceTenderCard.Next() = 0;
                    until SourceTender.Next() = 0;

                if GCopyCashDecl then begin
                    SourceCashDecl.SetRange("Store No.", GFromStore);
                    if SourceCashDecl.FindSet() then
                        repeat
                            CopyCashDeclaration();
                        until SourceCashDecl.Next() = 0;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control1100004001)
                {
                    ShowCaption = false;
                    field(FromStore; GFromStore)
                    {
                        Caption = 'Copy from Store';
                        ShowMandatory = true;
                        TableRelation = "CCS CASH Store"."No.";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Copy from Store field.';
                    }
                    field(ToStore; GToStore)
                    {
                        Caption = 'Copy To Store';
                        ShowMandatory = true;
                        TableRelation = "CCS CASH Store"."No.";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Copy To Store field.';
                    }
                    field(OverrideExisting; GOverrideExisting)
                    {
                        Caption = 'Override existing';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Override existing field.';
                    }
                    field(CopyCashDecl; GCopyCashDecl)
                    {
                        Caption = 'Copy Tender Operation';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Copy Tender Operation field.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Store: Record "CCS CASH Store";
        SourceTender: Record "CCS CASH Store Tender Type";
        DestTender: Record "CCS CASH Store Tender Type";
        DestTender2: Record "CCS CASH Store Tender Type";
        SourceTenderCard: Record "CCS CASH Tender Type C. Setup";
        DestTenderCard: Record "CCS CASH Tender Type C. Setup";
        DestTenderCard2: Record "CCS CASH Tender Type C. Setup";
        SourceCashDecl: Record "CCS CASH Declaration Setup";
        DestCashDecl: Record "CCS CASH Declaration Setup";
        DestCashDecl2: Record "CCS CASH Declaration Setup";
        GFromStore: Code[20];
        GToStore: Code[20];
        GOverrideExisting: Boolean;
        GCopyCashDecl: Boolean;
        Text001: Label 'Select a Store to copy from';
        Text002: Label 'Select a Store to copy to';

    local procedure CopyTender()
    begin
        DestTender.Init();
        DestTender.TransferFields(SourceTender);
        DestTender."Store No" := GToStore;
        DestTender.Validate(Code);
        if not DestTender2.Get(DestTender."Store No", DestTender.Code) then begin
            DestTender.Insert(true);
        end else
            if GOverrideExisting then begin
                DestTender2.TransferFields(SourceTender, false);
                DestTender2.Validate(Code);
                DestTender2.Modify(true);
            end;
    end;

    local procedure CopyTenderCard()
    begin
        DestTenderCard.Init();
        DestTenderCard.TransferFields(SourceTenderCard);
        DestTenderCard."Store No" := GToStore;
        if not DestTenderCard2.Get(
                 DestTenderCard."Store No", DestTenderCard."Tender Type", DestTenderCard."Card No.") then
            DestTenderCard.Insert(true)
        else
            if GOverrideExisting then begin
                DestTenderCard2.TransferFields(SourceTenderCard, false);
                DestTenderCard2.Modify(true);
            end;
    end;

    local procedure CopyCashDeclaration()
    begin
        DestCashDecl.Init();
        DestCashDecl.TransferFields(SourceCashDecl);
        DestCashDecl."Store No." := GToStore;
        if not DestCashDecl2.Get(DestCashDecl."Store No.", DestCashDecl."Tender Type", DestCashDecl.Type, DestCashDecl.Amount) then
            DestCashDecl.Insert(true)
        else
            if GOverrideExisting then begin
                DestCashDecl2.TransferFields(SourceCashDecl, false);
                DestCashDecl2.Modify(true);
            end;
    end;
}