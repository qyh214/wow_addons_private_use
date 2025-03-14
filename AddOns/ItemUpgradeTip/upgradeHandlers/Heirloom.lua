-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Heirloom = false;
private.Preferences.DisabledIntegrations.Heirloom = {
    type = "toggle",
    name = L["HEIRLOOM_UPGRADES"],
    order = 105,
    width = "double",
}

--- Updates the tooltip when a Heirloom is the item in question
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId number
---@param itemLink string
---@param currentUpgrade number
---@param maxUpgrade number
---@param bonusIds table<number, number>
---@return boolean
local function HandleHeirloom(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Heirloom then
        private.Debug("Heirloom integration is disabled");

        return false
    end

    if not C_Heirloom.GetHeirloomInfo(itemId) then
        private.Debug(itemId, "was not an Heirloom item");
        return false
    end

    tooltip:AddLine("\n")

    tooltip:AddLine("|cffa335ee" .. L["HEIRLOOM_UPGRADES"] .. "|r")
    tooltip:AddTexture("Interface/Icons/inv_staff_13")

    local upgradesRemaining = maxUpgrade - currentUpgrade
    if upgradesRemaining == 0 then
        if not private.DB.profile.CompactTooltips then
            tooltip:AddLine("|cffffffee" .. L["ITEM_UPGRADED_TO_MAX"] .. "|r")
        end
    else
        tooltip:AddLine("|cffffffee" .. L["UPGRADE_LEVEL_X_Y"]:format(currentUpgrade, maxUpgrade) .. "|r")
    end

    private.Debug(itemId, "did not match a Heirloom bonus ID");
    return true
end

table.insert(private.upgradeHandlers, HandleHeirloom)
