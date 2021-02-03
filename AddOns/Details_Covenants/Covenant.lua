local utilityMap = {
    [324739] = 1,
    [177278] = 1,
    [300728] = 4,
    [310143] = 3,
    [300728] = 2,
}

local abilityMap = {
    ["DEATHKNIGHT"] = {
        [315443] = 4,
        [312202] = 1,
        [311648] = 2,
        [324128] = 3,
    },
    ["DEMONHUNTER"] = {
        [306830] = 1,
        [329554] = 4,
        [323639] = 3,
        [317009] = 2,
    }, 
    ["DRUID"] = {
        [338142] = 1,
        [326462] = 1,
        [326446] = 1,
        [338035] = 1,
        [338018] = 1,
        [338411] = 1,
        [326434] = 1,
        [325727] = 4,
        [323764] = 3,
        [323546] = 2,
    },
    ["HUNTER"] = {
        [308491] = 1,
        [325028] = 4,
        [328231] = 3,
        [324149] = 2,
    },
    ["MAGE"] = {
        [307443] = 1,
        [324220] = 4,
        [314791] = 3,
        [314793] = 2,
    },
    ["MONK"] = {
        [310454] = 1,
        [325216] = 4,
        [327104] = 3,
        [326860] = 2,
    },
    ["PALADIN"] = {
        [304971] = 1,
        [328204] = 4,
        [328282] = 3,
        [328620] = 3,
        [328622] = 3,
        [328281] = 3,
        [316958] = 2,
    },
    ["PRIEST"] = {
        [325013] = 1,
        [324724] = 4,
        [327661] = 3,
        [323673] = 2,
    },
    ["ROGUE"] = {
        [323547] = 1,
        [328547] = 4,
        [328305] = 3,
        [323654] = 2,
    },
    ["SHAMAN"] = {
        [324519] = 1,
        [324386] = 1,
        [326059] = 4,
        [328923] = 3,
        [320674] = 2,
    },
    ["WARLOCK"] = {
        [312321] = 1,
        [325289] = 4,
        [325640] = 3,
        [321792] = 2,
    },
    ["WARRIOR"] = {
        [307865] = 1,
        [324143] = 4,
        [325886] = 3,
        [330334] = 2,
        [317488] = 2,
        [330325] = 2,
    },
}

local function isEmpty(table)
    for _, _ in pairs(table) do
        return false
    end
    return true
end

function isNumeric(x)
    if tonumber(x) ~= nil then
        return true
    end
    return false
end

DCovenant = {
    ["iconSize"] = 16,
}

local DetailsCovenant = {}

local frame = CreateFrame("FRAME", "DetailsCovenantFrame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

local function registerCombatEvent()
    if isEmpty(DetailsCovenant.emptyCovenants) then 
        frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    else
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        for key, _ in pairs(DetailsCovenant.emptyCovenants) do
            --print("|CFFFF0000Still not exists:|r "..key)
        end
    end
end

local function updateGroupRoster()
    DetailsCovenant.emptyCovenants = {}
    local numGroupMembers = GetNumGroupMembers()
    --print("|CFFFFFF00Numbers:|r "..numGroupMembers)
    for groupindex = 1, numGroupMembers do
        local name = GetRaidRosterInfo(groupindex)
        if name then
            local covenantID = DetailsCovenant.covenants[name]
            if not covenantID then
                --print("|CFFFF0000Not exists:|r "..name)
                DetailsCovenant.emptyCovenants[name] = 0
            end
        end
    end

    registerCombatEvent()
end

local function init()
    local isDeteilsLoaded = _G._detalhes ~= nil
    local isSkadaLoaded = _G.Skada ~= nil

    if isDeteilsLoaded or isSkadaLoaded then
        local covenantID = C_Covenants.GetActiveCovenantID()
        local playerName = UnitName("player")

        DetailsCovenant.covenants = { [playerName] = covenantID }
        frame:RegisterEvent("GROUP_ROSTER_UPDATE");
        
        updateGroupRoster()
    else
        DetailsCovenant.covenants = {}
        frame:UnregisterEvent("GROUP_ROSTER_UPDATE");
        frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    end
end

local function addCovenantForPlayer(covenantID, playerName)
    if covenantID then 
        DetailsCovenant.covenants[playerName] = covenantID
        DetailsCovenant.emptyCovenants[playerName] = nil
        registerCombatEvent()
        --print("|CFF00FF00Add new character covenant:|r "..sourceName.." "..covenantID)
    end
end

local function getCovenantIcon(covenantID)
    if covenantID > 0 and covenantID < 5 then
        local covenantMap = {
            [1] = "kyrian",
            [2] = "venthyr",
            [3] = "night_fae",
            [4] = "necrolord",
        }

        return "|T".."Interface\\AddOns\\Details_Covenants\\resources\\"..covenantMap[covenantID]..".tga:"..DCovenant["iconSize"]..":"..DCovenant["iconSize"].."|t"
    end

    return ""
end

-- Replace NickTag implementation
local function replaceDetailsImplmentation()
    if _G.NickTag and _G._detalhes then
        _G._detalhes.GetNickname = function(self, playerName, default, silent)
            local covenantID = DetailsCovenant.covenants[playerName]
            local covenantEmojiName = ""

            if default == false and covenantID then
                covenantEmojiName = getCovenantIcon(covenantID).." "
            end

            if (not silent) then
                assert (type (playerName) == "string", "NickTag 'GetNickname' expects a string or string on #1 argument.")
            end
            
            local _table = NickTag:GetNicknameTable (playerName)
            if (not _table) then
                if (_G._detalhes.remove_realm_from_name) then
                    playerName = playerName:gsub (("%-.*"), "")
                end

                return covenantEmojiName..playerName or nil
            end
            
            local nickName = _table[1]
            if nickName then
                if TemniUgolok_SetEmojiToDetails then
                    return covenantEmojiName..TemniUgolok_SetEmojiToDetails(_table[1])
                else 
                    return covenantEmojiName.._table[1]
                end 
            else
                return default or nil
            end
        end
    end
end

-- Skada
local function replaceSkadaImplmentation()
    if _G.Skada then
        _G.Skada.get_player = function(self, set, playerid, playername)
            local covenantID = DetailsCovenant.covenants[playername]
            local covenantEmojiName = ""

            if covenantID then
                covenantEmojiName = getCovenantIcon(covenantID).." "
            end

            -- Add player to set if it does not exist.
            local player = Skada:find_player(set, playerid)

            if not player then
                -- If we do not supply a playername (often the case in submodes), we can not create an entry.
                if not playername then
                    return
                end

                local _, playerClass = UnitClass(playername)
                local playerRole = UnitGroupRolesAssigned(playername)
                player = {id = playerid, class = playerClass, role = playerRole, name = playername, first = time(), ["time"] = 0}

                -- Tell each mode to apply its needed attributes.
                for i, mode in ipairs(_G.Skada:GetModes(nil)) do
                    if mode.AddPlayerAttributes ~= nil then
                        mode:AddPlayerAttributes(player, set)
                    end
                end

                -- Strip realm name
                -- This is done after module processing due to cross-realm names messing with modules (death log for example, which needs to do UnitHealthMax on the playername).
                local player_name, realm = string.split("-", playername, 2)
                player.name = covenantEmojiName..(player_name or playername)

                tinsert(set.players, player)
            end

            if player.name == UNKNOWN and playername ~= UNKNOWN then -- fixup players created before we had their info
                local player_name, realm = string.split("-", playername, 2)
                player.name = covenantEmojiName..(player_name or playername)
                local _, playerClass = UnitClass(playername)
                local playerRole = UnitGroupRolesAssigned(playername)
                player.class = playerClass
                player.role = playerRole
            end


            -- The total set clears out first and last timestamps.
            if not player.first then
                player.first = time()
            end

            -- Mark now as the last time player did something worthwhile.
            player.last = time()
            changed = true
            return player
        end
    end  
end

local function eventHandler(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        --print("|CFF00FFFFTriggered|r")
        local _, subevent, _, sourceGUID, sourceName = CombatLogGetCurrentEventInfo()

        if not isEmpty(DetailsCovenant.emptyCovenants) and DetailsCovenant.emptyCovenants[sourceName] then
            if subevent == "SPELL_CAST_SUCCESS" then
                local _, englishClass = GetPlayerInfoByGUID(sourceGUID)
                local classAbilityMap = abilityMap[englishClass]

                if classAbilityMap then
                    local spellID = select(12, CombatLogGetCurrentEventInfo())
                    local covenantIDByAbility = classAbilityMap[spellID]
                    local covenantIDByUtility = utilityMap[spellID]

                    addCovenantForPlayer(covenantIDByAbility, sourceName)
                    addCovenantForPlayer(covenantIDByUtility, sourceName)
                end
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        updateGroupRoster()
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
        replaceDetailsImplmentation()
        replaceSkadaImplmentation()
        frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
end

frame:SetScript("OnEvent", eventHandler);

-- Command line tools 
SLASH_DETAILSCOVENANT1, SLASH_DETAILSCOVENANT2 = '/dc', '/dcovenants';
local function commandLineHandler(msg, editBox)
    if isNumeric(msg) then
        local numberValue = tonumber(msg)
        if numberValue > 10 and numberValue < 48 then 
            DCovenant["iconSize"] = math.floor(numberValue / 2) * 2
            print("Details! Covenant icon size has been set to "..DCovenant["iconSize"])
        else
            print("Please enter value between 10 and 48") 
        end 
    else
        print("Details! Covenant icon size: "..DCovenant["iconSize"])
    end
end
SlashCmdList["DETAILSCOVENANT"] = commandLineHandler;
