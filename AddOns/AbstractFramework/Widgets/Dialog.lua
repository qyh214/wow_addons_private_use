---@class AbstractFramework
local AF = _G.AbstractFramework
local L = AF.L

local YES = AF.L["Yes"]
local NO = AF.L["No"]
local OKAY = AF.L["Okay"]
local CANCEL = AF.L["Cancel"]
local GOT_IT = AF.L["Got It"]
local GOT_IT_COUNTDOWN = GOT_IT .. " (%d)"

---------------------------------------------------------------------
-- dialog
---------------------------------------------------------------------
local dialogPool

---@class AF_Dialog:AF_BorderedFrame
local AF_DialogMixin = {}

---@param enabled boolean
function AF_DialogMixin:EnableYes(enabled)
    self.yes:SetEnabled(enabled)
end

---@param enabled boolean
function AF_DialogMixin:EnableNo(enabled)
    self.no:SetEnabled(enabled)
end

function AF_DialogMixin:SetToYesNo()
    self.yes:SetText(YES)
    self.no:SetText(NO)
    AF.SetWidth(self.yes, 50)
    AF.SetWidth(self.no, 50)
end

function AF_DialogMixin:SetToOkayCancel()
    self.yes:SetText(OKAY)
    self.no:SetText(CANCEL)
    AF.SetWidth(self.yes, 70)
    AF.SetWidth(self.no, 70)
end

---@param yesText string
---@param noText string
---@param buttonWidth? number
function AF_DialogMixin:SetToCustom(yesText, noText, buttonWidth)
    self.yes:SetText(yesText)
    self.no:SetText(noText)
    AF.SetWidth(self.yes, buttonWidth or 50)
    AF.SetWidth(self.no, buttonWidth or 50)
end

-- content.dialog will be set to the owner dialog
---@param content Frame content must have valid height (width is relative to the dialog)
---@param height? number content height can also be set here
function AF_DialogMixin:SetContent(content, height)
    content.dialog = self
    self.content = content
    content:SetParent(self.contentHolder)
    content:SetPoint("TOPLEFT", self.contentHolder)
    content:SetPoint("TOPRIGHT", self.contentHolder)
    if height then
        AF.SetHeight(content, height)
    end
    content:Show()
end

-- onConfirm
function AF_DialogMixin:SetOnConfirm(fn)
    self.onConfirm = fn
end

-- onCancel
function AF_DialogMixin:SetOnCancel(fn)
    self.onCancel = fn
end

-- update pixels
function AF_DialogMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)

    self:UpdateHeight()

    if self.minButtonWidth then
        AF.ResizeDialogButtonToFitText(self.minButtonWidth)
    end
end

function AF_DialogMixin:UpdateHeight()
    self:SetScript("OnUpdate", function()
        if self.text:GetText() then
            --! NOTE: text width must be set, and its x/y offset should be 0 (not sure), or WEIRD ISSUES would a appear.
            self.text:SetWidth(AF.Round(self:GetWidth() - 14))
            self.textHolder:SetHeight(AF.Round(self.text:GetStringHeight()))
        end
        if self.content then
            self.contentHolder:SetHeight(AF.Round(self.content:GetHeight()))
        end
        self:SetHeight(AF.Round(self.textHolder:GetHeight() + self.contentHolder:GetHeight()) + 40)
        self:SetScript("OnUpdate", nil)
    end)
end

local function Dialog_OnShow(self)
    self:UpdateHeight()

    -- accent color system
    local r, g, b = AF.GetColorRGB(self.accentColor)
    self:SetBackdropBorderColor(r, g, b)
    self.yes:SetBackdropBorderColor(r, g, b)
    self.no:SetBackdropBorderColor(r, g, b)
end

local function Dialog_OnHide(self)
    self:Hide()
    AF.ClearPoints(self)

    -- reset
    self.minButtonWidth = nil
    self.onConfirm = nil
    self.onCancel = nil

    -- reset text
    self.text:SetText()
    self.textHolder:SetHeight(0)

    -- reset content
    if self.content then
        self.content:ClearAllPoints()
        self.content:Hide()
        self.content = nil
    end
    self.contentHolder:SetHeight(0)

    -- reset button
    self.yes:SetEnabled(true)
    self:SetToYesNo()

    -- hide mask
    if self.shownMask then
        self.shownMask:Hide()
        self.shownMask = nil
    end

    -- reset shadow
    AF.ShowNormalGlow(self, "shadow", 2)

    -- release
    dialogPool:Release(self)
end

dialogPool = AF.CreateObjectPool(function()
    local dialog = AF.CreateBorderedFrame(AF.UIParent, nil, 200, 100)
    dialog:Hide() -- for first OnShow

    AF.ShowNormalGlow(dialog, "shadow", 2)
    dialog:EnableMouse(true)

    -- text holder
    local textHolder = AF.CreateFrame(dialog)
    dialog.textHolder = textHolder
    AF.SetPoint(textHolder, "TOPLEFT", 7, -9)
    AF.SetPoint(textHolder, "TOPRIGHT", -7, -9)

    local text = AF.CreateFontString(textHolder)
    dialog.text = text
    AF.SetPoint(text, "TOPLEFT")
    AF.SetPoint(text, "TOPRIGHT")
    text:SetWordWrap(true)
    text:SetSpacing(3)

    -- frame holder
    local contentHolder = AF.CreateFrame(dialog)
    dialog.contentHolder = contentHolder
    AF.SetPoint(contentHolder, "TOPLEFT", textHolder, "BOTTOMLEFT", 7, -7)
    AF.SetPoint(contentHolder, "TOPRIGHT", textHolder, "BOTTOMRIGHT", -7, -7)

    -- no
    local no = AF.CreateButton(dialog, NO, "red", 50, 17)
    dialog.no = no
    AF.SetPoint(no, "BOTTOMRIGHT")
    no:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    AF.ClearPoints(no.text)
    AF.SetPoint(no.text, "CENTER")
    no:SetScript("OnClick", function()
        if dialog.onCancel then dialog.onCancel() end
        dialog:Hide()
    end)

    -- yes
    local yes = AF.CreateButton(dialog, YES, "green", 50, 17)
    dialog.yes = yes
    AF.SetPoint(yes, "BOTTOMRIGHT", no, "BOTTOMLEFT", 1, 0)
    yes:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    AF.ClearPoints(yes.text)
    AF.SetPoint(yes.text, "CENTER")
    yes:SetScript("OnClick", function()
        if dialog.onConfirm then dialog.onConfirm() end
        dialog:Hide()
    end)

    -- script
    dialog:SetScript("OnShow", Dialog_OnShow)
    dialog:SetScript("OnHide", Dialog_OnHide)

    -- mixin
    Mixin(dialog, AF_DialogMixin)

    return dialog
end)

---@param dialog AF_Dialog
---@return boolean
function AF.IsDialogActive(dialog)
    return dialog and dialogPool:IsActive(dialog)
end

---@param parent Frame
---@param text string
---@param width? number default 200
---@param noMask? boolean
---@return AF_Dialog dialog
function AF.GetDialog(parent, text, width, noMask)
    local dialog = dialogPool:Acquire()

    dialog.accentColor = AF.GetAddonAccentColorName()

    dialog:SetParent(parent)
    AF.SetFrameLevel(dialog, 150, parent)
    AF.SetWidth(dialog, width or 200)

    dialog.text:SetText(text)

    if not noMask then
        dialog.shownMask = AF.ShowMask(parent)
    end

    dialog:Show()

    return dialog
end

---------------------------------------------------------------------
-- message dialog
---------------------------------------------------------------------
local messageDialogPool

---@class AF_MessageDialog:AF_BorderedFrame
local AF_MessageDialogMixin = {}

function AF_MessageDialogMixin:UpdatePixels()
    AF.ReSize(self)
    AF.RePoint(self)
    AF.ReBorder(self)

    self:UpdateHeight()
end

function AF_MessageDialogMixin:UpdateHeight()
    self:SetScript("OnUpdate", function()
        if self.text:GetText() then
            --! NOTE: text width must be set, and its x/y offset should be 0 (not sure), or WEIRD ISSUES would a appear.
            self.text:SetWidth(AF.Round(self:GetWidth() - 14))
            self.textHolder:SetHeight(AF.Round(self.text:GetStringHeight()))
        end
        self:SetHeight(AF.Round(self.textHolder:GetHeight()) + 40)
        self:SetScript("OnUpdate", nil)
    end)
end

local function MessageDialog_OnShow(self)
    self:UpdateHeight()

    -- accent color system
    self:SetBackdropBorderColor(AF.GetColorRGB(self.accentColor, 1))
    self.close:SetColor(self.accentColor)
end

local function MessageDialog_OnHide(self)
    self:Hide()
    AF.ClearPoints(self)

    -- reset text
    self.text:SetText()
    self.textHolder:SetHeight(0)

    -- reset timer
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end

    -- hide mask
    if self.shownMask then
        self.shownMask:Hide()
        self.shownMask = nil
    end

    -- reset shadow
    AF.ShowNormalGlow(self, "shadow", 2)

    -- release
    messageDialogPool:Release(self)
end

messageDialogPool = AF.CreateObjectPool(function()
    local messageDialog = AF.CreateBorderedFrame(AF.UIParent, nil, 200, 100)
    messageDialog:Hide() -- for first OnShow

    AF.ShowNormalGlow(messageDialog, "shadow", 2)
    messageDialog:EnableMouse(true)

    -- text holder
    local textHolder = AF.CreateFrame(messageDialog)
    messageDialog.textHolder = textHolder
    AF.SetPoint(textHolder, "TOPLEFT", 7, -7)
    AF.SetPoint(textHolder, "TOPRIGHT", -7, -7)

    local text = AF.CreateFontString(textHolder)
    messageDialog.text = text
    AF.SetPoint(text, "TOPLEFT")
    AF.SetPoint(text, "TOPRIGHT")
    text:SetWordWrap(true)
    text:SetSpacing(3)

    -- close
    local close = AF.CreateButton(messageDialog, GOT_IT, "accent", 17, 17)
    messageDialog.close = close
    AF.SetPoint(close, "BOTTOMLEFT", 5, 5)
    AF.SetPoint(close, "BOTTOMRIGHT", -5, 5)
    close:SetScript("OnClick", function()
        messageDialog:Hide()
    end)

    -- script
    messageDialog:SetScript("OnShow", MessageDialog_OnShow)
    messageDialog:SetScript("OnHide", MessageDialog_OnHide)

    -- mixin
    Mixin(messageDialog, AF_MessageDialogMixin)

    return messageDialog
end)

---@param parent Frame
---@param text string
---@param width? number default 200
---@param noMask? boolean
---@param countdown? number
---@return AF_MessageDialog
function AF.GetMessageDialog(parent, text, width, noMask, countdown)
    local messageDialog = messageDialogPool:Acquire()

    messageDialog.accentColor = AF.GetAddonAccentColorName()

    messageDialog:SetParent(parent)
    AF.SetFrameLevel(messageDialog, 150, parent)
    AF.SetWidth(messageDialog, width or 200)

    messageDialog.text:SetText(text)

    if not noMask then
        messageDialog.shownMask = AF.ShowMask(parent)
    end

    if countdown then
        messageDialog.close:SetEnabled(false)
        messageDialog.close:SetFormattedText(GOT_IT_COUNTDOWN, countdown)
        messageDialog.timer = C_Timer.NewTicker(1, function()
            messageDialog.timer = nil
            countdown = countdown - 1
            if countdown == 0 then
                messageDialog.close:SetText(GOT_IT)
                messageDialog.close:SetEnabled(true)
            else
                messageDialog.close:SetFormattedText(GOT_IT_COUNTDOWN, countdown)
            end
        end, countdown)
    else
        messageDialog.close:SetEnabled(true)
    end

    messageDialog:Show()

    return messageDialog
end

---------------------------------------------------------------------
-- global dialog
---------------------------------------------------------------------
local ceil, max = math.ceil, math.max
local globalDialog
local globalDialogQueue = AF.NewQueue()

local function globalDialog_UpdateHeight()
    globalDialog.elapsed = 0
    globalDialog:SetScript("OnUpdate", function(self, elapsed)
        self:SetHeight(max(AF.CeilToEven(self.text:GetStringHeight()), 40) + 15 + 15 + 22)
    end)
end

local function GlobalDialog_OnShow()
    globalDialog_UpdateHeight()
    globalDialog.showUpAnimation:Play()
    AF.PlaySound("smooth_alert1")
end

local function GlobalDialog_OnHide()
    if globalDialog.mask:IsShown() then
        AF.FrameFadeOut(globalDialog.mask, nil, nil, nil, true)
    end
    globalDialog.yes.highlight:SetHeight(0.001)
    globalDialog.no.highlight:SetHeight(0.001)
    C_Timer.After(0.5, globalDialog.ShowNext)
end

local function GlobalDialog_ShowNext()
    if globalDialogQueue:isEmpty() then
        globalDialog:Hide()
        return
    end

    if globalDialog:IsShown() then
        return
    end

    local dialogData = globalDialogQueue:pop()

    globalDialog.text:SetText(dialogData.text)
    globalDialog.onConfirm = dialogData.onConfirm
    globalDialog.onCancel = dialogData.onCancel

    if dialogData.showMask then
        if not globalDialog.mask:IsShown() then
            AF.FrameFadeIn(globalDialog.mask, nil, 0, 1)
        end
    elseif globalDialog.mask:IsShown() then
        AF.FrameFadeOut(globalDialog.mask, nil, nil, nil, true)
    end

    if dialogData.yesText then
        globalDialog.yes:SetText(dialogData.yesText)
    else
        globalDialog.yes:SetText(OKAY)
    end

    if dialogData.noText then
        globalDialog.no:SetText(dialogData.noText)
    else
        globalDialog.no:SetText(CANCEL)
    end

    globalDialog:Show()
end

local function CreateButtonHighlight(button, color1, color2)
    button.highlight = AF.CreateGradientTexture(button, "VERTICAL", color1, color2)
    button.highlight:SetPoint("BOTTOMLEFT")
    button.highlight:SetPoint("BOTTOMRIGHT")
    button.highlight:SetHeight(0.001)
    button.highlight:Hide()

    button:SetOnEnter(function(self)
        self.highlight:Show()
        AF.FrameResizeHeight(self.highlight, 0.1, nil, self:GetHeight())
    end)
    button:SetOnLeave(function(self)
        self.highlight:Hide()
        AF.FrameResizeHeight(self.highlight, 0.1, nil, 0)
    end)
end

-- local function GlobalDialog_OnHide(dialog)
--     dialog.yes.highlight:SetHeight(0.001)
--     dialog.no.highlight:SetHeight(0.001)
-- end

-- local function CreateButtonHighlight(button, color1, color2)
--     if button.isLeft then
--         button.highlight = AF.CreateGradientTexture(button, "HORIZONTAL", color2, color1)
--         button.highlight:SetPoint("TOPRIGHT")
--         button.highlight:SetPoint("BOTTOMRIGHT")
--     else
--         button.highlight = AF.CreateGradientTexture(button, "HORIZONTAL", color1, color2)
--         button.highlight:SetPoint("TOPLEFT")
--         button.highlight:SetPoint("BOTTOMLEFT")
--     end
--     button.highlight:SetWidth(0.001)
--     button.highlight:Hide()

--     button:SetOnEnter(function(self)
--         self.highlight:Show()
--         AF.FrameResizeWidth(self.highlight, 0.1, nil, self:GetWidth())
--     end)
--     button:SetOnLeave(function(self)
--         self.highlight:Hide()
--         AF.FrameResizeWidth(self.highlight, 0.1, nil, 0)
--     end)
-- end

local function CreateGlobalDialog()
    globalDialog = AF.CreateBorderedFrame(AF.UIParent, "AFGlobalDialog", 310)
    globalDialog:Hide()
    globalDialog:SetPoint("BOTTOM", AF.UIParent, "CENTER", 0, 15)
    globalDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    globalDialog:SetFrameLevel(7)
    -- globalDialog:SetBackdropColor(AF.GetColorRGB("background", 0.95))
    globalDialog:EnableMouse(true)

    -- mask
    local mask = AF.CreateFrame(AF.UIParent)
    globalDialog.mask = mask
    AF.ApplyDefaultBackdrop_NoBorder(mask)
    mask:SetBackdropColor(AF.GetColorRGB("mask"))
    mask:EnableMouse(true)
    mask:SetScript("OnMouseWheel", AF.noop)
    mask:SetAllPoints(AF.UIParent)
    mask:SetFrameStrata("FULLSCREEN_DIALOG")
    mask:SetFrameLevel(1)
    mask:Hide()

    -- showUpAnimation
    local showUpAnimation = globalDialog:CreateAnimationGroup()
    globalDialog.showUpAnimation = showUpAnimation

    showUpAnimation:SetScript("OnFinished", function()
        globalDialog:SetPoint("BOTTOM", AF.UIParent, "CENTER")
    end)

    local moveDown = showUpAnimation:CreateAnimation("Translation")
    moveDown:SetOffset(0, -15)
    moveDown:SetDuration(0.1)
    moveDown:SetSmoothing("OUT")
    moveDown:SetOrder(1)

    local fadeIn = showUpAnimation:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.1)
    fadeIn:SetSmoothing("OUT")
    fadeIn:SetOrder(1)

    -- hideOutAnimation
    local hideOutAnimation = globalDialog:CreateAnimationGroup()
    globalDialog.hideOutAnimation = hideOutAnimation

    hideOutAnimation:SetScript("OnFinished", function()
        globalDialog:Hide()
        globalDialog:SetPoint("BOTTOM", AF.UIParent, "CENTER", 0, 15)
    end)

    local moveUp = hideOutAnimation:CreateAnimation("Translation")
    moveUp:SetOffset(0, 15)
    moveUp:SetDuration(0.1)
    moveUp:SetSmoothing("IN")
    moveUp:SetOrder(1)

    local fadeOut = hideOutAnimation:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.1)
    fadeOut:SetSmoothing("IN")
    fadeOut:SetOrder(1)


    -- decoration
    local border = AF.CreateBorderedFrame(globalDialog, nil, nil, nil, "none", "accent")
    AF.SetOnePixelOutside(border, globalDialog)
    AF.RemoveFromPixelUpdater(border)

    AF.ShowNormalGlow(border, "shadow", 2)

    local bottomBG = AF.CreateTexture(globalDialog, nil, AF.GetColorTable("accent", 0.1))
    AF.SetPoint(bottomBG, "BOTTOMLEFT", globalDialog, 1, 1)
    AF.SetPoint(bottomBG, "BOTTOMRIGHT", globalDialog, -1, 1)
    AF.SetHeight(bottomBG, 22)
    AF.RemoveFromPixelUpdater(bottomBG)

    local bottomLine = AF.CreateTexture(globalDialog, nil, "border")
    bottomLine:SetPoint("BOTTOMLEFT", bottomBG, "TOPLEFT")
    bottomLine:SetPoint("BOTTOMRIGHT", bottomBG, "TOPRIGHT")
    AF.SetHeight(bottomLine, 1)
    AF.RemoveFromPixelUpdater(bottomLine)

    -- text
    local text = AF.CreateFontString(globalDialog)
    globalDialog.text = text
    AF.SetPoint(text, "TOPLEFT", 15, -15)
    AF.SetPoint(text, "TOPRIGHT", -15, -15)
    -- AF.SetPoint(text, "BOTTOM", bottomBG, "TOP", 0, 15)
    text:SetJustifyH("CENTER")
    -- text:SetJustifyV("MIDDLE")
    text:SetWordWrap(true)
    text:SetSpacing(5)
    AF.RemoveFromPixelUpdater(text)

    -- yes
    local yes = AF.CreateButton(globalDialog, OKAY, "none", nil, nil, nil, "", "")
    globalDialog.yes = yes
    yes:SetPoint("TOPLEFT", bottomBG)
    yes:SetPoint("BOTTOMRIGHT", bottomBG, "BOTTOM")
    yes.isLeft = true
    CreateButtonHighlight(yes, AF.GetColorTable("green", 0.8), AF.GetColorTable("green", 0.1))
    yes:SetOnClick(function()
        if globalDialog.onConfirm then
            globalDialog.onConfirm()
        end
        hideOutAnimation:Play()
    end)
    AF.RemoveFromPixelUpdater(yes)

    -- no
    local no = AF.CreateButton(globalDialog, CANCEL, "none", nil, nil, nil, "", "")
    globalDialog.no = no
    no:SetPoint("BOTTOMLEFT", bottomBG, "BOTTOM")
    no:SetPoint("TOPRIGHT", bottomBG)
    CreateButtonHighlight(no, AF.GetColorTable("red", 0.8), AF.GetColorTable("red", 0.1))
    no:SetOnClick(function()
        if globalDialog.onCancel then
            globalDialog.onCancel()
        end
        hideOutAnimation:Play()
    end)
    AF.RemoveFromPixelUpdater(no)

    -- OnShow/OnHide
    globalDialog:SetOnShow(GlobalDialog_OnShow)
    globalDialog:SetOnHide(GlobalDialog_OnHide)

    -- show next
    globalDialog.ShowNext = GlobalDialog_ShowNext

    -- pixel perfect
    AF.AddToPixelUpdater_Auto(globalDialog, function()
        AF.ReBorder(globalDialog)
        AF.ReSize(globalDialog)
        globalDialog_UpdateHeight()

        AF.RePoint(border)
        AF.ReBorder(border)

        AF.RePoint(bottomBG)
        AF.ReSize(bottomBG)

        AF.ReSize(bottomLine)

        AF.RePoint(text)
    end)
end

function AF.ShowGlobalDialog(text, onConfirm, onCancel, showMask, yesText, noText)
    if AF.IsBlank(text) then return end

    globalDialogQueue:push({
        text = text,
        onConfirm = onConfirm,
        onCancel = onCancel,
        showMask = showMask,
        yesText = yesText,
        noText = noText,
    })

    if not globalDialog then
        CreateGlobalDialog()
    end

    globalDialog.ShowNext()
end