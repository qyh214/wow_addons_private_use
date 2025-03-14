-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string

ItemUpgradeTipDisplayMixin = {}

function ItemUpgradeTipDisplayMixin:OnLoad()
    self:RegisterForDrag("LeftButton")

    PanelTemplates_SetNumTabs(self, #self.Tabs)
    table.insert(UISpecialFrames, self:GetName())

    local lastTab = nil
    for _, tab in ipairs(self.Tabs) do
        tab:ClearAllPoints()
        if lastTab == nil then
            tab:SetPoint("BOTTOMLEFT", 20, -30)
        else
            tab:SetPoint("LEFT", lastTab, "RIGHT", 0, 0)
        end
        lastTab = tab

        ItemUpgradeTip:AddSkinnableFrame("TabButton", tab, {tabs = self.Tabs})
    end
end

function ItemUpgradeTipDisplayMixin:OnShow()
    local visibleDisplayModes = {}
    local visibleTab
    for _, tab in ipairs(self.Tabs) do
        if tab:IsShown() then
            table.insert(visibleDisplayModes, tab.displayMode)
            if visibleTab == nil then
                visibleTab = tab
            end
        end
    end

    self:SetDisplayMode("MythicPlus")
end

function ItemUpgradeTipDisplayMixin:OnHide()
end

function ItemUpgradeTipDisplayMixin:GetBreadcrumb()
	return self.TitleContainer.Breadcrumb;
end

function ItemUpgradeTipDisplayMixin:SetDisplayMode(displayMode)
    for index, tab in ipairs(self.Tabs) do
        if tab.displayMode == displayMode then
            PanelTemplates_SetTab(self, index)
            self:SetTitle(AddOnFolderName)

            local titleText = self:GetTitleText();
            local breadcrumb = self:GetBreadcrumb();
            local prefix = not C_AddOns.IsAddOnLoaded("ItemUpgradeTip-GW2UI") and " - " or "     ";

            breadcrumb:SetText(prefix .. tab.title)
            breadcrumb:ClearAllPoints()
            breadcrumb:SetPoint("RIGHT", titleText, "RIGHT", breadcrumb:GetStringWidth(), 0)
            break
        end
    end

    for _, view in ipairs(self.Views) do
        view:SetShown(view.displayMode == displayMode)
    end
end
