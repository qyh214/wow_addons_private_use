-- Modified from ElitismHelper
local W, F, L, P = unpack(select(2, ...))
local AD = W:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0")

local assert = assert
local format = format
local gsub = gsub
local math_pow = math.pow
local pairs = pairs
local print = print
local select = select
local sort = sort
local strjoin = strjoin
local strmatch = strmatch
local strsplit = strsplit
local tinsert = tinsert
local tonumber = tonumber
local type = type
local unpack = unpack
local wipe = wipe

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetRealmName = GetRealmName
local GetSpellLink = GetSpellLink
local GetUnitName = GetUnitName
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealthMax = UnitHealthMax
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer

local C_ChatInfo_GetRegisteredAddonMessagePrefixes = C_ChatInfo.GetRegisteredAddonMessagePrefixes
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Timer_After = C_Timer.After

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local wprint = function()
    return
end
--local wprint = print

--------------------------------------------
-- Authority
--------------------------------------------
AD.prefix = "WDH_AD"
local myServerID, myPlayerUID, authorityCache

local function GetBestChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
        return "RAID"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "PARTY"
    end
end

function AD:InitializeAuthority()
    local successfulRequest = C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)

    local guidSplitted = {strsplit("-", UnitGUID("player"))}
    myServerID = tonumber(guidSplitted[2], 10)
    myPlayerUID = tonumber(guidSplitted[3], 16)
end

do
    local channelLevel = {
        SELF = 0,
        EMOTE = 1,
        PARTY = 2
    }

    function AD:SendMyLevel(force)
        if not self.db then
            return
        end

        if IsInGroup() then
            local main, sub, patch = strsplit(".", W.Version)
            local levelBase = tonumber(main) * 10000 + tonumber(sub) * 100 + tonumber(patch)
            local level = self.db.notification.channel and channelLevel[self.db.notification.channel] or 0

            if level ~= 0 then
                level = level * 100000 + levelBase
            end

            -- If reload the ui, the data is cleared
            if self.inRecording then
                level = level + 100000
            end

            if level ~= 0 and force then
                if authorityCache then
                    level = authorityCache.level + 1
                end
            end

            local message = format("%s;%d;%d", level, myServerID, myPlayerUID)
            C_ChatInfo_SendAddonMessage(self.prefix, message, GetBestChannel())
        end
    end
end

function AD:ReceiveLevel(message, sender)
    if message == "RESET_AUTHORITY" then
        self:UpdatePartyInfo()
        return
    end

    local level, serverID, playerUID = strmatch(message, "^([0-9]-);([0-9]-);([0-9]+)")
    level = tonumber(level)
    serverID = tonumber(serverID)
    playerUID = tonumber(playerUID)

    if not authorityCache then
        authorityCache = {
            level = level,
            serverID = serverID,
            playerUID = playerUID,
            name = sender
        }
        return
    end

    local needUpdate = false
    if level > authorityCache.level then -- 等级比较
        needUpdate = true
    elseif level == authorityCache.level then
        if serverID > authorityCache.serverID then -- 服务器 ID 比较
            needUpdate = true
        elseif serverID == authorityCache.serverID then
            if playerUID > authorityCache.playerUID then -- 玩家 ID 比较
                needUpdate = true
            end
        end
    end

    if needUpdate then
        authorityCache.level = level
        authorityCache.serverID = serverID
        authorityCache.playerUID = playerUID
        authorityCache.name = sender
    end
end

function AD:CHAT_MSG_ADDON(_, prefix, message, channel, sender)
    if prefix == self.prefix then
        self:ReceiveLevel(message, sender)
    end
end

do
    local waitSend = false
    function AD:UpdatePartyInfo()
        if waitSend or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
            return
        end

        waitSend = true

        C_Timer_After(
            0.5,
            function()
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    authorityCache = nil
                    AD:SendMyLevel()
                end
                waitSend = false
            end
        )
    end
end

function AD:GetActiveUser()
    return authorityCache and authorityCache.name or GetUnitName("player")
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or not IsInGroup() then
        return
    end

    if authorityCache and authorityCache.playerUID ~= myPlayerUID then
        if self.db.alwaysOutputToChat then
            print(message)
        end

        return
    end

    if self.db.notification.channel == "SELF" then
        print(message)
    elseif self.db.notification.channel == "PARTY" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(message, "PARTY")
    elseif self.db.notification.channel == "EMOTE" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(": " .. message, "EMOTE")
    end
end

function AD:ResetAuthority()
    if not IsInGroup() then
        return
    end

    C_ChatInfo_SendAddonMessage(self.prefix, "RESET_AUTHORITY", GetBestChannel())
end

--------------------------------------------
-- Database
--------------------------------------------
-- Types
AD.MISTAKE = {
    SPELL_DAMAGE = 1, -- 法術傷害
    AURA = 2, -- 得到錯誤的效果
    MELEE = 3 -- 近戰傷害
}

-- Data
local MistakeData = {
    ["General"] = {
        -- Debug (死靈進門右轉法術怪)
        -- {
        --     -- 近戰攻擊
        --     type = AD.MISTAKE.MELEE,
        --     npc = 166302
        -- },
        -- {
        --     -- 汲取體液
        --     type = AD.MISTAKE.SPELL_DAMAGE,
        --     spell = 334749
        -- },
        {
            -- 火山煙流
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 209862
        },
        {
            -- 膿血
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 226512
        },
        {
            -- 地震
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 240448
        },
        {
            -- 風暴
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 343520,
            playerIsDPS = true
        },
        {
            -- 懷恨幽影
            type = AD.MISTAKE.MELEE,
            npc = 174773
        },
        {
            -- 懷恨幽影 (DF)
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 350163
        },
        {
            -- 閃電之擊 (S1 雷霆詞綴環境傷害)
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 394873
        },
        {
            -- 洪荒超載 (S1 雷霆詞綴強暈傷害 拉薩葛斯)
            type = AD.MISTAKE.SPELL_DAMAGE,
            spell = 396411
        }
    }
}

--------------------------------------------
-- Triggers
--------------------------------------------

local MapTable = {}

function AD:GetCurrentDungeonName()
    local mapID = C_Map_GetBestMapForUnit("player")
    return mapID and MapTable[mapID]
end

function AD:AddData(mapName, mistakeData, mapIDs)
    if not mapName then
        return
    end
    MistakeData[mapName] = mistakeData
    for _, mapID in pairs(mapIDs) do
        MapTable[mapID] = mapName
    end
end

local policy = {
    spell = {},
    aura = {},
    melee = {}
}

local function GetIDByGUID(guid)
    return tonumber(strmatch(guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function AD:CompilePolicy(policies)
    for _, mistake in pairs(policies) do
        if mistake.type == self.MISTAKE.SPELL_DAMAGE then
            policy.spell[mistake.spell] = mistake
        elseif mistake.type == self.MISTAKE.AURA then
            policy.aura[mistake.aura] = mistake
        elseif mistake.type == self.MISTAKE.MELEE then
            policy.melee[mistake.npc] = mistake
        end
    end
end

function AD:Compile()
    policy = {
        spell = {},
        aura = {},
        melee = {}
    }

    local mapName = self:GetCurrentDungeonName()
    if not mapName or not MistakeData[mapName] then
        return
    end

    self:CompilePolicy(MistakeData.General)
    self:CompilePolicy(MistakeData[mapName])
end

--------------------------------------------
-- Message Functions
--------------------------------------------
local warningMessage
local stacksMessage
local spellMessage

function AD:FormatNumber(amount)
    if not self.db or not self.db.notification then
        return
    end

    if self.db.notification.unit == "ASIA" then
        if amount > math_pow(10, 4) then
            return F.Round(amount / 10000, self.db.notification.accuracy) .. L["[UNIT] W"]
        else
            return amount
        end
    elseif self.db.notification.unit == "WESTERN" then
        if amount > math_pow(10, 3) then
            return F.Round(amount / 1000, self.db.notification.accuracy) .. L["[UNIT] k"]
        else
            return amount
        end
    end

    return amount
end

function AD:SetNotificationText()
    if self.db.custom.enable then
        warningMessage = self.db.custom.warningMessage
        stacksMessage = self.db.custom.stacksMessage
        spellMessage = self.db.custom.spellMessage
    else
        warningMessage = P.avoidableDamage.custom.warningMessage
        stacksMessage = P.avoidableDamage.custom.stacksMessage
        spellMessage = P.avoidableDamage.custom.spellMessage
    end
end

function AD:GenerateOutput(text, name, spell, stack, damage, percent)
    text = gsub(text, "%%name%%", name)
    text = gsub(text, "%%spell%%", spell)

    if stack then
        text = gsub(text, "%%stack%%", stack)
    end

    if damage then
        text = gsub(text, "%%damage%%", damage)
    end

    if percent then
        percent = F.Round(percent, self.db.notification.accuracy)
        text = gsub(text, "%%percent%%", format("%s%%%%", percent))
    end

    return text
end

--------------------------------------------
-- Statistic Functions
--------------------------------------------
local timers = {}
local timerData = {}
local combinedFails = {}
local meleeNPCs = {}

local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
end

local function PlayerHasBuff(player, spellID)
    for i = 1, 40 do
        local debuffID = select(10, UnitBuff(player, i))
        if debuffID == spellID then
            return true
        end
    end

    return false
end

local function PlayerHasDebuff(player, spellID)
    for i = 1, 40 do
        local debuffID = select(10, UnitDebuff(player, i))
        if debuffID == spellID then
            return true
        end
    end

    return false
end

function AD:COMBAT_LOG_EVENT_UNFILTERED()
    local _, event, _, sourceGUID, sourceName, _, _, _, destName, _, _, param12, _, _, param15, param16, param17 =
        CombatLogGetCurrentEventInfo()

    if not UnitIsPlayer(destName) then
        return
    end

    local eventPrefix, eventSuffix = strmatch(event, "^(.-)_?([^_]*)$")

    if (strmatch(eventPrefix, "^SPELL") or strmatch(eventSuffix, "^RANGE")) and eventSuffix == "DAMAGE" then
        -- SPELL_DAMAGE | RANGE_DAMAGE | SPELL_PERIODIC_DAMAGE | SPELL_BUILDING_DAMAGE
        -- spell: 12th
        -- amount: 15th
        self:GetHit_Spell(destName, param12, param15)
    elseif eventPrefix == "SWING" and eventSuffix == "DAMAGE" then
        -- SWING_DAMAGE
        -- amount: 12th
        self:GetHit_Swing(destName, sourceGUID, sourceName, param12)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        -- SPELL_MISSED | SPELL_PERIODIC_MISSED
        -- spell: 12th
        -- amountMissed: 17th
        if param17 then
            self:GetHit_Spell(destName, param12, param17)
        end
    elseif event == "SPELL_AURA_APPLIED" then
        -- spell: 12th
        -- amount: 16th
        -- TODO
    elseif event == "SPELL_AURA_APPLIED_DOSE" then
    -- spell: 12th
    -- amount: 16th
    -- TODO
    end
end

function AD:IsPolicyPassed(player, amount, data)
    -- Windwalker monk karma
    if PlayerHasBuff(player, 125174) then
        return false
    end

    if data.noPlayerDebuff then
        if type(data.noPlayerDebuff) == "number" then
            if PlayerHasDebuff(player, data.noPlayerDebuff) then
                return false
            end
        end
    end

    if data.noPlayerBuff then
        if type(data.noPlayerBuff) == "number" then
            if PlayerHasBuff(player, data.noPlayerBuff) then
                return false
            end
        end
    end

    if data.playerIsNotTank then
        if UnitGroupRolesAssigned(player) == "TANK" then
            return false
        end
    end

    if data.playerIsDPS then
        if UnitGroupRolesAssigned(player) ~= "DAMAGER" then
            return false
        end
    end

    if data.damageThreshold then
        if amount < data.damageThreshold then
            return false
        end
    end

    return true
end

function AD:GetHit_Spell(player, spellID, amount)
    if not policy.spell[spellID] then
        return
    end

    if not self:IsPolicyPassed(player, amount, policy.spell[spellID]) then
        return
    end

    if timerData[player] == nil then
        timerData[player] = {}
    end

    if combinedFails[player] == nil then
        combinedFails[player] = 0
    end

    combinedFails[player] = combinedFails[player] + amount
    if timerData[player][spellID] == nil then
        timerData[player][spellID] = amount
    else
        timerData[player][spellID] = timerData[player][spellID] + amount
    end

    self:AnnounceAfterSeconds(4, player)
end

function AD:GetHit_Swing(player, sourceGUID, sourceName, amount)
    local sourceID = GetIDByGUID(sourceGUID)
    if not sourceID or not policy.melee[sourceID] then
        return
    end

    if not self:IsPolicyPassed(player, amount, policy.melee[sourceID]) then
        return
    end

    if not timerData[player] then
        timerData[player] = {}
    end

    if not combinedFails[player] then
        combinedFails[player] = 0
    end
    combinedFails[player] = combinedFails[player] + amount

    if not timerData[player][6603] then
        timerData[player][6603] = amount
    else
        timerData[player][6603] = timerData[player][6603] + amount
    end

    if not meleeNPCs[player] then
        meleeNPCs[player] = {}
    end
    meleeNPCs[player][sourceName] = true

    self:AnnounceAfterSeconds(4, player)
end

function AD:AnnounceAfterSeconds(sec, player)
    if not timers[player] then
        timers[player] = true
        C_Timer_After(
            sec,
            function()
                self:DamageAnnouncer(player)
            end
        )
    end
end

function AD:DamageAnnouncer(player)
    if not timerData[player] then
        return
    end

    local spellLinks = ""
    local totalDamage = 0

    for spellID, damage in pairs(timerData[player]) do
        if spellID == 6603 then
            local names = {}
            for name in pairs(meleeNPCs[player]) do
                tinsert(names, name)
            end
            spellLinks = spellLinks .. GetSpellLink(spellID) .. "(" .. strjoin(",", unpack(names)) .. ") "
        else
            spellLinks = spellLinks .. GetSpellLink(spellID) .. " "
        end
        totalDamage = totalDamage + damage
    end

    timerData[player] = nil
    timers[player] = nil
    meleeNPCs[player] = nil

    local playerMaxHealth = UnitHealthMax(player)
    local damageText = self:FormatNumber(totalDamage)
    local percentage = totalDamage / playerMaxHealth * 100

    if self.db.notification.enable and percentage >= self.db.notification.threshold then
        if self.db.rank.enable and self.db.rank.onlyRanking then
            return
        end
        self:SendChatMessage(self:GenerateOutput(spellMessage, player, spellLinks, nil, damageText, percentage))
    end
end

function AD:ResetStatistic()
    wipe(meleeNPCs)
    wipe(combinedFails)
    wipe(timerData)
    wipe(timers)
end

--------------------------------------------
-- Toggling
--------------------------------------------
function AD:CHALLENGE_MODE_COMPLETED()
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    if not self.inRecording then
        return
    end

    if not self.db.rank.enable then
        return
    end

    local count = 0
    for _ in pairs(combinedFails) do
        count = count + 1
    end

    if count == 0 then
        self:SendChatMessage(L["No failure damage was taken this run."])
    else
        self:SendChatMessage(L["Amount of failure damage:"])

        local damageTable = {}
        for name, damage in pairs(combinedFails) do
            tinsert(damageTable, {key = name, value = damage})
        end

        SortTable(damageTable)

        for index, data in pairs(damageTable) do
            self:SendChatMessage(format("%d. %s %s", index, data.key, self:FormatNumber(data["value"])))
        end

        if self.db.rank.worst then
            self:SendChatMessage("--------------------------------")
            self:SendChatMessage(format("%s: %s", self.db.rank.customWorst, damageTable[1].key))
        end
    end

    if self.db.rank.addonInfo then
        self:SendChatMessage("--------------------------------")
        self:SendChatMessage(L["The report generated by Wind Dungeon Helper."])
    end

    self:ResetStatistic()
    self.inRecording = nil
end

function AD:CHALLENGE_MODE_START()
    if not self:GetCurrentDungeonName() then
        return
    end

    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:Compile()
    self:ResetStatistic()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.inRecording = true
end

function AD:OnInitialize()
    AD:InitializeAuthority()
    AD:ProfileUpdate()
    AD:SetNotificationText()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function AD:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    C_Timer_After(
        4,
        function()
            self:ResetAuthority()
        end
    )

    C_Timer_After(
        10,
        function()
            self:ResetAuthority()
        end
    )
end

function AD:ZONE_CHANGED_NEW_AREA()
    self:Compile()
end

function AD:ProfileUpdate()
    self.db = W.db.avoidableDamage

    if self.db.enable then
        self:Compile()
        self:UpdatePartyInfo()
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE", "ResetAuthority")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        if IsInInstance() then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        self:UnregisterEvent("CHAT_MSG_ADDON")
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("CHALLENGE_MODE_START")
        self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:ResetStatistic()
    end
end
