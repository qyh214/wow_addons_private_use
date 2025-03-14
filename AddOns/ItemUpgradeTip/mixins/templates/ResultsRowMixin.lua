ItemUpgradeTipResultsRowTemplateMixin = {}

function ItemUpgradeTipResultsRowTemplateMixin:OnClick(...)
end

function ItemUpgradeTipResultsRowTemplateMixin:OnEnter(...)
    self.HighlightTexture:Show()
end

function ItemUpgradeTipResultsRowTemplateMixin:OnLeave(...)
    self.HighlightTexture:Hide()
end

function ItemUpgradeTipResultsRowTemplateMixin:Populate(rowData, dataIndex)
    self.rowData = rowData
    self.dataIndex = dataIndex
end
