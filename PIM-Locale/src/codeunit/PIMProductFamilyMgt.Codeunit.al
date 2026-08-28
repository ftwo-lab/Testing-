codeunit 50120 "PIM Product Family Mgt."
{
    SingleInstance = true;

    var
        SyncingFromItem: Boolean;
        SyncingFromMember: Boolean;
        Recalculating: Boolean;

    procedure OnItemFamilyCodeValidate(var Item: Record Item)
    var
        PIMProductFamily: Record "PIM Product Family";
        PIMProductFamilyMember: Record "PIM Product Family Member";
    begin
        if SyncingFromMember then
            exit;

        if Item."PIM Product Family Code" = '' then begin
            RemoveItemFromCurrentFamily(Item);
            ClearItemFamilyFieldsInternal(Item);
            exit;
        end;

        PIMProductFamily.Get(Item."PIM Product Family Code");
        Item."PIM Family Group Code" := PIMProductFamily."Family Group Code";
        Item."PIM Classification" := PIMProductFamily.Classification;

        PIMProductFamilyMember.SetRange("Item No.", Item."No.");
        PIMProductFamilyMember.SetFilter("Product Family Code", '<>%1', Item."PIM Product Family Code");
        if PIMProductFamilyMember.FindFirst() then
            PIMProductFamilyMember.Delete(true);

        if Item."PIM Family Role".AsInteger() = 0 then
            Item."PIM Family Role" := Item."PIM Family Role"::"Default Item";

        UpsertMemberFromItem(Item);
        RefreshItemLabels(Item);
    end;

    procedure OnItemFamilyRoleValidate(var Item: Record Item)
    begin
        if SyncingFromMember then
            exit;

        if Item."PIM Product Family Code" = '' then
            Error('Assign a Product Family before setting the family role.');

        case Item."PIM Family Role" of
            Item."PIM Family Role"::"Default Item":
                begin
                    Item."PIM Parent Item No." := '';
                    MakeDefaultItem(Item."No.");
                end;
            Item."PIM Family Role"::Variant:
                ;
            else
                Error('Choose Default Item or Variant.');
        end;

        UpsertMemberFromItem(Item);
        RefreshItemLabels(Item);
    end;

    procedure OnItemParentValidate(var Item: Record Item)
    var
        ParentItem: Record Item;
    begin
        if SyncingFromMember then
            exit;

        if Item."PIM Parent Item No." = '' then
            exit;

        if Item."PIM Parent Item No." = Item."No." then
            Error('An item cannot be a variant of itself.');

        ParentItem.Get(Item."PIM Parent Item No.");
        if ParentItem."PIM Product Family Code" = '' then
            Error('Item %1 is not assigned to a product family.', ParentItem."No.");

        if Item."PIM Product Family Code" = '' then
            Item.Validate("PIM Product Family Code", ParentItem."PIM Product Family Code")
        else
            if Item."PIM Product Family Code" <> ParentItem."PIM Product Family Code" then
                Error('The default item must belong to the same product family.');

        if ParentItem."PIM Family Role" <> ParentItem."PIM Family Role"::"Default Item" then
            Error('Item %1 is not a default item. Variants can only hang off a default item.', ParentItem."No.");

        Item."PIM Family Role" := Item."PIM Family Role"::Variant;
        UpsertMemberFromItem(Item);
        RefreshItemLabels(Item);
    end;

    procedure SyncMemberFromItem(var Item: Record Item)
    begin
        if SyncingFromMember then
            exit;
        if Item."PIM Product Family Code" = '' then
            exit;
        UpsertMemberFromItem(Item);
    end;

    procedure PrepareMemberOnInsert(var Member: Record "PIM Product Family Member")
    begin
        NormalizeMember(Member);
        ApplyMemberToItem(Member);
    end;

    procedure PrepareMemberOnModify(var Member: Record "PIM Product Family Member")
    begin
        NormalizeMember(Member);
        ApplyMemberToItem(Member);
    end;

    procedure ClearItemFamilyFields(var Item: Record Item)
    begin
        ClearItemFamilyFieldsInternal(Item);
        if Item.Modify(false) then;
    end;

    procedure MakeDefaultItem(ItemNo: Code[20])
    var
        Item: Record Item;
        Family: Record "PIM Product Family";
    begin
        Item.Get(ItemNo);
        if Item."PIM Product Family Code" = '' then
            Error('Assign a Product Family on the item before making it the default item.');

        Item."PIM Family Role" := Item."PIM Family Role"::"Default Item";
        Item."PIM Parent Item No." := '';
        UpsertMemberFromItem(Item);

        if Family.Get(Item."PIM Product Family Code") then
            if Family."Primary Default Item No." = '' then begin
                Family."Primary Default Item No." := Item."No.";
                Family.Modify();
            end;

        RecalculateFamilyDisplay(Item."PIM Product Family Code");
        RefreshItemLabels(Item);
        if Item.Modify(false) then;
        SyncNativeVariants(Item."No.");
    end;

    procedure AddItemAsVariant(ParentItemNo: Code[20]; VariantItemNo: Code[20]; DimensionValue: Text[50])
    var
        ParentItem: Record Item;
        VariantItem: Record Item;
    begin
        if ParentItemNo = VariantItemNo then
            Error('An item cannot be a variant of itself.');

        ParentItem.Get(ParentItemNo);
        VariantItem.Get(VariantItemNo);

        if ParentItem."PIM Product Family Code" = '' then
            Error('Assign a Product Family on default item %1 first.', ParentItemNo);

        if ParentItem."PIM Family Role" <> ParentItem."PIM Family Role"::"Default Item" then
            MakeDefaultItem(ParentItemNo);

        if VariantItem."PIM Product Family Code" = '' then
            VariantItem."PIM Product Family Code" := ParentItem."PIM Product Family Code"
        else
            if VariantItem."PIM Product Family Code" <> ParentItem."PIM Product Family Code" then
                Error('Variant %1 already belongs to family %2.', VariantItemNo, VariantItem."PIM Product Family Code");

        VariantItem."PIM Family Group Code" := ParentItem."PIM Family Group Code";
        VariantItem."PIM Classification" := ParentItem."PIM Classification";
        VariantItem."PIM Family Role" := VariantItem."PIM Family Role"::Variant;
        VariantItem."PIM Parent Item No." := ParentItemNo;
        if DimensionValue <> '' then
            VariantItem."PIM Variant Dim. Value" := DimensionValue;

        UpsertMemberFromItem(VariantItem);
        RecalculateFamilyDisplay(ParentItem."PIM Product Family Code");
        RefreshItemLabels(VariantItem);
        if VariantItem.Modify(true) then;
    end;

    procedure CopyOperationalAttributesFromParent(VariantItemNo: Code[20])
    var
        VariantItem: Record Item;
        ParentItem: Record Item;
        ParentUOM: Record "Item Unit of Measure";
        VariantUOM: Record "Item Unit of Measure";
    begin
        VariantItem.Get(VariantItemNo);
        if VariantItem."PIM Parent Item No." = '' then
            Error('Item %1 is not a variant. Select a Default Item No. first.', VariantItemNo);

        ParentItem.Get(VariantItem."PIM Parent Item No.");

        if ParentItem."Base Unit of Measure" <> '' then begin
            if not VariantUOM.Get(VariantItem."No.", ParentItem."Base Unit of Measure") then
                if ParentUOM.Get(ParentItem."No.", ParentItem."Base Unit of Measure") then begin
                    VariantUOM.Init();
                    VariantUOM := ParentUOM;
                    VariantUOM."Item No." := VariantItem."No.";
                    if VariantUOM.Insert() then;
                end else begin
                    VariantUOM.Init();
                    VariantUOM."Item No." := VariantItem."No.";
                    VariantUOM.Code := ParentItem."Base Unit of Measure";
                    VariantUOM."Qty. per Unit of Measure" := 1;
                    if VariantUOM.Insert() then;
                end;
            VariantItem.Validate("Base Unit of Measure", ParentItem."Base Unit of Measure");
        end;

        if ParentItem."VAT Prod. Posting Group" <> '' then
            VariantItem.Validate("VAT Prod. Posting Group", ParentItem."VAT Prod. Posting Group");

        if ParentItem."Gen. Prod. Posting Group" <> '' then
            VariantItem.Validate("Gen. Prod. Posting Group", ParentItem."Gen. Prod. Posting Group");

        VariantItem.Modify(true);
    end;

    procedure RecalculateFamilyDisplay(FamilyCode: Code[20])
    var
        ParentMember: Record "PIM Product Family Member";
        VariantMember: Record "PIM Product Family Member";
        OrderNo: Integer;
        VariantNo: Integer;
    begin
        if Recalculating then
            exit;
        if FamilyCode = '' then
            exit;

        Recalculating := true;
        OrderNo := 0;
        ParentMember.SetCurrentKey("Product Family Code", "Display Order");
        ParentMember.SetRange("Product Family Code", FamilyCode);
        ParentMember.SetRange(Role, ParentMember.Role::"Default Item");
        ParentMember.SetRange("Variant Code", '');
        if ParentMember.FindSet(true) then
            repeat
                OrderNo += 10;
                ParentMember."Display Order" := OrderNo;
                ParentMember.Indentation := 0;
                ParentMember."Variant Label" := 'Parent';
                ParentMember."Parent Item No." := '';
                ParentMember.Modify(false);
                ApplyMemberToItem(ParentMember);

                VariantNo := 0;
                VariantMember.Reset();
                VariantMember.SetCurrentKey("Product Family Code", "Parent Item No.", "Display Order");
                VariantMember.SetRange("Product Family Code", FamilyCode);
                VariantMember.SetRange("Parent Item No.", ParentMember."Item No.");
                VariantMember.SetRange(Role, VariantMember.Role::Variant);
                if VariantMember.FindSet(true) then
                    repeat
                        VariantNo += 1;
                        OrderNo += 10;
                        VariantMember."Display Order" := OrderNo;
                        VariantMember.Indentation := 1;
                        VariantMember."Variant Label" := CopyStr(StrSubstNo('V%1', VariantNo), 1, MaxStrLen(VariantMember."Variant Label"));
                        VariantMember.Modify(false);
                        if VariantMember."Variant Code" = '' then
                            ApplyMemberToItem(VariantMember);
                    until VariantMember.Next() = 0;
            until ParentMember.Next() = 0;

        VariantMember.Reset();
        VariantMember.SetRange("Product Family Code", FamilyCode);
        VariantMember.SetRange(Role, VariantMember.Role::Variant);
        VariantMember.SetRange("Parent Item No.", '');
        if VariantMember.FindSet(true) then
            repeat
                OrderNo += 10;
                VariantMember."Display Order" := OrderNo;
                VariantMember.Indentation := 1;
                if VariantMember."Variant Label" = '' then
                    VariantMember."Variant Label" := 'V?';
                VariantMember.Modify(false);
            until VariantMember.Next() = 0;

        Recalculating := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"PIM Product Family Member", 'OnAfterInsertEvent', '', false, false)]
    local procedure RecalcAfterMemberInsert(var Rec: Record "PIM Product Family Member"; RunTrigger: Boolean)
    begin
        RecalculateFamilyDisplay(Rec."Product Family Code");
    end;

    procedure EnsureExampleFamilies()
    begin
        EnsureFamilyGroup('SOAP', 'Cleaning Soap', 'Cleaning soap line used as the product-family example.');
        EnsureFamily('SOAP', 'SOAP', 'Cleaning Soap', 'Cleaning Soap', 'Color', 'Color variants of the same size share one default item. Different volumes stay separate default items.');

        EnsureFamilyGroup('COKE', 'Coca Cola - Main Product Family', 'Beverage brand. Packaging types are separate product families.');
        EnsureFamily('COKE-GLS', 'COKE', 'Glass Bottle - Product Family', 'Glass Bottle', 'Gebinde Volumen', 'Main product 0.5 L with volume and special-edition variants.');
        EnsureFamily('COKE-PET', 'COKE', 'PET - Product Family', 'PET-Bottle', 'Gebinde Volumen', 'Main product 0.5 L with 1 L and 2 L variants.');
        EnsureFamily('COKE-CAN', 'COKE', 'Can - Product Family', 'Can', 'Gebinde Volumen', 'Main product 0.33 L with 0.5 L and 0.1 L variants.');
    end;

    procedure CreateExampleItems(): Integer
    var
        Created: Integer;
        GenProd: Code[20];
        InvPost: Code[20];
        VatProd: Code[20];
        BaseUOM: Code[10];
        BottleUOM: Code[10];
        CanisterUOM: Code[10];
    begin
        EnsureExampleFamilies();
        if not GetPostingDefaults(GenProd, InvPost, VatProd, BaseUOM) then
            Error('Create at least one item first so posting groups and a unit of measure can be copied, then run this action again.');

        BottleUOM := ResolveUOM('BOTTLE', BaseUOM);
        CanisterUOM := ResolveUOM('CANISTER', BaseUOM);

        Created += CreateExampleItem('PIM-SOAP-BLU-1L', 'Cleaning Soap, Blue, 1L', 'SOAP', "PIM Family Member Role"::"Default Item", '', 'Blue 1L', BottleUOM, GenProd, InvPost, VatProd, true);
        Created += CreateExampleNativeVariant('PIM-SOAP-BLU-1L', 'PNK', 'Pink, 1L', 'Pink 1L');
        Created += CreateExampleNativeVariant('PIM-SOAP-BLU-1L', 'YEL', 'Yellow, 1L', 'Yellow 1L');
        Created += CreateExampleItem('PIM-SOAP-BLU-2L', 'Cleaning Soap, Blue, 2L', 'SOAP', "PIM Family Member Role"::"Default Item", '', 'Blue 2L', BottleUOM, GenProd, InvPost, VatProd, false);
        Created += CreateExampleItem('PIM-SOAP-PNK-05L', 'Cleaning Soap, Pink, 0.5L', 'SOAP', "PIM Family Member Role"::"Default Item", '', 'Pink 0.5L', BottleUOM, GenProd, InvPost, VatProd, false);
        Created += CreateExampleItem('PIM-SOAP-YEL-5L', 'Cleaning Soap, Yellow, 5L', 'SOAP', "PIM Family Member Role"::"Default Item", '', 'Yellow 5L', CanisterUOM, GenProd, InvPost, VatProd, false);

        Created += CreateExampleItem('PIM-COKE-GLS', 'Coca Cola Glass 0.5 L', 'COKE-GLS', "PIM Family Member Role"::"Default Item", '', '0.5 L', BottleUOM, GenProd, InvPost, VatProd, true);
        Created += CreateExampleNativeVariant('PIM-COKE-GLS', '033', '0.33 L', '0.33 L');
        Created += CreateExampleNativeVariant('PIM-COKE-GLS', '01', '0.1 L', '0.1 L');
        Created += CreateExampleNativeVariant('PIM-COKE-GLS', 'WM05', '0.5 L, WM Edition, Brazil', '0.5 L, WM Edition, Brazil');

        Created += CreateExampleItem('PIM-COKE-PET', 'Coca Cola PET 0.5 L', 'COKE-PET', "PIM Family Member Role"::"Default Item", '', '0.5 L', BottleUOM, GenProd, InvPost, VatProd, true);
        Created += CreateExampleNativeVariant('PIM-COKE-PET', '1L', '1 L', '1 L');
        Created += CreateExampleNativeVariant('PIM-COKE-PET', '2L', '2 L', '2 L');

        Created += CreateExampleItem('PIM-COKE-CAN', 'Coca Cola Can 0.33 L', 'COKE-CAN', "PIM Family Member Role"::"Default Item", '', '0.33 L', BottleUOM, GenProd, InvPost, VatProd, true);
        Created += CreateExampleNativeVariant('PIM-COKE-CAN', '05', '0.5 L', '0.5 L');
        Created += CreateExampleNativeVariant('PIM-COKE-CAN', '01', '0.1 L', '0.1 L');

        RecalculateFamilyDisplay('SOAP');
        RecalculateFamilyDisplay('COKE-GLS');
        RecalculateFamilyDisplay('COKE-PET');
        RecalculateFamilyDisplay('COKE-CAN');
        exit(Created);
    end;

    local procedure UpsertMemberFromItem(var Item: Record Item)
    var
        Member: Record "PIM Product Family Member";
        IsNew: Boolean;
    begin
        if SyncingFromMember then
            exit;
        if Item."No." = '' then
            exit;
        if Item."PIM Product Family Code" = '' then
            exit;

        SyncingFromItem := true;
        IsNew := not Member.Get(Item."PIM Product Family Code", Item."No.", '');
        if IsNew then begin
            Member.Init();
            Member."Product Family Code" := Item."PIM Product Family Code";
            Member."Item No." := Item."No.";
        end;

        Member.Role := Item."PIM Family Role";
        Member."Parent Item No." := Item."PIM Parent Item No.";
        Member."Variant Dim. Value" := Item."PIM Variant Dim. Value";
        NormalizeMember(Member);

        if IsNew then
            Member.Insert(false)
        else
            Member.Modify(false);

        SyncingFromItem := false;
        RecalculateFamilyDisplay(Item."PIM Product Family Code");
    end;

    local procedure ApplyMemberToItem(var Member: Record "PIM Product Family Member")
    var
        Item: Record Item;
        Family: Record "PIM Product Family";
    begin
        if SyncingFromItem then
            exit;
        if Member."Variant Code" <> '' then
            exit;
        if not Item.Get(Member."Item No.") then
            exit;

        SyncingFromMember := true;
        Item."PIM Product Family Code" := Member."Product Family Code";
        if Family.Get(Member."Product Family Code") then begin
            Item."PIM Family Group Code" := Family."Family Group Code";
            Item."PIM Classification" := Family.Classification;
            if Member."Is Primary Default" then
                if Family."Primary Default Item No." <> Item."No." then begin
                    Family."Primary Default Item No." := Item."No.";
                    Family.Modify();
                end;
        end;
        Item."PIM Family Role" := Member.Role;
        Item."PIM Parent Item No." := Member."Parent Item No.";
        Item."PIM Variant Dim. Value" := Member."Variant Dim. Value";
        Item."PIM Variant Label" := Member."Variant Label";
        Item.Modify(false);
        SyncingFromMember := false;
    end;

    local procedure NormalizeMember(var Member: Record "PIM Product Family Member")
    var
        Family: Record "PIM Product Family";
    begin
        if Member."Variant Code" <> '' then begin
            Member.Role := Member.Role::Variant;
            Member."Is Native Variant" := true;
            Member.Indentation := 1;
            if Member."Parent Item No." = '' then
                Member."Parent Item No." := Member."Item No.";
            if Member."Variant Label" = '' then
                Member."Variant Label" := NextVariantLabel(Member."Product Family Code", Member."Parent Item No.", Member."Item No.");
            exit;
        end;

        Member."Is Native Variant" := false;
        if Member.Role = Member.Role::" " then
            Member.Role := Member.Role::"Default Item";

        if Member.Role = Member.Role::"Default Item" then begin
            Member."Parent Item No." := '';
            Member.Indentation := 0;
            if Member."Variant Label" = '' then
                Member."Variant Label" := 'Parent';
        end else begin
            Member.Indentation := 1;
            if Member."Variant Label" = '' then
                Member."Variant Label" := NextVariantLabel(Member."Product Family Code", Member."Parent Item No.", Member."Item No.");
        end;

        if Family.Get(Member."Product Family Code") then
            if (Family."Primary Default Item No." = '') and (Member.Role = Member.Role::"Default Item") then begin
                Member."Is Primary Default" := true;
                Family."Primary Default Item No." := Member."Item No.";
                Family.Modify();
            end else
                Member."Is Primary Default" := Family."Primary Default Item No." = Member."Item No.";
    end;

    local procedure NextVariantLabel(FamilyCode: Code[20]; ParentItemNo: Code[20]; CurrentItemNo: Code[20]): Text[10]
    var
        Member: Record "PIM Product Family Member";
        VariantNo: Integer;
    begin
        Member.SetRange("Product Family Code", FamilyCode);
        Member.SetRange("Parent Item No.", ParentItemNo);
        Member.SetRange(Role, Member.Role::Variant);
        VariantNo := Member.Count + 1;
        exit(CopyStr(StrSubstNo('V%1', VariantNo), 1, 10));
    end;

    local procedure RefreshItemLabels(var Item: Record Item)
    var
        Member: Record "PIM Product Family Member";
        Family: Record "PIM Product Family";
    begin
        if Member.Get(Item."PIM Product Family Code", Item."No.", '') then
            Item."PIM Variant Label" := Member."Variant Label";
        if Family.Get(Item."PIM Product Family Code") then begin
            Item."PIM Family Group Code" := Family."Family Group Code";
            Item."PIM Classification" := Family.Classification;
        end;
    end;

    local procedure RemoveItemFromCurrentFamily(var Item: Record Item)
    var
        Member: Record "PIM Product Family Member";
        FamilyCode: Code[20];
    begin
        Member.SetRange("Item No.", Item."No.");
        if not Member.IsEmpty() then begin
            FamilyCode := '';
            if Member.FindFirst() then
                FamilyCode := Member."Product Family Code";
            Member.DeleteAll(false);
            RecalculateFamilyDisplay(FamilyCode);
        end;
    end;

    local procedure ClearItemFamilyFieldsInternal(var Item: Record Item)
    begin
        Item."PIM Product Family Code" := '';
        Item."PIM Family Group Code" := '';
        Item."PIM Family Role" := Item."PIM Family Role"::" ";
        Item."PIM Parent Item No." := '';
        Item."PIM Variant Dim. Value" := '';
        Item."PIM Classification" := '';
        Item."PIM Variant Label" := '';
    end;

    local procedure EnsureFamilyGroup(Code: Code[20]; Name: Text[100]; Description: Text[250])
    var
        Group: Record "PIM Product Family Group";
    begin
        if Group.Get(Code) then
            exit;
        Group.Init();
        Group.Code := Code;
        Group.Name := Name;
        Group.Description := Description;
        Group.Insert();
    end;

    local procedure EnsureFamily(Code: Code[20]; GroupCode: Code[20]; Name: Text[100]; Classification: Text[50]; VariantDimension: Text[50]; Description: Text[250])
    var
        Family: Record "PIM Product Family";
    begin
        if Family.Get(Code) then
            exit;
        Family.Init();
        Family.Code := Code;
        Family."Family Group Code" := GroupCode;
        Family.Name := Name;
        Family.Classification := Classification;
        Family."Variant Dimension" := VariantDimension;
        Family.Description := Description;
        Family.Insert();
    end;

    local procedure CreateExampleItem(ItemNo: Code[20]; Description: Text[100]; FamilyCode: Code[20]; Role: Enum "PIM Family Member Role"; ParentItemNo: Code[20]; DimValue: Text[50]; UOM: Code[10]; GenProd: Code[20]; InvPost: Code[20]; VatProd: Code[20]; IsPrimary: Boolean): Integer
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        Family: Record "PIM Product Family";
    begin
        if Item.Get(ItemNo) then begin
            Item."PIM Product Family Code" := FamilyCode;
            Item."PIM Family Role" := Role;
            Item."PIM Parent Item No." := ParentItemNo;
            Item."PIM Variant Dim. Value" := DimValue;
            UpsertMemberFromItem(Item);
            if IsPrimary and Family.Get(FamilyCode) then begin
                Family."Primary Default Item No." := ItemNo;
                Family.Modify();
            end;
            if Item.Modify(false) then;
            exit(0);
        end;

        Item.Init();
        Item."No." := ItemNo;
        Item.Description := Description;
        Item."Gen. Prod. Posting Group" := GenProd;
        Item."Inventory Posting Group" := InvPost;
        Item."VAT Prod. Posting Group" := VatProd;
        Item.Insert(true);

        if UOM <> '' then begin
            if not ItemUOM.Get(ItemNo, UOM) then begin
                ItemUOM.Init();
                ItemUOM."Item No." := ItemNo;
                ItemUOM.Code := UOM;
                ItemUOM."Qty. per Unit of Measure" := 1;
                ItemUOM.Insert();
            end;
            Item.Validate("Base Unit of Measure", UOM);
        end;

        Item."PIM Product Family Code" := FamilyCode;
        Item."PIM Family Role" := Role;
        Item."PIM Parent Item No." := ParentItemNo;
        Item."PIM Variant Dim. Value" := DimValue;
        if Family.Get(FamilyCode) then begin
            Item."PIM Family Group Code" := Family."Family Group Code";
            Item."PIM Classification" := Family.Classification;
            if IsPrimary then begin
                Family."Primary Default Item No." := ItemNo;
                Family.Modify();
            end;
        end;
        Item.Modify(true);
        UpsertMemberFromItem(Item);
        exit(1);
    end;

    local procedure GetPostingDefaults(var GenProd: Code[20]; var InvPost: Code[20]; var VatProd: Code[20]; var BaseUOM: Code[10]): Boolean
    var
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        InventoryPostingGroup: Record "Inventory Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        Item.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        Item.SetFilter("Inventory Posting Group", '<>%1', '');
        Item.SetFilter("Base Unit of Measure", '<>%1', '');
        if Item.FindFirst() then begin
            GenProd := Item."Gen. Prod. Posting Group";
            InvPost := Item."Inventory Posting Group";
            VatProd := Item."VAT Prod. Posting Group";
            BaseUOM := Item."Base Unit of Measure";
            exit(true);
        end;

        if not GenProductPostingGroup.FindFirst() then
            exit(false);
        if not InventoryPostingGroup.FindFirst() then
            exit(false);
        if not UnitOfMeasure.FindFirst() then
            exit(false);

        GenProd := GenProductPostingGroup.Code;
        InvPost := InventoryPostingGroup.Code;
        BaseUOM := UnitOfMeasure.Code;
        if VATProductPostingGroup.FindFirst() then
            VatProd := VATProductPostingGroup.Code;
        exit(true);
    end;

    local procedure ResolveUOM(Preferred: Code[10]; Fallback: Code[10]): Code[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.Get(Preferred) then
            exit(Preferred);
        exit(Fallback);
    end;

    procedure SyncNativeVariants(ItemNo: Code[20]): Integer
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Member: Record "PIM Product Family Member";
        Synced: Integer;
    begin
        if not Item.Get(ItemNo) then
            exit(0);
        if Item."PIM Product Family Code" = '' then
            exit(0);
        if Item."PIM Family Role" <> Item."PIM Family Role"::"Default Item" then
            exit(0);

        ItemVariant.SetRange("Item No.", ItemNo);
        if ItemVariant.FindSet() then
            repeat
                UpsertNativeVariantMember(Item."PIM Product Family Code", ItemNo, ItemVariant.Code, CopyStr(ItemVariant.Description, 1, 50));
                Synced += 1;
            until ItemVariant.Next() = 0;

        Member.SetRange("Product Family Code", Item."PIM Product Family Code");
        Member.SetRange("Item No.", ItemNo);
        Member.SetRange("Is Native Variant", true);
        if Member.FindSet() then
            repeat
                if Member."Variant Code" <> '' then
                    if not ItemVariant.Get(ItemNo, Member."Variant Code") then
                        Member.Delete(false);
            until Member.Next() = 0;

        RecalculateFamilyDisplay(Item."PIM Product Family Code");
        exit(Synced);
    end;

    procedure FillVisualBoard(FamilyGroupCode: Code[20]; var VisualLine: Record "PIM Family Visual Line")
    var
        Group: Record "PIM Product Family Group";
        Family: Record "PIM Product Family";
        Member: Record "PIM Product Family Member";
        SharedContent: Record "PIM Family Shared Content";
        EntryNo: Integer;
        SharedCount: Integer;
        DisplayName: Text[150];
    begin
        VisualLine.Reset();
        VisualLine.DeleteAll();
        if not Group.Get(FamilyGroupCode) then
            exit;

        SharedContent.SetRange(Scope, SharedContent.Scope::"Main Product Family");
        SharedContent.SetRange("Family Group Code", FamilyGroupCode);
        SharedCount := SharedContent.Count;
        EntryNo := AddVisualLine(VisualLine, EntryNo, "PIM Visual Node Type"::"Main Family", 0, 'Main Family', Group.Name, '', '', '', '', '', '', FamilyGroupCode, '', SharedCount, true);

        Family.SetRange("Family Group Code", FamilyGroupCode);
        if Family.FindSet() then
            repeat
                SharedContent.Reset();
                SharedContent.SetRange(Scope, SharedContent.Scope::"Product Family");
                SharedContent.SetRange("Product Family Code", Family.Code);
                SharedCount := SharedContent.Count;
                EntryNo := AddVisualLine(VisualLine, EntryNo, "PIM Visual Node Type"::"Product Family", 1, 'Family', Family.Name, Family.Classification, '', '', '', '', Family."Variant Dimension", FamilyGroupCode, Family.Code, SharedCount, true);

                Member.Reset();
                Member.SetCurrentKey("Product Family Code", "Display Order");
                Member.SetRange("Product Family Code", Family.Code);
                if Member.FindSet() then
                    repeat
                        Member.CalcFields(Description, "Variant Description", "Base Unit of Measure", "VAT Prod. Posting Group");
                        if Member."Variant Code" <> '' then
                            DisplayName := Member."Variant Description"
                        else
                            DisplayName := Member.Description;
                        if DisplayName = '' then
                            DisplayName := Member."Item No.";
                        if Member.Role = Member.Role::"Default Item" then
                            EntryNo := AddVisualLine(VisualLine, EntryNo, "PIM Visual Node Type"::"Default Item", 2, Member."Variant Label", DisplayName, Family.Classification, Member."Item No.", '', Member."Base Unit of Measure", Member."VAT Prod. Posting Group", Member."Variant Dim. Value", FamilyGroupCode, Family.Code, SharedCount, true)
                        else
                            EntryNo := AddVisualLine(VisualLine, EntryNo, "PIM Visual Node Type"::Variant, 3, Member."Variant Label", DisplayName, Family.Classification, Member."Item No.", Member."Variant Code", Member."Base Unit of Measure", Member."VAT Prod. Posting Group", Member."Variant Dim. Value", FamilyGroupCode, Family.Code, 0, false);
                    until Member.Next() = 0;
            until Family.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncFamilyAfterVariantInsert(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    begin
        SyncNativeVariants(Rec."Item No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SyncFamilyAfterVariantDelete(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    begin
        SyncNativeVariants(Rec."Item No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterModifyEvent', '', false, false)]
    local procedure SyncFamilyAfterVariantModify(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    begin
        SyncNativeVariants(Rec."Item No.");
    end;

    local procedure UpsertNativeVariantMember(FamilyCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; DimValue: Text[50])
    var
        Member: Record "PIM Product Family Member";
        IsNew: Boolean;
    begin
        if VariantCode = '' then
            exit;
        IsNew := not Member.Get(FamilyCode, ItemNo, VariantCode);
        if IsNew then begin
            Member.Init();
            Member."Product Family Code" := FamilyCode;
            Member."Item No." := ItemNo;
            Member."Variant Code" := VariantCode;
        end;
        Member.Role := Member.Role::Variant;
        Member."Is Native Variant" := true;
        Member."Parent Item No." := ItemNo;
        Member."Variant Dim. Value" := DimValue;
        NormalizeMember(Member);
        if IsNew then
            Member.Insert(false)
        else
            Member.Modify(false);
    end;

    local procedure CreateExampleNativeVariant(ItemNo: Code[20]; VariantCode: Code[10]; Description: Text[100]; DimValue: Text[50]): Integer
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if not Item.Get(ItemNo) then
            exit(0);
        if ItemVariant.Get(ItemNo, VariantCode) then begin
            SyncNativeVariants(ItemNo);
            exit(0);
        end;
        ItemVariant.Init();
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := VariantCode;
        ItemVariant.Description := Description;
        ItemVariant.Insert(true);
        UpsertNativeVariantMember(Item."PIM Product Family Code", ItemNo, VariantCode, DimValue);
        exit(1);
    end;

    local procedure AddVisualLine(var VisualLine: Record "PIM Family Visual Line"; EntryNo: Integer; NodeType: Enum "PIM Visual Node Type"; Indent: Integer; Label: Text[30]; Description: Text[150]; Classification: Text[50]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; VAT: Code[20]; DimValue: Text[50]; GroupCode: Code[20]; FamilyCode: Code[20]; SharedCount: Integer; Strong: Boolean): Integer
    begin
        EntryNo += 1;
        VisualLine.Init();
        VisualLine."Entry No." := EntryNo;
        VisualLine."Node Type" := NodeType;
        VisualLine."Variant Label" := Label;
        VisualLine.Description := Description;
        VisualLine.Classification := Classification;
        VisualLine."Item No." := ItemNo;
        VisualLine."Variant Code" := VariantCode;
        VisualLine."Base Unit of Measure" := UOM;
        VisualLine."VAT Prod. Posting Group" := VAT;
        VisualLine."Variant Dim. Value" := DimValue;
        VisualLine.Indentation := Indent;
        VisualLine."Family Group Code" := GroupCode;
        VisualLine."Product Family Code" := FamilyCode;
        VisualLine."Shared Content Count" := SharedCount;
        VisualLine."Style Strong" := Strong;
        VisualLine.Insert();
        exit(EntryNo);
    end;
}
