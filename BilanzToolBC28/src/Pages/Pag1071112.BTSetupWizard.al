namespace S_W.BilanzTool;

/// <summary>BilanzTool Setup Wizard — step-by-step setup following BC28 standard pattern.</summary>
page 62038 "BT Setup Wizard"
{
    Caption = 'BilanzTool Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    SourceTable = "BT Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(StepIntro)
            {
                ShowCaption = false;
                Visible = IntroVisible;
                group(WelcomeHeading)
                {
                    Caption = 'Welcome to BilanzTool Setup';
                    InstructionalText = 'This wizard helps you configure BilanzTool for creating financial statements directly in Business Central.';
                }
                group(NextSteps)
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to configure your default account groupings.';
                }
            }
            group(StepGroupings)
            {
                ShowCaption = false;
                Visible = GroupingsVisible;
                group(GroupingHeading)
                {
                    Caption = 'Default Account Groupings';
                    InstructionalText = 'Select the default grouping headers for each financial statement type. These will be preselected when creating new reports.';
                    field("Default Balance Grouping"; Rec."Default Balance Grouping")
                    {
                        ApplicationArea = All;
                        TableRelation = "BT Acc. Grouping Header".Code where (Type = const(Balance));
                    }
                    field("Default PL Grouping"; Rec."Default PL Grouping")
                    {
                        ApplicationArea = All;
                        TableRelation = "BT Acc. Grouping Header".Code where (Type = const(PL));
                    }
                    field("Default Cashflow Grouping"; Rec."Default Cashflow Grouping")
                    {
                        ApplicationArea = All;
                        TableRelation = "BT Acc. Grouping Header".Code where (Type = const(Cashflow));
                    }
                }
            }
            group(StepAccounts)
            {
                ShowCaption = false;
                Visible = AccountsVisible;
                group(AccountsHeading)
                {
                    Caption = 'Account Settings';
                    InstructionalText = 'Configure additional account settings for the financial statements.';
                    field("Retained Earnings Acc."; Rec."Retained Earnings Acc.")
                    {
                        ApplicationArea = All;
                    }
                    field("Default Depr. Book"; Rec."Default Depr. Book")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(StepJournal)
            {
                ShowCaption = false;
                Visible = JournalVisible;
                group(JournalHeading)
                {
                    Caption = 'Journal Settings';
                    InstructionalText = 'Configure the General Journal for automatic postings.';
                    field("Gen. Journal Template"; Rec."Gen. Journal Template")
                    {
                        ApplicationArea = All;
                    }
                    field("Gen. Journal Batch"; Rec."Gen. Journal Batch")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(StepDone)
            {
                ShowCaption = false;
                Visible = DoneVisible;
                group(DoneHeading)
                {
                    Caption = 'That''s it!';
                    InstructionalText = 'Choose Finish to save the setup. You can change all settings later from the BilanzTool Setup page.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    OrigSetup: Record "BT Setup";
                begin
                    OrigSetup.Get();
                    OrigSetup.TransferFields(Rec);
                    OrigSetup.Modify(true);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        Step: Option Intro,Groupings,Accounts,Journal,Done;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        IntroVisible: Boolean;
        GroupingsVisible: Boolean;
        AccountsVisible: Boolean;
        JournalVisible: Boolean;
        DoneVisible: Boolean;

    trigger OnOpenPage()
    var
        OrigSetup: Record "BT Setup";
    begin
        OrigSetup.Get();
        Rec.TransferFields(OrigSetup);
        ResetWizardControls();
        ShowIntroStep();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        ResetWizardControls();

        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        case Step of
            Step::Intro:
                ShowIntroStep();
            Step::Groupings:
                GroupingsVisible := true;
            Step::Accounts:
                AccountsVisible := true;
            Step::Journal:
                JournalVisible := true;
            Step::Done:
                ShowDoneStep();
        end;
        CurrPage.Update(true);
    end;

    local procedure ShowIntroStep()
    begin
        IntroVisible := true;
        BackEnabled := false;
    end;

    local procedure ShowDoneStep()
    begin
        DoneVisible := true;
        NextEnabled := false;
        FinishEnabled := true;
    end;

    local procedure ResetWizardControls()
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;
        IntroVisible := false;
        GroupingsVisible := false;
        AccountsVisible := false;
        JournalVisible := false;
        DoneVisible := false;
    end;
}
