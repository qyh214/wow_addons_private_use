---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants

---@class ItemOpenerUtils
local itemOpenerUtils = {
    ---@type table<any, string>
    L = nil,
    ---@type ItemUtils
    itemUtils = nil,
    ---@type LegionRH
    addon = nil
}
Private.ItemOpenerUtils = itemOpenerUtils

function itemOpenerUtils:CreateSettings(items)
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["ItemOpenerUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["ItemOpenerUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_ITEM_OPEN", "BOOLEAN", self.L["ItemOpenerUtils.AutoItemOpen"],
        self.L["ItemOpenerUtils.AutoItemOpenTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "itemOpener.autoItemOpen"))

    local openItemTooltip = self.L["ItemOpenerUtils.AutoOpenItemEntryTooltip"]
    for _, itemData in ipairs(items) do
        settingsUtils:CreateCheckbox(settingsCategory, "AUTO_ITEM_OPEN_" .. itemData.id, "BOOLEAN",
            itemData.link,
            openItemTooltip:format(itemData.link), true,
            settingsUtils:GetDBFunc("GETTERSETTER", "itemOpener.items." .. itemData.id))
    end
end

function itemOpenerUtils:InitAndCreateSettings()
    local items = {}
    for itemIndex, itemEntry in ipairs(const.ITEM_OPENER.ITEMS) do
        local id = itemEntry.ITEM_ID
        local item = Item:CreateFromItemID(id)
        item:ContinueOnItemLoad(function()
            local link = item:GetItemLink()
            if link and link ~= "" then
                tinsert(items, { id = id, link = link })

                if #items == #const.ITEM_OPENER.ITEMS then
                    self:CreateSettings(items)
                end
            end
        end)
    end
end

---@param itemID number
---@return boolean isEnabled
function itemOpenerUtils:IsOpenItemEnabled(itemID)
    local db = self.addon:GetDatabaseValue("itemOpener.items." .. itemID, true)
    return db and true or false
end

---@param itemLoc ItemLocationMixin
---@return boolean isAutoItem
function itemOpenerUtils:IsAutoItem(itemLoc)
    for _, itemEntry in ipairs(const.ITEM_OPENER.ITEMS) do
        if itemLoc and itemLoc:IsValid() then
            local itemID = C_Item.GetItemID(itemLoc)
            local isEnabled = self:IsOpenItemEnabled(itemEntry.ITEM_ID)
            if itemID == itemEntry.ITEM_ID and isEnabled then
                return true
            end
            if itemEntry.ITEM_NAME and isEnabled then
                local itemName = C_Item.GetItemName(itemLoc)
                if itemName == itemEntry.ITEM_NAME then
                    return true
                end
            end
        end
    end
    return false
end

function itemOpenerUtils:OpenBagItems()
    if not Private.Addon:GetDatabaseValue("itemOpener.autoItemOpen", true) then
        return
    end
    if InCombatLockdown() then
        local callback = self.addon:GetEventCallback("PLAYER_REGEN_ENABLED", "ItemOpenerUtils_OnPlayerRegenEnabled")
        if callback then
            return
        end
        self.addon:RegisterEvent("PLAYER_REGEN_ENABLED", "ItemOpenerUtils_OnPlayerRegenEnabled", function()
            self.addon:UnregisterEventCallback("PLAYER_REGEN_ENABLED", "ItemOpenerUtils_OnPlayerRegenEnabled")
            self:OpenBagItems()
        end)
        return
    end
    for itemLoc in self.itemUtils:ForEachBagItem() do
        if self:IsAutoItem(itemLoc) then
            C_Container.UseContainerItem(itemLoc:GetBagAndSlot())
            return -- after opening we will get another BAG_UPDATE_DELAYED. stop here to avoid Locked items
        end
    end
end

function itemOpenerUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon
    self.itemUtils = Private.ItemUtils

    addon:RegisterEvent("BAG_UPDATE_DELAYED", "ItemOpenerUtils_OnBagUpdateDelayed", function()
        RunNextFrame(function()
            self:OpenBagItems()
        end)
    end)
end
