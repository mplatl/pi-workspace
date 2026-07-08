namespace S_W.BilanzTool;

permissionset 62100 "BT Basic User"
{
    Assignable = true;
    Caption = 'BilanzTool Basic User';

    permissions =
        tabledata "BT Account Grouping" = RIMD,
        tabledata "BT Word Template" = RIMD,
        tabledata "BT Acc. Grouping Header" = RIMD,
        tabledata "BT Log" = RIMD,
        tabledata "BT KPI Header" = RIMD,
        tabledata "BT KPI" = RIMD,
        tabledata "BT Setup" = RIMD,
        tabledata "BT Fixed Asset Grouping" = RIMD,
        tabledata "BT Checklist" = RIMD,
        tabledata "BT List Values" = RIMD;
}

permissionset 62101 "BT Admin"
{
    Assignable = true;
    Caption = 'BilanzTool Administrator';

    IncludedPermissionSets = "BT Basic User";

    permissions =
        tabledata "BT Account Grouping" = RIMD,
        tabledata "BT Word Template" = RIMD,
        tabledata "BT Acc. Grouping Header" = RIMD,
        tabledata "BT Log" = RIMD,
        tabledata "BT KPI Header" = RIMD,
        tabledata "BT KPI" = RIMD,
        tabledata "BT Setup" = RIMD,
        tabledata "BT Fixed Asset Grouping" = RIMD,
        tabledata "BT Checklist" = RIMD,
        tabledata "BT List Values" = RIMD;
}

permissionset 62102 "BT Report User"
{
    Assignable = true;
    Caption = 'BilanzTool Reporting';

    permissions =
        tabledata "BT Account Grouping" = R,
        tabledata "BT Acc. Grouping Header" = R,
        tabledata "BT KPI" = R,
        tabledata "BT Setup" = R;
}
