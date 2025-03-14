---@diagnostic disable: duplicate-set-field
ItemUpgradeTipStringCellTemplateMixin = CreateFromMixins(ItemUpgradeTipCellMixin, TableBuilderCellMixin)

function ItemUpgradeTipStringCellTemplateMixin:Init(columnName)
    self.columnName = columnName

    self.text:SetJustifyH("LEFT")
end

function ItemUpgradeTipStringCellTemplateMixin:Populate(rowData, index)
    ItemUpgradeTipCellMixin.Populate(self, rowData, index)

    self.text:SetText(rowData[self.columnName])
end

function ItemUpgradeTipStringCellTemplateMixin:ShowTooltip()
    if not self.rowData[self.columnName .. "ItemLink"] and not self.rowData[self.columnName .. "CurrencyId"] and not self.rowData[self.columnName .. "ItemId"] then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    self.UpdateTooltip = self.OnEnter

    if self.rowData[self.columnName .. "ItemLink"] then
        GameTooltip:SetHyperlink(self.rowData[self.columnName .. "ItemLink"])
    elseif self.rowData[self.columnName .. "CurrencyId"] then
        GameTooltip:SetCurrencyByID(self.rowData[self.columnName .. "CurrencyId"])
    elseif self.rowData[self.columnName .. "ItemId"] then
        GameTooltip:SetItemByID(self.rowData[self.columnName .. "ItemId"])
    end

    GameTooltip:Show()
end

-- Used to prevent tooltip triggering too late and interfering with another
-- tooltip
function ItemUpgradeTipStringCellTemplateMixin:CancelContinuable()
    if self.continuableContainer then
        self.continuableContainer:Cancel()
        self.continuableContainer = nil
    end
end

function ItemUpgradeTipStringCellTemplateMixin:OnHide()
    self.text:Hide()
    self:CancelContinuable()
end

function ItemUpgradeTipStringCellTemplateMixin:OnShow()
    self.text:Show()
end

function ItemUpgradeTipStringCellTemplateMixin:OnEnter()
    ItemUpgradeTipCellMixin.OnEnter(self)

    self:CancelContinuable()

    self:ShowTooltip()
end

function ItemUpgradeTipStringCellTemplateMixin:OnLeave()
    ItemUpgradeTipCellMixin.OnLeave(self)

    self.UpdateTooltip = nil
    self:CancelContinuable()
    GameTooltip:Hide()
end
