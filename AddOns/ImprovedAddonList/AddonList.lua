local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件列表项启用状态按钮函数集
ImprovedAddonListItemEnableStatusButtonMixin = {}

-- 插件列表项启用状态按钮：鼠标划入 
function ImprovedAddonListItemEnableStatusButtonMixin:OnEnter()
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["enable_switch"], 1, 1, 1)
    GameTooltip:Show()
end

-- 插件列表项启用状态按钮：鼠标移出
function ImprovedAddonListItemEnableStatusButtonMixin:OnLeave()
    GameTooltip:Hide()
end

-- 插件列表项启用状态按钮：鼠标点击
function ImprovedAddonListItemEnableStatusButtonMixin:OnClick()
    local addonInfo = self:GetParent():GetAddonInfo()
    if addonInfo.Enabled then
        Addon:DisableAddon(addonInfo.Name)
    else
        Addon:EnableAddon(addonInfo.Name)
    end
    Addon:RefreshAddonInfo(addonInfo.Name)
end

-- 插件列表项锁定状态按钮函数集
ImprovedAddonListItemLockStatusButtonMixin = {}

-- 插件列表项锁定状态按钮：鼠标划入 
function ImprovedAddonListItemLockStatusButtonMixin:OnEnter()
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["lock_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 插件列表项锁定状态按钮：鼠标移出
function ImprovedAddonListItemLockStatusButtonMixin:OnLeave()
    GameTooltip:Hide()
end

-- 插件分组组函数集
ImprovedAddonListAddonCategoryMixin = {}

-- 插件分组：更新
function ImprovedAddonListAddonCategoryMixin:Update()
    local node = self:GetElementData()
    local categoryInfo = node:GetData().CategoryInfo
    self.Label:SetText(categoryInfo.Name)

    self:SetCollapsed(node:IsCollapsed())
end

-- 插件分组：获取分组信息
function ImprovedAddonListAddonCategoryMixin:GetCategoryInfo()
    return self:GetElementData():GetData().CategoryInfo
end

-- 插件分组：点击事件，切换折叠状态
function ImprovedAddonListAddonCategoryMixin:OnClick()
    local node = self:GetElementData()
    node:ToggleCollapsed()
    self:SetCollapsed(node:IsCollapsed())
end

-- 插件分组：设置折叠状态
function ImprovedAddonListAddonCategoryMixin:SetCollapsed(collapsed)
    local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse"
    self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
	self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize)
end

-- 插件列表项函数集
ImprovedAddonListAddonItemMixin = {}

-- 插件列表项：更新
function ImprovedAddonListAddonItemMixin:Update()
    local addonInfo = self:GetAddonInfo()

    local iconText = Addon:CreateAddonIconText(addonInfo.IconText)

    -- 设置标题和加载指示器
    local loadIndicatorDisplayType = Addon:GetLoadIndicatorDisplayType()
    local label = iconText .. " "
    if loadIndicatorDisplayType == Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE then
        label = label .. addonInfo.TitleWithoutColor
        self.LoadIndicator:Hide()
    elseif loadIndicatorDisplayType == Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL then
        label = label .. addonInfo.Title
        self.LoadIndicator:SetShown(addonInfo.TitleColorful)
    elseif loadIndicatorDisplayType == Addon.LOAD_INDICATOR_DISPLAY_ALWAYS then
        label = label .. addonInfo.Title
        self.LoadIndicator:Show()
    end

    -- 显示备注
    if addonInfo.Remark and strlenutf8(addonInfo.Remark) > 0 then
        label = iconText .. " " .. WrapTextInColor("*", DISABLED_FONT_COLOR) .. addonInfo.Remark
    end

    self.Label:SetText(label)
    local labelColor = self:GetLabelColor()
    self:SetLabelFontColor(labelColor)
    self:SetLoadIndicatorColor(labelColor)

    self:SetSelected(self:IsSelected())
    self:SyncEnableStatus()
end

function ImprovedAddonListAddonItemMixin:SetLoadIndicatorColor(color)
    self.LoadIndicator:SetVertexColor(color:GetRGB())
end

function ImprovedAddonListAddonItemMixin:SetLabelFontColor(color)
    self.Label:SetTextColor(color:GetRGB())
end

function ImprovedAddonListAddonItemMixin:GetLabelColor()
    local addonInfo = self:GetAddonInfo()

    if Addon:IsAddonShouldReload(addonInfo.Name) then
        return Addon:GetLoadIndicatorReloadColor()
    elseif addonInfo.Loaded then
        return Addon:GetLoadIndicatorLoadedColor()
    elseif addonInfo.Enabled and not addonInfo.Loaded then
        return Addon:GetLoadIndicatorUnloadedColor()
    elseif addonInfo.Enabled and not addonInfo.Loadable then
        return Addon:GetLoadIndicatorUnloadableColor()
    else
        return Addon:GetLoadIndicatorDisabledColor()
    end
end

-- 插件列表项：同步启用按钮状态
function ImprovedAddonListAddonItemMixin:SyncEnableStatus()
    local addonInfo = self:GetAddonInfo()
    local enableStatusButton = self.EnableStatus
    local lockStatusButton = self.LockStatus
    
    if addonInfo.IsLocked or not addonInfo.Unlockable then
        enableStatusButton:Hide()
        lockStatusButton:Show()

        local lockStatusTex
        if addonInfo.Unlockable then
            lockStatusTex = [[Interface\Addons\ImprovedAddonList\Media\lock.png]]
        else
            lockStatusTex = [[Interface\Addons\ImprovedAddonList\Media\cannot_unlock.png]]
        end
        lockStatusButton:SetNormalTexture(lockStatusTex)
        lockStatusButton:SetHighlightTexture(lockStatusTex, "ADD")
        lockStatusButton:GetHighlightTexture():SetAlpha(0.2)
    else
        enableStatusButton:Show()
        lockStatusButton:Hide()

        local enableStatusTex
        if addonInfo.Enabled then
            enableStatusTex = [[Interface\Addons\ImprovedAddonList\Media\enabled.png]]
        else
            enableStatusTex = [[Interface\Addons\ImprovedAddonList\Media\enable_status_border.png]]
        end
    
        enableStatusButton:SetNormalTexture(enableStatusTex)
        enableStatusButton:SetHighlightTexture(enableStatusTex, "ADD")
        enableStatusButton:GetHighlightTexture():SetAlpha(0.2)
    end
end

-- 插件列表项：鼠标划入
function ImprovedAddonListAddonItemMixin:OnEnter()
    self:SetLabelFontColor(WHITE_FONT_COLOR) 
end

-- 插件列表项：鼠标移出
function ImprovedAddonListAddonItemMixin:OnLeave()
    self:SetLabelFontColor(self:GetLabelColor())
end

-- 插件列表项：鼠标点击
function ImprovedAddonListAddonItemMixin:OnClick()
    if self:IsSelected() then 
        Addon:ShowAddonDetail(self:GetAddonInfo().Name)
        return 
    end

    Addon:GetAddonListScrollBox().SelectionBehavior:Select(self)
    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
end

function ImprovedAddonListAddonItemMixin:OnDoubleClick()
    local addonInfo = self:GetAddonInfo()
    if addonInfo.IsLocked then
        Addon:ShowError(L["lock_tips"])
        return
    end
    self.EnableStatus:Click()
end

-- 插件列表项：设置选中
function ImprovedAddonListAddonItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected)
	self.HighlightOverlay:SetShown(not selected)
end

-- 获取插件列表项对应插件信息
function ImprovedAddonListAddonItemMixin:GetAddonInfo()
    return self:GetElementData():GetData().AddonInfo
end

-- 插件列表项是否选中
function ImprovedAddonListAddonItemMixin:IsSelected()
    return Addon:GetAddonListScrollBox().SelectionBehavior:IsElementDataSelected(self:GetElementData())
end

-- 插件列表节点更新
local function AddonListTreeNodeUpdater(factory, node)
    local elementData = node:GetData()
    local function Initializer(button, node)
        button:Update()
    end
    if elementData.CategoryInfo then
        factory("ImprovedAddonListAddonCategoryTemplate", Initializer)
    elseif elementData.AddonInfo then
        factory("ImprovedAddonListAddonItemTemplate", Initializer)
    end
end

-- 选中变化
local function AddonListNodeOnSelectionChanged(_, elementData, selected)
    local button = Addon:GetAddonListScrollBox():FindFrame(elementData)
    
    if button then
        button:SetSelected(selected)
    end

    -- 显示插件详情
    local addonInfo = elementData:GetData().AddonInfo
    if addonInfo and selected then
        Addon:ShowAddonDetail(addonInfo.Name)
    end
end

-- 列表长度
local function ElementExtentCalculator(index, node)
    return 25
end

-- 设置按钮：鼠标划入
local function onSettingsButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["settings_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 设置按钮：鼠标移出
local function onSettingsButtonLeave(self)
    GameTooltip:Hide()
end

-- 设置按钮：鼠标点击
local function onSettingsButtonClick(self)
    Addon:ShowAddonSettings()
end

-- 覆盖插件集按钮：鼠标划入
local function onAddonsSetOpButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_op_tips"], 1, 1, 1, true)
    GameTooltip:Show()
end

-- 覆盖插件集按钮：鼠标移出
local function onAddonsSetOpButtonLeave(self)
    GameTooltip:Hide()
end

-- 覆盖插件集按钮：鼠标点击
local function onAddonsSetOpButtonClick(self)
    local addons = {}
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if not Addon:IsAddonManager(addonInfo.Name) and addonInfo.Enabled then
            tinsert(addons, addonInfo.Name)
        end
    end

    local choiceInfo = {
        Addons = addons
    }
    Addon:ShowAddonSetChoiceDialog(self, choiceInfo)
end

-- 启用全部按钮：鼠标划入
local function onEnableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["enable_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 启用全部按钮：鼠标移出
local function onEnableAllButtonLeave(self)
    GameTooltip:Hide()
end

-- 启用全部按钮：鼠标点击
local function onEnableAllButtonClick(self)
    Addon:EnableAllAddons()
    Addon:RefreshAddonListContainer()
end

-- 禁用全部按钮：鼠标划入
local function onDisableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["disable_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 禁用全部按钮：鼠标移出
local function onDisableAllButtonLeave(self)
    GameTooltip:Hide()
end

-- 禁用全部按钮：鼠标点击
local function onDisableAllButtonClick(self)
    Addon:DisableAllAddons()
    Addon:RefreshAddonListContainer()
end

-- 重置全部按钮：鼠标划入
local function onResetButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["reset_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 重置按钮：鼠标移出
local function onResetButtonLeave(self)
    GameTooltip:Hide()
end

-- 重置按钮：鼠标点击
local function onResetButtonClick(self)
    Addon:ResetAddonList()
    Addon:RefreshAddonListContainer()
end

-- 插件列表搜索框文本变化
local function onAddonListSearchBoxTextChanged(self, userInput)
    if self.searchJob then
        self.searchJob:Cancel()
    end
    
    if userInput or (self.preText and self.preText ~= self:GetText()) then
        self.preText = self:GetText()
        self.searchJob = C_Timer.NewTimer(0.25, function()
            Addon:RefreshAddonListContainer()
        end)
    end
end

-- 插件图标设置变更：显示模式
local function OnAddonIconDisplayModeChanged(self)
    self:RefreshAddonList()
end

-- 插件加载指示器设置变更：显示模式
local function OnLoadIndicatorDisplayModeSettingChanged(self)
    self:RefreshAddonList()
end

-- 插件加载指示器设置变更：颜色
local function OnLoadIndicatorColorSettingChanged(self)
    self:RefreshAddonList()
end

-- 插件列表加载
function Addon:OnAddonListContainerLoad()
    local AddonListContainer = self:GetAddonListContainer()
    
    -- 设置按钮
    local SettingsButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.SettingsButtton = SettingsButton
    local settingsButtonTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\settings.png"
    SettingsButton:SetSize(16, 16)
    SettingsButton:SetNormalTexture(settingsButtonTexture)
    SettingsButton:SetHighlightTexture(settingsButtonTexture)
    SettingsButton:GetHighlightTexture():SetAlpha(0.2)
    SettingsButton:SetPoint("TOPRIGHT", -8, -8)
    SettingsButton:SetScript("OnEnter", onSettingsButtonEnter)
    SettingsButton:SetScript("OnLeave", onSettingsButtonLeave)
    SettingsButton:SetScript("OnClick", onSettingsButtonClick)

    -- 插件集操作
    local AddonSetOpButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.AddonSetOpButton = AddonSetOpButton
    local overrideAddonSetButtonTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\addon_set_op.png"
    AddonSetOpButton:SetSize(16, 16)
    AddonSetOpButton:SetNormalTexture(overrideAddonSetButtonTexture)
    AddonSetOpButton:SetHighlightTexture(overrideAddonSetButtonTexture)
    AddonSetOpButton:GetHighlightTexture():SetAlpha(0.2)
    AddonSetOpButton:SetPoint("RIGHT", SettingsButton, "LEFT", -4, 0)
    AddonSetOpButton:SetScript("OnEnter", onAddonsSetOpButtonEnter)
    AddonSetOpButton:SetScript("OnLeave", onAddonsSetOpButtonLeave)
    AddonSetOpButton:SetScript("OnClick", onAddonsSetOpButtonClick)

    -- 启用全部按钮
    local EnableAllButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.EnableAllButton = EnableAllButton
    EnableAllButton:SetSize(16, 16)
    EnableAllButton:SetPoint("RIGHT", AddonSetOpButton, "LEFT", -4, 0)
    EnableAllButton:SetScript("OnEnter", onEnableAllButtonEnter)
    EnableAllButton:SetScript("OnLeave", onEnableAllButtonLeave)
    EnableAllButton:SetScript("OnClick", onEnableAllButtonClick)

    -- 禁用全部按钮
    local DisableAllButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.DisableAllButton = DisableAllButton
    DisableAllButton:SetSize(16, 16)
    DisableAllButton:SetPoint("RIGHT", EnableAllButton, "LEFT", -4, 0)
    DisableAllButton:SetScript("OnEnter", onDisableAllButtonEnter)
    DisableAllButton:SetScript("OnLeave", onDisableAllButtonLeave)
    DisableAllButton:SetScript("OnClick", onDisableAllButtonClick)

    -- 重置按钮
    local ResetButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.ResetButton = ResetButton
    ResetButton:SetSize(16, 16)
    ResetButton:SetPoint("RIGHT", DisableAllButton, "LEFT", -4, 0)
    ResetButton:SetScript("OnEnter", onResetButtonEnter)
    ResetButton:SetScript("OnLeave", onResetButtonLeave)
    ResetButton:SetScript("OnClick", onResetButtonClick)

    -- 插件列表搜索框
    local AddonListSearchBox = CreateFrame("EditBox", nil, AddonListContainer, "SearchBoxTemplate")
    AddonListContainer.SearchBox = AddonListSearchBox
    AddonListSearchBox:SetPoint("LEFT", 14, 0)
    AddonListSearchBox:SetPoint("TOPRIGHT", ResetButton, "TOPLEFT", -5, 0)
    AddonListSearchBox:SetPoint("BOTTOMRIGHT", ResetButton, "BOTTOMLEFT", -5, 0)
    AddonListSearchBox:HookScript("OnTextChanged", onAddonListSearchBoxTextChanged)

    -- 创建插件列表
    -- 滚动框
    local AddonListScrollBox = CreateFrame("Frame", nil, AddonListContainer, "WowScrollBoxList")
    AddonListContainer.ScrollBox = AddonListScrollBox
    AddonListScrollBox:SetPoint("TOP", AddonListSearchBox, "BOTTOM", 0, -5)
    AddonListScrollBox:SetPoint("LEFT", 5, 0)
    AddonListScrollBox:SetPoint("BOTTOMRIGHT", -20, 7)
    -- 滚动条
    local AddonListScrollBar = CreateFrame("EventFrame", nil, AddonListContainer, "MinimalScrollBar")
    AddonListContainer.ScrollBar =  AddonListScrollBar
    AddonListScrollBar:SetPoint("TOPLEFT", AddonListScrollBox, "TOPRIGHT")
    AddonListScrollBar:SetPoint("BOTTOMLEFT", AddonListScrollBox, "BOTTOMRIGHT")

    local addonListTreeView = CreateScrollBoxListTreeListView(10, 5, 5, 5, 5, 1)

    --添加选中特性
    AddonListScrollBox.SelectionBehavior = ScrollUtil.AddSelectionBehavior(AddonListScrollBox)
    AddonListScrollBox.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonListNodeOnSelectionChanged)

    addonListTreeView:SetElementFactory(AddonListTreeNodeUpdater)
    addonListTreeView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonListScrollBox, AddonListScrollBar, addonListTreeView)

    self:RegisterCallback("AddonSettings.AddonIconDisplayMode", OnAddonIconDisplayModeChanged, self)
    self:RegisterCallback("AddonSettings.LoadIndicatorDisplayMode", OnLoadIndicatorDisplayModeSettingChanged, self)
    self:RegisterCallback("AddonSettings.LoadIndicatorColor", OnLoadIndicatorColorSettingChanged, self)

    self:RefreshAddonListContainer()
end

-- 刷新插件列表选项按钮的状态
function Addon:RefreshAddonListOptionButtonsStatus()
    local AddonListContainer = self:GetAddonListContainer()
    
    local allEnabled, allDisabled, canReset, shouldReload = self:IsAllAddonsEnabled()

    -- 更新启用全部按钮
    local EnableAllButton = AddonListContainer.EnableAllButton
    local enableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (allEnabled and "enable_all_checked" or "enable_all")
    EnableAllButton:SetNormalTexture(enableAllTexture)
    EnableAllButton:SetHighlightTexture(enableAllTexture)
    EnableAllButton:GetHighlightTexture():SetAlpha(0.2)
    
    -- 更新禁用全部按钮
    local DisableAllButton = AddonListContainer.DisableAllButton
    local disableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (allDisabled and "disable_all_checked" or "disable_all")
    DisableAllButton:SetNormalTexture(disableAllTexture)
    DisableAllButton:SetHighlightTexture(disableAllTexture)
    DisableAllButton:GetHighlightTexture():SetAlpha(0.2)

    -- 更新重置按钮
    local ResetButton = AddonListContainer.ResetButton
    local resetButtonTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (canReset and "reset.png" or "reset_disabled.png")
    ResetButton:SetNormalTexture(resetButtonTexture)
    ResetButton:SetHighlightTexture(resetButtonTexture)
    ResetButton:GetHighlightTexture():SetAlpha(0.2)

    -- 刷新重载按钮指示器
    local reloadUIIndicator = self:GetReloadUIIndicator()
    local uiShouldReload = shouldReload or false
    reloadUIIndicator:SetShown(uiShouldReload)
    reloadUIIndicator.Animation:SetPlaying(uiShouldReload)
end

-- 滚动到选中项
function Addon:ScrollToSelectedAddon()
    local selectedPredicate = function(elementData)
        return self:GetAddonListScrollBox().SelectionBehavior:IsElementDataSelected(elementData)
    end
    self:GetAddonListScrollBox():ScrollToElementDataByPredicate(selectedPredicate, ScrollBoxConstants.AlignCenter, 0, ScrollBoxConstants.NoScrollInterpolation)
end

-- 更新插件列表
function Addon:RefreshAddonListContainer()
    self:RefreshAddonList()

    local currentFocusAddonName = self:CurrentFocusAddonName()
    local selectPredicate = function(node)
        local addonInfo = node:GetData().AddonInfo
        if currentFocusAddonName then
            -- 之前有选中插件，则刷新后再次选中
            return addonInfo and addonInfo.Name == currentFocusAddonName
        else
            -- 否则默认选中第一个
            return addonInfo
        end
    end

    -- 选中并滚动到选中项
    self:GetAddonListScrollBox().SelectionBehavior:SelectElementDataByPredicate(selectPredicate)
    self:ScrollToSelectedAddon()

    self:RefreshAddonDetailContainer()
    self:RefreshAddonListOptionButtonsStatus()
    self:RefreshAddonSetContainer()
end 

-- 刷新插件信息
function Addon:RefreshAddonInfo(addonName)
    self:UpdateAddonInfoByName(addonName)

    local forEach = function(frame, node)
        local addonInfo = node:GetData().AddonInfo
        if addonInfo and addonInfo.Name == addonName then
            frame:Update()
        end
    end
    self:GetAddonListScrollBox():ForEachFrame(forEach)

    self:RefreshAddonDetailContainer()
    self:RefreshAddonListOptionButtonsStatus()
    self:RefreshAddonSetContainer()
end

-- 刷新插件列表
function Addon:RefreshAddonList()
    self.AddonDataProvider = self.AddonDataProvider or CreateTreeDataProvider()
    local addonDataProvider = self.AddonDataProvider

    local searchText = self:GetAddonListSearchBox():GetText()
    searchText = searchText and strtrim(searchText)
    searchText = searchText and searchText:lower()

    addonDataProvider:Flush()

    local rootNode = addonDataProvider:GetRootNode()
    local addonInfos = self:GetAddonInfos()
    local shouldFilter = searchText and strlenutf8(searchText) > 0
    
    for index, addonInfo in ipairs(addonInfos) do
        if shouldFilter then
            local nickName = self:GetAddonRemark(addonInfo.Name) or ""
            if addonInfo.Title:lower():match(searchText) or addonInfo.Name:lower():match(searchText) or nickName:lower():match(searchText) then
                rootNode:Insert({ AddonInfo = addonInfo })
            end
        else
            rootNode:Insert({ AddonInfo = addonInfo })
        end
    end

    self:GetAddonListScrollBox():SetDataProvider(addonDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function Addon:GetAddonListScrollBox()
    return self:GetAddonListContainer().ScrollBox
end

function Addon:GetAddonListSearchBox()
    return self:GetAddonListContainer().SearchBox
end
