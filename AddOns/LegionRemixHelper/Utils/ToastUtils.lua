---@class AddonPrivate
local Private = select(2, ...)

---@class ToastUtils
---@field addon LegionRH
local toastUtils = {
    addon = nil,
    notifiedUpgrades = {},
    ---@type table<any, string>
    L = nil,
}
Private.ToastUtils = toastUtils

local const = Private.constants

function toastUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon

    addon:RegisterEvent("BAG_UPDATE_DELAYED", "ToastUtils_OnBagUpdateDelayed", function()
        local upgradeItem = self:GetHighestUpgradeItem()
        if upgradeItem then
            local itemLink = C_Item.GetItemLink(upgradeItem)
            if itemLink then
                self:ShowUpgradeToast(itemLink, upgradeItem)
            end
        end
    end)

    addon:RegisterEvent("ITEM_COUNT_CHANGED", "ToastUtils_OnItemCountChanged", function(_, _, itemID)
        if not itemID then return end
        if const.TOASTS.ARTIFACT.ITEM_IDS[itemID] and C_Item.GetItemCount(itemID) > 0 then
            self:ShowArtifactToast()
        end
    end)

    addon:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "ToastUtils_OnQuestAccepted", function(_, _, currencyID, _, quantityChange)
        if not currencyID then return end
        if currencyID == const.TOASTS.BRONZE.CURRENCY_ID then
            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
            local current = currencyInfo.quantity
            local percentage = (current / currencyInfo.maxQuantity) * 100
            local previous = current - (quantityChange or 0)
            local previewPercentage = (previous / currencyInfo.maxQuantity) * 100
            for _, milestone in ipairs(const.TOASTS.BRONZE.MILESTONES) do
                if previous < milestone and current >= milestone then
                    self:ShowBronzeToast(current, percentage)
                    break
                end
            end
            for _, milestone in ipairs(const.TOASTS.BRONZE.PERCENTAGE_MILESTONES) do
                if previewPercentage < milestone and percentage >= milestone then
                    self:ShowBronzeToast(current, percentage)
                    break
                end
            end
        end
    end)
end

---@return ItemLocationMixin?
function toastUtils:GetHighestUpgradeItem()
    local highestLoc, highestLevel = nil, 0
    for bagID = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemLoc = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
            if itemLoc:IsValid() then
                local itemGUID = C_Item.GetItemGUID(itemLoc)
                if not self.notifiedUpgrades[itemGUID] and C_Item.IsEquippableItem(C_Item.GetItemID(itemLoc)) then
                    local bagItemLevel = C_Item.GetCurrentItemLevel(itemLoc)
                    local equippedItemLevel = Private.ItemUtils:GetMinLevelForInvType(C_Item.GetItemInventoryType(itemLoc))
                    if equippedItemLevel and equippedItemLevel < bagItemLevel and bagItemLevel > highestLevel then
                        highestLoc = itemLoc
                        highestLevel = bagItemLevel
                    end
                end
            end
        end
    end
    if highestLoc then
        local itemGUID = C_Item.GetItemGUID(highestLoc)

        self.notifiedUpgrades[itemGUID] = true
        return highestLoc
    end
end

function toastUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["ToastUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["ToastUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_GENERAL", "BOOLEAN", self.L["ToastUtils.TypeGeneral"],
        self.L["ToastUtils.TypeGeneralTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.activate"))
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_SOUND", "BOOLEAN", self.L["ToastUtils.TypeSound"],
        self.L["ToastUtils.TypeSoundTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.sound"))
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_BRONZE", "BOOLEAN", self.L["ToastUtils.TypeBronze"],
        self.L["ToastUtils.TypeBronzeTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.bronze"))
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_ARTIFACT", "BOOLEAN", self.L["ToastUtils.TypeArtifact"],
        self.L["ToastUtils.TypeArtifactTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.artifact"))
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_UPGRADE", "BOOLEAN", self.L["ToastUtils.TypeUpgrade"],
        self.L["ToastUtils.TypeUpgradeTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.upgrade"))
    settingsUtils:CreateCheckbox(settingsCategory, "ACTIVATE_TOAST_TRAIT", "BOOLEAN", self.L["ToastUtils.TypeTrait"],
        self.L["ToastUtils.TypeTraitTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "toast.trait"))
    settingsUtils:CreateButton(settingsCategory, self.L["ToastUtils.TestToast"],
        self.L["ToastUtils.TestToastButtonTitle"],
        function()
            self:ShowToast(self.L["ToastUtils.TestToastTitle"], self.L["ToastUtils.TestToastDescription"], const.TOASTS.PLACEHOLDER_ICON)
        end,
        self.L["ToastUtils.TestToastTooltip"],
        true)
end

---@param toastType "activate"|"bronze"|"artifact"|"upgrade"|"trait"|"sound"
---@return boolean
function toastUtils:IsTypeActive(toastType)
    return self.addon:GetDatabaseValue("toast." .. toastType)
end

---@param title string
---@param description string
---@param texture number|string
---@param func fun(self: AlertComponentObject, button: string, down: boolean)?
function toastUtils:ShowToast(title, description, texture, func)
    if not self:IsTypeActive("activate") then
        return
    end
    Private.ToastUI:ShowToast(title, description, texture, func)

    if self:IsTypeActive("sound") then
        PlaySound(const.TOASTS.SOUND_ID, "SFX")
    end
end

---@param amount number
function toastUtils:ShowBronzeToast(amount, percentage)
    if not self:IsTypeActive("bronze") then
        return
    end
    self:ShowToast(
        self.L["ToastUtils.TypeBronzeTitle"],
        self.L["ToastUtils.TypeBronzeDescription"]:format(amount, percentage or 0),
        const.TOASTS.BRONZE.ICON
    )
end

function toastUtils:ShowArtifactToast()
    if not self:IsTypeActive("artifact") then
        return
    end
    self:ShowToast(
        self.L["ToastUtils.TypeArtifactTitle"],
        self.L["ToastUtils.TypeArtifactDescription"],
        const.TOASTS.ARTIFACT.ICON
    )
end

---@param itemLink string
---@param location ItemLocationMixin
function toastUtils:ShowUpgradeToast(itemLink, location)
    if not self:IsTypeActive("upgrade") then
        return
    end
    local icon = C_Item.GetItemIconByID(itemLink)
    self:ShowToast(
        self.L["ToastUtils.TypeUpgradeTitle"],
        itemLink or self.L["ToastUtils.TypeUpgradeFallback"],
        icon or const.TOASTS.FALLBACK_ICON,
        function()
            C_Container.PickupContainerItem(location:GetBagAndSlot())
            AutoEquipCursorItem()
        end
    )
end

function toastUtils:ShowTraitToast(name, icon)
    if not self:IsTypeActive("trait") then
        return
    end
    self:ShowToast(
        self.L["ToastUtils.TypeTraitTitle"],
        self.L["ToastUtils.TypeTraitDescription"]:format(name or self.L["ToastUtils.TypeTraitFallback"]),
        icon or const.TOASTS.FALLBACK_ICON
    )
end
