ItemUpgradeTipCellMixin = {}

function ItemUpgradeTipCellMixin:Populate(rowData, index)
    self.rowData = rowData
    self.index = index
end

function ItemUpgradeTipCellMixin:OnEnter()
    if self:GetParent().OnEnter ~= nil then
        self:GetParent():OnEnter()
    end
end

function ItemUpgradeTipCellMixin:OnLeave()
    if self:GetParent().OnLeave ~= nil then
        self:GetParent():OnLeave()
    end
end

function ItemUpgradeTipCellMixin:OnClick(...)
    if self:GetParent().OnClick ~= nil then
        self:GetParent():OnClick(...)
    end
end
