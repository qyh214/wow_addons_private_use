
--functions to create frames, use to keep clean the main files
---@type details
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil

---@class bosswidget : frame
---@field AvatarTexture texture
---@field TimeText fontstring
---@field VerticalLine texture
---@field EncounterInfo df_encounterinfo|nil
---@field EncounterData detailsmythicplus_encounterinfo|nil
---
---@class timesection : frame
---@field TimeText fontstring
---@field VerticalLine texture

---@param parent frame
---@param index number
---@return bosswidget
function addon.CreateBossPortraitTexture(parent, index)
    local newBossWidget = CreateFrame("frame", "$parentBossWidget" .. index, parent, "BackdropTemplate")
    newBossWidget:SetSize(64, 32)
    newBossWidget:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
    newBossWidget:SetBackdropColor(0, 0, 0, 0.1)
    newBossWidget:SetBackdropBorderColor(0, 0, 0, 0)

    local bossAvatar = detailsFramework:CreateImage(newBossWidget, "", 64, 32, "border")
    bossAvatar:SetPoint("bottomleft", newBossWidget, "bottomleft", 0, 0)
    bossAvatar:SetScale(1.0)
    newBossWidget.AvatarTexture = bossAvatar

    local timeText = detailsFramework:CreateLabel(newBossWidget)
    timeText:SetPoint("bottomright", newBossWidget, "bottomright", -2, 0)
    newBossWidget.TimeText = timeText

    local verticalLine = detailsFramework:CreateImage(newBossWidget, "", 1, 25, "overlay")
    verticalLine:SetColorTexture(1, 1, 0, 0.5)
    verticalLine:SetPoint("bottomleft", newBossWidget, "bottomright", 0, 0)
    verticalLine:SetPoint("topleft", timeText, "topright", 2, 0)
    newBossWidget.VerticalLine = verticalLine

    local timeBackground = detailsFramework:CreateImage(newBossWidget, "", 30, 12, "artwork")
    timeBackground:SetColorTexture(0, 0, 0, 0.8)
    timeBackground:SetPoint("topleft", timeText, "topleft", -2, 2)
    timeBackground:SetPoint("bottomright", timeText, "bottomright", 3, 0)

    newBossWidget:SetScript("OnEnter", function (self)
        if (not self.EncounterInfo or not self.EncounterData) then
            return
        end

        local duration = math.floor(self.EncounterData.endTime - self.EncounterData.startTime)

        GameCooltip:Preset(2)
        GameCooltip:AddLine(self.EncounterInfo.name, detailsFramework:IntegerToTimer(duration), nil, nil, nil, nil, 1, "darkorange")
        GameCooltip:AddIcon("worldquest-icon-boss", 1, 1, 16, 16)
        GameCooltip:AddIcon([[Interface\AddOns\Details\images\end_of_mplus.png]], 1, 2, 14, 14, 172/512, 235/512, 84/512, 150/512)
        GameCooltip:SetOwner(self, "bottom", "top", 0, -4)
        GameCooltip:SetOption("TextSize", Details.tooltip.fontsize)
        GameCooltip:SetOption("TextFont",  Details.tooltip.fontface)
        GameCooltip:SetOption("LeftPadding", -3)
        GameCooltip:SetOption("RightPadding", 2)
        GameCooltip:SetOption("LinePadding", -2)
        GameCooltip:SetOption("LineYOffset", 0)
        GameCooltip:SetOption("FixedWidth", false)
        GameCooltip:SetOption("UseTrilinearRight", true)
        GameCooltip:SetOwner(self)
        GameCooltip:Show()
    end)
    newBossWidget:SetScript("OnLeave", function ()
        GameCooltip:Hide()
    end)

    return newBossWidget
end

---@param parent frame
---@param index number
---@return timesection
function addon.CreateTimeSection(parent, index)
    local section = CreateFrame("frame", "$parentTimeSection" .. index, parent, "BackdropTemplate")
    section:SetSize(30, 12)
    section:SetAlpha(0.6)

    local timeText = detailsFramework:CreateLabel(section)
    timeText:ClearAllPoints()
    timeText:SetPoint("bottomleft", section, "bottomleft", 4, 0)
    detailsFramework:SetFontColor(timeText, 1, 1, 1)
    detailsFramework:SetFontSize(timeText, 10)
    section.TimeText = timeText

    local verticalLine = detailsFramework:CreateImage(section, "", 1, 25, "overlay")
    verticalLine:SetColorTexture(1, 1, 1, 0.5)
    verticalLine:SetPoint("bottomright", section, "bottomleft", -3, -2)
    verticalLine:SetPoint("topright", timeText, "topleft", -3, 2)
    section.VerticalLine = verticalLine

    local timeBackground = detailsFramework:CreateImage(section, "", 30, 12, "artwork")
    timeBackground:SetColorTexture(0, 0, 0, 0.5)
    timeBackground:SetPoint("topleft", timeText, "topleft", -3, 2)
    timeBackground:SetPoint("bottomright", timeText, "bottomright", 3, -2)

    return section
end
