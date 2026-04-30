local env = select(2, ...)
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local SavedVariables_Enum = env.modules:Import("packages\\saved-variables\\enum")
local SavedVariables_Handler = env.modules:New("packages\\saved-variables\\handler")

local type = type
local pairs = pairs
local concat = table.concat

local registeredDatabases = {}

local function GetStoredData(self)
    local storedData = _G[self.databaseName]
    if storedData == nil then
        storedData = {}
        _G[self.databaseName] = storedData
    end
    return storedData
end

local function ResolveNestedPath(rootTable, pathKeys)
    local current = rootTable
    for i = 1, #pathKeys do
        if current == nil then return nil end
        current = current[pathKeys[i]]
    end
    return current
end

local function ResolveNestedSlot(rootTable, pathKeys, createMissing)
    local current = rootTable
    local lastIndex = #pathKeys

    if lastIndex == 0 then return nil end

    for i = 1, lastIndex - 1 do
        local pathKey = pathKeys[i]
        local nextTable = current[pathKey]

        if nextTable == nil then
            if not createMissing then return nil end
            nextTable = {}
            current[pathKey] = nextTable
        elseif type(nextTable) ~= "table" then
            return nil
        end

        current = nextTable
    end

    return current, pathKeys[lastIndex]
end

local function GetValueAtKey(rootTable, key)
    if type(key) ~= "table" then
        return rootTable[key]
    end

    return ResolveNestedPath(rootTable, key)
end

local function SetValueAtKey(rootTable, key, value)
    if type(key) ~= "table" then
        local previousValue = rootTable[key]
        if previousValue == value then return false end

        rootTable[key] = value
        return true
    end

    local parentTable, finalKey = ResolveNestedSlot(rootTable, key, value ~= nil)
    if not parentTable or finalKey == nil then return false end

    local previousValue = parentTable[finalKey]
    if previousValue == value then return false end

    parentTable[finalKey] = value
    return true
end

local function GetCallbackKey(key)
    if type(key) ~= "table" then
        return key
    end

    return concat(key, ".")
end

local function SetVariable(self, key, value)
    local storedData = GetStoredData(self)

    if not SetValueAtKey(storedData, key, value) then return end

    CallbackRegistry.Trigger(self.callbackPrefix .. GetCallbackKey(key), value)
end

local function GetVariable(self, key)
    local storedValue = GetValueAtKey(GetStoredData(self), key)
    if storedValue ~= nil then return storedValue end
    return GetValueAtKey(self.defaultValues, key)
end

local function ResetVariable(self, key)
    local storedData = GetStoredData(self)
    local defaultValue = GetValueAtKey(self.defaultValues, key)

    if not SetValueAtKey(storedData, key, defaultValue) then return end

    CallbackRegistry.Trigger(self.callbackPrefix .. GetCallbackKey(key), defaultValue)
end

local function WipeDatabase(self)
    _G[self.databaseName] = {}
end

local function SetDefaults(self, defaultsTable)
    self.defaultValues = defaultsTable
    return self
end

local function Migrate(self, migrationSchema)
    local storedData = GetStoredData(self)
    if not storedData or type(migrationSchema) ~= "table" then return self end

    for i = 1, #migrationSchema do
        local migration = migrationSchema[i]
        local migrationType = migration.migrationType

        local sourceIsPath = type(migration.from) == "table"
        local destinationIsPath = type(migration.to) == "table"

        local sourceValue = sourceIsPath and ResolveNestedPath(storedData, migration.from) or storedData[migration.from]
        local destinationKey = destinationIsPath and ResolveNestedPath(storedData, migration.to) or migration.to

        if migrationType == "group" and sourceValue and destinationKey then
            local targetTable = destinationIsPath and destinationKey
                or (migration.to == SavedVariables_Enum.Root and storedData)
                or storedData[migration.to]

            if targetTable then
                for sourceKey, sourceVal in pairs(sourceValue) do
                    if targetTable[sourceKey] == nil then
                        targetTable[sourceKey] = sourceVal
                        sourceValue[sourceKey] = nil
                    end
                end
            end
        elseif migrationType == "variable" and sourceValue and destinationKey and storedData[destinationKey] == nil then
            storedData[destinationKey] = sourceValue
            storedData[migration.from] = nil
        elseif migrationType == "delete" and destinationKey then
            storedData[destinationKey] = nil
        elseif migrationType == "execute" and migration.script then
            migration.script(self)
        end
    end
    return self
end

local databaseMetatable = {
    __index = function(self, key)
        if key == "defaults" then
            return function(defaultsTable)
                return SetDefaults(self, defaultsTable)
            end
        elseif key == "migrationPlan" then
            return function(migrationSchema)
                return Migrate(self, migrationSchema)
            end
        end
    end
}

function SavedVariables_Handler.RegisterDatabase(databaseName)
    if not _G[databaseName] then _G[databaseName] = {} end

    local callbackPrefix = "SavedVariables." .. databaseName .. "."
    local databaseEntry = {
        SetVariable    = SetVariable,
        GetVariable    = GetVariable,
        ResetVariable  = ResetVariable,
        Wipe           = WipeDatabase,
        databaseName   = databaseName,
        defaultValues  = {},
        callbackPrefix = callbackPrefix
    }
    setmetatable(databaseEntry, databaseMetatable)

    registeredDatabases[databaseName] = databaseEntry
    return databaseEntry
end

function SavedVariables_Handler.RemoveDatabase(databaseName)
    registeredDatabases[databaseName] = nil
end

function SavedVariables_Handler.GetDatabase(databaseName)
    return registeredDatabases[databaseName]
end

function SavedVariables_Handler.OnChange(databaseName, variableName, callbackFunc)
    CallbackRegistry.Add("SavedVariables." .. databaseName .. "." .. GetCallbackKey(variableName), callbackFunc)
end
