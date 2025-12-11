---@class AddonPrivate
local Private = select(2, ...)

---@class MerchantUtils
---@field addon LegionRH
local merchantUtils = {
    addon = nil,
    ---@type table<any, string>
    L = nil,
    ---@type CollectionUtils
    collectionsUtils = nil,
    filteredVendorItems = {}
}
Private.MerchantUtils = merchantUtils

local const = Private.constants

function merchantUtils:Init()
    self.collectionsUtils = Private.CollectionUtils
    self.L = Private.L

    local addon = Private.Addon
    self.addon = addon

    -- Rebuild filtered items when the merchant window is first shown
    addon:RegisterEvent("MERCHANT_SHOW", "MerchantUtils_MerchantShow", function()
        self:OnMerchantShow()
    end)

    -- Merchant inventory can change in multiple ways; make the addon reapply
    -- the filter whenever the merchant frame updates (covers paging, tab
    -- changes and some Blizzard updates) and when the merchant data itself
    -- updates. This mirrors what toggling the option manually forces.
    addon:RegisterEvent("MERCHANT_UPDATE", "MerchantUtils_MerchantUpdate", function()
        -- Rebuild the filtered list and update UI when merchant data changes
        self:RefreshMerchant()
    end)

    -- Hook the broader frame update to ensure our UpdateMerchant runs whenever
    -- Blizzard refreshes the merchant UI layout.
    hooksecurefunc("MerchantFrame_Update", function()
        self:UpdateMerchant()
    end)

    -- Keep the existing, more specific hook as a fallback for API differences
    hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
        self:UpdateMerchant()
    end)
end

function merchantUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["MerchantUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["MerchantUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "HIDE_COLLECTED_MERCHANT_ITEMS", "BOOLEAN",
        self.L["MerchantUtils.HideCollectedMerchantItems"],
        self.L["MerchantUtils.HideCollectedMerchantItemsTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "merchant.hideCollectedItems"))
    settingsUtils:CreateCheckbox(settingsCategory, "HIDE_COLLECTED_PETS_AT_LIMIT", "BOOLEAN",
        self.L["MerchantUtils.HideCollectedPetsAtLimit"],
        self.L["MerchantUtils.HideCollectedPetsAtLimitTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "merchant.hideCollectedPetsAtLimit"))
end

function merchantUtils:UpdateMerchantBtn(btn, i)
    local merchantButton = _G["MerchantItem" .. btn]
    local itemName = _G["MerchantItem" .. btn .. "Name"]
    local itemButton = _G["MerchantItem" .. btn .. "ItemButton"]
    local altCurrency = _G["MerchantItem" .. btn .. "AltCurrencyFrame"]
    local function popItem()
        itemName:SetText("")
        itemButton:Hide()
        altCurrency:Hide()
        itemButton.IconQuestTexture:Hide()
        SetItemButtonSlotVertexColor(merchantButton, 0.4, 0.4, 0.4)
        SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5)
    end
    if i == nil then
        popItem()
        return
    end
    local item = C_MerchantFrame.GetItemInfo(i)
    if not item or item.name == nil then
        popItem()
        return
    end
    popItem()

    itemName:SetText(item.name)
    SetItemButtonTexture(itemButton, item.texture)
    MerchantFrame_UpdateAltCurrency(i, btn, CanAffordMerchantItem(i))
    altCurrency:Show()
    local itemLink = GetMerchantItemLink(i)
    MerchantFrameItem_UpdateQuality(merchantButton, itemLink)
    local merchantItemID = GetMerchantItemID(i)
    local isHeirloom = merchantItemID and C_Heirloom.IsItemHeirloom(merchantItemID)
    local isKnownHeirloom = isHeirloom and C_Heirloom.PlayerHasHeirloom(merchantItemID)
    itemButton:SetID(i)
    itemButton:Show()
    itemButton.link = itemLink
    itemButton.texture = item.texture
    if item.isQuestStartItem then
        itemButton.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
        itemButton.IconQuestTexture:Show()
    end
    SetItemButtonDesaturated(itemButton, isKnownHeirloom)

    if isKnownHeirloom then
        SetItemButtonSlotVertexColor(merchantButton, 0.5, 0.5, 0.5)
        SetItemButtonTextureVertexColor(itemButton, 0.5, 0.5, 0.5)
        SetItemButtonNormalTextureVertexColor(itemButton, 0.5, 0.5, 0.5)
    elseif not item.isPurchasable then
        SetItemButtonSlotVertexColor(merchantButton, 1.0, 0, 0)
        SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0)
        SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0)
    else
        SetItemButtonSlotVertexColor(merchantButton, 1.0, 1.0, 1.0)
        SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0)
        SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0)
    end
end

function merchantUtils:UpdateMerchant()
    if not self:IsSettingsAndMerchantValid() then
        return
    end

    local size = MERCHANT_ITEMS_PER_PAGE
    MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER, MerchantFrame.page,
        math.ceil(#self.filteredVendorItems / size))
    if #self.filteredVendorItems <= size then
        MerchantPageText:Hide()
        MerchantPrevPageButton:Hide()
        MerchantNextPageButton:Hide()
    elseif MerchantFrame.page == math.ceil(#self.filteredVendorItems / size) then
        MerchantNextPageButton:Disable()
    end
    for i = 1, size do
        local index = (MerchantFrame.page - 1) * size + i
        self:UpdateMerchantBtn(i, self.filteredVendorItems[index])
    end
end

function merchantUtils:IsItemCollected(itemID)
    if not itemID then return false end
    local setID = C_Item.GetItemLearnTransmogSet(itemID)
    if setID then -- tmog set
        return self.collectionsUtils:GetSetCollectionFunction(setID)()
    end
    if C_ToyBox.GetToyInfo(itemID) then -- toy
        return self.collectionsUtils:GetToyCollectionFunction(itemID)()
    end
    local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
    if speciesID then -- pet
        return self.collectionsUtils:GetPetCollectionFunction(speciesID, true)()
    end
    local mountID = C_MountJournal.GetMountFromItem(itemID)
    if mountID then -- mount
        return self.collectionsUtils:GetMountCollectionFunction(mountID)()
    end

    -- probably appearance, as we can't buy titles or Illusions from merchants
    return self.collectionsUtils:GetAppearanceCollectionFunction(itemID)()
end

---@return boolean isValid
function merchantUtils:IsSettingsAndMerchantValid()
    if not self.addon:GetDatabaseValue("merchant.hideCollectedItems", true) then
        return false
    end
    local npcID = self:GetNpcID()
    if not npcID then return false end
    if not self.collectionsUtils:GetVendorByID(npcID) then return false end
    return true
end

function merchantUtils:ShouldHidePetsAtLimit()
    return self.addon:GetDatabaseValue("merchant.hideCollectedPetsAtLimit", true)
end

function merchantUtils:IsFilteredOut(itemID)
    if not itemID then return false end
    local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
    if speciesID then
        local shouldHidePetsAtLimit = self:ShouldHidePetsAtLimit()
        local collected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        local isAtLimit = collected >= limit

        if shouldHidePetsAtLimit and isAtLimit then
            return true
        end
        return (not shouldHidePetsAtLimit) and (collected > 0)
    end
    return false
end

-- General-purpose merchant refresh used for show/update events
function merchantUtils:RefreshMerchant()
    if not self:IsSettingsAndMerchantValid() then
        return
    end

    self.filteredVendorItems = {}
    for i = 1, GetMerchantNumItems() do
        local itemID = GetMerchantItemID(i)
        if not (self:IsItemCollected(itemID) or self:IsFilteredOut(itemID)) then
            tinsert(self.filteredVendorItems, i)
        end
    end
    MerchantFrame.page = 1
    MerchantPrevPageButton:Disable()
    MerchantNextPageButton:Enable()

    self:UpdateMerchant()
end

-- Keep the original handler name as a thin wrapper for compatibility
function merchantUtils:OnMerchantShow()
    self:RefreshMerchant()
end

---@return number|nil npcID
function merchantUtils:GetNpcID()
    local guid = UnitGUID("npc") or UnitGUID("target")
    if not guid then
        return nil
    end
    local npcID = select(6, strsplit("-", guid))
    return tonumber(npcID)
end
