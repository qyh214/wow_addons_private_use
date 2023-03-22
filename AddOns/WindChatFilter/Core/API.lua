local W, F, L = unpack(select(2, ...))

local error = error
local type = type

_G[W.AddonNamePlain].API = {}
local API = _G[W.AddonNamePlain].API

function API.RegisterBlackList(name, func)
    if type(name) ~= "string" then
        error("Bad argument #1 to 'RegisterBlackList' (string expected, got " .. type(name) .. ")")
    end

    if type(func) ~= "table" then
        error("Bad argument #2 to 'RegisterBlackList' (table expected, got " .. type(func) .. ")")
    end

    W:GetModule("Core"):RegisterBlackList(name, func)
end

function API.UnregisterBlackList(name)
    if type(name) ~= "string" then
        error("Bad argument #1 to 'UnregisterBlackList' (string expected, got " .. type(name) .. ")")
    end

    W:GetModule("Core"):UnregisterBlackList(name)
end

function API.RegisterWhiteList(name, func)
    if type(name) ~= "string" then
        error("Bad argument #1 to 'RegisterWhiteList' (string expected, got " .. type(name) .. ")")
    end

    if type(func) ~= "table" then
        error("Bad argument #2 to 'RegisterWhiteList' (table expected, got " .. type(func) .. ")")
    end

    W:GetModule("Core"):RegisterWhiteList(name, func)
end

function API.UnregisterWhiteList(name)
    if type(name) ~= "string" then
        error("Bad argument #1 to 'UnregisterWhiteList' (string expected, got " .. type(name) .. ")")
    end

    W:GetModule("Core"):UnregisterWhiteList(name)
end

function API.RebuildRules()
    W:GetModule("Core"):RebuildRules()
end

function API.TestWithAllFilters(...)
    return W:GetModule("Core"):TestWithAllFilters(...)
end
