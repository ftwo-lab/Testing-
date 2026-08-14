codeunit 50639 "PIM Company Sync"
{
    procedure SyncItem(ItemNo: Code[20])
    var
        Assignment: Record "PIM Item Marketplace";
        Marketplace: Record "PIM Marketplace";
        Synced: Integer;
    begin
        Assignment.SetRange("Item No.", ItemNo);
        Assignment.SetRange("Sync Enabled", true);
        if Assignment.FindSet() then
            repeat
                if Marketplace.Get(Assignment."Marketplace Code") then
                    if Marketplace.Enabled then begin
                        SyncItemToMarketplace(ItemNo, Marketplace, Assignment);
                        Synced += 1;
                    end;
            until Assignment.Next() = 0;

        if Synced = 0 then
            Error('No enabled marketplaces are selected for item %1. Add marketplace codes on the item and enable sync.', ItemNo);
    end;

    procedure SyncPIMSetup(MarketplaceCode: Code[20])
    var
        Marketplace: Record "PIM Marketplace";
    begin
        Marketplace.Get(MarketplaceCode);
        if Marketplace."Company Name" = '' then
            Error('Set Business Central Company on marketplace %1.', MarketplaceCode);
        if Marketplace."Company Name" = CompanyName() then
            Error('Marketplace %1 points to the current company. Sync is master → child only.', MarketplaceCode);

        CopySetupToCompany(Marketplace."Company Name");
        Log('', Marketplace.Code, Marketplace."Company Name", 'Success', 'PIM setup copied (attributes, families, categories).');
    end;

    procedure SyncItemToMarketplace(ItemNo: Code[20]; Marketplace: Record "PIM Marketplace"; var Assignment: Record "PIM Item Marketplace")
    begin
        if Marketplace."Company Name" = '' then begin
            SetAssignmentError(Assignment, 'Company name is blank on the marketplace.');
            exit;
        end;
        if Marketplace."Company Name" = CompanyName() then begin
            SetAssignmentError(Assignment, 'Cannot sync into the master company.');
            exit;
        end;

        if not TrySyncItem(ItemNo, Marketplace) then begin
            SetAssignmentError(Assignment, CopyStr(GetLastErrorText(), 1, 250));
            Log(ItemNo, Marketplace.Code, Marketplace."Company Name", 'Error', CopyStr(GetLastErrorText(), 1, 250));
            exit;
        end;

        Assignment."Last Sync at" := CurrentDateTime();
        Assignment."Last Sync Status" := 'Success';
        Assignment."Last Error" := '';
        Assignment.Modify();
        Log(ItemNo, Marketplace.Code, Marketplace."Company Name", 'Success', StrSubstNo('Item %1 synced with the same item no.', ItemNo));
    end;

    [TryFunction]
    local procedure TrySyncItem(ItemNo: Code[20]; Marketplace: Record "PIM Marketplace")
    var
        MasterItem: Record Item;
        TargetItem: Record Item;
    begin
        MasterItem.Get(ItemNo);
        TargetItem.ChangeCompany(Marketplace."Company Name");
        EnsureUnitOfMeasure(MasterItem."Base Unit of Measure", Marketplace."Company Name");

        if TargetItem.Get(ItemNo) then
            UpdateTargetItem(MasterItem, TargetItem, Marketplace)
        else
            InsertTargetItem(MasterItem, TargetItem, Marketplace);

        CopyPimValues(ItemNo, Marketplace."Company Name");
    end;

    local procedure InsertTargetItem(MasterItem: Record Item; var TargetItem: Record Item; Marketplace: Record "PIM Marketplace")
    begin
        TargetItem.Init();
        TargetItem."No." := MasterItem."No.";
        TargetItem.Description := MasterItem.Description;
        TargetItem."Description 2" := MasterItem."Description 2";
        TargetItem.Type := MasterItem.Type;
        TargetItem.Insert(true);
        ApplyTemplateIfNew(TargetItem, Marketplace);
        ApplyMasterPimFields(MasterItem, TargetItem, Marketplace);
        TargetItem.Modify(true);
    end;

    local procedure UpdateTargetItem(MasterItem: Record Item; var TargetItem: Record Item; Marketplace: Record "PIM Marketplace")
    begin
        ApplyMasterPimFields(MasterItem, TargetItem, Marketplace);
        TargetItem.Modify(true);
    end;

    local procedure ApplyMasterPimFields(MasterItem: Record Item; var TargetItem: Record Item; Marketplace: Record "PIM Marketplace")
    begin
        TargetItem.Description := MasterItem.Description;
        TargetItem."Description 2" := MasterItem."Description 2";
        if MasterItem."Base Unit of Measure" <> '' then
            TargetItem."Base Unit of Measure" := MasterItem."Base Unit of Measure";
        TargetItem."PIM Family Code" := MasterItem."PIM Family Code";
        TargetItem."PIM Category Code" := MasterItem."PIM Category Code";
        TargetItem."PIM Published" := MasterItem."PIM Published";
        if Marketplace."Copy Unit Price" then
            TargetItem."Unit Price" := MasterItem."Unit Price";
        if Marketplace."Copy Posting Groups" then begin
            TargetItem."Gen. Prod. Posting Group" := MasterItem."Gen. Prod. Posting Group";
            TargetItem."Inventory Posting Group" := MasterItem."Inventory Posting Group";
            TargetItem."VAT Prod. Posting Group" := MasterItem."VAT Prod. Posting Group";
        end;
    end;

    local procedure ApplyTemplateIfNew(var TargetItem: Record Item; Marketplace: Record "PIM Marketplace")
    var
        TemplateItem: Record Item;
    begin
        if Marketplace."Template Item No." = '' then
            exit;
        TemplateItem.ChangeCompany(Marketplace."Company Name");
        if not TemplateItem.Get(Marketplace."Template Item No.") then
            exit;
        if TargetItem."Gen. Prod. Posting Group" = '' then
            TargetItem."Gen. Prod. Posting Group" := TemplateItem."Gen. Prod. Posting Group";
        if TargetItem."Inventory Posting Group" = '' then
            TargetItem."Inventory Posting Group" := TemplateItem."Inventory Posting Group";
        if TargetItem."VAT Prod. Posting Group" = '' then
            TargetItem."VAT Prod. Posting Group" := TemplateItem."VAT Prod. Posting Group";
        if TargetItem."Costing Method" = TargetItem."Costing Method"::FIFO then
            TargetItem."Costing Method" := TemplateItem."Costing Method";
    end;

    local procedure EnsureUnitOfMeasure(UOMCode: Code[10]; TargetCompany: Text[50])
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UOMCode = '' then
            exit;
        UnitOfMeasure.ChangeCompany(TargetCompany);
        if UnitOfMeasure.Get(UOMCode) then
            exit;
        UnitOfMeasure.Init();
        UnitOfMeasure.Code := UOMCode;
        UnitOfMeasure.Description := UOMCode;
        UnitOfMeasure.Insert();
    end;

    local procedure CopyPimValues(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterValue: Record "PIM Product Value";
        TargetValue: Record "PIM Product Value";
    begin
        TargetValue.ChangeCompany(TargetCompany);
        TargetValue.SetRange("Item No.", ItemNo);
        TargetValue.DeleteAll();

        MasterValue.SetRange("Item No.", ItemNo);
        if MasterValue.FindSet() then
            repeat
                TargetValue.Init();
                TargetValue."Item No." := MasterValue."Item No.";
                TargetValue."Attribute Code" := MasterValue."Attribute Code";
                TargetValue.Value := MasterValue.Value;
                TargetValue.Insert();
            until MasterValue.Next() = 0;
    end;

    local procedure CopySetupToCompany(TargetCompany: Text[50])
    var
        Group: Record "PIM Attribute Group";
        Attr: Record "PIM Attribute";
        Opt: Record "PIM Attribute Option";
        Family: Record "PIM Family";
        FamilyAttr: Record "PIM Family Attribute";
        Category: Record "PIM Category";
        TGroup: Record "PIM Attribute Group";
        TAttr: Record "PIM Attribute";
        TOpt: Record "PIM Attribute Option";
        TFamily: Record "PIM Family";
        TFamilyAttr: Record "PIM Family Attribute";
        TCategory: Record "PIM Category";
    begin
        TGroup.ChangeCompany(TargetCompany);
        TAttr.ChangeCompany(TargetCompany);
        TOpt.ChangeCompany(TargetCompany);
        TFamily.ChangeCompany(TargetCompany);
        TFamilyAttr.ChangeCompany(TargetCompany);
        TCategory.ChangeCompany(TargetCompany);

        if Group.FindSet() then
            repeat
                if not TGroup.Get(Group.Code) then begin
                    TGroup.Init();
                    TGroup.Code := Group.Code;
                    TGroup.Description := Group.Description;
                    TGroup."Sort Order" := Group."Sort Order";
                    TGroup.Insert();
                end;
            until Group.Next() = 0;

        if Attr.FindSet() then
            repeat
                if not TAttr.Get(Attr.Code) then begin
                    TAttr.Init();
                    TAttr.Code := Attr.Code;
                    TAttr.Caption := Attr.Caption;
                    TAttr.Type := Attr.Type;
                    TAttr."Group Code" := Attr."Group Code";
                    TAttr."Shopify Field" := Attr."Shopify Field";
                    TAttr.Insert();
                end;
            until Attr.Next() = 0;

        if Opt.FindSet() then
            repeat
                if not TOpt.Get(Opt."Attribute Code", Opt.Code) then begin
                    TOpt.Init();
                    TOpt."Attribute Code" := Opt."Attribute Code";
                    TOpt.Code := Opt.Code;
                    TOpt.Caption := Opt.Caption;
                    TOpt."Sort Order" := Opt."Sort Order";
                    TOpt.Insert();
                end;
            until Opt.Next() = 0;

        if Family.FindSet() then
            repeat
                if not TFamily.Get(Family.Code) then begin
                    TFamily.Init();
                    TFamily.Code := Family.Code;
                    TFamily.Description := Family.Description;
                    TFamily.Insert();
                end;
            until Family.Next() = 0;

        if FamilyAttr.FindSet() then
            repeat
                if not TFamilyAttr.Get(FamilyAttr."Family Code", FamilyAttr."Attribute Code") then begin
                    TFamilyAttr.Init();
                    TFamilyAttr."Family Code" := FamilyAttr."Family Code";
                    TFamilyAttr."Attribute Code" := FamilyAttr."Attribute Code";
                    TFamilyAttr.Required := FamilyAttr.Required;
                    TFamilyAttr.Insert();
                end;
            until FamilyAttr.Next() = 0;

        if Category.FindSet() then
            repeat
                if not TCategory.Get(Category.Code) then begin
                    TCategory.Init();
                    TCategory.Code := Category.Code;
                    TCategory.Description := Category.Description;
                    TCategory."Parent Code" := Category."Parent Code";
                    TCategory.Insert();
                end;
            until Category.Next() = 0;
    end;

    local procedure SetAssignmentError(var Assignment: Record "PIM Item Marketplace"; ErrorText: Text)
    begin
        Assignment."Last Sync at" := CurrentDateTime();
        Assignment."Last Sync Status" := 'Error';
        Assignment."Last Error" := CopyStr(ErrorText, 1, 250);
        Assignment.Modify();
    end;

    local procedure Log(ItemNo: Code[20]; MarketplaceCode: Code[20]; CompanyNameValue: Text[50]; Status: Text[30]; MessageText: Text[250])
    var
        SyncLog: Record "PIM Sync Log";
    begin
        SyncLog.Init();
        SyncLog."Item No." := ItemNo;
        SyncLog."Marketplace Code" := MarketplaceCode;
        SyncLog."Company Name" := CompanyNameValue;
        SyncLog.Status := Status;
        SyncLog.Message := MessageText;
        SyncLog."Created at" := CurrentDateTime();
        SyncLog.Insert();
    end;
}
