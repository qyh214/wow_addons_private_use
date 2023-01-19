local _, AddOn = ...

AddOn.worldBosses = {
    {
        instanceID = 322,                            -- Pandaria
        encounters = {
            { encounterID = 691, questID = 32099 },  -- Sha of Anger
            { encounterID = 725, questID = 32098 },  -- Salyis's Warband
            { encounterID = 814, questID = 32518 },  -- Nalak, The Storm Lord
            { encounterID = 826, questID = 32519 },  -- Oondasta
            { encounterID = nil, questID = 33117 },  -- The Four Celestials
            { encounterID = 861, questID = 33118 }   -- Ordos, Fire-God of the Yaungol
        }
    },
    {
        instanceID = 557,                            -- Draenor
        encounters = {
            { encounterID = 1291, questID = 37460 }, -- Drov the Ruiner
            { encounterID = 1211, questID = 37462 }, -- Tarlna the Ageless
            { encounterID = 1262, questID = 37464 }, -- Rukhmar
            { encounterID = 1452, questID = 39380 }  -- Supreme Lord Kazzak
        }
    },
    {
        instanceID = 822,                            -- Broken Isles
        encounters = {
            { encounterID = 1790, questID = 43512 }, -- Ana-Mouz
            { encounterID = 1956, questID = 47061 }, -- Apocron
            { encounterID = 1883, questID = 46947 }, -- Brutallus
            { encounterID = 1774, questID = 43193 }, -- Calamir
            { encounterID = 1789, questID = 43448 }, -- Drugon the Frostblood
            { encounterID = 1795, questID = 43985 }, -- Flotsam
            { encounterID = 1770, questID = 42819 }, -- Humongris
            { encounterID = 1769, questID = 43192 }, -- Levantus
            { encounterID = 1884, questID = 46948 }, -- Malificus
            { encounterID = 1783, questID = 43513 }, -- Na'zak the Fiend
            { encounterID = 1749, questID = 42270 }, -- Nithogg
            { encounterID = 1763, questID = 42779 }, -- Shar'thos
            { encounterID = 1885, questID = 46945 }, -- Si'vash
            { encounterID = 1756, questID = 42269 }, -- The Soultakers
            { encounterID = 1796, questID = 44287 }  -- Withered Jim
        }
    },
    {
        instanceID = 959,                            -- Invasion Points
        encounters = {
            { encounterID = 2010, questID = 49199 }, -- Matron Folnuna
            { encounterID = 2011, questID = 48620 }, -- Mistress Alluradel
            { encounterID = 2012, questID = 49198 }, -- Inquisitor Meto
            { encounterID = 2013, questID = 49195 }, -- Occularus
            { encounterID = 2014, questID = 49197 }, -- Sotanathor
            { encounterID = 2015, questID = 49196 }  -- Pit Lord Vilemus
        }
    },
    {
        instanceID = 1028,                           -- Azeroth
        encounters = {
            { encounterID = 2139, questID = 52181 }, -- T'zane
            { encounterID = 2141, questID = 52169 }, -- Ji'arak
            { encounterID = 2197, questID = 52157 }, -- Hailstone Construct
            { encounterID = nil , questID = nil   }, -- The Lion's Roar/Doom's Howl
            { encounterID = 2199, questID = 52163 }, -- Azurethos, The Winged Typhoon
            { encounterID = 2198, questID = 52166 }, -- Warbringer Yenajz
            { encounterID = 2210, questID = 52196 }, -- Dunegorger Kraulok
            { encounterID = nil , questID = nil   }, -- Ivus the Forest Lord/Ivus the Decayed
            { encounterID = 2362, questID = 56057 }, -- Ulmath, the Soulbinder
            { encounterID = 2363, questID = 56056 }, -- Wekemara
            { encounterID = 2381, questID = 55466 }, -- Vuk'laz the Earthbreaker
            { encounterID = 2378, questID = 58705 }  -- Grand Empress Shek'zara
        }
    },
    {
        instanceID = 1192,                           -- Shadowlands
        encounters = {
            { encounterID = 2430, questID = 61813 }, -- Valinor, the Light of Eons
            { encounterID = 2431, questID = 61816 }, -- Mortanis
            { encounterID = 2432, questID = 61815 }, -- Oranomonos the Everbranching
            { encounterID = 2433, questID = 61814 }, -- Nurgash Muckformed
            { encounterID = 2456, questID = 64531 }, -- Mor'geth, Tormentor of the Damned
            { encounterID = 2468, questID = 65143 }  -- Antros
        }
    },
    {
        instanceID = 1205,                           -- Dragon Isles
        encounters = {
            { encounterID = 2515, questID = 69929 }, -- Strunraan, The Sky's Misery
            { encounterID = 2506, questID = 69930 }, -- Basrikron, The Shale Wing
            { encounterID = 2517, questID = 69927 }, -- Bazual, The Dreaded Flame
            { encounterID = 2518, questID = 69928 }  -- Liskanoth, The Futurebane
        }
    }
}

function AddOn:RequestWarfrontInfo()
    local stromgardeState = C_ContributionCollector.GetState(self.playerFaction == "Horde" and 116 or 11)
    local darkshoreState = C_ContributionCollector.GetState(self.playerFaction == "Horde" and 117 or 118)
    self.isStromgardeAvailable = stromgardeState == Enum.ContributionState.Building or stromgardeState == Enum.ContributionState.Active
    self.isDarkshoreAvailable = darkshoreState == Enum.ContributionState.Building or darkshoreState == Enum.ContributionState.Active
end

---@param instanceIndex number
---@return string, number, boolean, string, number, number, number @ instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty
function AddOn:GetSavedWorldBossInfo(instanceIndex)
    local instanceID = self.worldBosses[instanceIndex].instanceID
    local instanceName = EJ_GetInstanceInfo(instanceID)
    local difficulty = 2
    local locked = false
    local difficultyName = RAID_INFO_WORLD_BOSS
    local numEncounters = 0
    local numCompleted = 0

    for encounterIndex = 1, #self.worldBosses[instanceIndex].encounters do
        local encounter = self.worldBosses[instanceIndex].encounters[encounterIndex]
        local isDefeated = C_QuestLog.IsQuestFlaggedCompleted(encounter.questID)
        if instanceIndex == 5 and encounterIndex == 4 then
            isDefeated = isDefeated and self.isStromgardeAvailable
        elseif instanceIndex == 5 and encounterIndex == 8 then
            isDefeated = isDefeated and self.isDarkshoreAvailable
        end
        if isDefeated then
            locked = true
            numCompleted = numCompleted + 1
        end
    end

    return instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty
end

---@param instanceIndex number
---@param encounterIndex number
---@return string, boolean @ bossName, isKilled
function AddOn:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex)
    if encounterIndex > #self.worldBosses[instanceIndex].encounters then return end
    local bossName
    local isKilled = C_QuestLog.IsQuestFlaggedCompleted(self.worldBosses[instanceIndex].encounters[encounterIndex].questID)
    if not self.worldBosses[instanceIndex].encounters[encounterIndex].encounterID then
        bossName = select(2, GetAchievementInfo(7333)) -- Localize "The Four Celestials"
    else
        bossName = EJ_GetEncounterInfo(self.worldBosses[instanceIndex].encounters[encounterIndex].encounterID)
    end
    return bossName, isKilled
end

---@param instanceIndex number
---@return table @ instanceLockout
function AddOn:GetInstanceLockout(instanceIndex)
    local instanceName, _, _, instanceDifficulty, locked, extended, _, _, _, difficultyName, numEncounters, numCompleted = GetSavedInstanceInfo(instanceIndex)
    if not locked and not extended then return end
    local instanceID = tonumber(GetSavedInstanceChatLink(instanceIndex):match("%b::(%d+)"))
    if instanceID == 1544 then
        numEncounters = 3 -- Fixes wrong encounters count for Assault on Violet Hold
    elseif instanceID == 1822 then
        numEncounters = 4 -- Fixes https://github.com/Meivyn/AdventureGuideLockouts/issues/1
    end

    local _, _, isHeroic, _, displayHeroic, displayMythic, _, isLFR = GetDifficultyInfo(instanceDifficulty)
    local difficulty = 2
    if displayMythic then
        difficulty = 4
    elseif isHeroic or displayHeroic then
        difficulty = 3
    elseif isLFR then
        difficulty = 1
    end

    local encounters = {}
    for encounterIndex = 1, numEncounters do
        if instanceID == 1822 then
            if self.playerFaction == "Alliance" and encounterIndex == 1 or self.playerFaction == "Horde" and encounterIndex == 2 then
                encounterIndex = encounterIndex + 1 -- Fixes https://github.com/Meivyn/AdventureGuideLockouts/issues/1
            end
        end
        local bossName, _, isKilled = GetSavedInstanceEncounterInfo(instanceIndex, encounterIndex)
        tinsert(encounters, {
            bossName = bossName,
            isKilled = isKilled
        })
    end

    return {
        encounters = encounters,
        instanceName = instanceName,
        instanceID = instanceID,
        difficulty = difficulty,
        difficultyName = difficultyName,
        numEncounters = numEncounters,
        numCompleted = numCompleted,
        progress = numCompleted .. "/" .. numEncounters,
        complete = numCompleted == numEncounters
    }
end

---@param instanceIndex number
---@return table @ instanceLockout
function AddOn:GetWorldBossLockout(instanceIndex)
    local instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty = self:GetSavedWorldBossInfo(instanceIndex)
    if not locked then return end

    local encounters = {}
    local encounterIndex = 1
    local bossName, isKilled = self:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex)
    while bossName do
        local isAvailable = true
        if instanceIndex == 5 and encounterIndex == 4 then
            isAvailable = self.isStromgardeAvailable
            isKilled = isKilled and isAvailable
        elseif instanceIndex == 5 and encounterIndex == 8 then
            isAvailable = self.isDarkshoreAvailable
            isKilled = isKilled and isAvailable
        elseif instanceIndex >= 5 then
            isAvailable = C_TaskQuest.GetQuestTimeLeftMinutes(self.worldBosses[instanceIndex].encounters[encounterIndex].questID) ~= nil
        end
        encounters[encounterIndex] = {
            bossName = bossName,
            isKilled = isKilled,
            isAvailable = isAvailable
        }
        numEncounters = (isAvailable or isKilled) and numEncounters + 1 or numEncounters
        encounterIndex = encounterIndex + 1
        bossName, isKilled = self:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex)
    end

    return {
        encounters = encounters,
        instanceName = instanceName,
        instanceID = instanceID,
        difficulty = difficulty,
        difficultyName = difficultyName,
        numEncounters = numEncounters,
        numCompleted = numCompleted,
        progress = numCompleted .. "/" .. numEncounters,
        complete = numCompleted == numEncounters
    }
end

function AddOn:UpdateSavedInstances()
    self.instanceLockouts = self.instanceLockouts and wipe(self.instanceLockouts) or {}
    local savedInstances = GetNumSavedInstances()
    for instanceIndex = 1, savedInstances + #self.worldBosses do
        local lockout
        if instanceIndex <= savedInstances then
            lockout = self:GetInstanceLockout(instanceIndex)
        else
            lockout = self:GetWorldBossLockout(instanceIndex - savedInstances)
        end
        if lockout then
            self.instanceLockouts[lockout.instanceID] = self.instanceLockouts[lockout.instanceID] or {}
            tinsert(self.instanceLockouts[lockout.instanceID], lockout)
        end
    end
end

---@param button Button
---@param orderIndex number
---@param difficulty number
---@return Frame @ statusFrame
function AddOn:CreateStatusFrame(button, orderIndex, difficulty)
    local statusFrame = CreateFrame("Frame", nil, button)
    statusFrame:SetSize(38, 46)
    statusFrame:SetScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(frame.instanceInfo.instanceName .. " (" .. frame.instanceInfo.difficultyName .. ")")
        for i = 1, #frame.instanceInfo.encounters do
            local encounter = frame.instanceInfo.encounters[i]
            local r, g, b
            local bossStatus
            if encounter.isKilled then
                r, g, b = RED_FONT_COLOR:GetRGB()
                bossStatus = BOSS_DEAD
            elseif encounter.isAvailable == false then
                r, g, b = GRAY_FONT_COLOR:GetRGB()
                bossStatus = QUEUE_TIME_UNAVAILABLE
            else
                r, g, b = GREEN_FONT_COLOR:GetRGB()
                bossStatus = BOSS_ALIVE
            end
            GameTooltip:AddDoubleLine(encounter.bossName, bossStatus, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, r, g, b)
        end
        GameTooltip:Show()
    end)
    statusFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    statusFrame.texture = statusFrame:CreateTexture(nil, "ARTWORK")
    statusFrame.texture:SetPoint("CENTER")
    statusFrame.texture:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
    statusFrame.texture:SetSize(64, 46)

    if difficulty == 4 then
        statusFrame.texture:SetTexCoord(0.25, 0.5, 0.0703125, 0.4296875)
    elseif difficulty == 3 then
        statusFrame.texture:SetTexCoord(0, 0.25, 0.0703125, 0.4296875)
    else
        statusFrame.texture:SetTexCoord(0, 0.25, 0.5703125, 0.9296875)
    end

    local completeFrame = CreateFrame("Frame", nil, statusFrame)
    completeFrame:SetSize(16, 16)

    completeFrame.texture = completeFrame:CreateTexture(nil, "ARTWORK", "GreenCheckMarkTemplate")
    completeFrame.texture:ClearAllPoints()
    completeFrame.texture:SetPoint("CENTER")

    local progressFrame = statusFrame:CreateFontString(nil, nil, "GameFontNormalSmallLeft")

    if difficulty == 1 or difficulty == 2 then
        completeFrame:SetPoint("CENTER", 0, -1)
        progressFrame:SetPoint("CENTER", 0, 5)
    else
        completeFrame:SetPoint("CENTER", 0, -12)
        progressFrame:SetPoint("CENTER", 0, -9)
    end

    statusFrame.completeFrame = completeFrame
    statusFrame.progressFrame = progressFrame

    self.statusFrames[orderIndex] = self.statusFrames[orderIndex] or {}
    self.statusFrames[orderIndex][difficulty] = statusFrame

    return statusFrame
end

---@param orderIndex number
function AddOn:UpdateStatusFramePosition(orderIndex)
    local numVisible = 0
    for difficulty = 4, 1, -1 do
        local statusFrame = self.statusFrames[orderIndex][difficulty]
        if statusFrame and statusFrame:IsVisible() then
            statusFrame:SetPoint("BOTTOMRIGHT", 4 + numVisible * -32, difficulty > 2 and -12 or -23)
            numVisible = numVisible + 1
        end
    end
end

---@param button Button
---@param elementData table
function AddOn:UpdateInstanceStatusFrame(button, elementData)
    self.statusFrames = self.statusFrames or {}
    local orderIndex = button:GetOrderIndex()
    local instances = self.instanceLockouts and (self.instanceLockouts[elementData.mapID] or self.instanceLockouts[elementData.instanceID])

    if self.statusFrames[orderIndex] then
        for _, frame in pairs(self.statusFrames[orderIndex]) do
            frame:Hide()
        end
    end

    if not instances then return end

    for i = 1, #instances do
        local instance = instances[i]
        local frame = self.statusFrames[orderIndex] and self.statusFrames[orderIndex][instance.difficulty] or self:CreateStatusFrame(button, orderIndex, instance.difficulty)
        if instance.complete then
            frame.completeFrame:Show()
            frame.progressFrame:Hide()
            frame:Show()
        elseif instance.progress then
            frame.completeFrame:Hide()
            frame.progressFrame:SetText(instance.progress)
            frame.progressFrame:Show()
            frame:Show()
        else
            frame:Hide()
        end
        frame.instanceInfo = instance
    end

    self:UpdateStatusFramePosition(orderIndex)
end

-- This fixes an issue with the original function
-- not setting the mapID correctly in the data provider.
local function UpdateDataProvider()
    local dataIndex = 1
    local showRaid = EncounterJournal_IsRaidTabSelected(EncounterJournal)
    local instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(dataIndex, showRaid)

    local dataProvider = CreateDataProvider()
    while instanceID ~= nil do
        dataProvider:Insert({
            instanceID = instanceID,
            name = name,
            description = description,
            buttonImage = buttonImage,
            link = link,
            mapID = mapID,
        })

        dataIndex = dataIndex + 1
        instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(dataIndex, showRaid)
    end

    EncounterJournal.instanceSelect.ScrollBox:SetDataProvider(dataProvider)
end

-- This fixes an issue introduced by assigning the mapID.
-- The Fated icon is not hidden when switching tabs or expansions.
local function SetFated(button, elementData)
    local modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(elementData.mapID)
    if modifiedInstanceInfo then
        button.ModifiedInstanceIcon.info = modifiedInstanceInfo
        button.ModifiedInstanceIcon.name = nil
        local atlas = button.ModifiedInstanceIcon:GetIconTextureAtlas()
        button.ModifiedInstanceIcon.Icon:SetAtlas(atlas, true)
        button.ModifiedInstanceIcon:SetSize(button.ModifiedInstanceIcon.Icon:GetSize())
        button.ModifiedInstanceIcon:Show()
    else
        button.ModifiedInstanceIcon:Hide()
    end
end

local function UpdateFrames(scrollBox, locked)
    if locked then return end
    local buttons = scrollBox:GetFrames()
    for i = 1, #buttons do
        local button = buttons[i]
        local elementData = button:GetElementData()
        AddOn:UpdateInstanceStatusFrame(button, elementData)
        SetFated(button, elementData)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BOSS_KILL")
frame:RegisterEvent("UPDATE_INSTANCE_INFO")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        AddOn.playerFaction = UnitFactionGroup("player")
        AddOn.worldBosses[5].encounters[4].encounterID = AddOn.playerFaction == "Horde" and 2212 or 2213
        AddOn.worldBosses[5].encounters[4].questID =  AddOn.playerFaction == "Horde" and 52848 or 52847
        AddOn.worldBosses[5].encounters[8].encounterID = AddOn.playerFaction == "Horde" and 2329 or 2345
        AddOn.worldBosses[5].encounters[8].questID =  AddOn.playerFaction == "Horde" and 54896 or 54895
    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_EncounterJournal" then
        hooksecurefunc("EncounterJournal_ListInstances", UpdateDataProvider)
        hooksecurefunc(EncounterJournal.instanceSelect.ScrollBox, "SetUpdateLocked", UpdateFrames)
    elseif event == "BOSS_KILL" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        AddOn:RequestWarfrontInfo()
        AddOn:UpdateSavedInstances()
        if EncounterJournal and EncounterJournal:IsVisible() then
            UpdateFrames(EncounterJournal.instanceSelect.ScrollBox)
        end
    end
end)
