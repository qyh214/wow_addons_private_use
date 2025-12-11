---@class AddonPrivate
local Private = select(2, ...)

---@class CollectionsTabUI
---@field contentFrame Frame
---@field tabSystem Frame|table
---@field contentTabs table<number, Frame>
---@field researchBar ProgressBarComponentObject
local collectionsTabUI = {
    contentFrame = nil,
    tabSystem = nil,
    contentTabs = {},
    researchBar = nil,
    ---@type table<any, string>
    L = nil,
}
Private.CollectionsTabUI = collectionsTabUI

local const = Private.constants
local components = Private.Components

function collectionsTabUI:Init()
    local addon = Private.Addon
    self.L = Private.L

    if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
        self:SetupTab()
    else
        addon:RegisterEvent("ADDON_LOADED", "collectionsTabUI_AddonLoaded", function(_, _, loadedAddonName)
            if loadedAddonName == "Blizzard_Collections" then
                addon:UnregisterEventCallback("ADDON_LOADED", "collectionsTabUI_AddonLoaded")
                self:SetupTab()
            end
        end)
    end
end

function collectionsTabUI:SetupTab()
    local addon = Private.Addon

    local collectionsTab = CreateFrame("Button", "CollectionsJournalTab7", CollectionsJournal, "CollectionsJournalTab")
    collectionsTab:SetID(const.COLLECTIONS_TAB.TAB_ID)
    collectionsTab:SetText(self.L["CollectionsTabUI.TabTitle"])
    collectionsTab:SetPoint("LEFT", CollectionsJournal.WarbandScenesTab, "RIGHT", 5, 0)
    PanelTemplates_TabResize(collectionsTab)

    function collectionsTab:GetTextYOffset(isSelected)
        return isSelected and -3 or 2
    end

    function collectionsTab:SetTabSelected(isSelected)
        if isSelected then
            PanelTemplates_SelectTab(collectionsTab)
        else
            PanelTemplates_DeselectTab(collectionsTab)
        end
    end

    local content = CreateFrame("Frame", nil, CollectionsJournal, "CollectionsBackgroundTemplate")
    self.contentFrame = content

    local function onTabUpdate(tabID)
        local isSelected = tabID == collectionsTab:GetID()
        collectionsTab:SetTabSelected(isSelected)
        content:SetShown(isSelected)

        if isSelected then
            RunNextFrame(function()
                CollectionsJournal:SetTitle(self.L["CollectionsTabUI.TabTitle"])
                CollectionsJournal:SetPortraitToAsset(const.COLLECTIONS_TAB.TAB_ICON)
            end)
        end
    end

    hooksecurefunc("CollectionsJournal_SetTab", function(_, tabID)
        onTabUpdate(tabID)
    end)
    onTabUpdate(PanelTemplates_GetSelectedTab(CollectionsJournal))

    local tabSys = CreateFrame("Frame", nil, content, "TabSystemTemplate")
    self.tabSystem = tabSys
    tabSys:SetPoint("TOPLEFT", 50, 30)

    tabSys:SetTabSelectedCallback(function(tabID)
        for id, tabContent in pairs(self.contentTabs) do
            tabContent:SetShown(id == tabID)
        end

        addon:SetDatabaseValue("collectionsTab.selected", tabID)
        return false
    end)

    self:SetupTraitsTab()

    local selectedID = addon:GetDatabaseValue("collectionsTab.selected") or 1
    if not self.contentTabs[selectedID] then
        selectedID = 1
    end
    tabSys:SetTab(selectedID)

    --- MOVE THIS PART TO A NEW COMPONENT!!!
    --- This is a very sloppy and quick way to fix this for now
    --- Will refactor later
    local proxyFrame = CreateFrame("Frame", nil, content)
    proxyFrame:SetAllPoints()
    local quickActionBar = CreateFrame("Button", nil, proxyFrame)
    quickActionBar:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, 30)
    quickActionBar:SetSize(25, 25)
    quickActionBar:SetHighlightAtlas("RedButton-Highlight", "ADD")
    local function updateQuickActionBarState()
        if Private.QuickActionBarUI:IsVisible() then
            quickActionBar:SetNormalAtlas("RedButton-Condense")
            quickActionBar:SetPushedAtlas("RedButton-Condense-Pressed")
            quickActionBar:SetDisabledAtlas("RedButton-Condense-Disabled")
        else
            quickActionBar:SetNormalAtlas("RedButton-Expand")
            quickActionBar:SetPushedAtlas("RedButton-Expand-Pressed")
            quickActionBar:SetDisabledAtlas("RedButton-Expand-Disabled")
        end
    end
    Private.QuickActionBarUI:Init(content)
    quickActionBar:SetScript("OnClick", function()
        Private.QuickActionBarUI:Toggle()
        updateQuickActionBarState()
    end)
    updateQuickActionBarState()

    local researchBar = components.ProgressBar:CreateFrame(content, {
        anchors = {
            { "TOPRIGHT", quickActionBar, "TOPLEFT", -10, -5 }
        },
        tooltipTextGetter = function()
            return Private.ResearchTaskUtils:GetCurrentTooltipText()
        end,
    })
    self.researchBar = researchBar
    local callbackObj = Private.ResearchTaskUtils:AddCallback(function(progress, total)
        researchBar:SetMinMaxValues(0, total or 1)
        researchBar:SetValue(progress or 0)
        researchBar:SetLabelText(string.format(self.L["CollectionsTabUI.ResearchProgress"], progress or "?", total or "?"))
    end)
    if callbackObj then
        callbackObj:Trigger(Private.ResearchTaskUtils:GetTaskProgress())
    end
end

function collectionsTabUI:SetupTraitsTab()
    if const.IS_REMIX_VERSION then
        local artifactTraitsContent = self:AddTopTab(self.L["CollectionsTabUI.TraitsTabTitle"])
        local traitsUI = Private.ArtifactTraitsTabUI
        traitsUI:Init(artifactTraitsContent)
    end

    local collectionContent = self:AddTopTab(self.L["CollectionsTabUI.CollectionTabTitle"])
    local collectionUI = Private.CollectionTabUI
    collectionUI:Init(collectionContent)
end

---@return Frame contentFrame
function collectionsTabUI:GetContentFrame()
    return self.contentFrame
end

---@param name string
---@return Frame tabContent
---@return number tabID
function collectionsTabUI:AddTopTab(name)
    local tabSystem = self.tabSystem

    local tabID = tabSystem:AddTab(name)
    local tabButton = tabSystem:GetTabButton(tabID)
    tabButton.isTabOnTop = true
    tabButton:Init(tabID, name)

    local tabContent = CreateFrame("Frame", nil, self:GetContentFrame())
    tabContent:SetAllPoints()
    tabContent:Hide()

    self.contentTabs[tabID] = tabContent

    return tabContent, tabID
end
