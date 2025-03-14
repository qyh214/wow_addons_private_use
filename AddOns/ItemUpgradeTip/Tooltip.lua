-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

local ITEM_UPGRADE_LEVEL_PATTERN = ITEM_UPGRADE_TOOLTIP_FORMAT:gsub("%%d+", "(%%d+)")  -- Upgrade Level: %d/%d
local ITEM_UPGRADE_TRACK_PATTERN = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%d", "(%%d+)"):gsub("%%s", "(.-)") -- "Upgrade Level: %s %d/%d"
local KEYSTONE_LINK_PATTERN = "keystone:(%d+):(.-):(.-):(.-):(.-):(.-):(.-)"
local TIMEWORN_KEYSTONE_ITEM_PATTERN = "item:(187786):(.+)" -- Timeworn Keystone
local MYTHIC_KEYSTONE_ITEM_PATTERN = "item:(180653):(.+)" -- Mythic Keystone

---@param tooltip GameTooltip
---@param itemLink string
---@return KeystoneInfo?
function private.HandleKeystone(tooltip, itemLink)
    local function ParseItemLink(pattern)
        local itemId, raw = itemLink:match(pattern)
        if not itemId then
            return
        end

        ---@type table<number,any>
        local itemSplit = {}

        for v in string.gmatch(raw, "(%d*:?)") do
            if v == ":" then
                itemSplit[#itemSplit + 1] = 0
            else
                itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
            end
        end

        -- itemSplit[15] is where the mythicPlusMapID is found, lookup with C_ChallengeMode.GetMapUIInfo(mythicPlusMapID)

        return itemId, itemSplit[15], itemSplit[17], itemSplit[19] or 0, itemSplit[21] or 0, itemSplit[23] or 0
    end

    local itemId, instanceId, keyLevel, affix1, affix2, affix3, affix4, _ = itemLink:match(KEYSTONE_LINK_PATTERN)
    if not itemId then
        itemId, instanceId, keyLevel, affix1, affix2, affix3, affix4 = ParseItemLink(TIMEWORN_KEYSTONE_ITEM_PATTERN)
    end
    if not itemId then
        itemId, instanceId, keyLevel, affix1, affix2, affix3, affix4 = ParseItemLink(MYTHIC_KEYSTONE_ITEM_PATTERN)
    end

    if not itemId then
        private.Debug(itemLink, "was not a Mythic+ keystone");
        return
    end

    itemId, instanceId, keyLevel, affix1, affix2, affix3, affix4 =
        tonumber(itemId),
        tonumber(instanceId),
        tonumber(keyLevel),
        tonumber(affix1),
        tonumber(affix2),
        tonumber(affix3),
        tonumber(affix4)

    if keyLevel >= 20 then
        -- Adjust to match the Mythic+ info
        keyLevel = "20+"
    end

    for _, mPlusKey in ipairs(ItemUpgradeTip:GetMythicPlusInfo()) do
        if keyLevel == mPlusKey.keyLevel then
            local icon = mPlusKey.currency.icon and CreateTextureMarkup(mPlusKey.currency.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""

            GameTooltip_AddBlankLineToTooltip(tooltip);
            tooltip:AddDoubleLine(L["LOOT_DROPS"], mPlusKey.lootDrops)
            tooltip:AddDoubleLine(L["VAULT_REWARD"], mPlusKey.vaultReward)
            tooltip:AddDoubleLine(L["CREST_TYPE"], icon .. " " .. mPlusKey.currency.color:WrapTextInColorCode(mPlusKey.currency.name))
        end
    end
end

--- Generic currency handler based on bonusInfo table
---@param tooltip GameTooltip
---@param currentUpgrade number
---@param maxUpgrade number
---@param bonusInfo BonusData
function private.HandleCurrency(tooltip, currentUpgrade, maxUpgrade, bonusInfo)
    local upgradesRemaining = maxUpgrade - currentUpgrade
    local currencyInfo = private.currencyInfo[bonusInfo.currencyId]
    if not currencyInfo then
        private.Debug(bonusInfo.currencyId, "was not found in the currency info cache");
        return
    end

    local currencyOwned = currencyInfo.quantity
    local currencyIconId = currencyInfo.iconFileID

    tooltip:AddLine("\n")

    tooltip:AddLine("|cffa335ee" .. L["X_UPGRADES"]:format(currencyInfo.name) .. "|r")
    tooltip:AddTexture(currencyIconId)

    if currencyOwned >= bonusInfo.toMax and upgradesRemaining > 0 and not private.DB.profile.CompactTooltips then
        tooltip:AddLine(L["ITEM_CAN_BE_UPGRADED_TO_MAX"])
    end

    if upgradesRemaining == 0 then
        if not private.DB.profile.CompactTooltips then
            tooltip:AddLine("|cffffffee" .. L["ITEM_UPGRADED_TO_MAX"] .. "|r")
        end
    else
        tooltip:AddDoubleLine("|cffffffee" .. L["COST_FOR_NEXT_LEVEL"] .. "|r", "|cffffffee" .. bonusInfo.amount .. "|r")
        tooltip:AddDoubleLine("|cffffffee" .. L["COST_TO_UPGRADE_TO_MAX"] .. "|r", "|cffffffee" .. bonusInfo.toMax .. "|r")

        if not private.DB.profile.CompactTooltips then
            if currencyOwned >= bonusInfo.toMax then
                tooltip:AddDoubleLine("|cffffffee" .. L["CURRENCY_REMAINING_AFTER_UPGRADING"] .. "|r", "|cffffffee" .. (currencyOwned - bonusInfo.toMax) .. "|r")
            else
                tooltip:AddDoubleLine("|cffffffee" .. L["CURRENCY_NEEDED_FOR_MAX"] .. "|r", "|cffffffee" .. (bonusInfo.toMax - currencyOwned) .. "|r")
            end
        end
    end
end

--- Handles updating an item tooltip to add additional information about upgrade costs
---@param tooltip GameTooltip
---@param tooltipData TooltipData
function private.HandleTooltipSetItem(tooltip, tooltipData)
    if tooltip ~= _G.GameTooltip and tooltip ~= _G.ItemRefTooltip then
    -- if tooltip.GetItem == nil then
        return
    end

    if private.DB.profile.ModifierKey ~= "NONE" and (
        (private.DB.profile.ModifierKey == "ALT" and not IsAltKeyDown())
        or (private.DB.profile.ModifierKey == "CTRL" and not IsControlKeyDown())
        or (private.DB.profile.ModifierKey == "SHIFT" and not IsShiftKeyDown())
    )
    then
        return
    end

    local _, itemLink = tooltip:GetItem()
    if not itemLink or type(itemLink) ~= "string" then
        return
    end

    if C_Item.IsItemKeystoneByID(itemLink) and private.HandleKeystone(tooltip, itemLink) then
        return
    end

    ---@type table<number, boolean>
    local processed = {};   --process each line once

    for i = 1, #tooltipData.lines do
        if not processed[i] then
            ---@type TooltipDataLine
            local tooltipLine = tooltipData.lines[i]

            private.Debug(tooltipLine.leftText)

            local debugPattern = ITEM_UPGRADE_LEVEL_PATTERN

            local currentUpgrade, ---@type number?
                maxUpgrade ---@type number?
            = tooltipLine.leftText:match(ITEM_UPGRADE_LEVEL_PATTERN)

            if not currentUpgrade or not maxUpgrade then
                _, currentUpgrade, maxUpgrade = tooltipLine.leftText:match(ITEM_UPGRADE_TRACK_PATTERN)

                debugPattern = ITEM_UPGRADE_TRACK_PATTERN
            end

            if currentUpgrade and maxUpgrade then
                private.Debug(debugPattern, "-", currentUpgrade, "/", maxUpgrade)

                if currentUpgrade == maxUpgrade then
                    private.Debug(currentUpgrade, "was equal to", maxUpgrade)
                    return
                end

                ---@type string?
                local itemString = string.match(itemLink, "item:([%-?%d:]+)")
                if not itemString then
                    private.Debug(itemLink, "does not appear to be a valid item string (did not match \"item:([%-?%d:]+)\")");
                    return
                end

                ---@type table<number, number>
                local bonusIds = {}

                ---@type table<number,any>
                local itemSplit = {}

                for v in string.gmatch(itemString, "(%d*:?)") do
                    if v == ":" then
                        itemSplit[#itemSplit + 1] = 0
                    else
                        itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
                    end
                end

                ---@type number?
                local itemId = tonumber(itemSplit[1])
                if not itemId then
                    private.Debug(itemString, "does not appear to contain a valid item ID (found", itemId, ")");
                    return
                end

                ---@type number?
                local numBonusIds = tonumber(itemSplit[13])
                if not numBonusIds then
                    private.Debug(itemString, "does not appear to contain the number of bonuses (found", numBonusIds, ")");
                    return
                end

                for index = 1, numBonusIds do
                    bonusIds[#bonusIds + 1] = tonumber(itemSplit[13 + index])
                end

                processed[i] = true;

                for j = 1, #private.upgradeHandlers do
                    local callback = private.upgradeHandlers[j]

                    if type(callback) == "function" and callback(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds) then return end
                end

                return
            end
        end
    end
end

-- Tooltip integration
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, private.HandleTooltipSetItem)
