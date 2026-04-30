local env = select(2, ...)
local Struct = env.modules:New("packages\\struct")

local type = type
local next = next
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable

local cachedMetatables = setmetatable({}, { __mode = "k" })

local function IsStruct(value)
    return type(value) == "table" and rawget(value, "isStruct")
end

local function CompareById(structA, structB)
    return structA and structB and structA.id == structB.id
end

local function GetOrCreateInstanceMetatable(definition)
    local metatable = cachedMetatables[definition]
    if metatable then return metatable end

    local function IndexHandler(instance, key)
        local value = rawget(instance, key)
        if value ~= nil then return value end

        local schema = rawget(instance, "definition")
        if not schema then return nil end

        local defaultValue = rawget(schema, key)
        if IsStruct(defaultValue) then
            local substruct = defaultValue({})
            rawset(instance, key, substruct)
            return substruct
        end

        return defaultValue
    end

    local function NewindexHandler(instance, key, value)
        local schema = rawget(instance, "definition")
        if schema then
            local defaultValue = rawget(schema, key)
            if IsStruct(defaultValue) and type(value) == "table" and not IsStruct(value) then
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

    local function CallHandler(instance, updates)
        if type(updates) ~= "table" then return instance end

        local schema = rawget(instance, "definition")
        if not schema then return instance end

        local clone = {
            id         = rawget(instance, "id"),
            definition = schema,
            isStruct   = true
        }
        setmetatable(clone, GetOrCreateInstanceMetatable(schema))

        for key, defaultValue in next, schema do
            if type(defaultValue) ~= "function" and key ~= "isStruct" then
                local existing = rawget(instance, key)
                if existing ~= nil then
                    rawset(clone, key, existing)
                elseif not IsStruct(defaultValue) then
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
        __index    = IndexHandler,
        __newindex = NewindexHandler,
        __call     = CallHandler,
        __eq       = CompareById
    }

    cachedMetatables[definition] = metatable
    return metatable
end

local function IndexDefinition(structType, key)
    return rawget(structType.definition, key)
end

local function CreateInstance(structType, initialValues)
    local schema = rawget(structType, "definition")
    local instance = initialValues or {}

    instance.id = rawget(structType, "id")
    instance.definition = schema
    instance.isStruct = true

    setmetatable(instance, GetOrCreateInstanceMetatable(schema))

    for key, defaultValue in next, schema do
        if rawget(instance, key) == nil and type(defaultValue) ~= "function" and key ~= "isStruct" then
            if not IsStruct(defaultValue) then
                instance[key] = defaultValue
            end
        end
    end

    return instance
end

local definitionMetatable = {
    __index = IndexDefinition,
    __eq    = CompareById,
    __call  = CreateInstance
}

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

function Struct.Wipe(object)
    for key in next, object do
        if key ~= "id" and key ~= "definition" and key ~= "isStruct" then
            rawset(object, key, nil)
        end
    end
end
