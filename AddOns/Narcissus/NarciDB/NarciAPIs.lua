local max = math.max;
local GetText = GetText;
local GetTexture = GetTexture;
local NumLines = NumLines;
local _;
local _G = _G;
local After = C_Timer.After;
local GetItemInfo = GetItemInfo;
local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local PlaySound = PlaySound;
local _, _, _, tocversion = GetBuildInfo();

------------------------
--Redirect API for 9.0--
------------------------
tocversion = tonumber(tocversion);

local HasQuestCompleted;

if tocversion == 80300 then
    function HasQuestCompleted(questID)
        return IsQuestComplete(questID);
    end
elseif tocversion > 89999 and C_QuestLog.IsComplete then
    function HasQuestCompleted(questID)
        return C_QuestLog.IsComplete(questID);
    end
else
    function HasQuestCompleted(questID)
        return false
    end
end

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

local _, CommanderOfArgus = GetAchievementInfo(12078);                                  --Argus Weapon Transmogs: Arsenal: Weapons of the Lightforged
CommanderOfArgus = CommanderOfArgus or "Commander of Argus";
CommanderOfArgus = "|cFFFFD100"..BATTLE_PET_SOURCE_6 .."|r "..CommanderOfArgus;
--local EnsorcelledEverwyrm = C_MountJournal.GetMountFromSpell(307932);
local _, _, PROMOTION_SHADOWLANDS = C_MountJournal.GetMountInfoExtraByID(1289);         --EnsorcelledEverwyrm   Promotion: Shadowlands Heroic Edition

local HERITAGE_ARMOR = Narci.L["Heritage Armor"];
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
    173968, 173966, 173970, 173971, 173967, 173969, 174354, 174355,                     --Vulpera
    173961, 173962, 173963, 173964, 173958, 173972,                                     --Mechagnome
    174000, 174001, 174002, 174003, 174004, 174005, 174006, 173999, 173998,             --Worgen

    --Reserved for test ↓
    
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

    [172075] = PROMOTION_SHADOWLANDS,       --The Eternal Traveler's
    [172076] = PROMOTION_SHADOWLANDS,
    [172077] = PROMOTION_SHADOWLANDS,
    [172078] = PROMOTION_SHADOWLANDS,
    [172079] = PROMOTION_SHADOWLANDS,
    [172080] = PROMOTION_SHADOWLANDS,
    [172081] = PROMOTION_SHADOWLANDS,
    [172082] = PROMOTION_SHADOWLANDS,
    [172083] = PROMOTION_SHADOWLANDS,
    --[134110] = PROMOTION_SHADOWLANDS,            --Test
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

    wipe(table);
    return newTable;
end

local HeritageArmorList = BuildSearchTable(HeritageArmorItemIDs);
local Ensemble_TheChosenDead = BuildSearchTable(Ensemble_TheChosenDead_ItemIDs);

function GetArtifactVisualModID(colorID)
    colorID = colorID or 42;
    local PRINT = false;
    local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, hideVisual = C_Transmog.GetSlotVisualInfo(16, 0);
    if not appliedSourceID or appliedSourceID == 0 then
        appliedSourceID = baseSourceID;
    end
    local categoryID, visualID, canEnchant, icon, _, itemLink, transmogLink, _ = C_TransmogCollection.GetAppearanceSourceInfo(appliedSourceID)
    local sourceInfo  = C_TransmogCollection.GetSourceInfo(appliedSourceID)
    if sourceInfo and PRINT then
        for k, v in pairs(sourceInfo) do
            print(k.." "..tostring(v))
        end
    else
        print(sourceInfo.itemModID);
    end
    itemID = sourceInfo.itemID or 127829;
    itemLink = "\124cffe5cc80\124Hitem:".. itemID .."::::::::120::16777472::2:::"..colorID..":::::::::::::\124h[".. (sourceInfo.name or "") .."]\124h\124r"
    DEFAULT_CHAT_FRAME:AddMessage(itemLink)
end

-----Color API------
Narci_GlobalColorIndex = 0;
Narci_ColorTable = {
    --[0] = { 35,  96, 147},	--default Blue  0.1372, 0.3765, 0.5765
    [0] = {78,  78,  78},   --Default Black
	[1] = {121,  31,  35},	--Orgrimmar
	[2] = { 49, 176, 107},	--Zuldazar
	[3] = {187, 161, 134},	--Vol'dun
	[4] = { 89, 140, 123},	--Tiragarde Sound
	[5] = {127, 164, 114},	--Stormsong
	[6] = {156, 165, 153},	--Drustvar
	[7] = { 42,  63,  79},	--Halls of Shadow

    --Major City--
    --[UiMapID] = {r, g, b}
    [84]  = {129, 144, 155},	--Stormwind City
    
	[85]  = {121,  52,  55},	--Orgrimmar
    [86]  = {121,  31,  35},	--Orgrimmar - Cleft of Shadow
    [463] = {163,  99,  89},	--Echo Isles
    
    [87]  = {102,  64,  58},	--Ironforge
    [27]  = {151, 198, 213},	--Dun Morogh
    [469] = {151, 198, 213},	--New Tinkertown
    
    [88]  = {115, 140, 113},	--Thunder Bluff
    
    [89]  = {121,  31,  35},	--Darnassus	R.I.P.
    
    [90]  = { 42,  63,  79},	--Undercity

    [110] = {172,  58,  54},    --Silvermoon City

    [202]  = {78,  78,  78},    --Gilneas City
    [217]  = {78,  78,  78},    --Ruins of Gilneas
    [627] = {102,  58,  64},	--Dalaran  	Broken Isles
    [111] = {88,  108,  91},	--Shattrath City

    -- TBC --
    [107] = {181,  151, 93},	--Nagrand Outland
    [109] = {96,   48, 108},	--Netherstorm
    [102] = {61,   77, 162},	--Zangarmash
    [105] = {123, 104,  80},	--Blade's Edge Mountains

    -- MOP --
    [378] = {120, 107,  81},	--The Wandering Isle
    [371] = { 95, 132,  78},    --The Jade Forrest
    [379] = { 90, 119, 156},    --Kun-Lai Summit

    -- LEG --
    [641] = { 70, 128, 116},    --Val'sharah

    -- BFA --
    [81]  = { 98,  84,  77},    --Silithus
    [1473]= {168, 136,  90},    --Chamber of Heart
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

    [249]  = {180,149, 121},    --Uldum Normal
    [1527] = {180,149, 121},    --Uldum Assault
    [390]  = {150, 117, 94},    --Eternal Blossoms Normal
    [1530] = {150, 117, 94},    --Eternal Blossoms Assault
    ["NZ"] = {105, 71, 156},    --During Assault: N'Zoth Purple Skybox

    [1580] = {105, 71, 156},    --Ny'alotha - Vision of Destiny
    [1581] = {105, 71, 156},    --Ny'alotha - Annex of Prophecy
    [1582] = {105, 71, 156},    --Ny'alotha - Ny'alotha
    [1590] = {105, 71, 156},    --Ny'alotha - The Hive
    [1591] = {105, 71, 156},    --Ny'alotha - Terrace of Desolation
    [1592] = {105, 71, 156},    --Ny'alotha - The Ritual Chamber
    [1593] = {105, 71, 156},    --Ny'alotha - Twilight Landing
    [1594] = {105, 71, 156},    --Ny'alotha - Maw of Gor'ma
    [1595] = {105, 71, 156},    --Ny'alotha - Warren of Decay
    [1596] = {105, 71, 156},    --Ny'alotha - Chamber of Rebirth
    [1597] = {105, 71, 156},    --Ny'alotha - Locus of Infinite Truths

    --Allied Race Starting Zone--
    [124]  = {87,  56, 132},    --DK
    [1186] = {117,  26, 22},    --Dark Iron
    [971]  = {65, 57, 124},     --Void Elf

    --Class Hall
	[625] = { 42,  63,  79},	--Dalaran, Broken Isles  Halls of Shadow
    [626] = { 42,  63,  79},	--Hall of Shadow
    [715] = {149, 180, 146},    --Emerald Dreamway
    [747] = { 70, 128, 116},    --The Dreamgrove

    --Frequently Visited
    [198]  = {78,  78,  78},    --Hyjal
};

-- 8.3 When Assault: N'Zoth is active, the map uses a different skybox (purple). This quest's location alters every week, so we need to re-index a color preset during the login
local AssignColor = CreateFrame("Frame");
AssignColor:RegisterEvent("PLAYER_ENTERING_WORLD");
AssignColor:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    After(2, function()
        local tag;
        tag = HasQuestCompleted(57566);           --N'Zoth Assault Tracker (Uldum)    --/dump C_QuestLog.IsQuestFlaggedCompleted(57566)
        if tag then
            Narci_ColorTable[1527] = {105, 71, 156};
            --print("N'Zoth in Uldum")
        else
            tag = HasQuestCompleted(57567);       --N'Zoth Assault Tracker (Vale)
            if tag then
                Narci_ColorTable[1530] = {105, 71, 156};
            end
        end
    end)
end);
----------------------------------------------------------------------

Narci_FontColor = {
    ["Brown"] = {0.85098, 0.80392, 0.70588, "|cffd9cdb4"},
    ["DarkGrey"] = {0.42, 0.42, 0.42, "|cff6b6b6b"},
    ["LightGrey"] = {0.72, 0.72, 0.72, "|cffb8b8b8"},
    ["White"] = {0.88, 0.88, 0.88, "|cffe0e0e0"},
    ["Good"] = {0.4862, 0.7725, 0.4627, "|cff7cc576"},
    ["Bad"] = {1, 0.3137, 0.3137, 0.3137, "|cffff5050"},
    ["Corrupt"] = {0.584, 0.428, 0.82, "|cff946dd1"},
};

local BorderTexture = {
    ["Bright"]  = {
        [0] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Black",
        [1] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder",
        [2] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Uncommon",
        [3] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Rare",
        [4] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Epic",   --Epic NZoth
        [5] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Legendary",
        [6] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Artifact",
        [7] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Heirloom",	--Void
        [8] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Azerite",
        [12] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Special",
        ["Heart"] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-Heart",    --Heart
        ["NZoth"] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-NZoth",
        ["BlackDragon"] = "Interface/AddOns/Narcissus/Art/Border/HexagonBorder-BlackDragon",    --8.3 Legendary Cloak
        ["Minimap"] = "Interface/AddOns/Narcissus/Art/Minimap/LOGO-Large",
    },

    ["Dark"] = {
        [0] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        [1] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        [2] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Uncommon",
        [3] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Rare",
        [4] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Epic",    --Epic
        [5] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Legendary",
        [6] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Artifact",
        [7] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Heirloom",	--Void
        [8] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Azerite",
        [12] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Black",
        ["Heart"] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-Heart",    --Heart
        ["NZoth"] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-NZoth",
        ["BlackDragon"] = "Interface/AddOns/Narcissus/Art/Border-Thick/HexagonThickBorder-BlackDragon",    --8.3 Legendary Cloak
        ["Minimap"] = "Interface/AddOns/Narcissus/Art/Minimap/LOGO-Large",                                --only enable Thick minimap when AzeriteUI is loaded
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

local function IsHeritageArmor(itemID)
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

    if IsHeritageArmor(itemID) then
        return true, HERITAGE_ARMOR;
    end

    local itemSource = SpecialItemList[itemID];
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
local DoesItemExist = C_Item.DoesItemExist;
local GetCurrentItemLevel = C_Item.GetCurrentItemLevel;
local GetItemLink = C_Item.GetItemLink
local GetItemStats = GetItemStats;

function NarciAPI_GetItemStats(itemLocation)
    local statsTable = {};
    statsTable.gems = 0;
    if not itemLocation or not DoesItemExist(itemLocation) then
        statsTable.prim = 0;
        statsTable.stamina = 0;
        statsTable.crit = 0;
        statsTable.haste = 0;
        statsTable.mastery = 0;
        statsTable.versatility = 0;
        statsTable.corruption = 0;
        statsTable.GemIcon = "";
        statsTable.GemPos = "";
        statsTable.EnchantPos = "";
        statsTable.EnchantSpellID = nil;
        statsTable.ilvl = 0;
        return statsTable;
    end

    local ItemLevel = GetCurrentItemLevel(itemLocation)
    local itemLink = GetItemLink(itemLocation)
    local stats = GetItemStats(itemLink) or {};
    local prim = stats["ITEM_MOD_AGILITY_SHORT"] or stats["ITEM_MOD_STRENGTH_SHORT"] or stats["ITEM_MOD_INTELLECT_SHORT"] or 0;
    local stamina = stats["ITEM_MOD_STAMINA_SHORT"] or 0;
    local crit = stats["ITEM_MOD_CRIT_RATING_SHORT"] or 0;
    local haste = stats["ITEM_MOD_HASTE_RATING_SHORT"] or 0;
    local mastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0;
    local versatility = stats["ITEM_MOD_VERSATILITY"] or 0;
    local corruption = stats["ITEM_MOD_CORRUPTION"] or 0;

    statsTable.prim = prim;
    statsTable.stamina = stamina;
    statsTable.crit = crit;
    statsTable.haste = haste;
    statsTable.mastery = mastery;
    statsTable.versatility = versatility;
    statsTable.corruption = corruption;
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

function NarciAPI_GetItemStatsFromSlot(slotID)
    local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID);
    local itemLink = C_Item.GetItemLink(itemLocation)
    return GetItemStats(itemLink);
end

--------------------
----Tooltip Scan----
--------------------

local TP = CreateFrame("GameTooltip", "NarciVirtualTooltip", nil, "GameTooltipTemplate");
TP:SetScript("OnLoad", GameTooltip_OnLoad);
TP:SetOwner(UIParent, 'ANCHOR_NONE');

local SocketAction = ITEM_SOCKETABLE;
local find = string.find;
local SocketPath = "ItemSocketingFrame";
function NarciAPI_IsItemSocketable(itemLink, SocketID)
    if not itemLink then return; end
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
        if texID == 458977 then     --no file name anymore 458977:Regular empty socket texture
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

function NarciAPI_GetItemRank(itemLink, statName)
    --Items that can get upgraded
    if not itemLink then return; end
    
    TP:SetHyperlink(itemLink);
    local fontstring = _G["NarciVirtualTooltip".."TextLeft"..2];
    fontstring = fontstring:GetText() or "";
    fontstring = strtrim(fontstring, "|r");
    local rank = string.match(fontstring, "%d+", -2) or "";

    if statName then
        local stats = GetItemStats(itemLink) or {};
        return "|cff00ccff"..rank.."|r", stats[statName] or 0
    else
        return "|cff00ccff"..rank.."|r"
    end
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
    if not itemID then return; end
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

function TestItemLinkAffix(from, to)
    local TP = TP;
    local max = max;
    local total = 0;
    local s = from  --6500;
    local e = to    --6600;
    local output;
    local itemLink;
    local function GetExtraInfo()
        itemLink = "\124cffa335ee\124Hitem:174954::::::::120::::2:1477:".. s ..":\124h[]\124h\124r";
        TP:SetHyperlink(itemLink);
        local num = TP:NumLines();
        local begin = max(num - 3, 0);
        local str;
    
        for i = begin, num, 1 do
            str = nil;
            str = _G["NarciVirtualTooltip".."TextLeft"..i]
            if not str then
                break;
            else
                str = str:GetText();
            end
            
            if find(str, onEquip) then
                print("|cFFFFD100"..s.."|r "..str);
                break
            end
        end

        s = s + 1;
        total = total + 1;
        if s < e and total < 1000 then
            After(0, GetExtraInfo);
        else
            print("Search Complete")
        end
    end

    print("Search from "..s.." to "..e);
    for i = s, e do
        --Cache
        itemLink = "\124cffa335ee\124Hitem:174954::::::::120::::2:1477:".. i ..":\124h[]\124h\124r";
        TP:SetHyperlink(itemLink);
    end
    After(1, GetExtraInfo);
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
NarciUIMixin = {};

function NarciUIMixin:Highlight(state)
    if state then
        self.Border.Highlight:SetAlpha(1);
        self.Border.Normal:SetAlpha(0);
    else
        self.Border.Highlight:SetAlpha(0);
        self.Border.Normal:SetAlpha(1);
    end
end

function NarciUIMixin:SetColor(r, g, b)
    if self.Color then
        self.Color:SetColorTexture(r/255, g/255, b/255);
    end
end

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

local OptimizeBorderThickness = NarciAPI_OptimizeBorderThickness;

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


--Internal Keybinding
NarciGenericKeyBindingButtonMixin = {};

local function ResetBindVisualAndScript(self)
    self.Border:SetColorTexture(0, 0, 0);
    self.Value:SetTextColor(1, 1, 1);
    self.Value:SetShadowColor(0, 0, 0);
    self.Value:SetShadowOffset(0.6, -0.6);
    self:SetPropagateKeyboardInput(true)
    self:SetScript("OnKeyDown", nil); 
    --self:SetScript("OnKeyUp", nil);
    self.IsOn = false;
end

local function GenericKeyBindingButton_OnKeydown(self, key)
    if key == "ESCAPE" or key == "SPACE" or key == "ENTER" then
        self:ExitKeyBinding();
        return
    end

    if self.keyValue then
        self:ExitKeyBinding(true);
        NarcissusDB[self.keyValue] = key;
    end
end

function NarciGenericKeyBindingButtonMixin:ExitKeyBinding(success)
    ResetBindVisualAndScript(self);
    After(0, function()
        self:GetBindingKey();
    end)
    if success then
        self.Highlight:SetColorTexture(0.4862, 0.7725, 0.4627);
        self.Description:SetText("|cff7cc576".. KEY_BOUND);
        UIFrameFadeIn(self.Highlight, 0.2, 0, 1);
        UIFrameFadeIn(self.Description, 0.2, 0, 1);
        self.Timer:Stop();
        self.Timer:SetScript("OnFinished", function()
            UIFrameFadeOut(self.Highlight, 0.5, 1, 0);
            UIFrameFadeOut(self.Description, 0.5, 1, 0);
        end);
        self.Timer:Play();
    end
end

function NarciGenericKeyBindingButtonMixin:GetBindingKey()
    OptimizeBorderThickness(self);
    if self.keyValue then
        self.Value:SetText(NarcissusDB[self.keyValue] or NOT_BOUND);
    else
        self.Value:SetText(NARCI_COLOR_RED_MILD.. "No Action");
    end
end

function NarciGenericKeyBindingButtonMixin:ReleaseBindingKey()
    ResetBindVisualAndScript(self);
    if self.keyValue then
        self.Value:SetText(self.defaultKey or NOT_BOUND);
        NarcissusDB[self.keyValue] = self.defaultKey;
        self.Highlight:SetColorTexture(0.9333, 0.1961, 0.1412);
        self.Description:SetText(NARCI_COLOR_RED_MILD.."Hotkey reset");
        UIFrameFadeIn(self.Description, 0.2, 0, 1);
        UIFrameFadeIn(self.Highlight, 0.2, 0, 1);
        self.Timer:Stop();
        self.Timer:SetScript("OnFinished", function()
            UIFrameFadeOut(self.Highlight, 0.5, 1, 0);
            UIFrameFadeOut(self.Description, 0.5, 1, 0);
        end);
        self.Timer:Play();
    end
end

function NarciGenericKeyBindingButtonMixin:OnClick(button)
    self.IsOn = not self.IsOn;

    if button == "LeftButton" then
        if self.IsOn then
            self.Border:SetColorTexture(0.9, 0.9, 0.9);
            self.Value:SetTextColor(0, 0, 0);
            self.Value:SetShadowColor(1, 1, 1);
            self.Value:SetShadowOffset(0.6, -0.6);
            self:SetPropagateKeyboardInput(false);
            self:SetScript("OnKeyDown", GenericKeyBindingButton_OnKeydown);
        end
    else
        self:ReleaseBindingKey();
    end
end

function NarciGenericKeyBindingButtonMixin:OnHide()
    self:StopAnimating();
end

-----Smooth Scroll-----
local min = math.min;
local max = math.max;
local minOffset = 2;
local function SmoothScrollContainer_OnUpdate(self, elapsed)
	local delta = self.delta;
    local scrollBar = self.scrollBar;
    local value = scrollBar:GetValue();
    local step = max(abs(value - self.endValue)*(self.timeRatio) , self.minOffset);		--if the step (Δy) is too small, the fontstring will jitter.
    local remainedStep;
    if ( delta == 1 ) then
        --Up
        remainedStep = min(self.endValue - value, 0);
        if - remainedStep <= ( self.minOffset) then
            self:Hide();
            scrollBar:SetValue(min(self.maxVal, self.endValue));
        else
            scrollBar:SetValue(max(0, value - step));
        end
	else
        remainedStep = max(self.endValue - value, 0);
        if remainedStep <= ( self.minOffset) then
            self:Hide();
            scrollBar:SetValue(min(self.maxVal, self.endValue));
        else
            scrollBar:SetValue(min(self.maxVal, value + step));
        end
    end
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
    local endValue = min(max(0, ScrollContainer.endValue - delta*deltaRatio*self.buttonHeight), self.range);
    ScrollContainer.endValue = endValue;
    if self.positionFunc then
        self.positionFunc(endValue);
    end
end

function NarciAPI_SmoothScroll_Initialization(self, updatedList, updateFunc, deltaRatio, timeRatio, minOffset, positionFunc)     --self=ListScrollFrame
    self.update = updateFunc;
    self.positionFunc = positionFunc;
    self.updatedList = UpdatedList;

    local parentName = self:GetName();
    local frameName = parentName and (parentName .. "SmoothScrollContainer") or nil;
    
    local SmoothScrollContainer = CreateFrame("Frame", frameName, self);
    SmoothScrollContainer:Hide();
    
    local scale = string.match(GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" );
    local uiScale = self:GetEffectiveScale(); 
    --local pixel = 768/scale/uiScale;
    --local _, screenHeight = GetPhysicalScreenSize();
    local pixel = (768/screenHeight)/uiScale;
    self.scrollBar:SetValueStep(0.001);
    SmoothScrollContainer.stepSize = 0;
    SmoothScrollContainer.delta = 0;
    SmoothScrollContainer.animationDuration = 0;
    SmoothScrollContainer.endValue = 0;
	SmoothScrollContainer.maxVal = 0;
    SmoothScrollContainer.deltaRatio = deltaRatio or 1;
    SmoothScrollContainer.timeRatio = timeRatio or 1;
    SmoothScrollContainer.minOffset = minOffset or pixel;
    SmoothScrollContainer.scrollBar = self.scrollBar;
    SmoothScrollContainer:SetScript("OnUpdate", SmoothScrollContainer_OnUpdate);
    SmoothScrollContainer:SetScript("OnShow", function(self)
        self.endValue = self:GetParent().scrollBar:GetValue();
    end);

    self.SmoothScrollContainer = SmoothScrollContainer;

    self:SetScript("OnMouseWheel", NarciAPI_SmoothScroll_OnMouseWheel);  --a position-related function
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
            Narci_PhotoModeController.PhotoModeController_AnimFrame.toAlpha = 0
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
            NarciGameTooltip:ClearAllPoints();
            NarciGameTooltip:SetPoint(self.point, self.relativeTo, self.relativePoint, self.ofsx, self.ofsy);
            UIFrameFadeIn(NarciGameTooltip, 0.12, 0, 1);
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

-----Run Delayed Function-----
local DelayedFunc = CreateFrame("Frame");
DelayedFunc:Hide();
DelayedFunc.delay = 0;
DelayedFunc.t = 0;

DelayedFunc:SetScript("OnHide", function(self)
    self.focus = nil;
    self.t = 0;
end)

DelayedFunc:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= self.delay then
        if self.focus == GetMouseFocus() then
            self.func();
        end
        self:Hide();
    end
end)

function NarciAPI_RunDelayedFunction(frame, delay, func)
    DelayedFunc:Hide();
    if func and type(func) == "function" then
        delay = delay or 0;
        DelayedFunc.focus = frame;
        DelayedFunc.delay = delay;
        DelayedFunc.func = func;
        DelayedFunc:Show();
    end
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

    After(0.5, function()
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



------------------------
--Filled Bar Animation--
------------------------
local cos = math.cos;
local pi = math.pi;
local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

local FluidAnim = CreateFrame("Frame");
FluidAnim:Hide();
FluidAnim.d = 0.5;
FluidAnim.d1 = 0.25;
FluidAnim.d2 = 0.5;

local function FluidLevel(self, elapsed)
	self.t = self.t + elapsed;
	local height = inOutSine(self.t, self.startHeight, self.endHeight - self.startHeight, self.d);
	if self.t >= self.d then
		height = self.endHeight;
		self:Hide();
	end
	self.Fluid:SetHeight(height);
end

local function FluidUp(self, elapsed)
	self.t = self.t + elapsed;
	local height;
	if self.t <= self.d1 then
		height = inOutSine(self.t, self.startHeight, 84 - self.startHeight, self.d1);
    elseif self.t < self.d3 then
        if not self.colorChanged then
            self.colorChanged = true;
            self.Fluid:SetColorTexture(self.r, self.g, self.b);
        end
		height = inOutSine(self.t - self.d1, 0.01, self.endHeight, self.d2);
	else
		height = self.endHeight;
		self:Hide();
	end
	self.Fluid:SetHeight(height);
end

local function FluidDown(self, elapsed)
	self.t = self.t + elapsed;
	local height;
	if self.t <= self.d1 then
		height = inOutSine(self.t, self.startHeight, 0.01 - self.startHeight, self.d1);
    elseif self.t < self.d3 then
        if not self.colorChanged then
            self.colorChanged = true;
            self.Fluid:SetColorTexture(self.r, self.g, self.b);
        end
		height = inOutSine(self.t - self.d1, 84, self.endHeight - 84, self.d2);
	else
		height = self.endHeight;
		self:Hide();
	end
	self.Fluid:SetHeight(height);
end

FluidAnim:SetScript("OnShow", function(self)
    self.t = 0;
    self.colorChanged = false;
end);

function NarciAPI_SmoothFluid(bar, newHeight, newLevel, r, g, b)
	local FluidAnim = FluidAnim;
	FluidAnim:Hide();
    FluidAnim.endHeight = newHeight;
    FluidAnim.Fluid = bar;
    FluidAnim.r, FluidAnim.g, FluidAnim.b = r, g, b;

	local oldLevel = FluidAnim.oldCorruptionLevel or newLevel;
	FluidAnim.oldCorruptionLevel = newLevel;

	local t1, t2;
	local h = FluidAnim.Fluid:GetHeight();
	FluidAnim.startHeight = h;

	if newLevel == oldLevel then
		FluidAnim:SetScript("OnUpdate", FluidLevel);
        FluidAnim.d = math.max( math.abs(h - FluidAnim.endHeight) / 84 , 0.35); 
        bar:SetColorTexture(r, g, b);
	elseif newLevel < oldLevel then
		FluidAnim:SetScript("OnUpdate", FluidDown);
		t1 = math.max(h / 84, 0);
		t2 = math.max((84 - FluidAnim.endHeight) / 84, 0.4);
		FluidAnim.d1 = t1
		FluidAnim.d2 = t2
		FluidAnim.d3 = t1 + t2;
	else
		FluidAnim:SetScript("OnUpdate", FluidUp);
		t1 = math.max((84 - h) / 84, 0);
		t2 = math.max(FluidAnim.endHeight / 84, 0.4);
		FluidAnim.d1 = t1
		FluidAnim.d2 = t2
		FluidAnim.d3 = t1 + t2;
	end
	
	After(0, function()
		FluidAnim:Show();
	end)

	return t1
end


local EyeballTexture = "Interface\\AddOns\\Narcissus\\ART\\Widgets\\CorruptionSystem\\Eyeball-Orange";
local CorruptionColor = "|cfff57f20";
local FluidColors = {0.847, 0.349, 0.145};
        
function NarciAPI_GetEyeballColor()
    return EyeballTexture, CorruptionColor, FluidColors[1], FluidColors[2], FluidColors[3];
end

function NarciAPI_SetEyeballColor(index)
    if index == 4 then
        EyeballTexture = "Interface\\AddOns\\Narcissus\\ART\\Widgets\\CorruptionSystem\\Eyeball-Blue";
        CorruptionColor = "|cff83c7e7";
        FluidColors = {0.596, 0.73, 0.902};
    elseif index == 2 then
        EyeballTexture = "Interface\\AddOns\\Narcissus\\ART\\Widgets\\CorruptionSystem\\Eyeball-Purple";
        CorruptionColor = "|cfff019ff";
        FluidColors = {0.87, 0.106, 0.949};
    elseif index == 3 then
        EyeballTexture = "Interface\\AddOns\\Narcissus\\ART\\Widgets\\CorruptionSystem\\Eyeball-Green";
        CorruptionColor = "|cff8cdacd";
        FluidColors = {0.56, 0.855, 0.757};
    else
        index = 1;
        EyeballTexture = "Interface\\AddOns\\Narcissus\\ART\\Widgets\\CorruptionSystem\\Eyeball-Orange";
        CorruptionColor = "|cfff57f20";
        FluidColors = {0.847, 0.349, 0.145};
    end

    NarcissusDB.EyeColor = index;
    local Preview = Narci_EyeColorPreview;
    local ColorButtons = Preview:GetParent().ColorButtons;
    Preview:SetTexCoord(0.25*(index - 1), 0.25*index, 0, 1);
    for i = 1, #ColorButtons do
        ColorButtons[i]:Highlight(false);
    end
    ColorButtons[index]:Highlight(true);

    Narci:SetItemLevel();
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

local ActorIDByRace = {
    --local GenderID = UnitSex(unit);   2 Male 3 Female
	--[raceID] = {male actorID, female actorID, bustOffsetZ_M, bustOffsetZ_F},
    [2]  = {483, 483},		-- Orc bow
    [3]  = {471, nil},		-- Dwarf
    [5]  = {472, 487},		-- UD   0.9585 seems small
    [6]  = {449, 484},		-- Tauren
    [7]  = {450, 450},		-- Gnome
    [8]  = {485, 486},		-- Troll  0.9414 too high?  
    [9]  = {476, 477},		-- Goblin
    [11] = {475, 501},		-- Goat
    [22] = {474, 500},      -- Worgen
    [24] = {473, 473},		-- Pandaren
    [28] = {490, 491},		-- Highmountain Tauren
    [30] = {488, 489},		-- Lightforged Draenei
    [31] = {492, 492},		-- Zandalari
    [32] = {494, 497},		-- Kul'Tiran
    [34] = {499, nil},		-- Dark Iron Dwarf
    [35] = {924, 923},      -- Vulpera
    [36] = {495, 498},		-- Mag'har
    [37] = {929, 931},      -- Mechagnome
}

local ZoomDistanceByRace = {
    --[raceID] = {male Zoom, female Zoom, bustOffsetZ_M, bustOffsetZ_F},
    [1]  = {2.4, 2},		-- Human
    [2]  = {2.5, 2},		-- Orc bow
    [3]  = {2.5, 2},		-- Dwarf
    [4]  = {2.2, 2.1},      -- Night Elf
    [5]  = {2.5, 2},		-- UD
    [6]  = {3, 2.5},		-- Tauren
    [7]  = {2.6, 2.8},		-- Gnome
    [8]  = {2.5, 2},		-- Troll
    [9]  = {2.9, 2.9},		-- Goblin
    [10] = {2, 2},          -- Blood Elf
    [11] = {2.4, 2},		-- Goat
    [22] = {2.8, 2},        -- Worgen
    [24] = {2.9, 2.4},		-- Pandaren
    [27] = {2, 2},		-- Nightborne
    --[29] = {2, 2},            -- Void Elf
    --[28] = {2, 2},		-- Highmountain Tauren
    --[30] = {2, 2},		-- Lightforged Draenei
    [31] = {2.2, 2},		-- Zandalari
    [32] = {2.4, 2.3},		-- Kul'Tiran
    --[34] = {2, 2},		-- Dark Iron Dwarf
    [35] = {2.6, 2.1},      -- Vulpera
    --[36] = {2, 2},		-- Mag'har
    --[37] = {2, 2},      -- Mechagnome
}

function NarciAPI_GetCameraZoomDistanceByUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not CanInspect(unit, false) then return; end
    
    local _, _, raceID = UnitRace(unit);
    local genderID = UnitSex(unit);
    if raceID == 25 or raceID == 26 then --Pandaren A|H
        raceID = 24;
    elseif raceID == 29 then
        raceID = 10;
    elseif raceID == 37 then
        raceID = 7;
    elseif raceID == 30 then
        raceID = 11;
    elseif raceID == 28 then
        raceID = 6;
    elseif raceID == 34 then
        raceID = 3;
    elseif raceID == 36 then
        raceID = 2;
    elseif raceID == 22 then
        if unit == "player" then
            local _, inAlternateForm = HasAlternateForm();
            if not inAlternateForm then
                --Wolf
                raceID = 22;
            else
                raceID = 1;
            end
        end
    end
    if not (raceID and genderID) then
        return 2
    elseif ZoomDistanceByRace[raceID] then
        return ZoomDistanceByRace[raceID][genderID - 1] or 2;
    else
        return 2
    end
end

local DEFAULT_ACTOR_INFO_ID = 438;

local PanningYOffsetByRace = {
    --[raceID] = { { male = {offsetY1 when frame maximiazed, offsetY2} }, {female = ...} }
    [0] = {     --default
        {-290, -110},
    },

    [4] = { --NE
        {-317, -117},
        {-282, -115.5},
    },

    [10] = {    --BE
        {-282, -110},
        {-290, -116}, 
    }
    --/dump DressUpFrame.ModelScene:GetActiveCamera().panningYOffset
}

PanningYOffsetByRace[29] = PanningYOffsetByRace[10];

local function GetPanningYOffset(raceID, genderID)
    genderID = genderID -1;
    if PanningYOffsetByRace[raceID] and PanningYOffsetByRace[raceID][genderID] then
        return PanningYOffsetByRace[raceID][genderID]
    else
        return PanningYOffsetByRace[0][1]
    end
end

local GetModelSceneActorInfoByID = C_ModelInfo.GetModelSceneActorInfoByID;

function NarciAPI_GetActorInfoByUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) or not CanInspect(unit, false) then return nil, PanningYOffsetByRace[0][1]; end
    
    local _, _, raceID = UnitRace(unit);
    local genderID = UnitSex(unit);
    if raceID == 25 or raceID == 26 then --Pandaren A|H
        raceID = 24
    end

    local actorInfoID;
    if not (raceID and genderID) then
        actorInfoID = DEFAULT_ACTOR_INFO_ID;     --438
    elseif ActorIDByRace[raceID] then
        actorInfoID = ActorIDByRace[raceID][genderID - 1] or DEFAULT_ACTOR_INFO_ID;
    else
        actorInfoID = DEFAULT_ACTOR_INFO_ID;     --438
    end

    return GetModelSceneActorInfoByID(actorInfoID), GetPanningYOffset(raceID, genderID)
end



function NarciAPI_SetupModelScene(modelScene, modelFileID, zoomDistance, view, actorIndex, UseTransit)
    local pi = math.pi;
    local model = modelScene;

    local actorTag;
    if not actorIndex then
        actorTag = "narciEffectActor";
    else
        actorTag = "narciEffectActor"..actorIndex
    end

    local actor = model[actorTag];

    if not actor then
        local actorID = 156;    --effect    C_ModelInfo.GetModelSceneActorInfoByID(156)
        local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(actorID);
        actor = model:AcquireAndInitializeActor(actorInfo);
        actor:SetYaw(pi);
        model[actorTag] = actor;

        local parentFrame = model:GetParent();
        if parentFrame then
            model:SetFrameLevel(parentFrame:GetFrameLevel() + 1 or 20);
        else
            model:SetFrameLevel(20);
        end
    end
    
    local cameraTag = "NarciUI";
    local camera = model.narciCamera;
    if not camera then
        camera = CameraRegistry:CreateCameraByType("OrbitCamera");
        if camera then
            model.narciCamera = camera;
            model:AddCamera(camera);
            local modelSceneCameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(114);
            camera:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, 1, 1);    --1 ~ CAMERA_TRANSITION_TYPE_IMMEDIATE / CAMERA_MODIFICATION_TYPE_DISCARD
        end
    end

    model:SetActiveCamera(camera);

    if modelFileID then
        actor:SetModelByFileID(modelFileID);
    end
    
    if zoomDistance then
        if UseTransit then
            --change camera.targetInterpolationAmount for smoothing time    --:GetTargetInterpolationAmount() :SetTargetInterpolationAmount(value)
            camera:SetZoomDistance(1);
            camera:SnapAllInterpolatedValues();
            After(0, function()
                camera:SetZoomDistance(zoomDistance);
            end);    
        else
            camera:SetZoomDistance(zoomDistance);
            camera:SynchronizeCamera();
        end
    end

    if view then
        local pitch, yaw;
        if type(view) == "string" then
            view = strupper(view);
            if view == "FRONT" then
                pitch = 0;
                yaw = pi;
            elseif view == "BACK" then
                pitch = 0;
                yaw = 0;
            elseif view == "TOP" then
                pitch = pi/2;
                yaw = pi; 
            elseif view == "BOTTOM" then
                pitch = -pi/2;
                yaw = pi;
            elseif view == "LEFT" then
                pitch = 0;
                yaw = -pi/2;  
            elseif view == "RIGHT" then
                pitch = 0;
                yaw = pi/2;
            else
                return;                    
            end
        elseif type(view) == "table" then
            pitch = view[1];
            yaw = view[2];
            if not (pitch and yaw) then
                return;
            end
        end

        actor:SetPitch(pitch);
        actor:SetYaw(yaw);
    end

    return actor, camera
    --[[
    if rollDegree then
        actor:SetRoll(rad(-rollDegree))     --Clockwise
    end
    --]]
end

local function ReAnchorFrame(frame)
    --maintain frame top position when changing its height
    local oldCenterX = frame:GetCenter();
    --local oldBottom = frame:GetBottom();
    local oldTop = frame:GetTop();
    local screenWidth = WorldFrame:GetWidth();
    local screenHeight = WorldFrame:GetHeight();
    local scale = frame:GetEffectiveScale();
    if not scale or scale == 0 then
        scale = 1;
    end
    local width = frame:GetWidth()/2;
    frame:ClearAllPoints();
    --frame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", oldCenterX + width - screenWidth / scale , oldBottom);
    frame:SetPoint("TOPRIGHT", nil, "TOPRIGHT", oldCenterX + width - screenWidth / scale , oldTop - screenHeight/scale);
end

local function ParserButton_ShowTooltip(self)
    if self.itemLink and not CursorHasItem() then
        local frame =self:GetParent();
        local TP = frame.tooltip;
        --GameTooltip_SetBackdropStyle(TP, GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM);
        TP:SetBackdrop(nil);
        TP:SetOwner(self, "ANCHOR_NONE");
        TP:SetPoint("TOP", frame.ItemString, "BOTTOM", 0, -14);
        TP:SetHyperlink(self.itemLink);
        TP:SetMinimumWidth(254 / 0.8);
        TP:Show();
        frame:SetHeight( math.max (math.floor(TP:GetHeight() - 260), 0) + 400);
        ReAnchorFrame(frame);
    end
end

local function ParserButton_GetCursor(self)
    local infoType, itemID, itemLink = GetCursorInfo();
    self.Highlight:Hide()

    if not (infoType and infoType == "item") then
        return
    elseif not IsCorruptedItem(itemLink) then
        local frame = self:GetParent();
        frame.ItemName:SetText("Not a Corrupted Item");
        local itemString = string.match(itemLink, "item:([%-?%d:]+)");
        frame.ItemString:SetText(itemString);

        After(2, function()
            frame.ItemName:SetText("Drop a Corrupted Item Here");
        end);
        ClearCursor();
        return
    end
    ClearCursor();
    self.itemLink = itemLink;

    local itemName, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc, itemIcon = GetItemInfo(itemLink);
    local itemString = string.match(itemLink, "item:([%-?%d:]+)");
    local supposedEffect, corruptionID = NarciAPI_GetCorruptedItemAffix(itemLink);
    local hasGem = NarciAPI_IsItemSocketable(itemLink);
    local enchantID = GetItemEnchant(itemLink);
    local corruption = GetItemStats(itemLink)["ITEM_MOD_CORRUPTION"] or 0;
    local _, extraEffect = NarciAPI_GetItemExtraEffect(itemLink);
    local r, g, b = GetItemQualityColor(itemQuality);
    local HEX_PURPLE = "|c"..CORRUPTION_COLOR:GenerateHexColor();

    if extraEffect then
        extraEffect = HEX_PURPLE.. extraEffect
    end

    if supposedEffect then
        supposedEffect = supposedEffect.."  ".."|cff946dd1"..corruption.."|r";
    else
        supposedEffect = "|cff946dd1"..corruption.."|r";
    end

    if hasGem then
        supposedEffect = supposedEffect.."  ".."|cff40C7ebSocket|r"
    end

    local enchantName;
    local colorizedString = itemString;
    if enchantID and enchantID ~= 0 then
        local GREEN = "|cff1eff00";
        local info = Narci_EnchantInfo[enchantID];
        if info then
            enchantName = string.gsub(info[1], "%a", string.upper, 1).." "..info[2];
            supposedEffect = supposedEffect.."  "..GREEN..enchantName.."|r";
        end
        colorizedString = string.gsub(itemString, enchantID, GREEN..enchantID.."|r", 1);
    end

    if corruptionID then
        colorizedString = string.gsub(colorizedString, corruptionID, HEX_PURPLE..corruptionID.."|r", 1);
    end

    --Show info
    self.ItemIcon:SetTexture(itemIcon);
    local frame = self:GetParent();
    frame.ItemName:SetText(supposedEffect);
    frame.ItemName:SetTextColor(r, g, b);
    frame.ItemString:SetText(colorizedString);
    frame.SupposedEffect:SetText(supposedEffect);
    frame.ActualEffect:SetText(extraEffect);

    frame.Pointer:Hide();

    ParserButton_ShowTooltip(self)
end



function Narci_ItemParser_OnLoad(self)
    self:SetUserPlaced(false)
    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    self:RegisterForDrag("LeftButton");
    self:SetScript("OnShow", ReAnchorFrame);
    self.ItemButton:SetScript("OnReceiveDrag", ParserButton_GetCursor);
    self.ItemButton:SetScript("OnClick", ParserButton_GetCursor);
    self.ItemButton:SetScript("OnEnter", ParserButton_ShowTooltip);

    local locale = GetLocale();
    local version, build, date, tocversion = GetBuildInfo();

    self.ClientInfo:SetText(locale.."  "..version.."."..build.."  "..NARCI_VERSION_INFO);

    local TP = CreateFrame("GameTooltip", "Narci_ItemParserTooltip", self, "GameTooltipTemplate");
    TP:Hide();
    self.tooltip = TP;

    local scale = 0.8;
    local tooltipScale = 0.8;
    self:SetScale(0.8);
    TP:SetScale(tooltipScale);
end

-----------------
-----Utility-----
-----------------
local DistanceCalculator;
local MovementListener;

function NarciAPI_ActivateDistanceCalculator(calibrateDistance)
    if not DistanceCalculator then
        --Timer frame
        DistanceCalculator = CreateFrame("Frame");
        DistanceCalculator:Hide();
        DistanceCalculator.basicSpeed = 0;

        local function OnUpdate(self, elapsed)
            self.t = self.t + elapsed;
        end

        DistanceCalculator:SetScript("OnShow", function(self)
            self.t = 0;
        end);

        DistanceCalculator:SetScript("OnHide", function(self)
            print(self.t);
            if self.basicSpeed > 0 then
                local d = self.basicSpeed * self.t;
                d = math.floor(d * 100 + 0.5) / 100;
                print("|cffFFF569"..d.." yd|r");
            elseif self.t > 0.2 then
                if self.calibrateDistance then
                    self.basicSpeed = self.calibrateDistance / self.t;
                    self.calibrateDistance = nil;
                    print("Speed: ".. math.floor(self.basicSpeed * 100 + 0.5) / 100 .. " yd/s" );
                else
                    print("Speed Not Calibrated");
                end
            end
            self.t = 0;
        end);

        DistanceCalculator:SetScript("OnUpdate", OnUpdate);

        --Event listener
        MovementListener = CreateFrame("Frame");
        MovementListener:Hide();

        MovementListener:SetScript("OnShow", function(self)
            self:RegisterEvent("PLAYER_STARTED_MOVING");
            self:RegisterEvent("PLAYER_STOPPED_MOVING");
        end);

        local function OnEvent(self, event)
            if event == "PLAYER_STARTED_MOVING" then
                DistanceCalculator:Show();
            else
                DistanceCalculator:Hide();
            end
        end

        MovementListener:SetScript("OnEvent", OnEvent);

        --Global
        function NarciAPI_DeactivateDistanceCalculator()
            MovementListener:Hide();
            DistanceCalculator:Hide();
        end
    end

    MovementListener:Show();

    if calibrateDistance and type(calibrateDistance) == "number" and calibrateDistance >= 5 then
        DistanceCalculator.basicSpeed = 0;
        DistanceCalculator.calibrateDistance = calibrateDistance;
    end
end

local Globals = {};
local totalGlobals = 1;
for k, v in pairs(_G) do
    Globals[totalGlobals] = k;
    totalGlobals = totalGlobals + 1;
end

local SEARCH_PER_FRAME = 240;
local numLoop = 0;
local numMatch = 0;
local function SearchLoop(b, key)
    local find = string.find;
    local index;
    for i = b, b + SEARCH_PER_FRAME  do
        if Globals[i] then
            index = i;

            if find(Globals[i], key) then
                numMatch = numMatch + 1;
                
                local t = type(_G[ Globals[i] ]);
                if t == "number" or t == "string" then
                    print("|cffffd200".. Globals[i].."|r = ".. (_G[Globals[i]] or "nil") );
                else
                    print("|cff808080"..t.." |cffffd200".. Globals[i]);
                end
            end
        else
            print("Search Completes ---------------")
            print("Found ".. "|cffffd200".. numMatch .. "|r matches.")
            numLoop = 0;
            return
        end
    end
    After(0, function()
        SearchLoop(b + SEARCH_PER_FRAME + 1, key)
    end)


    numLoop = numLoop + 1;
    if numLoop == 100 then
        numLoop = 0;
        print(math.floor(index / totalGlobals * 10000 + 0.5)/100 .. "% ----------------------------")
    end
end

function SearchGlobalString(key)
    if type(key) ~= "string" then
        print("The key must be a string!");
        return
    end
    numLoop = 0;
    numMatch = 0;
    local beginning = 1;
    SearchLoop(beginning, key)
end


----------------------------
-----Item Import/Export-----
----------------------------
local WOWHEAD_ENCODING = "0zMcmVokRsaqbdrfwihuGINALpTjnyxtgevElBCDFHJKOPQSUWXYZ123456789";  --version: 9    WH.calc.hash.getEncoding(9)
local WOWHEAD_DELIMITER = 8;                        --WH.calc.hash.getDelimiter(9)
local COMPRESSION_INDICATOR = 7;                    --WH.calc.hash.getZeroDelimiterCompressionIndicator(9) :7 + single letter
local WOWHEAD_MAXCODING_INDEX = 58                  --WH.calc.hash.getMaxEncodingIndex(a);  //9 ~ 58
local WOWHEAD_CUSTOMIZATION = "0zJ89b";

local EncodeValue = {}
for i = 0, #WOWHEAD_ENCODING do
    EncodeValue[i] = strsub(WOWHEAD_ENCODING, i+1, i+1);
end

local EquipmentOrderToCharacterSlot = {
    [1] = 1,
    [2] = 3,
    [3] = 15,
    [4] = 5,
    [5] = 4,
    [6] = 19,
    [7] = 9,
    [8] = 10,
    [9] = 6,
    [10]= 7,
    [11]= 8,
    [12]= 16,
    [13]= 17,
};

local CharacterSlotToEquipmentOrder = {}
for k, v in pairs(EquipmentOrderToCharacterSlot) do
    CharacterSlotToEquipmentOrder[v] = tostring(k);
    v = tostring(v);
end

local function EncodeLongValue(number)
    local m = WOWHEAD_MAXCODING_INDEX;
    if number <= m then
        return EncodeValue[number];
    end

    local floor = math.floor;
    local shortValues = {number};
    local v = 0;
    while(shortValues[1] > m) do
        v = floor(shortValues[1] / m);
        tinsert(shortValues, shortValues[1] - m * v);
        shortValues[1] = v;
    end

    local str = EncodeValue[ shortValues[1] ];
    for i = #shortValues, 2, -1 do
        if shortValues[2] ~= "0" then
            str = str .. EncodeValue[ shortValues[i] ]
        else
            str = str .. "7"
        end
    end
    return str
end

function NarciBridge_EncodeItemlist(itemlist, unitInfo)
    if not itemlist or type(itemlist) ~= "table" or itemlist == {} then return ""; end
    --itemlist = {[slot] = {itemID, bonusID}}

    local raceID, genderID, classID;

    if unitInfo then
        raceID, genderID, classID = unitInfo.raceID, unitInfo.genderID, unitInfo.classID;
    else
        local _;
        local unit = "player";
        _, _, raceID = UnitRace(unit);
        genderID = UnitSex(unit);
        _, _, classID = UnitClass(unit);
    end

    if not (raceID and genderID and classID) then
        local _;
        local unit = "player";
        _, _, raceID = UnitRace(unit);

        _, _, classID = UnitClass(unit);
        genderID = UnitSex(unit) or 2;
        raceID = raceID or 1;
        classID = classID or 1;
    end
    genderID = genderID - 2;      --Male 2 → 0  Female 3 → 1

    local wowheadLink = "https://www.wowhead.com/dressing-room#s".. EncodeValue[raceID] .. EncodeValue[genderID] .. EncodeValue[classID] .. WOWHEAD_CUSTOMIZATION.. WOWHEAD_DELIMITER;
    
    local segment, slot;
    local blanks = 0;
    for i = 1, #EquipmentOrderToCharacterSlot do
        --item = { itemID, bonusID }
        slot = EquipmentOrderToCharacterSlot[i]
        item = itemlist[slot];
        if item and item[1] then
            segment = EncodeLongValue(item[1])
            if #segment < 3 then
                segment = "7".. CharacterSlotToEquipmentOrder[slot] .. segment
            end
            item[2] = item[2] or 0; --bonusID
            if slot == 16 and item[2] > 0 and item[2] < 99 then
                local offHand = itemlist[17];
                if offHand and offHand[1] then
                    segment = segment .. WOWHEAD_DELIMITER .. "0" .. WOWHEAD_DELIMITER .. EncodeLongValue(offHand[1]) .. WOWHEAD_DELIMITER .. "7c" .. EncodeValue[ item[2] ];
                else
                    segment = segment .. WOWHEAD_DELIMITER .. "7V" .. EncodeValue[ item[2] ];
                end
                wowheadLink = wowheadLink .. segment;
                break;
            else
                segment = segment .. WOWHEAD_DELIMITER .. EncodeLongValue(item[2]) .. WOWHEAD_DELIMITER;
            end
            wowheadLink = wowheadLink .. segment;
        else
            blanks = blanks + 1;
            wowheadLink = wowheadLink .. "7M"
        end
    end

    return wowheadLink
end


----------------------------
----UI Animation Generic----
----------------------------
function NarciAPI_CreateAnimationFrame(duration)
    local frame = CreateFrame("Frame");
    frame:Hide();
    frame.total = 0;
    frame.duration = duration;
    frame:SetScript("OnHide", function(self)
        self.total = 0;
    end);
    return frame;
end



----------------------------
-------Frame Template-------
----------------------------
NarciFrameMixin = {};

function NarciFrameMixin:ShowFrame(state)
    self:SetShown(state);
    if state then
        self:SetAlpha(1);
    else
        self:SetAlpha(0);
    end
end

function NarciFrameMixin:HideFrame()
    self:ShowFrame(false);
end

function NarciFrameMixin:SetHeaderText(text, r, g, b)
    self.Header:SetText(text);

    self.Header:SetTextColor(r or 0.4, g or 0.4, b or 0.4);
end

function NarciFrameMixin:SetSizeAndAnchor(x, y, point, relativeTo, relativePoint, offsetX, offsetY)
    if x then x = max(x, 40) end;
    if y then y = max(y, 40) end;

    if x then
        if y then
            self:SetSize(x, y);
        else
            self:SetWidth(x);
        end
    else
        self:SetHeight(y);
    end

    self:ClearAllPoints();
    self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
end

function NarciFrameMixin:SetRelativeFrameLevel(offset)
    local parent = self:GetParent();
    if parent then
        local parentLevel = parent:GetFrameLevel() or 0;
        self:SetFrameStrata(parent:GetFrameStrata());
        self:SetFrameLevel( max(parentLevel + offset, 0) );
    end
end

function NarciFrameMixin:HideWhenParentIsHidden(state)
    if state then
        self:SetScript("OnHide", function(self)
            self:HideFrame();
        end);

        local parent = self:GetParent();
        if parent and not parent:IsVisible() then
            self:HideFrame();
        end
    else
        self:SetScript("OnHide", nil);
    end
end




--[[
function TestFX(modelFileID, zoomDistance, view)
    NarciAPI_SetupModelScene(TestScene, modelFileID, zoomDistance, view);
end
--]]
--/run TestFX(3152608, nil, ) 122972
--/run TestFX(1011653, 8, "
--/run TestFX(3004122, 8, "LEFT") --Eyeball