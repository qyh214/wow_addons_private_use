---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- show / hide
---------------------------------------------------------------------
local anchorOverride = {
    ["LEFT"] = "RIGHT",
    ["RIGHT"] = "LEFT",
    ["BOTTOMLEFT"] = "TOPLEFT",
    ["BOTTOMRIGHT"] = "TOPRIGHT",
}

---@param widget Frame
---@param anchor string
---@param x number
---@param y number
---@param lines string[]
function AF.ShowTooltips(widget, anchor, x, y, lines)
    local tooltip = _G["AFTooltip"]

    if type(lines) ~= "table" or #lines == 0 then
        tooltip:Hide()
        return
    end

    tooltip:SetParent(widget)
    AF.ReBorder(tooltip)

    x = AF.ConvertPixelsForRegion(x, tooltip)
    y = AF.ConvertPixelsForRegion(y, tooltip)

    tooltip:ClearLines()

    if anchorOverride[anchor] then
        tooltip:SetOwner(widget, "ANCHOR_NONE")
        tooltip:SetPoint(anchorOverride[anchor], widget, anchor, x, y)
    else
        if anchor and not strfind(anchor, "^ANCHOR_") then anchor = "ANCHOR_" .. anchor end
        tooltip:SetOwner(widget, anchor or "ANCHOR_TOP", x or 0, y or 0)
    end

    local r, g, b = AF.GetColorRGB("accent")
    tooltip:AddLine(lines[1], r, g, b)
    for i = 2, #lines do
        if type(lines[i]) == "string" then
            tooltip:AddLine(lines[i], 1, 1, 1, true)
        elseif type(lines[i]) == "table" then
            tooltip:AddDoubleLine(lines[i][1], lines[i][2], 1, 0.82, 0, 1, 1, 1)
        end
    end

    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetToplevel(true)
    -- tooltip:SetCustomLineSpacing(5)
    tooltip:SetCustomWordWrapMinWidth(300)
    tooltip:Show()
end

---@param widget Frame
---@param anchor string
---@param x number
---@param y number
---@param ... string
function AF.SetTooltips(widget, anchor, x, y, ...)
    if type(select(1, ...)) == "table" then
        widget._tooltips = ...
    else
        widget._tooltips = {...}
    end
    widget._tooltipsAnchor = anchor
    widget._tooltipsX = x
    widget._tooltipsY = y

    if not widget._tooltipsInited then
        widget._tooltipsInited = true

        widget:HookScript("OnEnter", function()
            AF.ShowTooltips(widget, anchor, x, y, widget._tooltips)
        end)
        widget:HookScript("OnLeave", function()
            _G["AFTooltip"]:Hide()
        end)
    end
end

function AF.ClearTooltips(widget)
    widget._tooltips = nil
end

function AF.HideTooltips()
    _G["AFTooltip"]:Hide()
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function CreateTooltip(name, hasIcon)
    local tooltip = CreateFrame("GameTooltip", name, AF.UIParent, "AFTooltipTemplate,BackdropTemplate")
    -- local tooltip = CreateFrame("GameTooltip", name, AF.UIParent, "SharedTooltipTemplate,BackdropTemplate")
    AF.ApplyDefaultBackdrop(tooltip)
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    tooltip:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    tooltip:SetOwner(AF.UIParent, "ANCHOR_NONE")

    if hasIcon then
        local iconBG = tooltip:CreateTexture(nil, "BACKGROUND")
        tooltip.iconBG = iconBG
        AF.SetSize(iconBG, 35, 35)
        AF.SetPoint(iconBG, "TOPRIGHT", tooltip, "TOPLEFT", -1, 0)
        iconBG:SetColorTexture(AF.GetColorRGB("accent"))
        iconBG:Hide()

        local icon = tooltip:CreateTexture(nil, "ARTWORK")
        tooltip.icon = icon
        AF.SetPoint(icon, "TOPLEFT", iconBG, 1, -1)
        AF.SetPoint(icon, "BOTTOMRIGHT", iconBG, -1, 1)
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

    if AF.isRetail then
        tooltip:RegisterEvent("TOOLTIP_DATA_UPDATE")
        tooltip:SetScript("OnEvent", function()
            if tooltip:IsVisible() then
                -- Interface\FrameXML\GameTooltip.lua GameTooltipDataMixin:RefreshData()
                tooltip:RefreshData()
            end
        end)
    end

    -- tooltip:SetScript("OnTooltipSetItem", function()
    --     -- color border with item quality color
    --     tooltip:SetBackdropBorderColor(_G[name.."TextLeft1"]:GetTextColor())
    -- end)

    tooltip:SetScript("OnHide", function()
        tooltip:SetPadding(0, 0, 0, 0)

        -- reset border color
        tooltip:SetBackdropBorderColor(AF.GetColorRGB("accent"))

        -- SetX with invalid data may or may not clear the tooltip's contents.
        tooltip:ClearLines()

        if hasIcon then
            tooltip.iconBG:Hide()
            tooltip.icon:Hide()
        end
    end)

    function tooltip:UpdatePixels()
        AF.ReBorder(self)
        if hasIcon then
            AF.RePoint(self.iconBG)
            AF.RePoint(self.icon)
        end
    end

    AF.AddToPixelUpdater(tooltip)
end

CreateTooltip("AFTooltip")
CreateTooltip("AFSpellTooltip", true)