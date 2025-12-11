---@class AbstractFramework
local AF = _G.AbstractFramework

local hooksecurefunc = hooksecurefunc

local STATUS_IDLE = "idle"
local STATUS_READY = "ready"
local STATUS_PROCESSING = "processing"

---@class AF_OnUpdateExecutor
local AF_OnUpdateExecutorMixin = {}

-- insert tasks to the queue and start processing
---@param tasks table
---@param useKey? boolean if true, table keys will be used as task objects
function AF_OnUpdateExecutorMixin:Submit(tasks, useKey)
    self:Hide() -- pause
    if useKey then
        for k in next, tasks do
            self.queue:push(k)
        end
    else
        for _, v in next, tasks do
            self.queue:push(v)
        end
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

function AF_OnUpdateExecutorMixin:Pause()
    self:Hide()
end

-- resume processing tasks in the queue
function AF_OnUpdateExecutorMixin:Execute()
    self.totalTasks = self.queue:size()
    self:Show()
end

-- process all tasks in the queue immediately, bypassing the executor's frame-based
function AF_OnUpdateExecutorMixin:RunImmediately()
    local task = self.queue:pop()
    while task do
        self:Run(task, self.queue:size(), self.totalTasks)
        task = self.queue:pop()
    end
end

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

        local tasksExecuted = 0
        while tasksExecuted < self.tasksPerFrame and self.queue:size() > 0 do
            local task = self.queue:pop()
            if task then
                self:Run(task, self.queue:size(), self.totalTasks)
                tasksExecuted = tasksExecuted + 1
            else
                break
            end
        end

        if self.queue:size() == 0 then
            -- all tasks finished
            self:Hide()
            if self.Finish then
                self:Finish(self.totalTasks)
            end
        else
            -- still have tasks to process
            self.status = STATUS_READY
        end
    end
end

---@private
-- function AF_OnUpdateExecutorMixin:OnEachTaskFinish()
--     self.status = STATUS_READY
-- end

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
---@param onFinish? fun(executor: AF_OnUpdateExecutor, numTotalTasks: number) called when all tasks are finished
---@param tasksPerFrame? number tasks per frame, default is 1
---@return AF_OnUpdateExecutor executor
function AF.BuildOnUpdateExecutor(taskHandler, onFinish, tasksPerFrame)
    local executor = CreateFrame("Frame")
    executor:Hide()

    Mixin(executor, AF_OnUpdateExecutorMixin)

    executor.totalTasks = 0
    executor.tasksPerFrame = tasksPerFrame or 1
    executor.status = STATUS_IDLE
    executor.queue = AF.NewQueue()

    executor.Run = taskHandler
    executor.Finish = onFinish
    -- hooksecurefunc(executor, "Run", executor.OnEachTaskFinish)

    executor:SetScript("OnUpdate", executor.OnUpdate)
    executor:SetScript("OnShow", executor.OnShow)
    executor:SetScript("OnHide", executor.OnHide)

    return executor
end
