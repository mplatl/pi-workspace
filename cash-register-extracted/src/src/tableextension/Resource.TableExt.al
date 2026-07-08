tableextension 1070548 "CCS CASH Resource" extends Resource
{
    fields
    {
        field(1070540; "CCS CASH Voucher No. Series"; Code[20])
        {
            Caption = 'Voucher No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(1070541; "CCS CASH Price includes VAT"; Boolean)
        {
            Caption = 'Price includes VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Unit Price");
            end;
        }
        field(1070542; "CCS CASH Unit Price Input"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price fh';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Unit Price" := CCS_CASH_CalculatePriceExVAT("CCS CASH Unit Price Input");
            end;
        }
        field(1070543; "CCS CASH VAT Bus. Pst. Gr. Prc"; Code[10])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                Validate("Price/Profit Calculation");
            end;
        }
        field(1070544; "CCS CASH Res. Published"; Boolean)
        {
            Caption = 'Res Published';
            DataClassification = CustomerContent;
        }
        field(1070545; "CCS CASH Voucher C. No. Mand."; Boolean)
        {
            Caption = 'Voucher Card No. Mandatory';
            DataClassification = CustomerContent;
        }
        field(1070546; "CCS CASH IsVoucher"; Boolean)
        {
            Caption = 'Voucher';
            DataClassification = CustomerContent;
        }
    }

    var
        Text1070540: Label 'Prices including VAT cannot be calculated when %1 is %2.', Comment = '%1=Value 1,%2=Value 2';

    local procedure CCS_CASH_CalculatePriceExVAT(InputPrice: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        VATpostingSetup: Record "VAT Posting Setup";
    begin
        if not "CCS CASH Price includes VAT" then
            exit(InputPrice);

        GLSetup.Get();
        if "CCS CASH VAT Bus. Pst. Gr. Prc" <> '' then begin
            VATpostingSetup.Get("CCS CASH VAT Bus. Pst. Gr. Prc", "VAT Prod. Posting Group");
            case VATpostingSetup."VAT Calculation Type" of
                VATpostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATpostingSetup."VAT %" := 0;
                VATpostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text1070540,
                      VATpostingSetup.FieldCaption("VAT Calculation Type"),
                      VATpostingSetup."VAT Calculation Type");
            end;

            exit(Round(
                (InputPrice / (1 + VATpostingSetup."VAT %" / 100)),
                 GLSetup."Unit-Amount Rounding Precision"));
        end;
    end;

}