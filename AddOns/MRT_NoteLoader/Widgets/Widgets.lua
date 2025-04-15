local _, addon = ...
local addonName = "MRT_NL"
addon.widgets = {}

local W = addon.widgets
local L = addon.L

local accentColor = {s="ffff9015", t={1, 0.56, 0.08, 0.5}}

function W:WrapTextInAccentColor(text)
    return WrapTextInColorCode(text, accentColor.s)
end

function W:GetAccentColorRGB()
    return unpack(accentColor.t)
end

-------------------------------------------------
-- fonts
-------------------------------------------------
function W:CreateFont(name, size, flags, justifyH)
    local font = CreateFont(name)
    font:SetFont(GameFontNormal:GetFont(), size, flags)
    if strfind(name, "DISABLE$") then
        font:SetTextColor(0.4, 0.4, 0.4, 1)
    elseif strfind(name, "ACCENT") then
        font:SetTextColor(accentColor.t[1], accentColor.t[2], accentColor.t[3])
    else
        font:SetTextColor(1, 1, 1, 1)
    end
    font:SetShadowColor(0, 0, 0)
    font:SetShadowOffset(1, -1)
    font:SetJustifyH(justifyH)
end

local font_title_name = strupper(addonName).."_FONT_ACCENT_TITLE"
local font_title = CreateFont(font_title_name)
font_title:SetFont(GameFontNormal:GetFont(), 13, "")
font_title:SetTextColor(accentColor.t[1], accentColor.t[2], accentColor.t[3])
font_title:SetShadowColor(0, 0, 0)
font_title:SetShadowOffset(1, -1)
font_title:SetJustifyH("CENTER")

local font_normal_name = strupper(addonName).."_FONT_NORMAL"
local font_normal = CreateFont(font_normal_name)
font_normal:SetFont(GameFontNormal:GetFont(), 12, "")
font_normal:SetTextColor(1, 1, 1, 1)
font_normal:SetShadowColor(0, 0, 0)
font_normal:SetShadowOffset(1, -1)
font_normal:SetJustifyH("CENTER")

local font_disable_name = strupper(addonName).."_FONT_DISABLE"
local font_disable = CreateFont(font_disable_name)
font_disable:SetFont(GameFontNormal:GetFont(), 12, "")
font_disable:SetTextColor(0.4, 0.4, 0.4, 1)
font_disable:SetShadowColor(0, 0, 0)
font_disable:SetShadowOffset(1, -1)
font_disable:SetJustifyH("CENTER")

local font_accent_name = strupper(addonName).."_FONT_ACCENT"
local font_accent = CreateFont(font_accent_name)
font_accent:SetFont(GameFontNormal:GetFont(), 12, "")
font_accent:SetTextColor(accentColor.t[1], accentColor.t[2], accentColor.t[3])
font_accent:SetShadowColor(0, 0, 0)
font_accent:SetShadowOffset(1, -1)
font_accent:SetJustifyH("CENTER")

local font_special_name = strupper(addonName).."_FONT_SPECIAL"
local font_special = CreateFont(font_special_name)
font_special:SetFont("Interface\\AddOns\\MRT_NoteLoader\\Media\\font.ttf", 12, "")
font_special:SetTextColor(1, 1, 1, 1)
font_special:SetShadowColor(0, 0, 0)
font_special:SetShadowOffset(1, -1)
font_special:SetJustifyH("CENTER")
font_special:SetJustifyV("MIDDLE")

-------------------------------------------------
-- stylize frame
-------------------------------------------------
function W:StylizeFrame(frame, color, borderColor)
    if not color then color = {0.1, 0.1, 0.1, 0.9} end
    if not borderColor then borderColor = {0, 0, 0, 1} end

    frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    frame:SetBackdropColor(unpack(color))
    frame:SetBackdropBorderColor(unpack(borderColor))
end

-------------------------------------------------
-- movable frame
-------------------------------------------------
function W:CreateMovableFrame(title, name, width, height, frameStrata, frameLevel, notUserPlaced)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:EnableMouse(true)
    -- f:SetIgnoreParentScale(true)
    -- f:SetResizable(false)
    f:SetMovable(true)
    f:SetUserPlaced(not notUserPlaced)
    f:SetFrameStrata(frameStrata or "HIGH")
    f:SetFrameLevel(frameLevel or 1)
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(0, 0, 20, 0)
    f:SetSize(width, height)
    f:SetPoint("CENTER")
    f:Hide()
    W:StylizeFrame(f)

    -- header
    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.header = header
    header:EnableMouse(true)
    header:SetClampedToScreen(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        f:StartMoving()
        if notUserPlaced then f:SetUserPlaced(false) end
    end)
    header:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    header:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, -1)
    header:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -1)
    header:SetHeight(20)
    W:StylizeFrame(header, {0.115, 0.115, 0.115, 1})

    header.text = header:CreateFontString(nil, "OVERLAY", font_title_name)
    header.text:SetText(title)
    header.text:SetPoint("CENTER", header)

    header.closeBtn = W:CreateButton(header, "×", "red", {20, 20}, false, false, font_special_name, font_special_name)
    header.closeBtn:SetPoint("TOPRIGHT")
    header.closeBtn:SetScript("OnClick", function() f:Hide() end)

    return f
end

-------------------------------------------------
-- button
-------------------------------------------------
function W:CreateButton(parent, text, buttonColor, size, noBorder, noBackground, fontNormal, fontDisable, template)
    local b = CreateFrame("Button", nil, parent, template and template..",BackdropTemplate" or "BackdropTemplate")
    if parent then b:SetFrameLevel(parent:GetFrameLevel()+1) end
    b:SetText(text)
    b:SetSize(size[1], size[2])

    local color, hoverColor
    if buttonColor == "red" then
        color = {0.6, 0.1, 0.1, 0.6}
        hoverColor = {0.6, 0.1, 0.1, 1}
    elseif buttonColor == "red-hover" then
        color = {0.115, 0.115, 0.115, 1}
        hoverColor = {0.6, 0.1, 0.1, 1}
    elseif buttonColor == "green" then
        color = {0.1, 0.6, 0.1, 0.6}
        hoverColor = {0.1, 0.6, 0.1, 1}
    elseif buttonColor == "green-hover" then
        color = {0.115, 0.115, 0.115, 1}
        hoverColor = {0.1, 0.6, 0.1, 1}
    elseif buttonColor == "cyan" then
        color = {0, 0.9, 0.9, 0.6}
        hoverColor = {0, 0.9, 0.9, 1}
    elseif buttonColor == "blue" then
        color = {0, 0.5, 0.8, 0.6}
        hoverColor = {0, 0.5, 0.8, 1}
    elseif buttonColor == "blue-hover" then
        color = {0.115, 0.115, 0.115, 1}
        hoverColor = {0, 0.5, 0.8, 1}
    elseif buttonColor == "yellow" then
        color = {0.7, 0.7, 0, 0.6}
        hoverColor = {0.7, 0.7, 0, 1}
    elseif buttonColor == "yellow-hover" then
        color = {0.115, 0.115, 0.115, 1}
        hoverColor = {0.7, 0.7, 0, 1}
    elseif buttonColor == "accent" then
        color = {accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.3}
        hoverColor = {accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4]}
    elseif buttonColor == "accent-hover" then
        color = {0.115, 0.115, 0.115, 1}
        hoverColor = {accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4]}
    elseif buttonColor == "chartreuse" then
        color = {0.5, 1, 0, 0.6}
        hoverColor = {0.5, 1, 0, 0.8}
    elseif buttonColor == "magenta" then
        color = {0.6, 0.1, 0.6, 0.6}
        hoverColor = {0.6, 0.1, 0.6, 1}
    elseif buttonColor == "transparent" then -- drop down item
        color = {0, 0, 0, 0}
        hoverColor = {0.5, 1, 0, 0.7}
    elseif buttonColor == "transparent-white" then -- drop down item
        color = {0, 0, 0, 0}
        hoverColor = {0.4, 0.4, 0.4, 0.7}
    elseif buttonColor == "transparent-accent" then -- drop down item
        color = {0, 0, 0, 0}
        hoverColor = {accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4]}
    elseif buttonColor == "none" then
        color = {0, 0, 0, 0}
    else
        color = {0.115, 0.115, 0.115, 0.7}
        hoverColor = {accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4]}
    end

    -- keep color & hoverColor
    b.color = color
    b.hoverColor = hoverColor

    local s = b:GetFontString()
    if s then
        s:SetWordWrap(false)
        -- s:SetWidth(size[1])
        s:SetPoint("LEFT")
        s:SetPoint("RIGHT")

        function b:SetTextColor(...)
            s:SetTextColor(...)
        end
    end

    if noBorder then
        b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
    else
        b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    end

    if buttonColor and string.find(buttonColor, "transparent") then -- drop down item
        -- b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
        if s then
            s:SetJustifyH("LEFT")
            s:SetPoint("LEFT", 5, 0)
            s:SetPoint("RIGHT", -5, 0)
        end
        b:SetBackdropBorderColor(1, 1, 1, 0)
        b:SetPushedTextOffset(0, 0)
    else
        if not noBackground then
            local bg = b:CreateTexture()
            bg:SetDrawLayer("BACKGROUND", -8)
            b.bg = bg
            bg:SetAllPoints(b)
            bg:SetColorTexture(0.115, 0.115, 0.115, 1)
        end

        b:SetBackdropBorderColor(0, 0, 0, 1)
        b:SetPushedTextOffset(0, -1)
    end


    b:SetBackdropColor(unpack(color))
    b:SetDisabledFontObject(fontDisable or font_disable)
    b:SetNormalFontObject(fontNormal or font_normal)
    b:SetHighlightFontObject(fontNormal or font_normal)

    if buttonColor ~= "none" then
        b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(self.hoverColor)) end)
        b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(self.color)) end)
    end

    -- click sound
    b:SetScript("PostClick", function() PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON) end)

    -- texture
    function b:SetTexture(tex, texSize, point)
        b.tex = b:CreateTexture(nil, "ARTWORK")
        b.tex:SetPoint(unpack(point))
        b.tex:SetSize(unpack(texSize))
        b.tex:SetTexture(tex)
        -- update fontstring point
        if s then
            s:ClearAllPoints()
            s:SetPoint("LEFT", b.tex, "RIGHT", point[2], 0)
            s:SetPoint("RIGHT", -point[2], 0)
            b:SetPushedTextOffset(0, 0)
        end
        -- push effect
        b.onMouseDown = function()
            b.tex:ClearAllPoints()
            b.tex:SetPoint(point[1], point[2], point[3]-1)
        end
        b.onMouseUp = function()
            b.tex:ClearAllPoints()
            b.tex:SetPoint(unpack(point))
        end
        b:SetScript("OnMouseDown", b.onMouseDown)
        b:SetScript("OnMouseUp", b.onMouseUp)
        -- enable / disable
        b:HookScript("OnEnable", function()
            b.tex:SetVertexColor(1, 1, 1)
            b:SetScript("OnMouseDown", b.onMouseDown)
            b:SetScript("OnMouseUp", b.onMouseUp)
        end)
        b:HookScript("OnDisable", function()
            b.tex:SetVertexColor(0.4, 0.4, 0.4)
            b:SetScript("OnMouseDown", nil)
            b:SetScript("OnMouseUp", nil)
        end)
    end

    return b
end

-------------------------------------------------
-- check button
-------------------------------------------------
function W:CreateCheckButton(parent, label, onClick, color)
    -- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
    -- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10

    local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    cb.onClick = onClick
    cb:SetScript("OnClick", function(self)
        PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        if cb.onClick then cb.onClick(self:GetChecked() and true or false, self) end
    end)

    cb.label = cb:CreateFontString(nil, "OVERLAY", font_normal_name)
    cb.label:SetText(label)
    cb.label:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    -- cb.label:SetTextColor(accentColor.t[1], accentColor.t[2], accentColor.t[3])

    cb:SetSize(14, 14)
    if strtrim(label) ~= "" then
        cb:SetHitRectInsets(0, -cb.label:GetStringWidth()-5, 0, 0)
    end

    cb:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    cb:SetBackdropColor(0.115, 0.115, 0.115, 0.9)
    cb:SetBackdropBorderColor(0, 0, 0, 1)

    local checkedTexture = cb:CreateTexture(nil, "ARTWORK")
    if color then
        checkedTexture:SetColorTexture(color[1], color[2], color[3], color[4])
    else
        checkedTexture:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4])
    end
    checkedTexture:SetPoint("TOPLEFT", 1, -1)
    checkedTexture:SetPoint("BOTTOMRIGHT", -1, 1)

    local highlightTexture = cb:CreateTexture(nil, "ARTWORK")
    if color then
        highlightTexture:SetColorTexture(color[1], color[2], color[3], 0.1)
    else
        highlightTexture:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.1)
    end
    highlightTexture:SetPoint("TOPLEFT", 1, -1)
    highlightTexture:SetPoint("BOTTOMRIGHT", -1, 1)

    cb:SetCheckedTexture(checkedTexture)
    cb:SetHighlightTexture(highlightTexture, "ADD")

    cb:SetScript("OnEnable", function()
        cb.label:SetTextColor(1, 1, 1)
        if color then
            checkedTexture:SetColorTexture(color[1], color[2], color[3], color[4])
        else
            checkedTexture:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], accentColor.t[4])
        end
        cb:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    cb:SetScript("OnDisable", function()
        cb.label:SetTextColor(0.4, 0.4, 0.4)
        checkedTexture:SetColorTexture(0.4, 0.4, 0.4)
        cb:SetBackdropBorderColor(0, 0, 0, 0.4)
    end)

    function cb:SetText(text)
        cb.label:SetText(text)
        if strtrim(label) ~= "" then
            cb:SetHitRectInsets(0, -cb.label:GetStringWidth()-5, 0, 0)
        else
            cb:SetHitRectInsets(0, 0, 0, 0)
        end
    end

    -- W:SetTooltips(cb, "ANCHOR_TOPLEFT", 0, 2, ...)

    return cb
end

-------------------------------------------------
-- editbox
-------------------------------------------------
function W:CreateEditBox(parent, width, height, isTransparent, isMultiLine, isNumeric, font)
    local eb = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    if not isTransparent then W:StylizeFrame(eb, {0.115, 0.115, 0.115, 0.9}) end
    eb:SetFontObject(font or font_normal)
    eb:SetMultiLine(isMultiLine)
    eb:SetMaxLetters(0)
    eb:SetJustifyH("LEFT")
    eb:SetJustifyV("MIDDLE")
    eb:SetWidth(width or 0)
    eb:SetHeight(height or 0)
    eb:SetTextInsets(5, 5, 0, 0)
    eb:SetAutoFocus(false)
    eb:SetNumeric(isNumeric)
    eb:SetScript("OnEscapePressed", function() eb:ClearFocus() end)
    eb:SetScript("OnEnterPressed", function() eb:ClearFocus() end)
    eb:SetScript("OnEditFocusGained", function() eb:HighlightText() end)
    eb:SetScript("OnEditFocusLost", function() eb:HighlightText(0, 0) end)
    eb:SetScript("OnDisable", function() eb:SetTextColor(0.4, 0.4, 0.4, 1) end)
    eb:SetScript("OnEnable", function() eb:SetTextColor(1, 1, 1, 1) end)

    return eb
end

-----------------------------------------
-- slider
-----------------------------------------
-- Interface\FrameXML\OptionsPanelTemplates.xml, line 76, OptionsSliderTemplate
function W:CreateSlider(name, parent, low, high, width, step, onValueChangedFn, afterValueChangedFn, isPercentage, ...)
    -- local tooltips = {...}
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(width, 10)
    local unit = isPercentage and "%" or ""

    W:StylizeFrame(slider, {0.115, 0.115, 0.115, 1})

    local nameText = slider:CreateFontString(nil, "OVERLAY", font_normal_name)
    nameText:SetText(name)
    nameText:SetPoint("BOTTOM", slider, "TOP", 0, 2)

    function slider:SetName(n)
        nameText:SetText(n)
    end

    local currentEditBox = W:CreateEditBox(slider, 48, 14)
    slider.currentEditBox = currentEditBox
    currentEditBox:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", math.ceil(width / 2 - 24), -1)
    -- currentEditBox:SetPoint("TOP", slider, "BOTTOM", 0, -1)
    currentEditBox:SetJustifyH("CENTER")
    currentEditBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    currentEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        local value = tonumber(self:GetText())
        -- if isPercentage then
        --     value = string.gsub(self:GetText(), "%%", "")
        --     value = tonumber(value)
        -- else
        --     value = tonumber(self:GetText())
        -- end

        if value == self.oldValue then return end
        if value then
            if value < slider.low then value = slider.low end
            if value > slider.high then value = slider.high end
            self:SetText(value)
            slider:SetValue(value)
            if slider.onValueChangedFn then slider.onValueChangedFn(value) end
            if slider.afterValueChangedFn then slider.afterValueChangedFn(value) end
        else
            self:SetText(self.oldValue)
        end
    end)
    currentEditBox:SetScript("OnShow", function(self)
        if self.oldValue then self:SetText(self.oldValue) end
    end)

    local lowText = slider:CreateFontString(nil, "OVERLAY", font_normal_name)
    slider.lowText = lowText
    lowText:SetTextColor(0.7, 0.7, 0.7)
    lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -1)
    lowText:SetPoint("BOTTOM", currentEditBox)

    local highText = slider:CreateFontString(nil, "OVERLAY", font_normal_name)
    slider.highText = highText
    highText:SetTextColor(0.7, 0.7, 0.7)
    highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -1)
    highText:SetPoint("BOTTOM", currentEditBox)

    local tex = slider:CreateTexture(nil, "ARTWORK")
    tex:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.7)
    tex:SetSize(8, 8)
    slider:SetThumbTexture(tex)

    local valueBeforeClick
    slider.onEnter = function()
        tex:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.9)
        valueBeforeClick = slider:GetValue()
        -- if #tooltips > 0 then
        --     ShowTooltips(slider, "ANCHOR_TOPLEFT", 0, 3, tooltips)
        -- end
    end
    slider:SetScript("OnEnter", slider.onEnter)
    slider.onLeave = function()
        tex:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.7)
    end
    slider:SetScript("OnLeave", slider.onLeave)

    slider.onValueChangedFn = onValueChangedFn
    slider.afterValueChangedFn = afterValueChangedFn

    local oldValue
    slider:SetScript("OnValueChanged", function(self, value, userChanged)
        if oldValue == value then return end
        oldValue = value

        if math.floor(value) < value then -- decimal
            value = tonumber(string.format("%.2f", value))
        end

        currentEditBox:SetText(value)
        currentEditBox.oldValue = value
        if userChanged and slider.onValueChangedFn then slider.onValueChangedFn(value) end
    end)

    -- local valueBeforeClick
    -- slider:HookScript("OnEnter", function(self, button, isMouseOver)
    --     valueBeforeClick = slider:GetValue()
    -- end)

    slider:SetScript("OnMouseUp", function(self, button, isMouseOver)
        -- oldValue here == newValue, OnMouseUp called after OnValueChanged
        if valueBeforeClick ~= oldValue and slider.afterValueChangedFn then
            valueBeforeClick = oldValue
            local value = slider:GetValue()
            if math.floor(value) < value then -- decimal
                value = tonumber(string.format("%.2f", value))
            end
            slider.afterValueChangedFn(value)
        end
    end)

    slider:SetValue(low) -- NOTE: needs to be after OnValueChanged

    slider:SetScript("OnDisable", function()
        nameText:SetTextColor(0.4, 0.4, 0.4)
        currentEditBox:SetEnabled(false)
        slider:SetScript("OnEnter", nil)
        slider:SetScript("OnLeave", nil)
        tex:SetColorTexture(0.4, 0.4, 0.4, 0.7)
        lowText:SetTextColor(0.4, 0.4, 0.4)
        highText:SetTextColor(0.4, 0.4, 0.4)
    end)

    slider:SetScript("OnEnable", function()
        nameText:SetTextColor(1, 1, 1)
        currentEditBox:SetEnabled(true)
        slider:SetScript("OnEnter", slider.onEnter)
        slider:SetScript("OnLeave", slider.onLeave)
        tex:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.7)
        lowText:SetTextColor(0.7, 0.7, 0.7)
        highText:SetTextColor(0.7, 0.7, 0.7)
    end)

    function slider:UpdateMinMaxValues(minV, maxV)
        slider:SetMinMaxValues(minV, maxV)
        slider.low = minV
        slider.high = maxV
        lowText:SetText(minV..unit)
        highText:SetText(maxV..unit)
    end
    slider:UpdateMinMaxValues(low, high)

    return slider
end

-----------------------------------------------------------------------------------
-- create scroll frame (with scrollbar & content frame)
-----------------------------------------------------------------------------------
--! NOTE: 要保持像素精确，滚动组件之间的间距以及step不要使用像素精确，但组件高度以及整个scrollFrame的高度应当使用像素精确
function W:CreateScrollFrame(parent, color, border)
    -- create scrollFrame & scrollbar seperately (instead of UIPanelScrollFrameTemplate), in order to custom it
    local scrollFrame = CreateFrame("ScrollFrame", parent:GetName() and parent:GetName().."ScrollFrame" or nil, parent, "BackdropTemplate")
    parent.scrollFrame = scrollFrame

    scrollFrame:SetPoint("TOPLEFT")
    scrollFrame:SetPoint("BOTTOMLEFT")
    scrollFrame:SetPoint("RIGHT")

    if color then
        W:StylizeFrame(scrollFrame, color, border)
    end

    -- content
    local content = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    content:SetSize(scrollFrame:GetWidth(), 2)
    scrollFrame:SetScrollChild(content)
    scrollFrame.content = content
    -- content:SetFrameLevel(2)

    -- scrollbar
    local scrollbar = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 2, 0)
    scrollbar:SetPoint("BOTTOMRIGHT", scrollFrame, 7, 0)
    scrollbar:Hide()
    W:StylizeFrame(scrollbar, {0.1, 0.1, 0.1, 0.8})
    scrollFrame.scrollbar = scrollbar

    -- scrollbar thumb
    local scrollThumb = CreateFrame("Frame", nil, scrollbar, "BackdropTemplate")
    scrollThumb:SetWidth(5) -- scrollbar's width is 5
    scrollThumb:SetHeight(scrollbar:GetHeight())
    scrollThumb:SetPoint("TOP")
    W:StylizeFrame(scrollThumb, {accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.8})
    scrollThumb:EnableMouse(true)
    scrollThumb:SetMovable(true)
    scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
    scrollFrame.scrollThumb = scrollThumb

    -- reset content height manually ==> content:GetBoundsRect() make it right @OnUpdate
    function scrollFrame:ResetHeight()
        content:SetHeight(2)
    end

    -- reset to top, useful when used with DropDownMenu (variable content height)
    function scrollFrame:ResetScroll()
        scrollFrame:SetVerticalScroll(0)
        scrollThumb:SetPoint("TOP")
    end

    -- FIXME: GetVerticalScrollRange goes wrong in 9.0.1
    function scrollFrame:GetVerticalScrollRange()
        local range = content:GetHeight() - scrollFrame:GetHeight()
        return range > 0 and range or 0
    end

    -- local scrollRange -- ACCURATE scroll range, for SetVerticalScroll(), instead of scrollFrame:GetVerticalScrollRange()
    function scrollFrame:VerticalScroll(step)
        local scroll = scrollFrame:GetVerticalScroll() + step
        -- if CANNOT SCROLL then scroll = -25/25, scrollFrame:GetVerticalScrollRange() = 0
        -- then scrollFrame:SetVerticalScroll(0) and scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange()) ARE THE SAME
        if scroll <= 0 then
            scrollFrame:SetVerticalScroll(0)
        elseif scroll >= scrollFrame:GetVerticalScrollRange() then
            scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
        else
            scrollFrame:SetVerticalScroll(scroll)
        end
    end

    -- NOTE: this func should not be called before Show, or GetVerticalScrollRange will be incorrect.
    function scrollFrame:ScrollToBottom()
        scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
    end

    function scrollFrame:SetContentHeight(height, num, spacing)
        if num and spacing then
            content:SetHeight(num*height+(num-1)*spacing)
        else
            content:SetHeight(height)
        end
    end

    --[[ BUG: not reliable
    -- to remove/hide widgets "widget:SetParent(nil)" MUST be called!!!
    scrollFrame:SetScript("OnUpdate", function()
        -- set content height, check if it CAN SCROLL
        local x, y, w, h = content:GetBoundsRect()
        -- NOTE: if content is not IN SCREEN -> x,y<0 -> h==-y!
        if x > 0 and y > 0 then
            content:SetHeight(h)
        end
    end)
    ]]

    -- stores all widgets on content frame
    -- local autoWidthWidgets = {}

    function scrollFrame:ClearContent()
        for _, c in pairs({content:GetChildren()}) do
            c:SetParent(nil)  -- or it will show (OnUpdate)
            c:ClearAllPoints()
            c:Hide()
        end
        -- wipe(autoWidthWidgets)
        scrollFrame:ResetHeight()
    end

    function scrollFrame:Reset()
        scrollFrame:ResetScroll()
        scrollFrame:ClearContent()
    end

    -- function scrollFrame:SetWidgetAutoWidth(widget)
    -- 	table.insert(autoWidthWidgets, widget)
    -- end

    -- on width changed, make the same change to widgets
    scrollFrame:SetScript("OnSizeChanged", function()
        -- change widgets width (marked as auto width)
        -- for i = 1, #autoWidthWidgets do
        -- 	autoWidthWidgets[i]:SetWidth(scrollFrame:GetWidth())
        -- end

        -- update content width
        content:SetWidth(scrollFrame:GetWidth())
    end)

    -- check if it can scroll
    content:SetScript("OnSizeChanged", function()
        -- set ACCURATE scroll range
        -- scrollRange = content:GetHeight() - scrollFrame:GetHeight()

        -- set thumb height (%)
        local p = scrollFrame:GetHeight() / content:GetHeight()
        p = tonumber(string.format("%.3f", p))
        if p < 1 then -- can scroll
            scrollThumb:SetHeight(scrollbar:GetHeight()*p)
            -- space for scrollbar
            scrollFrame:SetPoint("RIGHT", -7, 0)
            scrollbar:Show()
        else
            scrollFrame:SetPoint("RIGHT")
            scrollbar:Hide()
            if scrollFrame:GetVerticalScroll() > 0 then scrollFrame:SetVerticalScroll(0) end
        end
    end)

    -- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
    -- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
    -- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)

    -- dragging and scrolling
    scrollThumb:SetScript("OnMouseDown", function(self, button)
        if button ~= 'LeftButton' then return end
        local offsetY = select(5, scrollThumb:GetPoint(1))
        local mouseY = select(2, GetCursorPosition())
        local uiScale = UIParent:GetEffectiveScale() -- https://wowpedia.fandom.com/wiki/API_GetCursorPosition
        local currentScroll = scrollFrame:GetVerticalScroll()
        self:SetScript("OnUpdate", function(self)
            --------------------- y offset before dragging + mouse offset
            local newOffsetY = offsetY + (select(2, GetCursorPosition()) - mouseY) / uiScale

            -- even scrollThumb:SetPoint is already done in OnVerticalScroll, but it's useful in some cases.
            if newOffsetY >= 0 then -- @top
                scrollThumb:SetPoint("TOP")
                newOffsetY = 0
            elseif (-newOffsetY) + scrollThumb:GetHeight() >= scrollbar:GetHeight() then -- @bottom
                scrollThumb:SetPoint("TOP", 0, -(scrollbar:GetHeight() - scrollThumb:GetHeight()))
                newOffsetY = -(scrollbar:GetHeight() - scrollThumb:GetHeight())
            else
                scrollThumb:SetPoint("TOP", 0, newOffsetY)
            end
            local vs = (-newOffsetY / (scrollbar:GetHeight()-scrollThumb:GetHeight())) * scrollFrame:GetVerticalScrollRange()
            scrollFrame:SetVerticalScroll(vs)
        end)
    end)

    scrollThumb:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        if scrollFrame:GetVerticalScrollRange() ~= 0 then
            local scrollP = scrollFrame:GetVerticalScroll()/scrollFrame:GetVerticalScrollRange()
            local yoffset = -((scrollbar:GetHeight()-scrollThumb:GetHeight())*scrollP)
            scrollThumb:SetPoint("TOP", 0, yoffset)
        end
    end)

    function scrollFrame:UpdateSize()
        content:GetScript("OnSizeChanged")(content)
        scrollFrame:GetScript("OnVerticalScroll")(scrollFrame)
        scrollFrame:VerticalScroll(0)
    end

    local step = 25
    function scrollFrame:SetScrollStep(s)
        step = s
    end

    -- enable mouse wheel scroll
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta == 1 then -- scroll up
            scrollFrame:VerticalScroll(-step)
        elseif delta == -1 then -- scroll down
            scrollFrame:VerticalScroll(step)
        end
    end)

    return scrollFrame
end

-------------------------------------------------
-- dropdown menu
-------------------------------------------------
local listInit, list, highlightTexture
list = CreateFrame("Frame", addonName.."DropdownList", UIParent, "BackdropTemplate")
-- list:SetIgnoreParentScale(true)
-- W:StylizeFrame(list, {0.115, 0.115, 0.115, 1})
list:Hide()

-- store created buttons
list.items = {}

-- highlight
highlightTexture = CreateFrame("Frame", nil, list, "BackdropTemplate")
-- highlightTexture:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
-- highlightTexture:SetBackdropBorderColor(unpack(accentColor.t))
highlightTexture:Hide()

list:SetScript("OnShow", function()
    -- list:SetScale(list.menu:GetEffectiveScale())
    list:SetFrameStrata("FULLSCREEN")
    -- list:SetFrameLevel(77) -- top of its strata
end)
list:SetScript("OnHide", function() list:Hide() end)

-- close dropdown
function W:RegisterForCloseDropdown(f)
    if f:GetObjectType() == "Button" or f:GetObjectType() == "CheckButton" then
        f:HookScript("OnClick", function()
            list:Hide()
        end)
    elseif f:GetObjectType() == "Slider" then
        f:HookScript("OnValueChanged", function()
            list:Hide()
        end)
    end
end

local function SetHighlightItem(i)
    if not i then
        highlightTexture:ClearAllPoints()
        highlightTexture:Hide()
    else
        highlightTexture:SetParent(list.items[i]) -- buttons show/hide automatically when scroll, so let highlightTexture to be the same
        highlightTexture:ClearAllPoints()
        highlightTexture:SetAllPoints(list.items[i])
        highlightTexture:Show()
    end
end

function W:CreateDropdown(parent, width, dropdownType, isMini)
    local menu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    menu:SetSize(width, 20)
    menu:EnableMouse(true)
    -- menu:SetFrameLevel(5)
    W:StylizeFrame(menu, {0.115, 0.115, 0.115, 1})

    -- button: open/close menu list
    if isMini then
        menu.button = W:CreateButton(menu, "", "transparent-accent", {18 ,18})
        menu.button:SetAllPoints(menu)
        menu.button:SetFrameLevel(menu:GetFrameLevel()+1)
        -- selected item
        menu.text = menu.button:CreateFontString(nil, "OVERLAY", font_normal_name)
        menu.text:SetPoint("LEFT", 1, 0)
        menu.text:SetPoint("RIGHT",-1, 0)
        menu.text:SetJustifyH("CENTER")
    else
        menu.button = W:CreateButton(menu, "", "transparent-accent", {18 ,20})
        W:StylizeFrame(menu.button, {0.115, 0.115, 0.115, 1})
        menu.button:SetPoint("TOPRIGHT")
        menu.button:SetFrameLevel(menu:GetFrameLevel()+1)
        menu.button:SetNormalTexture([[Interface\AddOns\MRT_NoteLoader\Media\dropdown-normal]])
        menu.button:SetPushedTexture([[Interface\AddOns\MRT_NoteLoader\Media\dropdown-pushed]])

        local disabledTexture = menu.button:CreateTexture(nil, "OVERLAY")
        disabledTexture:SetTexture([[Interface\AddOns\MRT_NoteLoader\Media\dropdown-normal]])
        disabledTexture:SetVertexColor(0.4, 0.4, 0.4, 1)
        menu.button:SetDisabledTexture(disabledTexture)
        -- selected item
        menu.text = menu:CreateFontString(nil, "OVERLAY", font_normal_name)
        menu.text:SetPoint("TOPLEFT", 5, -1)
        menu.text:SetPoint("BOTTOMRIGHT", -18, 1)
        menu.text:SetJustifyH("LEFT")
    end

    -- selected item
    menu.text:SetJustifyV("MIDDLE")
    menu.text:SetWordWrap(false)

    if dropdownType == "texture" then
        menu.texture = menu:CreateTexture(nil, "ARTWORK")
        menu.texture:SetPoint("TOPLEFT", 1, -1)
        menu.texture:SetPoint("BOTTOMRIGHT", -18, 1)
        menu.texture:SetVertexColor(1, 1, 1, 0.7)
    end

    -- keep all menu item buttons
    menu.items = {}

    -- index in items
    -- menu.selected

    function menu:SetSelected(text, value)
        local valid
        for i, item in pairs(menu.items) do
            if item.text == text then
                valid = true
                -- store index for list
                menu.selected = i
                menu.text:SetText(text)
                if dropdownType == "texture" then
                    menu.texture:SetTexture(value)
                elseif dropdownType == "font" then
                    menu.text:SetFont(value, 13+fontSizeOffset, "")
                end
                break
            end
        end
        if not valid then
            menu.selected = nil
            menu.text:SetText("")
        end
    end

    function menu:SetSelectedValue(value)
        for i, item in pairs(menu.items) do
            if item.value == value then
                menu.selected = i
                menu.text:SetText(item.text)
                break
            end
        end
    end

    function menu:GetSelected()
        if menu.selected then
            return menu.items[menu.selected].value or menu.items[menu.selected].text
        end
        return nil
    end

    function menu:SetSelectedItem(itemNum)
        local item = menu.items[itemNum]
        menu.text:SetText(item.text)
        menu.selected = itemNum
    end

    -- items = {
    -- 	{
    -- 		["text"] = (string),
    -- 		["value"] = (obj),
    -- 		["texture"] = (string),
    -- 		["onClick"] = (function)
    -- 	},
    -- }
    function menu:SetItems(items)
        menu.items = items
        menu.reloadRequired = true
    end

    function menu:AddItem(item)
        tinsert(menu.items, item)
        menu.reloadRequired = true
    end

    function menu:RemoveCurrentItem()
        tremove(menu.items, menu.selected)
        menu.reloadRequired = true
    end

    function menu:ClearItems()
        wipe(menu.items)
        menu.selected = nil
        menu.text:SetText("")
    end

    function menu:SetCurrentItem(item)
        menu.items[menu.selected] = item
        -- usually, update current item means to change its name (text) and func
        menu.text:SetText(item["text"])
        menu.reloadRequired = true
    end

    local function LoadItems()
        if not listInit then
            listInit = true
            W:CreateScrollFrame(list)
            list.scrollFrame:SetScrollStep(18)
            W:StylizeFrame(list, {0.115, 0.115, 0.115, 1})
            highlightTexture:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
            highlightTexture:SetBackdropBorderColor(unpack(accentColor.t))
        end

        -- hide highlight
        SetHighlightItem()
        -- hide all list items
        list.scrollFrame:Reset()

        -- load current dropdown
        for i, item in pairs(menu.items) do
            local b
            if not list.items[i] then
                -- init
                b = W:CreateButton(list.scrollFrame.content, item.text, "transparent-accent", {18 ,18}, true) --! width is not important
                table.insert(list.items, b)

                -- texture
                b.texture = b:CreateTexture(nil, "ARTWORK")
                b.texture:SetPoint("TOPLEFT", 1, -1)
                b.texture:SetPoint("BOTTOMRIGHT", -1, 1)
                b.texture:SetVertexColor(1, 1, 1, 0.7)
                b.texture:Hide()
            else
                b = list.items[i]
                b:SetText(item.text)
            end

            local fs = b:GetFontString()
            if isMini then
                fs:ClearAllPoints()
                fs:SetJustifyH("CENTER")
                fs:SetPoint("LEFT", 1, 0)
                fs:SetPoint("RIGHT", -1, 0)
            else
                fs:ClearAllPoints()
                fs:SetJustifyH("LEFT")
                fs:SetPoint("LEFT", 5, 0)
                fs:SetPoint("RIGHT", -5, 0)
            end

            b:SetEnabled(not item.disabled)

            -- texture
            if item.texture then
                b.texture:SetTexture(item.texture)
                b.texture:Show()
            else
                b.texture:Hide()
            end

            -- font
            local f, s = font_normal:GetFont()
            if item.font then
                b:GetFontString():SetFont(item.font, s, "")
            else
                b:GetFontString():SetFont(f, s, "")
            end

            -- highlight
            if menu.selected == i then
                SetHighlightItem(i)
            end

            b:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
                if dropdownType == "texture" then
                    menu:SetSelected(item.text, item.texture)
                elseif dropdownType == "font" then
                    menu:SetSelected(item.text, item.font)
                else
                    menu:SetSelected(item.text)
                end
                list:Hide()
                if item.onClick then item.onClick(item.text) end
            end)

            -- update point
            b:SetParent(list.scrollFrame.content)
            b:Show()
            if i == 1 then
                b:SetPoint("TOPLEFT", 1, -1)
                b:SetPoint("TOPRIGHT", -1, -1)
            else
                b:SetPoint("TOPLEFT", list.items[i-1], "BOTTOMLEFT")
                b:SetPoint("TOPRIGHT", list.items[i-1], "BOTTOMRIGHT")
            end
        end

        -- update list size
        list.menu = menu -- menu's OnHide -> list:Hide
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", menu, "BOTTOMLEFT", 0, -2)

        if #menu.items == 0 then
            list:SetSize(menu:GetWidth(), 5)
        elseif #menu.items <= 10 then
            list:SetSize(menu:GetWidth(), 2 + #menu.items*18)
            list.scrollFrame:SetContentHeight(2 + #menu.items*18)
        else
            list:SetSize(menu:GetWidth(), 2 + 10*18)
            -- update list scrollFrame
            list.scrollFrame:SetContentHeight(2 + #menu.items*18)
        end
    end

    function menu:SetEnabled(f)
        menu.button:SetEnabled(f)
        if f then
            menu.text:SetTextColor(1, 1, 1)
        else
            menu.text:SetTextColor(0.4, 0.4, 0.4)
        end
    end

    menu:SetScript("OnHide", function()
        if list.menu == menu then
            list:Hide()
        end
    end)

    -- scripts
    menu.button:HookScript("OnClick", function()
        if list.menu ~= menu then -- list shown by other dropdown
            LoadItems()
            list:Show()

        elseif list:IsShown() then -- list showing by this, hide it
            list:Hide()

        else
            if menu.reloadRequired then
                LoadItems()
                menu.reloadRequired = false
            else
                -- update highlight
                if menu.selected then
                    SetHighlightItem(menu.selected)
                end
            end
            list:Show()
        end
    end)

    return menu
end

-------------------------------------------------
-- autoload button
-------------------------------------------------
function W:CreateAutoloadButton(parent, type, value, note, isPersonal)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    -- b:SetFrameLevel(5)
    b:SetSize(20, 20)
    b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    b:SetBackdropColor(0.115, 0.115, 0.115, 1)
    b:SetBackdropBorderColor(0, 0, 0, 1)

    local typeText = b:CreateFontString(nil, "OVERLAY", font_normal_name)
    typeText:SetPoint("LEFT", 5, 0)
    typeText:SetJustifyH("LEFT")
    typeText:SetWidth(50)
    typeText:SetWordWrap(false)
    typeText:SetText(L[type])

    local valueText = b:CreateFontString(nil, "OVERLAY", font_normal_name)
    valueText:SetPoint("LEFT", typeText, "RIGHT", 10, 0)
    valueText:SetJustifyH("LEFT")
    valueText:SetWidth(150)
    valueText:SetWordWrap(false)
    valueText:SetText(value)

    local noteText = b:CreateFontString(nil, "OVERLAY", font_normal_name)
    noteText:SetPoint("LEFT", valueText, "RIGHT", 10, 0)
    noteText:SetJustifyH("LEFT")
    noteText:SetWidth(100)
    noteText:SetWordWrap(false)
    noteText:SetText(note)

    if isPersonal then
        noteText:SetTextColor(0.56, 0.93, 0.56)
    end

    local sep1 = b:CreateTexture(nil, "ARTWORK")
    sep1:SetColorTexture(0, 0, 0, 1)
    sep1:SetWidth(1)
    sep1:SetPoint("TOPLEFT", 55, 0)
    sep1:SetPoint("BOTTOMLEFT", 55, 0)

    local sep2 = b:CreateTexture(nil, "ARTWORK")
    sep2:SetColorTexture(0, 0, 0, 1)
    sep2:SetWidth(1)
    sep2:SetPoint("TOPLEFT", 215, 0)
    sep2:SetPoint("BOTTOMLEFT", 215, 0)

    local closeBtn = W:CreateButton(b, "×", "red", {20, 20}, false, false, font_special_name, font_special_name)
    closeBtn:SetPoint("BOTTOMRIGHT")
    b.closeBtn = closeBtn

    b:SetScript("OnEnter", function()
        b:SetBackdropColor(accentColor.t[1], accentColor.t[2], accentColor.t[3], 0.1)
        b:SetBackdropBorderColor(accentColor.t[1], accentColor.t[2], accentColor.t[3], 1)
        closeBtn:SetBackdropBorderColor(accentColor.t[1], accentColor.t[2], accentColor.t[3], 1)
        sep1:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 1)
        sep2:SetColorTexture(accentColor.t[1], accentColor.t[2], accentColor.t[3], 1)
    end)

    b:SetScript("OnLeave", function()
        b:SetBackdropColor(0.115, 0.115, 0.115, 1)
        b:SetBackdropBorderColor(0, 0, 0, 1)
        closeBtn:SetBackdropBorderColor(0, 0, 0, 1)
        sep1:SetColorTexture(0, 0, 0, 1)
        sep2:SetColorTexture(0, 0, 0, 1)
    end)

    closeBtn:HookScript("OnEnter", b:GetScript("OnEnter"))
    closeBtn:HookScript("OnLeave", b:GetScript("OnLeave"))

    return b
end