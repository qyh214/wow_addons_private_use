--[[
    local React = env.WPM:Import("wpm_modules/react")


    -- React variables used a shared instance...

    local var = React.New(1)
    var:OnChange(function()
        print("var changed to:", var:Get())
    end)

    var:Set(2)
    -- var changed to: 2
    var:Set(3)
    -- var changed to: 3

    local var1 = var
    var1:Set(1)
    -- var changed to: 1
]]

local env     = select(2, ...)

local assert  = assert
local type    = type
local tinsert = table.insert

local React   = env.WPM:New("wpm_modules/react")


-- Shared
--------------------------------

local db = {}

local function handleOnChange(self, func)
    assert(type(func) == "function", "Invalid variable `func`: Must be of type `function`")
    tinsert(self, func)
    return #self
end

local function handleSet(self, value)
    local indexed = db[self.__id]
    indexed.__value = value

    if #indexed > 0 then
        for i = 1, #indexed do
            indexed[i](indexed)
        end
    end
end

local function handleGet(self)
    return db[self.__id].__value
end


-- API
--------------------------------

local idCounter = 0

function React.New(defaultValue)
    local var = {}
    local id = idCounter
    idCounter = idCounter + 1

    var.__id = id
    var.__isReact = true
    var.__value = defaultValue

    var.OnChange = handleOnChange
    var.Set = handleSet
    var.Get = handleGet

    db[id] = var

    return db[id]
end

function React.IsVariable(var)
    return type(var) == "table" and var.__isReact
end
