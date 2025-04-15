---@class AbstractFramework
local AF = _G.AbstractFramework

local setmetatable, wipe = setmetatable, wipe

local QUEUE_THRESHOLD = 100000

---@class AF_FIFOQueue
local FIFOQueue = {}
FIFOQueue.__index = FIFOQueue

function FIFOQueue:new(threshold)
    local instance = {
        first = 1,
        last = 0,
        length = 0,
        threshold = threshold or QUEUE_THRESHOLD,
        queue = {},
    }
    setmetatable(instance, FIFOQueue)
    return instance
end

function FIFOQueue:size()
    return self.length
end

function FIFOQueue:push(value)
    self.length = self.length + 1
    self.last = self.last + 1
    self.queue[self.last] = value
end

function FIFOQueue:pop()
    if self.first > self.last then return end
    local value = self.queue[self.first]
    self.queue[self.first] = nil
    self.first = self.first + 1
    self.length = self.length - 1
    return value
end

function FIFOQueue:clear()
    self.first = 1
    self.last = 0
    self.length = 0
    wipe(self.queue)
end

function FIFOQueue:isEmpty()
    return self.first > self.last
end

function FIFOQueue:shrink()
    local newQueue = {}
    local newFirst = 1
    for i = self.first, self.last do
        newQueue[newFirst] = self.queue[i]
        newFirst = newFirst + 1
    end
    self.queue = newQueue
    self.first = 1
    self.last = newFirst - 1
end

function FIFOQueue:checkShrink()
    if self.first > self.threshold then
        FIFOQueue:shrink()
    end
end

---@param threshold number? determine when to shrink the queue, default is 100000
---@return AF_FIFOQueue
function AF.NewQueue(threshold)
    return FIFOQueue:new(threshold)
end