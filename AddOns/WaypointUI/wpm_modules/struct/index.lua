local env              = select(2, ...)

local type             = type
local next             = next
local rawget           = rawget
local rawset           = rawset
local setmetatable     = setmetatable

local Struct           = env.WPM:New("wpm_modules/struct")


-- Shared
--------------------------------

local cachedMetatables = setmetatable({}, { __mode = "k" })


-- Helpers
--------------------------------

local function isStruct(value)
    return type(value) == "table" and rawget(value, "isStruct")
end

local function compareById(structA, structB)
    return structA and structB and structA.id == structB.id
end

local function getOrCreateInstanceMetatable(definition)
    local metatable = cachedMetatables[definition]
    if metatable then return metatable end

    local function indexHandler(instance, key)
        local value = rawget(instance, key)
        if value ~= nil then return value end

        local schema = rawget(instance, "definition")
        if not schema then return nil end

        local defaultValue = rawget(schema, key)
        if isStruct(defaultValue) then
            local substruct = defaultValue({})
            rawset(instance, key, substruct)
            return substruct
        end

        return defaultValue
    end

    local function newindexHandler(instance, key, value)
        local schema = rawget(instance, "definition")
        if schema then
            local defaultValue = rawget(schema, key)
            if isStruct(defaultValue) and type(value) == "table" and not isStruct(value) then
                local existing = rawget(instance, key)
                if existing then
                    for subKey, subValue in next, value do
                        existing[subKey] = subValue
                    end
                else
                    rawset(instance, key, defaultValue(value))
                end
                return
            end
        end
        rawset(instance, key, value)
    end

    local function callHandler(instance, updates)
        if type(updates) ~= "table" then return instance end

        local schema = rawget(instance, "definition")
        if not schema then return instance end

        local clone = {
            id         = rawget(instance, "id"),
            definition = schema,
            isStruct   = true
        }
        setmetatable(clone, getOrCreateInstanceMetatable(schema))

        for key, defaultValue in next, schema do
            if type(defaultValue) ~= "function" and key ~= "isStruct" then
                local existing = rawget(instance, key)
                if existing ~= nil then
                    rawset(clone, key, existing)
                elseif not isStruct(defaultValue) then
                    rawset(clone, key, defaultValue)
                end
            end
        end

        for key, value in next, instance do
            if key ~= "id" and key ~= "definition" and key ~= "isStruct" and rawget(clone, key) == nil then
                rawset(clone, key, value)
            end
        end

        for key, value in next, updates do
            clone[key] = value
        end

        return clone
    end

    metatable = {
        __index    = indexHandler,
        __newindex = newindexHandler,
        __call     = callHandler,
        __eq       = compareById
    }

    cachedMetatables[definition] = metatable
    return metatable
end

local function indexDefinition(structType, key)
    return rawget(structType.definition, key)
end

local function createInstance(structType, initialValues)
    local schema   = rawget(structType, "definition")
    local instance = initialValues or {}

    instance.id         = rawget(structType, "id")
    instance.definition = schema
    instance.isStruct   = true

    setmetatable(instance, getOrCreateInstanceMetatable(schema))

    for key, defaultValue in next, schema do
        if rawget(instance, key) == nil and type(defaultValue) ~= "function" and key ~= "isStruct" then
            if not isStruct(defaultValue) then
                instance[key] = defaultValue
            end
        end
    end

    return instance
end

local definitionMetatable = {
    __index = indexDefinition,
    __eq    = compareById,
    __call  = createInstance
}


-- API
--------------------------------

local structID = 0

function Struct.New(definition)
    structID = structID + 1

    local structType = {
        id         = structID,
        definition = definition,
        isStruct   = true
    }

    return setmetatable(structType, definitionMetatable)
end
