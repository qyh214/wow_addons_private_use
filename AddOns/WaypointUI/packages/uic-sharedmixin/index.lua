local env = select(2, ...)
local Utils_Blizzard = env.modules:Import("packages\\utils\\blizzard")
local UICSharedMixin = env.modules:New("packages\\uic-sharedmixin")

local CreateFromMixins = CreateFromMixins
local tinsert = table.insert

local function TriggerHooks(hooks, ...)
    for i = 1, #hooks do
        hooks[i](...)
    end
end

do -- Button
    local ButtonMixin = {}
    UICSharedMixin.ButtonMixin = ButtonMixin

    function ButtonMixin:InitButton()
        self.isEnabled = true
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

        TriggerHooks(self.onMouseEnterHooks, self)
    end

    function ButtonMixin:OnLeave()
        if not self:IsEnabled() then return end

        self:SetHighlighted(false)
        self:UpdateButtonState()

        TriggerHooks(self.onMouseLeaveHooks, self)
    end

    function ButtonMixin:OnMouseDown(button)
        if not self:IsEnabled() then return end

        self:SetPushed(self:IsEnabled() and true or false)
        self:UpdateButtonState()

        TriggerHooks(self.onMouseDownHooks, self, button)
    end

    function ButtonMixin:OnMouseUp(button)
        if not self:IsEnabled() then return end

        self:SetPushed(false)
        self:UpdateButtonState()

        TriggerHooks(self.onMouseUpHooks, self, button)

        if self:IsMouseOver() then
            self:OnClick()
        end
    end

    function ButtonMixin:OnClick(button)
        if not self:IsEnabled() or button == "RightButton" then return end
        TriggerHooks(self.onClickHooks, self, button)
        if self.clickFunc then self.clickFunc(self, button) end
    end

    function ButtonMixin:SetOnClick(func)
        self.clickFunc = func
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
        self.isEnabled = true
        TriggerHooks(self.onEnableChangeHooks, self, true)
        TriggerHooks(self.onStateChangeHooks, self, nil)
    end

    function ButtonMixin:Disable()
        self.isEnabled = false
        self.state = "NORMAL"
        TriggerHooks(self.onEnableChangeHooks, self, false)
        TriggerHooks(self.onStateChangeHooks, self, nil)
    end

    function ButtonMixin:SetEnabled(isEnabled)
        if isEnabled then self:Enable() else self:Disable() end
    end

    function ButtonMixin:IsEnabled()
        return self.isEnabled
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
            TriggerHooks(self.onStateChangeHooks, self, buttonState)
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
end

do -- Selection Menu Remote
    local SelectionMenuRemoteMixin = {}
    UICSharedMixin.SelectionMenuRemoteMixin = SelectionMenuRemoteMixin

    function SelectionMenuRemoteMixin:InitSelectionMenuRemoteMixin()
        self.selectionMenu = nil
        self.data = nil
        self.value = 1
        self.onValueChangedHooks = {}
        self:HookMouseUp(self.Remote_OnClick)
    end

    function SelectionMenuRemoteMixin:Remote_OnClick()
        local selectionMenu = self.selectionMenu
        local data = self.data
        local value = self.value

        if selectionMenu:IsOpen() and selectionMenu:GetRoot() == self then
            selectionMenu:Close()
        else
            selectionMenu:Open(value, data, self.SetValue, nil, "TOP", self, "BOTTOM", 0, -6, self)
        end
    end

    function SelectionMenuRemoteMixin:HookValueChanged(func, replace)
        if replace then wipe(self.onValueChangedHooks) end
        tinsert(self.onValueChangedHooks, func)
    end

    function SelectionMenuRemoteMixin:SetSelectionMenu(selectionMenu)
        self.selectionMenu = selectionMenu
    end

    function SelectionMenuRemoteMixin:GetSelectionMenu()
        return self.selectionMenu
    end

    function SelectionMenuRemoteMixin:GetValue()
        return self.value
    end

    function SelectionMenuRemoteMixin:SetValue(index)
        index = math.min(index, #self.data)

        self.value = index
        self:SetText(self.data[index])

        TriggerHooks(self.onValueChangedHooks, self, self.value)
    end

    function SelectionMenuRemoteMixin:SetData(data)
        self.data = data
        self:SetValue(self.value)
    end

    function SelectionMenuRemoteMixin:GetData()
        return self.data
    end
end

do -- Check Button
    local CheckButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
    UICSharedMixin.CheckButtonMixin = CheckButtonMixin

    function CheckButtonMixin:InitCheckButton()
        self:InitButton()
        self.isChecked = false
        self.onCheckHooks = {}
    end

    function CheckButtonMixin:HookCheck(func, replace)
        if replace then wipe(self.onCheckHooks) end
        tinsert(self.onCheckHooks, func)
    end

    function CheckButtonMixin:SetChecked(checked)
        if self.isChecked ~= checked then
            self.isChecked = checked
            TriggerHooks(self.onCheckHooks, self, self.isChecked)
        end
    end

    function CheckButtonMixin:GetChecked()
        return self.isChecked
    end

    function CheckButtonMixin:Toggle()
        self:SetChecked(not self:GetChecked())
    end
end

do -- Range
    local RangeMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
    UICSharedMixin.RangeMixin = RangeMixin

    function RangeMixin:InitRange()
        self:InitButton()
        self:HookEnableChange(self.OnEnableChange)
    end

    function RangeMixin:OnEnableChange(isEnabled)
        self:SetEnabledSlider(isEnabled)
    end
end

do -- Scroll Bar
    local ScrollBarMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
    UICSharedMixin.ScrollBarMixin = ScrollBarMixin

    function ScrollBarMixin:InitScrollBar()
        self:InitButton()
        self:HookEnableChange(self.OnEnableChange)
    end

    function ScrollBarMixin:OnEnableChange(isEnabled)
        self:SetEnabledSlider(isEnabled)
    end
end

do -- Input
    local InputMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
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
        self.inputFrame:SetEnabled(self:IsEnabled())
    end

    function InputMixin:HookFocusChange(func, replace)
        if replace then wipe(self.onFocusChangeHooks) end
        tinsert(self.onFocusChangeHooks, func)
    end

    function InputMixin:SetFocused(focused)
        if self.focused ~= focused then
            self.focused = focused
            TriggerHooks(self.onFocusChangeHooks, self, self.focused)
        end
    end

    function InputMixin:IsFocused()
        return self.focused
    end

    function InputMixin:RegisterMouseEventsWithComponents(hitRect, input)
        hitRect:AddOnEnter(function() self:OnEnter() end)
        hitRect:AddOnLeave(function() self:OnLeave() end)
        hitRect:AddOnMouseUp(function() input:SetFocus() end)
        input:HookEvent("OnFocusGained", function() self:OnFocusGained() end)
        input:HookEvent("OnFocusLost", function() self:OnFocusLost() end)

        self:HookEnableChange(self.OnEnableChange)

        self.hitRectFrame = hitRect
        self.inputFrame = input
    end
end

do -- Color Input
    local ColorInputMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
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
        Utils_Blizzard.ShowColorPicker(self.color, self.onColorChanged, self.onColorChanged, self.onColorChanged)
    end

    function ColorInputMixin:HookColorChange(func, replace)
        if replace then wipe(self.onColorChangeHooks) end
        tinsert(self.onColorChangeHooks, func)
    end

    function ColorInputMixin:SetColor(r, g, b)
        local cR, cG, cB = nil, nil, nil

        if r and not g and not b then
            cR = r.r or 1
            cG = r.g or 1
            cB = r.b or 1
        else
            cR = r or 1
            cG = g or 1
            cB = b or 1
        end

        self.color.r = cR
        self.color.g = cG
        self.color.b = cB

        TriggerHooks(self.onColorChangeHooks, self, self.color)
    end

    function ColorInputMixin:GetColor()
        return self.color
    end
end
