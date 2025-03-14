local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ImprovedAddonListAddonSetChoiceDialogItemMixin = {}

function ImprovedAddonListAddonSetChoiceDialogItemMixin:Update()
    local item = self:GetData()
    local addonSet = item.AddonSet
    self.Label:SetText(addonSet.Name)
    local enableStatusTex = "Interface\\Addons\\ImprovedAddonList\\Media\\" .. (item.Checked and "enabled.png" or "enable_status_border.png")
    self.EnableStatus:SetTexture(enableStatusTex)
end

function ImprovedAddonListAddonSetChoiceDialogItemMixin:OnClick()
    local item = self:GetData()
    item.Checked = not item.Checked
    self:Update()
    self:GetParent():GetParent():GetParent():UpdateButtonStatus()
end

local function showAddonListGameTooltip(self, title)
    local addons = {}
    for _, addonName in ipairs(self:GetParent():GetTargetAddons()) do
        tinsert(addons, { Name = addonName })
    end

    local addonListTooltipInfo = {
        Addons = addons,
        Label = title
    }

    Addon:ShowAddonListTooltips(self, addonListTooltipInfo)
end

local function onMergeButtonEnter(self)
    showAddonListGameTooltip(self, L["addon_set_choice_merge_tips"])
end

local function onMergeButtonLeave(self)
    Addon:HideAddonListTooltips()
end

local function onMergeButtonClick(self)
    self:GetParent():MergeAddonsToSelectedAddonSets()
end

local function onReplaceButtonEnter(self)
    showAddonListGameTooltip(self, L["addon_set_choice_replace_tips"])
end

local function onReplaceButtonLeave(self)
    Addon:HideAddonListTooltips()
end

local function onReplaceButtonClick(self)
    self:GetParent():ReplaceAddonsToSelectedAddonSets()
end

local function onDeleteButtonEnter(self)
    showAddonListGameTooltip(self, L["addon_set_choice_delete_tips"])
end

local function onDeleteButtonLeave(self)
    Addon:HideAddonListTooltips()
end

local function onDeleteButtonClick(self)
    self:GetParent():DeleteAddonsToSelectedAddonSets()
end

local function onEnableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_choice_enable_all_tips"], 1, 1, 1, true)
    GameTooltip:Show()
end

local function onEnableAllButtonLeave(self)
    GameTooltip:Hide()
end

local function onEnableAllButtonClick(self)
    local dialog = self:GetParent()
    dialog:GetDataProvider():ForEach(function(data)
        data.Checked = true
    end)
    dialog:GetScrollBox():ForEachFrame(function(frame)
        frame:Update()
    end)
    dialog:UpdateButtonStatus()
end

local function onDisableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_choice_disable_all_tips"], 1, 1, 1, true)
    GameTooltip:Show()
end

local function onDisableAllButtonLeave(self)
    GameTooltip:Hide()
end

local function onDisableAllButtonClick(self)
    local dialog = self:GetParent()
    dialog:GetDataProvider():ForEach(function(data)
        data.Checked = false
    end)
    dialog:GetScrollBox():ForEachFrame(function(frame)
        frame:Update()
    end)
    dialog:UpdateButtonStatus()
end

local function onAddonSetSearchBoxTextChanged(self, userInput)
    if self.searchJob then
        self.searchJob:Cancel()
    end
    
    if userInput or (self.preText and self.preText ~= self:GetText()) then
        self.preText = self:GetText()
        self.searchJob = C_Timer.NewTimer(0.25, function()
            self:GetParent():RefreshAddonSetList()
            self:GetParent():UpdateButtonStatus()
        end)
    end
end

local AddonSetChoiceDialogMixin = {}

function AddonSetChoiceDialogMixin:Init()
    self:SetWidth(200)
    self:SetFrameStrata("DIALOG")
    self:SetFrameLevel(400)
    self:SetMouseMotionEnabled(true)
    self:SetMouseClickEnabled(true)
    self:SetClampedToScreen(true)
    self:SetHeight(300)

    -- 框体外点击消失
    self:SetScript("OnShow", function(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    self:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)

    self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    self:SetScript("OnEvent", function(self, event)
        if event == "GLOBAL_MOUSE_DOWN" and not self:IsMouseOver() then
            self:Hide()
        end
    end)

    -- 合并按钮
    local MergeButton = CreateFrame("Button", nil, self)
    self.MergeButton = MergeButton
    local mergeButtonTex = "Interface\\AddOns\\ImprovedAddonList\\Media\\merge.png"
    MergeButton:SetSize(16, 16)
    MergeButton:SetPoint("TOPRIGHT", -8, -8)
    MergeButton:SetNormalTexture(mergeButtonTex)
    MergeButton:SetHighlightTexture(mergeButtonTex)
    MergeButton:GetHighlightTexture():SetAlpha(0.2)
    MergeButton:SetScript("OnEnter", onMergeButtonEnter)
    MergeButton:SetScript("OnLeave", onMergeButtonLeave)
    MergeButton:SetScript("OnClick", onMergeButtonClick)

    -- 替换按钮
    local ReplaceButton = CreateFrame("Button", nil, self)
    self.ReplaceButton = ReplaceButton
    local replaceButtonTex = "Interface\\AddOns\\ImprovedAddonList\\Media\\replace.png"
    ReplaceButton:SetSize(16, 16)
    ReplaceButton:SetPoint("RIGHT", MergeButton, "LEFT", -4, 0)
    ReplaceButton:SetNormalTexture(replaceButtonTex)
    ReplaceButton:SetHighlightTexture(replaceButtonTex)
    ReplaceButton:GetHighlightTexture():SetAlpha(0.2)
    ReplaceButton:SetScript("OnEnter", onReplaceButtonEnter)
    ReplaceButton:SetScript("OnLeave", onReplaceButtonLeave)
    ReplaceButton:SetScript("OnClick", onReplaceButtonClick)

    -- 删除按钮
    local DeleteButton = CreateFrame("Button", nil, self)
    self.DeleteButton = DeleteButton
    local deleteButtonTex = "Interface\\AddOns\\ImprovedAddonList\\Media\\delete.png"
    DeleteButton:SetSize(16, 16)
    DeleteButton:SetPoint("RIGHT", ReplaceButton, "LEFT", -4, 0)
    DeleteButton:SetNormalTexture(deleteButtonTex)
    DeleteButton:SetHighlightTexture(deleteButtonTex)
    DeleteButton:GetHighlightTexture():SetAlpha(0.2)
    DeleteButton:SetScript("OnEnter", onDeleteButtonEnter)
    DeleteButton:SetScript("OnLeave", onDeleteButtonLeave)
    DeleteButton:SetScript("OnClick", onDeleteButtonClick)

    -- 启用全部按钮
    local EnableAllButton = CreateFrame("Button", nil, self)
    self.EnableAllButton = EnableAllButton
    EnableAllButton:SetSize(16, 16)
    EnableAllButton:SetPoint("RIGHT", DeleteButton, "LEFT", -4, 0)
    EnableAllButton:SetScript("OnEnter", onEnableAllButtonEnter)
    EnableAllButton:SetScript("OnLeave", onEnableAllButtonLeave)
    EnableAllButton:SetScript("OnClick", onEnableAllButtonClick)

    -- 禁用全部按钮
    local DisableAllButton = CreateFrame("Button", nil, self)
    self.DisableAllButton = DisableAllButton
    DisableAllButton:SetSize(16, 16)
    DisableAllButton:SetPoint("RIGHT", EnableAllButton, "LEFT", -4, 0)
    DisableAllButton:SetScript("OnEnter", onDisableAllButtonEnter)
    DisableAllButton:SetScript("OnLeave", onDisableAllButtonLeave)
    DisableAllButton:SetScript("OnClick", onDisableAllButtonClick)

    -- 插件集列表搜索框
    local AddonSetSearchBox = CreateFrame("EditBox", nil, self, "SearchBoxTemplate")
    self.SearchBox = AddonSetSearchBox
    AddonSetSearchBox:SetPoint("LEFT", 14, 0)
    AddonSetSearchBox:SetPoint("TOPRIGHT", DisableAllButton, "TOPLEFT", -5, 0)
    AddonSetSearchBox:SetPoint("BOTTOMRIGHT", DisableAllButton, "BOTTOMLEFT", -5, 0)
    AddonSetSearchBox:HookScript("OnTextChanged", onAddonSetSearchBoxTextChanged)

    local AddonSetScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = AddonSetScrollBox
    AddonSetScrollBox:SetPoint("TOP", AddonSetSearchBox, "BOTTOM", 0, -5)
    AddonSetScrollBox:SetPoint("LEFT", 5, 0)
    AddonSetScrollBox:SetPoint("BOTTOMRIGHT", -25, 7)
    -- 滚动条
    local AddonSetScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    self.ScrollBar = AddonSetScrollBar
    AddonSetScrollBar:SetPoint("TOPLEFT", AddonSetScrollBox, "TOPRIGHT", 5, 0)
    AddonSetScrollBar:SetPoint("BOTTOMLEFT", AddonSetScrollBox, "BOTTOMRIGHT", 5, 0)

    local addonSetListView = CreateScrollBoxListLinearView(1, 1, 1, 1, 1)
    addonSetListView:SetElementInitializer("ImprovedAddonListAddonSetChoiceDialogItemTemplate", function(button, node)
        button:Update()
    end)
    addonSetListView:SetElementExtentCalculator(function()
        return 25
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonSetScrollBox, AddonSetScrollBar, addonSetListView)
end

function AddonSetChoiceDialogMixin:IsAllAddonSetSelected()
    local dataProvider = self:GetDataProvider()

    local allSelected, allDeselected
    for _, element in dataProvider:Enumerate() do
        if allSelected == nil and element.Checked ~= true then
            allSelected = false
        end
        if allDeselected == nil and element.Checked == true then
            allDeselected = false
        end
        if allSelected ~= nil and allDeselected ~= nil then
            break
        end
    end

    if allSelected == nil then
        allSelected = true
    end

    if allDeselected == nil then
        allDeselected = true
    end
    
    return allSelected, allDeselected
end

function AddonSetChoiceDialogMixin:UpdateButtonStatus()
    local EnableAllButton = self.EnableAllButton
    local isAllAddonSetSelected, isAllAddonSetDeselected = self:IsAllAddonSetSelected()
    local enableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (isAllAddonSetSelected and "enable_all_checked" or "enable_all")
    EnableAllButton:SetNormalTexture(enableAllTexture)
    EnableAllButton:SetHighlightTexture(enableAllTexture)
    EnableAllButton:GetHighlightTexture():SetAlpha(0.2)
    
    local DisableAllButton = self.DisableAllButton
    local disableAllTexture = "Interface\\AddOns\\ImprovedAddonList\\Media\\" .. (isAllAddonSetDeselected and "disable_all_checked" or "disable_all")
    DisableAllButton:SetNormalTexture(disableAllTexture)
    DisableAllButton:SetHighlightTexture(disableAllTexture)
    DisableAllButton:GetHighlightTexture():SetAlpha(0.2)
end

function AddonSetChoiceDialogMixin:GetDataProvider()
    self.AddonSetDataProvider = self.AddonSetDataProvider or CreateDataProvider()
    return self.AddonSetDataProvider
end

function AddonSetChoiceDialogMixin:GetScrollBox()
    return self.ScrollBox
end

function AddonSetChoiceDialogMixin:GetTargetAddons()
    return self.ChoiceInfo.Addons
end

function AddonSetChoiceDialogMixin:RefreshAddonSetList(reset)
    local addonSetDataProvider = self:GetDataProvider()

    local searchText = self.SearchBox:GetText()
    searchText = searchText and strtrim(searchText)
    searchText = searchText and searchText:lower()

    local checkStatus = {}
    addonSetDataProvider:ForEach(function(data)
        if data.Checked then
            checkStatus[data.AddonSet.Name] = true
        end
    end)

    addonSetDataProvider:Flush()

    local shouldFilter = searchText and strlen(searchText) > 0
    local addonSets = Addon:GetAddonSets()

    for addonSetName, addonSet in pairs(addonSets) do
        if not shouldFilter or addonSetName:lower():match(searchText) then 
            addonSetDataProvider:Insert({
                AddonSet = addonSet,
                Checked = not reset and checkStatus[addonSetName]
            })
        end
    end

    self.ScrollBox:SetDataProvider(addonSetDataProvider, ScrollBoxConstants.DiscardScrollPosition)
end

function AddonSetChoiceDialogMixin:SetupChoiceInfo(owner, choiceInfo)
    self.ChoiceInfo = choiceInfo
    self.SearchBox:SetText("")
    self:RefreshAddonSetList(true)
    self:UpdateButtonStatus()

    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -5)
    self:Show()
end

function AddonSetChoiceDialogMixin:MergeAddonsToSelectedAddonSets()
    local addonList = {}
    local targetAddons = self:GetTargetAddons()
    for _, addonName in ipairs(self:GetTargetAddons()) do
        addonList[addonName] = true
    end

    self:GetDataProvider():ForEach(function(data)
        if data.Checked then
            Addon:MergeAddonListToAddonSet(data.AddonSet.Name, addonList)
        end
    end)

    Addon:RefreshAddonSetContainer()
    Addon:RefreshAddonSetAddonListContainer()
    Addon:RefreshAddonDetailContainer()
    self:Hide()
end

function AddonSetChoiceDialogMixin:DeleteAddonsToSelectedAddonSets()
    local addonList = {}
    local targetAddons = self:GetTargetAddons()
    for _, addonName in ipairs(self:GetTargetAddons()) do
        addonList[addonName] = false
    end

    self:GetDataProvider():ForEach(function(data)
        if data.Checked then
            Addon:MergeAddonListToAddonSet(data.AddonSet.Name, addonList)
        end
    end)

    Addon:RefreshAddonSetContainer()
    Addon:RefreshAddonSetAddonListContainer()
    Addon:RefreshAddonDetailContainer()
    self:Hide()
end

function AddonSetChoiceDialogMixin:ReplaceAddonsToSelectedAddonSets()
    local addonList = {}
    local targetAddons = self:GetTargetAddons()
    for _, addonName in ipairs(self:GetTargetAddons()) do
        addonList[addonName] = true
    end

    self:GetDataProvider():ForEach(function(data)
        if data.Checked then
            Addon:SetAddonSetAddonList(data.AddonSet.Name, addonList)
        end
    end)

    Addon:RefreshAddonSetContainer()
    Addon:RefreshAddonSetAddonListContainer()
    Addon:RefreshAddonDetailContainer()
    self:Hide()
end

-- 显示插件集选择弹窗
function Addon:ShowAddonSetChoiceDialog(owner, choiceInfo)
    local UI = self:GetOrCreateUI()

    if UI.AddonSetChoiceDialog then
        UI.AddonSetChoiceDialog:SetupChoiceInfo(owner, choiceInfo)
        return
    end

    local AddonSetChoiceDialog = Mixin(CreateFrame("Frame", nil, UI, "TooltipBackdropTemplate"),
        AddonSetChoiceDialogMixin)
    UI.AddonSetChoiceDialog = AddonSetChoiceDialog

    AddonSetChoiceDialog:Init()
    AddonSetChoiceDialog:SetupChoiceInfo(owner, choiceInfo)
end
