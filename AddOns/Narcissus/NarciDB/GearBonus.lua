local L = Narci.L;

Narci_GemInfo = {
    --[ItemID] = {"Attribute", Amount},
    ----8 BFA----
    [168636] = {"STR", 120},        --Leviathan's Eye of Strength
    [168637] = {"AGI", 120},        --Leviathan's Eye of Agility
    [168638] = {"INT", 120},        --Leviathan's Eye of Intellect

    [168639] = {"crit", 50},        --Deadly Lava Lazuli
    [168640] = {"mastery", 50},     --Masterful Sea Currant
    [168641] = {"haste", 50},       --Quick Sand Spinel
    [168642] = {"versatility", 50}, --Versatile Dark Opal
    [169220] = {"MSPD", 5},         --***Straddling Sage Agate

    [154126] = {"crit", 40},        --Deadly Amberblaze
    [154127] = {"haste", 40},       --Quick Owlseye
    [154128] = {"versatility", 40}, --Versatile Royal Quartz
    [154129] = {"mastery", 40},     --Masterful Tidal Amethyst

    [153707] = {"STR", 80},         --Kraken's Eye of Strength
    [153708] = {"AGI", 80},         --Kraken's Eye of Agility
    [153709] = {"INT", 80},         --Kraken's Eye of Intellect

    [153710] = {"crit", 30},        --Deadly Solstone
    [153711] = {"haste", 30},       --Quick Golden Beryl
    [153712] = {"versatility", 30}, --Versatile Kyanite
    [153713] = {"mastery", 30},     --Masterful Kubiline
    [153714] = {"EXP", 5},          --***Insightful Rubellite 
    [153715] = {"MSPD", 3},         --***Straddling Viridium

    ----7 LEG----
    [151580] = {"crit", 11},        --Deadly Deep Chemirine
    [151583] = {"haste", 11},       --Quick Lightsphene
    [151584] = {"mastery", 11},     --Masterful Argulite
    [151585] = {"versatility", 11}, --Versatile Labradorite

    [130219] = {"crit", 9},         --Deadly Eye of Prophecy
    [130220] = {"haste", 9},        --Quick Dawnlight
    [130221] = {"versatility", 9},   --Versatile Maelstrom Sapphire
    [130222] = {"mastery", 9},      --Masterful Shadowruby

    [130215] = {"crit", 7},         --Deadly Deep Amber
    [130216] = {"haste", 7},        --Quick Azsunite
    [130217] = {"versatility", 7},  --Versatile Skystone
    [130218] = {"mastery", 7},      --Masterful Queen's Opal
}

Narci_EnchantInfo = {
    --[EnchantID] = {"Attribute", Amount, SpellID},  --need to be parsed from itemstring
    ----8 BFA----
    ----Ring----
    [5938] = {"crit", 30, 255094},          --Seal of Critical Strike
    [5939] = {"haste", 30, 255095},         --Seal of Haste
    [5940] = {"mastery", 30, 255096},       --Seal of Mastery
    [5941] = {"versatility", 30, 255097},   --Seal of Versatility

    [5942] = {"crit", 40, 255098},          --Pact of Critical Strike
    [5943] = {"haste", 40, 255099},         --Pact of Haste
    [5944] = {"mastery", 40, 255100},       --Pact of Mastery
    [5945] = {"versatility", 40, 255101},   --Pact of Versatility

    [6108] = {"crit", 60, 298011},          --Accord of Critical Strike
    [6109] = {"haste", 60, 298016},         --Accord of Haste
    [6110] = {"mastery", 60, 298002},       --Accord of Mastery
    [6111] = {"versatility", 60, 297999},   --Accord of Versatility

    ----Weapon----
    [5946] = {"heal", 0, 255105},           --Coastal Surge***
    [5948] = {"leech", 0, 255112},          --Siphoning***
    [5949] = {"spell", 0, 255131},          --Torrent of Elements       proc an aura which increases your elemental spell damage by 10%
    [5950] = {"speed", 0, 255143},          --Gale-Force Striking       increases your attack speed by 15% for 15 sec
    [5962] = {"versatility", 0, 268879},    --Versatile Navigation      +50 per stack, up to 10 stacks
    [5963] = {"haste", 0, 268897},          --Quick Navigation
    [5964] = {"mastery", 0, 268903},        --Masterful Navigation
    [5965] = {"crit", 0, 268909},           --Deadly Navigation
    [5966] = {"armor", 0, 268915},          --Stalwart Navigation

    [6112] = {"INT", 0, 300770},            --Machinist's Brilliance    occasionally increase Intellect and Mastery, Haste, or Critical Strike. Your highest stat is always chosen.
    [6148] = {"STR", 0, 300788},            --Force Multiplier          occasionally increase Strength or Agility and Mastery, Haste, or Critical Strike. Your highest stat is always chosen.
    [6150] = {"AGI", 0, 300789},            --Naga Hide                 When you Block, Dodge, or Parry, you have a chance to increase Strength or Agility
    [6149] = {"INT", 0, 298515},            --Oceanic Restoration       occasionally increase Intellect and restore mana

    ----7 LEG----
    ----Ring----
    [5423] = {"crit", 7, 190866},           --Word of Critical Strike
    [5424] = {"haste", 7, 190867},          --Word of Haste
    [5425] = {"mastery", 7, 190868},        --Word of Mastery
    [5426] = {"versatility", 7, 190869},    --Word of Versatility

    [5427] = {"crit", 9, 190870},           --Binding of Critical Strike
    [5428] = {"haste", 9, 190871},          --Binding of Haste
    [5429] = {"mastery", 9, 190872},        --Binding of Mastery
    [5430] = {"versatility", 9, 190873},    --Binding of Versatility
    
    ----Cloak----
    [5431] = {"STR", 7, 190874},            --Word of Strength
    [5432] = {"AGI", 7, 190875},            --Word of Agility
    [5433] = {"INT", 7, 190876},            --Word of Intellect

    [5434] = {"STR", 9, 190877},            --Binding of Strength
    [5435] = {"AGI", 9, 190878},            --Binding of Agility
    [5436] = {"INT", 9, 190879},            --Binding of Intellect
    
}


local GemBorderTexture = {
	[0]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",			--Empty
	[1]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Kraken's Eye
	[2]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Green",
	[3]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Prismatic	
	[4]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Meta
	[5]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Orange",	--Orange
	[6]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Purple",
    [7]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Yellow",	--Yellow	
	[8]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Blue",		--Blue
	[9]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Yellow",	--Empty
	[10] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Red",		--Red
	[11] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",			--Artifact
}




--Some gems require you to assign colors manually
--itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(itemID or "itemString" or "itemName" or "itemLink") 
local function GetGemBorderTexture(itemID, itemSubClassID)
    local index = itemSubClassID or 0;
    if itemID == 153714 then
        index = 10;     --Red EXP bonus
    elseif itemID == 153715 or itemID == 169220 then
        index = 2;      --Movement Speed
    elseif itemID == 168636 or itemID == 168637 or itemID == 168638 or
    itemID == 153707 or itemID == 153708 or itemID == 153709 then
        index = 1;      --Primary
    end
    return index, GemBorderTexture[index]
end

Narci.GetGemBorderTexture = GetGemBorderTexture;



--Corruption System
--Info based on Corruption System Overview (Squishei, Wowhead)
--[[
    CORRUPTION_COLOR
    CR_CORRUPTION = 12;
    CR_CORRUPTION_RESISTANCE = 13;
    GARRISON_CURRENT_LEVEL = Tier %d

    IsCorruptedItem(itemIDOrLink)
	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = math.max(corruption - corruptionResistance, 0); 
--]]
local Corruption_SpellIDs = {
    --[SpellID] = {Given Name, Rank, Itemlink ModID, TypeID}    TypeID: 1 ~ Percentage  2 ~ Constant
    --Passive
    [315607] = {STAT_AVOIDANCE, 1, 6483, 1},             --Avoidant: Your Avoidance is increased by an amount equal to 5% of your Haste.
    [315608] = {STAT_AVOIDANCE, 2, 6484, 1},             --8
    [315609] = {STAT_AVOIDANCE, 3, 6485, 1},             --10

    [315544] = {L["Haste Gained"], 1, 6474, 1},                 --Expedient:Increases the amount of Haste you gain from all sources by 6%.
    [315545] = {L["Haste Gained"], 2, 6475, 1},                 --9
    [315546] = {L["Haste Gained"], 3, 6476, 1},                 --12

    [315529] = {L["Mastery Gained"], 1, 6471, 1},               --Masterful: Increases the amount of Mastery you gain from all sources by 6%.
    [315530] = {L["Mastery Gained"], 2, 6472, 1},               --9
    [315531] = {L["Mastery Gained"], 3, 6473, 1},               --12

    [315554] = {L["Crit Gained"], 1, 6480, 1},       --Severe: Increases the amount of Critical Strike you gain from all sources by 6%.
    [315557] = {L["Crit Gained"], 2, 6481, 1},       --9
    [315558] = {L["Crit Gained"], 3, 6482, 1},       --12
    
    [315549] = {L["Versatility Gained"], 1, 6477, 1},           --Versatile: Increases the amount of Versatility you gain from all sources by 6%.
    [315552] = {L["Versatility Gained"], 2, 6478, 1},           --9
    [315553] = {L["Versatility Gained"], 3, 6479, 1},           --12

    [315590] = {STAT_LIFESTEAL, 1, 6493, 1},             --Increases your Leech by 2%.
    [315591] = {STAT_LIFESTEAL, 2, 6494, 1},             --4
    [315592] = {STAT_LIFESTEAL, 3, 6495, 1},             --6

    [315277] = {L["Critical Damage"], 1, 6437, 1},       --Strikethrough: Increases the damage and healing you deal with Critical Strikes by 2%.
    [315281] = {L["Critical Damage"], 2, 6438, 1},       --3
    [315282] = {L["Critical Damage"], 3, 6439, 1},       --4

    [315573] = {"Cooldown Reduced", 2, 6486},      --Glimpse of Clarity: Your spells and abilities have a chance to grant you a Glimpse of Clarity, reducing the cooldown of your next 1 spell cast by 3 sec.
    [318239] = {"Cooldown Reduced", 2, 6546},      --Glimpse of Clarity: Your spells and abilities have a chance to grant you a Glimpse of Clarity, reducing the cooldown of your next 1 spell cast by 3 sec.

    --Proc
    [318266] = {L["Proc Haste"], 1, 6555, 2},               --Racing Pulse: Your spells and abilities have a chance to increase your Haste by 546 for 4 sec.
    [318492] = {L["Proc Haste"], 2, 6559, 2},               --728
    [318496] = {L["Proc Haste"], 3, 6560, 2},               --1275
    
    [318268] = {L["Proc Crit"], 1, 6556, 2},                --Deadly Momentum: Your critical hits have a chance to increase your Critical Strike by 31 for 15 sec, stacking up to 5 times.
    [318493] = {L["Proc Crit"], 2, 6561, 2},                --41
    [318497] = {L["Proc Crit"], 3, 6562, 2},                --72

    [318270] = {L["Proc Versatility"], 1, 6558, 2},         --Surging Vitality: Taking damage has a chance to increase your Versatility by 312 for 20 sec.
    [318495] = {L["Proc Versatility"], 2, 6565, 2},         --416
    [318499] = {L["Proc Versatility"], 3, 6566, 2},         --728

    [318269] = {L["Proc Mastery"], 1, 6557, 2},             --Honed Mind: Your spells and abilities have a chance to increase your Mastery by 392 for 10 sec.
    [318494] = {L["Proc Mastery"], 2, 6563, 2},             --523
    [318498] = {L["Proc Mastery"], 3, 6564, 2},             --915


    --Unique Effect
    [318280] = {"Shdow AOE", 1, 6549},                      --Echoing Void: dealing 1.00% of your Health as Shadow damage to all nearby enemies every 1 sec until no stacks remain.
    [318485] = {"Shdow AOE", 2, 6550},                      --1.5
    [318486] = {"Shdow AOE", 3, 6551},                      --2.5

    [318489] = {"Arcane AOE", 1, 6552},                     --Infinite Stars:  dealing (60% of Attack or Spell Power) Arcane damage and increasing their damage taken from your Infinite Stars by 25%, stacking up to 10 times.
    [318487] = {"Arcane AOE", 2, 6553},                     --80
    [318488] = {"Arcane AOE", 3, 6554},                     --100

    [318303] = {"Cooldowns Accelerated", 1, 6547},          --Ineffable Truth: Your Spells and Abilities have a chance to show you the Ineffable Truth, increasing the rate your cooldowns recover by 30% for 10 sec.
    [318484] = {"Cooldowns Accelerated", 2, 6548},          --Ineffable Truth: Your Spells and Abilities have a chance to show you the Ineffable Truth, increasing the rate your cooldowns recover by 50% for 10 sec.

    [318276] = {"Frontal AOE", 1, 6537},                    --Twilight Devastation: Your attacks have a chance to trigger a beam of Twilight Devastation, dealing damage equal to 3.00% of your health to all enemies in front of you.
    [318477] = {"Frontal AOE", 2, 6538},                    --4
    [318478] = {"Frontal AOE", 3, 6539},                    --5

    [318481] = {"Tentacle", 1, 6543},                       --Twisted Appendage: Your attacks have a chance to spawn a tentacle which Mind Flays your target for 25% Attack or Spell Power Shadow damage every second for 10 sec.
    [318482] = {"Tentacle", 2, 6544},
    [318483] = {"Tentacle", 3, 6545},

    [318286] = {"Void Ritual", 1, 6540},                    --Void Ritual: Gain Void Ritual, a chance to increase all secondary stats by 7 every sec for 20 sec. This chance is increased if at least 2 nearby allies also have Void Ritual.
    [318479] = {"Void Ritual", 2, 6541},
    [318480] = {"Void Ritual", 3, 6542},

    [318179] = {"Damage Over Time", 1, 6573},               --Gushing Wound: a chance to cause your target to ooze blood, dealing [(10 / 100 * max(Attack power, Spell power) * 7] damage over 7 sec.
 
      
    --On Weapon
    [318294] = {"Devour Vitality", 1, 6567},            --Devour Vitality: Your autoattacks have a 25% change to bite into the target's soul, dealing 2.00% of your health in damage and healing you for that amount.
    [316782] = {"Hunter Ability", 1, 6568},             --Your auto-shots reduce the remaining cooldown of a random Hunter ability by 2.0 sec
    [317290] = {"Lash of the Void", 1, 6569},           --Lash of the Void: Your attacks have a chance to lash your target with a living tentacle, dealing (30% of Attack power) Shadow damage and snaring them by 30% for 6 sec.
    [318299] = {"Proc Intellect", 1, 6570},             --Flash of Insight: Your mind's true potential is unlocked, causing your spells to grant you flashes of insight. Gain between 1% and 8% Intellect at all times.
    [318293] = {"Frontal AOE", 1, 6571},                --Searing Flames: Your damaging abilities build stacks of Searing Flames. When you reach 30 stacks, exhale a Searing Breath, dealing damage equal to 5.00% of your health to all targets in front of you.
    [316651] = {"Obsidian Skin", 1, 6572},              --Obsidian Skin: increasing your Armor by 5%. While in combat, explode with Obsidian Destruction every 30 seconds, dealing Shadow damage equal to 300% of your Armor to all enemies within 20 yds.
};

local CorruptionAffix = {};

local RANK_FORMAT = "T%d";  --GARRISON_CURRENT_LEVEL;
local format = string.format;
local match = string.match;
local gmatch = string.gmatch;
local GetItemInfoInstant = GetItemInfoInstant;
local CORRUPTION_COLOR = "|cff946dd1";
local RANK_COLOR = "|cff7e82b6";
local CORRUPTED_COLOR = "|cffb6bde0";

local function GetCorruptionModID(itemLink)
    local tempFunc;
    local Affix = CorruptionAffix;
    tempFunc = gmatch(itemLink, "(65%d%d)");
    if tempFunc then
        for id in tempFunc do
            if Affix[id] then
                return id
            end
        end
    end

    tempFunc = gmatch(itemLink, "(64%d%d)");
    if tempFunc then
        for id in tempFunc do
            if Affix[id] then
                return id
            end
        end
    end
end

function NarciAPI_GetCorruptedItemAffix(itemLink)
    local ID = GetCorruptionModID(itemLink);

    if ID then
        --print("AffixID: "..ID);
        local info = CorruptionAffix[ID];
        if info then
            local rank = info[1];
            local name = info[2];
            if name then
                local str = CORRUPTED_COLOR..name.."|r  "..RANK_COLOR..format(RANK_FORMAT, rank)
                --print(str);
                return str, ID
            else
                return nil, ID
            end
        else
            return nil, ID
        end
    end
    
end

local Initialize = CreateFrame("Frame")
Initialize:RegisterEvent("PLAYER_ENTERING_WORLD");
Initialize:SetScript("OnEvent", function(self, event, ...)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    local GetSpellInfo = GetSpellInfo;
    local GetSpellDescription = GetSpellDescription;
    local flatTable = {};
    local queueTable = {};
    local sum = 0;
    for k, v in pairs(Corruption_SpellIDs) do
        --Cache
        GetSpellInfo(k);
        GetSpellDescription(k);
        sum = sum + 1;
        flatTable[sum] = k;
    end

    local i = 1;
    local info, modID, rank, spellID, name, type;
    local description, num;
    local match = string.match;
    local function BuildAffix(spellList)
        spellID = spellList[i];
        info = Corruption_SpellIDs[spellID];
        type = info[4];
        if type then
            if type == 1 then   --percentage
                description = GetSpellDescription(spellID);
                num = match(description, "(%d+)%%");
                if num then
                    name = info[1].." +"..num.."%";
                else
                    name = GetSpellInfo(spellID);
                end
            elseif type == 2 then   --number
                description = GetSpellDescription(spellID);
                num = match(description, "(%d+)");
                if num then
                    name = info[1].." +"..num;
                else
                    name = GetSpellInfo(spellID);
                end
            end
        else
            name = GetSpellInfo(spellID);
        end
        modID = info[3];
        rank = info[2];
        CorruptionAffix[tostring(modID)] = {rank, name};

        if i < sum then
            i = i + 1;
            C_Timer.After(0, function()
                BuildAffix(spellList);
            end)
        end
    end

    C_Timer.After(0.73, function()
        BuildAffix(flatTable)

        --Check Cache
        C_Timer.After(1, function()
            local IsSpellDataCached = C_Spell.IsSpellDataCached;
            for j = 1, #flatTable do
                spellID = flatTable[i];
                if not IsSpellDataCached(spellID) then
                    tinsert(queueTable, spellID);
                end
            end

            C_Timer.After(0.25, function()
                if #queueTable ~= 0 then
                    BuildAffix(queueTable);
                end
            end)
        end)
        
    end);
end)



--[[
    -- Dev Tool --
    
    /script DEFAULT_CHAT_FRAME:AddMessage("\124cffa335ee\124Hitem:174954::::::::120:102::29:5:6540:6515:6578:6579:4803:::\124h[Wristwraps of the Insatiable Maw]\124h\124r");
    8       4   Rare
    9       5   Epic
    9       7   Rare  Socket
    5       1   

    6578:6579

    /dump string.match("Racing Pulse: Your spells and abilities have a chance to increase your Haste by 546 for 4 sec.", "(%d+)")




    hooksecurefunc("DressUpItemLink", function(link)
        local str = string.match(link, "item[%-?%d:]+")
        --local test = string.match(link, "6578:6579:(%d+):");
        print(link)
        print(str)
        --print(GetCorruptionModID(link))
        --NarciAPI_GetCorruptedItemAffix(link)
    end)
--]]