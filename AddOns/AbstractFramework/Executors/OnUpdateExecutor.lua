---@class AbstractFramework
local AF = _G.AbstractFramework

local hooksecurefunc = hooksecurefunc

local STATUS_IDLE = "idle"
local STATUS_READY = "ready"
local STATUS_PROCESSING = "processing"

---@class AF_OnUpdateExecutor
local AF_OnUpdateExecutorMixin = {}

-- insert tasks to the queue and start processing
function AF_OnUpdateExecutorMixin:Submit(tasks)
    self:Hide() -- pause
    for _, task in ipairs(tasks) do
        self.queue:push(task)
    end
    self.totalTasks = self.queue:size()
    self:Show()
end

-- will pause the executor, manually call Execute() to resume
function AF_OnUpdateExecutorMixin:AddTask(task)
    self:Hide()
    self.queue:push(task)
    self.totalTasks = self.queue:size()
end

function AF_OnUpdateExecutorMixin:Execute()
    self.totalTasks = self.queue:size()
    self:Show()
end

-- function AF_OnUpdateExecutorMixin:RunImmediately(task)
--     self:Clear()
--     for _, t in ipairs(task) do
--         self:Run(t, 0, 0)
--     end
-- end

function AF_OnUpdateExecutorMixin:Clear()
    self:Hide()
    if self.totalTasks ~= 0 then
        self.totalTasks = 0
        self.queue:clear()
    end
end

---@private
function AF_OnUpdateExecutorMixin:OnUpdate()
    if self.status == STATUS_READY then
        self.status = STATUS_PROCESSING
        local task = self.queue:pop()
        if task then
            self:Run(task, self.queue:size(), self.totalTasks)
        else
            self:Hide()
            -- all tasks finished
            if self.Finish then
                self:Finish()
            end
        end
    end
end

---@private
function AF_OnUpdateExecutorMixin:OnEachTaskFinish()
    self.status = STATUS_READY
end

---@private
function AF_OnUpdateExecutorMixin:OnShow()
    self.status = STATUS_READY
end

---@private
function AF_OnUpdateExecutorMixin:OnHide()
    if self.status == STATUS_READY and self.queue:size() == 0 then
        -- all tasks are finished
        self.totalTasks = 0
        self.queue:clear() -- reset index
    end
    self.status = STATUS_IDLE
end

-- NOTE: This executor is only suitable for non-asynchronous tasks
---@param taskHandler fun(executor: AF_OnUpdateExecutor, task: any, numRemainingTasks: number, numTotalTasks: number)
---@param onFinish? fun(executor: AF_OnUpdateExecutor)
---@return AF_OnUpdateExecutor executor
function AF.BuildOnUpdateExecutor(taskHandler, onFinish)
    local executor = CreateFrame("Frame")
    executor:Hide()

    Mixin(executor, AF_OnUpdateExecutorMixin)

    executor.totalTasks = 0
    executor.status = STATUS_IDLE
    executor.queue = AF.NewQueue()

    executor.Run = taskHandler
    hooksecurefunc(executor, "Run", executor.OnEachTaskFinish)
    executor.Finish = onFinish

    executor:SetScript("OnUpdate", executor.OnUpdate)
    executor:SetScript("OnShow", executor.OnShow)
    executor:SetScript("OnHide", executor.OnHide)

    return executor
end
