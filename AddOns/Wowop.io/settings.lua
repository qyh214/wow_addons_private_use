-- Get addon namespace
local addonName, addon = ...

-- Initialize saved variables with defaults
WOWOP_SETTINGS = WOWOP_SETTINGS or {
    disableDeathPopup = false,
    alwaysExpandTooltips = false,
    disableAutoMPlusPopup = false
}

-- Add helper functions to check settings (moved to top)
function addon:IsDeathPopupEnabled()
    return not WOWOP_SETTINGS.disableDeathPopup
end

function addon:ShouldExpandTooltips()
    return WOWOP_SETTINGS.alwaysExpandTooltips or IsShiftKeyDown()
end

function addon:IsAutoMPlusPopupEnabled()
    return not WOWOP_SETTINGS.disableAutoMPlusPopup
end

-- Create settings panel
local frame = CreateFrame("Frame")
frame.name = "WoWOP.io"

-- Create the settings UI
frame:SetScript("OnShow", function(frame)
    -- Add title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("WoWOP.io Settings")
    
    -- Create death popup checkbox
    local deathPopupCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    deathPopupCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    deathPopupCheckbox.text = deathPopupCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    deathPopupCheckbox.text:SetPoint("LEFT", deathPopupCheckbox, "RIGHT", 8, 0)
    deathPopupCheckbox.text:SetText("Disable Death Analysis Popup")
    deathPopupCheckbox:SetChecked(WOWOP_SETTINGS.disableDeathPopup)
    deathPopupCheckbox:SetScript("OnClick", function(self)
        WOWOP_SETTINGS.disableDeathPopup = self:GetChecked()
        if self:GetChecked() then
            PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)
    deathPopupCheckbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("If checked, the death analysis popup will not be shown when you die to a known ability in a dungeon.")
        GameTooltip:Show()
    end)
    deathPopupCheckbox:SetScript("OnLeave", GameTooltip_Hide)
    
    -- Create expanded tooltips checkbox
    local tooltipCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    tooltipCheckbox:SetPoint("TOPLEFT", deathPopupCheckbox, "BOTTOMLEFT", 0, -8)
    tooltipCheckbox.text = tooltipCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tooltipCheckbox.text:SetPoint("LEFT", tooltipCheckbox, "RIGHT", 8, 0)
    tooltipCheckbox.text:SetText("Always Show Expanded Tooltips")
    tooltipCheckbox:SetChecked(WOWOP_SETTINGS.alwaysExpandTooltips)
    tooltipCheckbox:SetScript("OnClick", function(self)
        WOWOP_SETTINGS.alwaysExpandTooltips = self:GetChecked()
        if self:GetChecked() then
            PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)
    tooltipCheckbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("If checked, tooltips will always show detailed information without requiring the Shift key to be held.")
        GameTooltip:Show()
    end)
    tooltipCheckbox:SetScript("OnLeave", GameTooltip_Hide)
    
    -- Create auto M+ popup checkbox
    local mplusPopupCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    mplusPopupCheckbox:SetPoint("TOPLEFT", tooltipCheckbox, "BOTTOMLEFT", 0, -8)
    mplusPopupCheckbox.text = mplusPopupCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    mplusPopupCheckbox.text:SetPoint("LEFT", mplusPopupCheckbox, "RIGHT", 8, 0)
    mplusPopupCheckbox.text:SetText("Disable automatic M+ scoreboard at the end of a run")
    mplusPopupCheckbox:SetChecked(WOWOP_SETTINGS.disableAutoMPlusPopup)
    mplusPopupCheckbox:SetScript("OnClick", function(self)
        WOWOP_SETTINGS.disableAutoMPlusPopup = self:GetChecked()
        if self:GetChecked() then
            PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)
    mplusPopupCheckbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("If checked, the performance summary popup will not automatically show when completing a Mythic+ dungeon.")
        GameTooltip:Show()
    end)
    mplusPopupCheckbox:SetScript("OnLeave", GameTooltip_Hide)
    
    frame:SetScript("OnShow", nil)
end)

-- Register the settings panel
if InterfaceOptions_AddCategory then
    -- Old API (Classic, TBC, etc)
    InterfaceOptions_AddCategory(frame)
else
    -- New API (Dragonflight, etc)
    local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name)
    Settings.RegisterAddOnCategory(category)
    addon.settingsCategory = category
end

-- Register for ADDON_LOADED to initialize settings
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Store panel reference
        addon.settingsPanel = frame
    end
end)

-- Add slash command to open settings
SLASH_WOWOPSETTINGS1 = "/wowop settings"
SlashCmdList["WOWOPSETTINGS"] = function()
    if InterfaceOptions_AddCategory then
        -- Old API
        InterfaceOptionsFrame_OpenToCategory(frame)
        InterfaceOptionsFrame_OpenToCategory(frame) -- Called twice to work around a Blizzard bug
    else
        -- New API
        Settings.OpenToCategory(addon.settingsCategory.ID)
    end
end 