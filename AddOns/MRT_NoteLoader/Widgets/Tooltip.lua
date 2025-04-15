local _, MRT_NL = ...
local W = MRT_NL.widgets

-----------------------------------------
-- Tooltip
-----------------------------------------
local function CreateTooltip(name, hasIcon)
    local tooltip = CreateFrame("GameTooltip", name, UIParent, "MRTNLTooltipTemplate,BackdropTemplate")
    tooltip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    tooltip:SetBackdropBorderColor(W:GetAccentColorRGB())
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    if hasIcon then
        local iconBG = tooltip:CreateTexture(nil, "BACKGROUND")
        tooltip.iconBG = iconBG
        iconBG:SetSize(35, 35)
        iconBG:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -1, 0)
        iconBG:SetColorTexture(W:GetAccentColorRGB())
        iconBG:Hide()
        
        local icon = tooltip:CreateTexture(nil, "ARTWORK")
        tooltip.icon = icon
        P:Point(icon, "TOPLEFT", iconBG, 1, -1)
        P:Point(icon, "BOTTOMRIGHT", iconBG, -1, 1)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:Hide()

        hooksecurefunc(tooltip, "SetSpellByID", function(self, id, tex)
            if tex then
                iconBG:Show()
                icon:SetTexture(tex)
                icon:Show()
            end
        end)
    end

    tooltip:SetScript("OnTooltipCleared", function()
        -- reset border color
        tooltip:SetBackdropBorderColor(W:GetAccentColorRGB())
    end)

    tooltip:SetScript("OnHide", function()
        -- SetX with invalid data may or may not clear the tooltip's contents.
        tooltip:ClearLines()

        if hasIcon then
            tooltip.iconBG:Hide()
            tooltip.icon:Hide()
        end
    end)
end

CreateTooltip("MRT_NL_Tooltip")