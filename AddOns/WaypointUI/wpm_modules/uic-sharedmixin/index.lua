local env              = select(2, ...)
local MixinUtil        = env.WPM:Import("wpm_modules/mixin-util")
local Utils_Blizzard   = env.WPM:Import("wpm_modules/utils/blizzard")

local CreateFromMixins = MixinUtil.CreateFromMixins
local tinsert          = table.insert

local UICSharedMixin   = env.WPM:New("wpm_modules/uic-sharedmixin")


-- Shared Util
--------------------------------

local function triggerHooks(hooks, ...)
    for i = 1, #hooks do
        hooks[i](...)
    end
end


-- Button
--------------------------------

local ButtonMixin = {}
UICSharedMixin.ButtonMixin = ButtonMixin

function ButtonMixin:InitButton()
    self.enabled = true
    self.state = "NORMAL"
    self.isHighlighted = false
    self.isPushed = false

    self.clickFunc = nil
    self.onEnableChangeHooks = {}
    self.onClickHooks = {}
    self.onMouseDownHooks = {}
    self.onMouseUpHooks = {}
    self.onMouseEnterHooks = {}
    self.onMouseLeaveHooks = {}
    self.onStateChangeHooks = {}
end

function ButtonMixin:RegisterMouseEvents(blockMouseEvents)
    if blockMouseEvents == false then
        self:AwaitSetPropagateMouseClicks(true)
        self:AwaitSetPropagateMouseMotion(true)
    end

    self:HookScript("OnEnter", self.OnEnter)
    self:HookScript("OnLeave", self.OnLeave)
    self:HookScript("OnMouseDown", self.OnMouseDown)
    self:HookScript("OnMouseUp", self.OnMouseUp)
end

function ButtonMixin:OnEnter()
    if not self:IsEnabled() then return end

    self:SetHighlighted(self:IsEnabled() and true or false)
    self:UpdateButtonState()

    triggerHooks(self.onMouseEnterHooks, self)
end

function ButtonMixin:OnLeave()
    if not self:IsEnabled() then return end

    self:SetHighlighted(false)
    self:UpdateButtonState()

    triggerHooks(self.onMouseLeaveHooks, self)
end

function ButtonMixin:OnMouseDown()
    if not self:IsEnabled() then return end

    self:SetPushed(self:IsEnabled() and true or false)
    self:UpdateButtonState()

    triggerHooks(self.onMouseDownHooks, self)
end

function ButtonMixin:OnMouseUp()
    if not self:IsEnabled() then return end

    self:SetPushed(false)
    self:UpdateButtonState()

    triggerHooks(self.onMouseUpHooks, self)

    if self:IsMouseOver() then
        self:Click()
    end
end

function ButtonMixin:SetClick(func)
    self.clickFunc = func
end

function ButtonMixin:Click()
    if not self:IsEnabled() then return end
    triggerHooks(self.onClickHooks, self)
    if self.clickFunc then self.clickFunc(self) end
end

function ButtonMixin:HookEnableChange(func, replace)
    if replace then wipe(self.onEnableChangeHooks) end
    tinsert(self.onEnableChangeHooks, func)
end

function ButtonMixin:HookClick(func, replace)
    if replace then wipe(self.onClickHooks) end
    tinsert(self.onClickHooks, func)
end

function ButtonMixin:HookMouseDown(func, replace)
    if replace then wipe(self.onMouseDownHooks) end
    tinsert(self.onMouseDownHooks, func)
end

function ButtonMixin:HookMouseUp(func, replace)
    if replace then wipe(self.onMouseUpHooks) end
    tinsert(self.onMouseUpHooks, func)
end

function ButtonMixin:HookMouseEnter(func, replace)
    if replace then wipe(self.onMouseEnterHooks) end
    tinsert(self.onMouseEnterHooks, func)
end

function ButtonMixin:HookMouseLeave(func, replace)
    if replace then wipe(self.onMouseLeaveHooks) end
    tinsert(self.onMouseLeaveHooks, func)
end

function ButtonMixin:HookButtonStateChange(func, replace)
    if replace then wipe(self.onStateChangeHooks) end
    tinsert(self.onStateChangeHooks, func)
end

function ButtonMixin:Enable()
    self.enabled = true
    triggerHooks(self.onEnableChangeHooks, self, true)
end

function ButtonMixin:Disable()
    self.enabled = false
    self.state = "NORMAL"
    triggerHooks(self.onEnableChangeHooks, self, false)
end

function ButtonMixin:SetEnabled(enabled)
    if enabled then self:Enable() else self:Disable() end
end

function ButtonMixin:IsEnabled()
    return self.enabled
end

function ButtonMixin:SetHighlighted(highlighted)
    self.isHighlighted = highlighted
end

function ButtonMixin:SetPushed(pushed)
    self.isPushed = pushed
end

function ButtonMixin:IsHighlighted()
    return self.isHighlighted
end

function ButtonMixin:IsPushed()
    return self.isPushed
end

function ButtonMixin:SetButtonState(buttonState)
    assert(buttonState == "NORMAL" or buttonState == "PUSHED" or buttonState == "HIGHLIGHTED", "Invalid button state!")

    if self.state ~= buttonState then
        self.state = buttonState
        triggerHooks(self.onStateChangeHooks, self, buttonState)
    end
end

function ButtonMixin:UpdateButtonState()
    if self:IsPushed() then
        self:SetButtonState("PUSHED")
    elseif self:IsHighlighted() then
        self:SetButtonState("HIGHLIGHTED")
    else
        self:SetButtonState("NORMAL")
    end
end

function ButtonMixin:GetButtonState()
    return self.state
end


-- Selection Menu Remote
--------------------------------

local SelectionMenuRemote = {}
UICSharedMixin.SelectionMenuRemote = SelectionMenuRemote

function SelectionMenuRemote:InitSelectionMenuRemote()
    self.selectionMenu = nil
    self.data = nil
    self.value = 1

    self.onValueChangedHooks = {}

    self:HookMouseUp(self.OnClick)
end

function SelectionMenuRemote:OnClick()
    local selectionMenu = self.selectionMenu
    local data = self.data
    local value = self.value

    if selectionMenu:IsOpen() and selectionMenu:GetRoot() == self then
        selectionMenu:Close()
    else
        selectionMenu:Open(value, data, self.SetValue, nil, "TOP", self, "BOTTOM", 0, -3, self)
    end
end

function SelectionMenuRemote:HookValueChanged(func, replace)
    if replace then wipe(self.onValueChangedHooks) end
    tinsert(self.onValueChangedHooks, func)
end

function SelectionMenuRemote:SetSelectionMenu(selectionMenu)
    self.selectionMenu = selectionMenu
end

function SelectionMenuRemote:GetSelectionMenu()
    return self.selectionMenu
end

function SelectionMenuRemote:GetValue()
    return self.value
end

function SelectionMenuRemote:SetValue(index)
    -- Clamp index
    if index > #self.data then
        index = #self.data
    end

    self.value = index
    self:SetText(self.data[index])

    triggerHooks(self.onValueChangedHooks, self, self.value)
end

function SelectionMenuRemote:SetData(data)
    self.data = data
    self:SetValue(self.value)
end

function SelectionMenuRemote:GetData()
    return self.data
end


-- Check Button
--------------------------------

local CheckButtonMixin = CreateFromMixins(ButtonMixin)
UICSharedMixin.CheckButtonMixin = CheckButtonMixin

function CheckButtonMixin:InitCheckButton()
    self:InitButton()

    self.checked = false

    self.onCheckHooks = {}
end

function CheckButtonMixin:HookCheck(func, replace)
    if replace then wipe(self.onCheckHooks) end
    tinsert(self.onCheckHooks, func)
end

function CheckButtonMixin:SetChecked(checked)
    if self.checked ~= checked then
        self.checked = checked
        triggerHooks(self.onCheckHooks, self, self.checked)
    end
end

function CheckButtonMixin:GetChecked()
    return self.checked
end

function CheckButtonMixin:Toggle()
    self:SetChecked(not self:GetChecked())
end


-- Range
--------------------------------

local RangeMixin = CreateFromMixins(ButtonMixin)
UICSharedMixin.RangeMixin = RangeMixin

function RangeMixin:InitRange()
    self:InitButton()
    self:HookEnableChange(self.OnEnableChange)
end

function RangeMixin:OnEnableChange(enabled)
    self:SetEnabledSlider(enabled)
end


-- Scroll Bar
--------------------------------

local ScrollBarMixin = CreateFromMixins(ButtonMixin)
UICSharedMixin.ScrollBarMixin = ScrollBarMixin

function ScrollBarMixin:InitScrollBar()
    self:InitButton()
    self:HookEnableChange(self.OnEnableChange)
end

function ScrollBarMixin:OnEnableChange(enabled)
    self:SetEnabledSlider(enabled)
end


-- Input
--------------------------------

local InputMixin = CreateFromMixins(ButtonMixin)
UICSharedMixin.InputMixin = InputMixin

function InputMixin:InitInput()
    self:InitButton()

    self.focused = false

    self.onFocusChangeHooks = {}
end

function InputMixin:OnFocusGained()
    self:SetFocused(true)
end

function InputMixin:OnFocusLost()
    self:SetFocused(false)
end

function InputMixin:OnEnableChange()
    if not self.inputFrame then return end

    -- Assuming `inputFrame` is a refernece to the TextBox object
    self.inputFrame:SetEnabled(self:IsEnabled())
end

function InputMixin:HookFocusChange(func, replace)
    if replace then wipe(self.onFocusChangeHooks) end
    tinsert(self.onFocusChangeHooks, func)
end

function InputMixin:SetFocused(focused)
    if self.focused ~= focused then
        self.focused = focused
        triggerHooks(self.onFocusChangeHooks, self, self.focused)
    end
end

function InputMixin:IsFocused()
    return self.focused
end

function InputMixin:RegisterMouseEventsWithComponents(hitbox, input)
    hitbox:AddOnEnter(function() self:OnEnter() end)
    hitbox:AddOnLeave(function() self:OnLeave() end)
    hitbox:AddOnMouseUp(function() input:SetFocus() end)
    input:HookEvent("OnFocusGained", function() self:OnFocusGained() end)
    input:HookEvent("OnFocusLost", function() self:OnFocusLost() end)

    self:HookEnableChange(self.OnEnableChange)

    self.hitboxFrame = hitbox
    self.inputFrame = input
end


-- Color Input
--------------------------------

local ColorInputMixin = CreateFromMixins(ButtonMixin)
UICSharedMixin.ColorInputMixin = ColorInputMixin

local function ColorPicker_OnColorChanged(self)
    local r, g, b = nil, nil, nil
    r, g, b = ColorPickerFrame:GetColorRGB()
    self:SetColor(r, g, b)
end

function ColorInputMixin:InitColorInput()
    self:InitButton()

    self.color = {
        r = 1,
        g = 1,
        b = 1
    }

    self.onColorChangeHooks = {}
    self.onConfirmHooks = {}

    self.onColorChanged = function() ColorPicker_OnColorChanged(self) end
end

function ColorInputMixin:OnClick()
    Utils_Blizzard.ShowColorPicker(self.color,
                                   self.onColorChanged,
                                   self.onColorChanged,
                                   self.onColorChanged
    )
end

function ColorInputMixin:HookColorChange(func, replace)
    if replace then wipe(self.onColorChangeHooks) end
    tinsert(self.onColorChangeHooks, func)
end

function ColorInputMixin:SetColor(r, g, b)
    local cR, cG, cB = nil, nil, nil

    -- If only `r` is provided, assume it's a rgba color table
    if r and not g and not b then
        cR = r.r or 1
        cG = r.g or 1
        cB = r.b or 1
    else
        cR = r or 1
        cG = g or 1
        cB = b or 1
    end

    -- Store colors into the existing table
    self.color.r = cR
    self.color.g = cG
    self.color.b = cB

    -- Trigger hooks
    triggerHooks(self.onColorChangeHooks, self, self.color)
end

function ColorInputMixin:GetColor()
    return self.color
end
