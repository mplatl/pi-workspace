// ------------------------------------------------------------------------------------------------
// RC Template – Headline Part (Informationsleiste oben im Rollencenter)
// ------------------------------------------------------------------------------------------------
// PageType = HeadlinePart – zeigt eine oder mehrere Info-Gruppen an.
// Jede Gruppe kann statischen Text, berechnete KPIs oder Drilldown-Links enthalten.
//
// Standard-Gruppen (via RCHeadlinesPageCommon):
//   1. GreetingHeadline   → Personalisierte Begrüßung ("Guten Morgen, Michael")
//   2. DocumentationHeadline → "Mehr über <App-Name> erfahren?" mit Link
//
// Eigene Gruppen (Beispiele):
//   3. QuickStatsHeadline  → KPIs wie "Offene Verkaufsaufträge"
//   4. TasksHeadline       → "Letzte Aktion", "Nächster Schritt"
// ------------------------------------------------------------------------------------------------
/// <summary>
/// Headline-Part für das RC Demo Template.
/// Zeigt Begrüßung, Dokumentation und eigene KPIs.
/// </summary>
page 60002 "RC Demo Headline"
{
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(Content)
        {
            // ------------------------------------------------------------------------------------
            // Gruppe 1: Personalisierte Begrüßung (Standard)
            // ------------------------------------------------------------------------------------
            group(GreetingHeadline)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;

                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    Caption = 'Greeting headline';
                    Editable = false;
                }
            }

            // ------------------------------------------------------------------------------------
            // Gruppe 2: Dokumentation (Standard)
            // ------------------------------------------------------------------------------------
            group(DocumentationHeadline)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;

                field(DocumentationText; GetDocumentationText())
                {
                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        HyperLink(RCHeadlinesPageCommon.DocumentationUrlTxt());
                    end;
                }
            }

            // ------------------------------------------------------------------------------------
            // Gruppe 3: Eigene KPI – Anzahl offener Verkaufsaufträge
            // ------------------------------------------------------------------------------------
            group(QuickStatsHeadline)
            {
                ShowCaption = false;
                Visible = QuickStatsVisible;

                field(QuickStatsText; QuickStatsTxt)
                {
                    Caption = 'Quick stats headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Order List");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"RC Demo Headline");
        DefaultFieldsVisible := RCHeadlinesPageCommon.AreDefaultFieldsVisible();
        UserGreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
        LoadQuickStats();
    end;

    /// <summary>
    /// Berechnet eigene KPIs für die Headline.
    /// </summary>
    local procedure LoadQuickStats()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.IsEmpty() then begin
            QuickStatsVisible := false;
            exit;
        end;

        QuickStatsVisible := true;
        QuickStatsTxt := StrSubstNo(
            OpenOrdersHeadlineLbl,
            SalesHeader.Count()
        );
    end;

    /// <summary>
    /// Überschreibt den Doku-Text mit eigenem App-Namen.
    /// </summary>
    local procedure GetDocumentationText(): Text
    var
        thisModule: ModuleInfo;
        DocumentationTxt: Label 'Mehr über %1 erfahren?', Comment = '%1 = App-Name';
    begin
        NavApp.GetCurrentModuleInfo(thisModule);
        exit(StrSubstNo(DocumentationTxt, thisModule.Name));
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        DefaultFieldsVisible: Boolean;
        UserGreetingVisible: Boolean;
        QuickStatsVisible: Boolean;
        QuickStatsTxt: Text;
        OpenOrdersHeadlineLbl: Label '<qualifier>Demo KPI</qualifier><payload><emphasize>%1</emphasize> offene Verkaufsaufträge</payload>';
}
