ItemUpgradeTipDataProviderMixin = {}

function ItemUpgradeTipDataProviderMixin:OnLoad()
    self.results = {}
    self.cachedResults = {}
    self.insertedKeys = {}
    self.entriesToProcess = {}
    self.processCountPerUpdate = 200

    self.onEntryProcessed = function(_)
        self:NotifyCacheUsed()
    end
    self.onUpdate = function(_) end
    self.onSearchStarted = function() end
    self.onSearchEnded = function() end
    self.onPreserveScroll = function() end
    self.onResetScroll = function() end
end

function ItemUpgradeTipDataProviderMixin:OnUpdate(elapsed)
    if elapsed >= 0 then
        self:CheckForEntriesToProcess()
    end
end

function ItemUpgradeTipDataProviderMixin:Reset()
     -- Last set of results passed to self.onUpdate. Used to avoid errors with out
     -- of range indexes if :GetEntry is called before the OnUpdate fires.
    self.cachedResults = self.cachedResults or self.results or {}

    self.results = {}
    self.insertedKeys = {}
    self.entriesToProcess = {}
    self.processingIndex = 0

    self:SetDirty()
end


-- Derive: This defines the Results Listing table layout
-- The table layout should be an array of table layout column entries consisting of:
--     1. REQUIRED headerTemplate - String
--            The name of the frame template that should be used for the column header
--     2. OPTIONAL headerParameters - Array<Any>
--            An array of any elements that we want to pass to the column header; these will
--            be supplied to the column header's Init method
--     3. REQUIRED headerText - String
--            The text that should be displayed in the column header
--     4. REQUIRED cellTemplate - String
--            The name of the frame template that should be used for cells in this column
--     5. OPTIONAL cellParameters - Array<Any>
--            An array of any elements that we want to pass to the cell; these will be
--            supplied to the cell's Init method
--     6. OPTIONAL width - Integer
--            If supplied, this will be used to define the column's fixed width.
--            If omitted, the column will use ColumnWidthConstraints.Fill from TableBuilder
function ItemUpgradeTipDataProviderMixin:GetTableLayout()
    return {}
end

function ItemUpgradeTipDataProviderMixin:GetRowTemplate()
    return "ItemUpgradeTipResultsRowTemplate"
end

function ItemUpgradeTipDataProviderMixin:GetEntryAt(index)
    return self.cachedResults[index]
end

function ItemUpgradeTipDataProviderMixin:GetCount()
    return #self.cachedResults
end

function ItemUpgradeTipDataProviderMixin:SetOnEntryProcessedCallback(onEntryProcessedCallback)
    self.onEntryProcessed = onEntryProcessedCallback
end

function ItemUpgradeTipDataProviderMixin:SetOnUpdateCallback(onUpdateCallback)
    self.onUpdate = onUpdateCallback
end

function ItemUpgradeTipDataProviderMixin:NotifyCacheUsed()
    self.cacheUsedCount = self.cacheUsedCount + 1
end

function ItemUpgradeTipDataProviderMixin:SetDirty()
    self.isDirty = true
end

function ItemUpgradeTipDataProviderMixin:SetOnPreserveScrollCallback(onPreserveScrollCallback)
    self.onPreserveScroll = onPreserveScrollCallback
end

function ItemUpgradeTipDataProviderMixin:SetOnResetScrollCallback(onResetScrollCallback)
    self.onResetScroll = onResetScrollCallback
end

function ItemUpgradeTipDataProviderMixin:AppendEntries(entries)
    for _, entry in ipairs(entries) do
        table.insert(self.entriesToProcess, entry)
    end
end

-- We process a limited number of entries every frame to avoid freezing the client.
function ItemUpgradeTipDataProviderMixin:CheckForEntriesToProcess()
    if #self.entriesToProcess == 0 then
        if self.isDirty then
            self.cachedResults = self.results
            self.onUpdate(self.results)
            self.isDirty = false
        end
        return
    end

    local processCount = 0
    local entry
    local key

    self.cacheUsedCount = 0

    while processCount < self.processCountPerUpdate + self.cacheUsedCount and self.processingIndex < #self.entriesToProcess do
        self.processingIndex = self.processingIndex + 1
        entry = self.entriesToProcess[self.processingIndex]

        key = self:UniqueKey(entry)
        if self.insertedKeys[key] == nil then
            processCount = processCount + 1
            self.insertedKeys[key] = entry
            table.insert(self.results, entry)

            self.onEntryProcessed(entry)
        end
    end

    local resetQueue = false
    if self.processingIndex == #self.entriesToProcess then
        self.entriesToProcess = {}
        self.processingIndex = 0
        resetQueue = true
    end

    self.cachedResults = self.results
    self.onUpdate(self.results)
    self.isDirty = false

end
