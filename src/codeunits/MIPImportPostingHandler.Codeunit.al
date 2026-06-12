// ----------------------------------------------------------------------------
// Codeunit: MIP Import Posting Handler
// ----------------------------------------------------------------------------
// Event-Subscriptions für die Übertragung der MIP-Felder
// von Buchblattzeilen in gebuchte Posten.
// ----------------------------------------------------------------------------

codeunit 50001 "MIP Import Posting Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Überträgt MIP-Felder von Gen. Journal Line → G/L Entry beim Buchen.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnBeforePostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        SourceRef: RecordRef;
        TargetRef: RecordRef;
    begin
        SourceRef.GetTable(GenJnlLine);
        TargetRef.GetTable(GLEntry);
        TransferMIPFields(SourceRef, TargetRef);
    end;

    /// <summary>
    /// Überträgt MIP-Felder von Item Journal Line → Item Ledger Entry beim Buchen.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure OnBeforePostItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry")
    var
        SourceRef: RecordRef;
        TargetRef: RecordRef;
    begin
        SourceRef.GetTable(ItemJnlLine);
        TargetRef.GetTable(ItemLedgEntry);
        TransferMIPFields(SourceRef, TargetRef);
    end;

    /// <summary>
    /// Kopiert die vier MIP-Felder vom Quell- in den Ziel-Record via FieldRef.
    /// </summary>
    local procedure TransferMIPFields(var SourceRec: RecordRef; var TargetRec: RecordRef)
    var
        SourceField: FieldRef;
        TargetField: FieldRef;
        i: Integer;
    begin
        for i := 1 to 4 do begin
            SourceField := SourceRec.Field(i);
            TargetField := TargetRec.Field(i);
            TargetField.Value := SourceField.Value;
        end;
    end;
}
