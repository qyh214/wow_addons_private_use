local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.AnalyticsTableSortOrder = EnumUtil.MakeEnum(
    "ItemName",
    "ProfessionName",
    "TotalSeen",
    "TotalSeenFiltered",
    "AveragePerDay",
    "PeakPerHour",
    "MedianPerCustomer",
    "MedianPerCustomerFiltered"
);

CraftScanAnalyticsTableConstants = {};
CraftScanAnalyticsTableConstants.StandardPadding = 10;
CraftScanAnalyticsTableConstants.NoPadding = 0;
CraftScanAnalyticsTableConstants.ItemName = {
    Width = 330,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.ProfessionName = {
    Width = 100,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
}
CraftScanAnalyticsTableConstants.TotalSeen = {
    Width = 60,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.TotalSeenFiltered = {
    Width = 60,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.AveragePerDay = {
    Width = 60,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.PeakPerHour = {
    Width = 70,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.MedianPerCustomer = {
    Width = 70,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};
CraftScanAnalyticsTableConstants.MedianPerCustomerFiltered = {
    Width = 100,
    Padding = CraftScanAnalyticsTableConstants.StandardPadding,
    LeftCellPadding = CraftScanAnalyticsTableConstants.NoPadding,
    RightCellPadding = CraftScanAnalyticsTableConstants.NoPadding
};

local function TooltipText(sortOrder)
    if sortOrder == CraftScan.AnalyticsTableSortOrder.ItemName then
        return L(LID.ANALYTICS_ITEM_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.ProfessionName then
        return L(LID.ANALYTICS_PROFESSION_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeen then
        return L(LID.ANALYTICS_TOTAL_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeenFiltered then
        return L(LID.ANALYTICS_REPEAT_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.AveragePerDay then
        return L(LID.ANALYTICS_AVERAGE_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.PeakPerHour then
        return L(LID.ANALYTICS_PEAK_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomer then
        return L(LID.ANALYTICS_MEDIAN_TOOLTIP)
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomerFiltered then
        return L(LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED)
    end
end

local function HeaderName(sortOrder)
    if sortOrder == CraftScan.AnalyticsTableSortOrder.ItemName then
        return PROFESSIONS_COLUMN_HEADER_ITEM;
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.ProfessionName then
        return L("Profession");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeen then
        return L("Total");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.TotalSeenFiltered then
        return L("Repeat");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.AveragePerDay then
        return L("Avg Per Day");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.PeakPerHour then
        return L("Peak Per Hour");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomer then
        return L("Median Per Customer");
    elseif sortOrder == CraftScan.AnalyticsTableSortOrder.MedianPerCustomerFiltered then
        return L("Median Per Customer Filtered");
    end
end

CraftScanAnalyticsTableHeaderStringMixin = CreateFromMixins(CraftScanCrafterTableHeaderStringMixin);

function CraftScanAnalyticsTableHeaderStringMixin:OnEnter()
    local text = TooltipText(self.sortOrder);
    if text == nil then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    GameTooltip_SetTitle(GameTooltip, HeaderName(self.sortOrder));
    GameTooltip_AddBlankLineToTooltip(GameTooltip);
    GameTooltip:AddLine(text, 1, 1, 1, true);
    GameTooltip:Show();
end

function CraftScanAnalyticsTableHeaderStringMixin:OnLeave()
    GameTooltip:Hide();
end

CraftScanAnalyticsTableBuilderMixin = CreateFromMixins(CraftScanTableBuilderMixin,
    { header_template = "CraftScanAnalyticsTableHeaderStringTemplate" });

function CraftScanAnalyticsTableBuilderMixin:GetHeaderNameFromSortOrder(sortOrder)
    return HeaderName(sortOrder);
end

CraftScanAnalyticsCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsCellItemNameMixin:Populate(rowData)
    local itemInfo = rowData.item;

    -- The item is already loaded because we loaded it to generate this table row's source data.
    local item = Item:CreateFromItemID(itemInfo.itemID);
    local icon = item:GetItemIcon();
    self.Icon:SetTexture(icon);

    local qualityColor = item:GetItemQualityColor().color;
    local itemName = qualityColor:WrapTextInColorCode(item:GetItemName());
    self.Text:SetText(itemName);
end

CraftScanAnalyticsTableCellProfessionNameMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellProfessionNameMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.profession);
end

CraftScanAnalyticsTableCellTotalSeenMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellTotalSeenMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.totalSeen);
end

CraftScanAnalyticsTableCellTotalSeenFilteredMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellTotalSeenFilteredMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.totalSeenFiltered);
end

CraftScanAnalyticsTableCellAveragePerDayMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellAveragePerDayMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(string.format("%.2f", itemInfo.averagePerDay));
end

CraftScanAnalyticsTableCellPeakPerHourMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellPeakPerHourMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.peakPerHour);
end

CraftScanAnalyticsTableCellMedianPerCustomerMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellMedianPerCustomerMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.medianPerCustomer);
end

CraftScanAnalyticsTableCellMedianPerCustomerFilteredMixin = CreateFromMixins(TableBuilderCellMixin);

function CraftScanAnalyticsTableCellMedianPerCustomerFilteredMixin:Populate(rowData)
    local itemInfo = rowData.item;
    self.Text:SetText(itemInfo.medianPerCustomerFiltered);
end
