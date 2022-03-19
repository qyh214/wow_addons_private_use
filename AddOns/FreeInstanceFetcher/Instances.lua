local F = unpack(select(2, ...))
local StdUi = LibStub('StdUi')

-- Lua functions
local _G = _G
local bit_band, bit_lshift = bit.band, bit.lshift
local format, ipairs, next, pairs, select, strmatch = format, ipairs, next, pairs, select, strmatch
local tinsert, tonumber, wipe = tinsert, tonumber, wipe

-- WoW API / Variables
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID
local C_PetJournal_FindPetIDByName = C_PetJournal.FindPetIDByName
local C_PetJournal_GetPetInfoByItemID = C_PetJournal.GetPetInfoByItemID
local C_TransmogCollection_GetAppearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo
local C_TransmogCollection_GetIllusions = C_TransmogCollection.GetIllusions
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local GetAchievementInfo = GetAchievementInfo
local GetAchievementLink = GetAchievementLink
local GetDifficultyInfo = GetDifficultyInfo
local GetItemInfo = GetItemInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceInfo = GetSavedInstanceInfo
local PlayerHasToy = PlayerHasToy
local RequestRaidInfo = RequestRaidInfo

local C_Timer_After = C_Timer.After
local Item = Item

local classFilename = select(2, UnitClass('player'))

-- filters
local showDisabled = false
local showLooted = true
local showCollected = true
local showNotAvailable = false

local instanceList = {
    {
        -- Black Temple
        instanceID = 564,
        collections = {
            {
                -- Illidan Stormrage
                bossIndex = 9,
                bossBit = 8,
                type = 'achievement',
                achievementID = 426,
                available = (
                    classFilename == 'WARRIOR' or
                    classFilename == 'ROGUE' or
                    classFilename == 'DEATHKNIGHT' or
                    classFilename == 'MONK' or
                    classFilename == 'DEMONHUNTER'
                ),
            },
        },
    },
    {
        -- Ulduar
        instanceID = 603,
        collections = {
            {
                -- Yogg-Saron
                bossIndex = 16,
                bossBit = 13,
                type = 'mount',
                mountID = 304,
                itemID = 45693,
            },
        },
    },
    {
        -- Icecrown Citadel
        instanceID = 631,
        collections = {
            {
                -- The Lich King
                bossIndex = 12,
                bossBit = 11,
                type = 'mount',
                mountID = 363,
                itemID = 50818,
            },
        },
    },
    {
        -- Blackwing Descent
        instanceID = 669,
        collections = {
            {
                -- Nefarian and Onyxia
                bossIndex = 6,
                bossBit = 4,
                type = 'illusion',
                itemID = 138802,
                sourceID = 4097,
            },
        },
    },
    {
        -- Firelands
        instanceID = 720,
        difficulties = {
            [14] = {1, 2, 3},
            [15] = {1, 2, 3},
        },
        collections = {
            {
                -- Alysrazor
                bossIndex = 4,
                bossBit = 6,
                type = 'mount',
                mountID = 425,
                itemID = 71665,
            },
            {
                -- Majordomo Staghelm
                bossIndex = 6,
                bossBit = 0,
                type = 'toy',
                itemID = 122304,
                available = classFilename == 'DRUID',
            },
            {
                -- Ragnaros
                bossIndex = 7,
                bossBit = 3,
                type = 'mount',
                mountID = 415,
                itemID = 69224,
            },
        },
    },
    {
        -- Throne of the Four Winds
        instanceID = 754,
        collections = {
            {
                -- Al'Akir
                bossIndex = 2,
                bossBit = 0,
                type = 'mount',
                mountID = 396,
                itemID = 63041,
            },
        },
    },
    {
        -- Dragon Soul
        instanceID = 967,
        disabled = true,
        collections = {
            {
                -- Ultraxion
                bossIndex = 5,
                bossBit = 5,
                type = 'mount',
                mountID = 445,
                itemID = 78919,
            },
            {
                -- Madness of Deathwing
                bossIndex = 8,
                bossBit = 7,
                type = 'mount',
                mountID = 442,
                itemID = 77067,
            },
        },
    },
    {
        -- Terrace of Endless Spring
        instanceID = 996,
        disabled = true,
        collections = {
            {
                -- Sha of Fear
                bossIndex = 4,
                bossBit = 1,
                type = 'illusion',
                itemID = 138805,
                sourceID = 4442,
            },
        },
    },
    {
        -- Mogu'shan Vaults
        instanceID = 1008,
        disabled = true,
        collections = {
            {
                -- Elegon
                bossIndex = 5,
                bossBit = 5,
                type = 'mount',
                mountID = 478,
                itemID = 87777,
            },
        },
    },
    {
        -- Throne of Thunder
        instanceID = 1098,
        disabled = true,
        collections = {
            {
                -- Horridon
                bossIndex = 2,
                bossBit = 7,
                type = 'mount',
                mountID = 531,
                itemID = 93666,
            },
            {
                -- Ji-Kun
                bossIndex = 6,
                bossBit = 5,
                type = 'mount',
                mountID = 543,
                itemID = 95059,
            },
        },
    },
    {
        -- Siege of Orgrimmar
        instanceID = 1136,
        difficulties = {
            [14] = {1},
            [15] = {2},
        },
        collections = {
            {
                -- Siegecrafter Blackfuse
                bossIndex = 12,
                bossBit = 6,
                type = 'pet',
                itemID = 104158,
            },
            {
                -- Garrosh Hellscream
                bossIndex = 14,
                bossBit = 13,
                type = 'transmog',
                itemID = 112935,
                available = (
                    classFilename == 'WARRIOR' or
                    classFilename == 'DEATHKNIGHT' or
                    classFilename == 'PALADIN'
                ),
            },
        }
    },
    {
        -- Blackrock Foundry
        instanceID = 1205,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- Blackhand
                bossIndex = 10,
                bossBit = 8,
                type = 'illusion',
                itemID = 138809,
                sourceID = 5336,
            },
        },
    },
    {
        -- Hellfire Citadel
        instanceID = 1448,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- Kilrogg Deadeye
                bossIndex = 5,
                bossBit = 5,
                type = 'illusion',
                itemID = 138808,
                sourceID = 5384,
            },
        },
    },
    {
        -- The Emerald Nightmare
        instanceID = 1520,
        difficulties = {
            [14] = {1},
            [15] = {1, 2},
        },
        collections = {
            {
                -- Xavius
                bossIndex = 7,
                bossBit = 3,
                type = 'illusion',
                itemID = 138827,
                sourceID = 5876,
            },
            {
                -- Xavius
                bossIndex = 7,
                bossBit = 3,
                type = 'transmog',
                itemID = 141006,
                available = (
                    classFilename == 'DRUID' or
                    classFilename == 'ROGUE' or
                    classFilename == 'MONK' or
                    classFilename == 'DEMONHUNTER'
                ),
            },
        },
    },
    {
        -- The Nighthold
        instanceID = 1530,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- Gul'dan
                bossIndex = 10,
                bossBit = 5,
                type = 'mount',
                mountID = 791,
                itemID = 137574,
            },
        },
    },
    {
        -- Tomb of Sargeras
        instanceID = 1676,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- Mistress Sassz'ine
                bossIndex = 5,
                bossBit = 2,
                type = 'mount',
                mountID = 899,
                itemID = 143643,
            },
        },
    },
    {
        -- Antorus, the Burning Throne
        instanceID = 1712,
        difficulties = {
            [14] = {1, 2, 3},
            [15] = {1, 2, 3},
        },
        collections = {
            {
                -- Felhounds of Sargeras
                bossIndex = 2,
                bossBit = 5,
                type = 'mount',
                mountID = 971,
                itemID = 152816,
            },
            {
                -- Aggramar
                bossIndex = 10,
                bossBit = 0,
                type = 'transmog',
                itemID = 152094,
                available = (
                    classFilename == 'WARRIOR' or
                    classFilename == 'DEATHKNIGHT' or
                    classFilename == 'PALADIN' or
                    classFilename == 'HUNTER'
                ),
            },
            {
                -- Argus the Unmaker
                bossIndex = 11,
                bossBit = 10,
                type = 'transmog',
                itemID = 153115,
                available = (
                    classFilename == 'WARRIOR' or
                    classFilename == 'DEATHKNIGHT' or
                    classFilename == 'PALADIN' or
                    classFilename == 'HUNTER' or
                    classFilename == 'DRUID' or
                    classFilename == 'MONK'
                ),
            },
        },
    },
    {
        -- Uldir
        instanceID = 1861,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- Mythrax
                bossIndex = 7,
                bossBit = 3,
                type = 'transmog',
                itemID = 160686,
                available = (
                    classFilename == 'WARRIOR' or
                    classFilename == 'DEATHKNIGHT' or
                    classFilename == 'PALADIN'
                ),
            },
        },
    },
    {
        -- Battle of Dazar'alor
        instanceID = 2070,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- High Tinker Mekkatorque
                bossIndex = 7,
                bossBit = 12,
                type = 'mount',
                mountID = 1217,
                itemID = 166518,
            },
        },
    },
    {
        -- Sanctum of Domination
        instanceID = 2450,
        difficulties = {
            [14] = {1},
            [15] = {1},
        },
        collections = {
            {
                -- The Nine
                bossIndex = 3,
                bossBit = 2,
                type = 'mount',
                mountID = 1500,
                itemID = 186656,
            },
        },
    },
    {
        -- Return to Karazhan
        instanceID = 1651,
        difficulties = {
            [23] = {1},
        },
        collections = {
            {
                -- Attumen the Huntsman
                bossIndex = 4,
                bossBit = 3,
                type = 'mount',
                mountID = 875,
                itemID = 142236,
            },
        },
    },
    -- {
    --     -- Freehold
    --     instanceID = 1754,
    --     difficulties = {
    --         [23] = {1},
    --     },
    --     collections = {
    --         {
    --             -- Harlan Sweete
    --             bossIndex = 4,
    --             bossBit = 3,
    --             type = 'mount',
    --             mountID = 995,
    --             itemID = 159842,
    --         },
    --     },
    -- },
    -- {
    --     -- Kings' Rest
    --     instanceID = 1762,
    --     difficulties = {
    --         [23] = {1},
    --     },
    --     collections = {
    --         {
    --             -- King Dazar
    --             bossIndex = 4,
    --             bossBit = 3,
    --             type = 'mount',
    --             mountID = 1040,
    --             itemID = 159921,
    --         },
    --     },
    -- },
    -- {
    --     -- The Underrot
    --     instanceID = 1841,
    --     difficulties = {
    --         [23] = {1},
    --     },
    --     collections = {
    --         {
    --             -- Unbound Abomination
    --             bossIndex = 4,
    --             bossBit = 3,
    --             type = 'mount',
    --             mountID = 1053,
    --             itemID = 160829,
    --         },
    --     },
    -- },
    {
        -- Operation: Mechagon
        instanceID = 2097,
        difficulties = {
            [23] = {1},
        },
        collections = {
            {
                -- HK-8 Aerial Oppression Unit
                bossIndex = 4,
                bossBit = 5,
                type = 'mount',
                mountID = 1252,
                itemID = 168826,
            },
        },
    },
    {
        -- Tazavesh, the Veiled Market
        instanceID = 2441,
        difficulties = {
            [2] = {1},
            [23] = {1},
        },
        collections = {
            {
                -- So'leah
                bossIndex = 8,
                bossBit = 7,
                type = 'mount',
                mountID = 1481,
                itemID = 186638,
            },
        },
    },
}

do
    local eventFrame = CreateFrame('Frame')
    eventFrame:RegisterEvent('ENCOUNTER_END')
    eventFrame:RegisterEvent('UPDATE_INSTANCE_INFO')
    eventFrame:RegisterEvent('NEW_MOUNT_ADDED')
    eventFrame:RegisterEvent('NEW_TOY_ADDED')
    eventFrame:RegisterEvent('NEW_PET_ADDED')
    eventFrame:RegisterEvent('TRANSMOG_COLLECTION_UPDATED')
    eventFrame:SetScript('OnEvent', function(_, event, ...)
        if event == 'ENCOUNTER_END' then
            local success = select(5, ...)
            if success == 1 then
                RequestRaidInfo()
            end
        elseif (
            event == 'UPDATE_INSTANCE_INFO' or event == 'NEW_MOUNT_ADDED' or
            event == 'NEW_TOY_ADDED' or event == 'NEW_PET_ADDED' or
            event == 'TRANSMOG_COLLECTION_UPDATED'
        ) then
            if F.window and F.window:IsShown() then
                F:LoadInstances()
            end
        end
    end)
end

do
    local scanTooltipName = 'FIFScanTooltip'
    local scanTooltip = CreateFrame('GameTooltip', scanTooltipName, UIParent, 'GameTooltipTemplate')
    scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')

    local matchStr = gsub(INSTANCE_LOCK_SS, '%%[ds]', '(.+)')
    local template = "|cffff8000|Hinstancelock:" .. UnitGUID('player') .. ":%d:%d:%d|h[%s]|h|r"

    local instanceNameCache = {}
    local bossNameCache = {}

    function F:GetInstanceAndBossName(instanceID, bossIndex, bossBit)
        if instanceNameCache[instanceID] and bossNameCache[instanceID] and bossNameCache[instanceID][bossIndex] then
            return instanceNameCache[instanceID], bossNameCache[instanceID][bossIndex]
        end

        local bitmap = bit_lshift(1, bossBit)
        local root = format(template, instanceID, 0, bitmap, '')
        scanTooltip:SetHyperlink(root)

        local instanceName = _G[scanTooltipName .. 'TextLeft1']:GetText()
        instanceName = instanceName and select(2, strmatch(instanceName, matchStr))

        local bossName = _G[scanTooltipName .. 'TextLeft' .. (bossIndex + 1)]:GetText()

        if instanceName and bossName then
            instanceNameCache[instanceID] = instanceName
            if not bossNameCache[instanceID] then
                bossNameCache[instanceID] = {}
            end
            bossNameCache[instanceID][bossIndex] = bossName
        end

        return instanceName, bossName
    end
end

do
    local data = {}
    local inProgress = {}
    local instanceLock = {}
    local instanceLink = {}
    local scrollTable
    local isFinalized

    local function ExportData()
        if isFinalized and not next(inProgress) then
            scrollTable:SetData(data)
        end
    end

    function F:InitializeCollection(st)
        wipe(data)
        wipe(inProgress)
        wipe(instanceLock)
        wipe(instanceLink)

        scrollTable = st
        isFinalized = nil

        for i = 1, GetNumSavedInstances() do
            local difficulty, locked = select(4, GetSavedInstanceInfo(i))
            if locked then
                local link = GetSavedInstanceChatLink(i)
                local instanceID, bossBits = strmatch(link, ':(%d+):%d+:(%d+)\124h')
                if instanceID then
                    instanceID = tonumber(instanceID)
                    bossBits = tonumber(bossBits)

                    if not instanceLock[instanceID] then
                        instanceLock[instanceID] = {}
                    end
                    instanceLock[instanceID][difficulty] = bossBits
                    instanceLink[instanceID] = link
                end
            end
        end
    end

    function F:HandleCollection(instanceID, difficultyID, disabled, collectionData, retries)
        if not showNotAvailable and collectionData.available == false then return end

        local difficultyName = difficultyID and GetDifficultyInfo(difficultyID)
        local instanceName, bossName =
            self:GetInstanceAndBossName(instanceID, collectionData.bossIndex, collectionData.bossBit)

        if (not instanceName or not bossName) and (not retries or retries < 2) then
            local index = instanceID .. '-' .. (difficultyID or 0)
            inProgress[index] = true
            C_Timer_After(1, function()
                inProgress[index] = nil
                F:HandleCollection(instanceID, difficultyID, disabled, collectionData, retries and (retries + 1) or 1)
                ExportData()
            end)
            return
        end

        local info = {
            disabled = disabled,
            instanceLockLink = instanceLink[instanceID],
            instance = instanceName or instanceID,
            difficulty = difficultyName or '',
            boss = bossName or collectionData.bossIndex,
            collected = collectionData.available == false and 136813
        }

        if instanceLock[instanceID] then
            local bossBits, _
            if not difficultyID then
                _, bossBits = next(instanceLock[instanceID])
            else
                bossBits = instanceLock[instanceID][difficultyID]
            end

            if bossBits and bit_band(bossBits, bit_lshift(1, collectionData.bossBit)) > 0 then
                if not showLooted then return end

                info.killed = 136814
            end
        end

        local collectionType = collectionData.type
        if collectionType == 'achievement' then
            local completed = select(4, GetAchievementInfo(collectionData.achievementID))
            if not showCollected and completed then return end

            local link = GetAchievementLink(collectionData.achievementID)
            info.collected = completed and 136814 or info.collected
            info.collection = link
            info.achievementLink = link

            tinsert(data, info)
            return
        end

        local isCollected
        if collectionType == 'mount' then
            isCollected = select(11, C_MountJournal_GetMountInfoByID(collectionData.mountID))
        elseif collectionType == 'toy' then
            isCollected = PlayerHasToy(collectionData.itemID)
        elseif collectionType == 'pet' then
            local name = C_PetJournal_GetPetInfoByItemID(collectionData.itemID)
            local petGUID = name and select(2, C_PetJournal_FindPetIDByName(name))
            isCollected = not not petGUID
        elseif collectionType == 'illusion' then
            local visualsList = C_TransmogCollection_GetIllusions()
            for _, visual in ipairs(visualsList) do
                if visual.sourceID == collectionData.sourceID then
                    isCollected = visual.isCollected
                    break
                end
            end
        elseif collectionType == 'transmog' then
            local prevAppearanceID
            for i = 0, 4 do
                local appearanceID, sourceID = C_TransmogCollection_GetItemInfo(collectionData.itemID, i)
                if appearanceID then
                    if not prevAppearanceID then
                        prevAppearanceID = appearanceID
                        isCollected = select(5, C_TransmogCollection_GetAppearanceSourceInfo(sourceID))
                    elseif prevAppearanceID ~= appearanceID then
                        local itemModID = difficultyID == 14 and 0 or 1
                        local sourceID = select(2, C_TransmogCollection_GetItemInfo(collectionData.itemID, itemModID))
                        isCollected = sourceID and select(5, C_TransmogCollection_GetAppearanceSourceInfo(sourceID))
                        break
                    elseif not isCollected then
                        isCollected = select(5, C_TransmogCollection_GetAppearanceSourceInfo(sourceID))
                    end
                end
            end
        end

        if not showCollected and isCollected then return end

        local itemLink = select(2, GetItemInfo(collectionData.itemID))
        if not itemLink then
            local item = Item:CreateFromItemID(collectionData.itemID)
            inProgress[item] = true

            item:ContinueOnItemLoad(function()
                inProgress[item] = nil

                itemLink = select(2, GetItemInfo(collectionData.itemID))
                info.collected = isCollected and 136814 or info.collected
                info.collection = itemLink
                info.itemID = collectionData.itemID
                tinsert(data, info)

                ExportData()
            end)

            C_Timer_After(2, function()
                if inProgress[item] then
                    -- timeout
                    inProgress[item] = nil

                    itemLink = select(2, GetItemInfo(collectionData.itemID))
                    info.collected = isCollected and 136814 or info.collected
                    info.collection = itemLink or collectionData.itemID
                    info.itemID = collectionData.itemID
                    tinsert(data, info)

                    ExportData()
                end
            end)
            return
        end

        info.collected = isCollected and 136814 or info.collected
        info.collection = itemLink
        info.itemID = collectionData.itemID
        tinsert(data, info)
    end

    function F:FinalizeCollection()
        isFinalized = true
        ExportData()
    end
end

function F:LoadInstances()
    self:InitializeCollection(self.scrollTable)

    for _, instanceData in ipairs(instanceList) do
        if showDisabled or not instanceData.disabled then
            local instanceID = instanceData.instanceID
            if not instanceData.difficulties then
                for _, collectionData in ipairs(instanceData.collections) do
                    self:HandleCollection(instanceID, nil, instanceData.disabled, collectionData)
                end
            else
                for difficultyID, collectionIndexes in pairs(instanceData.difficulties) do
                    for _, index in ipairs(collectionIndexes) do
                        self:HandleCollection(instanceID, difficultyID, instanceData.disabled, instanceData.collections[index])
                    end
                end
            end
        end
    end

    self:FinalizeCollection()
end

function F:BuildWindow()
    local window = StdUi:Window(_G.UIParent, 700, 500, "支持副本")
    window:SetPoint('CENTER')
    window:SetScript('OnShow', function()
        F:LoadInstances()
    end)
    window:Hide()
    self.window = window

    local showDisabledButton = StdUi:Checkbox(window, "显示失效副本")
    showDisabledButton:SetChecked(showDisabled)
    showDisabledButton.OnValueChanged = function(_, checked)
        showDisabled = checked
        F:LoadInstances()
    end
    showDisabledButton:HookScript('OnEnter', function(self)
        _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine("显示由于游戏原因，无法提供染进度服务的副本。")
        _G.GameTooltip:Show()
    end)
    showDisabledButton:HookScript('OnLeave', function(self)
        _G.GameTooltip:Hide()
    end)
    StdUi:GlueTop(showDisabledButton, window, 50, -40, 'LEFT')

    local showLootedButton = StdUi:Checkbox(window, "显示已击杀首领")
    showLootedButton:SetChecked(showLooted)
    showLootedButton.OnValueChanged = function(_, checked)
        showLooted = checked
        F:LoadInstances()
    end
    showLootedButton:HookScript('OnEnter', function(self)
        _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine("显示此角色本周已经击杀的首领。")
        _G.GameTooltip:Show()
    end)
    showLootedButton:HookScript('OnLeave', function(self)
        _G.GameTooltip:Hide()
    end)
    StdUi:GlueTop(showLootedButton, window, 200, -40, 'LEFT')

    local showCollectedButton = StdUi:Checkbox(window, "显示已经收集藏品")
    showCollectedButton:SetChecked(showCollected)
    showCollectedButton.OnValueChanged = function(_, checked)
        showCollected = checked
        F:LoadInstances()
    end
    showCollectedButton:HookScript('OnEnter', function(self)
        _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine("显示已经收集的藏品。")
        _G.GameTooltip:Show()
    end)
    showCollectedButton:HookScript('OnLeave', function(self)
        _G.GameTooltip:Hide()
    end)
    StdUi:GlueTop(showCollectedButton, window, 350, -40, 'LEFT')

    local showNotAvailableButton = StdUi:Checkbox(window, "显示不可收藏藏品")
    showNotAvailableButton:SetChecked(showNotAvailable)
    showNotAvailableButton.OnValueChanged = function(_, checked)
        showNotAvailable = checked
        F:LoadInstances()
    end
    showNotAvailableButton:HookScript('OnEnter', function(self)
        _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine("显示此角色无法获取或加入收藏的藏品。")
        _G.GameTooltip:Show()
    end)
    showNotAvailableButton:HookScript('OnLeave', function(self)
        _G.GameTooltip:Hide()
    end)
    StdUi:GlueTop(showNotAvailableButton, window, 500, -40, 'LEFT')

    local cols = {
        {
            name     = "副本",
            width    = 150,
            align    = 'LEFT',
            index    = 'instance',
            format   = 'string',
            color    = function(_, _, rowData)
                if rowData.disabled then
                    return {r = 1, g = 0, b = 0, a = 1}
                end
                return {r = 1, g = 1, b = 1, a = 1}
            end,
            events   = {
                OnEnter = function(_, cellFrame, _, rowData)
                    if rowData.instanceLockLink then
                        _G.GameTooltip:SetOwner(cellFrame, 'ANCHOR_BOTTOMRIGHT')
                        _G.GameTooltip:ClearLines()
                        _G.GameTooltip:SetHyperlink(rowData.instanceLockLink)
                        _G.GameTooltip:Show()
                    end
                end,
                OnLeave = function()
                    _G.GameTooltip:Hide()
                end,
            },
        },
        {
            name     = "难度",
            width    = 40,
            align    = 'LEFT',
            index    = 'difficulty',
            format   = 'string',
        },
        {
            name     = "",
            width    = 40,
            align    = 'LEFT',
            index    = 'killed',
            format   = 'icon',
        },
        {
            name     = "首领",
            width    = 150,
            align    = 'LEFT',
            index    = 'boss',
            format   = 'string',
            events   = {
                OnEnter = function(_, cellFrame, _, rowData)
                    if rowData.instanceLockLink then
                        _G.GameTooltip:SetOwner(cellFrame, 'ANCHOR_BOTTOMRIGHT')
                        _G.GameTooltip:ClearLines()
                        _G.GameTooltip:SetHyperlink(rowData.instanceLockLink)
                        _G.GameTooltip:Show()
                    end
                end,
                OnLeave = function()
                    _G.GameTooltip:Hide()
                end,
            },
        },
        {
            name     = "",
            width    = 40,
            align    = 'LEFT',
            index    = 'collected',
            format   = 'icon',
        },
        {
            name     = "藏品",
            width    = 200,
            align    = 'LEFT',
            index    = 'collection',
            format   = 'string',
            events   = {
                OnEnter = function(_, cellFrame, _, rowData)
                    if rowData.itemID then
                        _G.GameTooltip:SetOwner(cellFrame, 'ANCHOR_BOTTOMRIGHT')
                        _G.GameTooltip:ClearLines()
                        _G.GameTooltip:SetItemByID(rowData.itemID)
                        _G.GameTooltip:Show()
                    elseif rowData.achievementLink then
                        _G.GameTooltip:SetOwner(cellFrame, 'ANCHOR_BOTTOMRIGHT')
                        _G.GameTooltip:ClearLines()
                        _G.GameTooltip:SetHyperlink(rowData.achievementLink)
                        _G.GameTooltip:Show()
                    end
                end,
                OnLeave = function()
                    _G.GameTooltip:Hide()
                end,
            },
        },
    }

    local st = StdUi:ScrollTable(window, cols, 15, 24)
    st:EnableSelection(true)
    StdUi:GlueTop(st, window, 0, -100)
    self.scrollTable = st

    -- xxx: rely on internal implement of StdUi
    local refreshButton = StdUi:SquareButton(window, 20, 20, '')
    refreshButton:SetIcon('Interface/Buttons/UI-RefreshButton', 16, 16, true)
    refreshButton:SetScript('OnClick', function()
        F:LoadInstances()
    end)
    StdUi:GlueAbove(refreshButton, st, 0, 0, 'RIGHT')
end

function F:ToggleInstances()
    if not self.window then
        self:BuildWindow()
    elseif self.window:IsShown() then
        self.window:Hide()
        return
    end

    self.window:Show()
end
