---@diagnostic disable: duplicate-set-field
ItemUpgradeTipTableResultsRowMixin = CreateFromMixins(ItemUpgradeTipResultsRowTemplateMixin)

function ItemUpgradeTipTableResultsRowMixin:Populate(rowData, ...)
    ItemUpgradeTipResultsRowTemplateMixin.Populate(self, rowData, ...)
    self.SelectedHighlight:SetShown(rowData.selected)
end

function ItemUpgradeTipTableResultsRowMixin:OnEnter()
    ItemUpgradeTipResultsRowTemplateMixin.OnEnter(self)

    if self.rowData.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        if string.match(self.rowData.itemLink, "battlepet") then
            BattlePetToolTip_ShowLink(self.rowData.itemLink)
        else
            GameTooltip:SetHyperlink(self.rowData.itemLink)
            GameTooltip:Show()
        end
    end
end

function ItemUpgradeTipTableResultsRowMixin:OnLeave()
    ItemUpgradeTipResultsRowTemplateMixin.OnLeave(self)

    if self.rowData.itemLink and string.match(self.rowData.itemLink, "battlepet") then
        BattlePetTooltip:Hide()
    elseif self.rowData.itemLink then
        GameTooltip:Hide()
    end
end

function ItemUpgradeTipTableResultsRowMixin:OnClick(button)
    if button == "LeftButton" then
        if IsModifiedClick("CHATLINK") then
            if self.rowData.itemLink ~= nil then
                ChatEdit_InsertLink(self.rowData.itemLink)
            end
        end
    end
end
