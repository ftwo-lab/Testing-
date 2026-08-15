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
        CopyItemChannels(ItemNo, Marketplace."Company Name");
        CopyItemMasterData(MasterItem, Marketplace."Company Name");
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
        if MasterItem."Base Unit of Measure" <> '' then begin
            EnsureUnitOfMeasure(MasterItem."Base Unit of Measure", Marketplace."Company Name");
            TargetItem."Base Unit of Measure" := MasterItem."Base Unit of Measure";
        end;
        TargetItem."PIM Family Code" := MasterItem."PIM Family Code";
        TargetItem."PIM Category Code" := MasterItem."PIM Category Code";
        TargetItem."PIM Published" := MasterItem."PIM Published";
        TargetItem."Item Category Code" := MasterItem."Item Category Code";
        TargetItem."Search Description" := MasterItem."Search Description";
        TargetItem."Common Item No." := MasterItem."Common Item No.";
        TargetItem.GTIN := MasterItem.GTIN;
        TargetItem."Tariff No." := MasterItem."Tariff No.";
        TargetItem."Country/Region of Origin Code" := MasterItem."Country/Region of Origin Code";
        TargetItem."Net Weight" := MasterItem."Net Weight";
        TargetItem."Gross Weight" := MasterItem."Gross Weight";
        TargetItem."Unit Volume" := MasterItem."Unit Volume";
        EnsureUnitOfMeasure(MasterItem."Sales Unit of Measure", Marketplace."Company Name");
        EnsureUnitOfMeasure(MasterItem."Purch. Unit of Measure", Marketplace."Company Name");
        TargetItem."Sales Unit of Measure" := MasterItem."Sales Unit of Measure";
        TargetItem."Purch. Unit of Measure" := MasterItem."Purch. Unit of Measure";
        TargetItem."Item Disc. Group" := MasterItem."Item Disc. Group";
        TargetItem."Service Item Group" := MasterItem."Service Item Group";
        TargetItem."Automatic Ext. Texts" := MasterItem."Automatic Ext. Texts";
        CopyPicture(MasterItem, TargetItem);
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

    local procedure CopyItemChannels(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterCh: Record "PIM Item Channel";
        TargetCh: Record "PIM Item Channel";
    begin
        TargetCh.ChangeCompany(TargetCompany);
        TargetCh.SetRange("Item No.", ItemNo);
        TargetCh.DeleteAll();

        MasterCh.SetRange("Item No.", ItemNo);
        if MasterCh.FindSet() then
            repeat
                TargetCh.Init();
                TargetCh."Item No." := MasterCh."Item No.";
                TargetCh."Channel Code" := MasterCh."Channel Code";
                TargetCh.Enabled := MasterCh.Enabled;
                TargetCh.Insert();
            until MasterCh.Next() = 0;
    end;

    local procedure CopySetupToCompany(TargetCompany: Text[50])
    var
        Group: Record "PIM Attribute Group";
        Attr: Record "PIM Attribute";
        Opt: Record "PIM Attribute Option";
        Family: Record "PIM Family";
        FamilyAttr: Record "PIM Family Attribute";
        Category: Record "PIM Category";
        Channel: Record "PIM Channel";
        TGroup: Record "PIM Attribute Group";
        TAttr: Record "PIM Attribute";
        TOpt: Record "PIM Attribute Option";
        TFamily: Record "PIM Family";
        TFamilyAttr: Record "PIM Family Attribute";
        TCategory: Record "PIM Category";
        TChannel: Record "PIM Channel";
    begin
        TGroup.ChangeCompany(TargetCompany);
        TAttr.ChangeCompany(TargetCompany);
        TOpt.ChangeCompany(TargetCompany);
        TFamily.ChangeCompany(TargetCompany);
        TFamilyAttr.ChangeCompany(TargetCompany);
        TCategory.ChangeCompany(TargetCompany);
        TChannel.ChangeCompany(TargetCompany);

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

        if Channel.FindSet() then
            repeat
                if not TChannel.Get(Channel.Code) then begin
                    TChannel.Init();
                    TChannel.Code := Channel.Code;
                    TChannel.Description := Channel.Description;
                    TChannel.Enabled := Channel.Enabled;
                    TChannel."Show in Webshop" := Channel."Show in Webshop";
                    TChannel."Language Code" := Channel."Language Code";
                    TChannel."Currency Code" := Channel."Currency Code";
                    TChannel."Category Tree Code" := Channel."Category Tree Code";
                    TChannel."Marketplace Code" := Channel."Marketplace Code";
                    TChannel."Channel Type" := Channel."Channel Type";
                    TChannel."Sort Order" := Channel."Sort Order";
                    TChannel.Insert();
                end;
            until Channel.Next() = 0;

        CopyItemCategories(TargetCompany);
        CopyItemAttributeSetup(TargetCompany);
    end;

    local procedure CopyItemMasterData(MasterItem: Record Item; TargetCompany: Text[50])
    begin
        CopyItemCategory(MasterItem."Item Category Code", TargetCompany);
        CopyVariants(MasterItem."No.", TargetCompany);
        CopyItemUnitsOfMeasure(MasterItem."No.", TargetCompany);
        CopyTranslations(MasterItem."No.", TargetCompany);
        CopyExtendedTexts(MasterItem."No.", TargetCompany);
        CopyItemReferences(MasterItem."No.", TargetCompany);
        CopyDocumentAttachments(MasterItem."No.", TargetCompany);
        CopyStandardItemAttributes(MasterItem."No.", TargetCompany);
    end;

    local procedure CopyPicture(MasterItem: Record Item; var TargetItem: Record Item)
    var
        i: Integer;
        MediaId: Guid;
    begin
        if MasterItem.Picture.Count = 0 then
            exit;
        for i := 1 to MasterItem.Picture.Count do begin
            MediaId := MasterItem.Picture.Item(i);
            if not IsNullGuid(MediaId) then
                TargetItem.Picture.Insert(MediaId);
        end;
    end;

    local procedure CopyItemCategory(CategoryCode: Code[20]; TargetCompany: Text[50])
    var
        MasterCat: Record "Item Category";
        TargetCat: Record "Item Category";
    begin
        if CategoryCode = '' then
            exit;
        if not MasterCat.Get(CategoryCode) then
            exit;
        if MasterCat."Parent Category" <> '' then
            CopyItemCategory(MasterCat."Parent Category", TargetCompany);
        TargetCat.ChangeCompany(TargetCompany);
        if TargetCat.Get(CategoryCode) then
            exit;
        TargetCat.Init();
        TargetCat.Code := MasterCat.Code;
        TargetCat.Description := MasterCat.Description;
        TargetCat."Parent Category" := MasterCat."Parent Category";
        TargetCat.Insert();
    end;

    local procedure CopyItemCategories(TargetCompany: Text[50])
    var
        MasterCat: Record "Item Category";
    begin
        if MasterCat.FindSet() then
            repeat
                CopyItemCategory(MasterCat.Code, TargetCompany);
            until MasterCat.Next() = 0;
    end;

    local procedure CopyVariants(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterVar: Record "Item Variant";
        TargetVar: Record "Item Variant";
    begin
        TargetVar.ChangeCompany(TargetCompany);
        MasterVar.SetRange("Item No.", ItemNo);
        if MasterVar.FindSet() then
            repeat
                if TargetVar.Get(ItemNo, MasterVar.Code) then begin
                    TargetVar.Description := MasterVar.Description;
                    TargetVar."Description 2" := MasterVar."Description 2";
                    TargetVar.Blocked := MasterVar.Blocked;
                    TargetVar.Modify();
                end else begin
                    TargetVar.Init();
                    TargetVar."Item No." := ItemNo;
                    TargetVar.Code := MasterVar.Code;
                    TargetVar.Description := MasterVar.Description;
                    TargetVar."Description 2" := MasterVar."Description 2";
                    TargetVar.Blocked := MasterVar.Blocked;
                    TargetVar.Insert();
                end;
            until MasterVar.Next() = 0;
    end;

    local procedure CopyItemUnitsOfMeasure(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterUOM: Record "Item Unit of Measure";
        TargetUOM: Record "Item Unit of Measure";
    begin
        MasterUOM.SetRange("Item No.", ItemNo);
        if MasterUOM.FindSet() then
            repeat
                EnsureUnitOfMeasure(MasterUOM.Code, TargetCompany);
                TargetUOM.ChangeCompany(TargetCompany);
                if TargetUOM.Get(ItemNo, MasterUOM.Code) then begin
                    TargetUOM."Qty. per Unit of Measure" := MasterUOM."Qty. per Unit of Measure";
                    TargetUOM.Length := MasterUOM.Length;
                    TargetUOM.Width := MasterUOM.Width;
                    TargetUOM.Height := MasterUOM.Height;
                    TargetUOM.Cubage := MasterUOM.Cubage;
                    TargetUOM.Weight := MasterUOM.Weight;
                    TargetUOM.Modify();
                end else begin
                    TargetUOM.Init();
                    TargetUOM."Item No." := ItemNo;
                    TargetUOM.Code := MasterUOM.Code;
                    TargetUOM."Qty. per Unit of Measure" := MasterUOM."Qty. per Unit of Measure";
                    TargetUOM.Length := MasterUOM.Length;
                    TargetUOM.Width := MasterUOM.Width;
                    TargetUOM.Height := MasterUOM.Height;
                    TargetUOM.Cubage := MasterUOM.Cubage;
                    TargetUOM.Weight := MasterUOM.Weight;
                    TargetUOM.Insert();
                end;
            until MasterUOM.Next() = 0;
    end;

    local procedure CopyTranslations(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterTr: Record "Item Translation";
        TargetTr: Record "Item Translation";
    begin
        TargetTr.ChangeCompany(TargetCompany);
        MasterTr.SetRange("Item No.", ItemNo);
        if MasterTr.FindSet() then
            repeat
                if TargetTr.Get(ItemNo, MasterTr."Language Code", MasterTr."Variant Code") then begin
                    TargetTr.Description := MasterTr.Description;
                    TargetTr."Description 2" := MasterTr."Description 2";
                    TargetTr.Modify();
                end else begin
                    TargetTr.Init();
                    TargetTr."Item No." := ItemNo;
                    TargetTr."Language Code" := MasterTr."Language Code";
                    TargetTr."Variant Code" := MasterTr."Variant Code";
                    TargetTr.Description := MasterTr.Description;
                    TargetTr."Description 2" := MasterTr."Description 2";
                    TargetTr.Insert();
                end;
            until MasterTr.Next() = 0;
    end;

    local procedure CopyExtendedTexts(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterHdr: Record "Extended Text Header";
        TargetHdr: Record "Extended Text Header";
        MasterLine: Record "Extended Text Line";
        TargetLine: Record "Extended Text Line";
    begin
        TargetHdr.ChangeCompany(TargetCompany);
        TargetLine.ChangeCompany(TargetCompany);

        MasterHdr.SetRange("Table Name", MasterHdr."Table Name"::Item);
        MasterHdr.SetRange("No.", ItemNo);
        if MasterHdr.FindSet() then
            repeat
                if not TargetHdr.Get(MasterHdr."Table Name", ItemNo, MasterHdr."Language Code", MasterHdr."Text No.") then begin
                    TargetHdr.Init();
                    TargetHdr."Table Name" := MasterHdr."Table Name";
                    TargetHdr."No." := ItemNo;
                    TargetHdr."Language Code" := MasterHdr."Language Code";
                    TargetHdr."Text No." := MasterHdr."Text No.";
                    TargetHdr.Description := MasterHdr.Description;
                    TargetHdr."Sales Invoice" := MasterHdr."Sales Invoice";
                    TargetHdr."Sales Quote" := MasterHdr."Sales Quote";
                    TargetHdr."Sales Order" := MasterHdr."Sales Order";
                    TargetHdr.Insert();
                end else begin
                    TargetHdr.Description := MasterHdr.Description;
                    TargetHdr.Modify();
                end;

                TargetLine.SetRange("Table Name", MasterHdr."Table Name");
                TargetLine.SetRange("No.", ItemNo);
                TargetLine.SetRange("Language Code", MasterHdr."Language Code");
                TargetLine.SetRange("Text No.", MasterHdr."Text No.");
                TargetLine.DeleteAll();

                MasterLine.SetRange("Table Name", MasterHdr."Table Name");
                MasterLine.SetRange("No.", ItemNo);
                MasterLine.SetRange("Language Code", MasterHdr."Language Code");
                MasterLine.SetRange("Text No.", MasterHdr."Text No.");
                if MasterLine.FindSet() then
                    repeat
                        TargetLine.Init();
                        TargetLine."Table Name" := MasterLine."Table Name";
                        TargetLine."No." := ItemNo;
                        TargetLine."Language Code" := MasterLine."Language Code";
                        TargetLine."Text No." := MasterLine."Text No.";
                        TargetLine."Line No." := MasterLine."Line No.";
                        TargetLine.Text := MasterLine.Text;
                        TargetLine.Insert();
                    until MasterLine.Next() = 0;
            until MasterHdr.Next() = 0;
    end;

    local procedure CopyItemReferences(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterRef: Record "Item Reference";
        TargetRef: Record "Item Reference";
    begin
        TargetRef.ChangeCompany(TargetCompany);
        MasterRef.SetRange("Item No.", ItemNo);
        if MasterRef.FindSet() then
            repeat
                if not TargetRef.Get(ItemNo, MasterRef."Variant Code", MasterRef."Unit of Measure", MasterRef."Reference Type", MasterRef."Reference Type No.", MasterRef."Reference No.") then begin
                    TargetRef.Init();
                    TargetRef."Item No." := ItemNo;
                    TargetRef."Variant Code" := MasterRef."Variant Code";
                    TargetRef."Unit of Measure" := MasterRef."Unit of Measure";
                    TargetRef."Reference Type" := MasterRef."Reference Type";
                    TargetRef."Reference Type No." := MasterRef."Reference Type No.";
                    TargetRef."Reference No." := MasterRef."Reference No.";
                    TargetRef.Description := MasterRef.Description;
                    TargetRef.Insert();
                end else begin
                    TargetRef.Description := MasterRef.Description;
                    TargetRef.Modify();
                end;
            until MasterRef.Next() = 0;
    end;

    local procedure CopyDocumentAttachments(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterAtt: Record "Document Attachment";
        TargetAtt: Record "Document Attachment";
    begin
        TargetAtt.ChangeCompany(TargetCompany);
        MasterAtt.SetRange("Table ID", Database::Item);
        MasterAtt.SetRange("No.", ItemNo);
        if not MasterAtt.FindSet() then
            exit;

        repeat
            TargetAtt.Reset();
            TargetAtt.ChangeCompany(TargetCompany);
            TargetAtt.SetRange("Table ID", Database::Item);
            TargetAtt.SetRange("No.", ItemNo);
            TargetAtt.SetRange("File Name", MasterAtt."File Name");
            if TargetAtt.FindFirst() then begin
                TargetAtt."File Extension" := MasterAtt."File Extension";
                TargetAtt."Document Reference ID" := MasterAtt."Document Reference ID";
                CopyUrlFields(MasterAtt, TargetAtt);
                TargetAtt.Modify();
            end else begin
                TargetAtt.Init();
                TargetAtt."Table ID" := Database::Item;
                TargetAtt."No." := ItemNo;
                TargetAtt."File Name" := MasterAtt."File Name";
                TargetAtt."File Extension" := MasterAtt."File Extension";
                TargetAtt."Document Reference ID" := MasterAtt."Document Reference ID";
                CopyUrlFields(MasterAtt, TargetAtt);
                TargetAtt.Insert(true);
            end;
        until MasterAtt.Next() = 0;
    end;

    local procedure CopyUrlFields(FromAtt: Record "Document Attachment"; var ToAtt: Record "Document Attachment")
    var
        FromRef: RecordRef;
        ToRef: RecordRef;
        FromFld: FieldRef;
        ToFld: FieldRef;
        i: Integer;
        Name: Text;
    begin
        FromRef.GetTable(FromAtt);
        ToRef.GetTable(ToAtt);
        for i := 1 to FromRef.FieldCount do begin
            FromFld := FromRef.FieldIndex(i);
            if FromFld.Class = FieldClass::Normal then begin
                Name := UpperCase(FromFld.Name);
                if (StrPos(Name, 'URL') > 0) or (StrPos(Name, 'URI') > 0) or (StrPos(Name, 'SHAREPOINT') > 0) then
                    if ToRef.FieldExist(FromFld.Number) then begin
                        ToFld := ToRef.Field(FromFld.Number);
                        if ToFld.Class = FieldClass::Normal then
                            ToFld.Value := FromFld.Value;
                    end;
            end;
        end;
        ToRef.SetTable(ToAtt);
    end;

    local procedure CopyItemAttributeSetup(TargetCompany: Text[50])
    var
        MasterAttr: Record "Item Attribute";
    begin
        if MasterAttr.FindSet() then
            repeat
                GetOrCreateItemAttributeId(MasterAttr, TargetCompany);
            until MasterAttr.Next() = 0;
    end;

    local procedure GetOrCreateItemAttributeId(MasterAttr: Record "Item Attribute"; TargetCompany: Text[50]): Integer
    var
        TargetAttr: Record "Item Attribute";
    begin
        TargetAttr.ChangeCompany(TargetCompany);
        TargetAttr.SetRange(Name, MasterAttr.Name);
        if TargetAttr.FindFirst() then
            exit(TargetAttr.ID);
        TargetAttr.Init();
        TargetAttr.Name := MasterAttr.Name;
        TargetAttr.Type := MasterAttr.Type;
        TargetAttr."Unit of Measure" := MasterAttr."Unit of Measure";
        TargetAttr.Insert(true);
        exit(TargetAttr.ID);
    end;

    local procedure GetOrCreateItemAttributeValueId(MasterVal: Record "Item Attribute Value"; TargetAttrId: Integer; TargetCompany: Text[50]): Integer
    var
        TargetVal: Record "Item Attribute Value";
    begin
        TargetVal.ChangeCompany(TargetCompany);
        TargetVal.SetRange("Attribute ID", TargetAttrId);
        TargetVal.SetRange(Value, MasterVal.Value);
        if TargetVal.FindFirst() then
            exit(TargetVal.ID);
        TargetVal.Init();
        TargetVal."Attribute ID" := TargetAttrId;
        TargetVal.Value := MasterVal.Value;
        TargetVal.Insert(true);
        exit(TargetVal.ID);
    end;

    local procedure CopyStandardItemAttributes(ItemNo: Code[20]; TargetCompany: Text[50])
    var
        MasterMap: Record "Item Attribute Value Mapping";
        TargetMap: Record "Item Attribute Value Mapping";
        MasterAttr: Record "Item Attribute";
        MasterVal: Record "Item Attribute Value";
        TargetAttrId: Integer;
        TargetValId: Integer;
    begin
        MasterMap.SetRange("Table ID", Database::Item);
        MasterMap.SetRange("No.", ItemNo);
        if not MasterMap.FindSet() then
            exit;
        repeat
            if MasterAttr.Get(MasterMap."Item Attribute ID") then begin
                TargetAttrId := GetOrCreateItemAttributeId(MasterAttr, TargetCompany);
                if MasterVal.Get(MasterMap."Item Attribute ID", MasterMap."Item Attribute Value ID") then
                    TargetValId := GetOrCreateItemAttributeValueId(MasterVal, TargetAttrId, TargetCompany)
                else
                    TargetValId := 0;
                TargetMap.ChangeCompany(TargetCompany);
                if TargetMap.Get(Database::Item, ItemNo, TargetAttrId) then begin
                    TargetMap."Item Attribute Value ID" := TargetValId;
                    TargetMap.Modify();
                end else begin
                    TargetMap.Init();
                    TargetMap."Table ID" := Database::Item;
                    TargetMap."No." := ItemNo;
                    TargetMap."Item Attribute ID" := TargetAttrId;
                    TargetMap."Item Attribute Value ID" := TargetValId;
                    TargetMap.Insert();
                end;
            end;
        until MasterMap.Next() = 0;
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
