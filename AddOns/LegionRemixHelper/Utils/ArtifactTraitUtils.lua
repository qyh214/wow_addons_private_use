---@class AddonPrivate
local Private = select(2, ...)

---@class ArtifactTraitUtils
---@field callbackUtils CallbackUtils
---@field baseTraits number[]
---@field rowTraits table<number, number[]>
---@field configCache number|nil
---@field specsCache number[]
---@field addon LegionRH
local artifactTraitUtils = {
    callbackUtils = nil,
    baseTraits = nil,
    rowTraits = {},
    configCache = nil,
    specsCache = {},
    addon = nil,
    ---@type table<any, string>
    L = nil,
}
Private.ArtifactTraitUtils = artifactTraitUtils

local const = Private.constants

function artifactTraitUtils:Init()
    self.L = Private.L
    self.callbackUtils = Private.CallbackUtils
    local addon = Private.Addon
    self.addon = addon
    addon:RegisterEvent("TRAIT_CONFIG_UPDATED", "artifactTraitUtils_TRAIT_CONFIG_UPDATED", function()
        local newConfigID = self:GetConfigID()
        if not newConfigID or self.configCache == newConfigID then return end
        self.configCache = newConfigID
        self:OnConfigUpdate()
    end)
    addon:RegisterEvent("WEAPON_SLOT_CHANGED", "artifactTraitUtils_WEAPON_SLOT_CHANGED", function()
        local newConfigID = self:GetConfigID()
        if not newConfigID or self.configCache == newConfigID then return end
        self.configCache = newConfigID
        self:OnWeaponUpdate()
    end)
    addon:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED", "artifactTraitUtils_TRAIT_TREE_CURRENCY_INFO_UPDATED",
        function(_, _, treeID)
            if treeID == const.REMIX_ARTIFACT_TRAITS.TREE_ID then
                self:OnPowerUpdate()
            end
        end)
    addon:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "artifactTraitUtils_CURRENCY_DISPLAY_UPDATE",
        function(_, _, currencyID)
            if not currencyID then return end
            if currencyID ~= const.REMIX_ARTIFACT_TRAITS.CURRENCY_ID then return end
            self:TryNextAutoBuy()
        end)
    addon:RegisterEvent("PLAYER_ENTERING_WORLD", "artifactTraitUtils_PLAYER_ENTERING_WORLD", function()
        self:BuildTraitTrees()
        self:UpdateSpecs()
    end)
    addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "artifactTraitUtils_PLAYER_EQUIPMENT_CHANGED", function()
        self:OnEquipmentUpdate()
    end)
end

function artifactTraitUtils:TryNextAutoBuy()
    if not self.addon:GetDatabaseValue("artifactTraits.autoBuy", true) then return end
    local nextNode = self:GetNextPurchaseNode()
    if not nextNode then return end
    if self:PurchasePossibleRanks(const.REMIX_ARTIFACT_TRAITS.TREE_ID, nextNode) then return end
    if not C_Traits.CommitConfig(self:GetConfigID()) then return end
    local spellId = self:GetSpellIDFromNodeID(nextNode)
    if not spellId then return end
    local spell = Spell:CreateFromSpellID(spellId)
    if not spell then return end
    spell:ContinueOnSpellLoad(function()
        Private.ToastUtils:ShowTraitToast(spell:GetSpellName(), C_Spell.GetSpellTexture(spellId))
    end)
end

---@param configID number
---@param availableNodes number[]
---@return number|nil cheapestNodeID
---@return number|nil cheapestNodeIndex
function artifactTraitUtils:GetCheapestNode(configID, availableNodes)
    local cheapestCost, cheapestNodeID, cheapestNodeIndex = math.huge, nil, nil

    for nodeIndex, nodeID in ipairs(availableNodes) do
        local cost = C_Traits.GetNodeCost(configID, nodeID)
        if not cost or #cost <= 0 then cost = { { amount = 0, ID = 4039 } } end
        local costNum = cost[1].amount
        if costNum < cheapestCost then
            cheapestCost = costNum
            cheapestNodeIndex = nodeIndex
            cheapestNodeID = nodeID
        end
    end

    return cheapestNodeID, cheapestNodeIndex
end

---@param treeID number
---@param stopAtNodes table<number, boolean>|nil
---@param overwriteRootNode number|nil
---@return number[]|nil pathNodeIDs
function artifactTraitUtils:BuildBuyPath(treeID, stopAtNodes, overwriteRootNode)
    local configID = C_Traits.GetConfigIDByTreeID(treeID)
    if not configID then return end
    local treeInfo = C_Traits.GetTreeInfo(configID, treeID)
    if not treeInfo then return end
    ---@diagnostic disable-next-line: undefined-field
    local rootNodeID = treeInfo.rootNodeID
    if overwriteRootNode then rootNodeID = overwriteRootNode end
    stopAtNodes = stopAtNodes or {}

    local availableNodes = { rootNodeID }
    local pathNodes = {}
    local allNodes = { [rootNodeID] = true }

    while #availableNodes > 0 do
        local nextNodeID, nextNodeIndex = self:GetCheapestNode(configID, availableNodes)
        if not nextNodeID then break end

        tinsert(pathNodes, nextNodeID)
        tremove(availableNodes, nextNodeIndex)
        allNodes[nextNodeID] = true

        local nodeInfo = C_Traits.GetNodeInfo(configID, nextNodeID)
        if not nodeInfo then break end

        for _, edgeInfo in ipairs(nodeInfo.visibleEdges) do
            local targetNodeID = edgeInfo.targetNode
            if not allNodes[targetNodeID] and not stopAtNodes[targetNodeID] then
                tinsert(availableNodes, targetNodeID)
                allNodes[targetNodeID] = true
            end
        end
    end

    return pathNodes
end

---@return boolean[] rowRootNodes
function artifactTraitUtils:GetRowRootNodes()
    local rowRootNodes = {}
    for _, row in pairs(const.REMIX_ARTIFACT_TRAITS.ROWS) do
        rowRootNodes[row.ROOT_NODE_ID] = true
    end
    return rowRootNodes
end

---@return number[] indexedRowRootNodes
function artifactTraitUtils:GetIndexedRowRootNodes()
    local indexedRowRootNodes = {}
    for _, row in pairs(const.REMIX_ARTIFACT_TRAITS.ROWS) do
        indexedRowRootNodes[row.ID] = row.ROOT_NODE_ID
    end
    return indexedRowRootNodes
end

function artifactTraitUtils:BuildTraitTrees()
    self.baseTraits = self:BuildBuyPath(const.REMIX_ARTIFACT_TRAITS.TREE_ID, self:GetRowRootNodes())
    for _, row in pairs(const.REMIX_ARTIFACT_TRAITS.ROWS) do
        local rowPath = self:BuildBuyPath(const.REMIX_ARTIFACT_TRAITS.TREE_ID, nil, row.ROOT_NODE_ID)
        self.rowTraits[row.ID] = rowPath
    end
end

---@return table<number, number[]> rowTraits
function artifactTraitUtils:GetRowTraits()
    if not self.rowTraits then
        self:BuildTraitTrees()
        if not self.rowTraits then return {} end
    end
    return CopyTable(self.rowTraits)
end

function artifactTraitUtils:GetRowTraitsForRow(rowID)
    return CopyTable(self:GetRowTraits()[rowID])
end

---@param treeID number|nil
---@return number configID
function artifactTraitUtils:GetConfigID(treeID)
    return C_Traits.GetConfigIDByTreeID(treeID or const.REMIX_ARTIFACT_TRAITS.TREE_ID)
end

---@param itemID number
---@return boolean
function artifactTraitUtils:IsJewelryItem(itemID)
    return const.REMIX_ARTIFACT_TRAITS.JEWELRY_ITEMS[itemID] and true or false
end

---@class JewelryItemInfo
---@field quality number
---@field level number
---@field location ItemLocation
---@field invType Enum.InventoryType

---@return table<number, JewelryItemInfo> highestItems
function artifactTraitUtils:GetHighestJewelryItems()
    local highestItems = {}
    for bagID = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemLoc = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
            if itemLoc:IsValid() then
                local itemID = C_Item.GetItemID(itemLoc)
                if itemID and self:IsJewelryItem(itemID) then
                    local quality = C_Item.GetItemQuality(itemLoc)
                    local ilevel = C_Item.GetCurrentItemLevel(itemLoc)
                    if
                        not highestItems[itemID] or
                        (highestItems[itemID].quality < quality) or
                        (highestItems[itemID].quality == quality and highestItems[itemID].level < ilevel)
                    then
                        highestItems[itemID] = {
                            quality = quality,
                            level = ilevel,
                            location = itemLoc,
                            invType = C_Item.GetItemInventoryType(itemLoc),
                        }
                    end
                end
            end
        end
    end
    return highestItems
end

---@param entryID number
---@param configID number?
---@return number? spellID
function artifactTraitUtils:GetSpellIDFromEntryID(entryID, configID)
    if not configID then configID = self:GetConfigID() end
    local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
    if not entryInfo or not entryInfo.definitionID then return end
    local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
    return definitionInfo.overriddenSpellID or definitionInfo.spellID
end

---@param nodeID number
---@param configID number?
---@return number? spellID
function artifactTraitUtils:GetSpellIDFromNodeID(nodeID, configID)
    if not configID then configID = self:GetConfigID() end
    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
    if not nodeInfo or not nodeInfo.entryIDs or #nodeInfo.entryIDs == 0 then return end
    return self:GetSpellIDFromEntryID(nodeInfo.entryIDs[1], configID)
end

---@param itemID number
---@return number?
function artifactTraitUtils:GetJewelrySpellID(itemID)
    local entryID = self:GetEntryIDFromItemID(itemID)
    if not entryID then return end
    return self:GetSpellIDFromEntryID(entryID)
end

---@param itemLocation ItemLocation
---@return string tooltip
function artifactTraitUtils:GetJewelryTooltip(itemLocation)
    if not itemLocation or not itemLocation:IsValid() then return self.L["ArtifactTraitUtils.NoItemEquipped"] end
    local itemID = C_Item.GetItemID(itemLocation)
    local entryID = self:GetEntryIDFromItemID(itemID)
    local spellName, spellIcon, traitUpgrade = self.L["ArtifactTraitUtils.UnknownTrait"], 134400, 0
    if entryID then
        local spellID = self:GetSpellIDFromEntryID(entryID)
        if spellID then
            spellName = C_Spell.GetSpellName(spellID)
            spellIcon = C_Spell.GetSpellTexture(spellID)

            local itemQuality = C_Item.GetItemQuality(itemLocation)
            traitUpgrade = const.REMIX_ARTIFACT_TRAITS.JEWELRY_QUALITY_UPGRADES[itemQuality] or 0
        end
    end
    return self.L["ArtifactTraitUtils.JewelryFormat"]:format(spellIcon, spellName, traitUpgrade)
end

---@param itemID number
---@return number? entryID
function artifactTraitUtils:GetEntryIDFromItemID(itemID)
    return const.REMIX_ARTIFACT_TRAITS.JEWELRY_ITEMS[itemID]
end

---@return table
function artifactTraitUtils:GetJewelrySlots()
    return const.REMIX_ARTIFACT_TRAITS.JEWELRY_SLOTS
end

---@param invSlot number
---@return ItemLocationMixin? equippedItemLocation
function artifactTraitUtils:GetEquippedJewelryBySlot(invSlot)
    local itemLoc = ItemLocation:CreateFromEquipmentSlot(invSlot)
    if itemLoc:IsValid() then
        return itemLoc
    end
end

---@param itemLocation ItemLocation
---@param invSlot number
function artifactTraitUtils:EquipJewelryForSlot(itemLocation, invSlot)
    if not itemLocation or not itemLocation:IsValid() then return end
    local bag, slot = itemLocation:GetBagAndSlot()

    EquipmentManager_EquipContainerItem({
        bag = bag,
        slot = slot,
        invSlot = invSlot,
    })
end

---@param slot Enum.InventoryType
---@return JewelryItemInfo[] slotItems
function artifactTraitUtils:GetJewelryBySlot(slot)
    local items = self:GetHighestJewelryItems()
    local slotItems = {}
    for _, itemInfo in pairs(items) do
        if itemInfo.invType == slot then
            tinsert(slotItems, itemInfo)
        end
    end
    return slotItems
end

---@return table<number, string> rowNames
function artifactTraitUtils:GetRowNames()
    local rowNames = {}
    for _, row in pairs(const.REMIX_ARTIFACT_TRAITS.ROWS) do
        rowNames[row.ID] = self.L[row.NAME_KEY] or row.NAME_KEY
    end
    return rowNames
end

---@param callbackFunction fun(update: table)
---@return CallbackObject|nil callbackObject
function artifactTraitUtils:AddCallback(category, callbackFunction)
    return self.callbackUtils:AddCallback(category, callbackFunction)
end

---@param callbackObj CallbackObject
function artifactTraitUtils:RemoveCallback(callbackObj)
    self.callbackUtils:RemoveCallback(callbackObj)
end

function artifactTraitUtils:TriggerCallbacks(category)
    local callbacks = self.callbackUtils:GetCallbacks(category)
    local update = {}
    for _, callback in ipairs(callbacks) do
        callback:Trigger(update)
    end
end

function artifactTraitUtils:OnConfigUpdate()
    self:TriggerCallbacks(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_CONFIG)
end

function artifactTraitUtils:OnWeaponUpdate()
    local newRow = self:GetPlayerRow()
    if newRow then
        self:SwitchRowTraits(newRow)
    end

    self:TriggerCallbacks(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_SPEC)
end

function artifactTraitUtils:OnPowerUpdate()
    self:TriggerCallbacks(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_CURRENCY)
    if not self.baseTraits then
        self:BuildTraitTrees()
    end
end

---@return number[] specIDs
function artifactTraitUtils:GetSpecs()
    local specs = self.specsCache
    if not specs then
        self:UpdateSpecs()
        specs = self.specsCache
    end
    return specs
end

---@return number? specID
function artifactTraitUtils:GetSpecID()
    return PlayerUtil.GetCurrentSpecID()
end

---@return number? classID
function artifactTraitUtils:GetClassID()
    return PlayerUtil.GetClassID()
end

function artifactTraitUtils:UpdateSpecs()
    self.specsCache = {}
    for i = 1, GetNumSpecializations() do
        self.specsCache[i] = C_SpecializationInfo.GetSpecializationInfo(i)
    end
end

function artifactTraitUtils:OnEquipmentUpdate()
    self:TriggerCallbacks(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_EQUIPPED)
end

---@param specID number|string
---@return number|nil activeRowID
function artifactTraitUtils:GetRowForSpec(specID)
    specID = tostring(specID)
    local specActivate = self.addon:GetDatabaseValue("artifactTraits.autoActive", true)
    if specActivate and specActivate[specID] then
        return specActivate[specID]
    end
end

---@param specID number|string
---@param rowID number|nil
function artifactTraitUtils:SetRowForSpec(specID, rowID)
    specID = tostring(specID)
    local rowActive = self:GetActiveRowID()
    if rowActive == rowID then
        rowID = nil
    end
    if rowID and specID == tostring(self:GetSpecID()) then
        self:SwitchRowTraits(rowID)
    end
    self.addon:SetDatabaseValue("artifactTraits.autoActive." .. specID, rowID)
end

---@return table<number, number>
function artifactTraitUtils:GetSpecRows()
    local specRows = {}
    for _, specID in ipairs(self:GetSpecs()) do
        local rowID = self:GetRowForSpec(specID)
        if rowID then
            specRows[specID] = rowID
        end
    end
    return specRows
end

---@return number|nil activeRowID
function artifactTraitUtils:GetPlayerRow()
    local specID = self:GetSpecID()
    if not specID then return end

    return self:GetRowForSpec(specID)
end

function artifactTraitUtils:ResetTree()
    local treeID = const.REMIX_ARTIFACT_TRAITS.TREE_ID
    C_Traits.ResetTree(self:GetConfigID(treeID), treeID)
end

function artifactTraitUtils:GetBaseTraits()
    if not self.baseTraits then
        self:BuildTraitTrees()
        if not self.baseTraits then return {} end
    end
    return CopyTable(self.baseTraits)
end

function artifactTraitUtils:GetActiveRowID()
    local rows = self:GetIndexedRowRootNodes()
    for rowID, nodeID in pairs(rows) do
        local rowInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeID)
        if rowInfo and rowInfo.currentRank > 0 then
            return rowID
        end
    end
end

function artifactTraitUtils:SwitchRowTraits(newRowID)
    local configID = self:GetConfigID()
    local treeID = const.REMIX_ARTIFACT_TRAITS.TREE_ID
    self:ResetTree()
    self:PurchaseNodes(treeID, self:GetBaseTraits())
    self:PurchaseNodes(treeID, self:GetBaseTraits())
    local rowTraits = self:GetRowTraitsForRow(newRowID)
    C_Traits.TryPurchaseToNode(configID, rowTraits[#rowTraits])
    C_Traits.TryPurchaseAllRanks(configID, const.REMIX_ARTIFACT_TRAITS.FINAL_TRAIT.NODE_ID)
    C_Traits.CommitConfig(configID)

    self:TriggerCallbacks(const.REMIX_ARTIFACT_TRAITS.CALLBACK_CATEGORY_ROW)
end

local TRY_PURCHASE_RESULTS = {
    SUCCESS = 0,
    NOT_ENOUGH_CURRENCY = 1,
    ALREADY_PURCHASED = 2,
    NOT_AVAILABLE = 3,
}
function artifactTraitUtils:TryPurchase(treeID, nodeID)
    local configID = self:GetConfigID(treeID)
    local costInfo = C_Traits.GetNodeCost(configID, nodeID)
    local currencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, false)[1]
    local currencyLeft = currencyInfo and currencyInfo.quantity or 0
    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
    if not nodeInfo.isAvailable then
        return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
    end
    local nodeCost = costInfo and costInfo[1] and costInfo[1].amount * nodeInfo.maxRanks or 0
    if currencyLeft < nodeCost then
        return TRY_PURCHASE_RESULTS.NOT_ENOUGH_CURRENCY
    end
    if nodeInfo.ranksPurchased >= nodeInfo.maxRanks then
        return TRY_PURCHASE_RESULTS.ALREADY_PURCHASED
    end
    if #nodeInfo.entryIDs > 1 then
        local entryID = nodeInfo.entryIDs[1]
        local success = C_Traits.SetSelection(configID, nodeID, entryID)
        local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
        for i = 1, entryInfo.maxRanks - 1 do
            success = C_Traits.PurchaseRank(configID, nodeID)
            if not success then
                return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
            end
        end
        if not success then
            return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
        end
    else
        for i = 1, nodeInfo.maxRanks do
            local success = C_Traits.PurchaseRank(configID, nodeID)
            if not success then
                return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
            end
        end
    end
    return TRY_PURCHASE_RESULTS.SUCCESS
end

function artifactTraitUtils:PurchasePossibleRanks(treeID, nodeID)
    local configID = self:GetConfigID(treeID)
    local costInfo = C_Traits.GetNodeCost(configID, nodeID)
    local currencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, false)[1]
    local currencyLeft = currencyInfo and currencyInfo.quantity or 0
    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
    if not nodeInfo.isAvailable then
        return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
    end
    if not (costInfo and costInfo[1] and costInfo[1].amount) then
        return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
    end
    local costPerRank = costInfo[1].amount
    local possibleRanks = math.floor(currencyLeft / costPerRank)
    if possibleRanks <= 0 then
        return TRY_PURCHASE_RESULTS.NOT_ENOUGH_CURRENCY
    end

    for i = 1, possibleRanks do
        local success = C_Traits.PurchaseRank(configID, nodeID)
        if not success then
            return TRY_PURCHASE_RESULTS.NOT_AVAILABLE
        end
    end
end

function artifactTraitUtils:PurchaseNodes(treeID, nodes)
    local tries = 0
    local maxTries = (#nodes * 3) + 10
    while true do
        for i, nodeID in ipairs(nodes) do
            local result = self:TryPurchase(treeID, nodeID)
            if result == TRY_PURCHASE_RESULTS.NOT_ENOUGH_CURRENCY then
                return
            end
            if result == TRY_PURCHASE_RESULTS.ALREADY_PURCHASED or result == TRY_PURCHASE_RESULTS.SUCCESS then
                tremove(nodes, i)
            end
        end
        if #nodes == 0 then
            return
        end
        if tries >= maxTries then
            self.addon:Print(self.L["ArtifactTraitUtils.MaxTriesReached"])
            return
        end
        tries = tries + 1
    end
end

---@return number|nil nextNodeID
function artifactTraitUtils:GetNextPurchaseNode()
    local baseTraits = self:GetBaseTraits()
    if #baseTraits <= 0 then return end
    for _, nodeID in ipairs(baseTraits) do
        local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeID)
        if nodeInfo and nodeInfo.isAvailable and nodeInfo.ranksPurchased < nodeInfo.maxRanks then
            return nodeID
        end
    end

    local rowTraits = self:GetRowTraitsForRow(self:GetRowForSpec(self:GetSpecID()) or 1)
    for _, nodeID in ipairs(rowTraits) do
        local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeID)
        if nodeInfo and nodeInfo.isAvailable and nodeInfo.ranksPurchased < nodeInfo.maxRanks then
            return nodeID
        end
    end
    return const.REMIX_ARTIFACT_TRAITS.FINAL_TRAIT.NODE_ID
end

function artifactTraitUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["ArtifactTraitUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["ArtifactTraitUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_ARTIFACT_BUY", "BOOLEAN", self.L["ArtifactTraitUtils.AutoBuy"],
        self.L["ArtifactTraitUtils.AutoBuyTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "artifactTraits.autoBuy"))
end