---@class AddonPrivate
local Private = select(2, ...)

---@class UXUI
---@field utils UXUtils
local uxUI = {
    utils = nil,
    ---@type Frame|BackdropTemplate|table
    copyBox = nil,
}
Private.UXUI = uxUI

local const = Private.constants
local components = Private.Components

function uxUI:Init()
    self.utils = Private.UXUtils
    self.L = Private.L
end

function uxUI:CreateCopyBox()
    local f = CreateFrame("Frame", nil, UIParent, "PortraitFrameTemplate")
    ButtonFrameTemplate_HidePortrait(f)
    self.copyBox = f

    local textBox = components.TextBox:CreateFrame(f, {
        anchors = {
            {"TOPLEFT", 30, -25}
        },
        width = 250,
        height = 30,
    })
    f.textBox = textBox

    f:SetSize(300, 60)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:Hide()
end

function uxUI:CopyURLToClipboard(url)
    if not url or url == "" then
        return
    end
    if not self.copyBox then
        self:CreateCopyBox()
    end
    local box = self.copyBox
    box:Show()
    box.textBox:SetText(url)
    box.textBox.editBox:SetFocus()
end

---@return fun(panel:Frame|BackdropTemplate|table, data:table)
function uxUI:GetSettingsPanelInitializer()
    return function(panel)
        if panel.isInitialized then
            return
        end
        panel.isInitialized = true
        NineSliceUtil.ApplyUniqueCornersLayout(panel, "OptionsFrame")

        local fullWidth = panel:GetWidth() - 20
        local widthPerButton = (fullWidth - 20) / #(const.SOCIALS)
        local height = panel:GetHeight() - 20
        for index, social in ipairs(const.SOCIALS) do
            local button = CreateFrame("Frame", nil, panel)
            local label = components.Label:CreateFrame(button, {
                justifyH = "CENTER",
            })
            label.frame:SetAllPoints()
            button:SetWidth(widthPerButton)
            button:SetHeight(height)
            button:SetPoint("TOPLEFT", 10 + (index - 1) * (widthPerButton + 10), -10)
            label:SetText(("|T%s:16|t %s"):format(social.ICON, social.NAME))

            button:SetScript("OnMouseDown", function()
                if social.URL then
                    self:CopyURLToClipboard(social.URL)
                end
            end)
        end
    end
end
