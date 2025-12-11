local env = select(2, ...)

local WPM = {}
env.WPM = WPM


-- API
--------------------------------

function WPM:New(name)
	env["wpm/" .. name] = {}
	return env["wpm/" .. name]
end

function WPM:Import(name)
	return env["wpm/" .. name]
end

local awaitMetatable = {
    __index = function(self, key)
        return env["wpm/" .. rawget(self, "name")][key]
    end
}

function WPM:Await(name)
    return setmetatable({ name = name }, awaitMetatable)
end
