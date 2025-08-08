local _, Addon = ...

-- 事件Frame
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local observers = self[event]
    if not observers then return end
    for func, _ in pairs(observers) do
        func(...)
    end
end)

function Addon:RegisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    if not func then return end

    eventFrame:RegisterEvent(event)
    eventFrame[event] = eventFrame[event] or {}
    eventFrame[event][func] = true
end

function Addon:UnregisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    local observers = eventFrame[event]
    if not observers then return end
    if not func then
        wipe(observers)
    else
        observers[func] = nil
    end
end

-- 回调
local callbackRegistry = CreateFromMixins(CallbackRegistryMixin)
callbackRegistry:OnLoad()
callbackRegistry:SetUndefinedEventsAllowed(true)

function Addon:RegisterCallback(event, func, owner, ...)
    return callbackRegistry:RegisterCallback(event, func, owner, ...)
end

function Addon:UnregisterCallback(event, owner)
    return callbackRegistry:UnregisterCallback(event, owner)
end

function Addon:TriggerEvent(event, ...)
    return callbackRegistry:TriggerEvent(event, ...)
end

-- 显示红字错误
function Addon:ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

-- 显示黄字消息
function Addon:ShowMessage(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.82, 0.0, 1, 3)
end