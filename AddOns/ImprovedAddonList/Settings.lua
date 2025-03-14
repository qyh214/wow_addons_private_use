local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local function TriggerSettingsMenuUpdate(settingsItem)
    if settingsItem and settingsItem.Event then
        Addon:TriggerEvent(settingsItem.Event, settingsItem)
        Addon:TriggerEvent("SettingsMenuUpdate", settingsItem.Event)
    end
end

-- 创建子弹窗
function Addon:GetOrCreateSettingsDialog(type)
    self.SettingsDialogs = self.SettingsDialogs or {}

    local dialog = self.SettingsDialogs[type]
    if dialog then
        dialog:Show()
        return dialog
    end

    local UI = self:GetOrCreateUI()
    dialog = CreateFrame("Frame", nil, UI, "TooltipBackdropTemplate")
    self.SettingsDialogs[type] = dialog

    dialog:SetFrameStrata("DIALOG")
    dialog:SetFrameLevel(1000)
    dialog:SetMouseMotionEnabled(true)
    dialog:SetMouseClickEnabled(true)

    -- 框体外点击消失
    dialog:SetScript("OnShow", function(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    dialog:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)

    dialog:RegisterEvent("GLOBAL_MOUSE_DOWN")
    dialog:SetScript("OnEvent", function(self, event)
        if event == "GLOBAL_MOUSE_DOWN" and not self:IsMouseOver() then
            self:Hide()
        end
    end)

    return dialog
end

-- 单选项
local SettingsSingleChoiceItemMixin = {}

function SettingsSingleChoiceItemMixin:OnLoad()
    self:SetHeight(20)

    local label = self:CreateFontString(nil, nil, "GameFontWhite")
    self.Label = label
    label:SetWordWrap(false)
    label:SetPoint("LEFT", 5, 0)

    local radioButton = self:CreateTexture()
    self.RadioButton = radioButton
    radioButton:SetSize(14, 14)
    radioButton:SetPoint("RIGHT", -5, 0)

    local hightlightOverlay = self:CreateTexture(nil, "HIGHLIGHT")
    hightlightOverlay:SetAtlas("Professions_Recipe_Hover", true)
    hightlightOverlay:SetAlpha(0.5)
    hightlightOverlay:SetAllPoints()

    self:SetScript("OnClick", function(self)
        self.SettingsItem:SetValue(self.Choice.Value)
        TriggerSettingsMenuUpdate(self.SettingsItem)
    end)

    self:SetScript("OnHide", function(self)
        self.SettingsItem = nil
        self.Choice = nil
    end)

    self:SetScript("OnEnter", function(self)
        local choice = self.Choice
        if choice and choice.Tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(choice.Tooltip, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)

    self:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    Addon:RegisterCallback("SettingsMenuUpdate", self.OnSettingsMenuUpdate, self)
end

function SettingsSingleChoiceItemMixin:OnSettingsMenuUpdate(event)
    if self.SettingsItem and self.SettingsItem.Event == event then
        self:Update()
    end
end

-- 设置单选项
function SettingsSingleChoiceItemMixin:SetChoiceItem(settingsItem, choice)
    self.SettingsItem = settingsItem
    self.Choice = choice

    self:Update()
end

-- 刷新
function SettingsSingleChoiceItemMixin:Update()
    local choice = self.Choice
    if not choice then
        return
    end

    self.Label:SetText(choice.Text)
    local checked = self.SettingsItem:GetValue() == choice.Value
    local tex = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (checked and "radio_button_checked.png" or "radio_button.png")
    self.RadioButton:SetTexture(tex)
end

function SettingsSingleChoiceItemMixin:GetWrapContentWidth()
    return self.Label:GetUnboundedStringWidth() + 30
end

-- 创建单选项
local function CreateSingleChoiceItem(parent)
    local item = Mixin(CreateFrame("Button", nil, parent), SettingsSingleChoiceItemMixin)
    item:OnLoad()
    return item
end

-- 显示单选弹窗
function Addon:ShowSingleChoiceDialog(owner, settingsItem)
    local Dialog = self:GetOrCreateSettingsDialog(settingsItem.Type)
    Dialog.ChoiceItems = Dialog.ChoiceItems or {}

    local choicesSize = #settingsItem.Choices

    for i, choice in ipairs(settingsItem.Choices) do
        local item = Dialog.ChoiceItems[i]
        if not item then
            item = CreateSingleChoiceItem(Dialog)
            Dialog.ChoiceItems[i] = item
        end

        item:SetChoiceItem(settingsItem, choice)
    end

    local paddingVertical = 10
    local marginVertical = 5
    local maxItemWidth = 0
    for i, item in ipairs(Dialog.ChoiceItems) do
        item:ClearAllPoints()
        if i <= choicesSize then
            item:Show()
            item:SetPoint("TOPLEFT", 10, -(paddingVertical + (20 + marginVertical) * (i - 1)))
            item:SetPoint("RIGHT", -10, 0)
            maxItemWidth = math.max(maxItemWidth, item:GetWrapContentWidth())
        else
            item:Hide()
        end
    end

    Dialog:SetWidth(maxItemWidth + 20)
    Dialog:SetHeight(choicesSize * 20 + (choicesSize - 1) * marginVertical + paddingVertical * 2)

    Dialog:ClearAllPoints()
    Dialog:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, -3)
end

-- 设置项：组
ImprovedAddonListSettingsGroupItemMixin = {}

function ImprovedAddonListSettingsGroupItemMixin:OnResetClick()
    local childrenNodes = self:GetElementData():GetNodes()
    if childrenNodes then
        for _, node in ipairs(childrenNodes) do
            local item = node:GetData()
            if item and item.Reset then
                item:Reset()
                TriggerSettingsMenuUpdate(item)
            end
        end
    end
end

function ImprovedAddonListSettingsGroupItemMixin:OnResetEnter()
    GameTooltip:SetOwner(self.Reset)
    GameTooltip:AddLine(SETTINGS_DEFAULTS, 1, 1, 1)
    GameTooltip:Show()
end

function ImprovedAddonListSettingsGroupItemMixin:OnResetLeave()
    GameTooltip:Hide()
end

function ImprovedAddonListSettingsGroupItemMixin:OnExpandClick()
    self:GetElementData():SetChildrenCollapsed(false)
end

function ImprovedAddonListSettingsGroupItemMixin:OnExpandEnter()
    GameTooltip:SetOwner(self.ExpandAll)
    GameTooltip:AddLine(L["settings_group_expand_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

function ImprovedAddonListSettingsGroupItemMixin:OnExpandLeave()
    GameTooltip:Hide()
end

function ImprovedAddonListSettingsGroupItemMixin:OnCollapseClick()
    self:GetElementData():SetChildrenCollapsed(true)
end

function ImprovedAddonListSettingsGroupItemMixin:OnCollapseEnter()
    GameTooltip:SetOwner(self.CollapseAll)
    GameTooltip:AddLine(L["settings_group_collapse_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

function ImprovedAddonListSettingsGroupItemMixin:OnCollapseLeave()
    GameTooltip:Hide()
end

function ImprovedAddonListSettingsGroupItemMixin:Update()
    local data = self:GetElementData():GetData()
    self.Title:SetText(data.Title)
    
    local canReset, canExpand = false, false
    local childrenNodes = self:GetElementData():GetNodes()
    if childrenNodes then
        for _, node in ipairs(childrenNodes) do
            local item = node:GetData()
            if item and item.Reset then
               canReset = true
            end

            if item and (item.Items or item.GetItems) then
                canExpand = true
            end 
            
            if canReset and canExpand then
                break
            end
        end
    end

    self.Reset:SetShown(canReset)
    self.ExpandAll:SetShown(canExpand)
    self.CollapseAll:SetShown(canExpand)
   
    if canExpand then
        self.ExpandAll:ClearAllPoints()
        if canReset then
            self.ExpandAll:SetPoint("RIGHT", self.Reset, "LEFT", -5, 0)
        else
            self.ExpandAll:SetPoint("RIGHT", -5, 0)
        end
    end
end

-- 设置项
ImprovedAddonListSettingsItemMixin = {}

function ImprovedAddonListSettingsItemMixin:OnLoad()
    local function onSettingsMenuUpdate(self, event)
        if not self.GetElementData then
            -- 此时被回收了
            return
        end

        local item = self:GetElementData():GetData()
        if item and item.Event == event then
            self:OnBind(item)
        end
    end
    Addon:RegisterCallback("SettingsMenuUpdate", onSettingsMenuUpdate, self)
end

function ImprovedAddonListSettingsItemMixin:OnBind(item)
end

function ImprovedAddonListSettingsItemMixin:OnEnter()
    local item = self:GetElementData():GetData()
    if item.Tooltip then
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(item.Tooltip, 1, 1, 1, true)
        GameTooltip:Show()
    elseif item.OnEnter then
        item:OnEnter(self)
    end
end

function ImprovedAddonListSettingsItemMixin:OnLeave()
    GameTooltip:Hide()
end

-- 设置项更新
function ImprovedAddonListSettingsItemMixin:Update()
    local item = self:GetElementData():GetData()
    self:SetTitle(item.Title, item.SubTitle)
    self:OnBind(item)
end

-- 设置项标题和副标题
function ImprovedAddonListSettingsItemMixin:SetTitle(title, subTitle)
    title = title or ""
    subTitle = subTitle or ""
    self.Title:SetText(title)
    self.SubTitle:SetText(subTitle)

    self.Title:ClearAllPoints()
    self.SubTitle:ClearAllPoints()

    if strlenutf8(subTitle) > 0 then
        self.Title:SetPoint("TOPLEFT", 5, -3)
        self.SubTitle:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -2)
        self.SubTitle:Show()
    else
        self.Title:SetPoint("LEFT", 5, 1)
        self.SubTitle:Hide()
    end
end

-- 单选项
ImprovedAddonListSettingsItemSingleChoiceMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

-- 单选项：获得当前值
function ImprovedAddonListSettingsItemSingleChoiceMixin:OnBind(item)
    local value = item:GetValue()
    local choice = FindValueInTableIf(item.Choices, function(choice) return choice.Value == value end)
    self.Value:SetText(choice and (choice.Description or choice.Text) or "")
end

-- 单选项：点击
function ImprovedAddonListSettingsItemSingleChoiceMixin:OnClick()
    local item = self:GetElementData():GetData()
    Addon:ShowSingleChoiceDialog(self, item)
end

-- 颜色选择器
ImprovedAddonListSettingsItemColorPickerMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemColorPickerMixin:OnBind(item)
    self.Indicator:SetVertexColor(item:GetColor():GetRGB())
end

function ImprovedAddonListSettingsItemColorPickerMixin:OnClick()
    local item = self:GetElementData():GetData()
    local color = item:GetColor()

    local onColorChanged = function(color)
        item:SetColor(color)
        TriggerSettingsMenuUpdate(item)
    end

    local info = {
        hasOpacity = false,
        r = color.r,
        g = color.g,
        b = color.b,
        swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local color = CreateColor(r, g, b)
            onColorChanged(color)
        end,
        cancelFunc = function(previousValues)
            local r, g, b = previousValues.r, previousValues.g, previousValues.b
            onColorChanged(CreateColor(r, g, b))
        end
    }
    ColorPickerFrame:SetupColorPickerAndShow(info)
end

-- 编辑框
ImprovedAddonListSettingsItemEditBoxMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemEditBoxMixin:OnBind(item)
    self.Value:SetText(item:GetText())
end

function ImprovedAddonListSettingsItemEditBoxMixin:OnClick()
    local item = self:GetElementData():GetData()
    local editInfo = {
        Title = item.Title,
        Label = item.Label,
        Text = item:GetText(),
        MaxLetters = item.MaxLetters,
        MaxLines = item.MaxLines,
        OnConfirm = function(text)
            if item:SetText(text) then
                TriggerSettingsMenuUpdate(item)
                return true
            end
        end
    }
    Addon:ShowEditDialog(editInfo)
end

-- Switch
ImprovedAddonListSettingsItemSwitchMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemSwitchMixin:OnBind(item)
    local enabled = item:IsEnabled()
    local tex = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (enabled and "switch_on.png" or "switch_off.png")
    self.Toggle:SetNormalTexture(tex)
    self.Toggle:SetHighlightTexture(tex)
    self.Toggle:GetHighlightTexture():SetAlpha(0.2)
end

function ImprovedAddonListSettingsItemSwitchMixin:OnClick()
    local item = self:GetElementData():GetData()
    local enabled = item:IsEnabled() and true or false
    if item:SetEnabled(not enabled) then
        TriggerSettingsMenuUpdate(item)
    end
end

-- 滑动条
ImprovedAddonListSettingsSliderMixin = {}

function ImprovedAddonListSettingsSliderMixin:OnValueChanged(value)
    local minValue, maxValue = self:GetMinMaxValues()
    local percent = 0
    if maxValue > minValue and value > minValue then
        percent = (value - minValue) / (maxValue - minValue)
    end

    local width = self:GetWidth() * percent
    if width <= 0 then
        width = 1
    end

    self.TrackActive:SetWidth(width)

    local parent = self:GetParent()
    if parent and parent.OnValueChanged then
        parent:OnValueChanged(value)
    end
end

function ImprovedAddonListSettingsSliderMixin:OnMouseDown()
    if self:IsDraggingThumb() then
        local parent = self:GetParent()
        if parent.OnSliderThumbDragStart then
            parent:OnSliderThumbDragStart()
        end
    end
end

function ImprovedAddonListSettingsSliderMixin:OnMouseUp()
    local parent = self:GetParent()
    if parent.OnSliderThumbDragStop then
        parent:OnSliderThumbDragStop()
    end
end

ImprovedAddonListSettingsItemSliderMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemSliderMixin:OnBind(item)
    local min, max = item.MinValue, item.MaxValue
    if min >= max then
        error(item.Title .. "'s min value(" .. min .. ") must less than max value(" .. max .. ")")
    end

    local value = item:GetValue()
    if value < min or value > max then
        error("value(" .. value .. ") invalid, because slider's min and max values is [" .. min .. "," ..  max .. "]")    
    end

    self.MinValue:SetText(tostring(min))
    self.MaxValue:SetText(tostring(max))
    self.Slider:SetMinMaxValues(min, max)
    self.Slider:SetValueStep(item.ValueStep)
    self.Slider:SetPoint("RIGHT", self, "RIGHT", -(self.MaxValue:GetStringWidth() + 8), 0)
    self.Slider:SetValue(value, false)
    self.Confirm:SetShown(value ~= item:GetValue())
end

function ImprovedAddonListSettingsItemSliderMixin:OnValueChanged(value)
    if not self.GetElementData then
        -- 此时还未绑定界面
        return
    end

    local item = self:GetElementData():GetData()
    if item.TrimValue then
        value = item:TrimValue(value)
    end
    self.Value:SetText(tostring(value))
    self.Confirm:SetShown(value ~= item:GetValue())
    -- 临时保存变量
    item:SetValue(value)
end

function ImprovedAddonListSettingsItemSliderMixin:OnSliderThumbDragStart()
    if self.Value.FadeJob then
        self.Value.FadeJob:Cancel()
    end
    self.Value:Show()
end

function ImprovedAddonListSettingsItemSliderMixin:OnSliderThumbDragStop()
    if self.Value.FadeJob then
        self.Value.FadeJob:Cancel()
    end
    self.Value.FadeJob = C_Timer.NewTimer(3, function()
        self.Value:Hide()
    end)
end

function ImprovedAddonListSettingsItemSliderMixin:OnConfirmClick()
    local item = self:GetElementData():GetData()
    item:Save()
    TriggerSettingsMenuUpdate(item)
end

function ImprovedAddonListSettingsItemSliderMixin:OnConfirmEnter()
    GameTooltip:SetOwner(self.Confirm)
    GameTooltip:AddLine(L["settings_slider_confirm_tips"], 1, 1, 1, true)
    GameTooltip:Show()
end

function ImprovedAddonListSettingsItemSliderMixin:OnConfirmLeave()
    GameTooltip:Hide()
end

-- 动态编辑框
ImprovedAddonListSettingsItemDynamicEditBoxMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemDynamicEditBoxMixin:OnClick()
    local node = self:GetElementData()
    local item = node:GetData()
    local editInfo = {
        Title = item.Title,
        Label = item.Label,
        MaxLetters = item.MaxLetters,
        MaxLines = item.MaxLines,
        OnConfirm = function(text)
            if item.AddItem then
                local item = item:AddItem(text)
                if item then
                    node:Insert(item)
                    return true
                end
            end
        end
    }
    Addon:ShowEditDialog(editInfo)
end

-- 动态编辑框-子项
ImprovedAddonListSettingsItemDynamicEditBoxItemMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemDynamicEditBoxItemMixin:OnAppendLoad()
    self.Title:SetTextColor(WHITE_FONT_COLOR:GetRGB())
end

function ImprovedAddonListSettingsItemDynamicEditBoxItemMixin:OnDelete()
    local node = self:GetElementData()
    local item = node:GetData()
    local parentNode = node:GetParent()
    local parentItem = parentNode:GetData()
    if parentItem.RemoveItem and parentItem:RemoveItem(item.Value) then
        parentNode:Remove(node)
    end
end

function ImprovedAddonListSettingsItemDynamicEditBoxItemMixin:OnDeleteEnter()
    GameTooltip:SetOwner(self.Delete)
    GameTooltip:AddLine(L["settings_dynamic_edit_box_delete_tips"], 1, 1, 1, true)
    GameTooltip:Show()
end

function ImprovedAddonListSettingsItemDynamicEditBoxItemMixin:OnDeleteLeave()
    GameTooltip:Hide()
end

-- 多选项
ImprovedAddonListSettingsItemMultiChoiceMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemMultiChoiceMixin:OnBind(item)
    local collapsed = self:GetElementData():IsCollapsed()
    local tex = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (collapsed and "expand.png" or "collapse.png")
    self.CollapseStatus:SetTexture(tex)
end

function ImprovedAddonListSettingsItemMultiChoiceMixin:OnClick()
    local node = self:GetElementData()
    node:ToggleCollapsed()
    self:Update()
end

-- 多选项-子项
ImprovedAddonListSettingsItemMultiChoiceItemMixin = CreateFromMixins(ImprovedAddonListSettingsItemMixin)

function ImprovedAddonListSettingsItemMultiChoiceItemMixin:OnAppendLoad()
    self.Title:SetTextColor(WHITE_FONT_COLOR:GetRGB())
end

function ImprovedAddonListSettingsItemMultiChoiceItemMixin:OnBind(item)
    local checked = item.Checked
    local tex = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (checked and "enabled.png" or "enable_status_border.png")
    self.CheckStatus:SetTexture(tex)
end

function ImprovedAddonListSettingsItemMultiChoiceItemMixin:OnClick()
    local node = self:GetElementData()
    local item = node:GetData()
    local parentNode = node:GetParent()
    local parentItem = parentNode:GetData()
    local checked = not item.Checked
    if parentItem.OnItemCheckedChange and parentItem:OnItemCheckedChange(item.Value, checked) then
        item.Checked = checked
        self:Update()
    end
end

-- 设置窗体
local SettingsFrameMixin = {}

-- 设置列表项节点更新
local function SettingListItemNodeUpdater(factory, node)
    local function Initializer(button, node)
        button:Update()
    end

    local data = node:GetData()
    if data.IsGroup then
        factory("ImprovedAddonListSettingsGroupItemTemplate", Initializer)
    elseif data.Type == "singleChoice" then
        factory("ImprovedAddonListSettingsItemSingleChoiceTemplate", Initializer)
    elseif data.Type == "colorPicker" then
        factory("ImprovedAddonListSettingsItemColorPickerTemplate", Initializer)
    elseif data.Type == "editBox" then
        factory("ImprovedAddonListSettingsItemEditBoxTemplate", Initializer)
    elseif data.Type == "switch" then
        factory("ImprovedAddonListSettingsItemSwitchTemplate", Initializer)
    elseif data.Type == "slider" then
        factory("ImprovedAddonListSettingsItemSliderTemplate", Initializer)
    elseif data.Type == "dynamicEditBox" then
        factory("ImprovedAddonListSettingsItemDynamicEditBoxTemplate", Initializer)
    elseif data.Type == "dynamicEditBoxItem" then
        factory("ImprovedAddonListSettingsItemDynamicEditBoxItemTemplate", Initializer)
    elseif data.Type == "multiChoice" then
        factory("ImprovedAddonListSettingsItemMultiChoiceTemplate", Initializer)
    elseif data.Type == "multiChoiceItem" then
        factory("ImprovedAddonListSettingsItemMultiChoiceItemTemplate", Initializer)
    end
end

-- 列表长度
local function ElementExtentCalculator(index, node)
    local data = node:GetData()

    if data.IsGroup then
        return 24
    else
        local title = data.Title or ""
        local subTitle = data.SubTitle or ""
        if strlenutf8(subTitle) > 0 then
            return 40
        else
            return 24
        end
    end
end

function SettingsFrameMixin:OnLoad()
    local Title = self:CreateFontString(nil, nil, "GameFontNormal")
    self.Title = Title
    Title:SetPoint("CENTER", self, "TOP", 0, 0)

    local ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = ScrollBox

    local Scrollbar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    Scrollbar:SetPoint("TOPRIGHT", -10, -7)
    Scrollbar:SetPoint("BOTTOMRIGHT", -10, 7)

    local anchorsWithScrollBar = {
        CreateAnchor("TOPLEFT", 5, -7);
        CreateAnchor("BOTTOMRIGHT", Scrollbar, "BOTTOMLEFT", -5, 0),
    }
    
    local anchorsWithoutScrollBar = {
        CreateAnchor("TOPLEFT", 5, -7),
        CreateAnchor("BOTTOMRIGHT", -7, 7);
    }

    local ScrollView = CreateScrollBoxListTreeListView(10, 0, 0, 0, 0, 1)
    ScrollView:SetElementFactory(SettingListItemNodeUpdater)
    ScrollView:SetElementExtentCalculator(ElementExtentCalculator)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, Scrollbar, ScrollView)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, Scrollbar, anchorsWithScrollBar, anchorsWithoutScrollBar)
end

-- 显示设置信息
function SettingsFrameMixin:ShowSettings(settingsInfo)
    self.Title:SetText(settingsInfo and settingsInfo.Title or "")

    self.SettingsDataProvider = self.SettingsDataProvider or CreateTreeDataProvider()
    local dataProvider = self.SettingsDataProvider
    dataProvider:Flush()

    if settingsInfo then
        local rootNode = dataProvider:GetRootNode()
        for _, groupInfo in ipairs(settingsInfo.Groups) do
            local categoryNode = rootNode:Insert({ IsGroup = true, Title = groupInfo.Title })
            for _, settingsItem in ipairs(groupInfo.Items) do
                local subNode = categoryNode:Insert(settingsItem)
                
                local initExpand = false
                if settingsItem.InitExpand then
                    initExpand = settingsItem:InitExpand()
                end
                subNode:SetCollapsed(not initExpand)
                
                local subItems = settingsItem.Items or (settingsItem.GetItems and settingsItem:GetItems())
                if subItems then
                    for _, subSettingsItem in ipairs(subItems) do
                        subNode:Insert(subSettingsItem)
                    end
                end
            end
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)

    self:Show()
end

function SettingsFrameMixin:GetScrollBox()
    return self.ScrollBox
end

-- 创建设置窗体
function Addon:CreateSettingsFrame(parent)
    local UI = self:GetOrCreateUI()
    local SettingsFrame = Mixin(self:CreateContainer(parent or UI), SettingsFrameMixin)
    SettingsFrame:OnLoad()
    return SettingsFrame
end
