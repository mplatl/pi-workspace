enum 1070555 "CCS CASH Sign. Request Type"
{
    Extensible = true;

    value(0; GetSignature)
    {
        Caption = 'Get Signature';
    }
    value(1; GetQRCode)
    {
        Caption = 'Get QR-Code';
    }
    value(2; State)
    {
        Caption = 'State';
    }
}