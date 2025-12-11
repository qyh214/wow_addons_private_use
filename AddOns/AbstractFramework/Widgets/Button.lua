---@class AbstractFramework
local AF = _G.AbstractFramework

local PlaySoundFile = PlaySoundFile
local PlaySound = PlaySound

local function RegisterMouseDownUp(b)
    b:SetScript("OnMouseDown", function()
        if b:IsEnabled() and b._pushEffectEnabled then
            b._pushed = true
            b:HandleMouseDownText()
            b:HandleMouseDownTexture()
        end
    end)
    b:SetScript("OnMouseUp", function()
        if b._pushed or (b:IsEnabled() and b._pushEffectEnabled) then
            b:HandleMouseUpText()
            b:HandleMouseUpTexture()
        end
        b._pushed = nil
    end)
    b:SetScript("OnHide", function()
        if b._pushed then
            b:HandleMouseUpText()
            b:HandleMouseUpTexture()
            b._pushed = nil
        end
    end)
end

-- local function UnregisterMouseDownUp(b)
--     b:SetScript("OnMouseDown", nil)
--     b:SetScript("OnMouseUp", nil)
-- end

---------------------------------------------------------------------
-- button
---------------------------------------------------------------------

---@class AF_Button:Button,AF_BaseWidgetMixin
local AF_ButtonMixin = {}

function AF_ButtonMixin:HandleMouseDownText()
    if self.texture and self.texture:IsShown() and self.textureJustifyH ~= "RIGHT" then -- NOTE: not sure why the text wont move if texture is on the right
        return
    end
    self.text:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(self))
end

function AF_ButtonMixin:HandleMouseUpText()
    if self.texture and self.texture:IsShown() and self.textureJustifyH ~= "RIGHT" then
        -- NOTE: not sure why the text wont move if texture is on the right
        return
    end
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

function AF_ButtonMixin:SetFormattedText(text, ...)
    self.text:SetFormattedText(text, ...)
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
            AF.SetPoint(self.text, "RIGHT", self.texture, "LEFT", -padding, 0)
        else
            AF.SetPoint(self.text, "LEFT", self.texture, "RIGHT", padding, 0)
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
        self._hoverBorderColor = AF.GetColorTable(color)
        self.highlightBorder = function()
            self:SetBackdropBorderColor(AF.UnpackColor(self._hoverBorderColor))
        end

        self._borderColor = self._borderColor or AF.GetColorTable("black")
        self.unhighlightBorder = function()
            self:SetBackdropBorderColor(AF.UnpackColor(self._borderColor))
        end
    else
        self._hoverBorderColor = nil
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

function AF_ButtonMixin:GetOnClick()
    return self:GetScript("OnClick")
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
function AF_ButtonMixin:SetTexture(tex, size, point, isAtlas, bgColor, justifyH, filterMode)
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
        self.realTexture:SetAtlas(tex, nil, filterMode)
    else
        if type(tex) == "number" then
            self.realTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        else
            self.realTexture:SetTexCoord(0, 1, 0, 1)
        end
        self.realTexture:SetTexture(tex, nil, nil, filterMode)
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

function AF_ButtonMixin:SetTooltip(...)
    AF.SetTooltip(self, "TOPLEFT", 0, 2, ...)
end

---@param parent Frame
---@param text string
---@param color? string|table if table, color[1] is normal color, color[2] is hover color
---@param width? number
---@param height? number
---@param template? string
---@param borderColor? string default is "border", set to "" to remove border
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
        -- RegisterMouseDownUp(b)
    end)

    b:SetScript("OnDisable", function()
        b.text:SetColor("disabled")
        -- UnregisterMouseDownUp(b)
    end)

    -- border -----------------------------------
    if borderColor == "" then
        AF.ApplyDefaultBackdrop_NoBorder(b)
    else
        AF.ApplyDefaultBackdrop(b)
        b:SetBackdropBorderColor(AF.GetColorRGB(borderColor or "border"))
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
        bg:SetColorTexture(AF.GetColorRGB(backgroundColor or "background", 1))
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
    AF.AddToPixelUpdater_OnShow(b)

    return b
end

---------------------------------------------------------------------
-- button group
---------------------------------------------------------------------
-- params for OnSelect/OnDeselect/OnClick/OnEnter/OnLeave: (button, buttonId)
---@param buttons table button's OnEnter/OnLeave/OnClick will be overridden
---@param onSelect? function
---@param onDeselect? function
---@param onClick? function
---@param onEnter? function
---@param onLeave? function
---@return function Highlight accept button.id as parameter, just to highlight the button without calling onSelect/onDeselect
-- buttonId is button.id, if button.id is not set, it will use button:GetText() or button:GetName() or tostring(button)
function AF.CreateButtonGroup(buttons, onSelect, onDeselect, onClick, onEnter, onLeave)
    local lastSelected

    local function Select(id, skipCallback)
        if lastSelected and lastSelected == id then return end
        lastSelected = id

        for _, b in next, buttons do
            if id == b.id then
                if b._hoverColor then b:SetBackdropColor(AF.UnpackColor(b._hoverColor)) end
                if b._hoverBorderColor then b:SetBackdropBorderColor(AF.UnpackColor(b._hoverBorderColor)) end
                if not skipCallback and onSelect then onSelect(b, b.id) end
                b.isSelected = true
            else
                if b._color then b:SetBackdropColor(AF.UnpackColor(b._color)) end
                if b._borderColor then b:SetBackdropBorderColor(AF.UnpackColor(b._borderColor)) end
                if not skipCallback and onDeselect then onDeselect(b, b.id) end
                b.isSelected = false
            end
        end
    end

    for _, b in next, buttons do
        b.id = b.id or b:GetText() or b:GetName() or tostring(b)
        -- assert(b.id, "button.id is required")

        b:SetScript("OnClick", function()
            Select(b.id)
            if onClick then onClick(b, b.id) end
        end)

        b:SetScript("OnEnter", function()
            if not b.isSelected and b._hoverColor then
                b:SetBackdropColor(AF.UnpackColor(b._hoverColor))
            end
            if b._tooltip then AF.ShowTooltip(b, b._tooltipAnchor, b._tooltipX, b._tooltipY, b._tooltip) end
            if onEnter then onEnter(b, b.id) end
        end)

        b:SetScript("OnLeave", function()
            if not b.isSelected and b._color then
                b:SetBackdropColor(AF.UnpackColor(b._color))
            end
            AF.HideTooltip()
            if onLeave then onLeave(b, b.id) end
        end)
    end

    local function Highlight(id)
        lastSelected = nil
        Select(id, true)
    end

    return Highlight
end

---------------------------------------------------------------------
-- close button
---------------------------------------------------------------------
---@param parent Frame
---@param frameToHide? Frame default is parent
---@param width? number default is 20
---@param height? number default is 20
---@param iconSize? number default is 14
---@return AF_Button
function AF.CreateCloseButton(parent, frameToHide, width, height, iconSize)
    width = width or 20
    height = height or 20
    iconSize = iconSize or 14

    local b = AF.CreateButton(parent, nil, "red", width, height)
    b:SetTexture(AF.GetIcon("Close"), {iconSize, iconSize}, {"CENTER", 0, 0})
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
    self.icon:AdjustPointsOffset(0, -AF.GetOnePixelForRegion(self))
end

function AF_IconButtonMixin:HandleMouseUpTexture()
    AF.RePoint(self.icon)
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

---@param color string|table|nil set to nil to remove hover border
function AF_IconButtonMixin:SetHoverBorder(color)
    if color then
        if not self.border then
            self.border = CreateFrame("Frame", nil, self, "BackdropTemplate")
            self.border:SetAllPoints(self.icon)
            AF.ApplyDefaultBackdrop_NoBackground(self.border)
            self.border:Hide()
        end
        if type(color) == "string" then
            self.border:SetBackdropBorderColor(AF.GetColorRGB(color))
        elseif type(color) == "table" then
            self.border:SetBackdropBorderColor(AF.UnpackColor(color))
        end
        self._hoverBorder = true
    else
        if self.border then
            self.border:Hide()
        end
        self._hoverBorder = nil
    end
end

function AF_IconButtonMixin:SetFilterMode(filterMode)
    self._filterMode = filterMode
    self.icon:SetTexture(self._iconPath, nil, nil, filterMode)
end

function AF_IconButtonMixin:SetTooltip(...)
    AF.SetTooltip(self, "TOPLEFT", 0, 2, ...)
end

function AF_IconButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.RePoint(self.icon)
end

---@param parent Frame
---@param icon string
---@param width? number
---@param height? number
---@param padding? number default is 0
---@param color? string|table
---@param hoverColor? string|table
---@param filterMode? string
---@param noPushDownEffect? boolean
---@return AF_IconButton
function AF.CreateIconButton(parent, icon, width, height, padding, color, hoverColor, filterMode, noPushDownEffect)
    local b = CreateFrame("Button", nil, parent)
    AF.SetSize(b, width, height)

    b.accentColor = AF.GetAddonAccentColorName()

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("CENTER")
    AF.SetInside(b.icon, b, padding)

    b.icon:SetTexture(icon, nil, nil, filterMode)
    b._iconPath = icon
    b._filterMode = filterMode

    b._color = type(color) == "string" and AF.GetColorTable(color) or (color or AF.GetColorTable("white"))
    b._hoverColor = type(hoverColor) == "string" and AF.GetColorTable(hoverColor) or (hoverColor or AF.GetColorTable("white"))
    b.icon:SetVertexColor(AF.UnpackColor(b._color))

    b:SetScript("OnEnter", function()
        b.icon:SetVertexColor(AF.UnpackColor(b._hoverColor))
        if b._hoverBorder then
            b.border:Show()
        end
    end)
    b:SetScript("OnLeave", function()
        b.icon:SetVertexColor(AF.UnpackColor(b._color))
        if b._hoverBorder then
            b.border:Hide()
        end
    end)
    b:SetScript("OnEnable", function()
        b.icon:SetDesaturated(false)
        b.icon:SetVertexColor(AF.UnpackColor(b._color))
    end)
    b:SetScript("OnDisable", function()
        b.icon:SetDesaturated(true)
        b.icon:SetVertexColor(AF.GetColorRGB("disabled"))
    end)

    Mixin(b, AF_IconButtonMixin)
    Mixin(b, AF_BaseWidgetMixin)

    RegisterMouseDownUp(b)
    b:EnablePushEffect(not noPushDownEffect)
    b.HandleMouseDownText = AF.noop
    b.HandleMouseUpText = AF.noop

    AF.AddToPixelUpdater_OnShow(b)

    return b
end

---------------------------------------------------------------------
-- tips button
---------------------------------------------------------------------
---@class AF_TipsButton:AF_IconButton
local AF_TipsButtonMixin = {}

local function TipsButton_OnEnter(self)
    if not AF.IsEmpty(self.tips) then
        AF.ShowTooltip(self, self.position, self.x, self.y, self.tips)
    end
end

local function TipsButton_OnLeave(self)
    AF.HideTooltip()
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

    tipsButton.accentColor = AF.GetAddonAccentColorName()

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

---@param color string|table
function AF_CheckButtonMixin:SetTextColor(color)
    if type(color) == "string" then
        self.label:SetTextColor(AF.GetColorRGB(color))
    elseif type(color) == "table" then
        self.label:SetTextColor(AF.UnpackColor(color))
    end
end

function AF_CheckButtonMixin:SetTooltip(...)
    AF.SetTooltip(self, "TOPLEFT", 0, 2, ...)
end

function AF_CheckButtonMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)
    AF.RePoint(self.checkedTexture)
    AF.RePoint(self.highlightTexture)
end

function AF_CheckButtonMixin:SetOnCheck(func)
    self.onCheck = func
end

---@param parent Frame
---@param label string|nil
---@param onCheck fun(checked: boolean, cb: AF_CheckButton)
---@return AF_CheckButton cb
function AF.CreateCheckButton(parent, label, onCheck)
    -- InterfaceOptionsCheckButtonTemplate --> FrameXML\InterfaceOptionsPanels.xml line 19
    -- OptionsBaseCheckButtonTemplate -->  FrameXML\OptionsPanelTemplates.xml line 10

    local cb = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    AF.SetSize(cb, 14, 14)

    cb.accentColor = AF.GetAddonAccentColorName()

    cb.onCheck = onCheck
    cb:SetScript("OnClick", function(self)
        PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        if self.onCheck then self.onCheck(self:GetChecked() and true or false, self) end
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
        cb:SetBackdropBorderColor(AF.GetColorRGB("black", 0.5))
    end)

    AF.AddToPixelUpdater_OnShow(cb)

    return cb
end

---------------------------------------------------------------------
-- switch
---------------------------------------------------------------------
---@class AF_Switch:AF_BorderedFrame
local AF_SwitchMixin = {}

---@param value any
---@param force boolean
function AF_SwitchMixin:SetSelectedValue(value, force)
    for _, b in ipairs(self.buttons) do
        if b.value == value then
            if force then
                b.isSelected = nil -- force trigger OnClick
            end
            b:SilentClick()
            break
        end
    end
end
AF_SwitchMixin.SetSelected = AF_SwitchMixin.SetSelectedValue

function AF_SwitchMixin:GetSelectedValue()
    return self.selected
end
AF_SwitchMixin.GetSelected = AF_SwitchMixin.GetSelectedValue

function AF_SwitchMixin:GetSelectedButton()
    for _, b in next, self.buttons do
        if b.isSelected then
            return b
        end
    end
end

---@param callback fun(value: any, labelData: table)
function AF_SwitchMixin:SetOnSelect(callback)
    self.callback = callback
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

function AF_SwitchMixin:SetLabel(label)
    if not self.label then
        self.label = AF.CreateFontString(self, label)
        self.label:SetJustifyH("LEFT")
        AF.SetPoint(self.label, "BOTTOMLEFT", self, "TOPLEFT", 2, 2)
    else
        self.label:SetText(label)
    end
end

---@param labels table {{["text"]=(string), ["value"]=(any), ["callback|onClick"]=(function), ["disabled"]= (boolean|nil)}, ...}
function AF_SwitchMixin:SetLabels(labels)
    if type(labels) ~= "table" then return end

    local switch = self
    switch.labels = labels
    local n = #labels

    local buttons = self.buttons
    for i, b in next, buttons do
        if i > n then
            b:Hide()
            AF.SetHeight(b.highlight, 1)
        end
    end

    local height = self._height

    for i, l in pairs(labels) do
        if not buttons[i] then
            buttons[i] = AF.CreateButton(switch, nil, "none", nil, nil, nil, "", "")

            buttons[i].highlight = AF.CreateTexture(buttons[i], nil, AF.GetColorTable(switch.accentColor, 0.7))
            AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
            AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
            AF.SetHeight(buttons[i].highlight, 1)

            -- fill animation -------------------------------------------
            -- local fill = buttons[i].highlight:CreateAnimationGroup()
            -- buttons[i].fill = fill

            -- fill.t = fill:CreateAnimation("Translation")
            -- fill.t:SetOffset(0, AF.ConvertPixelsForRegion(height / 2 - 1, buttons[i]))
            -- fill.t:SetSmoothing("IN")
            -- fill.t:SetDuration(0.1)

            -- fill.s = fill:CreateAnimation("Scale")
            -- fill.s:SetScaleTo(1, AF.ConvertPixelsForRegion(height - 2, buttons[i]))
            -- fill.s:SetDuration(0.1)
            -- fill.s:SetSmoothing("IN")

            -- fill:SetScript("OnPlay", function()
            --     AF.ClearPoints(buttons[i].highlight)
            --     AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
            --     AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
            -- end)

            -- fill:SetScript("OnFinished", function()
            --     AF.SetHeight(buttons[i].highlight, height - 2)
            --     -- to ensure highlight always fill the whole button exactly
            --     AF.ClearPoints(buttons[i].highlight)
            --     AF.SetPoint(buttons[i].highlight, "TOPLEFT", 1, -1)
            --     AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
            -- end)
            -------------------------------------------------------------

            -- empty animation ------------------------------------------
            -- local empty = buttons[i].highlight:CreateAnimationGroup()
            -- buttons[i].empty = empty

            -- empty.t = empty:CreateAnimation("Translation")
            -- empty.t:SetOffset(0, -AF.ConvertPixelsForRegion(height / 2 - 1, buttons[i]))
            -- empty.t:SetSmoothing("IN")
            -- empty.t:SetDuration(0.1)

            -- empty.s = empty:CreateAnimation("Scale")
            -- empty.s:SetScaleTo(1, 1 / AF.ConvertPixelsForRegion(height - 2, buttons[i]))
            -- empty.s:SetDuration(0.1)
            -- empty.s:SetSmoothing("IN")

            -- empty:SetScript("OnPlay", function()
            --     AF.ClearPoints(buttons[i].highlight)
            --     AF.SetPoint(buttons[i].highlight, "BOTTOMLEFT", 1, 1)
            --     AF.SetPoint(buttons[i].highlight, "BOTTOMRIGHT", -1, 1)
            -- end)

            -- empty:SetScript("OnFinished", function()
            --     AF.SetHeight(buttons[i].highlight, 1)
            -- end)
            -------------------------------------------------------------

            buttons[i]:SetScript("OnClick", function(self)
                -- if self.isSelected or fill:IsPlaying() or empty:IsPlaying() then return end
                if self.isSelected then return end

                AF.AnimatedResize(self.highlight, nil, AF.ConvertPixelsForRegion(height, self) - AF.ConvertPixelsForRegion(1, self) * 2, 0.017, 5)
                self.isSelected = true
                switch.selected = self.value

                -- deselect others
                for j, b in next, buttons do
                    if j ~= i and b:IsVisible() then
                        if b.isSelected then
                            AF.AnimatedResize(b.highlight, nil, 1, 0.017, 5)
                        end
                        b.isSelected = false
                    end
                end

                local callback = switch.labels[i].onClick or switch.labels[i].callback
                if callback then
                    callback(self.value)
                elseif switch.callback then
                    switch.callback(self.value, switch.labels[i])
                end
            end)

            buttons[i]:SetScript("OnEnter", function()
                switch:GetScript("OnEnter")()
            end)

            buttons[i]:SetScript("OnLeave", function()
                switch:GetScript("OnLeave")()
            end)
        end

        buttons[i]:SetEnabled(not labels[i].disabled)

        -- reset
        buttons[i].value = labels[i].value or labels[i].text
        if buttons[i].isSelected then
            AF.AnimatedResize(buttons[i].highlight, nil, 1, 0.02, 5)
            buttons[i].isSelected = false
        end

        -- text
        buttons[i]:SetText(labels[i].text)

        -- height
        AF.SetHeight(buttons[i], height)

        -- point
        AF.ClearPoints(buttons[i])
        if i == 1 then
            AF.SetPoint(buttons[i], "TOPLEFT")
        elseif i == n then
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i - 1], "TOPRIGHT", -1, 0)
            AF.SetPoint(buttons[i], "TOPRIGHT")
        else
            AF.SetPoint(buttons[i], "TOPLEFT", buttons[i - 1], "TOPRIGHT", -1, 0)
        end

        -- show
        buttons[i]:Show()
    end

    self:AutoResizeLabels()
end

function AF_SwitchMixin:AutoResizeLabels()
    local n = #self.labels
    local width = self:GetWidth() + AF.ConvertPixelsForRegion(1, self) * (n - 1)

    if n == 0 then return end
    local labelWidth = width / n
    for i, b in next, self.buttons do
        if b:IsShown() then
            b:SetSize(labelWidth, AF.ConvertPixelsForRegion(self._height, self))
        end
    end
end

---@param parent Frame
---@param width? number
---@param height? number default is 20
---@return AF_Switch switch
function AF.CreateSwitch(parent, width, height)
    local switch = AF.CreateBorderedFrame(parent, nil, width, height or 20, "widget")

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

    -- switch:SetLabels(labels)

    AF.AddToPixelUpdater_OnShow(switch)

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