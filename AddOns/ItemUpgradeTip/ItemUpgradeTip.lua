-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

---@class ItemUpgradeTip: AceAddon, AceConsole-3.0, AceEvent-3.0
ItemUpgradeTip = LibStub("AceAddon-3.0"):NewAddon(AddOnFolderName, "AceConsole-3.0", "AceEvent-3.0")

ItemUpgradeTip.Version = C_AddOns.GetAddOnMetadata(AddOnFolderName, "Version");
ItemUpgradeTip.L = L;

private.allFrames = {}
ItemUpgradeTip.Skins = {}

function ItemUpgradeTip:GetAllFrames()
  return private.allFrames
end

function ItemUpgradeTip:RegisterSkinListener(callback)
    if not private.skinListeners then
        private.skinListeners = {}
    end
    table.insert(private.skinListeners, callback)
end

function ItemUpgradeTip:AddSkinnableFrame(frameType, frame, extraInfo)
    if not frame.added then
        local details = {frameType = frameType, frame = frame, extraInfo = extraInfo}
        table.insert(private.allFrames, details)
        if private.skinListeners then
            for _, listener in ipairs(private.skinListeners) do
                xpcall(listener, CallErrorHandler, details)
            end
        end
        frame.added = true
    end
  end

-- Toggle the upgrade pane
function ItemUpgradeTip:ToggleView()
    ---@diagnostic disable-next-line: need-check-nil
    IUTView:SetShown(not IUTView:IsShown())
end

-- Return the Mythic+ info
---@return Array<MythicPlusInfo>
function ItemUpgradeTip:GetMythicPlusInfo()
    return private.mythicPlusInfo
end

-- Return the Raid info
---@return Array<RaidInfo>
function ItemUpgradeTip:GetRaidInfo()
    return private.raidInfo
end

-- Return the Raid currency info
---@return RaidCurrencyInfo
function ItemUpgradeTip:GetRaidCurrencyInfo()
    return private.raidCurrencyInfo
end

-- Return the Upgrade info
---@return Array<UpgradeTrackInfo>
function ItemUpgradeTip:GetUpgradeTrackInfo()
    return private.upgradeTrackInfo
end

-- Return the Crafting info
---@return Array<CraftingInfo>
function ItemUpgradeTip:GetCraftingInfo()
    return private.craftingInfo
end

-- Return the Currency info from cache
---@param currencyId integer
---@return CurrencyInfo
function ItemUpgradeTip:GetCurrencyInfo(currencyId)
    return private.currencyInfo[currencyId]
end

-- Core initialisation
function ItemUpgradeTip:OnInitialize()
    local DB = private.Preferences:InitializeDatabase()

    private.DB = DB

    private.Preferences:SetupOptions()

    self:RegisterChatCommand("itemupgradetip", "ChatCommand")
    self:RegisterChatCommand("iut", "ChatCommand")
end

-- Ran during PLAYER_LOGIN
function ItemUpgradeTip:OnEnable()
    for currencyId, _ in pairs(private.currencyIndexes) do
        private.currencyInfo[currencyId] = C_CurrencyInfo.GetCurrencyInfo(currencyId)
    end

    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    CreateFrame("Frame", "IUTView", UIParent, "ItemUpgradeTipUpgradeTemplate")

    ItemUpgradeTip:AddSkinnableFrame("ContainerFrame", IUTView)
end

-- Not super useful just now, but might be in the future
function ItemUpgradeTip:OnDisable()
    self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:UnregisterChatCommand("itemupgradetip")
    self:UnregisterChatCommand("iut")
end

---Currency updated
---@diagnostic disable: unused-local
---@param event string
---@param currencyType number?
---@param quantity number?
---@param quantityChange number?
---@param quantityGainSource number?
---@param quantityLostSource number?
function ItemUpgradeTip:CURRENCY_DISPLAY_UPDATE(event, currencyType, quantity, quantityChange, quantityGainSource, quantityLostSource)

    if currencyType and quantity then
        if private.currencyIndexes[currencyType] then
            -- Refresh the entire currency info in case there's info other than quantity that also updated
            private.currencyInfo[currencyType] = C_CurrencyInfo.GetCurrencyInfo(currencyType)
        end
    end
end

local SUBCOMMAND_FUNCS = {
    ["SETTINGS"] = function()
        local settingsPanel = SettingsPanel

        if settingsPanel:IsVisible() then
            settingsPanel:Hide()
        else
            ---@diagnostic disable-next-line: undefined-field
            Settings.OpenToCategory(private.Preferences.OptionsFrame.ID)
        end
    end
}

---@param input string
function ItemUpgradeTip:ChatCommand(input)
    local subcommand, arguments = self:GetArgs(input, 2)

    if subcommand then
        local func = SUBCOMMAND_FUNCS[subcommand:upper()]

        if func then
            func(arguments or "")
        end
    else
        self:ToggleView()
    end
end

function ItemUpgradeTip_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_NONE");
    GameTooltip:SetPoint("TOPRIGHT", menuButtonFrame, "BOTTOMRIGHT", 0, 0);
    GameTooltip:ClearLines();
    GameTooltip:AddDoubleLine(AddOnFolderName, ItemUpgradeTip.Version);
    GameTooltip_AddBlankLineToTooltip(GameTooltip);
    GameTooltip:AddLine(L["LEFT_CLICK"] .. " " .. BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(L["LEFT_CLICK_DESC"]));
    GameTooltip:AddLine(L["RIGHT_CLICK"] .. " "  .. BRIGHTBLUE_FONT_COLOR:WrapTextInColorCode(L["RIGHT_CLICK_DESC"]));
    GameTooltip:Show();
end

function ItemUpgradeTip_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide();
end

function ItemUpgradeTip_OnAddonCompartmentClick(addonName, button)
    if (button == "LeftButton") then
		ItemUpgradeTip:ToggleView()
	elseif (button == "RightButton") then
        ---@diagnostic disable-next-line: undefined-field
        Settings.OpenToCategory(private.Preferences.OptionsFrame.ID)
	end
end
