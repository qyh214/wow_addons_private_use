ItemUpgradeTipResultsListingMixin = {}

function ItemUpgradeTipResultsListingMixin:Init(dataProvider)
    self.isInitialized = false
    self.dataProvider = dataProvider
    self.columnSpecification = self.dataProvider:GetTableLayout()

    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(20)
    view:SetElementInitializer(dataProvider:GetRowTemplate(), function(frame, index)
        frame:Populate(self.dataProvider:GetEntryAt(index), index)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollArea.ScrollBox, self.ScrollArea.ScrollBar, view)

    -- Create an instance of table builder - note that the ScrollFrame we reference
    -- mixes a TableBuilder implementation in
    self.tableBuilder = CreateTableBuilder()
    -- Set the frame that will be used for header columns for this tableBuilder
    self.tableBuilder:SetHeaderContainer(self.HeaderContainer)

    self:InitializeTable()
    self:InitializeDataProvider()
end

function ItemUpgradeTipResultsListingMixin:InitializeDataProvider()
    self.dataProvider:SetOnUpdateCallback(function()
        self:UpdateTable()
    end)

    self.dataProvider:SetOnPreserveScrollCallback(function()
        self.savedScrollPosition = self.ScrollArea.ScrollBox:GetScrollPercentage()
    end)

    self.dataProvider:SetOnResetScrollCallback(function()
        self.savedScrollPosition = nil
    end)
end

function ItemUpgradeTipResultsListingMixin:RestoreScrollPosition()
    if self.savedScrollPosition ~= nil then
        self:UpdateTable()
        self.ScrollArea.ScrollBox:SetScrollPercentage(self.savedScrollPosition)
    end
end

function ItemUpgradeTipResultsListingMixin:OnLoad()
    ItemUpgradeTip:AddSkinnableFrame("NavBar", self)
    ItemUpgradeTip:AddSkinnableFrame("ScrollArea", self.ScrollArea)
end

function ItemUpgradeTipResultsListingMixin:OnShow()
    if not self.isInitialized then
        return
    end

    self.tableBuilder:Arrange()
    self:UpdateTable()
end

function ItemUpgradeTipResultsListingMixin:InitializeTable()
    self.tableBuilder:Reset()
    self.tableBuilder:SetTableMargins(15)
    self.tableBuilder:SetDataProvider(function(index)
        return self.dataProvider:GetEntryAt(index)
    end)

    ScrollUtil.RegisterTableBuilder(self.ScrollArea.ScrollBox, self.tableBuilder, function(a) return a end)

    for _, columnEntry in ipairs(self.columnSpecification) do
        local column = self.tableBuilder:AddColumn()
        column:ConstructHeader(
            "BUTTON",
            columnEntry.headerTemplate,
            columnEntry.headerText,
            nil,
            nil,
            nil,
            unpack((columnEntry.headerParameters or {}))
        )
        column:SetCellPadding(-5, 5)
        column:ConstructCells("FRAME", columnEntry.cellTemplate, unpack((columnEntry.cellParameters or {})))

        if columnEntry.width ~= nil then
            column:SetFixedConstraints(columnEntry.width, 0)
        else
            column:SetFillConstraints(1.0, 0)
        end
    end
    self.isInitialized = true
    self.tableBuilder:Arrange()
end

function ItemUpgradeTipResultsListingMixin:UpdateTable()
    if not self.isInitialized then
        return
    end

    local tmpDataProvider = CreateIndexRangeDataProvider(self.dataProvider:GetCount())

    local shouldPreserveScroll = self.savedScrollPosition ~= nil

    self.ScrollArea.ScrollBox:SetDataProvider(tmpDataProvider, shouldPreserveScroll)
end

function ItemUpgradeTipResultsListingMixin:EnableSpinner()
    self.ScrollArea.ResultsText:Show()
    self.ScrollArea.LoadingSpinner:Show()
    self.ScrollArea.SpinnerAnim:Play()
end

function ItemUpgradeTipResultsListingMixin:DisableSpinner()
    self.ScrollArea.ResultsText:Hide()
    self.ScrollArea.LoadingSpinner:Hide()
    self.ScrollArea.SpinnerAnim:Stop()
end
