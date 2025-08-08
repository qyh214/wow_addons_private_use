---@class AbstractFramework
local AF = _G.AbstractFramework

local type, select = type, select
local NewTimer = C_Timer.NewTimer

---------------------------------------------------------------------
-- delayed invoke
---------------------------------------------------------------------
local delayed = {}

function AF.DelayedInvoke(delay, func, ...)
    assert(type(delay) == "number", "delay must be a number")
    assert(type(func) == "function", "func must be a function")

    -- cancel existing timer
    if delayed[func] then
        delayed[func]:Cancel()
        delayed[func] = nil
    end

    -- save arguments directly to local variables to reduce closure overhead
    local a1, a2, a3, a4, a5, a6, a7, a8 = ...
    local numArgs = select("#", ...)
    local args
    if numArgs > 8 then
        args = {...}
    end

    delayed[func] = NewTimer(delay, function()
        delayed[func] = nil
        -- call function based on number of arguments, avoid creating temporary tables
        if numArgs == 0 then
            func()
        elseif numArgs == 1 then
            func(a1)
        elseif numArgs == 2 then
            func(a1, a2)
        elseif numArgs == 3 then
            func(a1, a2, a3)
        elseif numArgs == 4 then
            func(a1, a2, a3, a4)
        elseif numArgs == 5 then
            func(a1, a2, a3, a4, a5)
        elseif numArgs == 6 then
            func(a1, a2, a3, a4, a5, a6)
        elseif numArgs == 7 then
            func(a1, a2, a3, a4, a5, a6, a7)
        elseif numArgs == 8 then
            func(a1, a2, a3, a4, a5, a6, a7, a8)
        else
            func(unpack(args, 1, numArgs))
        end
    end)
end

function AF.GetDelayedInvoker(delay, func)
    assert(type(delay) == "number", "delay must be a number")
    assert(type(func) == "function", "func must be a function")

    return function(...)
        AF.DelayedInvoke(delay, func, ...)
    end
end