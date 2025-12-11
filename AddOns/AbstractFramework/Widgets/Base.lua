---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- function
---------------------------------------------------------------------
do
    local f = CreateFrame("Frame")
    -- AF.FrameSetSize = f.SetSize
    -- AF.FrameSetHeight = f.SetHeight
    -- AF.FrameSetWidth = f.SetWidth
    -- AF.FrameGetSize = f.GetSize
    -- AF.FrameGetHeight = f.GetHeight
    -- AF.FrameGetWidth = f.GetWidth
    -- AF.FrameSetPoint = f.SetPoint
    -- AF.FrameSetFrameLevel = f.SetFrameLevel
    AF.FrameShow = f.Show
    AF.FrameHide = f.Hide

    local c = CreateFrame("Cooldown")
    AF.FrameSetCooldown = c.SetCooldown
    AF.FrameSetCooldownDuration = c.SetCooldownDuration

    local t = f:CreateTexture()
    AF.TextureShow = t.Show
    AF.TextureHide = t.Hide
end

---------------------------------------------------------------------
-- OnEnter/OnLeave
---------------------------------------------------------------------
function AF.InvokeOnEnter(region)
    if region.HasScript and region:HasScript("OnEnter") then
        region:GetScript("OnEnter")(region)
    end
end

function AF.InvokeOnLeave(region)
    if region.HasScript and region:HasScript("OnLeave") then
        region:GetScript("OnLeave")(region)
    end
end

---------------------------------------------------------------------
-- AF_BaseWidgetMixin
---------------------------------------------------------------------
---@class AF_BaseWidgetMixin
AF_BaseWidgetMixin = {}

-- OnShow
function AF_BaseWidgetMixin:SetOnShow(func)
    self:SetScript("OnShow", func)
end

function AF_BaseWidgetMixin:HookOnShow(func)
    self:HookScript("OnShow", func)
end

function AF_BaseWidgetMixin:GetOnShow()
    return function()
        self:GetScript("OnShow")(self)
    end
end

function AF_BaseWidgetMixin:InvokeOnShow()
    self:GetScript("OnShow")(self)
end

-- OnHide
function AF_BaseWidgetMixin:SetOnHide(func)
    self:SetScript("OnHide", func)
end

function AF_BaseWidgetMixin:HookOnHide(func)
    self:HookScript("OnHide", func)
end

function AF_BaseWidgetMixin:GetOnHide()
    return function()
        self:GetScript("OnHide")(self)
    end
end

function AF_BaseWidgetMixin:InvokeOnHide()
    self:GetScript("OnHide")(self)
end

-- OnEnter
function AF_BaseWidgetMixin:SetOnEnter(func)
    self:SetScript("OnEnter", func)
end

function AF_BaseWidgetMixin:HookOnEnter(func)
    self:HookScript("OnEnter", func)
end

function AF_BaseWidgetMixin:GetOnEnter()
    return function()
        self:GetScript("OnEnter")(self)
    end
end

function AF_BaseWidgetMixin:InvokeOnEnter()
    self:GetScript("OnEnter")(self)
end

-- OnLeave
function AF_BaseWidgetMixin:SetOnLeave(func)
    self:SetScript("OnLeave", func)
end

function AF_BaseWidgetMixin:HookOnLeave(func)
    self:HookScript("OnLeave", func)
end

function AF_BaseWidgetMixin:GetOnLeave()
    return function()
        self:GetScript("OnLeave")(self)
    end
end

function AF_BaseWidgetMixin:InvokeOnLeave()
    self:GetScript("OnLeave")(self)
end

-- OnClick
function AF_BaseWidgetMixin:SetOnMouseDown(func)
    self:SetScript("OnMouseDown", func)
end

function AF_BaseWidgetMixin:HookOnMouseDown(func)
    self:HookScript("OnMouseDown", func)
end

function AF_BaseWidgetMixin:GetOnMouseDown()
    return function()
        self:GetScript("OnMouseDown")(self)
    end
end

-- OnMouseUp
function AF_BaseWidgetMixin:SetOnMouseUp(func)
    self:SetScript("OnMouseUp", func)
end

function AF_BaseWidgetMixin:HookOnMouseUp(func)
    self:HookScript("OnMouseUp", func)
end

function AF_BaseWidgetMixin:GetOnMouseUp()
    return function()
        self:GetScript("OnMouseUp")(self)
    end
end

-- OnMouseWheel
function AF_BaseWidgetMixin:SetOnMouseWheel(func)
    self:SetScript("OnMouseWheel", func)
end

function AF_BaseWidgetMixin:HookOnMouseWheel(func)
    self:HookScript("OnMouseWheel", func)
end

function AF_BaseWidgetMixin:GetOnMouseWheel()
    return function()
        self:GetScript("OnMouseWheel")(self)
    end
end

-- OnLoad
function AF_BaseWidgetMixin:SetOnLoad(func)
    self:SetScript("OnLoad", func)
end

function AF_BaseWidgetMixin:HookOnLoad(func)
    self:HookScript("OnLoad", func)
end

function AF_BaseWidgetMixin:GetOnLoad()
    return function()
        self:GetScript("OnLoad")(self)
    end
end

-- OnEnable
function AF_BaseWidgetMixin:SetOnEnable(func)
    if self:HasScript("OnEnable") then
        self:SetScript("OnEnable", func)
    end
end

function AF_BaseWidgetMixin:HookOnEnable(func)
    if self:HasScript("OnEnable") then
        self:HookScript("OnEnable", func)
    end
end

function AF_BaseWidgetMixin:GetOnEnable()
    if self:HasScript("OnEnable") then
        return function()
            self:GetScript("OnEnable")(self)
        end
    end
end

-- OnDisable
function AF_BaseWidgetMixin:SetOnDisable(func)
    if self:HasScript("OnDisable") then
        self:SetScript("OnDisable", func)
    end
end

function AF_BaseWidgetMixin:HookOnDisable(func)
    if self:HasScript("OnDisable") then
        self:HookScript("OnDisable", func)
    end
end

function AF_BaseWidgetMixin:GetOnDisable()
    if self:HasScript("OnDisable") then
        return function()
            self:GetScript("OnDisable")(self)
        end
    end
end

-- OnUpdate
function AF_BaseWidgetMixin:SetOnUpdate(func)
    if self:HasScript("OnUpdate") then
        self:SetScript("OnUpdate", func)
    end
end

function AF_BaseWidgetMixin:HookOnUpdate(func)
    if self:HasScript("OnUpdate") then
        self:HookScript("OnUpdate", func)
    end
end

function AF_BaseWidgetMixin:GetOnUpdate()
    if self:HasScript("OnUpdate") then
        return function()
            self:GetScript("OnUpdate")(self)
        end
    end
end

-- OnSizeChanged
function AF_BaseWidgetMixin:SetOnSizeChanged(func)
    if self:HasScript("OnSizeChanged") then
        self:SetScript("OnSizeChanged", func)
    end
end

function AF_BaseWidgetMixin:HookOnSizeChanged(func)
    if self:HasScript("OnSizeChanged") then
        self:HookScript("OnSizeChanged", func)
    end
end

function AF_BaseWidgetMixin:GetOnSizeChanged()
    if self:HasScript("OnSizeChanged") then
        return function()
            self:GetScript("OnSizeChanged")(self)
        end
    end
end

-- BlockMouse
---@param block boolean
--- this function uses EnableMouse and SetScript("OnMouseWheel") to block mouse events
function AF_BaseWidgetMixin:BlockMouse(block)
    self:EnableMouse(block)
    -- NOTE: EnableMouseWheel dose not work
    if block then
        self:SetScript("OnMouseWheel", AF.noop)
    else
        self:SetScript("OnMouseWheel", nil)
    end
end

function AF_BaseWidgetMixin:SyncEnableDisableWith(frame)
    if not frame then return end
    frame:HookOnEnable(function()
        AF.SetEnabled(true, self)
    end)
    frame:HookOnDisable(function()
        AF.SetEnabled(false, self)
    end)
end

function AF_BaseWidgetMixin:Toggle()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

---------------------------------------------------------------------
-- enable / disable
---------------------------------------------------------------------
function AF.SetEnabled(isEnabled, ...)
    if isEnabled == nil then isEnabled = false end

    for i = 1, select("#", ...) do
        local w = select(i, ...)
        if w:IsObjectType("FontString") then
            if isEnabled then
                w:SetTextColor(AF.GetColorRGB("white"))
            else
                w:SetTextColor(AF.GetColorRGB("disabled"))
            end
        elseif w:IsObjectType("Texture") then
            if isEnabled then
                w:SetDesaturated(false)
            else
                w:SetDesaturated(true)
            end
        elseif w.SetEnabled then
            w:SetEnabled(isEnabled)
        elseif isEnabled then
            w:Show()
        else
            w:Hide()
        end
    end
end

function AF.Enable(...)
    AF.SetEnabled(true, ...)
end

function AF.Disable(...)
    AF.SetEnabled(false, ...)
end

---------------------------------------------------------------------
-- show / hide
---------------------------------------------------------------------
function AF.Show(...)
    for i = 1, select("#", ...) do
        local w = select(i, ...)
        w:Show()
    end
end

function AF.Hide(...)
    for i = 1, select("#", ...) do
        local w = select(i, ...)
        w:Hide()
    end
end

function AF.Toggle(...)
    for i = 1, select("#", ...) do
        local w = select(i, ...)
        if w:IsShown() then
            w:Hide()
        else
            w:Show()
        end
    end
end

---------------------------------------------------------------------
-- check
---------------------------------------------------------------------
function AF.SetChecked(checked, ...)
    for i = 1, select("#", ...) do
        local w = select(i, ...)
        if w.SetChecked then
            w:SetChecked(checked)
        end
    end
end

---------------------------------------------------------------------
-- frame level relative to parent
---------------------------------------------------------------------
---@param frame Frame
---@param level number|nil default 0
---@param relativeTo Frame|nil default parent
function AF.SetFrameLevel(frame, level, relativeTo)
    level = level or 0
    relativeTo = relativeTo or frame:GetParent()
    frame:SetFrameStrata(relativeTo:GetFrameStrata())
    frame:SetFrameLevel(AF.Clamp(relativeTo:GetFrameLevel() + level, 0, 10000))
end

---------------------------------------------------------------------
-- backdrops
---------------------------------------------------------------------
function AF.ClearBackdrop(frame)
    if frame.ClearBackdrop then
        frame:ClearBackdrop()
    end
end

function AF.ApplyDefaultBackdrop(frame, borderSize)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    local n = borderSize or 1
    AF.SetBackdrop(frame, {bgFile = AF.GetPlainTexture(), edgeFile = AF.GetPlainTexture(), edgeSize = n, insets = {left = n, right = n, top = n, bottom = n}})
end

function AF.ApplyDefaultBackdrop_NoBackground(frame, borderSize)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    AF.SetBackdrop(frame, {edgeFile = AF.GetPlainTexture(), edgeSize = borderSize or 1})
    frame:SetBackdropBorderColor(AF.GetColorRGB("border"))
end

function AF.ApplyDefaultBackdrop_NoBorder(frame)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    AF.SetBackdrop(frame, {bgFile = AF.GetPlainTexture()})
    frame:SetBackdropColor(AF.GetColorRGB("background"))
end

function AF.ApplyDefaultBackdropColors(frame)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end
    frame:SetBackdropColor(AF.GetColorRGB("background"))
    frame:SetBackdropBorderColor(AF.GetColorRGB("border"))
end

---@param frame Frame
---@param color string|table|nil color name defined in Color.lua or color table
---@param borderColor string|table|nil color name defined in Color.lua or color table
---@param borderSize number|nil size of the border, default 1
function AF.ApplyDefaultBackdropWithColors(frame, color, borderColor, borderSize)
    color = color or "background"
    borderColor = borderColor or "border"

    AF.ApplyDefaultBackdrop(frame, borderSize)
    if type(color) == "string" then
        frame:SetBackdropColor(AF.GetColorRGB(color))
    else
        frame:SetBackdropColor(unpack(color))
    end
    if type(borderColor) == "string" then
        frame:SetBackdropBorderColor(AF.GetColorRGB(borderColor))
    else
        frame:SetBackdropBorderColor(unpack(borderColor))
    end
end

---------------------------------------------------------------------
-- drag
---------------------------------------------------------------------
---@param frame Frame draggable frame
---@param target Frame|nil if set then the target will be moved instead of the frame
---@param notUserPlaced boolean|nil
---@param onDragStart function|nil
---@param onDragStop function|nil
function AF.SetDraggable(frame, target, notUserPlaced, onDragStart, onDragStop)
    target = target or frame
    target:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMouseClickEnabled(true)
    frame:SetScript("OnDragStart", function()
        if onDragStart then onDragStart(target) end
        target:StartMoving(true) -- set to true to prevent weird behavior?
        if notUserPlaced then target:SetUserPlaced(false) end
    end)
    frame:SetScript("OnDragStop", function()
        target:StopMovingOrSizing()
        if onDragStop then onDragStop(target) end
    end)
end

---------------------------------------------------------------------
-- attach to cursor
---------------------------------------------------------------------
local GetCursorPosition = GetCursorPosition

---@param frame Frame
---@param anchorPoint string|nil e.g. "CENTER", "TOPLEFT", etc.
---@param offsetX number|nil
---@param offsetY number|nil
function AF.AttachToCursor(frame, anchorPoint, offsetX, offsetY)
    assert(frame and frame.HasScript and frame:HasScript("OnUpdate"), "AF.AttachToCursor: frame must have 'OnUpdate' script.")

    anchorPoint = anchorPoint or "CENTER"
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    local mouseX, mouseY = GetCursorPosition()
    local lastX, lastY

    local effectiveScale = frame:GetEffectiveScale()
    local startX = mouseX / effectiveScale
    local startY = mouseY / effectiveScale

    frame:SetScript("OnUpdate", function()
        local newMouseX, newMouseY = GetCursorPosition()
        if newMouseX == lastX and newMouseY == lastY then return end

        lastX = newMouseX
        lastY = newMouseY

        local newX = startX + (newMouseX - mouseX) / effectiveScale

        local newY = startY + (newMouseY - mouseY) / effectiveScale

        frame:ClearAllPoints()
        frame:SetPoint(anchorPoint, AF.UIParent, "BOTTOMLEFT", newX + offsetX, newY + offsetY)
    end)

    frame:Show()
end

function AF.DetachFromCursor(frame)
    if frame and frame.HasScript and frame:HasScript("OnUpdate") then
        frame:SetScript("OnUpdate", nil)
        frame:ClearAllPoints()
    end
end

---------------------------------------------------------------------
-- mouse focus
---------------------------------------------------------------------
function AF.GetMouseFocus()
    if GetMouseFoci then
        return GetMouseFoci()[1]
    else
        return GetMouseFocus()
    end
end

---------------------------------------------------------------------
-- toggle protected frames
---------------------------------------------------------------------
local frames = {}

local function ToggleProtectedFrames()
    for frame, action in next, frames do
        if action == "show" then
            frame:Show()
        elseif action == "hide" then
            frame:Hide()
        end
        frames[frame] = nil
    end
    AF.UnregisterCallback("AF_COMBAT_LEAVE", ToggleProtectedFrames)
end

function AF.ShowProtectedFrame(frame)
    if not frame then return end
    if InCombatLockdown() then
        frames[frame] = "show"
        AF.RegisterCallback("AF_COMBAT_LEAVE", ToggleProtectedFrames)
    else
        frame:Show()
    end
end

function AF.HideProtectedFrame(frame)
    if not frame then return end
    if InCombatLockdown() then
        frames[frame] = "hide"
        AF.RegisterCallback("AF_COMBAT_LEAVE", ToggleProtectedFrames)
    else
        frame:Hide()
    end
end

function AF.SetProtectedFrameShown(frame, shown)
    if shown then
        AF.ShowProtectedFrame(frame)
    else
        AF.HideProtectedFrame(frame)
    end
end