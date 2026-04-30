local env = select(2, ...)
local modules = {}
env.modules = modules

function modules:New(name)
    env["module:" .. name] = {}
    return env["module:" .. name]
end

function modules:Import(name)
    return env["module:" .. name]
end

local awaitMetatable = {
    __index = function(self, key)
        return env["module:" .. rawget(self, "name")][key]
    end
}

function modules:Await(name)
    return setmetatable({ name = name }, awaitMetatable)
end
