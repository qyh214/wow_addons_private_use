---@class AbstractFramework
local AF = _G.AbstractFramework

local hooksecurefunc = hooksecurefunc

-- basic hook system using hooksecurefunc
local hooks = {}

---@param obj table|nil if nil, the method is global
---@param method string the method to hook
---@param handler function the handler to call when the method is called
function AF.Hook(obj, method, handler)
    assert(type(method) == "string", "Method must be a string")
    assert(type(handler) == "function", "Handler must be a function")

    if obj then
        hooks[obj] = hooks[obj] or {}
        hooks[obj][method] = hooks[obj][method] or {}

        if hooks[obj][method][handler] then return end
        hooks[obj][method][handler] = true

        hooksecurefunc(obj, method, function(...)
            if hooks[obj][method][handler] then
                handler(...)
            end
        end)

    else
        hooks[method] = hooks[method] or {}

        if hooks[method][handler] then return end
        hooks[method][handler] = true

        hooksecurefunc(method, function(...)
            if hooks[method][handler] then
                handler(...)
            end
        end)
    end

end

---@param obj table|nil if nil, the method is global
---@param method string the method to unhook
---@param handler function the handler to remove
function AF.Unhook(obj, method, handler)
    assert(type(method) == "string", "Method must be a string")
    assert(type(handler) == "function", "Handler must be a function")

    if obj then
        if hooks[obj] and hooks[obj][method] then
            hooks[obj][method][handler] = nil
        end
    else
        if hooks[method] then
            hooks[method][handler] = nil
        end
    end
end