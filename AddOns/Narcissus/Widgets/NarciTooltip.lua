--Parent: Narci_EquipmentFlyoutFrame (Narcissus.xml)
local hasGapAdjusted = false;
local STAMINA_STRING = SPELL_STAT3_NAME
local GemInfo = Narci_GemInfo;
local EnchantInfo = Narci_EnchantInfo;
local DefaultHeight_Comparison = 160;
local DefaultHeight_StatsComparisonTemplate = 12;
local Format_Digit = "%.2f";

local BreakUpLargeNumbers = NarciAPI_FormatLargeNumbers --BreakUpLargeNumbers;
local Narci_GetPrimaryStatusName = NarciAPI_GetPrimaryStatusName;
local GetItemEnchant = NarciAPI_GetItemEnchant;
local GetItemExtraEffect = NarciAPI_GetItemExtraEffect;
local IsItemSocketable = NarciAPI_IsItemSocketable;

local GemBorderTexture = {
	[1]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[2]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Green",
	[3]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[4]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[5]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Orange",
	[6]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Purple",
    [7]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Yellow",
	[8]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Blue",	
	[9]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",
	[10] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",
	[11] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",
}

local LocalizedSlotName = {                                                                         --{Localized Name, InventorySlotName}
    [1]  = {HEADSLOT, "HeadSlot"},         [11] = {FINGER0SLOT_UNIQUE, "Finger0Slot"},
    [2]  = {NECKSLOT, "NeckSlot"},         [12] = {FINGER1SLOT_UNIQUE, "Finger1Slot"},
    [3]  = {SHOULDERSLOT, "ShoulderSlot"}, [13] = {TRINKET0SLOT_UNIQUE, "Trinket0Slot"},
    [4]  = {SHIRTSLOT, "ShirtSlot"},       [14] = {TRINKET1SLOT_UNIQUE, "Trinket1Slot"},
    [5]  = {CHESTSLOT, "ChestSlot"},       [15] = {BACKSLOT, "BackSlot"},
    [6]  = {WAISTSLOT, "WaistSlot"},       [16] = {MAINHANDSLOT, "MainHandSlot"},
    [7]  = {LEGSSLOT, "LegsSlot"},         [17] = {SECONDARYHANDSLOT, "SecondaryHandSlot"},
    [8]  = {FEETSLOT, "FeetSlot"},         [18] = {RANGEDSLOT, "AmmoSlot"},                             --Old
    [9]  = {WRISTSLOT, "WristSlot"},       [19] = {TABARDSLOT, "TabardSlot"},
    [10] = {HANDSSLOT, "HandsSlot"},
}

local CR_ConvertRatio = {      --Combat Rating number/percent
    stamina = 20,              -- 1 stamina = 20 HP
    }

local function SetCombatRatingRatio()
    local crit = math.max(GetCombatRating(CR_CRIT_MELEE), GetCombatRating(CR_CRIT_RANGED), GetCombatRating(CR_CRIT_SPELL));
    local critBonus = math.max(GetCombatRatingBonus(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_SPELL));
    CR_ConvertRatio.crit = critBonus / crit;

    local _, bonusCoeff = GetMasteryEffect();
    local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;
    
    CR_ConvertRatio.haste = GetCombatRatingBonus(CR_HASTE_MELEE) / GetCombatRating(CR_HASTE_MELEE);
    CR_ConvertRatio.mastery = masteryBonus / GetCombatRating(CR_MASTERY);
    CR_ConvertRatio.versa = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) / GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);

    --[[
    print(STAT_CRITICAL_STRIKE.." "..CR_ConvertRatio.crit)
    print(STAT_HASTE.." "..CR_ConvertRatio.haste)
    print(STAT_MASTERY.." "..CR_ConvertRatio.mastery)
    print(STAT_VERSATILITY.." "..CR_ConvertRatio.versa)
    --]]
end

local ColorTable = {
    Green = {r = 124 ,g = 197 ,b = 118},    --7cc576
    Red = {r = 255 ,g = 80 ,b = 80},
    Positive = {r = 98, g = 239, b = 165}, 
    Positive2 = {r = 135, g = 220, b = 153}, 
}

local function TextColor(Fontstring, color)
    local r, g, b = color.r/255, color.g/255, color.b/255
    Fontstring:SetTextColor(r, g, b);
end


local function NarciTooltip_AdjustGap()
    local frame = NarciTooltip;
    local defaultV1 = 60;
    local defaultV2 = 110;  --116
    local maxStringWidth = 60; --Default Gap is 80 = 60 + 20
    
    local statString = NarciTooltip.StatsList;
    for i=1, #statString do
        local tempWidth = statString[i].Label:GetWidth();
        if maxStringWidth < tempWidth then
            maxStringWidth = tempWidth;
        end
    end
    
    local ajustedV1 = maxStringWidth + 30;
    local ajustedV2 = math.floor(defaultV2 -(ajustedV1 - defaultV1));
    local extraWidth = 0;
    local minimumGap = 60;

    if ajustedV2 < minimumGap then
        extraWidth = math.floor(minimumGap - ajustedV2);
        ajustedV2 = minimumGap;
        frame:SetWidth(frame:GetWidth() + extraWidth)
    end
    
    frame.GuideLineV1:SetPoint("LEFT", ajustedV1, 0)
    frame.GuideLineV2:SetPoint("LEFT", frame.GuideLineV1:GetName(), ajustedV2, 0)
    hasGapAdjusted = true;
end


--[[
local function GetItemEnchant(itemLink)
    local EnchantID = 0;
    local _, a = string.find(itemLink, ":%d+:.-:")
    local _, b = string.find(itemLink, ":%d+:")

    if (b + 1) < (a -1) then
        EnchantID = string.sub(itemLink, b+1, a-1)
    end

    return tonumber(EnchantID)
end
--]]
local function CacheTooltip(itemLink)
    NarciCacheTooltip:SetHyperlink(itemLink)
end

local function ItemStats(itemLocation)
    local statsTable = {};

    if not C_Item.DoesItemExist(itemLocation) then
        statsTable.prim = 0;
        statsTable.stamina = 0;
        statsTable.crit = 0;
        statsTable.haste = 0;
        statsTable.mastery = 0;
        statsTable.versa = 0;
        statsTable.GemIcon = "";
        statsTable.GemPos = "";
        statsTable.EnchantPos = "";
        statsTable.EnchantSpellID = nil;
        statsTable.ilvl = 0;
        return statsTable;
    end

    local ItemLevel = C_Item.GetCurrentItemLevel(itemLocation)
    local itemLink = C_Item.GetItemLink(itemLocation)
    local stats = GetItemStats(itemLink);
    local prim = stats["ITEM_MOD_AGILITY_SHORT"] or stats["ITEM_MOD_STRENGTH_SHORT"] or stats["ITEM_MOD_INTELLECT_SHORT"] or 0;
    local stamina = stats["ITEM_MOD_STAMINA_SHORT"] or 0;
    local crit = stats["ITEM_MOD_CRIT_RATING_SHORT"] or 0;
    local haste = stats["ITEM_MOD_HASTE_RATING_SHORT"] or 0;
    local mastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0;
    local versa = stats["ITEM_MOD_VERSATILITY"] or 0;

    statsTable.prim = prim;
    statsTable.stamina = stamina;
    statsTable.crit = crit;
    statsTable.haste = haste;
    statsTable.mastery = mastery;
    statsTable.versa = versa;
    statsTable.ilvl = ItemLevel;

    --Calculate bonus from Gems and Enchants--

    local GemName, GemLink = GetItemGem(itemLink, 1)
    if GemLink then
        local GemID = GetItemInfoInstant(GemLink)
        --local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink)
        local _, _, _, _, GemIcon, _, itemSubClassID = GetItemInfoInstant(GemLink); 
        statsTable.GemIcon = GemIcon

        if GemInfo[GemID] then
            local GemInfo = GemInfo[GemID]
            if GemInfo[1] == "crit" then
                statsTable.crit = statsTable.crit + GemInfo[2];
                statsTable.GemPos = "NarciTooltipCritNum";
            elseif GemInfo[1] == "haste" then
                statsTable.haste = statsTable.haste + GemInfo[2];
                statsTable.GemPos = "NarciTooltipHasteNum";
            elseif GemInfo[1] == "mastery" then
                statsTable.mastery = statsTable.mastery + GemInfo[2];
                statsTable.GemPos = "NarciTooltipMasteryNum";
            elseif GemInfo[1] == "versa" then
                statsTable.versa = statsTable.versa + GemInfo[2];
                statsTable.GemPos = "NarciTooltipVersaNum";
            elseif GemInfo[1] == "AGI" or GemInfo[1] == "STR" or GemInfo[1] == "INT" then
                statsTable.prim = statsTable.prim + GemInfo[2];
                statsTable.GemPos = "NarciTooltipPrimNum";
            end
        end
    end

    local EnchantID = GetItemEnchant(itemLink)
    if EnchantID ~= 0 and EnchantInfo[EnchantID] then
        local EnchantInfo = EnchantInfo[EnchantID]
        if EnchantInfo[1] == "crit" then
            statsTable.crit = statsTable.crit + EnchantInfo[2];
            statsTable.EnchantPos = "NarciTooltipCritNum";
        elseif EnchantInfo[1] == "haste" then
            statsTable.haste = statsTable.haste + EnchantInfo[2];
            statsTable.EnchantPos = "NarciTooltipHasteNum";
        elseif EnchantInfo[1] == "mastery" then
            statsTable.mastery = statsTable.mastery + EnchantInfo[2];
            statsTable.EnchantPos = "NarciTooltipMasteryNum";
        elseif EnchantInfo[1] == "versa" then
            statsTable.versa = statsTable.versa + EnchantInfo[2];
            statsTable.EnchantPos = "NarciTooltipVersaNum";
        elseif EnchantInfo[1] == "AGI" or EnchantInfo[1] == "STR" or EnchantInfo[1] == "INT" then
            statsTable.prim = statsTable.prim + EnchantInfo[2];
            statsTable.EnchantPos = "NarciTooltipPrimNum";
        end

        statsTable.EnchantSpellID = EnchantInfo[3];
    end

    return statsTable;
end

local function DisplayComparison(Textframe, name, number, baseNumber, ratio, CustomColor)
    if not number then            --Set Number to "-"
        Textframe.Arrow:Hide();
        Textframe.NumDiff:Hide();
        Textframe.PctDiff:Hide();
        Textframe.Num:SetText("-");
        return;
    end

    local differentialNumber = tonumber(number) - tonumber(baseNumber)

    if differentialNumber > 0 then
        Textframe.Arrow:Show()
        Textframe.Arrow:SetTexCoord(0, 0.5, 0, 1)

        Textframe.NumDiff:Show();
        Textframe.PctDiff:Show();
        TextColor(Textframe.NumDiff, ColorTable.Green)
        TextColor(Textframe.PctDiff, ColorTable.Green)
    elseif differentialNumber < 0 then
        Textframe.Arrow:Show()
        Textframe.Arrow:SetTexCoord(0.5, 1, 0, 1)

        Textframe.NumDiff:Show();
        Textframe.PctDiff:Show();
        TextColor(Textframe.NumDiff, ColorTable.Red)
        TextColor(Textframe.PctDiff, ColorTable.Red)
    else
        Textframe.Arrow:Hide()
        Textframe.NumDiff:Hide();
        Textframe.PctDiff:Hide();
    end

    differentialNumber = math.abs(differentialNumber)

    Textframe.Label:SetText(name)
    if number ~= 0 then
        Textframe.Num:SetText(number);
        --Textframe:SetHeight(DefaultHeight_StatsComparisonTemplate);
        Textframe:Show();
    else
        Textframe.Num:SetText("-");
        --Textframe:SetHeight(0);
        --Textframe:Hide();
    end
    Textframe.NumDiff:SetText(differentialNumber);

    if CustomColor then
        Textframe.Label:SetTextColor(CustomColor[1], CustomColor[2], CustomColor[3])
    else
        Textframe.Label:SetTextColor(1, 0.96, 0.41)
    end

    if ratio then
        if name ~= STAMINA_STRING then
            Textframe.PctDiff:SetText(string.format(Format_Digit, ratio*differentialNumber).."%");
        else
            Textframe.PctDiff:SetText(BreakUpLargeNumbers(ratio*differentialNumber));
        end
    else
        Textframe.PctDiff:SetText("");
    end
end

local function EmptyComparison()
    DisplayComparison(NarciTooltipIlvl,STAT_AVERAGE_ITEM_LEVEL);
    DisplayComparison(NarciTooltipPrim, SPEC_FRAME_PRIMARY_STAT);
    DisplayComparison(NarciTooltipStamina, STAMINA_STRING);
    DisplayComparison(NarciTooltipCrit, STAT_CRITICAL_STRIKE);
    DisplayComparison(NarciTooltipHaste, STAT_HASTE);
    DisplayComparison(NarciTooltipMastery, STAT_MASTERY);
    DisplayComparison(NarciTooltipVersa, STAT_VERSATILITY);
end

local function UntruncateText(frame, fontstring)
    local n = 1;
    while fontstring:IsTruncated() do
        frame:SetWidth(frame.WidthBAK + 20*n);
        n = n + 1;
    end
end

local HeartLevel = 0;
local CurrentSpecID = 0;
--local IsAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem
local GetAllTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo;
local GetPowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo;
local IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected;
local GetPowerText = C_AzeriteEmpoweredItem.GetPowerText;   --azeriteEmpoweredItemLocation, powerID, level
local IsPowerAvailableForSpec = C_AzeriteEmpoweredItem.IsPowerAvailableForSpec;
--local DoesItemExist = C_Item.DoesItemExist;
local MaximumTier = 5;
local TierInfos, azeritePowerDescription;
--local itemLocation = Narci_EquipmentFlyoutFrame.BaseItem
local function GetActiveTraits(itemLocation, self)
    if not itemLocation then return; end
    local shouldCache = false;
    local PowerIDs, azeritePowerName, icon, unlockLevel, azeritePowerDescription;
    local ActiveTraits = {}  --[tier] = {PowerID, icon, name, description, unlockLevel}
    if (not C_Item.DoesItemExist(itemLocation)) or (not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)) then return; end
    TierInfos = GetAllTierInfo(itemLocation)
    if not TierInfos then return; end

    for i = 1, MaximumTier do
        if (not TierInfos[i]) or (not TierInfos[i].azeritePowerIDs) then
            if shouldCache then
                if self then
                    self:Disable();
                    C_Timer.After(0.2, function()
                        self:Enable();
                    end)
                end
            end            
            return ActiveTraits;
        end
        ActiveTraits[i] = {}
        PowerIDs = TierInfos[i].azeritePowerIDs;
        unlockLevel = TierInfos[i].unlockLevel or 0;
        for k, PowerID in pairs(PowerIDs) do
            azeritePowerName, _, icon = GetSpellInfo(GetPowerInfo(PowerID) and GetPowerInfo(PowerID).spellID);
            azeritePowerDescription = GetPowerText(itemLocation, PowerID, 0);
            
            if not azeritePowerDescription.description or azeritePowerDescription.description == "" then
                shouldCache = true;
                --print("shoud cache".." "..azeritePowerName)
            end
            if IsPowerSelected(itemLocation, PowerID) then
                ActiveTraits[i] = {PowerID, icon, azeritePowerName, azeritePowerDescription.description};
                break;
            else
                ActiveTraits[i] = {PowerID, nil, "", ""};
            end
        end
        tinsert(ActiveTraits[i], unlockLevel);
    end
    if shouldCache then
        if self then
            self:Disable();
            C_Timer.After(0.2, function()
                self:Enable();
            end)
        end
    end
    return ActiveTraits;
end

local TraitsCache = {};

local function DesatureBorder(texture, bool)
    if bool then
        texture:SetTexCoord(0.5, 0.75, 0, 1);
    else
        texture:SetTexCoord(0, 0.25, 0, 1);
    end
end

local function BuildAzeiteTraitsFrame(TraitsFrame, itemLocation, self)
    TraitsCache = GetActiveTraits(itemLocation, self);
    --print("CacheCheck Azerite: "..tostring(C_Item.IsItemDataCached(itemLocation)))
    if not TraitsCache then return; end
    local rightSpec = false;
    for i = 1, MaximumTier do
        local button = TraitsFrame.Traits[i];
        button.Icon:Hide();
        if (TraitsCache[i]) and (TraitsCache[i][5]) then
            if TraitsCache[i][5] > HeartLevel then
                button.Level:SetText(TraitsCache[i][5]);
                button.Level:Show();
                button.Border0:SetTexCoord(0.5, 0.75, 0, 1);        --Desaturated
                button.Border1:SetDesaturated(true);
            else
                button.Level:Hide();
                button.Icon:SetTexture(TraitsCache[i][2]);
                button.Icon:Show();
                rightSpec = IsPowerAvailableForSpec(TraitsCache[i][1], CurrentSpecID);
                if rightSpec then
                    button.Border0:SetTexCoord(0, 0.25, 0, 1);      --Saturated
                    button.Border1:SetDesaturated(false);
                    button.Icon:SetDesaturated(false);
                else
                    if TraitsCache[i][2] then                           --Hasn't pick traits
                        button.Border0:SetTexCoord(0.5, 0.75, 0, 1);    --Desaturated
                        button.Border1:SetDesaturated(true);
                        button.Icon:SetDesaturated(true);
                    else
                        button.Border0:SetTexCoord(0, 0.25, 0, 1);      --Saturated
                        button.Border1:SetDesaturated(false);
                        button.Icon:SetDesaturated(false);
                    end
                end
            end
            button:Show();

            if i == 1 then
                TraitsFrame.Name1:SetText(TraitsCache[i][3]);
                TraitsFrame.Description1:SetText(TraitsCache[i][4]);
                if rightSpec then
                    TraitsFrame.Description1:SetTextColor(0.9, 0.8, 0.5);
                else
                    TraitsFrame.Description1:SetTextColor(0.5, 0.5, 0.5);
                end
            elseif i == 2 then
                TraitsFrame.Name2:SetText(TraitsCache[i][3]);
                TraitsFrame.Description2:SetText(TraitsCache[i][4]);
                if rightSpec then
                    TraitsFrame.Description2:SetTextColor(0.9, 0.8, 0.5);
                else
                    TraitsFrame.Description2:SetTextColor(0.5, 0.5, 0.5);
                end           
            end
        else
            button.Border0:SetTexCoord(0.5, 0.75, 0, 1);            --Desaturated
            button.Border1:SetDesaturated(true);
            button:Hide();
        end
    end

    --Base Item--
    if not Narci_EquipmentFlyoutFrame.BaseItem then return; end 
    TraitsCache = GetActiveTraits(Narci_EquipmentFlyoutFrame.BaseItem);
    if not TraitsCache or Narci_EquipmentFlyoutFrame.BaseItem == itemLocation then 
        for i = 1, MaximumTier do
            TraitsFrame.Traits[i].BaseTrait:Hide();
        end
        return;
    end
    for i = 1, MaximumTier do
        local button = TraitsFrame.Traits[i];
        local tinybutton = button.BaseTrait;
        if (TraitsCache[i]) and (TraitsCache[i][5]) then
            if TraitsCache[i][2] then
                tinybutton.Icon:SetTexture(TraitsCache[i][2]);
                tinybutton:Show();
                button:Show();
            else
                tinybutton:Hide();
            end
        else
            tinybutton:Hide();
        end
    end

    wipe(TraitsCache);
    --[[
    for i = 1, MaximumTier do
        TraitsFrame.Traits[i].Icon:Hide();
        if (not TierInfos[i]) or (not TierInfos[i].azeritePowerIDs) then
            TraitsFrame.Traits[i]:Hide();
            for j = i + 1, MaximumTier do
                TraitsFrame.Traits[j]:Hide();
            end
            return;
        end
        TraitsFrame.Traits[i]:Show();
        PowerIDs = TierInfos[i].azeritePowerIDs;
        unlockLevel = TierInfos[i].unlockLevel;
        button = TraitsFrame.Traits[i];

        if unlockLevel > HeartLevel then
            button.Level:SetText(unlockLevel);
            button.Level:Show();
            button.Border0:SetTexCoord(0.5, 0.75, 0, 1);
            --button.Border1:SetTexCoord(0.5, 0.75, 0, 1);
        else
            button.Level:Hide();
            button.Border0:SetTexCoord(0, 0.25, 0, 1);
            --button.Border1:SetTexCoord(0, 0.25, 0, 1);
        end

        for k, PowerID in pairs(PowerIDs) do
            azeritePowerName, _, icon = GetSpellInfo(GetPowerInfo(PowerID) and GetPowerInfo(PowerID).spellID)
            --print(azeritePowerName)
            if IsPowerSelected(itemLocation, PowerID) then
                button.Icon:SetTexture(icon)
                button.BaseTrait.Icon:SetTexture(icon)
                button.Icon:Show();
                azeritePowerDescription = GetPowerText(itemLocation, PowerID, 0);
                button.Name = azeritePowerName;
                button.Description = azeritePowerDescription and azeritePowerDescription.description;
                button:Enable();
                break;
            end
            button:Disable();
        end

    end
    --]]
end

local RequestLoadItemData = C_Item.RequestLoadItemData  --Cache Item info
function NarciTooltip_SetComparison(itemLocation, self)
    local frame = NarciTooltip;
    if not C_Item.DoesItemExist(itemLocation) then
        frame.Label:SetText(CURRENTLY_EQUIPPED);
        frame.ItemName:SetText(EMPTY);
        frame.ItemName:SetTextColor(0.6, 0.6, 0.6);
        frame.EquipLoc:SetText(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][1])
        local _, textureName = GetInventorySlotInfo(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][2])
        frame.Icon:SetTexture(textureName);
        frame.BonusButton1:Hide();
        frame.BonusButton2:Hide();
        EmptyComparison();
        return;
    end

    RequestLoadItemData(itemLocation)
    --print("location"..C_Item.GetItemInventoryType(itemLocation))
    local itemLink = C_Item.GetItemLink(itemLocation)
    CacheTooltip(itemLink)
    local itemIcon = C_Item.GetItemIcon(itemLocation);
    local name = C_Item.GetItemName(itemLocation);
    local quality = C_Item.GetItemQuality(itemLocation);
    local r, g, b = GetItemQualityColor(quality);

    local stats = ItemStats(itemLocation);
    local primName = Narci_GetPrimaryStatusName();

    local baseStats = ItemStats(Narci_EquipmentFlyoutFrame.BaseItem);

    local _, _, itemSubType = GetItemInfoInstant(itemLink);

    frame.ItemName:SetText(name);
    frame.ItemName:SetTextColor(r, g, b);
    frame.Icon:SetTexture(itemIcon);
    frame.EquipLoc:SetText(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][1])
    frame.Label:SetText(itemSubType);

    DisplayComparison(NarciTooltipIlvl, STAT_AVERAGE_ITEM_LEVEL, stats.ilvl, baseStats.ilvl, nil, {1, 0.82, 0});
    DisplayComparison(NarciTooltipPrim, primName, stats.prim, baseStats.prim, nil, {1, 1, 1});
    DisplayComparison(NarciTooltipStamina, STAMINA_STRING, stats.stamina, baseStats.stamina, CR_ConvertRatio.stamina, {1, 1, 1});
    DisplayComparison(NarciTooltipCrit, STAT_CRITICAL_STRIKE, stats.crit, baseStats.crit, CR_ConvertRatio.crit);
    DisplayComparison(NarciTooltipHaste, STAT_HASTE, stats.haste, baseStats.haste, CR_ConvertRatio.haste);
    DisplayComparison(NarciTooltipMastery, STAT_MASTERY, stats.mastery, baseStats.mastery, CR_ConvertRatio.mastery);
    DisplayComparison(NarciTooltipVersa, STAT_VERSATILITY, stats.versa, baseStats.versa, CR_ConvertRatio.versa);

    RefVirtualTooltip:SetHyperlink(itemLink)    --Used to hook the Pawn upgrade notification (if supported)

    if stats.GemIcon and stats.GemPos then
        frame.BonusButton1.BonusIcon:SetTexture(stats.GemIcon);
        frame.BonusButton1:ClearAllPoints();
        frame.BonusButton1:SetPoint("LEFT", stats.GemPos, "RIGHT", 4, 0);
        frame.BonusButton1:Show();
    else
        frame.BonusButton1:Hide();
    end

    if stats.EnchantPos then
        frame.BonusButton2.BonusIcon:SetTexture(136244);
        frame.BonusButton2:ClearAllPoints();
        if frame.BonusButton1:IsShown() and ( stats.GemPos == stats.EnchantPos)then
            frame.BonusButton2:SetPoint("LEFT", stats.EnchantPos, "RIGHT", 14, 0);
        else
            frame.BonusButton2:SetPoint("LEFT", stats.EnchantPos, "RIGHT", 4, 0);
        end
        frame.BonusButton2:Show();
    else
        frame.BonusButton2:Hide();
    end

    if stats.EnchantSpellID then
        GameTooltip:SetSpellByID(stats.EnchantSpellID);
        GameTooltip:Show()
    end

    if not hasGapAdjusted then
        NarciTooltip_AdjustGap()
    end

    frame:SetFrameStrata("TOOLTIP");


    --Gem check
    local GemName, GemLink = IsItemSocketable(itemLink)
    if GemName then
        local itemSubClassID, icon = 9, nil;
        if GemLink then
            _, _, _, _, icon, _, itemSubClassID = GetItemInfoInstant(GemLink);
        end
        frame.GemSlot.GemBorder:SetTexture(GemBorderTexture[itemSubClassID]);
        frame.GemSlot.GemIcon:SetTexture(icon);
        frame.GemSlot:Show();
        frame.GemSlot.GemIcon:Show();
    else
        frame.GemSlot:Hide();
    end

    --SubTooltip
    local SubTooltip = frame.SubTooltip;
    local TraitsFrame = SubTooltip.AzeriteTraits;
    local extraText = SubTooltip.Description;
    local headerText = SubTooltip.Header.Text;
    --Azerite Empowered Items
    if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
        headerText:SetText(NARCI_AZERITE_POWERS);
        SubTooltip.Header:SetWidth(math.max(74, headerText:GetWidth() + 14))
        BuildAzeiteTraitsFrame(TraitsFrame, itemLocation, self);
        extraText:Hide();
        TraitsFrame:Show();
        SubTooltip:Show();
        return;
    else
        TraitsFrame:Hide();
    end

    --Extra Effect
    --print("CacheCheck Extra: "..tostring(C_Item.IsItemDataCachedByID(itemLink)))
    local headline, str = GetItemExtraEffect(itemLink)
    if not headline then
        headline, str = GetItemExtraEffect(itemLink)
    end

    if headline then
        extraText:SetText(str);
        TextColor(extraText, ColorTable.Positive2)
        headerText:SetText(headline);
        SubTooltip.Header:SetWidth(math.max(74, headerText:GetWidth() + 14))
        extraText:Show();
        SubTooltip:Show();
    else
        extraText:Hide();
        SubTooltip:Hide();
    end
    UntruncateText(SubTooltip, SubTooltip.Description)

    ----
end

local NT = CreateFrame("Frame");
NT:RegisterEvent("VARIABLES_LOADED");
NT:RegisterEvent("PLAYER_ENTERING_WORLD");
NT:RegisterEvent("PLAYER_LEVEL_UP");
NT:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
NT:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
NT:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
NT:SetScript("OnEvent",function(self,event,...)
    if event ~= "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
        C_Timer.After(1, function()
            SetCombatRatingRatio()
        end)
    end

    if event == "ACTIVE_TALENT_GROUP_CHANGED" then
        CurrentSpecID = GetSpecializationInfo(GetSpecialization())
    end

    if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        if azeriteItemLocation then
            HeartLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
        else
            HeartLevel = 0
        end
        CurrentSpecID = GetSpecializationInfo(GetSpecialization())
    end
end)

--[[
function PrintStats(slotID)
    --GetItemStats(C_Item.GetItemLink(ItemLocation:CreateFromEquipmentSlot(slotID)))
    local _, GemLink = GetItemGem(C_Item.GetItemLink(ItemLocation:CreateFromEquipmentSlot(slotID)), 1)
    print(GemLink)
    GemStats = GetItemStats(GemLink);
end
--]]


function NarciTooltip_Resize()
    local frame = NarciTooltip;
    local extraHeight = math.floor(frame.PawnText:GetHeight() + frame.ItemName:GetHeight() + 0.5)
    frame:SetHeight(DefaultHeight_Comparison + extraHeight)
    frame.Icon:SetWidth(frame:GetHeight());
end

function Narci_CreateAzeriteTraitTooltip(self)
    local maximumTraits = 5;
    local offset = 1;
    local startOffset = 8;
    local numButtons = 0;
    local name = self:GetName();
    local trait;
    for i = 2, maximumTraits do
        trait =  CreateFrame("Button", name .. i, self, "Narci_SubTooltip_Trait_Template");
        trait:SetPoint("LEFT", self.Traits[i-1], "RIGHT", offset, 0);
        tinsert(self.Traits, trait);
    end
end

NARCI_TEST_TRAIT = "Your damaging spells and abilities have a chance to fling a dagger at your target, causing them to bleed for 1620 Physical damage over 12 sec, stacking up to 4 times. Stabbing them in the back applies 2 stacks."
--[[
hooksecurefunc("DressUpItemLink", function(link)
    local str = string.match(link, "item[%-?%d:]+")
    local _, a = string.find(link, ":%d+:.-:")
    local _, b = string.find(link, ":%d+:")
    local strp = nil;
    if b + 1 < a -1 then
        strp = string.sub(link, b+1, a-1)
    end

    --local EnchantID = strp.match(strp, "%d%d+")
    --print(str)
    --print(strp)
end)
--]]