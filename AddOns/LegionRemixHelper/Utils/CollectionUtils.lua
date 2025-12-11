---@class AddonPrivate
local Private = select(2, ...)

---@class CollectionUtils
local collectionUtils = {
    cache = {},
    vendorCache = nil,
    isUpdated = false,
    priceIconCache = nil,
    ---@type table<any, string>
    L = nil,
}
Private.CollectionUtils = collectionUtils

local const = Private.constants

---@class RawCollectionReward
---@field REWARD_ID number
---@field REWARD_TYPE Enum.RHE_CollectionRewardType
---@field SOURCE_ID number
---@field SOURCE_TYPE Enum.RHE_CollectionSourceType
---@field PRICES? { TYPE: Enum.RHE_CollectionPriceType, AMOUNT: number }[]
---@field ILLUSION_ID number|nil
---@field UNIQUE_TO_REMIX boolean|nil

---@class CombinedCollectionReward
---@field REWARD_ID number
---@field REWARD_TYPE Enum.RHE_CollectionRewardType
---@field SOURCES { SOURCE_ID: number, SOURCE_TYPE: Enum.RHE_CollectionSourceType }[]
---@field PRICES? { TYPE: Enum.RHE_CollectionPriceType, AMOUNT: number }[]
---@field ILLUSION_ID number|nil
---@field UNIQUE_TO_REMIX boolean|nil

---@class NPCInfo
---@field ID number
---@field NAME string
---@field LOCATION { MAP_ID: number, X: number, Y: number }

---@class CollectionRewardObject : CollectionRewardMixin

---@class CollectionRewardMixin
---@field collected boolean
---@field collectionCheckFunction (fun():isCollected:boolean)|nil
---@field icon string|number|nil
---@field tooltip string
---@field name string
---@field itemID number|nil
---@field isIllusion number|nil
---@field rewardType Enum.RHE_CollectionRewardType|nil
---@field sourceTypes Enum.RHE_CollectionSourceType[]
---@field vendorInfo NPCInfo|nil
---@field achievementID number|nil
---@field bronzePrice number
---@field isRaidVariant boolean
---@field isUnique boolean
local collectionRewardMixin = {
    collectionCheckFunction = nil,
    collected = false,
    icon = nil,
    tooltip = "",
    name = "",
    itemID = nil,
    isIllusion = nil,
    rewardType = nil,
    sourceTypes = nil,
    vendorLocation = nil,
    vendorInfo = nil,
    achievementID = nil,
    bronzePrice = 0,
    isRaidVariant = false,
    isUnique = false,
}

---@return boolean isCollected
function collectionRewardMixin:IsCollected()
    return self.collected and true or false
end

---@param isCollected boolean
function collectionRewardMixin:SetCollected(isCollected)
    self.collected = isCollected
end

function collectionRewardMixin:CheckCollected()
    if self.collectionCheckFunction then
        self.collected = self.collectionCheckFunction()
        return self.collected
    end
end

---@param func fun():isCollected:boolean
function collectionRewardMixin:SetCollectionCheckFunction(func)
    self.collectionCheckFunction = func
end

function collectionRewardMixin:Preview()
    if self:GetIllusion() then
        collectionUtils:PreviewByItemID(self:GetIllusion(), true)
        return
    end
    if self.itemID then
        collectionUtils:PreviewByItemID(self.itemID)
    end
end

function collectionRewardMixin:Link()
    if self.itemID then
        collectionUtils:LinkByItemID(self.itemID)
    end
end

function collectionRewardMixin:SetVendorWaypoint()
    if not self.vendorInfo then return end
    local loc = self.vendorInfo.LOCATION
    if not loc then return end
    if TomTom then
        TomTom:AddWaypoint(loc.MAP_ID, loc.X / 100, loc.Y / 100, {
            title = self.vendorInfo.NAME,
            from = Private.Addon.DisplayName,
        })
        return
    else
        local mapPoint = UiMapPoint.CreateFromVector2D(loc.MAP_ID, CreateVector2D(loc.X / 100, loc.Y / 100))
        C_Map.SetUserWaypoint(mapPoint)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK_ON)
    end
end

function collectionRewardMixin:ShowAchievement()
    if not self.achievementID then return end
    if not AchievementFrame then
        AchievementFrame_LoadUI()
    end
    ShowUIPanel(AchievementFrame)
    AchievementFrame_SelectAchievement(self.achievementID)
end

function collectionRewardMixin:SetAchievementId(achievementID)
    self.achievementID = achievementID
end

---@param vendorInfo NPCInfo
function collectionRewardMixin:SetVendorInfo(vendorInfo)
    self.vendorInfo = vendorInfo
end

---@return string|number|nil icon
function collectionRewardMixin:GetIcon()
    return self.icon
end

---@param icon string|number|nil
function collectionRewardMixin:SetIcon(icon)
    self.icon = icon
end

---@return string tooltipText
function collectionRewardMixin:GetSourceTooltip()
    return self.tooltip
end

---@param tooltipText string
function collectionRewardMixin:SetSourceTooltip(tooltipText)
    self.tooltip = tooltipText
end

---@return string name
function collectionRewardMixin:GetName()
    return self.name
end

---@param name string
function collectionRewardMixin:SetName(name)
    self.name = name
end

---@return number itemID
function collectionRewardMixin:GetItemID()
    return self.itemID
end

---@param itemID number
function collectionRewardMixin:SetItemID(itemID)
    self.itemID = itemID
end

---@param illusionID number
function collectionRewardMixin:SetIllusion(illusionID)
    self.illusionID = illusionID
end

---@return number|nil
function collectionRewardMixin:GetIllusion()
    return self.illusionID
end

---@param rewardType Enum.RHE_CollectionRewardType
function collectionRewardMixin:SetRewardType(rewardType)
    self.rewardType = rewardType
end

---@return Enum.RHE_CollectionRewardType
function collectionRewardMixin:GetRewardType()
    return self.rewardType
end

---@param sourceType Enum.RHE_CollectionSourceType
function collectionRewardMixin:AddSourceType(sourceType)
    local sources = self.sourceTypes or {}
    table.insert(sources, sourceType)
    self.sourceTypes = sources
end

---@return Enum.RHE_CollectionSourceType[]
function collectionRewardMixin:GetSourceTypes()
    return self.sourceTypes
end

---@param sourceType Enum.RHE_CollectionSourceType
---@return boolean
function collectionRewardMixin:HasSourceType(sourceType)
    if not self.sourceTypes then return false end
    for _, st in ipairs(self.sourceTypes) do
        if st == sourceType then
            return true
        end
    end
    return false
end

---@param price number
function collectionRewardMixin:SetBronzePrice(price)
    self.bronzePrice = price
end

---@return number price
function collectionRewardMixin:GetBronzePrice()
    return self.bronzePrice
end

---@param isUnique boolean
function collectionRewardMixin:SetUniqueToRemix(isUnique)
    self.isUnique = isUnique
end

---@return boolean isUnique
function collectionRewardMixin:IsUniqueToRemix()
    return self.isUnique
end

---@param isRaidVariant boolean
function collectionRewardMixin:SetRaidVariant(isRaidVariant)
    self.isRaidVariant = isRaidVariant
end

---@return boolean isRaidVariant
function collectionRewardMixin:IsRaidVariant()
    return self.isRaidVariant
end

function collectionUtils:Init()
    self.L = Private.L
    self:CachePriceIcons()
    self:LoadRewardInfos()

    local addon = Private.Addon

    addon:RegisterEvent("NEW_MOUNT_ADDED", "CollectionUtils_MountAdded", function()
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.MOUNT)
    end)

    addon:RegisterEvent("NEW_TOY_ADDED", "CollectionUtils_ToyAdded", function()
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.TOY)
    end)

    addon:RegisterEvent("NEW_PET_ADDED", "CollectionUtils_PetAdded", function()
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.PET)
    end)

    addon:RegisterEvent("KNOWN_TITLES_UPDATE", "CollectionUtils_TitleUpdate", function()
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.TITLE)
    end)

    addon:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", "CollectionUtils_TransmogAdded", function()
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.APPEARANCE)
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.ILLUSION)
        self:RefreshCollectionByType(const.COLLECTIONS.ENUM.REWARD_TYPE.SET)
    end)
end

---@param reward CombinedCollectionReward
---@param name string
---@param icon string|number
---@param sourceTooltip string
---@param isCollected boolean
---@param bronzeCost number
---@param collectionCheckFunction fun():isCollected:boolean)
---@param itemID number|nil
---@param illusionID number|nil
---@return CollectionRewardObject
function collectionUtils:CreateCollectionObject(reward, name, icon, sourceTooltip, isCollected, bronzeCost,
                                                collectionCheckFunction,
                                                itemID, illusionID)
    local obj = setmetatable({}, { __index = collectionRewardMixin })

    obj:SetName(name)
    obj:SetIcon(icon)
    obj:SetSourceTooltip(sourceTooltip)
    obj:SetCollected(isCollected)
    obj:SetBronzePrice(bronzeCost)
    obj:SetCollectionCheckFunction(collectionCheckFunction)
    obj:SetItemID(itemID)
    obj:SetIllusion(illusionID)
    obj:SetUniqueToRemix(reward.UNIQUE_TO_REMIX == true)
    obj:SetRewardType(reward.REWARD_TYPE)
    for _, source in ipairs(reward.SOURCES) do
        obj:AddSourceType(source.SOURCE_TYPE)
        if source.SOURCE_TYPE == const.COLLECTIONS.ENUM.SOURCE_TYPE.VENDOR then
            obj:SetVendorInfo(collectionUtils:GetVendorByID(source.SOURCE_ID))
            obj:SetRaidVariant(collectionUtils:IsRemovedRaidVendor(source.SOURCE_ID) == true)
        elseif source.SOURCE_TYPE == const.COLLECTIONS.ENUM.SOURCE_TYPE.ACHIEVEMENT then
            obj:SetAchievementId(source.SOURCE_ID)
        end
    end

    return obj
end

---@param titleID number
---@return fun():isCollected:boolean
function collectionUtils:GetTitleCollectionFunction(titleID)
    return function()
        return IsTitleKnown(titleID)
    end
end

---@param setID number
---@return fun():isCollected:boolean
function collectionUtils:GetSetCollectionFunction(setID)
    return function()
        local setInfo = C_TransmogSets.GetSetInfo(setID)
        if setInfo and not setInfo.collected then
            local setItems = C_Transmog.GetAllSetAppearancesByID(setID)
            for _, item in ipairs(setItems) do
                if not C_TransmogCollection.PlayerHasTransmogByItemInfo(item.itemID) then
                    return false
                end
            end
            return true
        end
        return setInfo and setInfo.collected or false
    end
end

---@param mountID number
---@return fun():isCollected:boolean
function collectionUtils:GetMountCollectionFunction(mountID, itemID)
    return function()
        if not mountID then
            local druidFormQuest = const.COLLECTIONS.DRUID_FORM_BY_ID[itemID]
            if druidFormQuest then
                return C_QuestLog.IsQuestFlaggedCompleted(druidFormQuest)
            end
            return false
        end
        local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
        if mountInfo then
            return mountInfo[11] and true or false
        end
        return false
    end
end

---@param speciesID number
---@param checkAtLimit boolean?
---@return fun():isCollected:boolean
function collectionUtils:GetPetCollectionFunction(speciesID, checkAtLimit)
    return function()
        local collected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        return (checkAtLimit and collected >= limit) or (not checkAtLimit and collected > 0)
    end
end

---@param illusionID number
---@return fun():isCollected:boolean
function collectionUtils:GetIllusionCollectionFunction(illusionID)
    return function()
        local illusionInfo = C_TransmogCollection.GetIllusionInfo(illusionID)
        return illusionInfo and illusionInfo.isCollected and true or false
    end
end

---@param itemID number
---@return fun():isCollected:boolean
function collectionUtils:GetAppearanceCollectionFunction(itemID)
    return function()
        local hasTransmog = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
        return hasTransmog and true or false
    end
end

---@param itemID number
---@return fun():isCollected:boolean
function collectionUtils:GetToyCollectionFunction(itemID)
    return function()
        local hasToy = PlayerHasToy(itemID)
        return hasToy and true or false
    end
end

---@param collectionObject CollectionRewardObject
---@param rewardType Enum.RHE_CollectionRewardType
function collectionUtils:AddToCache(collectionObject, rewardType)
    if not self.cache[rewardType] then
        self.cache[rewardType] = {}
    end
    table.insert(self.cache[rewardType], collectionObject)
end

function collectionUtils:CacheReverseVendorLookup()
    self.vendorCache = self.vendorCache or {}
    local npcs = const.NPC
    for _, npc in pairs(npcs) do
        self.vendorCache[npc.ID] = npc
    end
end

---@param npcID number
---@return NPCInfo|nil npcInfo
function collectionUtils:GetVendorByID(npcID)
    if not self.vendorCache then
        self:CacheReverseVendorLookup()
    end

    return self.vendorCache[npcID]
end

---@param npcID number
---@return boolean|nil isRemovedVendor
function collectionUtils:IsRemovedRaidVendor(npcID)
    if npcID == const.NPC.LFR_APPAREL.ID or
        npcID == const.NPC.NORMAL_APPAREL.ID or
        npcID == const.NPC.HEROIC_APPAREL.ID
    then
        return true
    end
end

function collectionUtils:CachePriceIcons()
    self.priceIconCache = self.priceIconCache or {}
    for priceType, priceInfo in ipairs(const.COLLECTIONS.PRICE_INFO) do
        if priceInfo.CURRENCY_ID then
            local icon = C_CurrencyInfo.GetCurrencyInfo(priceInfo.CURRENCY_ID).iconFileID
            self.priceIconCache[priceType] = icon
        elseif priceInfo.ITEM_ID then
            local item = Item:CreateFromItemID(priceInfo.ITEM_ID)
            item:ContinueOnItemLoad(function()
                local icon = item:GetItemIcon()
                self.priceIconCache[priceType] = icon
            end)
        end
    end
end

---@param reward CombinedCollectionReward
---@return string sourceTooltip
function collectionUtils:GetSourceTooltip(reward)
    local tooltip = const.COLORS.YELLOW:WrapTextInColorCode(self.L["CollectionUtils.Sources"])

    for _, source in ipairs(reward.SOURCES) do
        if source.SOURCE_TYPE == const.COLLECTIONS.ENUM.SOURCE_TYPE.ACHIEVEMENT then
            local name = select(2, GetAchievementInfo(source.SOURCE_ID))
            name = name or self.L["CollectionUtils.UnknownAchievement"]
            tooltip = ("%s\n%s%s\n"):format(tooltip,
                const.COLORS.YELLOW:WrapTextInColorCode(self.L["CollectionUtils.Achievement"]), name)
        elseif source.SOURCE_TYPE == const.COLLECTIONS.ENUM.SOURCE_TYPE.VENDOR then
            local vendorInfo = self:GetVendorByID(source.SOURCE_ID)
            local name = vendorInfo and vendorInfo.NAME or self.L["CollectionUtils.UnknownVendor"]

            local prices = ""
            for _, priceInfo in ipairs(reward.PRICES) do
                local icon = self.priceIconCache[priceInfo.TYPE]
                icon = icon or 134400
                prices = ("%s|T%s:12|t %d\n"):format(prices, icon, priceInfo.AMOUNT)
            end
            tooltip = ("%s\n%s%s:\n%s"):format(tooltip,
                const.COLORS.YELLOW:WrapTextInColorCode(self.L["CollectionUtils.Vendor"]), name, prices)
        end
    end

    return tooltip
end

---@param reward CombinedCollectionReward
---@return number bronzeCost
function collectionUtils:GetBronzeCost(reward)
    local bronzePrice = 0
    if reward.PRICES then
        for _, priceInfo in ipairs(reward.PRICES) do
            if priceInfo.TYPE == const.COLLECTIONS.ENUM.PRICE_TYPE.BRONZE then
                bronzePrice = priceInfo.AMOUNT
                break
            end
        end
    end
    return bronzePrice
end

---@param reward CombinedCollectionReward
function collectionUtils:LoadReward(reward)
    if not reward or not reward.REWARD_ID then return end
    local rewardType = reward.REWARD_TYPE
    local rtEnum = const.COLLECTIONS.ENUM.REWARD_TYPE
    local tooltip = self:GetSourceTooltip(reward)
    local bronzePrice = self:GetBronzeCost(reward)

    if rewardType == rtEnum.TITLE then
        local titleID = reward.REWARD_ID
        local name = GetTitleName(titleID)
        if name and name ~= "" then
            local icon = 134939
            tooltip = name
            local collectionFunc = self:GetTitleCollectionFunction(titleID)

            local titleObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc)
            self:AddToCache(titleObj, rewardType)
        end
    elseif rewardType == rtEnum.SET then
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local setID = C_Item.GetItemLearnTransmogSet(itemID)
            local collectionFunc = self:GetSetCollectionFunction(setID)

            local setObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc,
                itemID)
            self:AddToCache(setObj, rewardType)
        end)
    elseif rewardType == rtEnum.PET then
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
            local collectionFunc = self:GetPetCollectionFunction(speciesID)

            local petObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc,
                itemID)
            self:AddToCache(petObj, rewardType)
        end)
    elseif rewardType == rtEnum.ILLUSION then
        local illusionID = reward.ILLUSION_ID
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local collectionFunc = self:GetIllusionCollectionFunction(illusionID)

            local illusionObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc,
                itemID, illusionID)
            self:AddToCache(illusionObj, rewardType)
        end)
    elseif rewardType == rtEnum.APPEARANCE then
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local collectionFunc = self:GetAppearanceCollectionFunction(itemID)

            local appearanceObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc, itemID)
            self:AddToCache(appearanceObj, rewardType)
        end)
    elseif rewardType == rtEnum.MOUNT then
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            local collectionFunc = self:GetMountCollectionFunction(mountID, itemID)

            local mountObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc,
                itemID)
            self:AddToCache(mountObj, rewardType)
        end)
    elseif rewardType == rtEnum.TOY then
        local itemID = reward.REWARD_ID
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local icon = item:GetItemIcon()
            local name = item:GetItemName()
            local collectionFunc = self:GetToyCollectionFunction(itemID)

            local toyObj = self:CreateCollectionObject(reward, name, icon, tooltip, collectionFunc(), bronzePrice,
                collectionFunc,
                itemID)
            self:AddToCache(toyObj, rewardType)
        end)
    end
end

function collectionUtils:LoadRewardInfos()
    local rewards = const.COLLECTIONS.REWARDS

    local combinedRewards = {}
    for _, reward in ipairs(rewards) do
        local key = reward.REWARD_TYPE .. "_" .. reward.REWARD_ID
        if not combinedRewards[key] then
            combinedRewards[key] = {
                REWARD_ID = reward.REWARD_ID,
                REWARD_TYPE = reward.REWARD_TYPE,
                SOURCES = {},
                PRICES = reward.PRICES,
                ILLUSION_ID = reward.ILLUSION_ID,
                UNIQUE_TO_REMIX = reward.UNIQUE_TO_REMIX
            }
        end
        if not combinedRewards[key].PRICES and reward.PRICES then
            combinedRewards[key].PRICES = reward.PRICES
        end
        tinsert(combinedRewards[key].SOURCES, { SOURCE_ID = reward.SOURCE_ID, SOURCE_TYPE = reward.SOURCE_TYPE })
    end

    for _, reward in pairs(combinedRewards) do
        self:LoadReward(reward)
    end
end

---Supports: Sets, Mounts, Pets and Appearances
---@param itemID any
---@param isIllusion boolean|nil
function collectionUtils:PreviewByItemID(itemID, isIllusion)
    if isIllusion then
        local link = select(2, C_TransmogCollection.GetIllusionStrings(itemID))
        DressUpVisualLink(nil, link)
        return
    end
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        DressUpLink(item:GetItemLink())
    end)
end

---@param itemID number
function collectionUtils:LinkByItemID(itemID)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local link = item:GetItemLink()
        if (ChatEdit_InsertLink(link)) then
            return true
        elseif (SocialPostFrame and Social_IsShown()) then
            Social_InsertLink(link)
            return true
        end
    end)
end

---@param rewardType Enum.RHE_CollectionRewardType
function collectionUtils:RefreshCollectionByType(rewardType)
    local hasNewCollections = false
    if not self.cache[rewardType] then return end

    for _, obj in ipairs(self.cache[rewardType]) do
        ---@cast obj CollectionRewardObject
        local status = obj:IsCollected()
        if not status then
            local newCollectionStatus = obj:CheckCollected()
            if newCollectionStatus ~= status then
                hasNewCollections = true
            end
        end
    end

    if hasNewCollections then
        self.isUpdated = false
    end
end

---@return CollectionRewardObject[]|nil scrollData
function collectionUtils:GetCollectionData()
    if self.isUpdated then return end
    self.isUpdated = true

    local items = {}
    for rewardType, rewards in pairs(self.cache) do
        self:RefreshCollectionByType(rewardType)
        for _, reward in ipairs(rewards) do
            ---@cast reward CollectionRewardObject
            tinsert(items, reward)
        end
    end

    sort(items, function(a, b)
        return a:GetName() < b:GetName()
    end)

    return items
end

---@param data CollectionRewardObject[]
---@return number spent, number total
function collectionUtils:GetCollectionBronzeCost(data)
    local spent, total = 0, 0
    for _, reward in ipairs(data) do
        local price = reward:GetBronzePrice() or 0
        total = total + price
        if reward:IsCollected() then
            spent = spent + price
        end
    end
    return spent, total
end
