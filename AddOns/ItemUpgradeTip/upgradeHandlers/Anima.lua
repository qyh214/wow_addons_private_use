-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Anima = false;
private.Preferences.DisabledIntegrations.Anima = {
    type = "toggle",
    name = L["ANIMA_UPGRADES"],
    order = 120,
    width = "double",
}

private.currencyIds["Anima"] = 1813
private.currencyIndexes[private.currencyIds.Anima] = true

---@type Array<BonusData>
local animaBonusIds = {
    [7195] = {currencyId = private.currencyIds.Anima, amount = 50,  toMax = 1050},
    [7196] = {currencyId = private.currencyIds.Anima, amount = 100, toMax = 1000},
    [7197] = {currencyId = private.currencyIds.Anima, amount = 150, toMax = 900},
    [7198] = {currencyId = private.currencyIds.Anima, amount = 200, toMax = 750},
    [7199] = {currencyId = private.currencyIds.Anima, amount = 250, toMax = 550},
    [7200] = {currencyId = private.currencyIds.Anima, amount = 300, toMax = 300},
    [7201] = {currencyId = private.currencyIds.Anima, amount = 0,   toMax = 0},
}

--- Checks for Anima bonus IDs and chains call to HandleCurrency if found
---@see private.HandleCurrency
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId number
---@param itemLink string
---@param currentUpgrade number
---@param maxUpgrade number
---@param bonusIds table<number, number>
---@return boolean
local function CheckAnimaBonusIds(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Anima then
        private.Debug("Anima integration is disabled");

        return false
    end

    for i = 1, #bonusIds do
        private.Debug("Checking Anima bonus IDs for", bonusIds[i]);

        ---@type BonusData?
        local bonusInfo = animaBonusIds[bonusIds[i]]

        if bonusInfo ~= nil then
            private.Debug(bonusIds[i], "matched an Anima bonus ID");
            private.HandleCurrency(tooltip, currentUpgrade, maxUpgrade, bonusInfo)
            return true
        end
    end

    private.Debug(itemId, "did not match an Anima bonus ID");
    return false
end

table.insert(private.upgradeHandlers, CheckAnimaBonusIds)
