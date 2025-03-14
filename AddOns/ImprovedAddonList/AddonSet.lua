local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件集列表按钮：鼠标滑入
local function onAddonSetListButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_list"], 1, 1, 1)
    GameTooltip:Show()
end

-- 插件集列表按钮：鼠标移出
local function onAddonSetListButtonLeave(self)
    GameTooltip:Hide()
end

-- 插件集列表按钮：鼠标点击
local function onAddonSetListButtonClick(self)
    Addon:ShowAddonSetDialog()
end

local EnabledAndNotInAddonSetColor = CreateColor(DISABLED_FONT_COLOR:GetRGB())
EnabledAndNotInAddonSetColor.a = 0.33

local DisabledAndInAddonSetColor = CreateColor(RED_FONT_COLOR:GetRGB())
DisabledAndInAddonSetColor.a = 0.33

-- 插件集提示按钮：鼠标划入
local function onAddonSetTipButtonEnter(self)
    local activeAddonSet = Addon:GetActiveAddonSet()
    if not activeAddonSet or not activeAddonSet.Addons then
        return
    end
    
    local disabledAndInAddonSetKey = "DisabledAndInAddonSet"
    local enabledAndNotInAddonSetKey = "EnabledAndNotInAddonSet"
    local disabledAndInAddonSetCount = 0
    local enabledAndNotInAddonSetCount = 0

    local addons = {}
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        if not Addon:IsAddonManager(addonName) then
            if addonInfo.Enabled and not activeAddonSet.Addons[addonName] then
                enabledAndNotInAddonSetCount = enabledAndNotInAddonSetCount + 1
                tinsert(addons, { Name = addonName, Legend = enabledAndNotInAddonSetKey }) 
            elseif not addonInfo.Enabled and activeAddonSet.Addons[addonName] then
                disabledAndInAddonSetCount = disabledAndInAddonSetCount + 1
                tinsert(addons, { Name = addonName, Legend = disabledAndInAddonSetKey })
            end
        end
    end

    local legends = {
        [disabledAndInAddonSetKey] = {
            Title = L["addon_set_not_perfect_match_disabled_but_in_addon_set"]:format(disabledAndInAddonSetCount),
            Color = DisabledAndInAddonSetColor
        },
        [enabledAndNotInAddonSetKey] = {
            Title = L["addon_set_not_perfect_match_enabled_but_not_in_addon_set"]:format(enabledAndNotInAddonSetCount),
            Color = EnabledAndNotInAddonSetColor
        }
    }

    local addonListTooltipInfo = {
        Legends = legends,
        Addons = addons,
        Label = L["addon_set_not_perfect_match_tips"]:format(WrapTextInColor(activeAddonSet.Name, NORMAL_FONT_COLOR))
    }
    Addon:ShowAddonListTooltips(self, addonListTooltipInfo)
end

-- 插件集提示按钮：鼠标移出
local function onAddonSetTipButtonLeave(self)
    Addon:HideAddonListTooltips()
end

-- 插件集提示按钮：鼠标点击
local function onAddonSetTipButtonClick(self, button)
    local activeAddonSet = Addon:GetActiveAddonSet()
    if not activeAddonSet or not activeAddonSet.Addons then
        return
    end

    if button == "RightButton" then
        -- merge
        for addonName, enabled in pairs(activeAddonSet.Addons) do
            if enabled then
                Addon:EnableAddon(addonName)
            end
        end
        Addon:UpdateAddonInfos()
    elseif button == "LeftButton" then
        Addon:ApplyAddonSetAddons(activeAddonSet.Name)
    end

    Addon:RefreshAddonListContainer()
end

-- 当前插件集文本：鼠标划入
local function onActiveAddonSetLabelEnter(self)
    local activeAddonSet = Addon:GetActiveAddonSet()
    if not activeAddonSet or not activeAddonSet.Addons then
        return
    end

    local addons = {}
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        if not Addon:IsAddonManager(addonName) and activeAddonSet.Addons[addonName] then
            tinsert(addons, { Name = addonName })
        end
    end

    local addonListTooltipInfo = {
        Addons = addons,
        Label = L["addon_set_current"]:format(WrapTextInColor(activeAddonSet.Name, NORMAL_FONT_COLOR))
    }
    Addon:ShowAddonListTooltips(self, addonListTooltipInfo)
end

-- 当前插件集文本：鼠标移出
local function onActiveAddonSetLabelLeave(self)
    Addon:HideAddonListTooltips()
end

function Addon:OnAddonSetContainerLoad()
    local AddonSetContainer = self:GetAddonSetContainer()

    -- 插件集列表
    local AddonSetListButton = CreateFrame("Button", nil, AddonSetContainer)
    AddonSetContainer.AddonSetListButton = AddonSetListButton
    AddonSetListButton:SetPoint("RIGHT", 0, -1)
    AddonSetListButton:SetSize(16, 16)
    AddonSetListButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_sets.png")
    AddonSetListButton:SetHighlightTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_sets_highlight.png")
    AddonSetListButton:SetScript("OnEnter", onAddonSetListButtonEnter)
    AddonSetListButton:SetScript("OnLeave", onAddonSetListButtonLeave)
    AddonSetListButton:SetScript("OnClick", onAddonSetListButtonClick)

    -- 提示按钮
    local AddonSetTipButton = CreateFrame("Button", nil, AddonSetContainer)
    AddonSetContainer.AddonSetTipButton = AddonSetTipButton
    AddonSetTipButton:SetSize(16, 16)
    AddonSetTipButton:SetPoint("LEFT", AddonSetListButton, "RIGHT", 4, 0)
    AddonSetTipButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\tip.png")
    AddonSetTipButton:SetScript("OnEnter", onAddonSetTipButtonEnter)
    AddonSetTipButton:SetScript("OnLeave", onAddonSetTipButtonLeave)
    AddonSetTipButton:SetScript("OnClick", onAddonSetTipButtonClick)
    AddonSetTipButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    AddonSetTipButton:Hide()

    local ActiveAddonSetContainer = CreateFrame("Frame", nil, AddonSetContainer, "InsetFrameTemplate3")
    ActiveAddonSetContainer:SetPoint("LEFT")
    ActiveAddonSetContainer:SetPoint("RIGHT", AddonSetListButton, "LEFT", -5, 0)
    ActiveAddonSetContainer:SetHeight(20)
    ActiveAddonSetContainer:SetScript("OnEnter", onActiveAddonSetLabelEnter)
    ActiveAddonSetContainer:SetScript("OnLeave", onActiveAddonSetLabelLeave)

    local ActiveAddonSetPrefix = ActiveAddonSetContainer:CreateFontString(nil, nil, "GameFontNormalSmall2")
    ActiveAddonSetPrefix:SetPoint("LEFT", 5, 0)
    ActiveAddonSetPrefix:SetText(L["addon_set_active_label"])

    -- 当前加载插件集
    local ActiveAddonSetLabel = ActiveAddonSetContainer:CreateFontString(nil, nil, "GameFontWhite")
    AddonSetContainer.ActiveAddonSetLabel = ActiveAddonSetLabel
    ActiveAddonSetLabel:SetJustifyH("RIGHT")
    ActiveAddonSetLabel:SetPoint("LEFT", ActiveAddonSetPrefix, "RIGHT", 8, 0)
    ActiveAddonSetLabel:SetPoint("RIGHT", -5, 0)
    ActiveAddonSetLabel:SetMaxLines(1)

    self:RefreshAddonSetContainer()
end

-- 刷新插件集
function Addon:RefreshAddonSetContainer()
    local addonSetContainer = self:GetAddonSetContainer()
    local activeAddonSetLable = addonSetContainer.ActiveAddonSetLabel
    local activeAddonSetName = self:GetActiveAddonSetName()

    if activeAddonSetName then
        activeAddonSetLable:SetText(activeAddonSetName)
        activeAddonSetLable:SetTextColor(WHITE_FONT_COLOR:GetRGB())
        addonSetContainer.AddonSetTipButton:SetShown(not self:IsAddonSetPerfectMacth(activeAddonSetName))
    else
        activeAddonSetLable:SetText(L["addon_set_inactive_tip"])
        activeAddonSetLable:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        addonSetContainer.AddonSetTipButton:Hide()
    end
end

-- 插件集列表项
ImprovedAddonListAddonSetItemMixin = {}

function ImprovedAddonListAddonSetItemMixin:Update()
    local activeAddonSetName = Addon:GetActiveAddonSetName()
    local data = self:GetElementData()
    
    local name, color
    if activeAddonSetName == data.Name then
        name = CreateSimpleTextureMarkup("Interface\\AddOns\\ImprovedAddonList\\Media\\location.png", 14, 14) .. " " .. data.Name
        color = NORMAL_FONT_COLOR
    elseif data.Enabled then
        name = data.Name
        color = WHITE_FONT_COLOR
    else
        name = data.Name
        color = DISABLED_FONT_COLOR
    end
    self.Label:SetText(name)
    self.Label:SetVertexColor(color:GetRGB())

    self:SetSelected(self:IsSelected())
end

function ImprovedAddonListAddonSetItemMixin:OnClick()
    if self:IsSelected() then 
        return 
    end

    Addon:GetAddonSetListScrollBox().SelectionBehavior:Select(self)
    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
end

function ImprovedAddonListAddonSetItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected)
	self.HighlightOverlay:SetShown(not selected)
end

function ImprovedAddonListAddonSetItemMixin:IsSelected()
    return Addon:GetAddonSetListScrollBox().SelectionBehavior:IsElementDataSelected(self:GetElementData())
end

-- 插件集内变更的插件列表，做临时存储用
-- key:AddonSetName
-- value:Table:{ key = addonName, value = [true, false, nil] }
local AddonSetChangedAddons = {}

-- 当前插件集所有插件是否都已启用
local function IsAllAddonsEnabledInCurrentFocusAddonSet()
    local currentAddonSet = Addon:GetCurrentFocusAddonSet()
    if not currentAddonSet then
        return false
    end

    local currentChangedAddons = AddonSetChangedAddons[currentAddonSet.Name]
    local addonInfos = Addon:GetAddonInfos()
    local currentAddonSetAddons = currentAddonSet.Addons

    local allEnabled, allDisabled, canReset
    for _, addonInfo in ipairs(addonInfos) do
        local isAddonManager = Addon:IsAddonManager(addonInfo.Name)
        local enabled = addonInfo.Enabled
        local addonName = addonInfo.Name
        local tempEnableStatus = currentChangedAddons and currentChangedAddons[addonName]
        local enableStatus = currentAddonSetAddons and currentAddonSetAddons[addonName]

        if not isAddonManager then
            if allEnabled == nil and (tempEnableStatus == false or (tempEnableStatus == nil and not enableStatus)) then
                allEnabled = false
            end

            if allDisabled == nil and (tempEnableStatus == true or (tempEnableStatus == nil and enableStatus)) then
                allDisabled = false
            end

            if canReset == nil and (tempEnableStatus ~= nil and tempEnableStatus ~= enableStatus) then
                canReset = true
            end
        end

        if allEnabled ~= nil and allDisabled ~= nil and canReset ~= nil then
            break
        end
    end

    if allEnabled == nil then
        allEnabled = true
    end

    if allDisabled == nil then
        allDisabled = true
    end

    return allEnabled, allDisabled, canReset
end

-- 插件集插件列表项
ImprovedAddonListAddonSetAddonListItemMixin = {}

function ImprovedAddonListAddonSetAddonListItemMixin:Update()
    local addonInfo = self:GetElementData()

    local iconText = Addon:CreateAddonIconText(addonInfo.IconText)
    local label = iconText .. " " .. addonInfo.Title
    -- 显示备注
    if addonInfo.Remark and strlenutf8(addonInfo.Remark) > 0 then
        label = iconText .. " " .. WrapTextInColor("*", DISABLED_FONT_COLOR) .. addonInfo.Remark
    end

    self.Label:SetText(label)

    self:SyncEnableStatus()
end

function ImprovedAddonListAddonSetAddonListItemMixin:SyncEnableStatus()
    local addonInfo = self:GetElementData()
    local addonName = addonInfo.Name

    local addonSet = Addon:GetCurrentFocusAddonSet()
    local tempChangedAddons = addonSet and AddonSetChangedAddons[addonSet.Name]

    local tempEnableStatus = tempChangedAddons and tempChangedAddons[addonName]
    local enableStatus = addonSet and addonSet.Addons and addonSet.Addons[addonName] and true or false

    local enabled = tempEnableStatus
    if enabled == nil then
        enabled = enableStatus
    end
    
    local enableStatusTex = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (enabled and "enabled.png" or "enable_status_border.png")
    
    self.EnableStatus:SetTexture(enableStatusTex)
    self.Changed:SetShown(tempEnableStatus ~= nil and tempEnableStatus ~= enableStatus)
end

function ImprovedAddonListAddonSetAddonListItemMixin:OnEnter()
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_addon_switch"], 1, 1, 1)
    GameTooltip:Show()
end

function ImprovedAddonListAddonSetAddonListItemMixin:OnLeave()
    GameTooltip:Hide()
end

function ImprovedAddonListAddonSetAddonListItemMixin:OnClick()
    local addonInfo = self:GetElementData()
    local focusAddonSet = Addon:GetCurrentFocusAddonSet()

    if not focusAddonSet then
        return
    end

    local addonName = addonInfo.Name
    local enableStatus = focusAddonSet.Addons and focusAddonSet.Addons[addonName] and true or false
    AddonSetChangedAddons[focusAddonSet.Name] = AddonSetChangedAddons[focusAddonSet.Name] or {}
    local changedAddons = AddonSetChangedAddons[focusAddonSet.Name]
    
    if changedAddons[addonName] ~= nil then
        changedAddons[addonName] = nil
    else
        changedAddons[addonName] = not enableStatus
    end

    Addon:UpdateAddonSetAddonItems(addonName)
end

-- 应用插件集：鼠标划入
local function onApplyAddonSetButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end
    
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_apply_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)), 1, 1, 1, true)
    GameTooltip:Show()
end

-- 应用插件集：鼠标移出
local function onApplyAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 应用插件集：点击
local function onApplyAddonSetButtonClick(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    local _, _, canReset = IsAllAddonsEnabledInCurrentFocusAddonSet()
    if canReset then
        Addon:ShowError(L["addon_set_apply_error_unsave"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)))
        return
    end

    Addon:SetActiveAddonSetName(focusAddonSetName)
    Addon:ApplyAddonSetAddons(focusAddonSetName)
    Addon:RefreshAddonSetListContainer()
    Addon:RefreshAddonListContainer()

    local alertInfo = {
        Label = L["addon_set_apply_alert"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)),
        ConfirmText = RELOADUI,
        CancelText = L["addon_set_apply_later"],
        OnConfirm = function()
            ReloadUI()
            return true
        end
    }
    Addon:ShowAlertDialog(alertInfo)
end

-- 停止使用插件集：鼠标划入
local function onClearAddonSetButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_clear_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 停止使用插件集：鼠标移出
local function onClearAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 停止使用插件集：点击
local function onClearAddonSetButtonClick(self)
    Addon:SetActiveAddonSetName(nil)
    Addon:RefreshAddonSetListContainer()
    Addon:RefreshAddonListContainer()
end

-- 添加插件集：鼠标划入
local function onAddAddonSetButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_add_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 添加插件集：鼠标移出
local function onAddAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 添加插件集：点击
local function onAddAddonSetButtonClick(self)
    local editInfo = {
        Title = L["addon_set_new"],
        Label = L["addon_set_new_label"],
        MaxLetters = Addon.ADDON_SET_NAME_MAX_LENGTH,
        MaxLines = 2,
        OnConfirm = function(name)
            if Addon:NewAddonSet(name) then
                Addon:RefreshAddonSetListContainer(name)
                return true
            end
        end
    }
    Addon:ShowEditDialog(editInfo)
end

-- 删除插件集：鼠标划入
local function onDeleteAddonSetButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_remove_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)), 1, 1, 1, true)
    GameTooltip:Show()
end

-- 删除插件集：鼠标移出
local function onDeleteAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 删除插件集：点击
local function onDeleteAddonSetButtonClick(self)
    local node = Addon:GetAddonSetListScrollBox().SelectionBehavior:GetFirstSelectedElementData()
    if not node then return end

    local alertInfo = {
        Label = L["addon_set_delete_confirm"]:format(WrapTextInColor(node.Name, NORMAL_FONT_COLOR)),
        Extra = node.Name,
        OnConfirm = function(addonSetName)
            Addon:DeleteAddonSet(addonSetName)
            Addon:RefreshAddonSetListContainer()
            Addon:RefreshAddonSetContainer()
            Addon:RefreshAddonDetailContainer()
            return true
        end
    }
    Addon:ShowAlertDialog(alertInfo)
end

-- 保存按钮：鼠标划入
local function onSaveAddonSetButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_save_addon_list_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)), 1, 1, 1, true)
    GameTooltip:Show()
end

-- 保存按钮：鼠标移出
local function onSaveAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 保存按钮：鼠标点击
local function onSaveAddonSetButtonClick(self)
    local focusAddonSet = Addon:GetCurrentFocusAddonSet()
    if not focusAddonSet then
        return
    end

    local changedAddons = AddonSetChangedAddons[focusAddonSet.Name]
    if not changedAddons then
        return
    end

    local addonList = {}
    local addonInfos = Addon:GetAddonInfos()

    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        local tempEnableStatus = changedAddons[addonName]
        local enabld = focusAddonSet.Addons and focusAddonSet.Addons[addonName] and true or false

        local finalEnableStatus
        if tempEnableStatus == nil then
            finalEnableStatus = enabld 
        else
            finalEnableStatus = tempEnableStatus
        end

        addonList[addonName] = finalEnableStatus
    end

    wipe(changedAddons)
    Addon:SetAddonSetAddonList(focusAddonSet.Name, addonList)

    Addon:UpdateAddonSetAddonItems()
    Addon:RefreshAddonSetContainer()
    Addon:RefreshAddonDetailContainer()
end

-- 替换按钮：鼠标划入
local function onReplaceAddonsButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_replace_addons_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR)), 1, 1, 1, true)
    GameTooltip:Show()
end

-- 替换按钮：鼠标移出
local function onReplaceAddonsButtonLeave(self)
    GameTooltip:Hide()
end

-- 替换按钮：鼠标点击
local function onReplaceAddonsButtonClick(self)
    local focusAddonSet = Addon:GetCurrentFocusAddonSet()
    if not focusAddonSet then
        return
    end

    AddonSetChangedAddons[focusAddonSet.Name] = AddonSetChangedAddons[focusAddonSet.Name] or {}
    local changedAddons = AddonSetChangedAddons[focusAddonSet.Name]
    wipe(changedAddons)

    -- 使用已启用插件列表覆盖插件集
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        if not Addon:IsAddonManager(addonName) then
            local enabledStatus = focusAddonSet.Addons and focusAddonSet.Addons[addonName] and true or false
            local tempEnabledStatus = addonInfo.Enabled

            -- 仅当该插件在插件集内的启用状态和临时启用状态不同时才赋值
            if enabledStatus ~= tempEnabledStatus then
                changedAddons[addonName] = tempEnabledStatus
            end
        end
    end

    Addon:UpdateAddonSetAddonItems()
end

-- 启用全部按钮：鼠标划入
local function onEnableAllButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    local tips = L["addon_set_enable_all_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR))
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(tips, 1, 1, 1)
    GameTooltip:Show()
end

-- 启用全部按钮：鼠标移出
local function onEnableAllButtonLeave(self)
    GameTooltip:Hide()
end

-- 启用全部按钮：鼠标点击
local function onEnableAllButtonClick(self)
    local focusAddonSet = Addon:GetCurrentFocusAddonSet()
    if not focusAddonSet then
        return
    end

    AddonSetChangedAddons[focusAddonSet.Name] = AddonSetChangedAddons[focusAddonSet.Name] or {}
    local ChangedAddons = AddonSetChangedAddons[focusAddonSet.Name]
    local currentAddonSetAddons = focusAddonSet.Addons

    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local enableStatus = currentAddonSetAddons and currentAddonSetAddons[addonInfo.Name]
        if enableStatus then
            -- 清除临时状态，这样会使用实际的启用状态
            -- 点击列表项时才不会有问题
            ChangedAddons[addonInfo.Name] = nil
        else
            ChangedAddons[addonInfo.Name] = true
        end
    end

    Addon:RefreshAddonSetAddonListContainer()
end

-- 禁用全部按钮：鼠标划入
local function onDisableAllButtonEnter(self)
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    local tips = L["addon_set_disable_all_tips"]:format(WrapTextInColor(focusAddonSetName, NORMAL_FONT_COLOR))
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(tips, 1, 1, 1)
    GameTooltip:Show()
end

-- 禁用全部按钮：鼠标移出
local function onDisableAllButtonLeave(self)
    GameTooltip:Hide()
end

-- 禁用全部按钮：鼠标点击
local function onDisableAllButtonClick(self)
    local focusAddonSet = Addon:GetCurrentFocusAddonSet()
    if not focusAddonSet then
        return
    end

    AddonSetChangedAddons[focusAddonSet.Name] = AddonSetChangedAddons[focusAddonSet.Name] or {}
    local ChangedAddons = AddonSetChangedAddons[focusAddonSet.Name]
    local currentAddonSetAddons = focusAddonSet.Addons

    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local enableStatus = currentAddonSetAddons and currentAddonSetAddons[addonInfo.Name]
        if not enableStatus then
            -- 清除临时状态，这样会使用实际的启用状态
            -- 点击列表项时才不会有问题
            ChangedAddons[addonInfo.Name] = nil
        else
            ChangedAddons[addonInfo.Name] = false
        end
    end

    Addon:RefreshAddonSetAddonListContainer()
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
    local focusAddonSetName = Addon:GetCurrentFocusAddonSetName()
    if not focusAddonSetName then
        return
    end

    local ChangedAddons = AddonSetChangedAddons[focusAddonSetName]
    if ChangedAddons then
        wipe(ChangedAddons)
    end

    Addon:RefreshAddonSetAddonListContainer()
end

local function AddonSetListNodeUpdater(factory, node)
    local function Initializer(button, node)
        button:Update()
    end

    factory("ImprovedAddonListAddonSetItemTemplate", Initializer)
end

local function AddonSetAddonListNodeUpdater(factory, node)
    local function Initializer(button, node)
        button:Update()
    end
    factory("ImprovedAddonListAddonSetAddonListItemTemplate", Initializer)
end

local function ElementExtentCalculator(index, node)
    return 25
end

local function onAddonSetListSearchBoxTextChanged(self, userInput)
    if self.searchJob then
        self.searchJob:Cancel()
    end
    
    if userInput or (self.preText and self.preText ~= self:GetText()) then
        self.preText = self:GetText()
        self.searchJob = C_Timer.NewTimer(0.25, function()
            Addon:RefreshAddonSetListContainer()
        end)
    end
end

local function onAddonSetAddonListSearchBoxTextChanged(self, userInput)
    if self.searchJob then
        self.searchJob:Cancel()
    end
    
    self.searchJob = C_Timer.NewTimer(0.25, function()
        Addon:RefreshAddonSetAddonListContainer()
    end)
end

local function AddonSetListNodeOnSelectionChanged(_, elementData, selected)
    if elementData and selected then
        Addon:SetCurrentFocusAddonSetName(elementData.Name)
        Addon:UpdateAddonSetAddonItems()
        Addon:RefreshAddonSetSettings()
    end

    local button = Addon:GetAddonSetListScrollBox():FindFrame(elementData)
    
    if button then
        button:SetSelected(selected)
    end
end

-- 插件集名称变更
local function onAddonSetNameChanged(self, settingsItem)
    local oldAddonSetName = settingsItem.Arg1
    if self:GetCurrentFocusAddonSetName() == oldAddonSetName then
        self:SetCurrentFocusAddonSetName(settingsItem.Arg2)
    end
    self:RefreshAddonSetListContainer(settingsItem.Arg2)
    self:RefreshAddonSetContainer()
    self:RefreshAddonSetSettings()
end

-- 插件集启用状态变更
local function onAddonSetEnabledChanged(self, settingsItem)
    self:RefreshAddonSetListContainer(settingsItem.Arg1)
end

-- 显示插件集弹窗
function Addon:ShowAddonSetDialog()
    local UI = self:GetOrCreateUI()

    if UI.AddonSetDialog then
        UI.AddonSetDialog:Show()
        return
    end

    local AddonSetDialog = self:CreateDialog(nil, UI)
    UI.AddonSetDialog = AddonSetDialog
    AddonSetDialog:SetSize(790, 650)
    AddonSetDialog:SetPoint("CENTER")
    AddonSetDialog:SetFrameStrata("DIALOG")
    AddonSetDialog:SetTitle(L["addon_set_list"])

    -- 插件集列表
    local AddonSetListContainer = self:CreateContainer(AddonSetDialog)
    AddonSetDialog.AddonSetListContainer = AddonSetListContainer
    AddonSetListContainer:SetWidth(210)
    AddonSetListContainer:SetPoint("TOPLEFT", 10, -30)
    AddonSetListContainer:SetPoint("BOTTOMLEFT", 10, 10)

    local ApplyAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.ApplyAddonSetButton = ApplyAddonSetButton
    local addAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\addon_set_apply.png"
    ApplyAddonSetButton:SetSize(16, 16)
    ApplyAddonSetButton:SetNormalTexture(addAddonSetButtonTexure)
    ApplyAddonSetButton:SetHighlightTexture(addAddonSetButtonTexure)
    ApplyAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    ApplyAddonSetButton:SetPoint("TOPRIGHT", -8, -8)
    ApplyAddonSetButton:SetScript("OnEnter", onApplyAddonSetButtonEnter)
    ApplyAddonSetButton:SetScript("OnLeave", onApplyAddonSetButtonLeave)
    ApplyAddonSetButton:SetScript("OnClick", onApplyAddonSetButtonClick)

    local ClearAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.ClearAddonSetButton = ClearAddonSetButton
    local addAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\addon_set_clear.png"
    ClearAddonSetButton:SetSize(16, 16)
    ClearAddonSetButton:SetNormalTexture(addAddonSetButtonTexure)
    ClearAddonSetButton:SetHighlightTexture(addAddonSetButtonTexure)
    ClearAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    ClearAddonSetButton:SetPoint("RIGHT", ApplyAddonSetButton, "LEFT", -4, 0)
    ClearAddonSetButton:SetScript("OnEnter", onClearAddonSetButtonEnter)
    ClearAddonSetButton:SetScript("OnLeave", onClearAddonSetButtonLeave)
    ClearAddonSetButton:SetScript("OnClick", onClearAddonSetButtonClick)

    local AddAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.AddAddonSetButton = AddAddonSetButton
    local addAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\add.png"
    AddAddonSetButton:SetSize(16, 16)
    AddAddonSetButton:SetNormalTexture(addAddonSetButtonTexure)
    AddAddonSetButton:SetHighlightTexture(addAddonSetButtonTexure)
    AddAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    AddAddonSetButton:SetPoint("RIGHT", ClearAddonSetButton, "LEFT", -4, 0)
    AddAddonSetButton:SetScript("OnEnter", onAddAddonSetButtonEnter)
    AddAddonSetButton:SetScript("OnLeave", onAddAddonSetButtonLeave)
    AddAddonSetButton:SetScript("OnClick", onAddAddonSetButtonClick)

    local DeleteAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.DeleteAddonSetButton = DeleteAddonSetButton
    local deleteAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\delete.png"
    DeleteAddonSetButton:SetSize(16, 16)
    DeleteAddonSetButton:SetNormalTexture(deleteAddonSetButtonTexure)
    DeleteAddonSetButton:SetHighlightTexture(deleteAddonSetButtonTexure)
    DeleteAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    DeleteAddonSetButton:SetPoint("RIGHT", AddAddonSetButton, "LEFT", -4, 0)
    DeleteAddonSetButton:SetScript("OnEnter", onDeleteAddonSetButtonEnter)
    DeleteAddonSetButton:SetScript("OnLeave", onDeleteAddonSetButtonLeave)
    DeleteAddonSetButton:SetScript("OnClick", onDeleteAddonSetButtonClick)

    -- 插件集列表搜索框
    local AddonSetSearchBox = CreateFrame("EditBox", nil, AddonSetListContainer, "SearchBoxTemplate")
    AddonSetListContainer.SearchBox = AddonSetSearchBox
    AddonSetSearchBox:SetPoint("LEFT", 14, 0)
    AddonSetSearchBox:SetPoint("TOPRIGHT", DeleteAddonSetButton, "TOPLEFT", -5, 0)
    AddonSetSearchBox:SetPoint("BOTTOMRIGHT", DeleteAddonSetButton, "BOTTOMLEFT", -5, 0)
    AddonSetSearchBox:HookScript("OnTextChanged", onAddonSetListSearchBoxTextChanged)

    local AddonSetScrollBox = CreateFrame("Frame", nil, AddonSetListContainer, "WowScrollBoxList")
    AddonSetListContainer.ScrollBox = AddonSetScrollBox

    -- 滚动条
    local AddonSetScrollBar = CreateFrame("EventFrame", nil, AddonSetListContainer, "MinimalScrollBar")
    AddonSetListContainer.ScrollBar =  AddonSetScrollBar
    AddonSetScrollBar:SetPoint("TOP", AddonSetSearchBox, "BOTTOM", 0, -5)
    AddonSetScrollBar:SetPoint("RIGHT", -15, 0)
    AddonSetScrollBar:SetPoint("BOTTOMRIGHT", -15, 7)

    local anchorsWithScrollBar = {
        CreateAnchor("TOP", AddonSetSearchBox, "BOTTOM", 0, -5),
        CreateAnchor("LEFT", 5, 0),
        CreateAnchor("BOTTOMRIGHT", AddonSetScrollBar, "BOTTOMLEFT", -5, 0),
    }
    
    local anchorsWithoutScrollBar = {
        CreateAnchor("TOP", AddonSetSearchBox, "BOTTOM", 0, -5),
        CreateAnchor("LEFT", 5, 0),
        CreateAnchor("BOTTOMRIGHT", -7, 7)
    }

    local addonSetListView = CreateScrollBoxListLinearView(1, 1, 1, 1, 1)
    addonSetListView:SetElementFactory(AddonSetListNodeUpdater)
    addonSetListView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonSetScrollBox, AddonSetScrollBar, addonSetListView)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(AddonSetScrollBox, AddonSetScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar)

    AddonSetScrollBox.SelectionBehavior = ScrollUtil.AddSelectionBehavior(AddonSetScrollBox)
    AddonSetScrollBox.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonSetListNodeOnSelectionChanged)

    local AddonListContainer = self:CreateContainer(AddonSetDialog)
    AddonSetDialog.AddonListContainer = AddonListContainer
    AddonListContainer:SetWidth(280)
    AddonListContainer:SetPoint("TOPLEFT", AddonSetListContainer, "TOPRIGHT", 10, 0)
    AddonListContainer:SetPoint("BOTTOMLEFT", AddonSetListContainer, "BOTTOMRIGHT", 10, 0)

    -- 保存按钮
    local SaveAddonSetButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.SaveAddonSetButton = SaveAddonSetButton
    SaveAddonSetButton:SetSize(16, 16)
    local saveAddonSetTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\save.png"
    SaveAddonSetButton:SetNormalTexture(saveAddonSetTexure)
    SaveAddonSetButton:SetHighlightTexture(saveAddonSetTexure)
    SaveAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    SaveAddonSetButton:SetPoint("TOPRIGHT", -8, -8)
    SaveAddonSetButton:SetScript("OnEnter", onSaveAddonSetButtonEnter)
    SaveAddonSetButton:SetScript("OnLeave", onSaveAddonSetButtonLeave)
    SaveAddonSetButton:SetScript("OnClick", onSaveAddonSetButtonClick)

    -- 替换按钮
    local ReplaceAddonsButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.ReplaceAddonsButton = ReplaceAddonsButton
    ReplaceAddonsButton:SetSize(16, 16)
    local replaceAddonsTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\replace.png"
    ReplaceAddonsButton:SetNormalTexture(replaceAddonsTexure)
    ReplaceAddonsButton:SetHighlightTexture(replaceAddonsTexure)
    ReplaceAddonsButton:GetHighlightTexture():SetAlpha(0.2)
    ReplaceAddonsButton:SetPoint("RIGHT", SaveAddonSetButton, "LEFT", -4,0)
    ReplaceAddonsButton:SetScript("OnEnter", onReplaceAddonsButtonEnter)
    ReplaceAddonsButton:SetScript("OnLeave", onReplaceAddonsButtonLeave)
    ReplaceAddonsButton:SetScript("OnClick", onReplaceAddonsButtonClick)

    -- 启用全部按钮
    local EnableAllButton = CreateFrame("Button", nil, AddonListContainer)
    AddonListContainer.EnableAllButton = EnableAllButton
    EnableAllButton:SetSize(16, 16)
    EnableAllButton:SetPoint("RIGHT", ReplaceAddonsButton, "LEFT", -4,0)
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
    AddonListSearchBox:HookScript("OnTextChanged", onAddonSetAddonListSearchBoxTextChanged)

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

    local addonListTreeView = CreateScrollBoxListLinearView(1, 1, 1, 1, 1)

    addonListTreeView:SetElementFactory(AddonSetAddonListNodeUpdater)
    addonListTreeView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonListScrollBox, AddonListScrollBar, addonListTreeView)

    local SettingsFrame = self:CreateSettingsFrame(AddonSetDialog)
    AddonSetDialog.SettingsFrame = SettingsFrame
    SettingsFrame:SetWidth(260)
    SettingsFrame:SetPoint("TOPLEFT", AddonListContainer, "TOPRIGHT", 10, 0)
    SettingsFrame:SetPoint("BOTTOMLEFT", AddonListContainer, "BOTTOMRIGHT", 10, 0)

    self:RefreshAddonSetListContainer()

    self:RegisterCallback("AddonSetSettings.AddonSetName", onAddonSetNameChanged, self)
    self:RegisterCallback("AddonSetSettings.AddonSetEnabled", onAddonSetEnabledChanged, self)
end

function Addon:GetAddonSetDialog()
    return self:GetOrCreateUI().AddonSetDialog
end

function Addon:GetAddonSetListScrollBox()
    return self:GetOrCreateUI().AddonSetDialog.AddonSetListContainer.ScrollBox
end

function Addon:GetAddonSetListSearchBox()
    return self:GetOrCreateUI().AddonSetDialog.AddonSetListContainer.SearchBox
end

-- 设置当前聚焦的插件集
function Addon:SetCurrentFocusAddonSetName(addonSetName)
    self.FocusAddonSetName = addonSetName
end

-- 获取当前聚焦的插件集
function Addon:GetCurrentFocusAddonSetName()
    return self.FocusAddonSetName
end

-- 获取当前聚焦的插件集
function Addon:GetCurrentFocusAddonSet()
    if self.FocusAddonSetName then
        return self:GetAddonSetByName(self.FocusAddonSetName)
    end
end

function Addon:RefreshAddonSetListContainer(targetAddonSetName)
    local addonSetDialog = self:GetAddonSetDialog()
    if not addonSetDialog then
        return
    end
    
    self:RefreshAddonSetList()
    
    -- 没有插件集时，刷新框体
    local addonSets = self:GetAddonSets()
    if next(addonSets) == nil then
        self:SetCurrentFocusAddonSetName(nil)
        self:RefreshAddonSetAddonListContainer()
        self:RefreshAddonSetSettings()
        return
    end

    if not targetAddonSetName then
        local activeAddonSetName = self:GetActiveAddonSetName()
        if activeAddonSetName then
            targetAddonSetName = activeAddonSetName
        end
    end

    local selectPredicate = function(node)
        if targetAddonSetName then
            return targetAddonSetName == node.Name 
        else
            return node
        end
    end

    self:GetAddonSetListScrollBox().SelectionBehavior:SelectElementDataByPredicate(selectPredicate)
    self:ScrollToSelectedAddonSet()
end

function Addon:ScrollToSelectedAddonSet()
    local selectedPredicate = function(elementData)
        return self:GetAddonSetListScrollBox().SelectionBehavior:IsElementDataSelected(elementData)
    end
    self:GetAddonSetListScrollBox():ScrollToElementDataByPredicate(selectedPredicate, ScrollBoxConstants.AlignCenter, 0, ScrollBoxConstants.NoScrollInterpolation)
end

-- 刷新插件集列表
function Addon:RefreshAddonSetList()
    local addonSetDialog = self:GetAddonSetDialog()
    if not addonSetDialog then
        return
    end

    addonSetDialog.AddonSetDataProvider = addonSetDialog.AddonSetDataProvider or CreateDataProvider()
    local addonSetDataProvider = addonSetDialog.AddonSetDataProvider

    local searchText = self:GetAddonSetListSearchBox():GetText()
    searchText = searchText and strtrim(searchText)
    searchText = searchText and searchText:lower()

    addonSetDataProvider:Flush()

    local shouldFilter = searchText and strlenutf8(searchText) > 0
    local addonSets = self:GetAddonSets()

    for addonSetName, addonSet in pairs(addonSets) do
        if shouldFilter then
            if addonSetName:lower():match(searchText) then
                addonSetDataProvider:Insert(addonSet)
            end
        else
            addonSetDataProvider:Insert(addonSet)
        end
    end

    local function sortComparator(a, b)
        if a == nil or b == nil then
            return false
        end

        if a.Enabled == b.Enabled then
            return b.Name < a.Name
        end
        
        return a.Enabled
    end

    addonSetDataProvider:SetSortComparator(sortComparator)

    self:GetAddonSetListScrollBox():SetDataProvider(addonSetDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function Addon:GetAddonSetAddonListContainer()
    return self:GetOrCreateUI().AddonSetDialog.AddonListContainer
end

function Addon:GetAddonSetAddonListScrollBox()
    return self:GetAddonSetAddonListContainer().ScrollBox
end

function Addon:GetAddonSetAddonListSearchBox()
    return self:GetAddonSetAddonListContainer().SearchBox
end

function Addon:RefreshAddonSetAddonListContainer()
    self:RefreshAddonSetAddonList()
    self:RefreshAddonSetAddonListOptionButtonsStatus()
end

function Addon:UpdateAddonSetAddonItems(addonName)
    local forEach = function(frame, node)
        if addonName then
            if addonName == node.Name then
                frame:Update()
            end
        else
            frame:Update()
        end
    end
    self:GetAddonSetAddonListScrollBox():ForEachFrame(forEach)
    self:RefreshAddonSetAddonListOptionButtonsStatus()
end

function Addon:RefreshAddonSetAddonList()
    local addonSetDialog = self:GetAddonSetDialog()
    if not addonSetDialog then
        return
    end

    addonSetDialog.AddonSetAddonDataProvider = addonSetDialog.AddonSetAddonDataProvider or CreateDataProvider()
    local addonSetAddonDataProvider = addonSetDialog.AddonSetAddonDataProvider

    local searchText = self:GetAddonSetAddonListSearchBox():GetText()
    searchText = searchText and strtrim(searchText)
    searchText = searchText and searchText:lower()

    addonSetAddonDataProvider:Flush()

    local shouldFilter = searchText and strlenutf8(searchText) > 0
    local addonInfos = self:GetAddonInfos()
    
    for index, addonInfo in ipairs(addonInfos) do
        -- 本插件不纳入插件集
        if not self:IsAddonManager(addonInfo.Name) then
            if shouldFilter then
                local nickName = self:GetAddonRemark(addonInfo.Name) or ""
                if addonInfo.Title:lower():match(searchText) or addonInfo.Name:lower():match(searchText) or nickName:lower():match(searchText) then
                    addonSetAddonDataProvider:Insert(addonInfo)
                end
            else
                addonSetAddonDataProvider:Insert(addonInfo)
            end
        end
    end

    self:GetAddonSetAddonListScrollBox():SetDataProvider(addonSetAddonDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function Addon:RefreshAddonSetAddonListOptionButtonsStatus()
    local addonSetDialog = self:GetAddonSetDialog()
    if not addonSetDialog then
        return
    end

    local AddonListContainer = self:GetAddonSetAddonListContainer()
    
    -- 更新启用全部按钮
    local EnableAllButton = AddonListContainer.EnableAllButton
    local isAllAddonsEnabled, isAllAddonsDisabled, addonListCanReset = IsAllAddonsEnabledInCurrentFocusAddonSet()
    local enableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (isAllAddonsEnabled and "enable_all_checked" or "enable_all")
    EnableAllButton:SetNormalTexture(enableAllTexture)
    EnableAllButton:SetHighlightTexture(enableAllTexture)
    EnableAllButton:GetHighlightTexture():SetAlpha(0.2)
    
    -- 更新禁用全部按钮
    local DisableAllButton = AddonListContainer.DisableAllButton
    local disableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (isAllAddonsDisabled and "disable_all_checked" or "disable_all")
    DisableAllButton:SetNormalTexture(disableAllTexture)
    DisableAllButton:SetHighlightTexture(disableAllTexture)
    DisableAllButton:GetHighlightTexture():SetAlpha(0.2)

    -- 更新重置按钮
    local ResetButton = AddonListContainer.ResetButton
    local resetButtonTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (addonListCanReset and "reset.png" or "reset_disabled.png")
    ResetButton:SetNormalTexture(resetButtonTexture)
    ResetButton:SetHighlightTexture(resetButtonTexture)
    ResetButton:GetHighlightTexture():SetAlpha(0.2)
end