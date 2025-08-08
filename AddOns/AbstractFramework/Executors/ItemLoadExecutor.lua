---@class AbstractFramework
local AF = _G.AbstractFramework

local DEFAULT_TIMEOUT = 1

---@class AF_ItemLoadExecutor
local AF_ItemLoadExecutorMixin = {}

---@param items number[] list of item IDs to load
---@param arg any argument to pass to the item handler
function AF_ItemLoadExecutorMixin:Submit(items, arg)
    -- push items and arg as a whole into the queue
    self.queue:push({items = items, arg = arg})
    self:ProcessNextBatch()
end

-- function AF_ItemLoadExecutorMixin:Clear()
--     self:StopTimeout()
--     if self.currentCancelFunc then
--         self.currentCancelFunc()
--         self.currentCancelFunc = nil
--     end

--     self.queue:clear()
--     self.currentItems = nil
--     self.currentArg = nil
--     self.currentItemID = nil
--     self.currentIndex = nil
--     self.processedCount = 0
--     self.totalItems = 0
-- end

---@private
function AF_ItemLoadExecutorMixin:ProcessNextBatch()
    -- if there is no current batch being processed, try to get a new batch from the queue
    if not self.currentItems then
        local batch = self.queue:pop()
        if batch then
            -- print("NEXT BATCH")
            self.currentItems = batch.items
            self.currentArg = batch.arg
            self.processedCount = 0
            self.totalItems = #batch.items

            -- current batch started
            if self.GroupStart then
                self:GroupStart(self.currentArg)
            end

            self:ProcessNextItem()

        else
            -- print("ALL FINISH")
            -- all batches finished, reset
            self:StopTimeout()
            self.currentItems = nil
            self.currentArg = nil
            self.currentItemID = nil
            self.currentIndex = nil
            self.processedCount = 0
            self.totalItems = 0

            if self.AllFinish then
                self:AllFinish()
            end
        end
    end
end

---@private
function AF_ItemLoadExecutorMixin:OnItemLoaded()
    self:StopTimeout()
    self.currentCancelFunc = nil

    self:Run(self.itemMixinInstance, self.currentItemID, self.currentIndex, self.totalItems, self.currentArg)

    self.processedCount = self.currentIndex
    self:ProcessNextItem()
end

---@private
function AF_ItemLoadExecutorMixin:OnItemLoadFailed()
    self:StopTimeout()

    if self.currentCancelFunc then
        self.currentCancelFunc()
        self.currentCancelFunc = nil
    end

    -- print("item load failed:", self.currentItemID)
    self:Run(nil, self.currentItemID, self.currentIndex, self.totalItems, self.currentArg)

    self.processedCount = self.currentIndex
    self.currentItemID = nil
    self.currentIndex = nil

    self:ProcessNextItem()
end

---@private
function AF_ItemLoadExecutorMixin:ProcessNextItem()
    -- stop timeout monitoring
    self:StopTimeout()
    if self.currentCancelFunc then
        self.currentCancelFunc()
        self.currentCancelFunc = nil
    end

    if not self.currentItems or self.processedCount >= self.totalItems then
        -- current batch finished
        -- print("BATCH FINISH", self.currentArg, self.processedCount, self.totalItems)
        if self.GroupFinish then
            self:GroupFinish(self.currentArg)
        end

        -- reset current batch state
        self.currentItems = nil
        self.currentArg = nil

        -- process the next batch
        self:ProcessNextBatch()
        return
    end

    -- process next in current batch
    self.currentIndex = self.processedCount + 1
    self.currentItemID = self.currentItems[self.currentIndex]

    -- start timeout monitoring
    self:StartTimeout()

    self.itemMixinInstance:SetItemID(self.currentItemID)
    self.currentCancelFunc = self.itemMixinInstance:ContinueWithCancelOnItemLoad(self.onItemLoadedCallback)
end

---@private
function AF_ItemLoadExecutorMixin:StartTimeout()
    self.timeoutStartTime = GetTime()
    self:Show()
end

---@private
function AF_ItemLoadExecutorMixin:StopTimeout()
    self:Hide()
    self.timeoutStartTime = nil
end

---@private
function AF_ItemLoadExecutorMixin:OnUpdate()
    if self.timeoutStartTime and GetTime() - self.timeoutStartTime >= DEFAULT_TIMEOUT then
        self:OnItemLoadFailed()
    end
end

-- executor for asynchronous item info loading
-- if item load failed, will send a nil itemMixin to the handler
---@param itemHandler fun(executor: AF_ItemLoadExecutor, itemMixin: ItemMixin|nil, batchItemID: number, batchItemIndex: number, batchSize: number, arg: any)
---@param onEachGroupStart? fun(executor: AF_ItemLoadExecutor, arg: any)
---@param onEachGroupFinish? fun(executor: AF_ItemLoadExecutor, arg: any)
---@param onAllFinish? fun(executor: AF_ItemLoadExecutor)
---@return AF_ItemLoadExecutor executor
function AF.BuildItemLoadExecutor(itemHandler, onEachGroupStart, onEachGroupFinish, onAllFinish)
    local executor = CreateFrame("Frame")
    executor:Hide()

    Mixin(executor, AF_ItemLoadExecutorMixin)

    executor.queue = AF.NewQueue()
    executor.processedCount = 0
    executor.totalItems = 0

    executor.itemMixinInstance = Item:CreateFromItemID(0)
    executor.onItemLoadedCallback = function()
        executor:OnItemLoaded()
    end

    executor.Run = itemHandler
    executor.GroupStart = onEachGroupStart
    executor.GroupFinish = onEachGroupFinish
    executor.AllFinish = onAllFinish

    executor:SetScript("OnUpdate", executor.OnUpdate)

    return executor
end