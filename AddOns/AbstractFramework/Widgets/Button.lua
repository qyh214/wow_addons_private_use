---@class AbstractFramework
local AF = _G.AbstractFramework

local PlaySoundFile = PlaySoundFile
local PlaySound = PlaySound

local function RegisterMouseDownUp(b)
    b:SetScript("OnMouseDown", function()
        if b._pushEffectEnabled then
            b:HandleMouseDownText()
            b:HandleMouseDownTexture()
        end
    end)
    b:SetScript("OnMouseUp", function()
        if b._pushEffectEnabled then
            b:HandleMouseUpText()
            b:HandleMouseUpTexture()
        end
    end)
end

local function UnregisterMouseDownUp(b)
    b:SetScript("OnMouseDown", nil)
    b:SetScript("OnMouseUp", nil)
end

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------

---@class AF_Button:Button,AF_BaseWidgetMixin
local AF_ButtonMixin = {}

function AF_ButtonMixin:HandleMouseDownText()
    if self.texture and self.texture:IsShown()
    and self.textureJustifyH ~= "RIGHT" -- NOTE: not sure why the text wont move if texture is on the right
    then return end
    self.text:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(self))
end

function AF_ButtonMixin:HandleMouseUpText()
    if self.texture and self.texture:IsShown()
    and self.textureJustifyH ~= "RIGHT" -- NOTE: not sure why the text wont move if texture is on the right
    then return end
    AF.RePoint(self.text)
end

function AF_ButtonMixin:HandleMouseDownTexture()
    if not self.texture then return end
    self.texture:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(self))
end

function AF_ButtonMixin:HandleMouseUpTexture()
    if not self.texture then return end
    AF.RePoint(self.texture)
end

function AF_ButtonMixin:EnablePushEffect(enabled)
    self._pushEffectEnabled = enabled
end

---@param color string
function AF_ButtonMixin:SetTextHighlightColor(color)
    if color then
        self.highlightText = function()
            self.text:SetColor(color)
        end
        self.unhighlightText = function()
            self.text:SetColor("white")
        end
    else
        self.highlightText = nil
        self.unhighlightText = nil
    end
end

function AF_ButtonMixin:SetText(str)
    self.text:SetText(str)
end

function AF_ButtonMixin:GetText()
    return self.text:GetText()
end

function AF_ButtonMixin:GetFontString()
    return self.text
end

function AF_ButtonMixin:SetTextColor(color)
    self.text:SetColor(color)
end

function AF_ButtonMixin:SetFontObject(f)
    self.text:SetFontObject(f)
end

function AF_ButtonMixin:SetFont(...)
    self.text:SetFont(...)
end

function AF_ButtonMixin:GetFont()
    return self.text:GetFont()
end

function AF_ButtonMixin:SetTextJustifyH(justify)
    self.text:SetJustifyH(justify)
end

-- function AF_ButtonMixin:SetTextJustifyV(justify)
--     self.text:SetJustifyV(justify)
-- end

function AF_ButtonMixin:SetTextPadding(padding)
    self.textPadding = padding
    AF.ClearPoints(self.text)
    if self.texture and self.texture:IsShown() then
        if self.textureJustifyH == "RIGHT" then
            AF.SetPoint(self.text, "LEFT", padding, 0)
        else
            AF.SetPoint(self.text, "RIGHT", -padding, 0)
        end
    else
        AF.SetPoint(self.text, "LEFT", padding, 0)
        AF.SetPoint(self.text, "RIGHT", -padding, 0)
    end
end

---@param color string
function AF_ButtonMixin:SetBorderHighlightColor(color)
    if color then
        self.highlightBorder = function()
            self:SetBackdropBorderColor(AF.GetColorRGB(color))
        end

        self._borderColor = self._borderColor or AF.GetColorTable("black")
        self.unhighlightBorder = function()
            self:SetBackdropBorderColor(AF.UnpackColor(self._borderColor))
        end
    else
        self.highlightBorder = nil
        self.unhighlightBorder = nil
    end
end

---@param color string
function AF_ButtonMixin:SetBorderColor(color)
    self._borderColor = AF.GetColorTable(color)
    self:SetBackdropBorderColor(AF.UnpackColor(self._borderColor))
end

---@param color string|table if table, color[1] is normal color, color[2] is hover color
function AF_ButtonMixin:SetColor(color)
    if not color then return end

    -- keep color & hoverColor ------------------
    if type(color) == "table" then
        assert(#color == 2, "color table must have 2 elements")
        self._color = type(color[1]) == "table" and color[1] or AF.GetButtonNormalColor(color[1])
        self._hoverColor = type(color[2]) == "table" and color[2] or AF.GetButtonHoverColor(color[2])
    else
        self._color = AF.GetButtonNormalColor(color)
        self._hoverColor = AF.GetButtonHoverColor(color)
    end

    self:SetBackdropColor(AF.UnpackColor(self._color))

    -- OnEnter / OnLeave ------------------------
    self:SetScript("OnEnter", function()
        self:SetBackdropColor(AF.UnpackColor(self._hoverColor))
        if self.highlightText then self.highlightText() end
        if self.highlightBorder then self.highlightBorder() end
    end)
    self:SetScript("OnLeave", function()
        self:SetBackdropColor(AF.UnpackColor(self._color))
        if self.unhighlightText then self.unhighlightText() end
        if self.unhighlightBorder then self.unhighlightBorder() end
    end)
end

function AF_ButtonMixin:SetOnClick(func)
    self:SetScript("OnClick", func)
end

function AF_ButtonMixin:HookOnClick(func)
    self:HookScript("OnClick", func)
end

---@param tex string
---@param size? table default is {16, 16}
---@param point? table default is {"CENTER", 0, 0}
---@param isAtlas boolean
---@param bgColor? string no texture border if nil
---@param justifyH? string default is "LEFT"
function AF_ButtonMixin:SetTexture(tex, size, point, isAtlas, bgColor, justifyH)
    if not self.texture then
        self.texture = self:CreateTexture(nil, "BORDER")

        self:HookScript("OnEnable", function()
            self.realTexture:SetDesaturated(false)
            self.realTexture:SetVertexColor(AF.GetColorRGB("white"))
        end)

        self:HookScript("OnDisable", function()
            self.realTexture:SetDesaturated(true)
            self.realTexture:SetVertexColor(AF.GetColorRGB("disabled"))
        end)

        size = size or {16, 16}
        self.point = point or {"CENTER", 0, 0}
        AF.SetPoint(self.texture, unpack(self.point))
        AF.SetSize(self.texture, unpack(size))

        self.textureJustifyH = justifyH or "LEFT"
    end

    AF.ClearPoints(self.text)
    if self.textureJustifyH == "RIGHT" then
        AF.SetPoint(self.text, "LEFT", self.textPadding, 0)
        AF.SetPoint(self.text, "RIGHT", self.texture, "LEFT", -2, 0)
    else
        AF.SetPoint(self.text, "LEFT", self.texture, "RIGHT", 2, 0)
        AF.SetPoint(self.text, "RIGHT", -self.textPadding, 0)
    end

    self.texture:Show()

    if bgColor then
        if not self.textureFG then
            self.textureFG = self:CreateTexture(nil, "ARTWORK")
            AF.SetOnePixelInside(self.textureFG, self.texture)
        end
        self.texture:SetColorTexture(AF.GetColorRGB(bgColor))
        self.realTexture = self.textureFG
        self.textureFG:Show()
    else
        if self.textureFG then
            self.textureFG:Hide()
        end
        self.realTexture = self.texture
    end

    if isAtlas then
        self.realTexture:SetAtlas(tex)
    else
        if type(tex) == "number" then
            self.realTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        else
            self.realTexture:SetTexCoord(0, 1, 0, 1)
        end
        self.realTexture:SetTexture(tex)
    end
end

---@param color string
function AF_ButtonMixin:SetTextureColor(color)
    if self.realTexture then
        self.realTexture:SetVertexColor(AF.GetColorRGB(color))
    end
end

function AF_ButtonMixin:ShowTexture()
    if self.texture then
        self.texture:Show()
    end
    if self.textureFG then
        self.textureFG:Show()
    end
    AF.ClearPoints(self.text)
    if self.textureJustifyH == "RIGHT" then
        AF.SetPoint(self.text, "LEFT", self.textPadding, 0)
        AF.SetPoint(self.text, "RIGHT", self.texture, "LEFT", -2, 0)
    else
        AF.SetPoint(self.text, "LEFT", self.texture, "RIGHT", 2, 0)
        AF.SetPoint(self.text, "RIGHT", -self.textPadding, 0)
    end
end

function AF_ButtonMixin:HideTexture()
    if self.texture then
        self.texture:Hide()
    end
    if self.textureFG then
        self.textureFG:Hide()
    end
    AF.ClearPoints(self.text)
    AF.SetPoint(self.text, "LEFT", self.textPadding, 0)
    AF.SetPoint(self.text, "RIGHT", -self.textPadding, 0)
end

function AF_ButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.RePoint(self.text)
    AF.ReBorder(self)
    if self.texture then
        AF.ReSize(self.texture)
        AF.RePoint(self.texture)
    end
    if self.textureFG then
        AF.RePoint(self.textureFG)
    end
end

---@param sound string|nil|"default" default is SOUNDKIT.U_CHAT_SCROLL_BUTTON
function AF_ButtonMixin:SetClickSound(sound)
    if sound == "default" then
        self._customSound = nil
        self._noSound = nil
    elseif sound then
        self._customSound = sound
        self._noSound = nil
    else
        self._noSound = true
    end
end

function AF_ButtonMixin:SilentClick()
    self._noSound = true
    self:Click()
    self._noSound = nil
end

---@param parent Frame
---@param text string
---@param color? string|table if table, color[1] is normal color, color[2] is hover color
---@param width? number
---@param height? number
---@param template? string
---@param borderColor? string default is "black", set to "" to remove border
---@param backgroundColor? string default is "background", set to "" to remove background
---@param font? string?
---@return AF_Button button
function AF.CreateButton(parent, text, color, width, height, template, borderColor, backgroundColor, font)
    local b = CreateFrame("Button", nil, parent, template and template..",BackdropTemplate" or "BackdropTemplate")
    if parent then AF.SetFrameLevel(b, 1) end
    AF.SetSize(b, width, height)

    Mixin(b, AF_ButtonMixin)
    Mixin(b, AF_BaseWidgetMixin)

    RegisterMouseDownUp(b)
    b:EnablePushEffect(true)

    -- text -------------------------------------
    b.text = AF.CreateFontString(b, text, nil, font)
    AF.RemoveFromPixelUpdater(b.text)
    b:SetTextPadding(5)
    b.text:SetWordWrap(false)
    b.text:SetText(text)

    b:SetScript("OnEnable", function()
        b.text:SetColor("white")
        RegisterMouseDownUp(b)
    end)

    b:SetScript("OnDisable", function()
        b.text:SetColor("disabled")
        UnregisterMouseDownUp(b)
    end)

    -- border -----------------------------------
    if borderColor == "" then
        AF.ApplyDefaultBackdrop_NoBorder(b)
    else
        AF.ApplyDefaultBackdrop(b)
        b:SetBackdropBorderColor(AF.GetColorRGB(borderColor or "black"))
    end

    -- background -------------------------------
    if backgroundColor ~= "" then
        local bg = b:CreateTexture(nil, "BACKGROUND", nil, -8)
        b.bg = bg
        if borderColor == "" then
            bg:SetAllPoints(b)
        else
            AF.SetOnePixelInside(bg, b)
        end
        bg:SetColorTexture(AF.GetColorRGB(backgroundColor or "background"))
        -- bg:SetDrawLayer("BACKGROUND", -8)
    end

    -- color ------------------------------------
    b.accentColor = AF.GetAddonAccentColorName() -- just for Tooltips ...
    b:SetColor(color)

    -- click sound ------------------------------
    if not AF.isVanilla then
        if template and strfind(template, "SecureActionButtonTemplate") then
            b._isSecure = true
            -- NOTE: ActionButtonUseKeyDown will affect OnClick
            b:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown", "RightButtonDown")
        end

        b:SetScript("PostClick", function(self, button, down)
            if self._noSound then return end
            local play
            if b._isSecure then
                if down == GetCVarBool("ActionButtonUseKeyDown") then
                    play = true
                end
            else
                play = true
            end
            if play then
                if b._customSound then
                    if strlower(b._customSound):find("^interface") then
                        PlaySoundFile(b._customSound)
                    else
                        AF.PlaySound(b._customSound)
                    end
                else
                    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
                end
            end
        end)
    else
        b:SetScript("PostClick", function()
            if self._noSound then return end
            if b._customSound then
                if strlower(b._customSound):find("^interface") then
                    PlaySoundFile(b._customSound)
                else
                    AF.PlaySound(b._customSound)
                end
            else
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            end
        end)
    end

    -- pixel updater ----------------------------
    AF.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- button group
---------------------------------------------------------------------
---@param buttons table
---@param onClick function
---@param selectedFn function
---@param unselectedFn function
---@param onEnter function
---@param onLeave function
---@return function HighlightButton accept button.id as parameter
function AF.CreateButtonGroup(buttons, onClick, selectedFn, unselectedFn, onEnter, onLeave)
    local function HighlightButton(id)
        for _, b in pairs(buttons) do
            if id == b.id then
                b:SetBackdropColor(unpack(b._hoverColor))
                b:SetScript("OnEnter", function()
                    if b._tooltips then AF.ShowTooltips(b, b._tooltipsAnchor, b._tooltipsX, b._tooltipsY, b._tooltips) end
                    if onEnter then onEnter(b) end
                end)
                b:SetScript("OnLeave", function()
                    AF.HideTooltips()
                    if onLeave then onLeave(b) end
                end)
                if selectedFn then selectedFn(b.id, b) end
            else
                b:SetBackdropColor(unpack(b._color))
                b:SetScript("OnEnter", function()
                    if b._tooltips then AF.ShowTooltips(b, b._tooltipsAnchor, b._tooltipsX, b._tooltipsY, b._tooltips) end
                    b:SetBackdropColor(unpack(b._hoverColor))
                    if onEnter then onEnter(b) end
                end)
                b:SetScript("OnLeave", function()
                    AF.HideTooltips()
                    b:SetBackdropColor(unpack(b._color))
                    if onLeave then onLeave(b) end
                end)
                if unselectedFn then unselectedFn(b.id, b) end
            end
        end
    end

    for _, b in pairs(buttons) do
        b:SetScript("OnClick", function()
            HighlightButton(b.id)
            onClick(b.id, b)
        end)
    end

    return HighlightButton
end

---------------------------------------------------------------------
-- close button
---------------------------------------------------------------------
---@return AF_Button
function AF.CreateCloseButton(parent, frameToHide, width, height, padding)
    width = width or 16
    height = height or 16
    padding = padding or 6

    local b = AF.CreateButton(parent, nil, "red", width, height)
    b:SetTexture(AF.GetIcon("Close"), {width - padding, height - padding}, {"CENTER", 0, 0})
    b:SetScript("OnClick", function()
        if frameToHide then
            frameToHide:Hide()
        else
            parent:Hide()
        end
    end)
    return b
end

---------------------------------------------------------------------
-- icon button
---------------------------------------------------------------------
---@class AF_IconButton:Button,AF_BaseWidgetMixin
local AF_IconButtonMixin = {}

function AF_IconButtonMixin:HandleMouseDownTexture()
    self.icon:ClearAllPoints()
    self.icon:SetPoint("CENTER", 0, -AF.GetOnePixelForRegion(self))
end

function AF_IconButtonMixin:HandleMouseUpTexture()
    self.icon:ClearAllPoints()
    self.icon:SetPoint("CENTER")
end

function AF_IconButtonMixin:EnablePushEffect(enabled)
    self._pushEffectEnabled = enabled
end

function AF_IconButtonMixin:SetOnClick(func)
    self:SetScript("OnClick", func)
end

function AF_IconButtonMixin:HookOnClick(func)
    self:HookScript("OnClick", func)
end

function AF_IconButtonMixin:SetTexCoord(...)
    self.icon:SetTexCoord(...)
end

---@param icon string
---@param filterMode string|nil "LINEAR"|"TRILINEAR"|"NEAREST". default is "LINEAR".
function AF_IconButtonMixin:SetIcon(icon, filterMode)
    if filterMode then
        self._filterMode = filterMode
    end
    self._iconPath = icon
    self.icon:SetTexture(icon, nil, nil, self._filterMode)
end

---@param color string|table
function AF_IconButtonMixin:SetColor(color)
    assert(type(color) == "string" or (type(color) == "table" and (#color == 3 or #color == 4)), "color must be a string or a table with 3 or 4 elements")
    self._color = type(color) == "string" and AF.GetColorTable(color) or color
    if not self:IsMouseOver() then
        self.icon:SetVertexColor(AF.UnpackColor(self._color))
    end
end

---@param color string|table
function AF_IconButtonMixin:SetHoverColor(color)
    assert(type(color) == "string" or (type(color) == "table" and (#color == 3 or #color == 4)), "color must be a string or a table with 3 or 4 elements")
    self._hoverColor = type(color) == "string" and AF.GetColorTable(color) or color
    if self:IsMouseOver() then
        self.icon:SetVertexColor(AF.UnpackColor(self._hoverColor))
    end
end

function AF_IconButtonMixin:SetFilterMode(filterMode)
    self._filterMode = filterMode
    self.icon:SetTexture(self._iconPath, nil, nil, filterMode)
end

function AF_IconButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.SetSize(self.icon, self._width - self._padding, self._height - self._padding)
end

---@param parent Frame
---@param icon string
---@param width number
---@param height number
---@param padding? number default is 0
---@param color? string|table
---@param hoverColor? string|table
---@param filterMode? string
---@param noPushDownEffect? boolean
---@return AF_IconButton
function AF.CreateIconButton(parent, icon, width, height, padding, color, hoverColor, filterMode, noPushDownEffect)

    local b = CreateFrame("Button", nil, parent)
    AF.SetSize(b, width, height)

    b._padding = (padding or 0) * 2

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("CENTER")
    AF.SetSize(b.icon, width - b._padding, height - b._padding)

    b.icon:SetTexture(icon, nil, nil, filterMode)
    b._icon = icon
    b._filterMode = filterMode

    b._color = type(color) == "string" and AF.GetColorTable(color) or (color or AF.GetColorTable("white"))
    b._hoverColor = type(hoverColor) == "string" and AF.GetColorTable(hoverColor) or (hoverColor or AF.GetColorTable("white"))
    b.icon:SetVertexColor(AF.UnpackColor(b._color))

    b:SetScript("OnEnter", function()
        b.icon:SetVertexColor(AF.UnpackColor(b._hoverColor))
    end)
    b:SetScript("OnLeave", function()
        b.icon:SetVertexColor(AF.UnpackColor(b._color))
    end)

    Mixin(b, AF_IconButtonMixin)
    Mixin(b, AF_BaseWidgetMixin)

    RegisterMouseDownUp(b)
    b:EnablePushEffect(not noPushDownEffect)
    b.HandleMouseDownText = AF.noop
    b.HandleMouseUpText = AF.noop

    AF.AddToPixelUpdater(b)

    return b
end

---------------------------------------------------------------------
-- tips button
---------------------------------------------------------------------
---@class AF_TipsButton:AF_IconButton
local AF_TipsButtonMixin = {}

local function TipsButton_OnEnter(self)
    if not AF.IsEmpty(self.tips) then
        AF.ShowTooltips(self, self.position, self.x, self.y, self.tips)
    end
end

local function TipsButton_OnLeave(self)
    AF.HideTooltips()
end

---@param ... string
function AF_TipsButtonMixin:SetTips(...)
    self.tips = {...}
end

function AF_TipsButtonMixin:SetTipsPosition(position, x, y)
    self.position = position or "TOPRIGHT"
    self.x = x or 0
    self.y = y or 0
end

---@return AF_TipsButton
function AF.CreateTipsButton(parent)
    local tipsButton = AF.CreateIconButton(parent, AF.GetIcon("Info_Square"), 16, 16, 0, "gray", "white", "NEAREST", true)
    Mixin(tipsButton, AF_TipsButtonMixin)
    tipsButton:SetTipsPosition("TOPRIGHT", 0, 0)
    tipsButton:HookOnEnter(TipsButton_OnEnter)
    tipsButton:HookOnLeave(TipsButton_OnLeave)
    return tipsButton
end

---------------------------------------------------------------------
-- check button
---------------------------------------------------------------------
---@class AF_CheckButton:CheckButton,AF_BaseWidgetMixin
local AF_CheckButtonMixin = {}

function AF_CheckButtonMixin:SetText(text)
    self.label:SetText(text)
    if text and strtrim(text) ~= "" then
        self:SetHitRectInsets(0, -self.label:GetStringWidth()-5, 0, 0)
    else
        self:SetHitRectInsets(0, 0, 0, 0)
    end
end

function AF_CheckButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.checkedTexture)
    AF.RePoint(self.highlightTexture)
end

---@return AF_CheckButton cb
function AF.CreateCheckButton(parent, label, onClick)
    -- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
    -- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10

    local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    AF.SetSize(cb, 14, 14)

    cb.accentColor = AF.GetAddonAccentColorName()

    cb.onClick = onClick
    cb:SetScript("OnClick", function(self)
        PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        if self.onClick then self.onClick(self:GetChecked() and true or false, self) end
    end)

    cb.label = cb:CreateFontString(nil, "OVERLAY", "AF_FONT_NORMAL")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 5, 0)

    Mixin(cb, AF_CheckButtonMixin)
    Mixin(cb, AF_BaseWidgetMixin)

    cb:SetText(label)

    AF.ApplyDefaultBackdrop(cb)
    cb:SetBackdropColor(AF.GetColorRGB("widget"))
    cb:SetBackdropBorderColor(0, 0, 0, 1)

    local checkedTexture = cb:CreateTexture(nil, "ARTWORK")
    cb.checkedTexture = checkedTexture
    checkedTexture:SetColorTexture(AF.GetColorRGB(cb.accentColor, 0.7))
    AF.SetPoint(checkedTexture, "TOPLEFT", 1, -1)
    AF.SetPoint(checkedTexture, "BOTTOMRIGHT", -1, 1)

    local highlightTexture = cb:CreateTexture(nil, "ARTWORK")
    cb.highlightTexture = highlightTexture
    highlightTexture:SetColorTexture(AF.GetColorRGB(cb.accentColor, 0.1))
    AF.SetPoint(highlightTexture, "TOPLEFT", 1, -1)
    AF.SetPoint(highlightTexture, "BOTTOMRIGHT", -1, 1)

    cb:SetCheckedTexture(checkedTexture)
    cb:SetHighlightTexture(highlightTexture, "ADD")
    -- cb:SetDisabledCheckedTexture([[Interface\AddOns\Cell\Media\CheckBox\CheckBox-DisabledChecked-16x16]])

    cb:SetScript("OnEnable", function()
        cb.label:SetTextColor(1, 1, 1)
        checkedTexture:SetColorTexture(AF.GetColorRGB(cb.accentColor, 0.7))
        cb:SetBackdropBorderColor(0, 0, 0, 1)
    end)

    cb:SetScript("OnDisable", function()
        cb.label:SetTextColor(AF.GetColorRGB("disabled"))
        checkedTexture:SetColorTexture(AF.GetColorRGB("disabled", 0.7))
        cb:SetBackdropBorderColor(0, 0, 0, 0.7)
    end)

    AF.AddToPixelUpdater(cb)

    return cb
end

---------------------------------------------------------------------
-- switch
---------------------------------------------------------------------
---@class AF_Switch:AF_BorderedFrame
local AF_SwitchMixin = {}

function AF_SwitchMixin:SetSelectedValue(value)
    for _, b in ipairs(self.buttons) do
        -- if b.value == value then
        --     if not b.isSelected then b.fill:Play() end
        --     b.isSelected = true
        -- else
        --     if b.isSelected then b.empty:Play() end
        --     b.isSelected = false
        -- end
        if b.value == value then
            b:SilentClick()
            break
        end
    end
end

function AF_SwitchMixin:GetSelectedValue()
    return self.selected
end

-- function AF_SwitchMixin:UpdatePixels()
--     AF.ReSize(self)
--     AF.RePoint(self)
--     AF.ReBorder(self)
--     -- AF.RePoint(self.highlight)

--     -- update highlights
--     -- for _, b in ipairs(buttons) do
--     --     AF.ReSize(b.highlight)
--     --     AF.RePoint(b.highlight)
--     -- end
-- end

---@param labels table {{["text"]=(string), ["value"]=(any), ["onClick"]=(function)}, ...}
function AF_SwitchMixin:SetLabels(labels)
    if type(labels) ~= "table" then return end

    local buttons = self.buttons
    for _, b in ipairs(buttons) do
        b:Hide()
    end
    wipe(buttons)

    local switch = self
    local n = #labels
    local width = self._width / n
    local height = self._height

    for i, l in pairs(labels) do
        buttons[i] = AF.CreateButton(switch, labels[i].text, "none", width, height, nil, "", "")
        buttons[i].value = labels[i].value or labels[i].text
        buttons[i].isSelected = false

        buttons[i].highlight = AF.CreateTexture(buttons[i], nil, AF.GetColorTable(switch.accentColor, 0.7))
        AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
        AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
        AF.SetHeight(buttons[i].highlight, 1)

        -- fill animation -------------------------------------------
        local fill = buttons[i].highlight:CreateAnimationGroup()
        buttons[i].fill = fill

        fill.t = fill:CreateAnimation("Translation")
        fill.t:SetOffset(0, AF.ConvertPixelsForRegion(height/2-1, buttons[i]))
        fill.t:SetSmoothing("IN")
        fill.t:SetDuration(0.1)

        fill.s = fill:CreateAnimation("Scale")
        fill.s:SetScaleTo(1, AF.ConvertPixelsForRegion(height-2, buttons[i]))
        fill.s:SetDuration(0.1)
        fill.s:SetSmoothing("IN")

        fill:SetScript("OnPlay", function()
            AF.ClearPoints(buttons[i].highlight)
            AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
            AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
        end)

        fill:SetScript("OnFinished", function()
            AF.SetHeight(buttons[i].highlight, height-2)
            -- to ensure highlight always fill the whole button exactly
            AF.ClearPoints(buttons[i].highlight)
            AF.SetPoint(buttons[i].highlight, "TOPLEFT", 1, -1)
            AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
        end)
        -------------------------------------------------------------

        -- empty animation ------------------------------------------
        local empty = buttons[i].highlight:CreateAnimationGroup()
        buttons[i].empty = empty

        empty.t = empty:CreateAnimation("Translation")
        empty.t:SetOffset(0, -AF.ConvertPixelsForRegion(height/2-1, buttons[i]))
        empty.t:SetSmoothing("IN")
        empty.t:SetDuration(0.1)

        empty.s = empty:CreateAnimation("Scale")
        empty.s:SetScaleTo(1, 1/AF.ConvertPixelsForRegion(height-2, buttons[i]))
        empty.s:SetDuration(0.1)
        empty.s:SetSmoothing("IN")

        empty:SetScript("OnPlay", function()
            AF.ClearPoints(buttons[i].highlight)
            AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
            AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
        end)

        empty:SetScript("OnFinished", function()
            AF.SetHeight(buttons[i].highlight, 1)
        end)
        -------------------------------------------------------------

        buttons[i]:SetScript("OnClick", function(self)
            if self.isSelected or fill:IsPlaying() or empty:IsPlaying() then return end

            fill:Play()
            self.isSelected = true
            switch.selected = self.value

            if labels[i].onClick then
                labels[i].onClick()
            end

            -- deselect others
            for j, b in ipairs(buttons) do
                if j ~= i then
                    if b.isSelected then b.empty:Play() end
                    b.isSelected = false
                end
            end
        end)

        buttons[i]:SetScript("OnEnter", function()
            switch:GetScript("OnEnter")()
        end)

        buttons[i]:SetScript("OnLeave", function()
            switch:GetScript("OnLeave")()
        end)

        if i == 1 then
            AF.SetPoint(buttons[i], "TOPLEFT")
        elseif i == n then
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i-1], "TOPRIGHT", -1, 0)
            AF.SetPoint(buttons[i], "TOPRIGHT")
        else
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i-1], "TOPRIGHT", -1, 0)
        end
    end
end

---@param parent Frame
---@param width number can not be nil
---@param height number can not be nil
---@param labels table? {{["text"]=(string), ["value"]=(any), ["onClick"]=(function)}, ...}
---@return AF_Switch switch
function AF.CreateSwitch(parent, width, height, labels)
    local switch = AF.CreateBorderedFrame(parent, nil, width, height, "widget")

    switch.accentColor = AF.GetAddonAccentColorName()

    switch.highlight = AF.CreateTexture(switch, nil, AF.GetColorTable(switch.accentColor, 0.07))
    AF.SetPoint(switch.highlight, "TOPLEFT", 1, -1)
    AF.SetPoint(switch.highlight, "BOTTOMRIGHT", -1, 1)
    switch.highlight:Hide()

    switch:SetScript("OnEnter", function()
        switch.highlight:Show()
    end)

    switch:SetScript("OnLeave", function()
        switch.highlight:Hide()
    end)

    -- buttons
    switch.buttons = {}

    Mixin(switch, AF_SwitchMixin)
    Mixin(switch, AF_BaseWidgetMixin)

    switch:SetLabels(labels)

    AF.AddToPixelUpdater(switch)

    return switch
end

---------------------------------------------------------------------
-- resize button
---------------------------------------------------------------------
---@return Button|AF_BaseWidgetMixin
function AF.CreateResizeButton(target, minWidth, minHeight, maxWidth, maxHeight)
    local b = CreateFrame("Button", nil, target)
    Mixin(b, PanelResizeButtonMixin)
    Mixin(b, AF_BaseWidgetMixin)

    b:Init(target, minWidth, minHeight, maxWidth, maxHeight)

    AF.SetSize(b, 16, 16)
    AF.SetPoint(b, "BOTTOMRIGHT", -1, 1)


    b:SetScript("OnEnter", b.OnEnter)
    b:SetScript("OnLeave", b.OnLeave)
    b:SetScript("OnMouseDown", b.OnMouseDown)
    b:SetScript("OnMouseUp", b.OnMouseUp)

    local tex = b:CreateTexture(nil, "ARTWORK")
    b.tex = tex
    tex:SetAllPoints()
    tex:SetTexture(AF.GetIcon("ResizeButton"))

    return b
end