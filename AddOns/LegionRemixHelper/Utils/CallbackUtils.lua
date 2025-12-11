---@class AddonPrivate
local Private = select(2, ...)

---@class CallbackUtils
---@field callbacks table<any, table<number, CallbackObject>>
local callbackUtils = {
    callbacks = {}
}
Private.CallbackUtils = callbackUtils

---@class CallbackObject : CallbackObjectMixin

---@class CallbackObjectMixin
local callbackObjectMixin = {}

---@param ... unknown
function callbackObjectMixin:Trigger(...)
    local func = self:GetFunction()
    if type(func) == "function" then
        func(...)
    end
end

function callbackObjectMixin:Remove()
    callbackUtils:RemoveCallback(self)
end

---@return any category
function callbackObjectMixin:GetCategory()
    return self.category
end

---@param category any
function callbackObjectMixin:SetCategory(category)
    self.category = category
end

---@return function func
function callbackObjectMixin:GetFunction()
    return self.func
end

---@param func function
function callbackObjectMixin:SetFunction(func)
    self.func = func
end

---@param category any
---@param func function
---@return CallbackObject|nil callbackObject
function callbackUtils:AddCallback(category, func)
    if type(func) ~= "function" then return end

    local callbackObject = {}
    setmetatable(callbackObject, { __index = callbackObjectMixin })
    ---@cast callbackObject CallbackObject
    callbackObject:SetCategory(category)
    callbackObject:SetFunction(func)

    self.callbacks[category] = self.callbacks[category] or {}
    tinsert(self.callbacks[category], callbackObject)

    return callbackObject
end

---@param category any
---@return table<number, CallbackObject> callbacks
function callbackUtils:GetCallbacks(category)
    return self.callbacks[category] or {}
end

---@param callbackObject CallbackObject
function callbackUtils:RemoveCallback(callbackObject)
    local category = callbackObject:GetCategory()
    if not category or not self.callbacks[category] then return end
    for i, cbObj in ipairs(self.callbacks[category]) do
        if cbObj == callbackObject then
            tremove(self.callbacks[category], i)
            return
        end
    end
end
