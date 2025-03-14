local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 字体
local ImprovedAddonListLabelFont = CreateFont("ImprovedAddonListLabelFont")
ImprovedAddonListLabelFont:CopyFontObject(GameFontWhite)
ImprovedAddonListLabelFont:SetTextColor(0.8039, 0.6039, 0.3568)

local ImprovedAddonListBodyFont = CreateFont("ImprovedAddonListBodyFont")
ImprovedAddonListBodyFont:CopyFontObject(GameFontWhite)
ImprovedAddonListBodyFont:SetJustifyH("LEFT")

local ImprovedAddonListButtonNormalFont = CreateFont("ImprovedAddonListButtonNormalFont")
ImprovedAddonListButtonNormalFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonNormalFont:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

local ImprovedAddonListButtonHighlightFont = CreateFont("ImprovedAddonListButtonHighlightFont")
ImprovedAddonListButtonHighlightFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonHighlightFont:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())

local ImprovedAddonListButtonDisabledFont = CreateFont("ImprovedAddonListButtonDisabledFont")
ImprovedAddonListButtonDisabledFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonDisabledFont:SetTextColor(DISABLED_FONT_COLOR:GetRGB())

-- 创建对话框
function Addon:CreateDialog(name, parent)
    local dialog = CreateFrame("Frame", name, parent, "PortraitFrameTemplate")
    ButtonFrameTemplateMinimizable_HidePortrait(dialog)
    dialog.TitleContainer:ClearAllPoints()
    dialog.TitleContainer:SetPoint("TOPLEFT", 1, -1)
    dialog.TitleContainer:SetPoint("TOPRIGHT", -1, -1)
    dialog.CloseButton:SetFrameLevel(dialog.TitleContainer:GetFrameLevel() + 1)

    -- 响应Escape
    local function OnEscapePressed(self, key)
        if InCombatLockdown() then
            -- 战斗中，按下任意按键都隐藏面板
            -- 因为SetPropagateKeyboardInput战斗中无法调用
            self:Hide()
        else
            if key == "ESCAPE" then
                self:SetPropagateKeyboardInput(false)
                self:Hide()
            else
                self:SetPropagateKeyboardInput(true)
            end
        end
    end
    
    dialog:SetScript("OnKeyDown", OnEscapePressed)
    dialog:SetMouseMotionEnabled(true)
    dialog:SetMouseClickEnabled(true)

    -- 拖动
    dialog:SetMovable(true)
    dialog.TitleContainer:EnableMouse(true)
    dialog.TitleContainer:RegisterForDrag("LeftButton")
    dialog:SetClampedToScreen(true)
    dialog.TitleContainer:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
        self:GetParent():SetUserPlaced(false)
    end)
    dialog.TitleContainer:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)

    return dialog
end

-- 创建带背景和边框的容器
function Addon:CreateContainer(parent)
    local Container = CreateFrame("Frame", nil, parent)

    -- 背景
    local Background = Container:CreateTexture(nil, "BACKGROUND")
    Background:SetAtlas("Professions-background-summarylist")
    Background:SetAllPoints()
    Container.Background = Background

    -- 边框
    local BackgroundNineSlice = CreateFrame("Frame", nil, Container, "NineSlicePanelTemplate")
    BackgroundNineSlice.layoutType = "InsetFrameTemplate"
    BackgroundNineSlice:SetAllPoints(Background)
    BackgroundNineSlice:SetFrameLevel(Container:GetFrameLevel())
    BackgroundNineSlice:OnLoad()
    Container.BackgroundNineSlice = BackgroundNineSlice

    return Container
end

-- 获取环境信息
local function GetEnvInfo()
    local patch, build, date, tocNumber = GetBuildInfo()
    local clientBit = Is64BitClient() and "64" or "32"

    -- 系统
    local system
    if IsWindowsClient() then
        system = "Windows"
    elseif IsMacClient() then
        system = "Mac"
        clientBit = ""
    elseif IsLinuxClient() then
        system = "Linux"
    else
        system = "Unknown"
    end

    -- 游戏版本，虽然并没有判断的必要，因为本插件只支持正式服
    local flavor
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        flavor = "Retail"
    elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        flavor = "Classic"
    elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
        flavor = "Wotlk"
    elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
        flavor = "Cata"
    else
        flavor = "Unknown"
    end

    return format("%s.%d(%s) on %s %s\nBuild on %s, current toc version:%s", patch, build, flavor, system, clientBit, date, tocNumber)
end

-- 启用过期插件按钮选中变化
local function OnEnableExpiredAddonsButtonCheckedChange(self)
    if self:GetChecked() then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        C_AddOns.SetAddonVersionCheck(false);
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        C_AddOns.SetAddonVersionCheck(true);
    end
    Addon:UpdateAddonInfos()
    Addon:RefreshAddonListContainer()
end

-- 重载插件指示器：鼠标划入
local function OnReloadUIIndicatorEnter(self)
    local addons = {}
    for _, name in ipairs(Addon:GetAddonNamesShouldReload()) do
        table.insert(addons, { Name = name })
    end

    local addonListTooltipInfo = {
        Addons = addons,
        Label = L["reload_ui_tips_title"]
    }
    Addon:ShowAddonListTooltips(self, addonListTooltipInfo)
end

-- 重载插件指示器：鼠标移出
local function OnReloadUIIndicatorLeave(self)
    Addon:HideAddonListTooltips()
end

local function OnUIScaleChanged(self)
    self:GetOrCreateUI():SetScale(self:GetUIScale())
end

-- UI函数
function Addon:GetOrCreateUI()
    local UI = self.UI
    if UI then return UI end

    -- 创建UI
    UI = self:CreateDialog("ImprovedAddonListDialog", UIParent)
    self.UI = UI

    -- 基本样式
    UI:SetSize(630, 600)
    UI:ClearAllPoints()
    UI:SetPoint("CENTER")
    UI:SetTitle(ADDON_LIST)
    UI:SetFrameStrata("HIGH")
    UI:SetScale(self:GetUIScale())

    -- 启用过期插件按钮
    local EnableExpiredAddonsButton = CreateFrame("CheckButton", nil, UI, "UICheckButtonTemplate")
    UI.EnableExpiredAddonsButton = EnableExpiredAddonsButton
    EnableExpiredAddonsButton:SetSize(26, 26)
    EnableExpiredAddonsButton.text:SetFontObject(GameFontWhite)
    EnableExpiredAddonsButton.text:SetText(ADDON_FORCE_LOAD)
    EnableExpiredAddonsButton:SetChecked(not C_AddOns.IsAddonVersionCheckEnabled())
    EnableExpiredAddonsButton:SetPoint("TOPRIGHT", -(EnableExpiredAddonsButton.text:GetStringWidth() + 20), -30)
    EnableExpiredAddonsButton:SetScript("OnClick", OnEnableExpiredAddonsButtonCheckedChange)

    -- 重载界面按钮
    local ReloadUIButton = CreateFrame("Button", nil, UI, "SharedButtonSmallTemplate")
    UI.ReloadUIButton = ReloadUIButton
    ReloadUIButton:SetSize(120, 22)
    ReloadUIButton:SetText(RELOADUI)
    ReloadUIButton:SetPoint("BOTTOMRIGHT", -10, 10)
    -- 点击重载界面
    ReloadUIButton:SetScript("OnClick", function() ReloadUI() end)

    -- 重载界面指示器
    local ReloadUIIndicator = CreateFrame("Button", nil, UI)
    UI.ReloadUIIndicator = ReloadUIIndicator
    ReloadUIIndicator:SetSize(16, 16)
    ReloadUIIndicator:SetNormalTexture("Interface\\AddOns\\ImprovedAddonList\\Media\\reload_indicator.png")
    ReloadUIIndicator:SetHighlightTexture("Interface\\AddOns\\ImprovedAddonList\\Media\\reload_indicator.png")
    ReloadUIIndicator:GetHighlightTexture():SetAlpha(0.2)
    ReloadUIIndicator:SetPoint("RIGHT", ReloadUIButton, "LEFT", -8, 0)
    ReloadUIIndicator:SetScript("OnEnter", OnReloadUIIndicatorEnter)
    ReloadUIIndicator:SetScript("OnLeave", OnReloadUIIndicatorLeave)
    -- 动画
    local Animation = ReloadUIIndicator:CreateAnimationGroup()
    Animation:SetLooping("BOUNCE")
    ReloadUIIndicator.Animation = Animation
    local alpha = Animation:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(1.5)

    -- 游戏Build信息
    local BuildInfo = UI:CreateFontString(nil, nil, "GameFontDisableTiny")
    UI.BuildInfo = BuildInfo
    BuildInfo:SetJustifyH("LEFT")
    BuildInfo:SetPoint("BOTTOMLEFT", 10, 10)
    BuildInfo:SetText(GetEnvInfo())

    -- 插件集
    local AddonSetContainer = CreateFrame("Frame", nil, UI)
    UI.AddonSetContainer = AddonSetContainer
    AddonSetContainer:SetSize(280, 24)
    AddonSetContainer:SetPoint("TOPLEFT", 10, -32)

    -- 创建插件列表页
    local AddonListContainer = self:CreateContainer(UI)
    UI.AddonListContainer = AddonListContainer
    AddonListContainer:SetWidth(300)
    AddonListContainer:SetPoint("BOTTOMLEFT", 10, 40)
    AddonListContainer:SetPoint("TOPLEFT", 10, -60)

    -- 创建插件详情页
    local AddonDetailContainer = self:CreateContainer(UI)
    UI.AddonDetailContainer = AddonDetailContainer
    AddonDetailContainer:SetWidth(300)
    AddonDetailContainer:SetPoint("TOPLEFT", AddonListContainer, "TOPRIGHT", 10, 0)
    AddonDetailContainer:SetPoint("BOTTOMLEFT", AddonListContainer, "BOTTOMRIGHT", 10, 0)

    -- 初始化
    self:OnAddonDetailContainerLoad()
    self:OnAddonSetContainerLoad()
    self:OnAddonListContainerLoad()

    self:RegisterCallback("AddonSettings.UIScale", OnUIScaleChanged, self)

    return UI
end

local EditDialogMinxin = {}

function EditDialogMinxin:Init()
    self:SetWidth(280)
    self:SetPoint("CENTER")
    self:SetFrameStrata("DIALOG")
    self:SetFrameLevel(1000)
    self:SetMouseMotionEnabled(true)
    self:SetMouseClickEnabled(true)

    CreateFrame("Frame", nil, self, "DialogBorderDarkTemplate")

    local Title = self:CreateFontString(nil, nil, "ImprovedAddonListButtonNormalFont")
    self.Title = Title
    Title:SetWidth(250)
    Title:SetPoint("TOP", 0, -15)

    local Label = self:CreateFontString(nil, nil, "ImprovedAddonListButtonHighlightFont")
    self.Label = Label
    Label:SetPoint("TOP", Title, "BOTTOM", 0, -15)
    Label:SetWidth(250)
    Label:SetHeight(0)

    local EditBoxLayer = self:CreateTexture()
    EditBoxLayer:SetTexture("Interface\\AddOns\\ImprovedAddonList\\Media\\input_background.png")
    EditBoxLayer:SetVertexColor(DISABLED_FONT_COLOR:GetRGB())
    EditBoxLayer:SetTextureSliceMargins(24, 24, 24, 24)
    EditBoxLayer:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
    EditBoxLayer:SetPoint("TOP", Label, "BOTTOM", 0, -15)
    EditBoxLayer:SetPoint("LEFT", 15, 0)
    EditBoxLayer:SetPoint("RIGHT", -15, 0)
    self.EditBoxLayer = EditBoxLayer

    local EditBox = CreateFrame("Frame", nil, self, "ScrollingEditBoxTemplate")
    EditBox:SetPoint("TOPLEFT", EditBoxLayer, 8, -8)
    EditBox:SetPoint("BOTTOMRIGHT", EditBoxLayer, -8, 8)
    self.EditBox = EditBox

    self.EditBox:GetEditBox():HookScript("OnEditFocusGained", function(editBox)
        editBox:SetCursorPosition(strlenutf8(editBox:GetText() or ""))
        self.EditBoxLayer:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
    end)

    self.EditBox:GetEditBox():HookScript("OnEditFocusLost", function()
        self.EditBoxLayer:SetVertexColor(DISABLED_FONT_COLOR:GetRGB())
    end)

    local CancelButton = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate, UIButtonTemplate")
    self.CancelButton = CancelButton
    CancelButton:SetText(CANCEL)
    CancelButton:SetPoint("LEFT", 15, 0)
    CancelButton:SetPoint("RIGHT", EditBoxLayer, "CENTER", -6, 0)
    CancelButton:SetPoint("TOP", EditBoxLayer, "BOTTOM", 0, -15)
    CancelButton:SetScript("OnClick", function()
        self:Hide()
    end)

    local AcceptButton = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate, UIButtonTemplate")
    self.AcceptButton = AcceptButton
    AcceptButton:SetText(SAVE)
    AcceptButton:SetPoint("RIGHT", -15, 0)
    AcceptButton:SetPoint("LEFT", EditBoxLayer, "CENTER", 6, 0)
    AcceptButton:SetPoint("TOP", EditBoxLayer, "BOTTOM", 0, -15)
    AcceptButton:SetScript("OnClick", function(btn)
        if self.OnConfirm and self.OnConfirm(self.EditBox:GetInputText()) then
            self:Hide()
        end
    end)

    self:SetScript("OnHide", function(self)
        self.Extra = nil
    end)
end

-- editInfo:编辑信息
-- {
--     Title = "标题",
--     Label = "标签",
--     MaxLetters = 35, -- 最大字数
--     MaxLines = 1, -- 最大行数
--     Text = "测试", -- 编辑框文本
--     OnConfirm = function(extra, text) end, -- 确认回调，返回true，则隐藏弹窗
-- }
function EditDialogMinxin:SetupEditInfo(editInfo)
    local height = 15 * 5 + self.AcceptButton:GetHeight()

    self.Title:SetText(editInfo.Title or "")
    self.Label:SetText(editInfo.Label or "")

    local editBox = self.EditBox:GetEditBox()
    editBox:SetMaxLetters(editInfo.MaxLetters or 50)
    self.EditBox:SetText(editInfo.Text or "")
    
    local maxLines = editInfo.MaxLines or 1
    local editBoxHeight = 20 + maxLines * 15
    self.EditBoxLayer:SetHeight(editBoxHeight)
    
    height = height + self.Title:GetStringHeight() + self.Label:GetStringHeight() + self.EditBoxLayer:GetHeight()
    self:SetHeight(height)

    self.OnConfirm = editInfo.OnConfirm

    self:Show()
end

-- 显示编辑框
function Addon:ShowEditDialog(editInfo)
    local UI = self:GetOrCreateUI()

    if UI.EditDialog then
        UI.EditDialog:SetupEditInfo(editInfo)
        return 
    end

    local EditDialog = Mixin(CreateFrame("Frame", nil, UI), EditDialogMinxin)
    UI.EditDialog = EditDialog

    EditDialog:Init()
    EditDialog:SetupEditInfo(editInfo)
end

local AlertDialogMixin = {}

function AlertDialogMixin:Init()
    self:SetWidth(320)
    self:SetPoint("CENTER")
    self:SetFrameStrata("DIALOG")
    self:SetFrameLevel(1000)
    self:SetMouseMotionEnabled(true)
    self:SetMouseClickEnabled(true)

    CreateFrame("Frame", nil, self, "DialogBorderDarkTemplate")

    local Label = self:CreateFontString(nil, nil, "GameFontHighlight")
    self.Label = Label
    Label:SetPoint("TOP", 0, -20)
    Label:SetWidth(280)
    Label:SetSpacing(4)

    local CancelButton = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate, UIButtonTemplate")
    self.CancelButton = CancelButton
    CancelButton:SetPoint("LEFT", 20, 0)
    CancelButton:SetPoint("RIGHT", self, "CENTER", -6, 0)
    CancelButton:SetPoint("TOP", Label, "BOTTOM", 0, -20)
    CancelButton:SetScript("OnClick", function()
        self:Hide()
    end)

    local AcceptButton = CreateFrame("BUTTON", nil, self, "UIPanelButtonTemplate, UIButtonTemplate")
    self.AcceptButton = AcceptButton
    AcceptButton:SetPoint("RIGHT", -20, 0)
    AcceptButton:SetPoint("LEFT", self, "CENTER", 6, 0)
    AcceptButton:SetPoint("TOP", Label, "BOTTOM", 0, -20)
    AcceptButton:SetScript("OnClick", function(btn)
        if self.OnConfirm and self.OnConfirm(self.Extra) then
            self:Hide()
        end
    end)

    self:SetScript("OnHide", function(self)
        self.Extra = nil
        self.OnConfirm = nil
    end)
end

-- alterInfo:弹窗信息
-- {
--     Label = "标签",
--     ConfirmText = "yes",
--     CancelText = "no"
--     OnConfirm = function(extra) end, -- 确认回调，返回true，则隐藏弹窗
--     Extra = Any 
-- }
function AlertDialogMixin:SetupAlertInfo(alertInfo)
    self.Label:SetText(alertInfo.Label)
    self.AcceptButton:SetText(alertInfo.ConfirmText or YES)
    self.CancelButton:SetText(alertInfo.CancelText or NO)

    local height = self.Label:GetStringHeight() + self.AcceptButton:GetHeight() + 60
    self:SetHeight(height)

    self.Extra = alertInfo.Extra
    self.OnConfirm = alertInfo.OnConfirm

    self:Show()
end

function Addon:ShowAlertDialog(alertInfo)
    if Addon.AlertDialog then
        Addon.AlertDialog:SetupAlertInfo(alertInfo)
        return 
    end

    local AlertDialog = Mixin(CreateFrame("Frame", nil, UIParent), AlertDialogMixin)
    Addon.AlertDialog = AlertDialog

    AlertDialog:Init()
    AlertDialog:SetupAlertInfo(alertInfo)
end

function Addon:ShowUI()
    self:HideUIPanel(GameMenuFrame)
    self:GetOrCreateUI():Show()
end

function Addon:GetAddonListContainer()
    return self.UI.AddonListContainer
end

function Addon:GetAddonDetailContainer()
    return self.UI.AddonDetailContainer
end

function Addon:GetAddonSetContainer()
    return self.UI.AddonSetContainer
end

function Addon:GetReloadUIIndicator()
    return self.UI.ReloadUIIndicator
end

-- 暴雪插件列表显示的时候，鸠占鹊巢
local function OnBlizzardAddonListShow()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    Addon:ShowUI()
end

local function OnGameMenuFrameInitButtons(frame, text, callback, isDisabled, disabledText)
    local children = { frame:GetChildren() }

    for _, child in ipairs(children) do
        if child:GetObjectType() == "Button" and child:GetText() == ADDONS then
            child:SetScript("OnClick", OnBlizzardAddonListShow)
        end
    end
end

hooksecurefunc(GameMenuFrame, "InitButtons", OnGameMenuFrameInitButtons)