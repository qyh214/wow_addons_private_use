local _, MazeHelper = ...;
MazeHelper.E = {};

local E, M = MazeHelper.E, MazeHelper.M;

E.CreateTooltip = function(frame, tooltip, anchor)
    if not frame then
        return;
    end

    frame.tooltip = tooltip;

    frame:HookScript('OnEnter', function(self)
        if not self.tooltip then
            return;
        end

        GameTooltip:SetOwner(self, anchor or 'ANCHOR_RIGHT');
        GameTooltip:AddLine(self.tooltip, 1, 0.85, 0, true);
        GameTooltip:Show();
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

E.CreateRoundedCheckButton = function(parent)
    local b = CreateFrame('CheckButton', nil, parent);

    b:SetNormalTexture(M.Icons.TEXTURE);
    b:GetNormalTexture():SetTexCoord(unpack(M.Icons.COORDS.CHECKBUTTON_NORMAL));
    b:SetCheckedTexture(M.Icons.TEXTURE);
    b:GetCheckedTexture():SetTexCoord(unpack(M.Icons.COORDS.CHECKBUTTON_CHECKED));
    b:SetHighlightTexture(M.Icons.TEXTURE);
    b:GetHighlightTexture():SetTexCoord(unpack(M.Icons.COORDS.CHECKBUTTON_NORMAL));

    b:SetHitRectInsets(0, 0, 0, 0);

    b.Label = b:CreateFontString(nil, 'ARTWORK', 'GameFontNormal');
    PixelUtil.SetPoint(b.Label, 'LEFT', b, 'RIGHT', 6, 0);
    PixelUtil.SetHeight(b.Label, 12);
    b.Label:SetJustifyH('LEFT');

    b.SetLabel = function(self, label)
        self.Label:SetText(label);
        self:SetHitRectInsets(0, -1 * math.max(100, self.Label:GetStringWidth() + 8), 0, 0);
        PixelUtil.SetWidth(self.Label, math.min(238, self.Label:GetStringWidth() + 8));
    end

    b.SetTooltip = function(self, tooltip)
        self.tooltip = tooltip;
    end

    b.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
        PixelUtil.SetPoint(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels);
    end

    b.SetSize = function(self, width, height)
        PixelUtil.SetSize(self, width, height);
    end

    hooksecurefunc(b, 'SetEnabled', function(self, state)
        if state then
            self.Label:SetFontObject('GameFontNormal');
            self:GetNormalTexture():SetDesaturated(false);
            self:GetCheckedTexture():SetDesaturated(false);
        else
            self.Label:SetFontObject('GameFontDisable');
            self:GetNormalTexture():SetDesaturated(true);
            self:GetCheckedTexture():SetDesaturated(true);
        end
    end);

    E.CreateTooltip(b);

    b:SetSize(26, 26);

    return b;
end

E.CreateCheckButton = function(name, parent)
    local b = CreateFrame('CheckButton', name, parent, 'ChatConfigCheckButtonTemplate');
    b:SetHitRectInsets(0, 0, 0, 0);

    b.Label = _G[b:GetName() .. 'Text'];
    PixelUtil.SetPoint(b.Label, 'LEFT', b, 'RIGHT', 4, 0);

    b.SetLabel = function(self, label)
        self.Label:SetText(label);
        self:SetHitRectInsets(0, -(self.Label:GetStringWidth() + 8), 0, 0);
    end

    b.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
        PixelUtil.SetPoint(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels);
    end

    b.SetTooltip = function(self, tooltip)
        self.tooltip = tooltip;
    end

    E.CreateTooltip(b);

    hooksecurefunc(b, 'SetEnabled', function(self, state)
        if state then
            self.Label:SetTextColor(1, 1, 1);
        else
            self.Label:SetTextColor(0.35, 0.35, 0.35);
        end
    end);

    hooksecurefunc(b, 'Enable', function(self)
        self.Label:SetTextColor(1, 1, 1);
    end);

    hooksecurefunc(b, 'Disable', function(self)
        self.Label:SetTextColor(0.35, 0.35, 0.35);
    end);

    return b;
end

E.CreateScrollFrame = function(parent, scrollStep)
    local scrollChild = CreateFrame('Frame', nil, parent);
    scrollChild.Data = {};

    local scrollArea = CreateFrame('ScrollFrame', '$parentScrollFrame', parent, 'UIPanelScrollFrameTemplate');
    PixelUtil.SetPoint(scrollArea, 'TOPLEFT', parent, 'TOPLEFT', 0, -8);
    PixelUtil.SetPoint(scrollArea, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -27, 20);

    scrollArea:SetScrollChild(scrollChild);

    PixelUtil.SetSize(scrollChild, scrollArea:GetWidth(), scrollArea:GetHeight() - scrollStep);

    scrollArea.scrollBarHideable = true;
    scrollArea.noScrollThumb     = false;
    scrollArea.noScrollBar       = true;

    local scrollbarName    = scrollArea:GetName();
    local scrollBar        = _G[scrollbarName .. 'ScrollBar'];
    local scrollUpButton   = _G[scrollbarName .. 'ScrollBarScrollUpButton'];
    local scrollDownButton = _G[scrollbarName .. 'ScrollBarScrollDownButton'];
    local scrollThumb      = _G[scrollbarName .. 'ScrollBarThumbTexture'];

    PixelUtil.SetPoint(scrollBar, 'TOPLEFT', scrollArea, 'TOPRIGHT', 6, -20);
    PixelUtil.SetPoint(scrollBar, 'BOTTOMLEFT', scrollArea, 'BOTTOMRIGHT', 6, 24);

    scrollBar.scrollStep = scrollStep;

    scrollUpButton:SetSize(1, 1);
    scrollUpButton:SetAlpha(0);

    scrollDownButton:SetSize(1, 1);
    scrollDownButton:SetAlpha(0);

    scrollThumb:SetTexture('Interface\\Buttons\\WHITE8x8');
    scrollThumb:SetSize(2, 64);
    scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);

    scrollBar.isMouseIsDown = false;
    scrollBar.isMouseIsOver = false;

    scrollBar:HookScript('OnEnter', function(self)
        self.isMouseIsOver = true;
        C_Timer.After(0.1, function()
            if scrollBar:IsMouseOver() then
                scrollThumb:SetSize(6, 64)
                scrollThumb:SetVertexColor(1, 0.85, 0, 1);
            end
        end);
    end);

    scrollBar:HookScript('OnLeave', function(self)
        self.isMouseIsOver = false;
        if not self.isMouseIsDown then
            C_Timer.After(0.25, function()
                if not scrollBar:IsMouseOver() then
                    scrollThumb:SetSize(2, 64);
                    scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);
                end
            end);
        end
    end);

    scrollBar:HookScript('OnMouseDown', function(self)
        self.isMouseIsDown = true;
        scrollThumb:SetSize(6, 64)
        scrollThumb:SetVertexColor(1, 0.85, 0, 1);
    end);

    scrollBar:HookScript('OnMouseUp', function(self)
        self.isMouseIsDown = false;
        if not self.isMouseIsOver then
            C_Timer.After(0.25, function()
                scrollThumb:SetSize(2, 64);
                scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);
            end);
        end
    end);

    scrollBar:EnableMouse(true);
    scrollBar:HookScript('OnMouseWheel', function(self, value)
        ScrollFrameTemplate_OnMouseWheel(self, value, self);
    end);

    ScrollFrame_OnLoad(scrollArea);

    return scrollChild, scrollArea;
end

E.CreateSmoothShowing = function(frame)
    if not frame then
        return;
    end

    local AnimationFadeInGroup = frame:CreateAnimationGroup();
    local fadeIn = AnimationFadeInGroup:CreateAnimation('Alpha');
    fadeIn:SetDuration(0.3);
    fadeIn:SetFromAlpha(0);
    fadeIn:SetToAlpha(1);
    fadeIn:SetStartDelay(0);

    frame:HookScript('OnShow', function()
        AnimationFadeInGroup:Play();
    end);

    local AnimationFadeOutGroup = frame:CreateAnimationGroup();
    local fadeOut = AnimationFadeOutGroup:CreateAnimation('Alpha');
    fadeOut:SetDuration(0.2);
    fadeOut:SetFromAlpha(1);
    fadeOut:SetToAlpha(0);
    fadeOut:SetStartDelay(0);

    AnimationFadeOutGroup:SetScript('OnFinished', function()
        frame:HideDefault();
    end);

    frame.HideDefault = frame.Hide;
    frame.Hide = function()
        AnimationFadeOutGroup:Play();
    end

    frame.SetShown = function(self, state)
        if not state then
            if self:IsShown() then
                self:Hide();
            end
        else
            if not self:IsShown() then
                self:Show();
            end
        end
    end

    frame.AnimIn  = AnimationFadeInGroup;
    frame.AnimOut = AnimationFadeOutGroup;
end

local function SliderRound(val, minVal, valueStep)
    return math.floor((val - minVal) / valueStep + 0.5) * valueStep + minVal;
end

do
    local SLIDER_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\UI-SliderBar-Background',
        edgeFile = M.SLIDER_BORDER,
        tile     = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets   = { left = 3, right = 3, top = 6, bottom = 6 },
    };

    local EDITBOX_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { top = 1, left = 1, bottom = 1, right = 1 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    E.CreateSlider = function(name, parent)
        local slider  = CreateFrame('Slider', 'MazeHelper_Settings_' .. name .. 'Slider', parent, 'OptionsSliderTemplate, BackdropTemplate');
        local editbox = CreateFrame('EditBox', '$parentEditBox', slider, 'InputBoxTemplate');

        slider:SetOrientation('HORIZONTAL');

        PixelUtil.SetPoint(slider.Low, 'TOPLEFT', slider, 'BOTTOMLEFT', 1, -1);
        PixelUtil.SetPoint(slider.High, 'TOPRIGHT', slider, 'BOTTOMRIGHT', -1, -1);
        PixelUtil.SetPoint(slider.Text, 'BOTTOMLEFT', slider, 'TOPLEFT', 1, 0);

        slider.Text:SetFontObject(GameFontNormal);

        slider.Thumb:SetSize(26, 26);
        slider.Thumb:SetTexture(M.Icons.TEXTURE);
        slider.Thumb:SetTexCoord(unpack(M.Icons.COORDS.CIRCLE_NORMAL));

        slider:HookScript('OnEnter', function(self)
            self.Thumb:SetTexCoord(unpack(M.Icons.COORDS.CIRCLE_HIGHLIGHT));
        end);

        slider:HookScript('OnLeave', function(self)
            self.Thumb:SetTexCoord(unpack(M.Icons.COORDS.CIRCLE_NORMAL));
        end);

        slider:SetBackdrop(SLIDER_BACKDROP);

        slider.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
            PixelUtil.SetPoint(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels);
        end

        hooksecurefunc(slider, 'SetValue', function(self, value)
            self.currentValue = value;
        end);

        slider.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        slider.SetLabel = function(self, label)
            self.Text:SetText(label);
        end

        slider.SetValues = function(self, currentValue, minValue, maxValue, stepValue)
            self.currentValue = currentValue or 0;
            self.minValue     = minValue or 0;
            self.maxValue     = maxValue or 100;
            self.stepValue    = stepValue or 1;

            self:SetMinMaxValues(self.minValue, self.maxValue);
            self:SetStepsPerPage(self.stepValue);
            self:SetValueStep(self.stepValue);
            self:SetValue(SliderRound(self.currentValue, self.minValue, self.stepValue));

            self.Low:SetText(self.minValue);
            self.High:SetText(self.maxValue);

            self.editbox:SetText(SliderRound(self.currentValue, self.minValue, self.stepValue));
        end

        slider:SetScript('OnValueChanged', function(self, value)
            value = SliderRound(value, self.minValue, self.stepValue);
            self.currentValue = value;

            self.editbox:SetText(self.currentValue);

            if slider:IsDraggingThumb() and self.editbox:HasFocus() then
                self.editbox:ClearFocus();
            end

            if self.OnValueChangedCallback then
                self:OnValueChangedCallback(self.currentValue);
            end
        end);

        slider:SetScript('OnMouseUp', function(self)
            if self.OnMouseUpCallback then
                self:OnMouseUpCallback(self.currentValue);
            end
        end);

        editbox:ClearAllPoints();
        PixelUtil.SetPoint(editbox, 'TOP', slider, 'BOTTOM', 4, 2);
        PixelUtil.SetSize(editbox, 40, 30);

        editbox:SetFontObject(GameFontHighlight);
        editbox:SetAutoFocus(false);

        editbox.Left:Hide();
        editbox.Middle:Hide();
        editbox.Right:Hide();

        editbox.Background = CreateFrame('Frame', '$parentBackground', editbox, 'BackdropTemplate');
        PixelUtil.SetPoint(editbox.Background, 'TOPLEFT', editbox, 'TOPLEFT', -5, -4);
        PixelUtil.SetSize(editbox.Background, 41, 21);
        editbox.Background:SetFrameLevel(editbox:GetFrameLevel() - 1);
        editbox.Background:SetBackdrop(EDITBOX_BACKDROP);

        editbox.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);
        editbox.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        editbox:SetScript('OnEnterPressed', function(self)
            self.lastValue = nil;
            self:ClearFocus();

            local value = tonumber(self:GetText());
            if value then
                value = math.min(value, self:GetParent().maxValue);
                value = math.max(value, self:GetParent().minValue);
            else
                value = self:GetParent().currentValue;
            end

            self:GetParent():SetValue(SliderRound(value, self:GetParent().minValue, self:GetParent().stepValue));
            self:SetText(value);

            if self:GetParent().OnValueChangedCallback then
                self:GetParent():OnValueChangedCallback(value);
            end

            if self:GetParent().OnMouseUpCallback then
                self:GetParent():OnMouseUpCallback(value);
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        end);

        editbox:SetScript('OnEditFocusGained', function(self)
            self.isFocused = true;
            self.lastValue = tonumber(self:GetNumber());
            self:HighlightText();
            self.Background:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);
        end);

        editbox:SetScript('OnEditFocusLost', function(self)
            self.isFocused = false;
            if self.lastValue then
                self:SetText(SliderRound(self.lastValue, self:GetParent().minValue, self:GetParent().stepValue));
            end

            EditBox_ClearHighlight(self);
            self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        end);

        editbox:HookScript('OnEnter', function(self)
            if not self.isFocused then
                self.Background:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
            end

            if not self:GetParent().tooltip then
                return;
            end

            GameTooltip:SetOwner(self:GetParent(), 'ANCHOR_RIGHT');
            GameTooltip:AddLine(self:GetParent().tooltip, 1, 0.85, 0, true);
            GameTooltip:Show();
        end);

        editbox:HookScript('OnLeave', function(self)
            if not self.isFocused then
                self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
            end

            GameTooltip_Hide();
        end);


        slider.editbox = editbox;

        E.CreateTooltip(slider);

        slider:Show();

        return slider;
    end
end

E.CreateHeader = function(parent, text)
    local frame = CreateFrame('Frame', nil, parent);

    frame.SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
        PixelUtil.SetPoint(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels);
    end

    frame.SetSize = function(self, width, height)
        PixelUtil.SetSize(self, width, height);
    end

    local label = frame:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal');
    PixelUtil.SetPoint(label, 'TOP', frame, 'TOP', 0, 0);
    PixelUtil.SetPoint(label, 'BOTTOM', frame, 'BOTTOM', 0, 0);
    label:SetJustifyH('CENTER');

    local left = frame:CreateTexture(nil, 'BACKGROUND');
    PixelUtil.SetPoint(left, 'LEFT', frame, 'LEFT', 3, 0);
    PixelUtil.SetPoint(left, 'RIGHT', label, 'LEFT', -5, 0);
    PixelUtil.SetHeight(left, 2);
    left:SetTexture('Interface\\Buttons\\WHITE8x8');
    left:SetVertexColor(0.4, 0.4, 0.4, 1);

    local right = frame:CreateTexture(nil, 'BACKGROUND');
    PixelUtil.SetPoint(right, 'RIGHT', frame, 'RIGHT', -3, 0);
    PixelUtil.SetPoint(right, 'LEFT', label, 'RIGHT', 5, 0);
	PixelUtil.SetHeight(right, 2);
    right:SetTexture('Interface\\Buttons\\WHITE8x8');
    right:SetVertexColor(0.4, 0.4, 0.4, 1);

    if text and text ~= '' then
        label:SetText(text);
        PixelUtil.SetPoint(left, 'RIGHT', label, 'LEFT', -5, 0);
        right:Show();
    else
        PixelUtil.SetPoint(left, 'RIGHT', frame, 'RIGHT', -3, 0);
        right:Hide();
    end

    frame.Label = label;

    return frame;
end

-- Reinventing the wheel
do
    local activeLists = {};

    local DROPDOWN_WIDTH, DROPDOWN_HEIGHT = 100, 24;

    local DROPDOWN_HOLDER_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { top = 0, left = 0, bottom = 0, right = 0 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local DROPDOWN_ARROWBUTTON_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { top = 0, left = 0, bottom = 0, right = 0 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local DROPDOWN_LIST_BACKDROP = {
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        insets = { top = 0, left = 0, bottom = 0, right = 0 },
    };

    local DROPDOWN_ITEMBUTTON_BACKDROP = {
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        insets = { top = 0, left = 0, bottom = 0, right = 0 },
    };

    E.CreateDropdown = function(parent)
        local holderButton = CreateFrame('Button', nil, parent, 'BackdropTemplate');

        holderButton.WidthValue  = DROPDOWN_WIDTH;
        holderButton.HeightValue = DROPDOWN_HEIGHT;

        PixelUtil.SetSize(holderButton, holderButton.WidthValue, holderButton.HeightValue);
        holderButton:SetBackdrop(DROPDOWN_HOLDER_BACKDROP);
        holderButton:SetBackdropColor(0.05, 0.05, 0.05, 1);
        holderButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        holderButton:SetScript('OnClick', function(self)
            self.list:SetShown(not self.list:IsShown());
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        end);

        holderButton.Text = holderButton:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight');
        PixelUtil.SetPoint(holderButton.Text, 'LEFT', holderButton, 'LEFT', 6, 0);

        local arrowButton = CreateFrame('Button', nil, holderButton, 'BackdropTemplate');
        PixelUtil.SetPoint(arrowButton, 'TOPRIGHT', holderButton, 'TOPRIGHT', 0, 0);
        PixelUtil.SetSize(arrowButton, holderButton.HeightValue, holderButton.HeightValue);
        arrowButton.Icon = arrowButton:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(arrowButton.Icon, 'CENTER', arrowButton, 'CENTER', 0, 0);
        PixelUtil.SetSize(arrowButton.Icon, holderButton.HeightValue / 1.2, holderButton.HeightValue / 1.2);
        arrowButton.Icon:SetTexture(M.Icons.TEXTURE);
        arrowButton.Icon:SetTexCoord(unpack(M.Icons.COORDS.ARROW_DOWN));
        arrowButton:SetBackdrop(DROPDOWN_ARROWBUTTON_BACKDROP);
        arrowButton:SetBackdropColor(0.1, 0.1, 0.1, 1);
        arrowButton:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

        arrowButton:SetScript('OnClick', function(self)
            self:GetParent().list:SetShown(not self:GetParent().list:IsShown());
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        end);

        arrowButton:HookScript('OnEnter', function(self)
            self.Icon:SetVertexColor(1, 0.72, 0.2);
            self:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);
        end);

        arrowButton:HookScript('OnLeave', function(self)
            self.Icon:SetVertexColor(1, 1, 1);
            self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
        end);

        local list = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate');
        PixelUtil.SetPoint(list, 'TOPLEFT', holderButton, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(list, 'TOPRIGHT', holderButton, 'TOPRIGHT', 0, 0);
        list:SetFrameLevel(arrowButton:GetFrameLevel() + 1);
        list:SetBackdrop(DROPDOWN_LIST_BACKDROP);
        list:SetBackdropColor(0.05, 0.05, 0.05, 1);
        list:SetShown(false);

        list.buttonPool = CreateFramePool('Button', list, 'BackdropTemplate');

        table.insert(activeLists, list);

        holderButton.arrowButton = arrowButton;
        holderButton.list        = list;

        holderButton.SetSize = function(self, width, height)
            if not width or not height then
                return;
            end

            PixelUtil.SetSize(self, width, height);
            PixelUtil.SetSize(arrowButton, height, height);
            PixelUtil.SetSize(arrowButton.Icon, height / 1.2, height / 1.2);

            self.WidthValue  = width;
            self.HeightValue = height;
        end

        holderButton.SetList = function(self, itemsTable)
            local itemButton, isNew, lastButton;
            local itemCounter = 0;
            local listFrame = self.list;

            listFrame.buttonPool:ReleaseAll();

            for key, value in ipairs(itemsTable) do
                itemCounter = itemCounter + 1;
                itemButton, isNew = list.buttonPool:Acquire();

                if itemCounter == 1 then
                    PixelUtil.SetPoint(itemButton, 'TOPLEFT', listFrame, 'TOPLEFT', 0, 0);
                    PixelUtil.SetPoint(itemButton, 'TOPRIGHT', listFrame, 'TOPRIGHT', 0, 0);
                else
                    PixelUtil.SetPoint(itemButton, 'TOPLEFT', lastButton, 'BOTTOMLEFT', 0, 0);
                    PixelUtil.SetPoint(itemButton, 'TOPRIGHT', lastButton, 'BOTTOMRIGHT', 0, 0);
                end

                lastButton = itemButton;

                if isNew then
                    itemButton:SetBackdrop(DROPDOWN_ITEMBUTTON_BACKDROP);
                    itemButton:SetBackdropColor(0, 0, 0, 1);

                    itemButton.SelectedIcon = itemButton:CreateTexture(nil, 'ARTWORK');
                    PixelUtil.SetPoint(itemButton.SelectedIcon, 'LEFT', itemButton, 'LEFT', 2, 0);
                    itemButton.SelectedIcon:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');
                    itemButton.SelectedIcon:SetShown(false);

                    itemButton.Text = itemButton:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight');
                    PixelUtil.SetPoint(itemButton.Text, 'LEFT', itemButton.SelectedIcon, 'RIGHT', 2, 0);

                    itemButton:HookScript('OnEnter', function(self)
                        self:SetBackdropColor(1, 0.72, 0.2, 0.65);
                    end);

                    itemButton:HookScript('OnLeave', function(self)
                        self:SetBackdropColor(0, 0, 0, 1);
                    end);

                    itemButton:SetScript('OnClick', function(self)
                        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

                        holderButton:SetValue(self.Key);
                        listFrame:SetShown(false);

                        if holderButton.OnValueChangedCallback then
                            holderButton:OnValueChangedCallback(self.Key);
                        end
                    end);
                end

                PixelUtil.SetHeight(itemButton, self.HeightValue);
                PixelUtil.SetSize(itemButton.SelectedIcon, self.HeightValue / 1.5, self.HeightValue / 1.5);
                itemButton.Text:SetText(value);

                itemButton.Key   = key;
                itemButton.Value = value;

                itemButton:SetShown(true);
            end

            PixelUtil.SetHeight(listFrame, itemCounter * self.HeightValue);
        end

        holderButton.SetValue = function(self, value)
            for button, _ in self.list.buttonPool:EnumerateActive() do
                button.SelectedIcon:SetShown(false);

                if button.Key == value then
                    button.SelectedIcon:SetShown(true);
                    self.Text:SetText(button.Value);
                    self.currentValue = value;
                end
            end
        end

        holderButton.GetValue = function(self)
            return self.currentValue;
        end

        hooksecurefunc(holderButton, 'SetScale', function(self, value)
            self.list:SetScale(value);
        end);

        hooksecurefunc(holderButton, 'SetEnabled', function(self, state)
            if state then
                self.Text:SetFontObject('GameFontHighlight');
                self.arrowButton:Enable();
                self.arrowButton.Icon:SetVertexColor(1, 1, 1, 1);
            else
                self.Text:SetFontObject('GameFontDisable');
                self.arrowButton:Disable();
                self.arrowButton.Icon:SetVertexColor(0.5, 0.5, 0.5, 1);
            end
        end);

        holderButton.Label = holderButton:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight');
        PixelUtil.SetPoint(holderButton.Label, 'LEFT', holderButton, 'RIGHT', 6, 0);
        holderButton.Label:SetJustifyH('LEFT');

        holderButton.SetLabel = function(self, label)
            self.Label:SetText(label);
        end

        holderButton.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        E.CreateTooltip(holderButton);

        return holderButton;
    end

    if UIDropDownMenu_HandleGlobalMouseEvent then
        local function DropDown_CloseNotActive()
            for _, list in ipairs(activeLists) do
                if list:IsShown() and not list:IsMouseOver() then
                    list:SetShown(false);
                end
            end
        end

        hooksecurefunc('UIDropDownMenu_HandleGlobalMouseEvent', function(button, event)
            if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton') then
                DropDown_CloseNotActive();
            end
        end);
    end
end

-- Based on Phanx's LibColorPicker-1.0
-- https://github.com/Phanx/PhanxConfig-ColorPicker
local NewColorPicker do
    local NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR, GRAY_FONT_COLOR = _G.NORMAL_FONT_COLOR, _G.HIGHLIGHT_FONT_COLOR, _G.GRAY_FONT_COLOR;

    local function GetFloorValue(value)
        return math.floor(value * 100 + 0.5) / 100;
    end

    function NewColorPicker(parent, hasOpacity)
        local holder = CreateFrame('Button', nil, parent);
        PixelUtil.SetSize(holder, 27, 27);

        local background = holder:CreateTexture(nil, 'BACKGROUND');
        background:SetTexture(M.Icons.TEXTURE);
        background:SetTexCoord(unpack(M.Icons.COORDS.FULL_CIRCLE));
        background:SetVertexColor(0.8, 0.8, 0.8);
        PixelUtil.SetPoint(background, 'CENTER', holder, 'CENTER', 0, 0);
        PixelUtil.SetSize(background, 17, 17)
        holder.background = background;

        local border = holder:CreateTexture(nil, 'BORDER');
        border:SetTexture(M.Icons.TEXTURE);
        border:SetTexCoord(unpack(M.Icons.COORDS.FULL_CIRCLE));
        border:SetVertexColor(0, 0, 0);
        PixelUtil.SetPoint(border, 'TOPLEFT', background, 'TOPLEFT', 2, -2);
        PixelUtil.SetPoint(border, 'BOTTOMRIGHT', background, 'BOTTOMRIGHT', -2, 2);
        holder.border = border;

        local sample = holder:CreateTexture(nil, 'OVERLAY');
        sample:SetTexture(M.Icons.TEXTURE);
        sample:SetTexCoord(unpack(M.Icons.COORDS.FULL_CIRCLE));
        PixelUtil.SetPoint(sample, 'TOPLEFT', border, 'TOPLEFT', 1, -1);
        PixelUtil.SetPoint(sample, 'BOTTOMRIGHT', border, 'BOTTOMRIGHT', -1, 1);
        holder.sample = sample;

        local label = holder:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight');
        PixelUtil.SetPoint(label, 'LEFT', sample, 'RIGHT', 8, 0);
        holder.label = label;

        holder:SetScript('OnEnter', function(self)
            if not self.disabled then
                self.background:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            end
        end);

        holder:SetScript('OnLeave', function(self)
            if not self.disabled then
                self.background:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
            end
        end);

        holder:SetScript('OnClick', function(self)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

            if ColorPickerFrame:IsShown() then
                ColorPickerFrame:Hide();
                return;
            end

            self.r, self.g, self.b, self.opacity = self:GetValue();
            self.opening = true;

            ColorPickerFrame:SetupColorPickerAndShow(self);

            ColorPickerFrame:SetFrameStrata('TOOLTIP');
            ColorPickerFrame:Raise();

            self.opening = false;
        end);

        holder:SetScript('OnDisable', function(self)
            self.background:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
            self.label:SetFontObject(GameFontDisable);

            self.disabled = true;
        end);

        holder:SetScript('OnEnable', function(self)
            local color = self:IsMouseOver() and NORMAL_FONT_COLOR or HIGHLIGHT_FONT_COLOR;

            self.background:SetVertexColor(color.r, color.g, color.b);
            self.label:SetFontObject(GameFontHighlight);

            self.disabled = false;
        end);

        holder.GetValue = function(self)
            local r, g, b, a = self.sample:GetVertexColor();
            return GetFloorValue(r), GetFloorValue(g), GetFloorValue(b), GetFloorValue(a);
        end

        holder.SetValue = function(self, r, g, b, a)
            if type(r) == 'table' then
                r, g, b, a = r.r or r[1], r.g or r[2], r.b or r[3], r.a or r[4];
            end

            r, g, b = GetFloorValue(r), GetFloorValue(g), GetFloorValue(b);
            a       = a and self.hasOpacity and GetFloorValue(a) or 1;

            if self.OnValueChanged then
                local cR, cG, cB, cA = self.sample:GetVertexColor();
                cR, cG, cB, cA = GetFloorValue(cR), GetFloorValue(cG), GetFloorValue(cB), GetFloorValue(cA);
                if cR ~= r or cG ~= g or cB ~= b or cA ~= a then
                    self:OnValueChanged(r, g, b, a);
                end
            end

            self.sample:SetVertexColor(r, g, b, a);
            self.background:SetAlpha(a);
        end

        holder.hasOpacity = hasOpacity;

        holder.cancelFunc = function()
            holder:SetValue(holder.r, holder.g, holder.b, holder.hasOpacity and holder.opacity or 1);
        end

        holder.opacityFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB();
            local a = ColorPickerFrame:GetColorAlpha();

            holder:SetValue(r, g, b, a);
        end

        holder.swatchFunc = function()
            if holder.opening then
                return;
            end

            local r, g, b = ColorPickerFrame:GetColorRGB();
            local a = ColorPickerFrame:GetColorAlpha();

            holder:SetValue(r, g, b, a);
        end

        holder.SetLabel = function(self, text)
            self.label:SetText(text);
            self:SetHitRectInsets(0, -(self.label:GetStringWidth() + 2), 0, 0);
        end

        holder.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        E.CreateTooltip(holder);

        return holder;
    end
end

E.CreateColorPicker = function(parent, color)
    if type(color) ~= 'table' then
        return;
    end

    local hasOpacity = false;

    if not color.r and color[4] then
        hasOpacity = color[4];
        color = color;
    elseif color.a then
        hasOpacity = color.a;
        color = { color.r, color.g, color.b, color.a };
    elseif color.r and color.g and color.b then
        hasOpacity = false;
        color = { color.r, color.g, color.b };
    end

    local colorpicker = NewColorPicker(parent, hasOpacity);
    colorpicker:SetValue(unpack(color));

    return colorpicker;
end