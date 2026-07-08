codeunit 1070544 "CCS CASH POS Register Init"
{
    trigger OnRun()
    begin
        InitSetup();
    end;

    var
        RetailSetup: Record "CCS CASH Cash Sales Setup";
        constSTORENosCode: Label 'CS-STORE';
        constPOSNosCode: Label 'CS-POS';
        constSTAFFNosCode: Label 'CS-STAFF';
        constStoreNosDesc: Label 'Cash Sales Store Nos.';
        constPOSNosDesc: Label 'Cas Sales POS Nos.';
        constSTAFFNosDesc: Label 'Cash Sales Staff Nos.';
        constStoreNos: Label 'S01';
        constPOSNos: Label 'P01';
        constSTAFFNos: Label '001';
        NoSeries: Record "No. Series";
        NoSerLine: Record "No. Series Line";

    internal procedure InitSetup()
    begin
        if not RetailSetup.FindFirst() then begin
            RetailSetup.Init();
            RetailSetup."Cash Receipt Invoice Report ID" := 1070541;
            RetailSetup."Dayend Report ID" := 1070545;
            RetailSetup."Cash Invoice Report ID" := 1070540;
            RetailSetup."Daystart Report ID" := 1070544;
            RetailSetup."TenderDecl Report ID" := 1070543;
            RetailSetup."Cash Journal Report ID" := 1070542;
            RetailSetup."Cust. Payment Report ID" := 1070546;
            RetailSetup."Cash Receipt CrMemo Report ID" := 1070551;
            RetailSetup."Cash CrMemo Report ID" := 1070550;
            // + POS0007
            RetailSetup."Voucher Report ID" := 1070553;
            // - POS0007
            RetailSetup."Autovoid Open Transactions" := true;
            RetailSetup."No Dialog on Receipt Print" := true;
            RetailSetup."No Display on Standard Pages" := true;
            RetailSetup."Merge Pmt to Document" := true;
            RetailSetup."Default Quantity at POS" := 1;
            RetailSetup."Store Nos." := constSTORENosCode;
            RetailSetup."POS Terminal Nos." := constPOSNosCode;
            RetailSetup."Staff Nos." := constSTAFFNosCode;
            RetailSetup.Version := '90.0001';
            RetailSetup.Insert();
        end;

        if not NoSeries.Get(constSTORENosCode) then begin
            NoSeries.Init();
            NoSeries.Code := constSTORENosCode;
            NoSeries.Description := constStoreNosDesc;
            NoSeries."Default Nos." := true;
            NoSeries.Insert();

            NoSerLine.Init();
            NoSerLine."Series Code" := constSTORENosCode;
            NoSerLine."Line No." := 10000;
            NoSerLine."Starting No." := constStoreNos;
            NoSerLine."Increment-by No." := 1;
            NoSerLine.Open := true;
            NoSerLine.Insert();
        end;

        if not NoSeries.Get(constPOSNosCode) then begin
            NoSeries.Init();
            NoSeries.Code := constPOSNosCode;
            NoSeries.Description := constPOSNosDesc;
            NoSeries."Default Nos." := true;
            NoSeries.Insert();

            NoSerLine.Init();
            NoSerLine."Series Code" := constPOSNosCode;
            NoSerLine."Line No." := 10000;
            NoSerLine."Starting No." := constPOSNos;
            NoSerLine."Increment-by No." := 1;
            NoSerLine.Open := true;
            NoSerLine.Insert();
        end;

        if not NoSeries.Get(constSTAFFNosCode) then begin
            NoSeries.Init();
            NoSeries.Code := constSTAFFNosCode;
            NoSeries.Description := constSTAFFNosDesc;
            NoSeries."Default Nos." := true;
            NoSeries.Insert();

            NoSerLine.Init();
            NoSerLine."Series Code" := constSTAFFNosCode;
            NoSerLine."Line No." := 10000;
            NoSerLine."Starting No." := constSTAFFNos;
            NoSerLine."Increment-by No." := 1;
            NoSerLine.Open := true;
            NoSerLine.Insert();
        end;
    end;
}