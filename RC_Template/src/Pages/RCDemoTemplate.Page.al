// ------------------------------------------------------------------------------------------------
// RC Template – Standalone Role Center
// ------------------------------------------------------------------------------------------------
// Minimales Rollencenter als Vorlage für Demo-Apps.
// Enthält die drei Standard-Action-Bereiche:
//   area(Sections)   = Navigationsmenü (linke Seite)
//   area(embedding)  = Top-Navigation (z. B. Kunden, Lieferanten, Artikel)
//   area(processing) = Action Bar (z. B. Berichte, Stapelverarbeitung)
// ------------------------------------------------------------------------------------------------
/// <summary>
/// Leeres Rollencenter (PageType = RoleCenter) als Vorlage.
/// </summary>
page 60000 "RC Demo Template"
{
    Caption = 'RC Demo';
    PageType = RoleCenter;
    ApplicationArea = Basic, Suite;

    // --------------------------------------------------------------------------------------------
    // Layout: Cues / Activities-Parts (rechter Inhaltsbereich)
    // --------------------------------------------------------------------------------------------
    layout
    {
        area(rolecenter)
        {
            // Eigene Headline: Begrüßung, Doku-Link, KPIs (z. B. offene Aufträge)
            part(DemoHeadline; "RC Demo Headline")
            {
                ApplicationArea = Suite;
            }

            // Activities-Part (Cues) – hier eine existierende BC Activities-Page
            part(DemoActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
        }
    }

    // --------------------------------------------------------------------------------------------
    // Actions
    // --------------------------------------------------------------------------------------------
    actions
    {
        // ========================================================================================
        // area(Sections) – Navigationsmenü (linke Leiste)
        // Gruppiert nach Fachbereichen. Jede group enthält action(s) mit RunObject.
        // ========================================================================================
        area(Sections)
        {
            group(DemoGroup)
            {
                Caption = 'Demo';
                Image = Sales;
                ToolTip = 'Demo-Bereich – hier eigene Aktionen einfügen.';

                action(DemoCustomers)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Kunden';
                    Image = Customer;
                    RunObject = page "Customer List";
                    ToolTip = 'Öffnet die Kundenübersicht.';
                }

                action(DemoVendors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lieferanten';
                    Image = Vendor;
                    RunObject = page "Vendor List";
                    ToolTip = 'Öffnet die Lieferantenübersicht.';
                }

                action(DemoSalesOrders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Verkaufsaufträge';
                    RunObject = page "Sales Order List";
                    ToolTip = 'Öffnet die Liste der Verkaufsaufträge.';
                    ShortCutKey = 'Ctrl+Shift+V';
                }
            }
        }

        // ========================================================================================
        // area(embedding) – Top-Navigation (eingebettete Aktionen über dem Inhalt)
        // ========================================================================================
        area(embedding)
        {
            action(DemoCustomersEmbedded)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Kunden';
                Image = Customer;
                RunObject = page "Customer List";
                ToolTip = 'Schnellzugriff auf die Kundenliste.';
            }

            action(DemoVendorsEmbedded)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Lieferanten';
                Image = Vendor;
                RunObject = page "Vendor List";
                ToolTip = 'Schnellzugriff auf die Lieferantenliste.';
            }

            action(DemoItemsEmbedded)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Artikel';
                Image = Item;
                RunObject = page "Item List";
                ToolTip = 'Schnellzugriff auf die Artikelliste.';
            }
        }

        // ========================================================================================
        // area(processing) – Action Bar (z. B. "Neu", "Berichte", "Verlauf")
        // ========================================================================================
        area(processing)
        {
            group(DemoNew)
            {
                Caption = 'Neu';
                Image = NewDocument;

                action(DemoNewSalesOrder)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Verkaufsauftrag';
                    Image = NewOrder;
                    RunObject = page "Sales Order";
                    RunPageMode = Create;
                    ToolTip = 'Neuen Verkaufsauftrag anlegen.';
                }
            }

            group(DemoReports)
            {
                Caption = 'Berichte';
                Image = Report;

                action(DemoPostedSalesInvoices)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gebuchte Verkaufsrechnungen';
                    Image = PostedOrder;
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'Liste der gebuchten Verkaufsrechnungen.';
                }
            }
        }
    }
}
