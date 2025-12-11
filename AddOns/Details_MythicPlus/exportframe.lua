---@type details
---@diagnostic disable-next-line: undefined-field
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil
local L = detailsFramework.Language.GetLanguageTable(addonName)

---@class exportframe : frame
---@field TextBox df_luaeditor

function addon.ShowExportFrame(exportText)
    local exportFrame = addon.GetOrCreateExportFrame()
    exportFrame:Show()
    exportFrame.TextBox:Show()

    exportFrame.TextBox.editbox:ClearFocus()
    exportFrame.TextBox:SetText("")

    C_Timer.After(0, function()
        exportFrame.TextBox.editbox:SetFocus()
        exportFrame.TextBox:SetText(exportText)
        exportFrame.TextBox.editbox:HighlightText(0)

        C_Timer.After(0, function()
            exportFrame.TextBox.editbox:HighlightText(0)
        end)
    end)
end

function addon.GetOrCreateExportFrame()
    --create a frame parented to uiparent, attach it to the center of the screen, it'll have 600x400 size, dialog strata. this frame have a title bar with the text "Export M+ Run".
    --a text entry box where it'll show the export data (text).
    --a button in the bottom right corner to close the panel.

    if (_G["DetailsMythicPlusExportFrame"]) then
        return _G["DetailsMythicPlusExportFrame"]
    end

    ---@type exportframe
    local exportFrame = CreateFrame("Frame", "DetailsMythicPlusExportFrame", UIParent)
    exportFrame:SetSize(600, 400)
    exportFrame:SetPoint("center", UIParent, "center", 0, 0)
    exportFrame:SetFrameStrata("FULLSCREEN")
    exportFrame:Show()

    detailsFramework:ApplyStandardBackdrop(exportFrame)

    local title = exportFrame:CreateFontString(nil, "overlay", "GameFontNormalLarge")
    title:SetPoint("top", exportFrame, "top", 0, -5)
    title:SetText("Export M+ Run (JSON)")

    local luaEditFrame = detailsFramework:NewSpecialLuaEditorEntry(exportFrame, 1, 1, "editbox", "$parentEntry", true)
    luaEditFrame:SetPoint("topleft", exportFrame, "topleft", 2, -24)
    luaEditFrame:SetPoint("bottomright", exportFrame, "bottomright", -20, 26)
    exportFrame.TextBox = luaEditFrame
    detailsFramework:ApplyStandardBackdrop(luaEditFrame)
    detailsFramework:ReskinSlider(luaEditFrame.scroll)

    exportFrame.TextBox.editbox:SetScript("OnKeyDown", function(self, key)
        if (IsControlKeyDown() and (key == "c" or key == "C")) then
            C_Timer.After(0, function()
                exportFrame:Hide()
            end)
        end
    end)

    local closeButton = CreateFrame("Button", nil, exportFrame, "UIPanelButtonTemplate")
    closeButton:SetSize(100, 22)
    closeButton:SetPoint("BOTTOMRIGHT", -2, 2)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function()
        exportFrame:Hide()
    end)

    local copyMessage = exportFrame:CreateFontString(nil, "overlay", "GameFontNormal")
    copyMessage:SetPoint("bottom", exportFrame, "bottom", 0, 5)
    copyMessage:SetText("press ctrl+c to copy")

    exportFrame:SetScript("OnHide", function()
        exportFrame.TextBox.editbox:ClearFocus()
        exportFrame.TextBox:SetText("")
        exportFrame.TextBox:Hide()
    end)

    return exportFrame
end
