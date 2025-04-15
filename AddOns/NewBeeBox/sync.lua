local adonName, ns = ...

local pt = print
local After = C_Timer.After

local ver = select(4, GetBuildInfo())
local realmID = GetRealmID()
local realmName = GetRealmName()
local player = UnitName("player")

local function RegisterEvent(Event, OnEvent)
    local frame = CreateFrame("Frame")
    frame:RegisterEvent(Event)
    frame:SetScript("OnEvent", OnEvent)
end

local function Size(t)
    local s = 0
    for k, v in pairs(t) do
        if v ~= nil then s = s + 1 end
    end
    return s
end

local NB = {}

if ver >= 110000 then
    NB.IsRetail = true
elseif ver >= 40000 then
    NB.IsCTM = true
elseif ver >= 30000 then
    NB.IsWLK = true
else
    NB.IsVanilla = true
end

local function Init()
    -- 藏品
    if not NB.IsVanilla then
        WclBoxGlobal.collections = WclBoxGlobal.collections or {}
        -- 坐骑
        do
            WclBoxGlobal.collections.mount = WclBoxGlobal.collections.mount or {}

            function NB.SaveMountInfo(mountID)
                local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific,
                faction, shouldHideOnChar, isCollected, mountID, isSteadyFlight = C_MountJournal.GetMountInfoByID(mountID)
                -- https://warcraft.wiki.gg/wiki/API_C_MountJournal.GetMountInfoByID
                if isCollected then
                    local sourceText = "未分类"
                    if sourceType ~= 0 then
                        sourceText = _G["BATTLE_PET_SOURCE_" .. sourceType] or ""
                    end
                    WclBoxGlobal.collections.mount[mountID] = {
                        mountID        = mountID,        -- 坐骑ID
                        name           = name,           -- 坐骑名字
                        spellID        = spellID,        -- 法术ID
                        icon           = icon,           -- 图标材质ID
                        sourceType     = sourceType,     -- 坐骑来源ID（0-11，怀旧服的都是0）
                        sourceText     = sourceText,     -- 坐骑来源文本（怀旧服的都是未分类，正式服的可能有世界活动/成就/宠物大战等等）
                        isFavorite     = isFavorite,     -- 玩家是否设定为了偏好
                        isSteadyFlight = isSteadyFlight, -- 是否飞行坐骑
                    }
                end
            end

            for i, mountID in ipairs(C_MountJournal.GetMountIDs()) do
                NB.SaveMountInfo(mountID)
            end

            RegisterEvent("NEW_MOUNT_ADDED", function(self, event, mountID)
                NB.SaveMountInfo(mountID)
            end)
        end

        -- 宠物
        do
            WclBoxGlobal.collections.pet = WclBoxGlobal.collections.pet or {}

            function NB.SavePetInfo(i, _petID)
                if not WclBoxGlobal.collections.pet then return end
                local petID, speciesID, owned, customName, level, isFavorite, isRevoked, speciesName, icon,
                petType, companionID, sourceText, description, isWild, canBattle, isTradeable, isUnique,
                obtainable, _
                if i then
                    petID, speciesID, owned, customName, level, isFavorite, isRevoked, speciesName, icon,
                    petType, companionID, sourceText, description, isWild, canBattle, isTradeable, isUnique,
                    obtainable = C_PetJournal.GetPetInfoByIndex(i)
                elseif _petID then
                    speciesID, customName, level, _, _, _, isFavorite, speciesName, icon, petType,
                    _, sourceText, description, isWild, canBattle, isTradeable, isUnique,
                    obtainable = C_PetJournal.GetPetInfoByPetID(_petID)
                end
                -- https://warcraft.wiki.gg/wiki/API_C_PetJournal.GetPetInfoByIndex
                -- https://warcraft.wiki.gg/wiki/API_C_PetJournal.GetPetInfoByPetID
                if owned or _petID then
                    WclBoxGlobal.collections.pet[speciesID] = {
                        petID       = petID or _petID, -- 宠物ID（这种格式的：BattlePet-0-00000019984F，如果同一种宠物有多个（比如凤凰宝宝），这个ID不同）
                        speciesID   = speciesID,       -- 物种ID（如果同一种宠物有多个（比如凤凰宝宝），这个ID相同）
                        isFavorite  = isFavorite,      -- 玩家是否设定为了偏好
                        speciesName = speciesName,     -- 宠物名字
                        icon        = icon,            -- 图标材质ID
                        petType     = petType,         -- 物种类型
                        companionID = companionID,     -- 生物ID（实际召唤出来的宠物的NPC ID）
                        sourceText  = sourceText,      -- 宠物来源文本（怀旧服返回的值是空的"")
                        description = description,     -- 宠物的描述文本（怀旧服返回的值是空的"")
                        isTradeable = isTradeable,     -- 宠物是否可交易
                        isUnique    = isUnique,        -- 宠物是否唯一
                        obtainable  = obtainable,      -- 宠物是否可获得（可能是指是否已绝版？）
                    }
                end
            end

            local default1 = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED)
            local default2 = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED)
            C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
            C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, false)
            After(5, function()
                local numPets, numOwned = C_PetJournal.GetNumPets()
                for i = 1, numPets do
                    NB.SavePetInfo(i)
                end
                C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, default1)
                C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, default2)
            end)

            RegisterEvent("NEW_PET_ADDED", function(self, event, petID)
                NB.SavePetInfo(nil, petID)
            end)
        end

        -- 玩具
        do
            WclBoxGlobal.collections.toy = WclBoxGlobal.collections.toy or {}

            function NB.SaveToyInfo(itemID)
                if itemID == -1 then return end
                if not PlayerHasToy(itemID) then return end
                local itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(itemID)
                WclBoxGlobal.collections.toy[itemID] = {
                    itemID = itemID,           -- 玩具的物品ID
                    toyName = toyName,         -- 玩具名称
                    icon = icon,               -- 图标材质ID
                    isFavorite = isFavorite,   -- 玩家是否设定为了偏好
                    itemQuality = itemQuality, -- 玩具的物品质量（0灰色，1白色，2绿色，3蓝色，4紫色，5橙色）
                }
            end

            After(5, function()
                for i = 1, C_ToyBox.GetNumToys() do
                    local itemID = C_ToyBox.GetToyFromIndex(i)
                    NB.SaveToyInfo(itemID)
                end
            end)
            RegisterEvent("NEW_TOY_ADDED", function(self, event, itemID)
                NB.SaveToyInfo(itemID)
            end)
        end
    end

    -- 成就
    if not NB.IsVanilla then
        WclBoxGlobal.achievements = nil
        WclBoxCharacter.achievements = WclBoxCharacter.achievements or {}

        -- 成就
        do
            WclBoxCharacter.achievements.totalPoint = WclBoxCharacter.achievements.totalPoint or {}
            WclBoxCharacter.achievements.achievement = WclBoxCharacter.achievements.achievement or {}

            local updateFrame = CreateFrame("Frame")

            function NB.SaveTotalAchievementPoints()
                WclBoxCharacter.achievements.totalPoint = GetTotalAchievementPoints()
            end

            function NB.SaveAchievementInfo(categoryIDorAchievementID, i)
                local achievementID, title, points, completed, month, day, year, description, flags, icon,
                rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(categoryIDorAchievementID, i)
                if completed then
                    local categoryID = GetAchievementCategory(achievementID)
                    local parentTitle = GetCategoryInfo(categoryID)
                    local dateText = year and format("%d-%02d-%02d", year, month, day) or nil
                    WclBoxCharacter.achievements.achievement[achievementID] = {
                        parentTitle = parentTitle,     -- 类别名称（比如完成50个任务，类别就是"任务"）
                        achievementID = achievementID, -- 成就ID
                        title = title,                 -- 成就名字
                        points = points,               -- 成就点数
                        completed_date = dateText,     -- 完成日期（格式是：25-03-10）
                        description = description,     -- 成就描述
                        icon = icon,                   -- 图标材质ID
                        rewardText = rewardText,       -- 成就奖励的相关介绍文本
                        isGuild = isGuild,             -- 是否公会成就
                    }
                    local preAchievementID = GetPreviousAchievement(achievementID)
                    if preAchievementID then
                        NB.SaveAchievementInfo(preAchievementID)
                    end
                end
            end

            local tbl = {}
            local function GetCompletedAchievements()
                if IsInInstance() then return end
                wipe(tbl)
                local categories = GetCategoryList()
                for _, categoryID in ipairs(categories) do
                    for i = 1, GetCategoryNumAchievements(categoryID) do
                        tinsert(tbl, {
                            categoryID = categoryID,
                            i = i,
                        })
                    end
                end
                local startI = 1
                local oneTime = 1
                local isEnd
                updateFrame:SetScript("OnUpdate", function(self, elapsed)
                    if IsInInstance() or isEnd then
                        self:SetScript("OnUpdate", nil)
                        return
                    end
                    for i = startI, startI + oneTime - 1 do
                        local v = tbl[i]
                        if not v then
                            isEnd = true
                            break
                        end
                        NB.SaveAchievementInfo(v.categoryID, v.i)
                    end
                    startI = startI + oneTime
                end)
            end

            After(6, function()
                NB.SaveTotalAchievementPoints()
                GetCompletedAchievements()
            end)

            RegisterEvent("ACHIEVEMENT_EARNED", function(self, event, achievementID)
                NB.SaveAchievementInfo(achievementID)
                After(1, function()
                    NB.SaveTotalAchievementPoints()
                end)
            end)
        end

        -- 统计
        do
            WclBoxCharacter.achievements.Statistic = WclBoxCharacter.achievements.Statistic or {}

            local updateFrame = CreateFrame("Frame")

            function NB.SaveStatisticInfo(categoryID, i)
                local achievementID, title, points, completed, month, day, year, description, flags, icon,
                rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(categoryID, i)
                if not achievementID then return end
                local value = GetStatistic(achievementID)
                value = value:gsub("|T.-|t", ""):gsub(" ", "")
                if value == "--" or value == "0" then return end
                local parentTitle = GetCategoryInfo(categoryID)
                WclBoxCharacter.achievements.Statistic[achievementID] = {
                    value = value,                 -- 统计数值
                    parentTitle = parentTitle,     -- 类别名称（比如统计：使用绷带，类别是"消耗品"）
                    achievementID = achievementID, -- 成就ID
                    description = description,     -- 统计内容（比如使用绷带：83，这个值就是"使用绷带"
                }
            end

            local tbl = {}
            local function GetStatisticInfo()
                if IsInInstance() then return end
                wipe(tbl)
                local categories = GetStatisticsCategoryList()
                for _, categoryID in ipairs(categories) do
                    for i = 1, GetCategoryNumAchievements(categoryID) do
                        tinsert(tbl, {
                            categoryID = categoryID,
                            i = i,
                        })
                    end
                end
                local startI = 1
                local oneTime = 1
                local isEnd
                updateFrame:SetScript("OnUpdate", function(self, elapsed)
                    if IsInInstance() or isEnd then
                        self:SetScript("OnUpdate", nil)
                        return
                    end
                    for i = startI, startI + oneTime - 1 do
                        local v = tbl[i]
                        if not v then
                            isEnd = true
                            break
                        end
                        NB.SaveStatisticInfo(v.categoryID, v.i)
                    end
                    startI = startI + oneTime
                end)
            end

            After(60, function()
                GetStatisticInfo()
            end)
            C_Timer.NewTicker(300, function()
                GetStatisticInfo()
            end)
        end
    end

    -- 背包/银行物品
    do
        WclBoxCharacter.bag = WclBoxCharacter.bag or {}
        WclBoxCharacter.bagKey = WclBoxCharacter.bagKey or {}
        WclBoxCharacter.bank = WclBoxCharacter.bank or {}

        local function GetBagSlots(bagType)
            if bagType == "bag" then
                if NB.IsRetail then
                    return BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS
                else
                    return BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS
                end
            elseif bagType == "bank" then
                if NB.IsRetail then
                    return NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS
                else
                    return NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
                end
            end
        end

        local function SaveFormBagNum(b, bagType)
            for i = 1, C_Container.GetContainerNumSlots(b) do
                local info = C_Container.GetContainerItemInfo(b, i)
                if info then
                    tinsert(WclBoxCharacter[bagType], {
                        itemID = info.itemID,
                        isBound = info.isBound,
                        stackCount = info.stackCount,
                    })
                end
            end
        end
        function NB.SaveBag()
            wipe(WclBoxCharacter.bag)
            wipe(WclBoxCharacter.bagKey)
            local startB, endB = GetBagSlots("bag")
            for b = startB, endB do
                SaveFormBagNum(b, "bag")
            end
            SaveFormBagNum(-2, "bagKey")
        end

        function NB.SaveBank()
            if not NB.bankIsOpen then return end
            wipe(WclBoxCharacter.bank)
            local startB, endB = GetBagSlots("bank")
            for b = startB, endB do
                SaveFormBagNum(b, "bank")
            end
            SaveFormBagNum(-1, "bank")
        end

        local f = CreateFrame("Frame")
        f:RegisterEvent("BAG_UPDATE_DELAYED")
        f:RegisterEvent("BANKFRAME_OPENED")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "BAG_UPDATE_DELAYED" then
                NB.SaveBag()
                NB.SaveBank()
            elseif event == "BANKFRAME_OPENED" then
                NB.bankIsOpen = true
                NB.SaveBank()
            elseif event == "BANKFRAME_CLOSED" then
                NB.bankIsOpen = false
            end
        end)
    end

    -- 角色装备
    do
        WclBoxCharacter.equip = WclBoxCharacter.equip or {}

        function NB.SaveEquip()
            wipe(WclBoxCharacter.equip)
            for slot = 1, 19 do
                local link = GetInventoryItemLink("player", slot)
                local itemID = GetInventoryItemID("player", slot)
                slot = tostring(slot)
                WclBoxCharacter.equip[slot] = {
                    link = link,
                    itemID = itemID,
                }
            end
        end

        NB.SaveEquip()

        RegisterEvent("UNIT_INVENTORY_CHANGED", function()
            After(.5, function()
                NB.SaveEquip()
            end)
        end)
    end

    -- 货币
    if not NB.IsVanilla then
        WclBoxCharacter.currency = WclBoxCharacter.currency or {}

        local GetCurrencyListSize = (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListSize) or GetCurrencyListSize
        local GetCurrencyListInfo = (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListInfo) or GetCurrencyListInfo
        local GetCurrencyListLink = (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListLink) or GetCurrencyListLink
        local ExpandCurrencyList = (C_CurrencyInfo and C_CurrencyInfo.ExpandCurrencyList) or ExpandCurrencyList
        local header

        local function GetCurrencyID(link)
            return tonumber(link:match("currency:(%d+)"))
        end

        local function Expand()
            local check = true
            local count = 0
            while check do
                check = false
                count = count + 1
                for i = 1, GetCurrencyListSize() do
                    local headerCheck = GetCurrencyListInfo(i)
                    if NB.IsRetail then
                        if headerCheck.isHeader and not headerCheck.isHeaderExpanded then
                            ExpandCurrencyList(i, true)
                            check = true
                        end
                    else
                        local name, isHeader, isExpanded = GetCurrencyListInfo(i)
                        if isHeader and not isExpanded then
                            ExpandCurrencyList(i, 1)
                            check = true
                        end
                    end
                end
                if count >= 50 then
                    break
                end
            end
        end

        function NB.SaveCurrency()
            wipe(WclBoxCharacter.currency)
            header = nil
            Expand()
            for i = 1, GetCurrencyListSize() do
                if NB.IsRetail then
                    local info = GetCurrencyListInfo(i)
                    if info.isHeader then
                        header = info.name
                    else
                        local link = GetCurrencyListLink(i)
                        local currencyID = GetCurrencyID(link)
                        WclBoxCharacter.currency[currencyID] = {
                            name = info.name,
                            count = info.quantity,
                            icon = info.iconFileID,
                            header = header,
                        }
                    end
                else
                    local name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum,
                    hasWeeklyLimit, currentWeeklyAmount, unknown, itemID = GetCurrencyListInfo(i)
                    if isHeader then
                        header = name
                    else
                        local link = GetCurrencyListLink(i)
                        local currencyID = GetCurrencyID(link)
                        WclBoxCharacter.currency[currencyID] = {
                            name = name,
                            count = count,
                            icon = icon,
                            header = header,
                        }
                    end
                end
            end
        end

        NB.SaveCurrency()

        RegisterEvent("CURRENCY_DISPLAY_UPDATE", function()
            After(.5, function()
                NB.SaveCurrency()
            end)
        end)
    end

    -- 副本CD
    do
        WclBoxCharacter.instanceCD = WclBoxCharacter.instanceCD or {}

        function NB.SaveInstanceCD()
            wipe(WclBoxCharacter.instanceCD)
            local time = GetServerTime()
            for i = 1, GetNumSavedInstances() do
                local name, lockoutID, resettime, difficultyID, locked, extended, instanceIDMostSig,
                isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled,
                instanceID = GetSavedInstanceInfo(i)
                if locked then
                    local encounterInfo = {}
                    for ii = 1, numEncounters do
                        local bossName, fileDataID, isKilled =
                            GetSavedInstanceEncounterInfo(i, ii)
                        encounterInfo[ii] = {
                            bossName = bossName,
                            isKilled = isKilled,
                            bossIndex = ii,
                        }
                    end
                    tinsert(WclBoxCharacter.instanceCD, {
                        name = name,
                        instanceID = instanceID,
                        lockoutID = lockoutID,
                        resettime = resettime,
                        endtime = resettime + time,
                        difficultyID = difficultyID,
                        difficultyName = difficultyName,
                        isRaid = isRaid,
                        maxPlayers = maxPlayers,
                        numEncounters = numEncounters,
                        encounterInfo = encounterInfo,
                    })
                end
            end
        end

        RequestRaidInfo()
        After(3, function()
            NB.SaveInstanceCD()
        end)

        RegisterEvent("ENCOUNTER_END", function(self, event, bossID, _, _, _, success)
            if event == "ENCOUNTER_END" and success == 1 then
                After(.5, function()
                    RequestRaidInfo()
                end)
            end
        end)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ENCOUNTER_END")
        f:RegisterEvent("UPDATE_INSTANCE_INFO")
        f:SetScript("OnEvent", function(self, event, bossID, _, _, _, success)
            if (event == "ENCOUNTER_END") or (event == "ENCOUNTER_END" and success == 1) then
                After(1, function()
                    NB.SaveInstanceCD()
                end)
            end
        end)
    end

    -- 声望
    do
        WclBoxCharacter.reputation = WclBoxCharacter.reputation or {}

        local ExpandAllFactionHeaders = ExpandAllFactionHeaders or C_Reputation.ExpandAllFactionHeaders
        local GetNumFactions = GetNumFactions or C_Reputation.GetNumFactions
        local GetFactionInfo = GetFactionInfo or C_Reputation.GetFactionDataByIndex

        local yes = true
        function NB.SaveReputation()
            if ReputationFrame and ReputationFrame:IsVisible() then return end
            local header1, header2
            ExpandAllFactionHeaders()
            yes = false
            After(60, function()
                yes = true
            end)
            for i = 1, GetNumFactions() do
                if NB.IsRetail then
                    -- local info = GetFactionInfo(i)
                    -- if info.isHeader then
                    --     if info.isChild then
                    --         header2 = info.name
                    --     else
                    --         header1 = info.name
                    --         header2 = nil
                    --     end
                    -- else
                    --     local factionID = info.factionID
                    --     local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID)
                    --     local standing, currentValue, maxValue
                    --     if friendshipData.maxRep == 0 then
                    --         standing = _G["FACTION_STANDING_LABEL" .. info.reaction]
                    --         currentValue = info.currentStanding - info.currentReactionThreshold
                    --         maxValue = info.nextReactionThreshold - info.currentReactionThreshold
                    --     else
                    --         standing = friendshipData.reaction
                    --         currentValue = friendshipData.standing - friendshipData.reactionThreshold
                    --         maxValue = friendshipData.nextThreshold - friendshipData.reactionThreshold
                    --     end
                    --     WclBoxCharacter.reputation[factionID] = {
                    --         name = info.name,
                    --         description = info.description,
                    --         standing = standing,
                    --         currentValue = currentValue,
                    --         maxValue = maxValue,
                    --         atWarWith = info.atWarWith,
                    --         header1 = header1,
                    --         header2 = header2,
                    --         factionID = factionID,
                    --     }
                    -- end
                else
                    local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar,
                    isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus
                    = GetFactionInfo(i)
                    if isHeader then
                        if isChild then
                            header2 = name
                        else
                            header1 = name
                            header2 = nil
                        end
                    else
                        local standing = _G["FACTION_STANDING_LABEL" .. standingID]
                        WclBoxCharacter.reputation[factionID] = {
                            name = name,
                            description = description,
                            standing = standing,
                            currentValue = barValue - barMin,
                            maxValue = barMax - barMin,
                            atWarWith = atWarWith,
                            header1 = header1,
                            header2 = header2,
                            factionID = factionID,
                        }
                    end
                end
            end
        end

        After(10, function()
            NB.SaveReputation()
        end)
        RegisterEvent("UPDATE_FACTION", function(self, event)
            if yes then
                After(.5, function()
                    NB.SaveReputation()
                end)
            end
        end)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Init()
    end
end)

--[[
RegisterEvent("", function(self, event,... )

end)

]]

--[[
/run LoadAddOn("Blizzard_AchievementUI") if AchievementFrame:IsVisible() then HideUIPanel(AchievementFrame) else ShowUIPanel(AchievementFrame) end
]]
