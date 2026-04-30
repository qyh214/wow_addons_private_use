local env = select(2, ...)
local React = env.modules:New("packages\\react")

local assert = assert
local type = type
local tinsert = table.insert


local db = {}

local function HandleOnChange(self, func)
    assert(type(func) == "function", "Invalid variable `func`: Must be of type `function`")
    tinsert(self, func)
    return #self
end

local function HandleSet(self, value)
    local indexed = db[self.__id]
    indexed.__value = value

    if #indexed > 0 then
        for i = 1, #indexed do
            indexed[i](indexed)
        end
    end
end

local function HandleGet(self)
    return db[self.__id].__value
end


local nextId = 0

function React.New(defaultValue)
    local var = {}
    local id = nextId
    nextId = nextId + 1

    var.__id = id
    var.__isReact = true
    var.__value = defaultValue

    var.OnChange = HandleOnChange
    var.Set = HandleSet
    var.Get = HandleGet

    db[id] = var

    return db[id]
end

function React.IsVariable(var)
    return type(var) == "table" and var.__isReact
end
