---@class AbstractFramework
local AF = _G.AbstractFramework

local pool

---@class AF_HelpTip:AF_BorderedFrame
local AF_HelpTipMixin = {}

---@private
function AF_HelpTipMixin:OnShow()
    self.elapsed = 0
    self:SetFrameStrata("TOOLTIP")
    self:Raise()
end

---@private
function AF_HelpTipMixin:Close()
    if self.callback then
        self.callback(self.widget)
    end
    pool:Release(self)
end

---@private
function AF_HelpTipMixin:Next()
    if self.nextTip then
        local next = self.nextTip
        self:Close()
        AF.ShowHelpTip(next)
    end
end

function AF_HelpTipMixin:SetText(text)
    self.text:SetText(text)
end

---------------------------------------------------------------------
-- create
---------------------------------------------------------------------
local function HelpTipBuilder()
    local tip = AF.CreateBorderedFrame(AF.UIParent, nil, nil, nil, "none", "gold")
    -- tip:SetFrameStrata("TOOLTIP")
    -- tip:SetToplevel(true)
    tip:SetClampedToScreen(true)
    tip:SetIgnoreParentAlpha(true)
    tip:Hide()

    Mixin(tip, AF_HelpTipMixin)

    -- glow
    AF.ShowNormalGlow(tip, 3, "#dbb800")

    -- bg
    local bg = AF.CreateGradientTexture(tip, "VERTICAL", "#010000", "#3a2f00", nil, "BACKGROUND")
    tip.bg = bg
    bg:SetAllPoints()

    -- arrow
    local arrow = AF.CreateTexture(tip, AF.GetIcon("ArrowRight2"), "gold", "BORDER")
    tip.arrow = arrow

    -- update size & check widget visibility
    tip:SetOnShow(tip.OnShow)
    tip.elapsed = 0
    tip:SetOnUpdate(function(self, elapsed)
        self:SetHeight(self.text:GetHeight() + 25)
        if not self.widget or not self.widget:IsVisible() then
            self:Hide()
        end
    end)

    -- close
    local close = AF.CreateIconButton(tip, AF.GetIcon("Close1"), 14, 14, 1, "gold")
    tip.close = close
    AF.SetPoint(close, "TOPRIGHT")

    close:HookOnMouseDown(function()
        if tip.closeHoldDuration == 0 then return end
        if tip.timer:IsPaused() then
            tip.timer:Resume()
        else
            tip.timer:SetCooldownDuration(tip.closeHoldDuration)
        end
    end)

    close:HookOnMouseUp(function()
        if tip.closeHoldDuration == 0 then return end
        tip.timer:Pause()
    end)

    close:SetOnClick(function()
        if tip.closeHoldDuration == 0 then
            tip:Close()
        end
    end)

    -- timer
    local timer = AF.CreateCooldown(tip, nil, AF.GetIcon("Circle2"), "gold", true)
    tip.timer = timer
    AF.SetPoint(timer, "RIGHT", close, "LEFT")
    AF.SetSize(timer, 10, 10)
    timer:SetOnCooldownDone(function()
        tip:Close()
    end)

    -- next
    local next = AF.CreateIconButton(tip, AF.GetIcon("ArrowDoubleDown"), 14, 14, 1, "gold")
    tip.next = next
    AF.SetPoint(next, "BOTTOMRIGHT")
    next:Hide()
    next:SetOnClick(function()
        tip:Next()
    end)

    -- text
    local text = AF.CreateFontString(tip)
    tip.text = text
    AF.SetPoint(text, "TOPLEFT", 12, -12)
    AF.SetPoint(text, "TOPRIGHT", -12, 12)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("TOP")
    text:SetSpacing(5)
    text:SetWordWrap(true)

    return tip
end

local function Release(_, tip)
    AF.ClearPoints(tip)
    tip:Hide()
    tip.widget = nil
    tip.callback = nil
    tip.nextTip = nil
    tip.elapsed = 0
end

pool = AF.CreateObjectPool(HelpTipBuilder, Release)

---------------------------------------------------------------------
-- hook OnMouseDown
---------------------------------------------------------------------
local function OnMouseDown(widget)
    local helpTip = widget._helptip
    if helpTip.widget == widget and helpTip:IsShown() then
        helpTip:Close()
    end
end

local function HookOnMouseDown(widget, tip)
    tip.widget = widget
    if not widget._helptip then
        widget:HookScript("OnMouseDown", OnMouseDown)
    end
    widget._helptip = tip
end

---------------------------------------------------------------------
-- single
---------------------------------------------------------------------
local pos = {
    LEFT = {"RIGHT", -12, 0, "ArrowRight2", 8, 16, {0.34375, 0.65625, 0.1875, 0.828125}},
    RIGHT = {"LEFT", 12, 0, "ArrowLeft2", 8, 16, {0.328125, 0.640625, 0.1875, 0.828125}},
    TOP = {"BOTTOM", 0, 12, "ArrowDown2", 16, 8, {0.171875, 0.8125, 0.390625, 0.703125}},
    BOTTOM = {"TOP", 0, -12, "ArrowUp2", 16, 8, {0.171875, 0.8125, 0.3125, 0.625}},
}

-- local info = {
--     widget = (Frame),
--     position = ("LEFT" | "RIGHT" | "TOP" | "BOTTOM"),
--     x = (number),
--     y = (number),
--     text = (string),
--     width = (number), -- default is 200
--     glow = (boolean), -- show glow on widget, default is false
--     closeHoldDuration = (number), -- seconds to hold closeButton to hide the tip, default is 0.5, 0 means no hold
--     callback = (function), -- invoked when onMouseDown the widget or close the tip
-- }

---@param info table
---@return AF_HelpTip tip
function AF.ShowHelpTip(info)
    assert(type(info) == "table", "Usage: ShowHelpTip({widget=Frame, position=\"LEFT\"|\"RIGHT\"|\"TOP\"|\"BOTTOM\", text=string, width=number, glow=boolean, closeHoldDuration=number, callback=function})")

    local widget = info.widget
    local position = info.position
    local text = info.text
    local width = info.width
    local glow = info.glow
    local closeHoldDuration = info.closeHoldDuration
    local callback = info.callback
    local nextTip = info._nextTip

    if widget._helptip and widget._helptip.widget == widget and widget._helptip:IsShown() then
        return
    end

    position = position:upper()
    local anchor, x, y, icon, w, h, coords = AF.Unpack7(pos[position])

    -- tip
    local tip = pool:Acquire()
    HookOnMouseDown(widget, tip)
    -- tip:SetParent(widget)
    AF.SetWidth(tip, width or 200)
    tip:SetText(text)

    -- position
    AF.ClearPoints(tip)
    AF.SetPoint(tip, anchor, widget, position, info.x or x, info.y or y)

    -- arrow
    AF.SetSize(tip.arrow, w, h)
    tip.arrow:SetTexture(AF.GetIcon(icon))
    tip.arrow:ClearAllPoints()
    tip.arrow:SetPoint(position, tip, anchor)
    tip.arrow:SetTexCoord(AF.Unpack4(coords))

    -- timer
    tip.timer:Clear()
    tip.closeHoldDuration = closeHoldDuration or 0.5

    -- glow
    if glow then
        AF.ShowCalloutGlow(tip, true)
        AF.SetOutside(tip.calloutGlow, widget, 4)
    else
        AF.HideCalloutGlow(tip)
    end

    --next
    if nextTip then
        tip.nextTip = nextTip
        tip.next:Show()
    else
        tip.next:Hide()
    end

    -- callback
    tip.callback = callback

    if widget:IsVisible() then
        tip:Show()
    elseif not widget._helpTipHelper then
        widget._helpTipHelper = CreateFrame("Frame", nil, widget)
        widget._helpTipHelper:SetScript("OnShow", function(self)
            if widget._helptip and widget._helptip.widget == widget then
                widget._helptip:Show()
            end
        end)
    end

    return tip
end

---------------------------------------------------------------------
-- group
---------------------------------------------------------------------
---@param tips table
function AF.ShowHelpTipGroup(tips)
    local n = #tips
    for i, info in ipairs(tips) do
        local info = tips[i]
        if i < n then
            info._nextTip = tips[i + 1]
        end
    end
    AF.ShowHelpTip(tips[1])
end

---------------------------------------------------------------------
-- hide all
---------------------------------------------------------------------
function AF.HideAllHelpTips()
    pool:ReleaseAll()
end