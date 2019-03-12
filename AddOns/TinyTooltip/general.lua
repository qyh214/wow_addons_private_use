
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local DEAD = DEAD

local addon = TinyTooltip

BigTipDB = {}

local function ColorStatusBar(self, value)
    if (addon.db.general.statusbarColor == "auto") then
        local unit = "mouseover"
        local focus = GetMouseFocus()
        if (focus and focus.unit) then
            unit = focus.unit
        end
        local r, g, b
        if (UnitIsPlayer(unit)) then
            r, g, b = GetClassColor(select(2,UnitClass(unit)))
        else
            r, g, b = GameTooltip_UnitColor(unit)
            if (g == 0.6) then g = 0.9 end
            if (r==1 and g==1 and b==1) then r, g, b = 0, 0.9, 0.1 end
        end
        self:SetStatusBarColor(r, g, b)
    elseif (addon.db.general.statusbarColor == "smooth") then
        HealthBar_OnValueChanged(self, value, true)
    end
end

LibEvent:attachEvent("VARIABLES_LOADED", function()
    --CloseButton
    if (ItemRefCloseButton and not IsAddOnLoaded("ElvUI")) then
        ItemRefCloseButton:SetSize(14, 14)
        ItemRefCloseButton:SetPoint("TOPRIGHT", -4, -4)
        ItemRefCloseButton:SetNormalTexture("Interface\\\Buttons\\UI-StopButton")
        ItemRefCloseButton:SetPushedTexture("Interface\\\Buttons\\UI-StopButton")
        ItemRefCloseButton:GetNormalTexture():SetVertexColor(0.9, 0.6, 0)
    end
    --StatusBar
    local bar = GameTooltipStatusBar
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(1, 1, 1)
    bar.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    bar.TextString = bar:CreateFontString(nil, "OVERLAY")
    bar.TextString:SetPoint("CENTER")
    bar.TextString:SetFont(NumberFontNormal:GetFont(), 11, "THINOUTLINE")
    bar.capNumericDisplay = true
    bar.lockShow = 1
    bar:HookScript("OnValueChanged", function(self, hp)
        if (hp <= 0) then
            local min, max = self:GetMinMaxValues()
            self.TextString:SetFormattedText("|cff999999%s|r |cffffcc33<%s>|r", AbbreviateLargeNumbers(max), DEAD)
        else
            TextStatusBar_UpdateTextString(self)
        end
        ColorStatusBar(self, hp)
    end)
    bar:HookScript("OnShow", function(self)
        if (addon.db.general.statusbarHeight == 0) then
            self:Hide()
        end
    end)
    --Variable
    addon.db = addon:MergeVariable(addon.db, BigTipDB)
    LibEvent:trigger("tooltip:variables:loaded")
    --Init
    LibEvent:trigger("tooltip.style.font.header", GameTooltip, addon.db.general.headerFont, addon.db.general.headerFontSize, addon.db.general.headerFontFlag)
    LibEvent:trigger("tooltip.style.font.body", GameTooltip, addon.db.general.bodyFont, addon.db.general.bodyFontSize, addon.db.general.bodyFontFlag)
    LibEvent:trigger("tooltip.statusbar.height", addon.db.general.statusbarHeight)
    LibEvent:trigger("tooltip.statusbar.text", addon.db.general.statusbarText)
    LibEvent:trigger("tooltip.statusbar.font", addon.db.general.statusbarFont, addon.db.general.statusbarFontSize, addon.db.general.statusbarFontFlag)
    LibEvent:trigger("tooltip.statusbar.texture", addon.db.general.statusbarTexture)
    for _, tip in ipairs(addon.tooltips) do
        LibEvent:trigger("tooltip.style.init", tip)
        LibEvent:trigger("tooltip.scale", tip, addon.db.general.scale)
        LibEvent:trigger("tooltip.style.mask", tip, addon.db.general.mask)
        LibEvent:trigger("tooltip.style.bgfile", tip, addon.db.general.bgfile)
        LibEvent:trigger("tooltip.style.border.corner", tip, addon.db.general.borderCorner)
        LibEvent:trigger("tooltip.style.border.size", tip, addon.db.general.borderSize)
        LibEvent:trigger("tooltip.style.border.color", tip, unpack(addon.db.general.borderColor))
        LibEvent:trigger("tooltip.style.background", tip, unpack(addon.db.general.background))
    end
    --ShadowText
    GameTooltipHeaderText:SetShadowOffset(1, -1)
    GameTooltipHeaderText:SetShadowColor(0, 0, 0, 0.9)
    GameTooltipText:SetShadowOffset(1, -1)
    GameTooltipText:SetShadowColor(0, 0, 0, 0.9)
    Tooltip_Small:SetShadowOffset(1, -1)
    Tooltip_Small:SetShadowColor(0, 0, 0, 0.9)
end)

LibEvent:attachTrigger("tooltip:cleared, tooltip:hide", function(self, tip)
    LibEvent:trigger("tooltip.style.border.color", tip, unpack(addon.db.general.borderColor))
    LibEvent:trigger("tooltip.style.background", tip, unpack(addon.db.general.background))
    tip:SetBackdrop(nil)
end)

LibEvent:attachTrigger("tooltip:show", function(self, tip)
    if (tip ~= GameTooltip) then return end
    LibEvent:trigger("tooltip.statusbar.position", addon.db.general.statusbarPosition, addon.db.general.statusbarOffsetX, addon.db.general.statusbarOffsetY)
    local w = GameTooltipStatusBar.TextString:GetWidth() + 10
    if (GameTooltipStatusBar:IsShown() and w > tip:GetWidth()) then
        tip:SetMinimumWidth(w+2)
        tip:Show()
    end
end)
