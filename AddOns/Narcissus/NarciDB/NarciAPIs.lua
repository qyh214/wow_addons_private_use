local max = math.max;
local GetText = GetText;
local GetTexture = GetTexture;
local NumLines = NumLines;
local _G = _G;
local GetItemInfo = GetItemInfo;
local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local PlaySound = PlaySound;
--------------------
----API Datebase----
--------------------
local SlotIDtoName = {
    --[SlotID] = {InventorySlotName, Localized Name, SlotID}
    [1] = {"HeadSlot", HEADSLOT, INVTYPE_HEAD},
    [2] = {"NeckSlot", NECKSLOT, INVSLOT_NECK},
    [3] = {"ShoulderSlot", SHOULDERSLOT, INVTYPE_SHOULDER},
    [4] = {"ShirtSlot", SHIRTSLOT, INVTYPE_BODY},
    [5] = {"ChestSlot", CHESTSLOT, INVTYPE_CHEST},
    [6] = {"WaistSlot", WAISTSLOT, INVTYPE_WAIST},
    [7] = {"LegsSlot", LEGSSLOT, INVTYPE_LEGS},
    [8] = {"FeetSlot", FEETSLOT, INVTYPE_FEET},
    [9] = {"WristSlot", WRISTSLOT, INVTYPE_WRIST},
    [10]= {"HandsSlot", HANDSSLOT, INVTYPE_HAND},
    [11]= {"Finger0Slot", FINGER0SLOT_UNIQUE, INVSLOT_FINGER1},
    [12]= {"Finger1Slot", FINGER1SLOT_UNIQUE, INVSLOT_FINGER2},
    [13]= {"Trinket0Slot", TRINKET0SLOT_UNIQUE, INVSLOT_TRINKET1},
    [14]= {"Trinket1Slot", TRINKET1SLOT_UNIQUE, INVSLOT_TRINKET2},
    [15]= {"BackSlot", BACKSLOT, INVTYPE_CLOAK},
    [16]= {"MainHandSlot", MAINHANDSLOT, INVTYPE_WEAPONMAINHAND},
    [17]= {"SecondaryHandSlot", SECONDARYHANDSLOT, INVTYPE_WEAPONOFFHAND},
    [18]= {"AmmoSlot", RANGEDSLOT, INVSLOT_RANGED},
    [19]= {"TabardSlot", TABARDSLOT, INVTYPE_TABARD},
}

Narci.SlotIDtoName = SlotIDtoName;
-----------------------------------------------------

local _, CommanderOfArgus = GetAchievementInfo(12078)                                   --Argus Weapon Transmogs: Arsenal: Weapons of the Lightforged
CommanderOfArgus = CommanderOfArgus or "Commander of Argus"
CommanderOfArgus = BATTLE_PET_SOURCE_6 .." |cFFFFD100"..CommanderOfArgus.."|r"
--print("Name: "..CommanderOfArgus)

local HeritageArmorItemIDs = {
    165931, 165932, 165933, 165934, 165935, 165936, 165937, 16598,                      --Dwarf
    161008, 161009, 161010, 161011, 161012, 161013, 161014, 161015,                     --Dark Iron
    156668, 156669, 156670, 156671, 156672, 156673, 156674, 156684,                     --Highmountain
    156699, 156700, 156701, 156702, 156703, 156704, 156705, 156706,                     --Lightforged
    161050, 161051, 161052, 161054, 161055, 161056, 161057, 161058,                     --Mag'har Orc (Blackrock Recolor)
    161059, 161060, 161061, 161062, 161063, 161064, 161065, 161066,                     --Mag'har Orc (Frostwolf Recolor)
    160992, 160993, 160994, 160999, 161000, 161001, 161002, 161003,                     --Mag'har Orc (Warsong Recolor)
    156690, 156691, 156692, 156693, 156694, 156695, 156696, 156697, 157758, 158917,     --Void Elf
    156675, 156676, 156677, 156678, 156679, 156680, 156681, 156685,                     --Nightborne
    166348, 166349, 166351, 166352, 166353, 166354, 166355, 166356, 166357,             --Blood Elf
    164993, 164994, 164995, 164996, 164997, 164998, 164999, 165000,                     --Zandalari
    165002, 165003, 165004, 165005, 165006, 165007, 165008, 165009,                     --Kul'tiran
    168282, 168283, 168284, 168285, 168286, 168287, 168288, 168289, 168290,             --Gnome
    168291, 168292, 168293, 168294, 168295, 168296, 168297, 168298, 170063,             --Tauren 
    --Reserved for test↓
    
}

local SecretlItemIDs = {
    [162690]  = true,     --Waist of Time
}

local SpecialItemList = {
    [152332] = CommanderOfArgus,            --Brilliant Daybreak Aegis
    [152333] = CommanderOfArgus,            --Lustrous Daybreak Aegis
    [152334] = CommanderOfArgus,            --Brilliant Eventide Aegis
    [152335] = CommanderOfArgus,            --Lustrous Eventide Aegis
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152337] = CommanderOfArgus,            --Brilliant Daybreak Blade
    [152338] = CommanderOfArgus,            --Lustrous Eventide Blade
    [152339] = CommanderOfArgus,            --Brilliant Daybreak Blade
    [152340] = CommanderOfArgus,            --Lustrous Daybreak Greatsword
    [152341] = CommanderOfArgus,            --Lustrous Eventide Greatsword
    [152342] = CommanderOfArgus,            --Lustrous Daybreak Staff
    [152343] = CommanderOfArgus,            --Lustrous Eventide Staff
    --[157636] = CommanderOfArgus,            --Test
}

local Ensemble_TheChosenDead_ItemIDs = {
    142423, 142421, 142422, 142434, 142420, 142433,     --Mail
    142427, 142425, 142431, 142435, 142426, 142424,     --Plate
    142419, 142430, 142432, 142417, 142418, 142416,     --Leather
    142415, 142411, 142410, 142413, 142429, 142414,     --Cloth
    143355, 143345, 143334, 143354, 143346, 143347,
    143356, 143339, 143349, 143342, 143344, 143335,
    143353, 143368, 143340, 143337, 143348, 143341,
    143343, 143367, 143336, 143352, 143366, 143351,
    143360, 143358, 143350, 143361, 143364, 143359,
    143338, 143369, 143365, 143363, 143362, 143357,
};


local function BuildSearchTable(table)
    if type(table) ~="table" then
        return;
    end

    local newTable = {};

    for k, v in pairs(table) do
        newTable[v] = true;
    end

    wipe(table)
    return newTable;
end

local HeritageArmorList = BuildSearchTable(HeritageArmorItemIDs);
local Ensemble_TheChosenDead = BuildSearchTable(Ensemble_TheChosenDead_ItemIDs);

-----Color API------
Narci_GlobalColorIndex = 0;
Narci_ColorTable = {
	[0] = { 35,  96, 147},	--default Blue  0.1372, 0.3765, 0.5765
	[1] = {121,  31,  35},	--Orgrimmar
	[2] = { 49, 176, 107},	--Zuldazar
	[3] = {187, 161, 134},	--Vol'dun
	[4] = { 89, 140, 123},	--Tiragarde Sound
	[5] = {127, 164, 114},	--Stormsong
	[6] = {156, 165, 153},	--Drustvar
	[7] = { 42,  63,  79},	--Halls of Shadow


	--Main City--
    [84]  = { 35,  96, 147},	--Stormwind City
    
	[85]  = {121,  52,  55},	--Orgrimmar
    [86]  = {121,  31,  35},	--Orgrimmar - Cleft of Shadow
    
    [87]  = {102,  64,  58},	--Ironforge
    [27]  = {151, 198, 213},	--Dun Morogh
    [469] = {151, 198, 213},	--New Tinkertown
    
    [88]  = {115, 140, 113},	--Thunder Bluff
    
    [89]  = {121,  31,  35},	--Darnassus	R.I.P.
    
    [90]  = { 42,  63,  79},	--Undercity

	[625] = { 42,  63,  79},	--Dalaran  	Broken Isles Halls of Shadow
	[626] = { 42,  63,  79},	--Hall of Shadow
	[627] = {102,  58,  64},	--Dalaran  	Broken Isles

	-- BFA --
	[1163]= { 89, 140, 123},	--Dazar'alor - The Great Seal
	[1164]= { 89, 140, 123},	--Dazar'alor - Hall of Chroniclers
	[1165]= { 89, 140, 123},	--Dazar'alor
	[862] = { 89, 140, 123},	--Zuldazar
	[864] = {187, 161, 134},	--Vol'dun
	[863] = {113, 173, 183},	--Nazmir
	[895] = { 89, 140, 123},	--Tiragarde Sound
	[1161]= { 89, 140, 123},	--Boralus
	[942] = {127, 164, 114},	--Stormsong
    [896] = {156, 165, 153},	--Drustvar
    
    [1462] = {16, 156, 192},    --Mechagon
    [1355] = {41,  74, 127},    --Nazjatar

    --Allied Race Starting Zone--
    [124]  = {87,  56, 132},    --DK
    [1186] = {117,  26, 22},    --Dark Iron

};

Narci_FontColor = {
    ["Brown"] = {0.85098, 0.80392, 0.70588, "|cffd9cdb4"},
    ["DarkGrey"] = {0.42, 0.42, 0.42, "|cff6b6b6b"},
    ["LightGrey"] = {0.72, 0.72, 0.72, "|cffb8b8b8"},
    ["White"] = {0.88, 0.88, 0.88, "|cffe0e0e0"},
    ["Good"] = {0.4862, 0.7725, 0.4627, "|cff7cc576"},
    ["Bad"] = {1, 0.3137, 0.3137, 0.3137, "|cffff5050"},
};

local BorderTexture = {
    ["Bright"]  = {
        [0] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Black",
        [1] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder",
        [2] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Uncommon",
        [3] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Rare",
        [4] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Epic",
        [5] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Legendary",
        [6] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Artifact",
        [7] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Heirloom",	--Void
        [8] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Azerite",
        [12] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Special",
        ["Heart"] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Heart",    --Heart
        ["Minimap"] = "Interface/AddOns/Narcissus/Art/Minimap/LOGO",
    },

    ["Dark"] = {
        [0] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        [1] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        [2] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Uncommon",
        [3] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Rare",
        [4] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Epic",
        [5] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Legendary",
        [6] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Artifact",
        [7] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Heirloom",	--Void
        [8] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Azerite",
        [12] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        ["Heart"] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Heart",    --Heart
        ["Minimap"] = "Interface/AddOns/Narcissus/Art/Minimap/LOGO-Thick",
    },
}

function NarciAPI_GetBorderTexture()
    local index = NarcissusDB and NarcissusDB.BorderTheme
    if not index then
        return BorderTexture["Bright"], BorderTexture["Bright"]["Minimap"], "Bright"
    else
        return (BorderTexture[index] or BorderTexture["Bright"]), BorderTexture[index]["Minimap"], index
    end
end

--------------------
------Item API------
--------------------

function NarciAPI_GetItemEnchant(itemLink)
    local _, _, _, linkType, linkID, EnchantID = strsplit(":|H", itemLink);
    return tonumber(EnchantID) or 0;
end

function NarciAPI_IsHeritageArmor(itemID)
    if not itemID then
        return false;
    end
    
    if HeritageArmorList[itemID] then
        return true;
    else
        return false;
    end
end

function NarciAPI_IsSpecialItem(itemID, modID)
    if not itemID then
        return false;
    end
    
    local itemSource = SpecialItemList[itemID]
    if itemSource ~= nil then
        --print("Is Special")
        return true, itemSource;
    end

    if SecretlItemIDs[itemID] then
        return true, ITEMSOURCE_SECRETFINDING;
    end

    if Ensemble_TheChosenDead[itemID] then
        return true, "|cFFFFD100"..DUNGEON_FLOOR_HELHEIMRAID1.."|r";
    end

    return false;
end

local PrimaryStatsList = {
	[LE_UNIT_STAT_STRENGTH] = NARCI_STAT_STRENGTH,
	[LE_UNIT_STAT_AGILITY] = NARCI_STAT_AGILITY,
	[LE_UNIT_STAT_INTELLECT] = NARCI_STAT_INTELLECT,
};

function NarciAPI_GetPrimaryStats()
    --Return name and value
	local currentSpec = GetSpecialization() or 1;
    local _, _, _, _, _, primaryStat = GetSpecializationInfo(currentSpec);
    primaryStat = primaryStat or 1;
    local value = UnitStat("player", primaryStat);
	local name = PrimaryStatsList[primaryStat];
	return name, value;
end

local GetItemEnchant = NarciAPI_GetItemEnchant;
local GemInfo = Narci_GemInfo;
local EnchantInfo = Narci_EnchantInfo;

function NarciAPI_GetItemStats(itemLocation)
    local statsTable = {};
    statsTable.gems = 0;
    if not itemLocation or not C_Item.DoesItemExist(itemLocation) then
        statsTable.prim = 0;
        statsTable.stamina = 0;
        statsTable.crit = 0;
        statsTable.haste = 0;
        statsTable.mastery = 0;
        statsTable.versatility = 0;
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
    local versatility = stats["ITEM_MOD_VERSATILITY"] or 0;

    statsTable.prim = prim;
    statsTable.stamina = stamina;
    statsTable.crit = crit;
    statsTable.haste = haste;
    statsTable.mastery = mastery;
    statsTable.versatility = versatility;
    statsTable.ilvl = ItemLevel;

    --Calculate bonus from Gems and Enchants--
    local gemIndex = 1;         --BFA 1 gem for each item.
    local GemName, GemLink = GetItemGem(itemLink, gemIndex);
    if GemLink then
        local GemID = GetItemInfoInstant(GemLink)
        --local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink)
        local _, _, _, _, GemIcon, _, itemSubClassID = GetItemInfoInstant(GemLink); 
        statsTable.GemIcon = GemIcon
        statsTable.gems = 1;

        if GemInfo[GemID] then
            local GemInfo = GemInfo[GemID]
            statsTable.GemPos = GemInfo[1];
            if GemInfo[1] == "crit" then
                statsTable.crit = statsTable.crit + GemInfo[2];
            elseif GemInfo[1] == "haste" then
                statsTable.haste = statsTable.haste + GemInfo[2];
            elseif GemInfo[1] == "mastery" then
                statsTable.mastery = statsTable.mastery + GemInfo[2];
            elseif GemInfo[1] == "versatility" then
                statsTable.versatility = statsTable.versatility + GemInfo[2];
            elseif GemInfo[1] == "AGI" or GemInfo[1] == "STR" or GemInfo[1] == "INT" then
                statsTable.prim = statsTable.prim + GemInfo[2];
                statsTable.GemPos = "prim";
            end
        end
    end

    local EnchantID = GetItemEnchant(itemLink)
    if EnchantID ~= 0 and EnchantInfo[EnchantID] then
        local EnchantInfo = EnchantInfo[EnchantID]
        statsTable.EnchantPos = EnchantInfo[1];
        if EnchantInfo[1] == "crit" then
            statsTable.crit = statsTable.crit + EnchantInfo[2];
        elseif EnchantInfo[1] == "haste" then
            statsTable.haste = statsTable.haste + EnchantInfo[2];
        elseif EnchantInfo[1] == "mastery" then
            statsTable.mastery = statsTable.mastery + EnchantInfo[2];
        elseif EnchantInfo[1] == "versatility" then
            statsTable.versatility = statsTable.versatility + EnchantInfo[2];
        elseif EnchantInfo[1] == "AGI" or EnchantInfo[1] == "STR" or EnchantInfo[1] == "INT" then
            statsTable.prim = statsTable.prim + EnchantInfo[2];
            statsTable.EnchantPos = "prim";
        end

        statsTable.EnchantSpellID = EnchantInfo[3];
    end

    return statsTable;
end
--------------------
----Tooltip Scan----
--------------------

local TP = CreateFrame("GameTooltip", "NarciVirtualTooltip", nil, "GameTooltipTemplate")
TP:SetScript("OnLoad", GameTooltip_OnLoad);
TP:SetOwner(UIParent, 'ANCHOR_NONE');

local SocketAction = ITEM_SOCKETABLE;
local find = string.find;
local SocketPath = "ItemSocketingFrame";
function NarciAPI_IsItemSocketable(itemLink, SocketID)
    if not itemLink then    return; end
    if not SocketID then SocketID = 1; end
    local gemName, gemLink = GetItemGem(itemLink, SocketID)
    if gemName then
        return gemName, gemLink;
    end
    --]]

    local tex, texID;
    for i = 1, 3 do
        tex = _G["NarciVirtualTooltip".."Texture"..i]
        tex = tex:SetTexture(nil);
    end

    TP:SetHyperlink(itemLink);

    for i = 1, 3 do     --max 10
        tex = _G["NarciVirtualTooltip".."Texture"..i]
        texID = tex and tex:GetTexture();
        --print(texID)
        --if texID and find(texID, SocketPath) then
        if texID == 458977 then     --no file name anymore 458977:Regular empty socket texture
            --print("Has Socket")
            return "Empty", nil;
        end
    end
    --[[
    for i = begin, num do
        local str = _G["NarciVirtualTooltip".."TextLeft"..i]
        if str and str:GetText() == SocketAction then
            print("Has Socket")
            return;
        end
    end
    --]]
    return nil, nil;
end

local strtrim = strtrim;
local gsub = gsub;
local greyFont = "|cff959595";
local leftBrace = "%(";
local rightBrace = "%)";
if (GetLocale() == "zhCN") or (GetLocale() == "zhTW") then
    leftBrace = "（"
    rightBrace = "）"
end


local SOURCE_KNOWN = TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN;
local APPEARANCE_KNOWN = TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN;
local APPEARANCE_UNKNOWN = TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN;

function NarciAPI_IsAppearanceKnown(itemLink)
    --Need to correspond with C_TransmogCollection.PlayerHasTransmog
    if not itemLink then    return; end
    TP:SetHyperlink(itemLink);
    local str;
    local num = TP:NumLines();
    for i = num, num - 2, -1 do
        str = nil;
        str = _G["NarciVirtualTooltip".."TextLeft"..i]
        if not str then
            return false;
        else
            str = str:GetText();
        end
        if str == SOURCE_KNOWN or str == APPEARANCE_KNOWN then
            return true;
        elseif str == APPEARANCE_UNKNOWN then
            return false;
        end
    end
    return false;
end

local function trimComma(text)
    return strtrim(text, ":：");
end

local function formatString(text, removedText)
    text = strtrim(text, removedText);
    text = trimComma(text);
    text = strtrim(text);                               --remove space
    text = gsub(text, leftBrace, "\n\n"..greyFont)
    text = gsub(text, rightBrace, "|r")
    return text;
end



local onUse = ITEM_SPELL_TRIGGER_ONUSE;
local onEquip = ITEM_SPELL_TRIGGER_ONEQUIP;
local onProc = ITEM_SPELL_TRIGGER_ONPROC;
local minLevel = SOCKETING_ITEM_MIN_LEVEL_I;
local _onUse = trimComma(onUse)
local _onEquip = trimComma(onEquip)
local _onProc = trimComma(onProc)

function NarciAPI_GetItemExtraEffect(itemLink)
    if not itemLink then    return; end

    TP:SetHyperlink(itemLink);
    local num = TP:NumLines();
    local begin = max(num - 6, 0);
    local output = "";
    local category, str;

    for i = begin, num, 1 do
        str = nil;
        str = _G["NarciVirtualTooltip".."TextLeft"..i]
        if not str then
            return;
        else
            str = str:GetText();
        end

        if find(str, onUse) then
            str = formatString(str, _onUse);
            if not category then    category = _onUse; end
            --return _onUse, str;
            output = output..str.."\n\n"
        elseif find(str, onEquip) then
            str = formatString(str, _onEquip);
            if not category then    category = _onEquip; end
            --return _onEquip, str;
            output = output..str.."\n\n"
        elseif find(str, onProc) then
            str = formatString(str, _onProc);
            if not category then    category = _onProc; end
            --return _onProc, str;
            output = output..str.."\n\n"
        end
        
    end
    return category, output;
end

function NarciAPI_GetGemBonus(itemID)
    --itemID: Gem's Item ID or hyperlink
    if not itemID then    return; end
    if type(itemID) == "number" then
        TP:SetItemByID(itemID)
    else
        TP:SetHyperlink(itemID)
    end
    local num = TP:NumLines();
    local output;
    local str, level;
    
    for i = 1, num do
        str = _G["NarciVirtualTooltip".."TextLeft"..i]
        if not str then
            return;
        else
            str = str:GetText();
            if not str then
                return;
            end
        end
        
        if strsub(str, 1, 1) == "+" then
            output = str;
        end

        if find(str, minLevel) then
            level = formatString(str, minLevel);
        end

        if level and output then return output, tonumber(level); end
    end
    return output, level;
end

--------------------
---Formating API----
--------------------

function NarciAPI_FormatLargeNumbers(value)
    value = tonumber(value) or 0;
    local formatedNumber = ""
    if value >= 1000 and value < 1000000 then
        formatedNumber = strsub(value, 1, -4) .. "," .. strsub(value, -3);
    elseif value >= 1000000 and value < 1000000000 then
        formatedNumber = strsub(value, 1, -7) .. "," .. strsub(value, -6, -4) .. "," .. strsub(value, -3);
    else
        formatedNumber  = tostring(value)
    end
    return formatedNumber
end


--------------------
---Fade Frame API---
--------------------

local function SetFade_finishedFunc(frame)
	if frame.fadeInfo.mode == "OUT" then
		frame:Hide();
	elseif	frame.fadeInfo.mode == "IN" then
		frame:Show();
	end
end

function NarciAPI_FadeFrame(frame, time, mode)
	if mode == "IN" then
		UIFrameFadeIn(frame, time, frame:GetAlpha(), 1);
	elseif mode == "OUT" then
		if not frame:IsShown() then
			return;
		end
		UIFrameFadeOut(frame, time, frame:GetAlpha(), 0);
	elseif mode == "Forced_IN" then
		UIFrameFadeIn(frame, time, 0, 1);
	elseif mode == "Forced_OUT" then
	    UIFrameFadeOut(frame, time, 1, 0);
	end

	if not frame.fadeInfo then
		return;
	end

	frame.fadeInfo.finishedArg1 = frame;
	frame.fadeInfo.finishedFunc = SetFade_finishedFunc
end
------------------------------------------------------------------

--------------------
---UI Element API---
--------------------
local screenWidth, screenHeight = GetPhysicalScreenSize();
local UIParentWidth, UIParentHeight = UIParent:GetSize();

function NarciAPI_OptimizeBorderThickness(self)
    if not self.HasOptimized then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()

        local uiScale = self:GetEffectiveScale(); 
        --local scale = string.match(GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" );
        --local rate = 768/scale/uiScale;
        --local _, screenHeight = GetPhysicalScreenSize();
        local rate = (768/screenHeight)/uiScale
        local borderWeight = 2.0;
        local weight = borderWeight * rate;
        local weight2 = weight * math.sqrt(2);
        self.Border:SetPoint("TOPLEFT", self, "TOPLEFT", weight, -weight)
        self.Border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -weight, weight)

        if self.ThumbBorder then
            self.ThumbBorder:SetPoint("TOPLEFT", self.VirtualThumb, -weight2, weight2)
            self.ThumbBorder:SetPoint("BOTTOMRIGHT", self.VirtualThumb,weight2, -weight2)
        end

        if self.Marks then
            for i=1, #self.Marks do
                self.Marks[i]:SetWidth(weight);
            end
        end

        self.HasOptimized = true;
    end
end

function NarciAPI_SliderWithSteps_OnLoad(self)
    self.oldValue = -1208;
    self.Marks = {};
    local width = self:GetWidth();
    local step = self:GetValueStep();
    local sliderMin, sliderMax = self:GetMinMaxValues()
    local range = sliderMax - sliderMin;
    local num_Gap = math.floor((range / step) + 0.5);
    if num_Gap == 0 then return; end;
    local tex;
    local markOffset = 5;
    width = width - 2*markOffset
    --print(self:GetName().." "..(num_Gap + 1))
    for i=1, (num_Gap + 1) do
        tex = self:CreateTexture(nil, "BACKGROUND", nil, 1);
        --tex:SetAllPoints()
        tex:SetSize(2, 10)
        tex:SetColorTexture(0.3, 0.3, 0.3, 1)
        --print((i-1)*width/num_Gap)
        tex:SetPoint("LEFT", self, "LEFT", markOffset + (i-1)*width/num_Gap, 0)
        tinsert(self.Marks, tex);
    end
end

-----Smooth Scroll-----
local min = math.min;
local max = math.max;
local minOffset = 2;
local function SmoothScrollContainer_OnUpdate(self, elapsed)
	local delta = self.delta;
    local scrollBar = self:GetParent().scrollBar;
    local step = max(abs(scrollBar:GetValue() - self.EndValue)*(self.timeRatio) , self.minOffset);		--if the step (Δy) is too small, the fontstring will jitter.
    
	local remainedStep = abs(self.EndValue - scrollBar:GetValue())
    if ( delta == 1 ) then
		scrollBar:SetValue(max(0, scrollBar:GetValue() - step));
	else
		scrollBar:SetValue(min(self.maxVal, scrollBar:GetValue() + step));
    end
    
	if self.animationDuration >= 2 or remainedStep <= ( self.minOffset) then
        --scrollBar:SetValue(math.floor(min(self.maxVal, self.EndValue) + 0.5));
        scrollBar:SetValue(min(self.maxVal, self.EndValue));
        self:Hide();
    end

    --print(step)
end

local function NarciAPI_SmoothScroll_OnMouseWheel(self, delta, stepSize)
	if ( not self.scrollBar:IsVisible() ) then
		return;
	end
    local ScrollContainer = self.SmoothScrollContainer; 
	local stepSize = stepSize or self.stepSize or self.buttonHeight;

    ScrollContainer.stepSize = stepSize;
	ScrollContainer.maxVal = self.range

	self.scrollBar:SetValueStep(0.01);
	ScrollContainer.delta = delta;

	local Current = self.scrollBar:GetValue();
	if not((Current == 0 and delta > 0) or (Current == self.range and delta < 0 )) then
		ScrollContainer:Show()
	end
	
	local deltaRatio = ScrollContainer.deltaRatio or 1;
    ScrollContainer.EndValue = min(max(0, ScrollContainer.EndValue - delta*deltaRatio*self.buttonHeight), self.range);
end

function NarciAPI_SmoothScroll_Initialization(self, updatedList, updateFunc, deltaRatio, timeRatio, minOffset)     --self=ListScrollFrame
	self.update = updateFunc;
    self.updatedList = UpdatedList;

    local parentName = self:GetName();
    local frameName = parentName and (parentName .. "SmoothScrollContainer") or nil;
    
    local SmoothScrollContainer = CreateFrame("Frame", frameName, self);
    SmoothScrollContainer:Hide();
    
    local scale = string.match(GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" );
    local uiScale = self:GetEffectiveScale(); 
    --local pixel = 768/scale/uiScale;
    --local _, screenHeight = GetPhysicalScreenSize();
    local pixel = (768/screenHeight)/uiScale
    self.scrollBar:SetValueStep(0.001);
    SmoothScrollContainer.stepSize = 0;
    SmoothScrollContainer.delta = 0;
    SmoothScrollContainer.animationDuration = 0;
    SmoothScrollContainer.EndValue = 0;
	SmoothScrollContainer.maxVal = 0;
    SmoothScrollContainer.deltaRatio = deltaRatio or 1;
    SmoothScrollContainer.timeRatio = timeRatio or 1;
    SmoothScrollContainer.minOffset = pixel or minOffset or 2;
    SmoothScrollContainer:SetScript("OnUpdate", SmoothScrollContainer_OnUpdate);
    SmoothScrollContainer:SetScript("OnShow", function(self)
        self.EndValue = self:GetParent().scrollBar:GetValue();
    end);

    self.SmoothScrollContainer = SmoothScrollContainer;

    self:SetScript("OnMouseWheel", NarciAPI_SmoothScroll_OnMouseWheel);
end

-----Create A List of Button----
function NarciAPI_BuildButtonList(self, buttonTemplate, buttonNameTable, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	local button, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	initialPoint = initialPoint or "TOPLEFT";
    initialRelative = initialRelative or "TOPLEFT";
    initialOffsetX = initialOffsetX or 0;
    initialOffsetY = initialOffsetY or 0;
	point = point or "TOPLEFT";
	relativePoint = relativePoint or "BOTTOMLEFT";
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;

	if ( self.buttons ) then
		buttons = self.buttons;
		buttonHeight = buttons[1]:GetHeight();
	else
		button = CreateFrame("BUTTON", buttonName and (buttonName .. 1) or nil, self, buttonTemplate);
		buttonHeight = button:GetHeight();
        button:SetPoint(initialPoint, self, initialRelative, initialOffsetX, initialOffsetY);
        button:SetID(0);
        buttons = {}
        button.Name:SetText(buttonNameTable[1])
		tinsert(buttons, button);
	end

	local numButtons = #buttonNameTable;

	for i = 2, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, self, buttonTemplate);
        button:SetPoint(point, buttons[i-1], relativePoint, offsetX, offsetY);
        button:SetID(i-1);
        button.Name:SetText(buttonNameTable[i])
		tinsert(buttons, button);
	end

	self.buttons = buttons;
end


-----Language Adaptor-----
function Narci_LanguageDetector(string)
	local str = string
	local len = strlen(str)
	local i = 1
	while i <= len do
		local c = string.byte(str, i)
		local shift = 1
		--print(c)
		if (c > 0 and c <= 127)then
			shift = 1
		elseif c== 195 then
			shift = 2	--Latin/Greek
		elseif (c >= 208 and c <=211) then
			shift = 2
			return "RU" --RU included
		elseif (c >= 224 and c <= 227) then
			shift = 3	--JP
			return "JP"
		elseif (c >= 228 and c <= 233) then
			shift = 3	--CN
			return "CN"
		elseif (c >= 234 and c <= 237) then
			shift = 3	--KR
			return "KR"
		elseif (c >= 240 and c <= 244) then
			shift = 4	--Unknown invalid
		end
		local char = string.sub(str, i, i+shift-1)
		i = i + shift
	end
	return "RM"
end

--[[
function LDTest(string)
	local str = string
	local lenInByte = #str
	
	for i=1,lenInByte do
		local char = strsub(str, i,i)
		local curByte = string.byte(str, i)
		print(char.." "..curByte)
	end
	return "roman"
end

local Eng = "abcdefghijklmnopqrstuvwxyz" --abcdefghijklmnopqrstuvwxyz Z~90 z~122 1-1
local DE =  "äöüß" --195 1-2
local CN =  "乀氺" --228 229 230 233 HEX E4-E9 Hexadecimal UTF-8 CJK
local KR = "제" --237 236 235 234 1-3  EB-ED
local RU = "ѱӧ" --D0400-D04C0  208 209 210 211 1-2
local FR = "ÀÃÇÊÉÕàãçêõáéíóúà" --1-2 195 C3 -PR
local JP = "ひらがな" --1-3 227 E3 Kana
--LDTest("繁體繁体")
--local language = LanguageDetector("繁體中文")
--print("Str is: "..language)
--]]

local LanguageDetector = Narci_LanguageDetector;
local PlayerNameFont={
	["CN"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
	["RM"] = "Interface\\AddOns\\Narcissus\\Font\\SemplicitaPro-Semibold.otf",
	["RU"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSans-Medium.ttf",
	["KR"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
	["JP"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
}

local EditBoxFont={
	["CN"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
	["RM"] = {"Interface\\AddOns\\Narcissus\\Font\\SourceSansPro-Semibold.ttf", 9},
	["RU"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSans-Medium.ttf", 8},
	["KR"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
	["JP"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
}
--SetTextColor(0.85098, 0.80392, 0.70588)
local function SmartFontType(self, height, fontTable)
	local str = self:GetText();
	local Language = LanguageDetector(str);
	--print(str.." Language is: "..Language);
    local Height = self:GetHeight();
    if Language and fontTable[Language] then
		self:SetFont(fontTable[Language] , Height);
	end
end

local function SmartEditBoxFont(self, extraHeight)
	local str = self:GetText();
	local Language = LanguageDetector(str);
    if Language and EditBoxFont[Language] then
        local height = extraHeight or 0;
		self:SetFont(EditBoxFont[Language][1] , EditBoxFont[Language][2] + height);
	end
end

function NarciAPI_SmartFontType(self, height)
    SmartFontType(self, height, PlayerNameFont);
end

function NarciAPI_SmartEditBoxType(self, extraHeight)
    SmartEditBoxFont(self, extraHeight);
end

function NarciAPI_EditBox_OnLanguageChanged(self, language)
    SmartEditBoxFont(self);
end

-----Filter Shared Functions-----
function NarciAPI_LetterboxAnimation(command)
	local frame = Narci_FullScreenMask;
	frame:StopAnimating();
	if command == "IN" then
		frame:Show();
		frame.BottomMask.animIn:Play();
		frame.TopMask.animIn:Play();
	elseif command == "OUT" then
		frame.BottomMask.animOut:Play();
		frame.TopMask.animOut:Play();
	else
        if NarcissusDB.LetterboxEffect then
            PhotoModeController.PhotoModeController_AnimFrame.toAlpha = 0
			frame:Show();
			frame.BottomMask.animIn:Play();
			frame.TopMask.animIn:Play();
		end
	end
end

-----Format Normalization-----
local function SplitTooltipByLineBreak(str)
    local str1, _, str2 = strsplit("\n", str);
    return str1 or "", str2 or "";
end

NARCI_CRIT_TOOLTIP, NARCI_CRIT_TOOLTIP_FORMAT = SplitTooltipByLineBreak(CR_CRIT_TOOLTIP);
_, NARCI_HASTE_TOOLTIP_FORMAT = SplitTooltipByLineBreak(STAT_HASTE_BASE_TOOLTIP);
NARCI_VERSATILITY_TOOLTIP_FORMAT_1, NARCI_VERSATILITY_TOOLTIP_FORMAT_2 = SplitTooltipByLineBreak(CR_VERSATILITY_TOOLTIP);

-----Delayed Tooltip-----
local timeDelay = 0.6;

local GetCursorPosition = GetCursorPosition;
local DelayedTP = CreateFrame("Frame");
DelayedTP:Hide();

DelayedTP:SetScript("OnShow", function(self)
    self.TotalTime = 0;                                    --Total time after ShowDelayedTooltip gets called
    --self.ScanTime = 0;                                   --Cursor scaning time
    --self.CursorX, self.CursorY = GetCursorPosition();    --Cursor position
end)
DelayedTP:SetScript("OnHide", function(self)
    self.TotalTime = 0;
    --self.ScanTime = 0;
end)
DelayedTP:SetScript("OnUpdate", function(self, elapsed)
    self.TotalTime = self.TotalTime + elapsed;
    --self.ScanTime = self.ScanTime + elapsed;
    if self.TotalTime >= timeDelay then
        if self.focus and self.focus == GetMouseFocus() then
            GameTooltip:ClearAllPoints();
            GameTooltip:SetPoint(self.point, self.relativeTo, self.relativePoint, self.ofsx, self.ofsy);
            UIFrameFadeIn(GameTooltip, 0.12, 0, 1);
        end
        self:Hide();
    end
end)

function NarciAPI_ShowDelayedTooltip(point, relativeTo, relativePoint, ofsx, ofsy)     
    local TP = DelayedTP;
    TP.focus = GetMouseFocus();
    TP.point, TP.relativeTo, TP.relativePoint, TP.ofsx, TP.ofsy = point, relativeTo, relativePoint, ofsx, ofsy;
    TP:Hide();
    TP:Show();
end

-----Alert Frame-----
NarciAlertFrameMixin = {};

local function CreateErrorAnimation(frame)
    if frame.animError then return; end;

    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Translation")
    a1:SetOrder(1);
    a1:SetOffset(4, 0);
    a1:SetDuration(0.05);
    local a2 = ag:CreateAnimation("Translation")
    a2:SetOrder(2);
    a2:SetOffset(-8, 0);
    a2:SetDuration(0.1);
    local a3 = ag:CreateAnimation("Translation")
    a3:SetOrder(3);
    a3:SetOffset(8, 0);
    a3:SetDuration(0.1);
    local a4 = ag:CreateAnimation("Translation")
    a4:SetOrder(4);
    a4:SetOffset(-4, 0);
    a4:SetDuration(0.05);

    frame.animError = ag;
end

function NarciAlertFrameMixin:SetAnchor(frame, offsetY, AddErrorAnimation)
    frame:RegisterEvent("UI_ERROR_MESSAGE");
	self:Hide();
    self:ClearAllPoints();
    self:SetScale(Narci_Character:GetEffectiveScale())
    local y = offsetY or -12;
	self:SetPoint("BOTTOM", frame, "TOP", 0, y);
    self:SetFrameLevel(50)
    self.anchor = frame;

    if AddErrorAnimation then
        CreateErrorAnimation(frame);
    end

    C_Timer.After(0.5, function()
		frame:UnregisterEvent("UI_ERROR_MESSAGE");
    end)
end

function NarciAlertFrameMixin:AddMessage(msg, UseErrorAnimation)
    self.Text:SetText(msg);
    self:SetHeight(self.Background:GetHeight());
    UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1);
    PlaySound(138528);      --Mechagon_HK8_Lockon
    local anchorFrame = self.anchor;
    if anchorFrame then
        if anchorFrame.animError and UseErrorAnimation then
            anchorFrame.animError:Play();
        end
        anchorFrame:UnregisterEvent("UI_ERROR_MESSAGE");
    end
end



--------------------
--UI 3D Animation---
--------------------
Narci.AnimSequenceInfo = 
{	["Controller"] = {
		["TotalFrames"] = 30,
		["cX"] = 0.205078125,
		["cY"] = 0.1171875,
		["Column"] = 4,
		["Row"] = 8,
	},

	["Heart"] = {
		["TotalFrames"] = 28,
		["cX"] = 0.25,
		["cY"] = 0.140625,
		["Column"] = 4,
		["Row"] = 7,
    },
    
	["ActorPanel"] = {
		["TotalFrames"] = 26,
		["cX"] = 0.4296875,
		["cY"] = 0.056640625,
		["Column"] = 2,
		["Row"] = 17,
    },
}

function NarciAPI_PlayAnimationSequence(index, SequenceInfo, Texture)
	local Frames = SequenceInfo["TotalFrames"];
	local cX, cY = SequenceInfo["cX"], SequenceInfo["cY"];
	local Column, Row = SequenceInfo["Column"], SequenceInfo["Row"]

	if index > Frames or index < 1 then
		return false;
	end

	local n = math.modf((index -1)/ Row) + 1;
	local m = index % Row
	if m == 0 then
		m = Row;
	end

	local left, right = (n-1)*cX, n*cX;
	local top, bottom = (m-1)*cY, m*cY;
	Texture:SetTexCoord(left, right, top, bottom);
	
	Texture:SetAlpha(1)
	return true;
end



--------------------
-----Play Voice-----
--------------------
local _, _, raceID = UnitRace("player");
local genderID = UnitSex("player") or 2;
raceID = raceID or 1;
genderID = genderID - 1;    --(2→1) Male (3→2) Female
if raceID == 25 or raceID == 26 then
    --Pandaren faction
    raceID = 24;
end

local VOICE_BY_RACE = {
    --[raceID] = { [gender] = {Error_NoTarget, } }
	[1] = {[1] = {1906, 2669, },
				[2] = {2030, 2681, }},		            --1 Human 

	[2] = {[1] = {2317, 2693, },
				[2] = {2372, 2705, }},		            --2 Orc

	[3] = {[1] = {1614, 2717, },
				[2] = {1684, 2729, }},		            --3 Dwarf 

	[4] = {[1] = {56231, 56311, },
				[2] = {56096, 56174, }},		        --4 NE 

	[5] = {[1] = {2085, 2765, },
				[2] = {2205, 2777, }},		            --5 UD 

	[6] = {[1] = {2459, 2789, },
				[2] = {2458, 2802, }},		            --6 Tauren

	[7] = {[1] = {1741, 2827, },
				[2] = {1796, 2839, }},		            --7 Gnome 

	[8] = {[1] = {1851, 2851, },
				[2] = {1961, 2863, }},		            --8 Troll 

	[9] = {[1] = {19109, 19137, },
				[2] = {19218, 19246}},		            --9 Goblin 

	[10] = {[1] = {9597, 9664, },
				[2] = {9598, 9624, }},		            --10 BloodElf

	[11] = {[1] = {9463, 9714, },
				[2] = {9514, 9689, }},		            --11 Goat 
			
	[22] = {[1] = {18991, 19346, },
				[2] = {18719, 19516, }},	            --22 Worgen

	[24] = {[1] = {28846, 28924, },
				[2] = {29899, 29812, }},		        --24 Pandaren

	[27] = {[1] = {96356, 96383, },
				[2] = {96288, 96315, }},		        --27 Nightborne

	[28] = {[1] = {95931, 95844, },
                [2] = {95510, 95543, }},		        --28 Highmountain Tauren
                
	[29] = {[1] = {95636, 95665, },
				[2] = {95806, 95857, }},		        --29 Void Elf

	[30] = {[1] = {96220, 96247, },
                [2] = {96152, 96179, }},		        --30 Light-forged
                
	[31] = {[1] = {127289, 1273128, },
				[2] = {126915, 126944, }},		        --31 Zandalari

	[32] = {[1] = {127102, 127131, },
				[2] = {127008, 127037, }},	            --32 Kul'Tiran 

	[34] = {[1] = {101933, 101962, },
                [2] = {101859, 101888, }},		        --36 Dark Iron Dwarf

	[35] = {[1] = {144073, 144111, },
                [2] = {143981, 144019, }},		        --35 Vulpera     
                      
	[36] = {[1] = {110370, 110399, },
                [2] = {110295, 110324, }},		        --36 Mag'har
                
	[37] = {[1] = {143863, 143892, },
				[2] = {144223, 144275, }},		        --37 Mechagnome!!!!
}

local ERROR_NOTARGET, ALERT_INCOMING;
if VOICE_BY_RACE[raceID] then
    ERROR_NOTARGET = VOICE_BY_RACE[raceID][genderID][1];
    ALERT_INCOMING = VOICE_BY_RACE[raceID][genderID][2];

end
ERROR_NOTARGET = ERROR_NOTARGET or 2030;
ALERT_INCOMING = ALERT_INCOMING or 2669;

function Narci:PlayVoice(name)
    if name == "ERROR" then
        PlaySound(ERROR_NOTARGET, "Dialog");
    elseif name == "DANGER" then
        PlaySound(ALERT_INCOMING, "Dialog");
    end
end

--Time
--C_DateAndTime.GetCurrentCalendarTime