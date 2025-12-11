local BtWQuests = BtWQuests;
local L = BtWQuests.L;
local OUTDATED_LEVEL = 110;

local INTERFACE_NUMBER = select(4, GetBuildInfo())

local wipe = table.wipe
local format = string.format
local lower = string.lower
local gsub = string.gsub
local gmatch = string.gmatch
local concat = string.concat

local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn;
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded;

local LE_EXPANSION_LEVEL_CURRENT = LE_EXPANSION_LEVEL_CURRENT or 0;

--@REMOVE AFTER 9.0
local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local GetQuestWatchType = C_QuestLog.GetQuestWatchType
local AddQuestWatch = C_QuestLog.AddQuestWatch
local RemoveQuestWatch = C_QuestLog.RemoveQuestWatch
if INTERFACE_NUMBER < 90000 then
    GetLogIndexForQuestID = GetQuestLogIndexByID
    function GetQuestWatchType(questID)
        return IsQuestWatched(GetLogIndexForQuestID(questID)) and 0 or nil
    end
    AddQuestWatch = AddQuestWatchForQuestID
    RemoveQuestWatch = RemoveQuestWatchForQuestID
end
local GetItemCount = C_Item and C_Item.GetItemCount or GetItemCount

-- [[ Helper functions ]]
function BtWQuestsItem_GetItems(item, character)
    if item.items ~= nil then
        return item.items
    end

    if item.type == "chain" then
        return BtWQuests.Database.Chains[item.id].items
    elseif item.type == "category" then
        return BtWQuests.Database.Categories[item.id].items
    elseif item.type == "expansion" then
        return BtWQuests.Database.Expansions[item.id].items
    end

    return nil
end
function BtWQuestsItem_Active(item, character)
    if item.type == "quest" then
        local ids = item.ids or {item.id}
        for _,id in ipairs(ids) do
            if character:IsQuestActive(id) then
                return true
            end
        end
    elseif item.type == "time" then
        return GetServerTime() < item.time
    end

    return false
end
function BtWQuestsItem_ActiveOrCompleted(item, character)
    if item.type == "quest" then
        local ids = item.ids or {item.id}
        for _,id in ipairs(ids) do
            if character:IsQuestActive(id) or character:IsQuestCompleted(id) then
                return true
            end
        end
    end

    return false
end

--[[
    relationship = {
        breadcrumb = 52065,
        blockers = {51711, 51752},
    },
]]
function BtWQuestsItem_RelationshipBlockersVisible(item, character)
    local blockers = item.relationship.blockers or {item.relationship.blocker}
    for _,questID in ipairs(blockers) do
        if character:IsQuestActive(questID) or character:IsQuestCompleted(questID) then
            return false
        end
    end

    return true
end

function BtWQuestsItem_RelationshipSourceVisible(item, character)
    if character:IsQuestCompleted(item.relationship.breadcrumb) then
        return true
    end

    return BtWQuestsItem_RelationshipBlockersVisible(item, character)
end

function BtWQuestsItem_RelationshipSourceActive(item, character)
    return character:IsQuestActive(item.relationship.breadcrumb) or character:IsQuestCompleted(item.relationship.breadcrumb)
end

local function GetVariation(database, item, character)
    if item.variations == nil then
        return item;
    end

    if character ~= nil then
        for _,variation in ipairs(item.variations) do
            if not variation.initialized then
                variation.initialized = true;
                for k,v in pairs(item) do
                    if k ~= "variations" and variation[k] == nil then
                        variation[k] = v;
                    end
                end
            end

            local details = database:GetItemType(variation.type);
            if details:IsValidForCharacter(database, variation, character) then
                return variation;
            end
        end
    end

    local variation = item.variations[#item.variations];
    if not variation.initialized then
        variation.initialized = true;
        for k,v in pairs(item) do
            if k ~= "variations" and variation[k] == nil then
                variation[k] = v;
            end
        end
    end
    return variation
end

local function CheckTargetStatus(target, item, character)
    assert(target ~= nil, format("Missing Data %s - %d", item.type, item.id or 0))
    if item.status ~= nil then
        for _,status in ipairs(item.status) do
            if status == "available" and target:IsAvailable(character) then
                return true
            elseif status == "active" and target:IsActive(character) then
                return true
            elseif status == "completed" and target:IsCompleted(character) then
                return true
            elseif status == "notactive" and not target:IsActive(character) then
                return true
            elseif status == "notcompleted" and not target:IsCompleted(character) then
                return true
            end
        end
    elseif item.active == true then
        if target:IsActive(character) then
            return true
        end
    elseif item.active == false then
        if not target:IsActive(character) then
            return true
        end
    elseif item.completed == false then
        if not target:IsCompleted(character) then
            return true
        end
    else
        if target:IsCompleted(character) then
            return true
        end
    end

    return false
end
local function CheckPetStatus(id, item, character)
    if item.status == 'summon' then
        local guid = C_PetJournal.GetSummonedPetGUID()
        if not guid then
            return false;
        end
        return C_PetJournal.GetPetInfoByPetID(guid) == id;
    else
        return select(1, C_PetJournal.GetNumCollectedInfo(id)) > 0
    end
end
local function CheckMountStatus(id, item, character)
    return select(11, C_MountJournal.GetMountInfoByID(id))
end
local function CheckItemStatus(id, item, character)
    return GetItemCount(id) > 0
end
local function CheckQuestStatus(id, item, character)
    if item.status ~= nil then
        for _,status in ipairs(item.status) do
            if status == "pending" and (not character:IsQuestActive(id) and not character:IsQuestCompleted(id)) then
                return true
            elseif status == "active" and character:IsQuestActive(id) then
                return true
            elseif status == "completed" and character:IsQuestCompleted(id) then
                return true
            elseif status == "notactive" and not character:IsQuestActive(id) then
                return true
            elseif status == "notcompleted" and not character:IsQuestCompleted(id) then
                return true
            end
        end
    elseif item.active == true then
        if character:IsQuestActive(id) then
            return true
        end
    elseif item.active == false then
        if not character:IsQuestActive(id) then
            return true
        end
    elseif item.completed == false then
        if not character:IsQuestCompleted(id) then
            return true
        end
    else
        if character:IsQuestCompleted(id) then
            return true
        end
    end

    return false
end
local function CheckChainStatus(id, item, character)
    if item.status ~= nil then
        for _,status in ipairs(item.status) do
            if status == "pending" and (not character:IsChainActive(id) and not character:IsChainCompleted(id)) then
                return true
            elseif status == "active" and character:IsChainActive(id) then
                return true
            elseif status == "completed" and character:IsChainCompleted(id) then
                return true
            elseif status == "notactive" and not character:IsChainActive(id) then
                return true
            elseif status == "notcompleted" and not character:IsChainCompleted(id) then
                return true
            end
        end
    elseif item.active == true then
        if character:IsChainActive(id) then
            return true
        end
    elseif item.active == false then
        if not character:IsChainActive(id) then
            return true
        end
    elseif item.completed == false then
        if not character:IsChainCompleted(id) then
            return true
        end
    else
        if character:IsChainCompleted(id) then
            return true
        end
    end

    return false
end
local function CheckCategoryStatus(id, item, character)
    if item.status ~= nil then
        for _,status in ipairs(item.status) do
            if status == "pending" and (not character:IsCategoryActive(id) and not character:IsCategoryCompleted(id)) then
                return true
            elseif status == "active" and character:IsCategoryActive(id) then
                return true
            elseif status == "completed" and character:IsCategoryCompleted(id) then
                return true
            elseif status == "notactive" and not character:IsCategoryActive(id) then
                return true
            elseif status == "notcompleted" and not character:IsCategoryCompleted(id) then
                return true
            end
        end

        return false
    elseif item.active == true then
        if character:IsCategoryActive(id) then
            return true
        end
    elseif item.active == false then
        if not character:IsCategoryActive(id) then
            return true
        end
    elseif item.completed == false then
        if not character:IsCategoryCompleted(id) then
            return true
        end
    else
        if character:IsCategoryCompleted(id) then
            return true
        end
    end

    return false
end
local function CheckStatusCount(amount, item)
    local count = item.count or 1

    local lessthan = item.lessthan and true or false
    local morethan = item.morethan and true or false
    local notequals = item.notequals and true or false
    local equals = item.equals and true or false
    local morethanorequals = not lessthan and not morethan and not notequals and not equals

    if lessthan and amount < count then
        return true
    elseif morethan and amount > count then
        return true
    elseif notequals and amount ~= count then
        return true
    elseif equals and amount == count then
        return true
    elseif morethanorequals and amount >= count then
        return true
    end

    return false
end
local function StatusCompleted(item, character, callback)
    local amount = 0
    if item.ids then
        for _,id in ipairs(item.ids) do
            if callback(id, item, character) then
                amount = amount + 1
            end
        end
    else
        if callback(item.id, item, character) then
            amount = amount + 1
        end
    end

    return CheckStatusCount(amount, item)
end

local function TableOnClick(tbl, item)
    if tbl[1] ~= nil then
        for _,v in ipairs(tbl) do
            TableOnClick(v, item)
        end
    else
        if tbl.type == "category" then
            BtWQuestsFrame:SelectCategory(tbl.id, tbl.scrollTo)
        elseif tbl.type == "chain" then
            BtWQuestsFrame:SelectChain(tbl.id, tbl.scrollTo)
        elseif tbl.type == "coords" then
            BtWQuests_ShowMapWithWaypoint(tbl.mapID, tbl.x, tbl.y, tbl.name or item:GetName())
        end
    end
end

local timezones = {
    [BTWQUESTS_REGION_ID_US] = {
        ["Aegwynn"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Aerie Peak"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Agamaggan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Aggramar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Akama"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Alexstrasza"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Alleria"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Altar of Storms"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Alterac Mountains"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Aman'Thul"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Andorhal"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Anetheron"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Antonidas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Anub'arak"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Anvilmar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Arathor"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Archimonde"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Area 52"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Argent Dawn"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Arthas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Arygos"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Auchindoun"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Azgalor"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Azjol-Nerub"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Azralon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO,
        ["Azshara"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Azuremyst"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Baelgun"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Balnazzar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Barthilas"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Black Dragonflight"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Blackhand"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Blackrock"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Blackwater Raiders"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Blackwing Lair"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Blade's Edge"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Bladefist"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Bleeding Hollow"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Blood Furnace"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Bloodhoof"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Bloodscalp"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Bonechewer"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Borean Tundra"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Boulderfist"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Bronzebeard"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Burning Blade"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Burning Legion"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Caelestrasz"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Cairne"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Cenarion Circle"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Cenarius"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Cho'gall"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Chromaggus"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Coilfang"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Crushridge"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Daggerspine"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Dalaran"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Dalvengyr"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Dark Iron"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Darkspear"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Darrowmere"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Dath'Remar"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Dawnbringer"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Deathwing"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Demon Soul"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Dentarg"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Destromath"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Dethecus"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Detheroc"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Doomhammer"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Draenor"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Dragonblight"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Dragonmaw"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Drak'Tharon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Drak'thul"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Draka"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Drakkari"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Dreadmaul"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Drenden"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Dunemaul"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Durotan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Duskwood"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Earthen Ring"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Echo Isles"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Eitrigg"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Eldre'Thalas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Elune"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Emerald Dream"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Eonar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Eredar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Executus"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Exodar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Farstriders"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Feathermoon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Fenris"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Firetree"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Fizzcrank"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Frostmane"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Frostmourne"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Frostwolf"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Galakrond"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Gallywix"] = BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO,
        ["Garithos"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Garona"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Garrosh"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Ghostlands"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Gilneas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Gnomeregan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Goldrinn"] = BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO,
        ["Gorefiend"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Gorgonnash"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Greymane"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Grizzly Hills"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Gul'dan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Gundrak"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Gurubashi"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Hakkar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Haomarush"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Hellscream"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Hydraxis"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Hyjal"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Icecrown"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Illidan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Jaedenar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Jubei'Thos"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Kael'thas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Kalecgos"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Kargath"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Kel'Thuzad"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Khadgar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Khaz Modan"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Khaz'goroth"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Kil'jaeden"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Kilrogg"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Kirin Tor"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Korgath"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Korialstrasz"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Kul Tiras"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Laughing Skull"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Lethon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Lightbringer"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Lightning's Blade"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Lightninghoof"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Llane"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Lothar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Madoran"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Maelstrom"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Magtheridon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Maiev"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Mal'Ganis"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Malfurion"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Malorne"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Malygos"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Mannoroth"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Medivh"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Misha"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Mok'Nathal"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Moon Guard"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Moonrunner"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Mug'thol"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Muradin"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Nagrand"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Nathrezim"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Nazgrel"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Nazjatar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Nemesis"] = BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO,
        ["Ner'zhul"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Nesingwary"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Nordrassil"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Norgannon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Onyxia"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Perenolde"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Proudmoore"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Quel'Thalas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Quel'dorei"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Ragnaros"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Ravencrest"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Ravenholdt"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Rexxar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Rivendare"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Runetotem"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Sargeras"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Saurfang"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["Scarlet Crusade"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Scilla"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Sen'jin"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Sentinels"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Shadow Council"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Shadowmoon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Shadowsong"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Shandris"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Shattered Halls"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Shattered Hand"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Shu'halo"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Silver Hand"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Silvermoon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Sisters of Elune"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Skullcrusher"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Skywall"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Smolderthorn"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Spinebreaker"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Spirestone"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Staghelm"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Steamwheedle Cartel"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Stonemaul"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Stormrage"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Stormreaver"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Stormscale"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Suramar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Tanaris"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Terenas"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Terokkar"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Thaurissan"] = BTWQUESTS_TIMEZONE_ID_AUSTRALIA_MELBOURN,
        ["The Forgotten Coast"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["The Scryers"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["The Underbog"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["The Venture Co"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Thorium Brotherhood"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Thrall"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Thunderhorn"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Thunderlord"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Tichondrius"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Tol Barad"] = BTWQUESTS_TIMEZONE_ID_AMERICA_SAOPAULO,
        ["Tortheldrin"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Trollbane"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Turalyon"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Twisting Nether"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Uldaman"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Uldum"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Undermine"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Ursin"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Uther"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Vashj"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Vek'nilash"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Velen"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Warsong"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Whisperwind"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Wildhammer"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Windrunner"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Winterhoof"] = BTWQUESTS_TIMEZONE_ID_AMERICA_CHICAGO,
        ["Wyrmrest Accord"] = BTWQUESTS_TIMEZONE_ID_AMERICA_LOSANGELAS,
        ["Ysera"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Ysondre"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Zangarmarsh"] = BTWQUESTS_TIMEZONE_ID_AMERICA_DENVER,
        ["Zul'jin"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
        ["Zuluhed"] = BTWQUESTS_TIMEZONE_ID_AMERICA_NEWYORK,
    },
    [BTWQUESTS_REGION_ID_KOREA] = BTWQUESTS_TIMEZONE_ID_ASIA_SEOUL,
    [BTWQUESTS_REGION_ID_EUROPE] = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS,
    [BTWQUESTS_REGION_ID_TAIWAN] = BTWQUESTS_TIMEZONE_ID_ASIA_TAIPEI,
}
function BtWQuests_GetTimeZone(region, realm)
    if region == nil then
        region = GetCurrentRegion()
    elseif type(region) == "string" then
        return BtWQuests_GetTimeZone(nil, region)
    end
    if realm == nil then
        realm = GetRealmName()
    end

    if type(timezones[region]) == "table" then
        return timezones[region][realm]
    else
        return timezones[region]
    end
end
local function GetPlayerPosition(targetMapID)
    local sourceMapID = C_Map.GetBestMapForUnit("player")
    local sourceCoords = C_Map.GetPlayerMapPosition(sourceMapID, "player")
    if sourceMapID == targetMapID then
        return sourceCoords
    else
        local continentID, coords = C_Map.GetWorldPosFromMapPos(sourceMapID, sourceCoords)
        if coords == nil then
            return nil
        end

        local _, coords = C_Map.GetMapPosFromWorldPos(continentID, coords, targetMapID)
        if coords == nil then
            return nil
        end

        return coords
    end
end
function BtWQuests_GetBestLocation(database, locations, relativeMapID) -- , relativeX, relativeY Should these be added?
    if relativeMapID == nil then
        local possibleLocations = {}
        for mapID in pairs(locations) do
            local _, item = BtWQuests_GetBestLocation(database, locations, mapID)
            if item then
                possibleLocations[#possibleLocations+1] = item
            end
        end

        table.sort(possibleLocations, function (a, b)
            return (a.distanceSq or 0) < (b.distanceSq or 0)
        end)

        local result = possibleLocations[1]
        return result.mapID, result
    end

    if locations[relativeMapID] == nil then -- This'll take a while
        local sourceMapID, sourceCoords = BtWQuests_GetBestLocation(database, locations)
        if sourceCoords == nil then
            return nil
        end

        local continentID, coords = C_Map.GetWorldPosFromMapPos(sourceMapID, sourceCoords)
        if coords == nil then
            return nil
        end

        local _, coords = C_Map.GetMapPosFromWorldPos(continentID, coords, relativeMapID)
        if coords == nil then
            return nil
        end

        return relativeMapID, coords
    else
        local filtered = database:FilterItems(locations[relativeMapID], BtWQuestsCharacters:GetPlayer())

        local result = filtered[1]
        local resultDistanceSq
        if #filtered > 1 then
            local playerPos = GetPlayerPosition(relativeMapID)
            if playerPos then
                resultDistanceSq = CalculateDistanceSq(result.x, result.y, playerPos.x, playerPos.y)
                for i=2,#filtered do
                    local item = filtered[i]
                    local itemDistanceSq = CalculateDistanceSq(item.x, item.y, playerPos.x, playerPos.y)
                    if itemDistanceSq < resultDistanceSq then
                        result = item
                        resultDistanceSq = itemDistanceSq
                    end
                end
            end
        end

        if not result then
            return nil
        end

        result = CreateVector2D(result.x, result.y)
        result.mapID = relativeMapID
        result.distanceSq = resultDistanceSq
        return relativeMapID, result
    end
end

local ConditionMixin = {}
function ConditionMixin:EvalFor(character)
    return self.database:EvalRequirement(self, self, character);
end

local DataMixin = {};
function DataMixin:GetID()
    return self.id;
end
function DataMixin:GetName()
    return self.database:EvalText(self.name, self)
end
function DataMixin:GetUserdata()
    return self.userdata
end
function DataMixin:IsValidForCharacter(character)
    return self.database:IsItemValidForCharacter(self, character);
end
function DataMixin:Visible(character)
    if self.visible ~= nil then
        return self.database:EvalRequirement(self.visible, self, character);
    end
    
    return true;
end
function DataMixin:IsAvailable(character)
    assert(character ~= nil);

    if self:IsCompleted(character) then
        return false;
    end

    if self:IsActive(character) then
        return false;
    end

    if self.prerequisites ~= nil then
        return self.database:EvalRequirement(self.prerequisites, self, character);
    end

    return true;
end
function DataMixin:IsActive(character)
    assert(character ~= nil);

    if self:IsCompleted(character) then
        return false;
    end

    if self.active ~= nil then
        return self.database:EvalRequirement(self.active, self, character, true);
    end

    if self.prerequisites ~= nil then
        return self.database:EvalRequirement(self.prerequisites, self, character);
    end

    return true;
end
function DataMixin:IsCompleted(character)
    if self.completed ~= nil then
        return self.database:EvalRequirement(self.completed, self, character);
    end

    return false
end
function DataMixin:GetPrerequisites()
    if self.prerequisitesItems == nil then
        self.prerequisitesItems = {}

        if self.prerequisites then
            if self.prerequisites[1] == nil then
                self.prerequisitesItems[#self.prerequisitesItems+1] = self.database:CreateItem(-1, self.prerequisites, self);
            else
                for _,prerequisite in ipairs(self.prerequisites) do
                    self.prerequisitesItems[#self.prerequisitesItems+1] = self.database:CreateItem(-1, prerequisite, self);
                end
            end
        end
    end

    return self.prerequisitesItems, self.hasLowPriorityPrerequisites;
end
function DataMixin:GetRestrictions()
    if self.restrictionsItems == nil then
        self.restrictionsItems = {}

        if self.restrictions then
            local restrictions = self.restrictions
            if type(restrictions) == "number" then
                restrictions = self.database:GetConditionByID(restrictions)
            end
            if restrictions[1] == nil then
                self.restrictionsItems[#self.restrictionsItems+1] = self.database:CreateItem(-1, restrictions, self);
            else
                for _,restriction in ipairs(restrictions) do
                    self.restrictionsItems[#self.restrictionsItems+1] = self.database:CreateItem(-1, restriction, self);
                end
            end
        end
    end

    return self.restrictionsItems;
end
function DataMixin:GetRewards()
    if self.rewardsItems == nil then
        self.rewardsItems = {}

        if self.rewards then
            for _,reward in ipairs(self.rewards) do
                self.rewardsItems[#self.rewardsItems+1] = self.database:CreateItem(-1, reward, self, self);
            end
        end
    end

    return self.rewardsItems;
end

local QuestMixin = CreateFromMixins(DataMixin);
function QuestMixin:GetContentTuningID()
    return self.contentTuningID or -1
end
function QuestMixin:GetLevel()
    return self.level or -1
end
function QuestMixin:GetRequiredLevel()
    return self.requiredLevel or -1
end
function QuestMixin:GetMaxLevel()
    return self.maxLevel or 255
end
function QuestMixin:GetLevelFlag()
    return self.levelFlag or 0
end
if INTERFACE_NUMBER < 90000 then
    function QuestMixin:GetLink()
        if self.link == nil then
            self.link = format("\124cffffff00\124Hquest:%d:%d:%d:%d:%d\124h[%s]\124h\124r", self:GetID(), self:GetLevel(), self:GetRequiredLevel(), self:GetMaxLevel(), self:GetLevelFlag(), self:GetName())
        end

        return self.link
    end
else
    function QuestMixin:GetLink()
        if self.link == nil then
            self.link = format("\124cffffff00\124Hquest:%d:%d\124h[%s]\124h\124r", self:GetID(), self:GetContentTuningID(), self:GetName())
        end
    
        return self.link
    end
end
function QuestMixin:IsActive(character)
    return character:IsQuestActive(self.id)
end
function QuestMixin:IsCompleted(character)
    return character:IsQuestCompleted(self.id)
end
function QuestMixin:GetUserdata()
    -- if self.userdata == nil then
    --     self.userdata = self.item.userdata or {}

    --     self.userdata.link = self.userdata.link or self:GetLink()
    -- end

    return self.userdata
end
function QuestMixin:GetSource(character)
    if self.source ~= nil then
        return self.database:CreateItem(-1, self.source, self, self);
    end

    return nil;
end
function QuestMixin:HasTarget()
    return self.target ~= nil or self.targets ~= nil
end
function QuestMixin:GetTargetMapID()
    return (self.target and self.target.uiMapID) or (self.targets and self.targets.mapID)
end
function QuestMixin:HasObjectives()
    return self.objectives ~= nil
end
function QuestMixin:GetCurrentObjectiveMapID()
    for index,objective in ipairs(C_QuestLog.GetQuestObjectives(self:GetID())) do
        if not objective.finished then
            return self.objectives[index].uiMapID or self.objectives[index].mapID
        end
    end
end

local MissionMixin = CreateFromMixins(DataMixin);
function MissionMixin:IsBreadcrumb()
    return true
end
function MissionMixin:IsAvailable(character)
    local mission = C_Garrison.GetBasicMissionInfo(self.id or self.ids[1])

    return mission ~= nil
end
function MissionMixin:IsActive(character)
    local mission = C_Garrison.GetBasicMissionInfo(self.id or self.ids[1])

    return mission and mission.inProgress or false
end
function MissionMixin:IsCompleted(character)
    return false
end

local NPCMixin = CreateFromMixins(DataMixin);
function NPCMixin:IsBreadcrumb()
    return true
end
function NPCMixin:IsAvailable(character)
    return false
end
function NPCMixin:IsActive(character)
    return false
end
function NPCMixin:IsCompleted(character)
    return false
end
function NPCMixin:GetLocation(...)
    if self.locations == nil then
        return nil
    end

    return BtWQuests_GetBestLocation(self.database, self.locations, ...)
end

local ObjectMixin = CreateFromMixins(NPCMixin);

local ChainMixin = CreateFromMixins(DataMixin);
function ChainMixin:GetSubtext(character, small)
    if self:IsCompleted(character) then
        return L["BTWQUESTS_COMPLETED"]
    elseif self:IsActive(character) then
        return L["BTWQUESTS_ACTIVE"]
    elseif self:IsAvailable(character) then
        return L["BTWQUESTS_AVAILABLE"]
    end
end
function ChainMixin:GetLink()
    if self.link == nil then
        self.link = format("\124cffffff00\124Hgarrmission:btwquests:chain:%s\124h[%s]\124h\124r", self:GetID(), self:GetName())
    end

    return self.link
end
function ChainMixin:GetExpansion()
    return self.expansion
end
function ChainMixin:GetCategory()
    return self.category
end
function ChainMixin:GetNumPrerequisites()
    if self.prerequisites == nil then
        return 0
    end

    if self.prerequisites[1] == nil then
        return 1
    end

    return #self.prerequisites
end
function ChainMixin:GetNumItems()
    return #self.items
end
-- Check if the character is ignoring this chain
function ChainMixin:IsIgnored(character)
    return character:IsChainIgnored(self:GetID())
end
function ChainMixin:IsAvailable(character)
    assert(character ~= nil);
    if self:IsIgnored(character) then
        return false
    end

    return DataMixin.IsAvailable(self, character);
end
function ChainMixin:IsActive(character)
    assert(character ~= nil);
    if self:IsIgnored(character) then
        return false
    end

    return DataMixin.IsActive(self, character);
end
function ChainMixin:IsMajor()
    return self.major == true
end
function ChainMixin:GetButtonImage()
    if type(self.buttonImage) ~= "table" then
        return self.buttonImage
    end

    return self.buttonImage.texture, unpack(self.buttonImage.texCoords)
end
function ChainMixin:GetListImage()
    if type(self.listImage) ~= "table" then
        return self.listImage
    end

    return self.listImage.texture, unpack(self.listImage.texCoords)
end
function ChainMixin:GetItem(index, character)
    local index = tonumber(index);
    if index == nil or self.items[index] == nil then
        return nil;
    end

    local item = GetVariation(self.database, self.items[index], character)
    local result = self.database:CreateItem(index, item, self, self);

    if result:GetType() == "chain" and result:IsEmbed() then
        local connections = result:GetConnections();
        if connections then
            if connections[1] ~= nil and type(connections[1]) ~= "table" then
                connections[result:GetNumItems()] = {connections[1]};
                connections[1] = nil;
            end
        end
    end

    return result;
end
function ChainMixin:GetNextItem(character)
    for i = 1,self:GetNumItems() do
        local item = self:GetItem(i, character)
        if item and item:IsValidForCharacter(character) and not item:IsAside(character) and not item:IsBreadcrumb(character) and item:Visible(character) and not item:IsCompleted(character) then
            return item
        end
    end
end
function ChainMixin:GetAlternative(character)
    if self.alternatives == nil then
        return nil
    end

    for _,v in ipairs(self.alternatives) do
        if self.database:GetChainByID(v):IsValidForCharacter(character) then
            return v;
        end
    end

    return nil;
end

local CategoryMixin = CreateFromMixins(DataMixin);
function CategoryMixin:GetProgress(character)
    local majorProgress = 0
    local majorTotal = 0
    local minorProgress = 0
    local minorTotal = 0

    for _,v in ipairs(self.items) do
        if v.type == 'chain' then
            if not character:IsChainIgnored(v.id) and self.database:IsItemValidForCharacter(v, character) then
                local chain = self.database:GetChainByID(v.id);
                if v.major or (chain and chain:IsMajor()) then
                    if self.database:IsChainCompleted(v.id, character) then
                        majorProgress = majorProgress + 1
                    end
                    majorTotal = majorTotal + 1
                else
                    if self.database:IsChainCompleted(v.id, character) then
                        minorProgress = minorProgress + 1
                    end
                    minorTotal = minorTotal + 1
                end
            end
        elseif v.type == 'category' then
            if not character:IsCategoryIgnored(v.id) then
                if self.database:IsCategoryCompleted(v.id, character) then
                    minorProgress = minorProgress + 1
                end
                minorTotal = minorTotal + 1
            end
        end
    end

    if majorTotal == 0 then
        majorProgress = minorProgress
        majorTotal = minorTotal

        minorProgress = 0
        minorTotal = 0
    end

    if minorTotal == 0 then
        return majorProgress, majorTotal
    end

    return majorProgress, majorTotal, minorProgress, minorTotal
end
function CategoryMixin:GetSubtext(character, small)
    if self:IsCompleted(character) then
        return L["BTWQUESTS_COMPLETED"]
    end

    local majorProgress, majorTotal, minorProgress, minorTotal = self:GetProgress(character)

    if minorTotal == nil then
        return string.format(L["BTWQUESTS_PROGRESS"], majorProgress, majorTotal)
    elseif small then
        return string.format(L["BTWQUESTS_PROGRESS"], minorProgress + majorProgress, minorTotal + majorTotal)
    else
        return string.format(L["BTWQUESTS_PROGRESS_SIDE"], majorProgress, majorTotal, minorProgress + majorProgress, minorTotal + majorTotal)
    end
end
function CategoryMixin:GetExpansion()
    return self.expansion
end
function CategoryMixin:GetParent()
    return self.parent
end
function CategoryMixin:GetLink()
    if self.link == nil then
        self.link = format("\124cffffff00\124Hgarrmission:btwquests:category:%s\124h[%s]\124h\124r", self:GetID(), self:GetName())
    end

    return self.link
end
function CategoryMixin:GetItemList(character, noHeaders, filterCompleted, filterIgnored, filterMajor, includeChildren)
    local major = {}
    local others = {}
    local completed = {}
    local ignored = {}
    local header = nil

    local index = 1
    local item = self:GetItem(index, character)
    while item do
        if item:IsValidForCharacter(character) and item:Visible(character) then
            if item:GetType() == "header" then
                header = item
            else
                if includeChildren and item:GetType() == "category" then
                    local children = item:GetItemList(character, noHeaders, false, false, false, includeChildren)

                    if filterIgnored and character:IsCategoryIgnored(item:GetID()) then
                        for _,child in ipairs(children) do
                            table.insert(ignored, child)
                        end
                    else
                        for _,child in ipairs(children) do
                            if filterIgnored and child:GetType() == "chain" and character:IsChainIgnored(child:GetID()) then
                                table.insert(ignored, child)
                            elseif filterCompleted and child:IsCompleted(character) then
                                table.insert(completed, child)
                            elseif filterMajor and child:GetType() == "chain" and child:IsMajor() then
                                table.insert(major, child)
                            else
                                table.insert(others, child)
                            end
                        end
                    end
                elseif filterIgnored and item:GetType() == "category" and character:IsCategoryIgnored(item:GetID()) then
                    table.insert(ignored, item)
                elseif filterIgnored and item:GetType() == "chain" and character:IsChainIgnored(item:GetID()) then
                    table.insert(ignored, item)
                elseif filterCompleted and item:IsCompleted(character) then
                    table.insert(completed, item)
                elseif filterMajor and item:GetType() == "chain" and item:IsMajor() then
                    table.insert(major, item)
                else
                    if header ~= nil then
                        if not noHeaders then
                            table.insert(others, header)
                        end
                        header = nil
                    end

                    table.insert(others, item)
                end
            end
        end

        index = index + 1
        item = self:GetItem(index, character)
    end

    local results = {}

    if #major > 0 then
        if not noHeaders then
            table.insert(results, self.database:CreateItem(-1, {type = "header", name = L["BTWQUESTS_MAJOR"]}, self, self))
        end

        for _,item in ipairs(major) do
            table.insert(results, item)
        end
    end

    for _,item in ipairs(others) do
        table.insert(results, item)
    end

    if #completed > 0 then
        if not noHeaders then
            table.insert(results, self.database:CreateItem(-1, {type = "header", name = L["BTWQUESTS_COMPLETED"]}, self, self))
        end

        for _,item in ipairs(completed) do
            table.insert(results, item)
        end
    end

    if #ignored > 0 then
        if not noHeaders then
            table.insert(results, self.database:CreateItem(-1, {type = "header", name = L["BTWQUESTS_IGNORED"]}, self, self))
        end

        for _,item in ipairs(ignored) do
            table.insert(results, item)
        end
    end

    return results
end
function CategoryMixin:GetItem(index, character)
    local index = tonumber(index)
    if index == nil or self.items == nil or self.items[index] == nil then
        return nil
    end

    local item = GetVariation(self.database, self.items[index], character)
    return self.database:CreateItem(index, item, self, self);
end
function CategoryMixin:IsMajor()
    return self.major == true
end
function CategoryMixin:GetButtonImage()
    if type(self.buttonImage) ~= "table" then
        return self.buttonImage
    end

    return self.buttonImage.texture, unpack(self.buttonImage.texCoords)
end
function CategoryMixin:GetListImage()
    if type(self.listImage) ~= "table" then
        return self.listImage
    end

    return self.listImage.texture, unpack(self.listImage.texCoords)
end
function CategoryMixin:IsCompleted(character)
    for _,v in ipairs(self.items) do
        if v.type == 'chain' then
            local item = self.database:GetChainByID(v.id)
            if not character:IsChainIgnored(v.id) and item:IsValidForCharacter(character) and not item:IsCompleted(character) then
                return false
            end
        elseif v.type == 'category' then
            local item = self.database:GetCategoryByID(v.id)
            if not character:IsCategoryIgnored(v.id) and not item:IsCompleted(character) then
                return false
            end
        end
    end

    return true
end
function CategoryMixin:IsActive(character)
    return false
end
function CategoryMixin:GetAlternative(character)
    if self.alternatives == nil then
        return nil
    end

    for _,v in ipairs(self.alternatives) do
        if self.database:GetCategoryByID(v):IsValidForCharacter(character) then
            return v;
        end
    end

    return nil;
end

local ExpansionMixin = CreateFromMixins(CategoryMixin);
function ExpansionMixin:GetLink()
    if self.link == nil then
        self.link = format("\124cffffff00\124Hgarrmission:btwquests:expansion:%s\124h[%s]\124h\124r", self:GetID(), self:GetName())
    end

    return self.link
end
function ExpansionMixin:GetImage()
    if type(self.image) ~= "table" then
        return self.image
    end

    return self.image.texture, unpack(self.image.texCoords)
end
-- Gets 3 items about the expansions
function ExpansionMixin:GetMajorItems(character)
    local actives, available, upcoming = {}, {}, {}

    local items = self:GetItemList(character, true, true, true, true, true)
    for _,item in ipairs(items) do
        if item:IsActive(character) then
            actives[#actives+1] = item
            if #actives == 3 then
                break
            end
        elseif item:IsAvailable(character) then
            available[#available+1] = item
        elseif not item:IsCompleted(character) then
            upcoming[#upcoming+1] = item
        end
    end

    local items = actives
    for _,item in ipairs(available) do
        if #items == 3 then
            break
        end

        items[#items+1] = item
    end
    for _,item in ipairs(upcoming) do
        if #items == 3 then
            break
        end

        items[#items+1] = item
    end

    return {items[1], items[2], items[3]}
end
function ExpansionMixin:IsCompleted()
    return GetAccountExpansionLevel() >= self.id
end
function ExpansionMixin:IsLoaded()
    if type(self.addons) ~= "table" or next(self.addons) == nil then
        return true
    end

    for addon in pairs(self.addons) do
        if not IsAddOnLoaded(addon) then
            return false
        end
    end

    return true
end
function ExpansionMixin:SupportAutoLoad()
    return type(self.addons) == "table" and next(self.addons) ~= nil
end
function ExpansionMixin:IsAutoLoad()
    if type(self.addons) ~= "table" or next(self.addons) == nil then
        return true
    end

    for addon in pairs(self.addons) do
        if not BtWQuests_AutoLoad[addon] then
            return false
        end
    end

    return true
end
function ExpansionMixin:SetAutoLoad(value)
    if type(self.addons) ~= "table" or next(self.addons) == nil then
        return
    end

    for addon in pairs(self.addons) do
        BtWQuests_AutoLoad[addon] = value
    end
end
function ExpansionMixin:Load()
    wipe(self.database.questCache);
    if self.addons then
        for addon in pairs(self.addons) do
            LoadAddOn(addon)
        end
    end
end

local ItemMixin = {};
function ItemMixin:EqualsItem(database, item, other)
    local type = self:GetType(database, item)
    if type ~= other.type then
        return false
    end

    if type == "chain" or type == "category" or type == "npc" or type == "quest" or type == "achievement" or type == "mission" or type == "faction" or type == "race" or type == "class" then
        return tonumber(self:GetID(database, item)) == tonumber(other.id)
    elseif type == "level" then
        return tonumber(self:GetLevel(database, item)) == tonumber(other.level)
    else
        return false
    end
end
function ItemMixin:GetType(database, item)
    return item.type;
end
function ItemMixin:GetID(database, item, index)
    if item.id then
        return item.id;
    end

    local index = index or 1;
    if item.ids and item.ids[index] then
        return item.ids[index];
    end

    return nil;
end
function ItemMixin:GetVariation(database, item, character)
    if item.variations == nil then
        return nil;
    end

    return database:CreateItem(item.index, GetVariation(database, item, character), item, self:GetRoot(database, item));
end
function ItemMixin:IsValidForCharacter(database, item, character)
    if item.restrictions ~= nil then
        return database:IsItemValidForCharacter(item, character);
    end

    return true;
end
function ItemMixin:Visible(database, item, character, showAll)
    if item.visible ~= nil then
        return (showAll or not item.lowPriority) and database:EvalRequirement(item.visible, item, character);
    end

    return (showAll or not item.lowPriority);
end
function ItemMixin:GetName(database, item, character)
    if item.name then
        return database:EvalText(item.name, item, character);
    end

    return "Unnamed"
end
function ItemMixin:GetSubtext(database, item, character, small)
    if item.subtext then
        return database:EvalText(item.subtext, item, character);
    end
end
function ItemMixin:GetAlternative(database, item, character)
    if item.alternatives ~= nil then
        for _,v in ipairs(item.alternatives) do
            if database:IsItemValidForCharacter({type = item.type, id = v}, character) then
                return v;
            end
        end
    end

    return nil;
end
function ItemMixin:IsAvailable(database, item, character)
    if self:IsCompleted(database, item, character) then
        return false;
    end

    if self:IsActive(database, item, character) then
        return false;
    end

    if item.prerequisites ~= nil then
        return database:EvalRequirement(item.prerequisites, item, character);
    end

    return true
end
function ItemMixin:IsActive(database, item, character)
    if self:IsCompleted(database, item, character) then
        return false;
    end

    if item.active ~= nil then
        return database:EvalRequirement(item.active, item, character, true);
    end

    return false;
end
function ItemMixin:IsCompleted(database, item, character, ...)
    if item.completed ~= nil then
        return database:EvalRequirement(item.completed, item, character);
    end

    return false
end
function ItemMixin:IsBreadcrumb(database, item, character)
    if item.breadcrumb ~= nil then
        return item.breadcrumb;
    end

    return false
end
function ItemMixin:IsAside(database, item, character)
    if item.aside ~= nil then
        return item.aside;
    end

    return false
end
function ItemMixin:OnClick(database, item, character, ...)
    if type(item.onClick) == "table" then
        return TableOnClick(item.onClick, database:CreateItem(0, item), character, ...);
    elseif type(item.onClick) == "function" then
        return item.onClick(item, character, ...);
    end

    return nil;
end
function ItemMixin:OnEnter(database, item, character, ...)
    if item.onEnter ~= nil then
        return item.onEnter(item, character, ...);
    end

    return nil;
end
function ItemMixin:OnLeave(database, item, character, ...)
    if item.onLeave ~= nil then
        return item.onLeave(item, character, ...);
    end

    return nil;
end
function ItemMixin:GetPrerequisites(database, item)
    if item.prerequisites ~= nil then
        local result = {}
        for _,prerequisite in ipairs(item.prerequisites) do
            result[#result+1] = database:CreateItem(-1, prerequisite, item, self:GetRoot(database, item));
        end
        return result, item.hasLowPriorityPrerequisites;
    end
end
function ItemMixin:GetRewards(database, item)
    if item.rewards ~= nil then
        local result = {}
        for _,reward in ipairs(item.rewards) do
            result[#result+1] = database:CreateItem(-1, reward, item, self:GetRoot(database, item));
        end
        return result;
    end
end
function ItemMixin:GetDifficulty(database, item)
    return item.difficulty;
end
function ItemMixin:GetTagID(database, item)
    return item.tagID;
end
function ItemMixin:GetUserdata(database, item)
    if item.userdata ~= nil then
        return item.userdata;
    end

    return nil;
end
function ItemMixin:GetStatus(database, item, character)
    if item.status ~= nil then
        return database:EvalText(item.status, item, character)
    end

    if self:IsCompleted(database, item, character) then
        return "complete"
    end

    if self:IsBreadcrumb(database, item, character) and self:HasConnections(database, item, character) then
        local completed = false
        local index = 1
        local connection = self:GetConnection(database, item, index, character)
        while connection do
            if connection:IsValidForCharacter(character) and connection:Visible(character) and connection:GetStatus(character) ~= nil then
                completed = true
                break
            end

            index = index + 1
            connection = self:GetConnection(database, item, index, character)
        end

        if completed then
            return "complete"
        end
    end

    if self:IsActive(database, item, character) then
        return "active"
    end

    return nil
end
function ItemMixin:GetX(database, item)
    return item.x;
end
function ItemMixin:GetY(database, item)
    return item.y
end
function ItemMixin:GetParent(database, item)
    return item.parent
end
function ItemMixin:GetRoot(database, item)
    return item.root
end
function ItemMixin:GetIndex(database, item)
    return item.index
end
function ItemMixin:HasConnections(database, item)
    return item.connections and #item.connections > 0
end
function ItemMixin:GetConnection(database, item, index, character, overrideConnections, overrideChain)
    local index = tonumber(index)
    if overrideConnections then
        local connections = overrideConnections;
        if index == nil or connections == nil or connections[index] == nil then
            return nil;
        end
    
        local connection = tostring(connections[index]);
        local match = string.gmatch(connection, "[^%.]+");
        local result = overrideChain:GetItem(tonumber(match()), character);
        for value in match do
            result = result:GetItem(tonumber(value), character);
        end
        
        while result and result:GetType() == "chain" and result:IsEmbed() do
            result = result:GetItem(1, character);
        end
    
        return result;
    else
        local connections = item.connections;
        if index == nil or connections == nil or connections[index] == nil then
            return nil;
        end
    
        local connection = tostring(connections[index]);
        local match = string.gmatch(connection, "[^%.]+");
        local result = self:GetRoot(database, item):GetItem(item.index + tonumber(match()), character);
        for value in match do
            result = result:GetItem(tonumber(value), character);
        end

        while result and result:GetType() == "chain" and result:IsEmbed() do
            result = result:GetItem(1, character);
        end
    
        return result;
    end
end
function ItemMixin:GetConnections(database, item)
    return item.connections;
end
function ItemMixin:GetAtlas(database, item)
    return item.atlas
end
function ItemMixin:GetSource(database, item, character)
    if item.source ~= nil then
        return database:CreateItem(-1, item.source, item, self:GetRoot(database, item));
    end

    return nil;
end

local TargetItemMixin = CreateFromMixins(ItemMixin);
function TargetItemMixin:GetTargetType(database, item)
    return item.type;
end
function TargetItemMixin:GetTarget(database, item, index)
    local type = self:GetTargetType(database, item);
    if type == nil or not database:HasDataType(type) then
        return nil;
    end

    if item.id then
        return database:GetData(type, item.id);
    end

    local index = index or 1;
    if item.ids and item.ids[index] then
        return database:GetData(type, item.ids[index]);
    end

    return nil;
end
function TargetItemMixin:TargetCount(database, item)
    return item.ids and #item.ids or 1;
end
function TargetItemMixin:IsValidForCharacter(database, item, character)
    if item.restrictions ~= nil then
        return ItemMixin.IsValidForCharacter(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:IsValidForCharacter(character);
    end

    return true;
end
function TargetItemMixin:Visible(database, item, character, showAll)
    if not showAll and item.lowPriority then
        return false
    end
    
    if item.visible ~= nil then
        return ItemMixin.Visible(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:Visible(character);
    end

    return true;
end
function TargetItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetName(character);
    end

    return "Unnamed"
end
function TargetItemMixin:GetSubtext(database, item, character, small)
    if item.subtext then
        return ItemMixin.GetSubtext(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetSubtext(character, small);
    end
end
function TargetItemMixin:GetAlternative(database, item, character)
    if item.alternatives ~= nil then
        return ItemMixin.GetAlternative(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetAlternative(character);
    end
end
function TargetItemMixin:IsAvailable(database, item, character)
    if item.prerequisites ~= nil then
        return ItemMixin.IsAvailable(self, database, item, character);
    end

    for i=1,self:TargetCount(database, item) do
        local target = self:GetTarget(database, item, i);
        if target and target:IsAvailable(character) then
            return true
        end
    end

    return false
end
function TargetItemMixin:IsActive(database, item, character)
    if item.active ~= nil then
        return ItemMixin.IsActive(self, database, item, character);
    end

    for i=1,self:TargetCount(database, item) do
        local target = self:GetTarget(database, item, i);
        if target and target:IsActive(character) then
            return true
        end
    end

    return false
end
function TargetItemMixin:IsCompleted(database, item, character, ...)
    if item.completed ~= nil then
        return ItemMixin.IsCompleted(self, database, item, character);
    end

    local type = self:GetTargetType(database, item);
    if type == nil or not database:HasDataType(type) then
        return false;
    end

    local amount = 0
    if item.ids then
        for _,id in ipairs(item.ids) do
            if CheckTargetStatus(database:GetData(type, id), item, character) then
                amount = amount + 1
            end
        end
    else
        if CheckTargetStatus(database:GetData(type, item.id), item, character) then
            amount = amount + 1
        end
    end

    return CheckStatusCount(amount, item)
end
function TargetItemMixin:GetPrerequisites(database, item, character)
    if item.prerequisites ~= nil then
        return ItemMixin.GetPrerequisites(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetPrerequisites(character);
    end
end
function TargetItemMixin:GetRewards(database, item, character)
    if item.rewards ~= nil then
        return ItemMixin.GetRewards(self, database, item, character);
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetRewards(character);
    end
end

local HeaderItemMixin = CreateFromMixins(ItemMixin);

local QuestItemMixin = CreateFromMixins(TargetItemMixin);
-- Using this instead of the target system because some quests wont be in our database
function QuestItemMixin:IsCompleted(database, item, character, ...)
    if item.completed ~= nil then
        return ItemMixin.IsCompleted(self, database, item, character)
    end

    return StatusCompleted(item, character, CheckQuestStatus)
end
function QuestItemMixin:GetContentTuningID(database, item)
    return item.contentTuningID or self:GetTarget(database, item):GetContentTuningID();
end
function QuestItemMixin:GetLevel(database, item)
    return item.level or self:GetTarget(database, item):GetLevel();
end
function QuestItemMixin:GetRequiredLevel(database, item)
    return item.requiredLevel or self:GetTarget(database, item):GetRequiredLevel();
end
function QuestItemMixin:GetMaxLevel(database, item)
    return item.requiredLevel or self:GetTarget(database, item):GetMaxLevel();
end
function QuestItemMixin:GetLevelFlag(database, item)
    return item.levelFlag or self:GetTarget(database, item):GetLevelFlag();
end
if INTERFACE_NUMBER < 90000 then
    function QuestItemMixin:GetLink(database, item)
        return format("\124cffffff00\124Hquest:%d:%d:%d:%d:%d\124h[%s]\124h\124r", self:GetID(database, item), self:GetLevel(database, item), self:GetRequiredLevel(database, item), self:GetMaxLevel(database, item), self:GetLevelFlag(database, item), self:GetName(database, item));
    end
else
    function QuestItemMixin:GetLink(database, item)
        return format("\124cffffff00\124Hquest:%d:%d\124h[%s]\124h\124r", self:GetID(database, item), self:GetContentTuningID(database, item), self:GetName(database, item));
    end
end
function QuestItemMixin:OnClick(database, item, character, button, frame, tooltip)
    if item.onClick ~= nil then
        return ItemMixin.OnClick(self, database, item, character, button, frame, tooltip)
    end

    if self:GetTarget(database, item) and ChatEdit_TryInsertChatLink(self:GetLink(database, item)) then
        return
    end

    local questID = self:GetID(database, item)
    local questLogIndex = GetLogIndexForQuestID(questID)
    if IsModifiedClick("QUESTWATCHTOGGLE") then
        if GetQuestWatchType(questID) ~= nil then
            RemoveQuestWatch(questID)
        else
            AddQuestWatch(questID)
        end

        return
    end
    
    if questLogIndex and questLogIndex ~= 0 then
        if BtWQuestsFrame:SelectFromLink(self:GetLink(database, item)) then
            return
        end
    else
        local source = self:GetSource(database, item, character)
        if source then
            local mapID, coords = source:GetLocation()

            if mapID and coords then
                BtWQuests_ShowMapWithWaypoint(mapID, coords.x, coords.y, source:GetName())
            end
        end
    end
end
function QuestItemMixin:OnEnter(database, item, character, button, frame, tooltip)
    if item.onEnter ~= nil then
        return ItemMixin.OnEnter(self, database, item, character, button, frame, tooltip)
    end

    if tooltip ~= nil then
        local target = self:GetTarget(database, item)
        local userdata = self:GetUserdata(database, item)
        local link = userdata and userdata.link or (target and self:GetLink(database, item))
        if link then
            tooltip:SetPoint("TOPLEFT", button, "TOPRIGHT")
            tooltip:SetOwner(button, "ANCHOR_PRESERVE");
            tooltip:SetHyperlink(link, character)
        end
    end
end
function QuestItemMixin:OnLeave(database, item, character, button, frame, tooltip)
    if item.onLeave ~= nil then
        return ItemMixin.OnLeave(self, database, item, character, button, frame, tooltip)
    end

    if tooltip ~= nil then
        tooltip:Hide()
    end
end
function QuestItemMixin:GetSource(database, item, character)
    if item.source ~= nil then
        return database:CreateItem(-1, item.source, item, self:GetRoot(database, item));
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetSource(character);
    end

    return nil;
end

local ExpansionItemMixin = CreateFromMixins(TargetItemMixin);

local CategoryItemMixin = CreateFromMixins(TargetItemMixin);
function CategoryItemMixin:GetLink(database, item)
    return self:GetTarget(database, item):GetLink();
end
function CategoryItemMixin:IsMajor(database, item)
    return item.major or self:GetTarget(database, item):IsMajor();
end
function CategoryItemMixin:GetItemList(database, item, ...)
    return self:GetTarget(database, item):GetItemList(...);
end
function CategoryItemMixin:GetButtonImage(database, item)
    if item.buttonImage == nil then
        return self:GetTarget(database, item):GetButtonImage();
    end

    if type(item.buttonImage) ~= "table" then
        return item.buttonImage
    end

    return item.buttonImage.texture, unpack(item.buttonImage.texCoords)
end
function CategoryItemMixin:GetListImage(database, item)
    if item.listImage == nil then
        return self:GetTarget(database, item):GetListImage();
    end

    if type(item.listImage) ~= "table" then
        return item.listImage
    end

    return item.listImage.texture, unpack(item.listImage.texCoords)
end
function CategoryItemMixin:OnClick(database, item, character, button, frame, tooltip)
    if ChatEdit_TryInsertChatLink(self:GetLink(database, item)) then
        return
    end

    local userdata = self:GetUserdata(database, item)
    if frame:SelectFromLink(self:GetLink(database, item), userdata and userdata.scrollTo) then
        PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
        return
    end

    tooltip:Hide()
end
function CategoryItemMixin:OnEnter(database, item, character, button, frame, tooltip)
end
function CategoryItemMixin:OnLeave(database, item, character, button, frame, tooltip)
    tooltip:Hide()
end

local ChainItemMixin = CreateFromMixins(TargetItemMixin);
function ChainItemMixin:GetName(database, item, character)
    local name = TargetItemMixin.GetName(self, database, item, character)
    local uptoType = type(item.upto)
    if uptoType == "table" then
    elseif uptoType == "number" then
        local quest = database:GetQuestByID(item.upto)
        if quest then
            return string.format(L["UP_TO"], name, quest:GetName())
        end
    end
    return name
end
function ChainItemMixin:GetLink(database, item)
    return self:GetTarget(database, item):GetLink();
end
function ChainItemMixin:IsMajor(database, item)
    if item.major ~= nil then
        return item.major;
    end
    return self:GetTarget(database, item):IsMajor();
end
function ChainItemMixin:GetButtonImage(database, item)
    if item.buttonImage == nil then
        return self:GetTarget(database, item):GetButtonImage();
    end

    if type(item.buttonImage) ~= "table" then
        return item.buttonImage
    end

    return item.buttonImage.texture, unpack(item.buttonImage.texCoords)
end
function ChainItemMixin:GetListImage(database, item)
    if item.listImage == nil then
        return self:GetTarget(database, item):GetListImage();
    end

    if type(item.listImage) ~= "table" then
        return item.listImage
    end

    return item.listImage.texture, unpack(item.listImage.texCoords)
end
function ChainItemMixin:GetItem(database, item, index, character)
    return self:GetTarget(database, item):GetItem(index, character);
end
function ChainItemMixin:GetNumItems(database, item)
    return self:GetTarget(database, item):GetNumItems();
end
function ChainItemMixin:OnClick(database, item, character, button, frame, tooltip)
    if ChatEdit_TryInsertChatLink(self:GetLink(database, item)) then
        return
    end

    local userdata = self:GetUserdata(database, item)
    if frame:SelectFromLink(self:GetLink(database, item), userdata and userdata.scrollTo) then
        return
    end

    tooltip:Hide()
end
function ChainItemMixin:OnEnter(database, item, character, button, frame, tooltip)
    local userdata = self:GetUserdata(database, item)
    local link = userdata and userdata.link or self:GetLink(database, item)

    tooltip:SetPoint("TOPLEFT", button, "TOPRIGHT");
    tooltip:SetOwner(button, "ANCHOR_PRESERVE");
    tooltip:SetHyperlink(link, character);
end
function ChainItemMixin:OnLeave(database, item, character, button, frame, tooltip)
    tooltip:Hide()
end
function ChainItemMixin:IsEmbed(database, item)
    return item.embed
end
function ChainItemMixin:IsCompleted(database, item, character, ...)
    if item.completed ~= nil then
        return ItemMixin.IsCompleted(self, database, item, character);
    end

    local uptoType = type(item.upto)
    if uptoType == "table" then
    elseif uptoType == "number" then
        return character:IsQuestCompleted(item.upto)
    end

    return TargetItemMixin.IsCompleted(self, database, item, character, ...)
end

local MissionItemMixin = CreateFromMixins(TargetItemMixin);
function MissionItemMixin:IsBreadcrumb()
    return true
end

local NPCItemMixin = CreateFromMixins(TargetItemMixin);
function NPCItemMixin:GetTargetType()
    return "npc"
end
function NPCItemMixin:GetName(database, item, character)
    return string.format(L["BTWQUESTS_GO_TO"], TargetItemMixin.GetName(self, database, item, character))
end
function NPCItemMixin:IsBreadcrumb(database, item, character)
    if item.breadcrumb ~= nil then
        return item.breadcrumb;
    end

    return true
end
function NPCItemMixin:GetLocation(database, item, ...)
    if item.locations ~= nil then
        return BtWQuests_GetBestLocation(database, item.locations, ...)
    end

    local target = self:GetTarget(database, item);
    if target then
        return target:GetLocation(...);
    end

    return nil;
end
function NPCItemMixin:OnClick(database, item, character, button, frame, tooltip)
    local mapID, coords = self:GetLocation(database, item)
    if mapID and coords then
        BtWQuests_ShowMapWithWaypoint(mapID, coords.x, coords.y, self:GetName(database, item))
    end
end

local KillItemMixin = CreateFromMixins(NPCItemMixin);
function KillItemMixin:GetName(database, item, character)
    return string.format(L["BTWQUESTS_KILL"], TargetItemMixin.GetName(self, database, item, character))
end

local TalkItemMixin = CreateFromMixins(NPCItemMixin);
function TalkItemMixin:GetName(database, item, character)
    return string.format(L["BTWQUESTS_TALK_TO"], TargetItemMixin.GetName(self, database, item, character))
end

local ObjectItemMixin = CreateFromMixins(NPCItemMixin);
function ObjectItemMixin:GetTargetType()
    return "object"
end

local LootItemMixin = CreateFromMixins(ObjectItemMixin);
function LootItemMixin:GetName(database, item, character)
    return string.format(L["BTWQUESTS_LOOT"], TargetItemMixin.GetName(self, database, item, character))
end

local LevelItemMixin = CreateFromMixins(ItemMixin);
function LevelItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    return string.format(L["LEVEL_TO"], item.level);
end
function LevelItemMixin:IsActive(database, item, character)
    if self:IsCompleted(database, item, character) then
        return false;
    end

    return true
end
function LevelItemMixin:IsCompleted(database, item, character)
    if item.atmost then
        return character:AtmostLevel(item.level);
    else
        return character:AtleastLevel(item.level);
    end
end

local ExperienceItemMixin = CreateFromMixins(ItemMixin);
function ExperienceItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    local amount;
    if item.amounts then
        local level = math.min(math.max(character:GetLevel(), item.minLevel), item.maxLevel) - item.minLevel + 1
        if level > #item.amounts then
            if character:GetLevel() > OUTDATED_LEVEL and item.outdated then
                amount = item.outdated;
            else
                amount = item.amounts[#item.amounts];
            end
        else
            amount = item.amounts[level];
        end
    else
        amount = item.amount;
    end

    local modifier = 1 + character:GetXPModifier();
    if character:IsWarModeDesired() and not item.noWarModeBonus then
        modifier = modifier + (character:GetWarModeRewardBonus() * 0.01);
    end

    return format(GAIN_EXPERIENCE, math.floor(amount * modifier + .5))
end
function ExperienceItemMixin:Visible(database, item, character)
    return character:GetLevel() < (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or MAX_PLAYER_LEVEL)
end
function ExperienceItemMixin:IsActive(database, item, character)
    return true
end
function ExperienceItemMixin:IsCompleted(database, item, character)
    return false
end

local Races = {}
for i=1,100 do
    local race = C_CreatureInfo.GetRaceInfo(i);
    if race then
        Races[race.clientFileString] = race
    end
end
local RaceItemMixin = CreateFromMixins(ItemMixin);
function RaceItemMixin:GetName(database, item, character, variation)
    local name
    if item.name then
        name = ItemMixin.GetName(self, database, item, character);
    elseif item.id then
        local race = Races[item.id] or C_CreatureInfo.GetRaceInfo(item.id);
        name = race and race.raceName
    elseif item.ids then
        local names = {};
        for id in ipairs(item.ids) do
            local race = Races[id] or C_CreatureInfo.GetRaceInfo(id);
            if race and race.raceName then
                names[#names+1] = race.raceName
            end
        end
        if #names > 1 then
            local past = table.remove(names)
            name = table.concat(names, ", ") .. ", and " .. past
        else
            name = table.concat(names, ", ")
        end
    end
    
    return name or ""
end
function RaceItemMixin:IsCompleted(database, item, character)
    if item.id then
        return character:IsRace(item.id);
    else
        return character:InRaces(item.ids);
    end
end

local ClassItemMixin = CreateFromMixins(ItemMixin);
function ClassItemMixin:GetName(database, item, character, variation)
    local name
    if item.name then
        name = ItemMixin.GetName(self, database, item, character);
    elseif item.id then
        local class = C_CreatureInfo.GetClassInfo(item.id);
        name = class and class.className
    elseif item.ids then
        local names = {};
        for id in ipairs(item.ids) do
            local class = C_CreatureInfo.GetClassInfo(id);
            if class and class.className then
                names[#names+1] = class.className
            end
        end
        if #names > 1 then
            local past = table.remove(names)
            name = table.concat(names, ", ") .. ", and " .. past
        else
            name = table.concat(names, ", ")
        end
    end
    
    return name or ""
end
function ClassItemMixin:IsCompleted(database, item, character)
    if item.id then
        return character:IsClass(item.id);
    else
        return character:InClasses(item.ids);
    end
end

local FactionItemMixin = CreateFromMixins(ItemMixin);
function FactionItemMixin:GetName(database, item, character, variation)
    local name
    if item.name then
        name = ItemMixin.GetName(self, database, item, character);
    elseif item.id == "Horde" then
        name = FACTION_HORDE
    elseif item.id == "Alliance" then
        name = FACTION_ALLIANCE
    end
    
    return name
end
function FactionItemMixin:IsCompleted(database, item, character)
    return character:IsFaction(item.id);
end

local ReputationItemMixin = CreateFromMixins(ItemMixin);
function ReputationItemMixin:GetName(database, item, character, variation)
    local name
    if item.name then
        name = ItemMixin.GetName(self, database, item, character);
    end

    local factionName, standing, barMin, _, value = (character or BtWQuestsCharacters:GetPlayer()):GetFactionInfoByID(item.id)
    if factionName == nil then
        factionName = L["UNKNOWN"]
    end

    if item.standing == nil then
        if item.amount ~= nil then
            local amount = item.amount
            -- if character:IsRace(BTWQUESTS_RACE_ID_HUMAN) then
            --     amount = amount * 1.1
            -- end
            name = string.format(L["REPUTATION_WITH"], amount, factionName)
        elseif variation == "reward" or variation == "prerequisite" then
            name = string.format(L["BTWQUESTS_PREFIX"], L["BTWQUESTS_FACTION"], factionName)
        else
            name = factionName;
        end
    else
        local gender = character:GetSex()
        local standingText = getglobal("FACTION_STANDING_LABEL" .. item.standing .. (gender == 3 and "_FEMALE" or ""))
        
        if item.amount ~= nil then
            name = string.format(name or L["BTWQUESTS_REPUTATION_AMOUNT_STANDING"], item.amount, standingText, factionName)
        else
            name = string.format(name or L["BTWQUESTS_REPUTATION_STANDING"], standingText, factionName)
        end
    end

    return name
end
function ReputationItemMixin:IsActive(database, item, character)
    assert(character ~= nil);

    if self:IsCompleted(database, item, character) then
        return false;
    end

    if item.active ~= nil then
        return database:EvalRequirement(item.active, self, character, true);
    end

    return true
end
function ReputationItemMixin:IsCompleted(database, item, character)
    local function Callback(id, item, character)
        local factionName, standing, barMin, _, value = character:GetFactionInfoByID(item.id)
        
        if standing == nil then
            return false
        elseif item.amount ~= nil then
            return standing > item.standing or (standing == item.standing and value - barMin >= item.amount)
        else
            return standing >= item.standing
        end
    end

    return StatusCompleted(item, character, Callback)
end

local FriendshipItemMixin = CreateFromMixins(ItemMixin);
function FriendshipItemMixin:GetName(database, item, character)
    local name
    if item.name then
        name = ItemMixin.GetName(self, database, item, character);
    end

    return name
end
function FriendshipItemMixin:IsActive(database, item, character)
    assert(character ~= nil);

    if self:IsCompleted(database, item, character) then
        return false;
    end

    if item.active ~= nil then
        return database:EvalRequirement(item.active, self, character, true);
    end
    
    return true
end
function FriendshipItemMixin:IsCompleted(database, item, character)
    local factionInfo = character:GetFriendshipReputation(item.id)
    
    return (factionInfo and factionInfo.standing or 0) >= item.amount
end

local AchievementItemMixin = CreateFromMixins(ItemMixin);
function AchievementItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    local id = self:GetID(database, item);
    if item.criteria then
        return select(1, GetAchievementCriteriaInfo(id, item.criteria))
    elseif item.criteriaId then
        return select(1, GetAchievementCriteriaInfoByID(id, item.criteriaId))
    elseif item.reward then
        return select(11, GetAchievementInfo(id))
    else
        return select(2, GetAchievementInfo(id))
    end
end
function AchievementItemMixin:IsActive(database, item, character)
    return true
end
function AchievementItemMixin:IsCompleted(database, item, character)
    if item.criteria then
        if item.completed == false then
            return not select(3, character:GetAchievementCriteriaInfo(item.id, item.criteria))
        else
            return select(3, character:GetAchievementCriteriaInfo(item.id, item.criteria))
        end
    elseif item.criteriaId then
        if item.completed == false then
            return not select(3, character:GetAchievementCriteriaInfoByID(item.id, item.criteriaId))
        else
            return select(3, character:GetAchievementCriteriaInfoByID(item.id, item.criteriaId))
        end
    elseif item.anyone then
        if item.completed == false then
            return not select(4, GetAchievementInfo(item.id))
        else
            return select(4, GetAchievementInfo(item.id))
        end
    else
        if item.completed == false then
            return not select(13, character:GetAchievementInfo(item.id))
        else
            return select(13, character:GetAchievementInfo(item.id))
        end
    end
end

local GetCoinTextureString = C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString or GetCoinTextureString;
local MoneyItemMixin = CreateFromMixins(ItemMixin);
function MoneyItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    if item.amounts then
        local level = math.min(math.max(character:GetLevel(), item.minLevel), item.maxLevel) - item.minLevel + 1
        return GetCoinTextureString(item.amounts[level])
    end

    return GetCoinTextureString(item.amount)
end
function MoneyItemMixin:IsCompleted(database, item, character)
    return false
end
function MoneyItemMixin:IsActive(database, item, character)
    return true
end

local CurrencyItemMixin = CreateFromMixins(ItemMixin);
function CurrencyItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    local name = L["BTWQUESTS_CURRENCY"];
    local info = C_CurrencyInfo.GetBasicCurrencyInfo(item.id, item.amount);
    return format(name, info.icon, info.displayAmount, info.name);
end
function CurrencyItemMixin:IsCompleted(database, item, character)
    return character:GetCurrencyQuantity(item.id) >= item.amount
end
function CurrencyItemMixin:IsActive(database, item, character)
    return true
end

local TimeItemMixin = CreateFromMixins(ItemMixin);
function TimeItemMixin:GetName(database, item, character)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end

    local total,days,hours,minutes,seconds = difftime(item.time, GetServerTime())

    if total <= 0 then
        return L["BTWQUESTS_PASSED"]
    end

    days = floor(total / 86400)
    total = total % 86400

    hours = floor(total / 3600)
    total = total % 3600

    minutes = floor(total / 60)

    seconds = total % 60

    if days ~= nil and days ~= 0 then
        return string.format(L["BTWQUESTS_COUNTDOWN_DHM"], days, hours, minutes)
    elseif hours ~= nil and hours ~= 0 then
        return string.format(L["BTWQUESTS_COUNTDOWN_HMS"], hours, minutes, seconds)
    elseif minutes ~= nil and minutes ~= 0 then
        return string.format(L["BTWQUESTS_COUNTDOWN_MS"], minutes, seconds)
    else
        return string.format(L["BTWQUESTS_COUNTDOWN_S"], seconds)
    end
end
function TimeItemMixin:IsCompleted(database, item, character)
    return GetServerTime() >= item.time
end
function TimeItemMixin:IsActive(database, item, character)
    return true
end

local TimeZoneItemMixin = CreateFromMixins(ItemMixin);
function TimeZoneItemMixin:IsCompleted(database, item, character)
    return BtWQuests_GetTimeZone(character:GetRealm()) == item.timezone
end

local CoordsItemMixin = CreateFromMixins(ItemMixin);
function CoordsItemMixin:IsBreadcrumb(database, item, character)
    if item.breadcrumb ~= nil then
        return item.breadcrumb;
    end

    return true
end
function CoordsItemMixin:GetLocation(database, item, relativeMapID, ...)
    if item.locations ~= nil then
        return BtWQuests_GetBestLocation(database, item.locations, relativeMapID, ...)
    end

    if relativeMapID == nil or item.mapID == relativeMapID then
        return item.mapID, CreateVector2D(item.x, item.y)
    else
        local sourceMapID, sourceCoords = self:GetLocation(database, item)
        if sourceCoords == nil then
            return nil
        end

        local continentID, coords = C_Map.GetWorldPosFromMapPos(sourceMapID, sourceCoords)
        if coords == nil then
            return nil
        end

        local _, coords = C_Map.GetMapPosFromWorldPos(continentID, coords, relativeMapID)
        if coords == nil then
            return nil
        end

        return relativeMapID, coords
    end
end
function CoordsItemMixin:OnClick(database, item, character, button, frame, tooltip)
    local mapID, coords = self:GetLocation(database, item)
    if mapID and coords then
        BtWQuests_ShowMapWithWaypoint(mapID, coords.x, coords.y, self:GetName(database, item))
    end
end

local PetItemMixin = CreateFromMixins(ItemMixin);
function PetItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local id = self:GetID(database, item)
    local name = C_PetJournal.GetPetInfoBySpeciesID(id) or ""
    if variation == "reward" or variation == "prerequisite" then
        return string.format(L["BTWQUESTS_PREFIX"], L["BTWQUESTS_PET"], name)
    elseif item.status == 'summon' then
        return string.format(L["BTWQUESTS_SUMMON"], name)
    else
        return name
    end
end
function PetItemMixin:IsCompleted(database, item, character)
    return StatusCompleted(item, character, CheckPetStatus)
end

local MountItemMixin = CreateFromMixins(ItemMixin);
function MountItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local id = self:GetID(database, item)
    local name = C_MountJournal.GetMountInfoByID(id) or ""
    if variation == "reward" then
        return string.format(L["BTWQUESTS_PREFIX"], L["BTWQUESTS_MOUNT"], name)
    else
        return name
    end
end
function MountItemMixin:IsCompleted(database, item, character)
    return StatusCompleted(item, character, CheckMountStatus)
end

local ToyItemMixin = CreateFromMixins(ItemMixin);
function ToyItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local name = select(2, C_ToyBox.GetToyInfo(item.id or item.ids[1])) or ""
    if variation == "reward" then
        return format(L["BTWQUESTS_PREFIX"], L["BTWQUESTS_TOY"], name)
    else
        return name
    end
end
function ToyItemMixin:IsCompleted(database, item, character)
    return StatusCompleted(item, character, PlayerHasToy)
end

local AuraItemMixin = CreateFromMixins(ItemMixin);
function AuraItemMixin:IsCompleted(database, item, character)
    local id = self:GetID(database, item);
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        return not not C_UnitAuras.GetPlayerAuraBySpellID(id)
    else
        local index = 1
        local name, _, count, _, _, _, _, _, _, spellId = UnitAura("player", index)
        while name do
            if spellId == id then
                return true
            end
            index = index + 1
            name, _, count, _, _, _, _, _, _, spellId = UnitAura("player", index)
        end
    end
end

local ProfessionItemMixin = CreateFromMixins(ItemMixin);
function ProfessionItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local id = self:GetID(database, item)
    local name = C_TradeSkillUI.GetTradeSkillDisplayName(id)
    if item.level then
        return string.format(L["BTWQUESTS_SKILL_LEVEL"], item.level, name or id)
    else
        return name or id
    end
end
function ProfessionItemMixin:IsCompleted(database, item, character)
    local id = self:GetID(database, item)
    if item.level then
        local level, maxLevel = character:GetSkillInfo(id)
        return level >= item.level
    else
        local level, maxLevel = character:GetSkillInfo(id)
        if level ~= 0 then
            return true
        else
            return character:HasProfession(id) -- Fallback
        end
    end
end

local ItemItemMixin = CreateFromMixins(ItemMixin);
function ItemItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local id = self:GetID(database, item);
    local name = GetItemInfo(id);
    if variation == "reward" then
        return name or L["UNKNOWN"];
    else
        return string.format(L["BTWQUESTS_COLLECT"], name or L["UNKNOWN"]);
    end
end
function ItemItemMixin:IsCompleted(database, item, character)
    if character:IsPlayer() then
        return StatusCompleted(item, character, CheckItemStatus);
    end
end

local EquippedItemMixin = CreateFromMixins(ItemMixin);
function EquippedItemMixin:GetName(database, item, character, variation)
    if item.name then
        return ItemMixin.GetName(self, database, item, character);
    end
    
    local id = self:GetID(database, item);
    local name = GetItemInfo(id);
    return string.format(L["BTWQUESTS_EQUIP"], name);
end
function EquippedItemMixin:IsCompleted(database, item, character)
    if character:IsPlayer() then
        return StatusCompleted(item, character, IsEquippedItem);
    end
end

local QuestLineItemMixin = CreateFromMixins(ItemMixin);
function QuestLineItemMixin:IsCompleted(database, item, character)
    if item.questID and (character:IsQuestActive(item.questID) or character:IsQuestCompleted(item.questID)) then
        return true
    end

    if character:IsPlayer() then
        local questLines = C_QuestLine.GetAvailableQuestLines(item.mapID)
        for _,questLine in ipairs(questLines) do
            if questLine.questLineID == item.id then
                if item.questID == nil then
                    return true
                else
                    return questLine.questID == item.questID
                end
            end
        end
    end

    return false
end

local FollowerItemMixin = CreateFromMixins(ItemMixin);
function FollowerItemMixin:GetName(database, item, character)
    local follower = C_Garrison.GetFollowerInfo(item.id)
    return follower and follower.name
end
function FollowerItemMixin:IsCompleted(database, item, character)

    return false
end
local GarrisonTalentTreeItemMixin = CreateFromMixins(ItemMixin);
function GarrisonTalentTreeItemMixin:GetName(database, item, character)
    local info = C_Garrison.GetTalentTreeInfo(item.id)
    if item.rank then
        return string.format(L["RANK"], info and info.title or L["UNKNOWN"], item.rank)
    else
        return info and info.title or L["UNKNOWN"]
    end
end
function GarrisonTalentTreeItemMixin:IsActive(database, item, character)
	local treeInfo = C_Garrison.GetTalentTreeInfo(item.id);
    for _,talent in ipairs(treeInfo.talents) do
        if talent.tier + 1 == item.rank then
            return talent.isBeingResearched
        end
    end

    return false
end
function GarrisonTalentTreeItemMixin:IsCompleted(database, item, character)
    local rank = C_Garrison.GetTalentPointsSpentInTalentTree(item.id)
    if item.rank then
        return item.rank <= rank
    else
        return rank >= 0
    end
end
local GarrisonTalentItemMixin = CreateFromMixins(ItemMixin);
function GarrisonTalentItemMixin:GetName(database, item, character)
    local info = C_Garrison.GetTalentInfo(item.id)
    if item.rank then
        return string.format(L["RESEARCH_RANK"], info and info.name or L["UNKNOWN"], item.rank)
    else
        return string.format(L["RESEARCH"], info and info.name or L["UNKNOWN"])
    end
end
function GarrisonTalentItemMixin:IsActive(database, item, character)
	local info = C_Garrison.GetTalentInfo(item.id);
    return info.isBeingResearched
end
function GarrisonTalentItemMixin:IsCompleted(database, item, character)
	local info = C_Garrison.GetTalentInfo(item.id);
    if item.rank then
        return item.rank <= info.talentRank
    else
        return info.researched
    end
end
local CampaignItemMixin = CreateFromMixins(ItemMixin);
function CampaignItemMixin:GetName(database, item, character)
    local info = C_CampaignInfo.GetCampaignInfo(item.id)
    return info and info.name or L["UNKNOWN"]
end

local AreaItemMixin = CreateFromMixins(CoordsItemMixin);
function AreaItemMixin:GetName(database, item, character)
    return string.format(L["BTWQUESTS_GO_TO"], (C_Map.GetAreaInfo(item.id)))
end
local ChromieTimeItemMixin = CreateFromMixins(ItemMixin);
function ChromieTimeItemMixin:IsCompleted(database, item, character)
    local chromieId = character:GetChromieTimeID()
    if item.id ~= -1 then
        return item.id == chromieId
    else
        return chromieId > 0
    end
end

local DatabaseItemMetatable = {};
function DatabaseItemMetatable.__index(tbl, key)
    local details;
    if tbl.item.type ~= nil then
        details = tbl.database.ItemTypes[tbl.item.type];
    else
        details = ItemMixin;
    end

    return details[key] and function (self, ...)
        return details[key](details, tbl.database, tbl.item, ...);
    end
end

local function CreateTable(database, mixin)
    local target, sources = {}, {};
    setmetatable(target, {
        __index = function (self, key)
            if key ~= nil then
                local tbl;
                for _,source in ipairs(sources) do
                    if source[key] then
                        tbl = Mixin({database = database, id = key}, source[key], mixin);
                        break;
                    end
                end
                self[key] = tbl;
                return tbl;
            end
        end,
    });
    return target, sources;
end
local function SplitRanges(...)
    local i = 0
    local tbl = {...}
    return function ()
        i = i + 1

        local range = tbl[i]
        if not range then
            return nil
        end
        local from, to = strsplit("-", range, 2)
        if to == nil then
            to = from
        end
        from = tonumber(from)
        to = tonumber(to)
        assert(from and to, "Range number be number-number")
        return from, to
    end
end
local function GetRanges(str)
    return SplitRanges(strsplit(",", str))
end

local ConditionCacheChildMetatable = {
}
local Database = {};
function Database:Init()
    do
        local database = self
        self.ConditionCache = setmetatable({}, {
            __index = function (self, character)
                if type(character) == "table" then
                    local result = setmetatable({}, {
                        __index = function (self, id)
                            if type(id) == "number" then
                                local result = database:GetData("condition", id):EvalFor(character);
                                self[id] = result
                                return result
                            end
                        end
                    });
                    self[character] = result
                    return result
                end
            end
        });
    end
    self.DataTypes = {};
    self.ItemTypes = {};
    self.buckets = {};
    self.questCache = {};
    self.QuestIDToItem = {};
    self.MapIDToItem = {};
    self.Continents = {};
end
function Database:RegisterDataType(dataType, mixin)
    self.DataTypes[dataType] = mixin;
    self[dataType], self[dataType.."List"] = CreateTable(self, mixin);
    self[dataType.."Ranges"] = {}
end
function Database:AddData(dataType, id, item)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    self[dataType][tonumber(id)] = CreateFromMixins({database = self, id = tonumber(id), items = {}}, item, self.DataTypes[dataType]);
    return self[dataType][tonumber(id)];
end
function Database:AddDataTable(dataType, items)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    local list = self[dataType.."List"];
    list[#list+1] = items;
end
function Database:UpdateDataTable(dataType, items)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    local list = self[dataType.."List"];
    for _,listItems in pairs(list) do
        for itemID,item in pairs(items) do
            if listItems[itemID] then
                Mixin(listItems[itemID], item);
            end
        end
    end
end
function Database:HasDataType(dataType)
    return self[dataType] ~= nil;
end
function Database:GetData(dataType, id)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    return self[dataType][tonumber(id)];
end
function Database:AddDataRanges(dataType, str, target)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    assert(target ~= nil, format("Must have a target"))
    local tbl = self[dataType.."Ranges"];

    for from,to in GetRanges(str) do
        tbl[#tbl+1] = {from=from,to=to,target=target}
    end
    table.sort(tbl, function (a, b)
        return a.from < b.from
    end)
end
function Database:LoadExpansionForDataID(dataType, id)
    assert(self[dataType] ~= nil, format("Missing data type %s", dataType));
    local tbl = self[dataType.."Ranges"];
    id = tonumber(id)
    for _,item in ipairs(tbl) do
        if item.from <= id and item.to >= id then
            self:GetExpansionByID(item.target):Load()
        end
    end
end
function Database:RegisterItemType(itemType, mixin)
    self.ItemTypes[itemType] = mixin;
end
function Database:GetItemType(itemType)
    return itemType and self.ItemTypes[itemType] or ItemMixin;
end
function Database:CreateItem(index, item, parent, root)
    item.index = index;
    item.parent = parent;
    item.root = root or parent;

    local result = {database = self, item = item};
    setmetatable(result, DatabaseItemMetatable);
    return result;
end
function Database:GetItemTypeDetails(itemType)
    local details = self.ItemTypes[itemType];
    assert(details ~= nil, format("Unknown item type %s", itemType));
    return details;
end
function Database:IsItemValidForCharacter(item, character) -- In effect its the same as ItemMixin:IsValidForCharacter
    if item == nil then
        return false;
    end

    if item.restrictions ~= nil and not self:EvalRequirement(item.restrictions, item, character) then
        return false;
    end
    
    return true;
end
function Database:FilterItems(items, character, tbl)
    tbl = tbl or {}
    if items[1] == nil then
        if self:IsItemValidForCharacter(items, character) then
            tbl[#tbl+1] = items
        end
    else
        for _,item in ipairs(items) do
            if self:IsItemValidForCharacter(item, character) then
                tbl[#tbl+1] = item
            end
        end
    end
    return tbl
end
-- /dump BtWQuestsDatabase:EvalRequirement()
function Database:EvalRequirement(requirement, item, character, one)
    if type(requirement) == "boolean" then
        return requirement
    elseif type(requirement) == "number" then
        return self:EvalCondition(requirement, character)
    elseif type(requirement) == "function" then
        return self:EvalRequirement(requirement(item, character), item, character)
    elseif type(requirement) == "table" then
        if requirement[1] ~= nil then
            one = one and true or false -- Should we only require 1 item to be true

            local filtered = {}
            for _, v in ipairs(requirement) do
                if self:IsItemValidForCharacter(v, character) then
                    table.insert(filtered, v)
                end
            end

            for _, v in ipairs(filtered) do
                if self:EvalItemRequirement(v, character) == one then
                    return one
                end
            end
            
            return not one
        else
            return self:EvalItemRequirement(requirement, character)
        end
    end
    
    assert(requirement == nil, "Invalid requirement type " .. type(requirement))
end
function Database:EvalItemRequirement(item, character)
    local item = GetVariation(self, item, character)
    
    if item.type == "quest" then
        local ids = item.ids or {item.id}
        local amount = 0
        for _,id in ipairs(ids) do
            if CheckQuestStatus(id, item, character) then
                amount = amount + 1
            end
        end

        return CheckStatusCount(amount, item)
    elseif item.type == "chain" then
        local ids = item.ids or {item.id}
        local amount = 0
        for _,id in ipairs(ids) do
            if CheckChainStatus(id, item, character) then
                amount = amount + 1
            end
        end

        return CheckStatusCount(amount, item)
    elseif item.type == "category" then
        local ids = item.ids or {item.id}
        local amount = 0
        for _,id in ipairs(ids) do
            if CheckCategoryStatus(id, item, character) then
                amount = amount + 1
            end
        end

        return CheckStatusCount(amount, item)
    elseif item.type ~= nil then
        assert(self.ItemTypes[item.type] ~= nil, format("Unknown type %s", item.type));
        return self.ItemTypes[item.type]:IsCompleted(self, item, character);
    else
        return self:EvalRequirement(item.onEval or item.completed, item, character)
    end
end
function Database:EvalText(text, item, character)
    local result = text;

    if text == nil then
        result = "Unnamed"
    elseif type(text) == "function" then
        result = self:EvalText(text(item, character), item, character)
    elseif type(text) == "table" then
        if text[1] ~= nil then
            result = "Unnamed"

            for _,t in ipairs(text) do
                if self:IsItemValidForCharacter(t, character) then
                    result = self:EvalItemName(t, character)
                    break;
                end
            end
        else
            result = self:EvalItemName(text, character)
        end
    end
    
    return result ~= nil and tostring(result) or nil;
end
function Database:EvalItemName(item, character)
    if item == nil then
        return "Unnamed"
    end

    if item.name then
        return self:EvalText(item.name, item, character)
    end

    if self.DataTypes[item.type] then
        local item = self:GetData(item.type, item.id or item.ids[1]);
        if item == nil then
            return "Unnamed"
        end

        return item:GetName();
    end
    
    assert(self.ItemTypes[item.type] ~= nil, format("Unknown type %s", item.type));
    return self.ItemTypes[item.type]:GetName(self, item, character);
end

function Database:AddCondition(id, item)
    return self:AddData("condition", id, item);
end
function Database:AddConditionTable(items)
    self:AddDataTable("condition", items);
end
function Database:GetConditionByID(id)
    return self:GetData("condition", id);
end
function Database:EvalCondition(id, character)
    return self.ConditionCache[character][id];
end
do
    local eventHandler = CreateFrame("Frame")
    eventHandler:SetScript("OnEvent", function ()
        wipe(Database.ConditionCache[BtWQuestsCharacters:GetPlayer()])
    end)
    function Database:RegisterConditionClearCacheEvent(event)
        eventHandler:RegisterEvent(event)
    end
end

-- Expansion
function Database:AddExpansion(id, item)
    local expansion = self:GetData("expansion", id);
    if not expansion then
        if item.name == nil then
            item.name = L['BTWQUESTS_EXPANSION_NAME' .. id];
        end

        expansion = self:AddData("expansion", id, item);
    end

    return expansion;
end
function Database:AddExpansionsTable(items)
    self:AddDataTable("expansion", items);
end
function Database:GetExpansionByID(id)
    return self:GetData("expansion", id);
end
function Database:AddExpansionItem(id, t)
    local expansion = self:GetData("expansion", id);
    table.insert(expansion.items, t);
end
function Database:AddExpansionItems(id, t)
    for _,v in ipairs(t) do
        self:AddExpansionItem(id, v);
    end
end
function Database:HasMultipleExpansion()
    local first = next(self.expansion)

    return first ~= nil and next(self.expansion, first) ~= nil
end
function Database:GetFirstExpansion()
    return (select(2, next(self.expansion)))
end
function Database:GetLoadedExpansion()
    local loadedExpansion = nil

    for i=0,LE_EXPANSION_LEVEL_CURRENT do
        local expansion = self:GetExpansionByID(i);
        if expansion and expansion:IsLoaded() then
            loadedExpansion = loadedExpansion == nil and expansion or false
        end
    end

    return loadedExpansion
end
function Database:HasExpansion(id)
    local expansion = self:GetData("expansion", id);
    return expansion ~= nil -- and expansion.items ~= nil and #expansion.items > 0;
end
function Database:GetExpansionList()
    local items = {}

    for i=0,LE_EXPANSION_LEVEL_CURRENT do
        local expansion = self:GetExpansionByID(i);
        if expansion then
            items[#items+1] = expansion;
        end
    end

    return items
end
local chromieTimeExpansionMap = {
    [5] = 0,
    [6] = 1,
    [7] = 2,
    [8] = 4,
    [9] = 5,
    [10] = 6,
}
function Database:GetBestExpansionForCharacter(character)
    local first = next(self.expansion)
    if next(self.expansion, first) == nil then
        return first
    end

    -- Do fancy chromie time stuff here
    local chromieTimeID = character:GetChromieTimeID()
    local expansion = chromieTimeExpansionMap[chromieTimeID]
    if self:HasExpansion(expansion) then
        return expansion
    end

    -- Not in chromie time so use player level
    local playerLevel = character:GetLevel()
    expansion = GetExpansionForLevel(playerLevel)
    if self:HasExpansion(expansion) then
        return expansion
    end
    -- Find the best expansion closest to the players current level
    for variance = 1,GetNumExpansions()-1 do
        if expansion+variance < GetNumExpansions() and self:HasExpansion(expansion+variance) then
            return expansion+variance
        end
        if expansion-variance >= 0 and self:HasExpansion(expansion-variance) then
            return expansion-variance
        end
    end

    return first
end

function Database:AddCategory(id, item)
    return self:AddData("category", id, item);
end
function Database:AddCategoriesTable(items)
    self:AddDataTable("category", items);
end
function Database:GetCategoryByID(id)
    return self:GetData("category", id);
end
function Database:IsCategoryActive(id, character)
    local item = self:GetCategoryByID(id)
    if item == nil then
        return nil
    end

    return item:IsActive(character)
end
function Database:IsCategoryCompleted(id, character)
    local item = self:GetCategoryByID(id)
    if item == nil then
        return nil
    end

    return item:IsCompleted(character)
end
function Database:GetCategoryName(id)
    if not id then
        return nil;
    end
    
    local item = self:GetCategoryByID(id);
    if not item then
        return nil;
    end
    
    return item:GetName();
end
function Database:LoadCategory(id)
    self:LoadExpansionForDataID("category", id)
    return self:GetData("category", id);
end
function Database:AddCategoryRanges(str, target)
    self:AddDataRanges("category", str, target)
end

function Database:AddChain(id, item)
    return self:AddData("chain", id, item);
end
function Database:AddChainsTable(items)
    self:AddDataTable("chain", items);
end
function Database:GetChainByID(id)
    return self:GetData("chain", id);
end
function Database:IsChainActive(chainID, character)
    local chain = self:GetChainByID(chainID)
    if chain == nil then
        return nil
    end

    return chain:IsActive(character)
end
function Database:IsChainCompleted(chainID, character)
    local chain = self:GetChainByID(chainID)
    if chain == nil then
        return nil
    end

    return chain:IsCompleted(character)
end
function Database:GetChainName(id)
    if not id then
        return nil;
    end
    
    local item = self:GetChainByID(id);
    if not item then
        return nil;
    end
    
    return item:GetName();
end
function Database:LoadChain(id)
    self:LoadExpansionForDataID("chain", id)
    return self:GetData("chain", id);
end
function Database:AddChainRanges(str, target)
    self:AddDataRanges("chain", str, target)
end

function Database:AddQuest(id, item)
    return self:AddData("quest", id, item);
end
function Database:AddQuestsTable(items)
    self:AddDataTable("quest", items);
end
function Database:UpdateQuestsTable(items)
    self:UpdateDataTable("quest", items);
end
function Database:GetQuestByID(id)
    return self:GetData("quest", id);
end
function Database:GetQuestName(id)
    if not id then
        return nil;
    end
    
    local quest = self:GetQuestByID(id);
    if not quest then
        return nil;
    end
    
    return quest:GetName();
end


function Database:AddQuestItem(id, t, replace)
    if self.QuestIDToItem[id] == nil or replace then
        self.QuestIDToItem[id] = {}
    end

    table.insert(self.QuestIDToItem[id], t)
end
function Database:AddQuestItems(id, t, replace)
    if self.QuestIDToItem[id] == nil or replace then
        self.QuestIDToItem[id] = {}
    end
    
    for _,v in ipairs(t) do
        self:AddQuestItem(id, v)
    end
end
function Database:AddQuestItemsForOtherChain(chainID, otherChain, replace)
    local chain = self:GetChainByID(otherChain)
    assert(chain ~= nil)

    local items = chain.items

    local index = 1
    local item = items[index]
    while item do
        if item[1] ~= nil then
            for _,subitem in ipairs(item) do
                local target = {
                    type = "chain",
                    id = chainID,
                    restrictions = subitem.restrictions
                }
    
                local ids = subitem.ids or {subitem.id}
                for _,id in ipairs(ids) do
                    self:AddQuestItem(id, target, replace)
                end
            end
        elseif item.type == "quest" then
            local target = {
                type = "chain",
                id = chainID,
                restrictions = item.restrictions
            }

            local ids = item.ids or {item.id}
            for _,id in ipairs(ids) do
                self:AddQuestItem(id, target, replace)
            end
        end

        index = index + 1
        item = items[index]
    end
end
function Database:AddQuestItemsForChain(chainID, replace)
    local chain = self:GetChainByID(chainID)
    assert(chain ~= nil)

    local items = chain.items

    local index = 1
    local item = items[index]
    while item do
        if item[1] ~= nil then
            for _,subitem in ipairs(item) do
                if subitem.type == "quest" then
                    local target = {
                        type = "chain",
                        id = chainID,
                        restrictions = subitem.restrictions
                    }
        
                    local ids = subitem.ids or {subitem.id}
                    for _,id in ipairs(ids) do
                        self:AddQuestItem(id, target, replace)
                    end
                end
            end
        elseif item.variations then
            for _,variation in ipairs(item.variations) do
                if variation.type == "quest" or (variation.type == nil and item.type == "quest") then
                    local target = {
                        type = "chain",
                        id = chainID,
                        restrictions = variation.restrictions or item.restrictions
                    }
        
                    local ids = variation.ids or {variation.id}
                    for _,id in ipairs(ids) do
                        self:AddQuestItem(id, target, replace)
                    end
                end
            end
        elseif item.type == "quest" then
            local target = {
                type = "chain",
                id = chainID,
                restrictions = item.restrictions
            }

            local ids = item.ids or {item.id}
            for _,id in ipairs(ids) do
                self:AddQuestItem(id, target, replace)
            end
        end

        index = index + 1
        item = items[index]
    end
end
function Database:GetQuestItem(questID, character)
    questID = tonumber(questID)
    local item = self.QuestIDToItem[questID]
    
    if item == nil then
        return nil
    end

    for i = 1,#item do
        if self:IsItemValidForCharacter(item[i], character) then
            return self:CreateItem(0, item[i]);
        end
    end

    return nil
end

function Database:AddMission(id, item)
    return self:AddData("mission", id, item);
end
function Database:AddMissionsTable(items)
    self:AddDataTable("mission", items);
end
function Database:UpdateMissionsTable(items)
    self:UpdateDataTable("mission", items);
end
function Database:GetMissionByID(id)
    return self:GetData("mission", id);
end
function Database:GetMissionName(id)
    if not id then
        return nil;
    end
    
    local item = self:GetMissionByID(id);
    if not item then
        return nil;
    end
    
    return item:GetName();
end


function Database:AddNPC(id, item)
    return self:AddData("npc", id, item);
end
function Database:AddNPCsTable(items)
    self:AddDataTable("npc", items);
end
function Database:UpdateNPCsTable(items)
    self:UpdateDataTable("npc", items);
end
function Database:GetNPCByID(id)
    return self:GetData("npc", id);
end

function Database:AddObject(id, item)
    return self:AddData("object", id, item);
end
function Database:AddObjectsTable(items)
    self:AddDataTable("object", items);
end
function Database:UpdateObjectsTable(items)
    self:UpdateDataTable("object", items);
end
function Database:GetObjectByID(id)
    return self:GetData("object", id);
end

-- Search
function Database:AddSearchBucket(key, t)
    if self.buckets[key] == nil then
        self.buckets[key] = {}
    end

    local u = self.buckets[key]
    for _,v in ipairs(t) do
        u[#u+1] = v
        -- table.insert(u,v)
    end
end
function Database:AddSearchBuckets(t)
    for k,v in pairs(t) do
        self:AddSearchBucket(k,v)
    end
end
function Database:SearchScore(a, b)
    local startChar, endChar = b:find(a)
    if not startChar then
        return 0
    end

    return (endChar - startChar + 1) / b:len()
end
function Database:SearchTargetExists(item)
    local _, itemType, itemID = strsplit(':', item.link)
    if itemType == "expansion" then
        return self:GetExpansionByID(tonumber(itemID)) ~= nil
    elseif itemType == "category" then
        return self:GetCategoryByID(tonumber(itemID)) ~= nil
    elseif itemType == "chain" then
        return self:GetChainByID(tonumber(itemID)) ~= nil
    end
    return true
end
local keywords, results, keywordCharacters = {}, {}, {}
function Database:Search(tbl, query, character)
    local tbl = tbl or {};
    local query = string.gsub(query:lower(), "[,.?:;!'\"%-%(%)]", "")

    if self.questCache[character] == nil then
        self.questCache[character] = {}
    end

    if self.questCache[character][query] ~= nil then
        for _,v in ipairs(self.questCache[character][query]) do
            tbl[#tbl+1] = v;
        end
        return tbl;
    end

    local prefixlist
    local start = ""
    for character in gmatch(query, "[\32-\127\192-\247][\128-\191]*") do
        start = start .. character
        if self.buckets[start] ~= nil then
            prefixlist = self.buckets[start]
            break
        end
    end

    wipe(keywords);
    for keyword in string.gmatch(query, "[^%s]+") do
        keywords[#keywords+1] = keyword
    end

    wipe(results);
    if prefixlist == nil then
        return results
    end
    
    local item
    for i=1,#prefixlist do
        item = prefixlist[i]
        if results[item] == nil and self:IsItemValidForCharacter(item, character) and self:SearchTargetExists(item) then
            results[item] = 0
        end
    end

    local keyword, result
    for k=1,#keywords do
        keyword = keywords[k]
        -- Filter items based on other keywords
        for item in pairs(results) do
            if item.keywords == nil and item.name ~= nil then
                item.keywords = gsub(lower(item.name), "[,.?:;!'\"%-%(%)]", "")
            end
            if type(item.keywords) == "string" then
                local keywords = item.keywords
                
                result = {};
                for keyword in gmatch(keywords, "[^%s]+") do
                    wipe(keywordCharacters)
                    for character in gmatch(keyword, "[\32-\127\192-\247][\128-\191]*") do
                        keywordCharacters[#keywordCharacters + 1] = character
                    end
    
                    for i=1,#keywordCharacters do
                        for j=#keywordCharacters,i,-1 do
                            local word = table.concat(keywordCharacters, "", i, j)
                            result[word] = (result[word] or 0) + ((j - i + 1) / #keywordCharacters) / ((result[word] or 0) + 1)
                        end
                    end
                end
                
                item.keywords = result;
            end

            results[item] = results[item] + (item.keywords[keyword] or 0)
        end
    end

    wipe(tbl);
    for item,score in pairs(results) do
        if score > 0 then
            tbl[#tbl+1] = {
                name = item.name,
                item = item,
                score = score,
            }
        end
    end
    table.sort(tbl, function (a, b)
        if a.score == b.score then
            return (a.item.type or "") < (b.item.type or "")
        end

        return a.score > b.score
    end)

    self.questCache[character][query] = {unpack(tbl)}

    return tbl
end


-- Map
function Database:AddMap(id, t, replace)
    if t[1] ~= nil then
        for _,v in ipairs(t) do
            self:AddMap(id, v)
        end
    else
        if self.MapIDToItem[id] ~= nil then
            if replace then
                self.MapIDToItem[id] = {t}
            else
                if self.MapIDToItem[id][1] == nil then
                    self.MapIDToItem[id] = {self.MapIDToItem[id]}
                end
                    
                table.insert(self.MapIDToItem[id], t)
            end
        else
            self.MapIDToItem[id] = t
        end
    end
end
function Database:AddMapRecursive(id, t, force, replace)
    self:AddMap(id, t, replace)

    local children = C_Map.GetMapChildrenInfo(id, nil, true) or {}
    for _,map in ipairs(children) do
        if force or self.MapIDToItem[map.mapID] == nil then
            self:AddMap(map.mapID, t, replace)
        end
    end
end
function Database:GetMapItemByID(mapID, character)
    local item = self.MapIDToItem[mapID]
    
    if item == nil then
        return nil
    end
    
    if item[1] ~= nil then
        for i = 1, #item do
            if self:IsItemValidForCharacter(item[i], character) then
                return item[i]
            end
        end
    elseif self:IsItemValidForCharacter(item, character) then
        return item
    end

    return nil
end

-- Adds quest chains to a list based on the continent they are on, later used to display map indicators
function Database:AddContinentItem(id, t)
	local mapInfo = C_Map.GetMapInfo(id)
    while mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent and mapInfo.mapType ~= Enum.UIMapType.World and mapInfo.mapType ~= Enum.UIMapType.Cosmic do
        id = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(id)
    end

    assert(mapInfo ~= nil, string.format("Continent %d doesnt exist", id))

    if self.Continents[id] == nil then
        self.Continents[id] = {t}
    else
        table.insert(self.Continents[id], t)
    end
end
function Database:AddContinentItems(id, t)
	local mapInfo = C_Map.GetMapInfo(id)
    while mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent and mapInfo.mapType ~= Enum.UIMapType.World and mapInfo.mapType ~= Enum.UIMapType.Cosmic do
        id = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(id)
    end

    assert(mapInfo ~= nil, string.format("Continent %d doesnt exist", id))

    if self.Continents[id] == nil then
        self.Continents[id] = {}
    end

    for _,item in ipairs(t) do
        if item.type == "chain" then 
            assert(self:GetChainByID(item.id) ~= nil, string.format("Chain %d doesnt exist", item.id))
        end
        table.insert(self.Continents[id], item)
    end
end
function Database:GetAvailableMapItems(mapID, character)
    local continentID = mapID
	local mapInfo = C_Map.GetMapInfo(continentID);
    while mapInfo and mapInfo.mapType ~= Enum.UIMapType.Continent and mapInfo.mapType ~= Enum.UIMapType.World and mapInfo.mapType ~= Enum.UIMapType.Cosmic do
        continentID = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(continentID);
    end

    local result = {}

    if mapInfo and self.Continents[continentID] then
        local items = self.Continents[continentID]
        for _,item in ipairs(items) do
            local chain = self:GetChainByID(item.id)
            assert(chain ~= nil, string.format("Missing chain %d on map %d within continent %d", item.id, mapID, continentID))
            if chain:IsValidForCharacter(character) and not chain:IsCompleted(character) and (chain:IsAvailable(character) or chain:IsActive(character)) then
                local item = chain:GetNextItem(character)
                
                if item and not item:IsActive(character) then
                    local source = item:GetSource(character)
                    if source ~= nil then
                        local _, coords = source:GetLocation(mapID)
                        if coords ~= nil then
                            local x, y = coords:GetXY()
                            if x >= 0 and x <= 1 and y >= 0 and y <= 1 then -- Within the map
                                table.insert(result, {
                                    chainID = chain:GetID(),
                                    chainName = chain:GetName(),
                                    itemName = item:GetName(character),
                                    x = x,
                                    y = y,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    return result
end


-- Achievement
function BtWQuests_GetAchievementName(achievementID)
    return select(2, GetAchievementInfo(achievementID))
end

-- Achievement info isnt always loaded so sometimes need to delay reading achievement names
function BtWQuests_GetAchievementNameDelayed(achievementID)
    return function ()
        return select(2, GetAchievementInfo(achievementID))
    end
end

-- The first return value for GetAchievementCriteriaInfo is the name anyway so no need for the overhead of using another function
BtWQuests_GetAchievementCriteriaName = GetAchievementCriteriaInfo

-- Achievement info isnt always loaded so sometimes need to delay reading achievement names
function BtWQuests_GetAchievementCriteriaNameDelayed(achievementID, criteriaIndex)
    return function ()
        return BtWQuests_GetAchievementCriteriaName(achievementID, criteriaIndex)
    end
end

function BtWQuests_GetAchievementCriteriaFullName(achievementID, criteriaIndex)
    return string.format("%s: %s", BtWQuests_GetAchievementName(achievementID), BtWQuests_GetAchievementCriteriaName(criteriaIndex))
end

-- Achievement info isnt always loaded so sometimes need to delay reading achievement names
function BtWQuests_GetAchievementCriteriaFullNameDelayed(achievementID, criteriaIndex)
    return function ()
        return BtWQuests_GetAchievementCriteriaFullName(achievementID, criteriaIndex)
    end
end

function BtWQuests.GetAreaName(areaID)
    return C_Map.GetAreaInfo(areaID)
end
function BtWQuests.GetMapName(mapID)
    return ((C_Map.GetMapInfo(mapID) or {}).name or "Unnamed")
end
BtWQuests_GetAreaName = BtWQuests.GetAreaName;
BtWQuests_GetMapName = BtWQuests.GetMapName;

Database.ItemMixin = ItemMixin
Database:Init();
Database:RegisterDataType("condition", ConditionMixin);
Database:RegisterDataType("expansion", ExpansionMixin);
Database:RegisterDataType("category", CategoryMixin);
Database:RegisterDataType("chain", ChainMixin);
Database:RegisterDataType("quest", QuestMixin);
Database:RegisterDataType("npc", NPCMixin);
Database:RegisterDataType("object", ObjectMixin);
Database:RegisterDataType("mission", MissionMixin);

Database:RegisterItemType("header", HeaderItemMixin);
Database:RegisterItemType("quest", QuestItemMixin);
Database:RegisterItemType("expansion", ExpansionItemMixin);
Database:RegisterItemType("category", CategoryItemMixin);
Database:RegisterItemType("chain", ChainItemMixin);
Database:RegisterItemType("mission", MissionItemMixin);
Database:RegisterItemType("npc", NPCItemMixin);
Database:RegisterItemType("kill", KillItemMixin);
Database:RegisterItemType("talk", TalkItemMixin);
Database:RegisterItemType("object", ObjectItemMixin);
Database:RegisterItemType("loot", LootItemMixin);
Database:RegisterItemType("level", LevelItemMixin);
Database:RegisterItemType("experience", ExperienceItemMixin);
Database:RegisterItemType("race", RaceItemMixin);
Database:RegisterItemType("class", ClassItemMixin);
Database:RegisterItemType("faction", FactionItemMixin);
Database:RegisterItemType("reputation", ReputationItemMixin);
Database:RegisterItemType("friendship", FriendshipItemMixin);
Database:RegisterItemType("achievement", AchievementItemMixin);
Database:RegisterItemType("money", MoneyItemMixin);
Database:RegisterItemType("currency", CurrencyItemMixin);
Database:RegisterItemType("time", TimeItemMixin);
Database:RegisterItemType("timezone", TimeZoneItemMixin);
Database:RegisterItemType("coords", CoordsItemMixin);
Database:RegisterItemType("pet", PetItemMixin);
Database:RegisterItemType("mount", MountItemMixin);
Database:RegisterItemType("toy", ToyItemMixin);
Database:RegisterItemType("aura", AuraItemMixin);
Database:RegisterItemType("profession", ProfessionItemMixin);
Database:RegisterItemType("item", ItemItemMixin);
Database:RegisterItemType("equipped", EquippedItemMixin);
Database:RegisterItemType("questline", QuestLineItemMixin);
Database:RegisterItemType("follower", FollowerItemMixin);
Database:RegisterItemType("garrisontalenttree", GarrisonTalentTreeItemMixin);
Database:RegisterItemType("garrisontalent", GarrisonTalentItemMixin);
Database:RegisterItemType("campaign", CampaignItemMixin);
Database:RegisterItemType("spell", ItemMixin); -- Is just used to track with rewards spells are used
Database:RegisterItemType("area", AreaItemMixin);
Database:RegisterItemType("chromietime", ChromieTimeItemMixin);

Database:AddCondition(-1, { type = "chromietime" });
Database:AddCondition(923, { type = "faction", id = "Horde" });
Database:AddCondition(924, { type = "faction", id = "Alliance" });

Database:RegisterConditionClearCacheEvent("QUEST_ACCEPTED")
Database:RegisterConditionClearCacheEvent("QUEST_AUTOCOMPLETE")
Database:RegisterConditionClearCacheEvent("QUEST_COMPLETE")
Database:RegisterConditionClearCacheEvent("QUEST_FINISHED")
Database:RegisterConditionClearCacheEvent("QUEST_TURNED_IN")
Database:RegisterConditionClearCacheEvent("QUEST_WATCH_LIST_CHANGED")
Database:RegisterConditionClearCacheEvent("QUEST_WATCH_UPDATE")
if INTERFACE_NUMBER >= 70200 then
    Database:RegisterConditionClearCacheEvent("QUEST_LOG_CRITERIA_UPDATE")
end
if C_QuestSession then
    Database:RegisterConditionClearCacheEvent("QUEST_SESSION_JOINED")
    Database:RegisterConditionClearCacheEvent("QUEST_SESSION_LEFT")
end

BtWQuestsDatabase = Database;
BtWQuests.Database = Database;