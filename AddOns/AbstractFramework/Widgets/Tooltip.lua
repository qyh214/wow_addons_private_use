---@class AbstractFramework
local AF = _G.AbstractFramework

local tt = CreateFrame("GameTooltip", nil, nil, "GameTooltipTemplate")
local SetOwner = tt.SetOwner
local SetItemByID = tt.SetItemByID
local SetSpellByID = tt.SetSpellByID

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
    if type(lines) ~= "table" or #lines == 0 then
        AF.Tooltip:Hide()
        return
    end

    x = AF.ConvertPixelsForRegion(x, AF.Tooltip)
    y = AF.ConvertPixelsForRegion(y, AF.Tooltip)

    AF.Tooltip:ClearLines()

    if anchorOverride[anchor] then
        AF.Tooltip:SetOwner(widget, "ANCHOR_NONE")
        AF.Tooltip:SetPoint(anchorOverride[anchor], widget, anchor, x, y)
    else
        if anchor and not strfind(anchor, "^ANCHOR_") then anchor = "ANCHOR_" .. anchor end
        AF.Tooltip:SetOwner(widget, anchor or "ANCHOR_TOP", x or 0, y or 0)
    end

    local r, g, b = AF.GetColorRGB(widget.accentColor or "accent")

    AF.Tooltip.accentColor = widget.accentColor -- for iconBG color
    AF.Tooltip:SetBackdropBorderColor(r, g, b)

    AF.Tooltip:AddLine(lines[1], r, g, b)

    for i = 2, #lines do
        if type(lines[i]) == "string" then
            AF.Tooltip:AddLine(lines[i], 1, 1, 1, true)
        elseif type(lines[i]) == "table" then
            AF.Tooltip:AddDoubleLine(lines[i][1], lines[i][2], 1, 0.82, 0, 1, 1, 1)
        end
    end

    AF.Tooltip:SetFrameStrata("TOOLTIP")
    -- AF.Tooltip:SetCustomLineSpacing(5)
    AF.Tooltip:SetCustomWordWrapMinWidth(300)
    AF.Tooltip:Show()
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
            AF.Tooltip:Hide()
        end)
    end
end

function AF.ClearTooltips(widget)
    widget._tooltips = nil
end

local tooltips = {}
function AF.HideTooltips()
    for _, tooltip in pairs(tooltips) do
        tooltip:Hide()
    end
end

---------------------------------------------------------------------
-- event related functions
---------------------------------------------------------------------
local strupper = strupper

local function IsRequiredModifierKeyDown(self)
    if not self.requiredModifier then
        return true
    end

    if self.requiredModifier == "ALT" then
        return IsAltKeyDown()
    elseif self.requiredModifier == "CTRL" then
        return IsControlKeyDown()
    elseif self.requiredModifier == "SHIFT" then
        return IsShiftKeyDown()
    -- elseif -- TODO:
    --     return IsMetaKeyDown()
    end
end

local function MODIFIER_STATE_CHANGED(self, event, key, down)
    if not self.requiredModifier then return end
    if not key:find(self.requiredModifier) then return end
    self:SetAlpha(down)
end

local function TOOLTIP_DATA_UPDATE(self)
    if self:IsVisible() then
        -- Interface\FrameXML\GameTooltip.lua GameTooltipDataMixin:RefreshData()
        -- self:RefreshData()
        if self.itemID then
            self:SetItemByID(self.itemID)
        elseif self.spellID then
            self:SetSpellByID(self.spellID)
        end
    end
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local GetItemIconByID = C_Item.GetItemIconByID
local GetSpellTexture = C_Spell.GetSpellTexture
local GetItemQualityByID = C_Item.GetItemQualityByID

local function GameTooltip_OnHide(self)
    self.itemID = nil
    self.spellID = nil
    self.waitingForData = false

    GameTooltip_ClearMoney(self)
    GameTooltip_ClearStatusBars(self)
    GameTooltip_ClearProgressBars(self)
    GameTooltip_ClearWidgetSet(self)
    TooltipComparisonManager:Clear(self)

    GameTooltip_HideBattlePetTooltip()

    if self.ItemTooltip then
        EmbeddedItemTooltip_Hide(self.ItemTooltip)
    end
    self:SetPadding(0, 0, 0, 0)

    self:ClearHandlerInfo()

    GameTooltip_ClearStatusBars(self)
    GameTooltip_ClearStatusBarWatch(self)
end

---@class AF_Tooltip:GameTooltip
local AF_TooltipMixin = {}

function AF_TooltipMixin:SetOwner(owner, ...)
    self:Hide()
    self:SetParent(owner) -- update scale
    SetOwner(self, owner, ...)
    AF.ReBorder(self)
end

function AF_TooltipMixin:UpdatePixels()
    AF.ReBorder(self)
    if self.icon then
        AF.RePoint(self.iconBG)
        AF.RePoint(self.icon)
    end
end

function AF_TooltipMixin:OnHide()
    AF.ClearPoints(self)
    GameTooltip_OnHide(self)

    -- reset border color
    self:SetBackdropBorderColor(AF.GetColorRGB("accent"))

    -- SetX with invalid data may or may not clear the tooltip's contents.
    self:ClearLines()

    if self.icon then
        self.iconBG:Hide()
        self.icon:Hide()
    end

    self.requiredModifier = nil
    self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

function AF_TooltipMixin:OnShow()
    self:SetFrameStrata("TOOLTIP")
    self:UpdatePixels()
end

---@param modifier string "ALT"|"CTRL"|"SHIFT", only accepts single modifier key
function AF_TooltipMixin:RequireModifier(modifier)
    if AF.IsBlank(modifier) then return end
    self.requiredModifier = strupper(modifier)
    self:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
end

function AF_TooltipMixin:SetItemByID(itemID)
    self.itemID = itemID
    self.spellID = nil

    SetItemByID(self, itemID)

    local quality = GetItemQualityByID(itemID)
    if quality then
        self:SetBackdropBorderColor(AF.GetItemQualityColor(quality))
    end

    local icon = GetItemIconByID(itemID)
    if icon then
        if not self.icon then
            self:SetupIcon("TOPRIGHT", "TOPLEFT", -1, 0)
        end
        self.icon:SetTexture(icon)
    end

    self:Show()
    self:SetAlpha(IsRequiredModifierKeyDown(self) and 1 or 0)
end

AF_TooltipMixin.SetItem = AF_TooltipMixin.SetItemByID

function AF_TooltipMixin:SetSpellByID(spellID)
    self.spellID = spellID
    self.itemID = nil

    SetSpellByID(self, spellID)

    local icon = GetSpellTexture(spellID)
    if icon then
        if not self.icon then
            self:SetupIcon("TOPRIGHT", "TOPLEFT", -1, 0)
        end
        self.icon:SetTexture(icon)
    end

    self:Show()
    self:SetAlpha(IsRequiredModifierKeyDown(self) and 1 or 0)
end

AF_TooltipMixin.SetSpell = AF_TooltipMixin.SetSpellByID

function AF_TooltipMixin:SetupIcon(point, relativePoint, x, y)
    if not self.icon then
        local iconBG = self:CreateTexture(nil, "BORDER")
        self.iconBG = iconBG
        AF.SetSize(iconBG, 35, 35)
        iconBG:Hide()

        local icon = self:CreateTexture(nil, "ARTWORK")
        self.icon = icon
        AF.SetOnePixelInside(icon, iconBG)
        AF.ApplyDefaultTexCoord(icon)
        icon:Hide()

        hooksecurefunc(self, "SetBackdropBorderColor", function(self, r, g, b)
            self.iconBG:SetColorTexture(r, g, b)
        end)
    end

    self.iconBG:SetColorTexture(AF.GetColorRGB(self.accentColor or "accent"))

    AF.ClearPoints(self.iconBG)
    AF.SetPoint(self.iconBG, point, self, relativePoint, x, y)
end

function AF_TooltipMixin:ShowIcon()
    if not self.icon then
        self:SetupIcon("TOPRIGHT", "TOPLEFT", -1, 0)
    end
    self.iconBG:Show()
    self.icon:Show()
end

function AF_TooltipMixin:HideIcon()
    if self.icon then
        self.iconBG:Hide()
        self.icon:Hide()
    end
end

---@return AF_Tooltip
local function CreateTooltip(name)
    ---@type AF_Tooltip
    local tooltip = CreateFrame("GameTooltip", name, AF.UIParent, "AFTooltipTemplate,BackdropTemplate")
    -- local tooltip = CreateFrame("GameTooltip", name, AF.UIParent, "SharedTooltipTemplate,BackdropTemplate")
    tinsert(tooltips, tooltip)
    AF.ApplyDefaultBackdrop(tooltip)
    tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    tooltip:SetBackdropBorderColor(AF.GetColorRGB("accent"))

    AF.AddEventHandler(tooltip)
    Mixin(tooltip, AF_BaseWidgetMixin)
    Mixin(tooltip, AF_TooltipMixin)

    if AF.isRetail then
        tooltip:RegisterEvent("TOOLTIP_DATA_UPDATE", TOOLTIP_DATA_UPDATE)
    end

    -- tooltip:SetScript("OnTooltipSetItem", function()
    --     -- color border with item quality color
    --     tooltip:SetBackdropBorderColor(_G[name.."TextLeft1"]:GetTextColor())
    -- end)

    tooltip:SetOnHide(tooltip.OnHide)
    tooltip:SetOnShow(tooltip.OnShow)

    AF.AddToPixelUpdater(tooltip)

    return tooltip
end

AF.RegisterCallback("AF_LOADED", function()
    AF.Tooltip = CreateTooltip("AFTooltip")
    AF.Tooltip2 = CreateTooltip("AFTooltip2")
end, "high")