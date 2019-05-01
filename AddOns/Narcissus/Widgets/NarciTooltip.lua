--Parent: Narci_EquipmentFlyoutFrame (Narcissus.xml)
local hasGapAdjusted = false;
local STAMINA_STRING = SPELL_STAT3_NAME
local GemInfo = Narci_GemInfo;
local EnchantInfo = Narci_EnchantInfo;
local DefaultHeight_Comparison = 160;
local DefaultHeight_StatsComparisonTemplate = 12;
local Format_Digit = "%.2f";

local BreakUpLargeNumbers = NarciAPI_FormatLargeNumbers --BreakUpLargeNumbers;

local GetItemEnchant = NarciAPI_GetItemEnchant;

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
    local ajustedV1 = maxStringWidth + 30
    defaultV2 = defaultV2 -(ajustedV1 - defaultV1)
    --print("ajustedGap= "..tostring(ajustedV1))
    frame.GuideLineV1:SetPoint("LEFT", ajustedV1, 0)
    frame.GuideLineV2:SetPoint("LEFT", frame.GuideLineV1:GetName(), defaultV2, 0)
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
        local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink)
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

local function DisplayGearBonus()

end

local function DisplayComparison(Textframe, name, number, baseNumber, ratio, CustomColor)
    if not number then            --Set Number to "-"
        Textframe.Arrow:Hide();
        Textframe.NumDiff:Hide();
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
    DisplayComparison(NarciTooltipPrim, SPEC_FRAME_PRIMARY_STAT);
    DisplayComparison(NarciTooltipStamina, STAMINA_STRING);
    DisplayComparison(NarciTooltipCrit, STAT_CRITICAL_STRIKE);
    DisplayComparison(NarciTooltipHaste, STAT_HASTE);
    DisplayComparison(NarciTooltipMastery, STAT_MASTERY);
    DisplayComparison(NarciTooltipVersa, STAT_VERSATILITY);
end

function NarciTooltip_SetComparison(itemLocation)
    local frame = NarciTooltip;
    if not C_Item.DoesItemExist(itemLocation) then
        frame.ItemName:SetText(EMPTY);
        frame.ItemName:SetTextColor(0.6, 0.6, 0.6);
        frame.EquipLoc:SetText(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][1])
        
        local _, textureName = GetInventorySlotInfo(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][2])
        frame.Icon:SetTexture(textureName);
        return;
    end
    --print("location"..C_Item.GetItemInventoryType(itemLocation))
    local itemIcon = C_Item.GetItemIcon(itemLocation);
    local name = C_Item.GetItemName(itemLocation);
    local quality = C_Item.GetItemQuality(itemLocation);
    local r, g, b = GetItemQualityColor(quality);

    local stats = ItemStats(itemLocation);
    local primName = Narci_GetPrimaryStatusName();

    local baseStats = ItemStats(Narci_EquipmentFlyoutFrame.BaseItem);

    frame.ItemName:SetText(name);
    frame.ItemName:SetTextColor(r, g, b);
    frame.Icon:SetTexture(itemIcon);
    frame.EquipLoc:SetText(LocalizedSlotName[Narci_EquipmentFlyoutFrame.slotID][1])

    DisplayComparison(NarciTooltipIlvl, STAT_AVERAGE_ITEM_LEVEL, stats.ilvl, baseStats.ilvl, nil, {1, 0.82, 0});
    DisplayComparison(NarciTooltipPrim, primName, stats.prim, baseStats.prim, nil, {1, 1, 1});
    DisplayComparison(NarciTooltipStamina, STAMINA_STRING, stats.stamina, baseStats.stamina, CR_ConvertRatio.stamina, {1, 1, 1});
    DisplayComparison(NarciTooltipCrit, STAT_CRITICAL_STRIKE, stats.crit, baseStats.crit, CR_ConvertRatio.crit);
    DisplayComparison(NarciTooltipHaste, STAT_HASTE, stats.haste, baseStats.haste, CR_ConvertRatio.haste);
    DisplayComparison(NarciTooltipMastery, STAT_MASTERY, stats.mastery, baseStats.mastery, CR_ConvertRatio.mastery);
    DisplayComparison(NarciTooltipVersa, STAT_VERSATILITY, stats.versa, baseStats.versa, CR_ConvertRatio.versa);

    local itemLink = C_Item.GetItemLink(itemLocation)
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

    frame:SetFrameStrata("TOOLTIP")
end

local NT = CreateFrame("Frame");
NT:RegisterEvent("VARIABLES_LOADED");
NT:RegisterEvent("PLAYER_LEVEL_UP");
NT:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
NT:SetScript("OnEvent",function(self,event,...)
    C_Timer.After(4, function()
        SetCombatRatingRatio()
    end)
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
    frame.Icon:SetWidth(frame.Background:GetHeight());
end

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
