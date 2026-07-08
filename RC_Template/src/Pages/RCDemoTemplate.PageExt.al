// ------------------------------------------------------------------------------------------------
// RC Template – PageExtension Beispiel
// ------------------------------------------------------------------------------------------------
// Zeigt, wie ein bestehendes Rollencenter per PageExtension erweitert wird.
// Dieses Beispiel hängt eine Aktion an den "Business Manager Role Center" an.
//
// Pattern:
//   pageextension <ID> "<Name>" extends "<Basis-Rollencenter>"
//   {
//       layout   { addafter(<ControlName>) { part(...) } }   // Cues hinzufügen
//       actions  { addafter(<ActionName>) { action(...) } }   // Navigation erweitern
//   }
// ------------------------------------------------------------------------------------------------
/// <summary>
/// Erweitert "Customer List" um eine Demo-Aktion – zeigt das PageExtension-Pattern.
/// </summary>
pageextension 60001 "RC Demo Cust. List Ext." extends "Customer List"
{
    actions
    {
        addlast(Processing)
        {
            action(DemoExtAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'RC Demo';
                Image = Sales;
                RunObject = page "Sales Order List";
                ToolTip = 'Von RC Demo Template per PageExtension hinzugefügt.';
            }
        }
    }
}
