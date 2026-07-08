/// <summary>
/// Testet die Übertragung des WA-Kommentars vom Warenausgangskopf in den gebuchten Lieferschein.
/// Verwendet das Application Test Toolkit (Library-Sales, Library-Warehouse, Library-Inventory).
/// </summary>
codeunit 90105 "WA Comment Transfer Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        WarehouseEmployee: Record "Warehouse Employee";

    /// <summary>
    /// Testet, dass ein Kommentar vom Warenausgangskopf beim Buchen in den Lieferschein übertragen wird.
    /// </summary>
    [Test]
    [Scope('OnPrem')]
    procedure TransferCommentToSalesShipment()
    var
        Location: Record Location;
        Item: Record Item;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseSourceFilter: Record "Warehouse Source Filter";
        SalesShipmentHeader: Record "Sales Shipment Header";
        TestComment: Text[250];
    begin
        // [SETUP] Initialize journal template and warehouse setup
        Initialize();

        // [SETUP] Create item, location, and inventory
        LibraryInventory.CreateItem(Item);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Location."Require Shipment" := true;
        Location.Modify(true);
        CreateItemJournalLine(Item."No.", Location.Code, 100);
        LibraryInventory.PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);

        // [SETUP] Create customer
        LibrarySales.CreateCustomer(Customer);

        // [SETUP] Create and release a sales order
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 10);
        SalesLine.Validate("Location Code", Location.Code);
        SalesLine.Modify(true);
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [SETUP] Create a warehouse shipment from the sales order
        LibraryWarehouse.CreateWarehouseShipmentHeader(WarehouseShipmentHeader);
        // WarehouseEmployee direkt vor Location-Code-Validierung anlegen
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, true);
        WarehouseShipmentHeader.Validate("Location Code", Location.Code);
        WarehouseShipmentHeader.Modify(true);

        LibraryWarehouse.CreateWarehouseSourceFilter(WarehouseSourceFilter, WarehouseSourceFilter.Type::Outbound);
        WarehouseSourceFilter.Validate("Sell-to Customer No. Filter", Customer."No.");
        WarehouseSourceFilter.Modify(true);

        LibraryWarehouse.GetSourceDocumentsShipment(WarehouseShipmentHeader, WarehouseSourceFilter, Location.Code);

        // [SETUP] Set the WA comment on the warehouse shipment header
        TestComment := 'Test-Kommentar WA-' + Format(CurrentDateTime());
        WarehouseShipmentHeader."WA Shipment Comment" := TestComment;
        WarehouseShipmentHeader.Modify(true);

        // [EXERCISE] Post the warehouse shipment (Ship only, no Invoice)
        LibraryWarehouse.PostWhseShipment(WarehouseShipmentHeader, false);

        // [VERIFY] Find the posted sales shipment and check the comment was transferred
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesShipmentHeader.Get(SalesHeader."Last Shipping No.");

        Assert.AreEqual(TestComment, SalesShipmentHeader."WA Shipment Comment",
            'Der Kommentar sollte vom Warenausgangskopf in den Lieferschein übertragen werden.');
    end;

    // ------------------------------------------------------------------------
    // Setup-Hilfsfunktionen
    // ------------------------------------------------------------------------

    /// <summary>
    /// Initialisiert den Item-Journal-Template/Batch und das Warehouse-Setup.
    /// </summary>
    local procedure Initialize()
    var
        WarehouseSetup: Record "Warehouse Setup";
        GlobalNoSeriesCode: Code[20];
    begin
        // Item journal template
        Clear(ItemJournalTemplate);
        ItemJournalTemplate.Init();
        LibraryInventory.SelectItemJournalTemplateName(
            ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        GlobalNoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
        ItemJournalTemplate.Validate("No. Series", GlobalNoSeriesCode);
        ItemJournalTemplate.Modify(true);

        // Item journal batch
        Clear(ItemJournalBatch);
        ItemJournalBatch.Init();
        LibraryInventory.SelectItemJournalBatchName(
            ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
        ItemJournalBatch.Validate("No. Series", GlobalNoSeriesCode);
        ItemJournalBatch.Modify(true);

        // Warehouse setup: stop on first posting error
        WarehouseSetup.Get();
        WarehouseSetup."Shipment Posting Policy" :=
            WarehouseSetup."Shipment Posting Policy"::"Stop and show the first posting error";
        WarehouseSetup.Modify(true);
    end;

    /// <summary>
    /// Erstellt eine Item-Journal-Zeile mit einer positiven Bestandskorrektur.
    /// </summary>
    /// <param name="ItemNo">Artikelnummer.</param>
    /// <param name="LocationCode">Lagerortcode.</param>
    /// <param name="Quantity">Menge.</param>
    local procedure CreateItemJournalLine(ItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.ClearItemJournal(ItemJournalTemplate, ItemJournalBatch);
        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::"Positive Adjmt.", ItemNo, Quantity);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Modify(true);
    end;
}
