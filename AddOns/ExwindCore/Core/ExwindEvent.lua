-- =============================================================
-- [[ ExwindTools 核心组件：事件分发与事件频率监听 ]]
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

--=======================================================================
--========================== 事件分发系统 =================================
--=======================================================================
ExwindTools.EventHandlers = {}
ExwindTools.CoreEventFrame = CreateFrame("Frame")

--- 注册游戏事件 (支持原生事件和虚拟事件)
function ExwindTools:RegisterEvent(event, owner, func)
    if type(event) ~= "string" then error("RegisterEvent: event must be string", 2) end
    if owner == nil then error("RegisterEvent: owner cannot be nil", 2) end
    if type(func) ~= "function" then error("RegisterEvent: func must be function", 2) end

    if not self.EventHandlers[event] then
        self.EventHandlers[event] = {}
        -- 尝试注册原生事件，虚拟事件会静默失败
        pcall(self.CoreEventFrame.RegisterEvent, self.CoreEventFrame, event)
    end
    self.EventHandlers[event][owner] = func
end

--- 注销游戏事件 (支持原生事件和虚拟事件)
function ExwindTools:UnregisterEvent(event, owner)
    if self.EventHandlers[event] then
        self.EventHandlers[event][owner] = nil
        local count = 0
        for _ in pairs(self.EventHandlers[event]) do count = count + 1 end
        if count == 0 then
            pcall(self.CoreEventFrame.UnregisterEvent, self.CoreEventFrame, event)
            self.EventHandlers[event] = nil
        end
    end
end

--- 发送虚拟事件
--- @param event string 事件名称
--- @param ... any 事件参数
function ExwindTools:SendEvent(event, ...)
    local handlers = self.EventHandlers[event]
    if not handlers then return end

    for owner, func in pairs(handlers) do
        local ok, err = pcall(func, event, ...)
        if not ok then
            self:LogError(string.format("SendEvent[%s][%s]", event, owner), err)
            print(string.format("|cffff0000[ExwindTools] SendEvent 错误 [%s][%s]: %s|r", event, owner, tostring(err)))
        end
    end
end

-- 事件分发核心
ExwindTools.CoreEventFrame:SetScript("OnEvent", function(_, event, ...)
    local handlers = ExwindTools.EventHandlers[event]
    if handlers then
        for owner, func in pairs(handlers) do
            local ok, err = pcall(func, event, ...)
            if not ok then
                ExwindTools:LogError(string.format("Event[%s][%s]", event, owner), err)
                print(string.format("|cffff0000[ExwindTools] 事件错误 [%s][%s]: %s|r", event, owner, tostring(err)))
            end
        end
    end
end)

--=======================================================================
--========================== 事件频率监听 (WatchEven) ====================
--=======================================================================
ExwindTools.WatchEvenRegistry = {}
ExwindTools.WatchEvenOwner = "__ExwindTools_WatchEven_Dispatcher"

local function NormalizeWatchEvenArgs(a, b, c, d, e, f, g)
    -- 兼容两种调用风格：
    -- 1) ExwindTools.WatchEven("EVENT", "模块", 3, 4, 1.0, callback)
    -- 2) ExwindTools:WatchEven("EVENT", "模块", 3, 4, 1.0, callback)
    if a == ExwindTools then
        return b, c, d, e, f, g
    end
    return a, b, c, d, e, f
end

local function NormalizeUnwatchEvenArgs(a, b, c)
    if a == ExwindTools then
        return b, c
    end
    return a, b
end

local function IsTableEmpty(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

local function WatchEvenOnEvent(event, ...)
    local moduleWatchers = ExwindTools.WatchEvenRegistry[event]
    if not moduleWatchers then return end

    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()

    for moduleName, watcher in pairs(moduleWatchers) do
        local hitTimes = watcher.hitTimes
        hitTimes[#hitTimes + 1] = now

        -- 清理窗口外记录，仅保留 interval 秒内的触发历史
        while hitTimes[1] and (now - hitTimes[1]) > watcher.interval do
            table.remove(hitTimes, 1)
        end

        local count = #hitTimes
        if count >= watcher.minCount and count <= watcher.maxCount then
            local ok, err = pcall(
                watcher.callback,
                event,
                moduleName,
                count,
                watcher.minCount,
                watcher.maxCount,
                watcher.interval,
                ...
            )
            if not ok then
                ExwindTools:LogError(string.format("WatchEven[%s][%s]", event, moduleName), err)
                print(string.format("|cffff0000[ExwindTools] WatchEven 回调错误 [%s][%s]: %s|r", event, moduleName,
                    tostring(err)))
            end
        end
    end
end

--- 注册事件频率监听
--- @param eventName string 事件名称
--- @param moduleName string 模块名称（用于隔离不同调用方）
--- @param minCount number 最小触发次数（含）
--- @param maxCount number 最大触发次数（含）
--- @param interval number|function 统计窗口（秒）；若省略则可直接传 callback，默认 1 秒
--- @param callback function 回调函数
function ExwindTools.WatchEven(a, b, c, d, e, f, g)
    local eventName, moduleName, minCount, maxCount, interval, callback = NormalizeWatchEvenArgs(a, b, c, d, e, f, g)

    -- 兼容简写：WatchEven(event, module, min, max, callback)
    if type(interval) == "function" and callback == nil then
        callback = interval
        interval = 1
    end

    if type(eventName) ~= "string" or eventName == "" then
        error("WatchEven: eventName must be non-empty string", 2)
    end
    if type(moduleName) ~= "string" or moduleName == "" then
        error("WatchEven: moduleName must be non-empty string", 2)
    end
    if type(minCount) ~= "number" or minCount < 1 then
        error("WatchEven: minCount must be number >= 1", 2)
    end
    if type(maxCount) ~= "number" or maxCount < minCount then
        error("WatchEven: maxCount must be number and >= minCount", 2)
    end
    if type(interval) ~= "number" or interval <= 0 then
        error("WatchEven: interval must be number > 0", 2)
    end
    if type(callback) ~= "function" then
        error("WatchEven: callback must be function", 2)
    end

    local isNewEvent = (ExwindTools.WatchEvenRegistry[eventName] == nil)
    if isNewEvent then
        ExwindTools.WatchEvenRegistry[eventName] = {}
    end

    ExwindTools.WatchEvenRegistry[eventName][moduleName] = {
        minCount = math.floor(minCount),
        maxCount = math.floor(maxCount),
        interval = interval,
        callback = callback,
        hitTimes = {},
    }

    if isNewEvent then
        ExwindTools:RegisterEvent(eventName, ExwindTools.WatchEvenOwner, WatchEvenOnEvent)
    end
end

--- 取消事件频率监听
--- @param eventName string 事件名称
--- @param moduleName string|nil 模块名称；为空时取消该事件下全部监听
function ExwindTools.UnwatchEven(a, b, c)
    local eventName, moduleName = NormalizeUnwatchEvenArgs(a, b, c)

    if type(eventName) ~= "string" or eventName == "" then
        error("UnwatchEven: eventName must be non-empty string", 2)
    end

    local moduleWatchers = ExwindTools.WatchEvenRegistry[eventName]
    if not moduleWatchers then return end

    if moduleName ~= nil then
        if type(moduleName) ~= "string" or moduleName == "" then
            error("UnwatchEven: moduleName must be non-empty string when provided", 2)
        end
        moduleWatchers[moduleName] = nil
    else
        wipe(moduleWatchers)
    end

    if IsTableEmpty(moduleWatchers) then
        ExwindTools.WatchEvenRegistry[eventName] = nil
        ExwindTools:UnregisterEvent(eventName, ExwindTools.WatchEvenOwner)
    end
end

--- 按模块取消全部事件频率监听
--- @param moduleName string 模块名称
function ExwindTools.UnwatchEvenByModule(a, b)
    local moduleName = (a == ExwindTools) and b or a

    if type(moduleName) ~= "string" or moduleName == "" then
        error("UnwatchEvenByModule: moduleName must be non-empty string", 2)
    end

    for eventName, moduleWatchers in pairs(ExwindTools.WatchEvenRegistry) do
        if moduleWatchers[moduleName] then
            moduleWatchers[moduleName] = nil
            if IsTableEmpty(moduleWatchers) then
                ExwindTools.WatchEvenRegistry[eventName] = nil
                ExwindTools:UnregisterEvent(eventName, ExwindTools.WatchEvenOwner)
            end
        end
    end
end
