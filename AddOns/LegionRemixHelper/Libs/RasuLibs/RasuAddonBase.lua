---@class RasuAddon
---@field RegisteredAddons table<string, RasuAddonBase>
---@field CreateAddon fun(self:RasuAddon, name:string, db:string|table|?, defaultDB:table|?, loc:table|?, defaultLoc:string|?, ignoreError:boolean|?, charDB:string|table|?, defaultCharDB:table|?) : RasuAddonBase
---@field GetAddon fun(self:RasuAddon, name:string) : RasuAddonBase|?
local lib = LibStub:NewLibrary("RasuAddon", 53)

if not lib then
    return
end

---@alias elapsedTime number
---@alias RasuEvent WowEvent
---|"EVERY_FRAME",  # `elapsedTime`

lib.RegisteredAddons = {}

---@class RasuBaseMixin
---@field PrefixColor colorRGB
---@field Version string
---@field Name string
---@field DisplayName string
---@field Events table
---@field Commands table
---@field Loc table|?
---@field Database table|string|?
---@field CharDatabase table|string|?
---@field DefaultDatabase table|?
---@field DefaultCharDatabase table|?
---@field OnInitialize function|?
---@field OnEnable function|?
---@field OnDisable function|?
---@field EventsFrame Frame
local AddonBase = {
    PrefixColor = CreateColorFromHexString("FFFFCA2E"),
    Version = "",
    Name = "",
    DisplayName = "",
    EventCallbacks = {},
    DatabaseCallbacks = {},
    Commands = {},
    Loc = {},
    Database = {},
    DefaultDatabase = {},
    CharDatabase = {},
    DefaultCharDatabase = {}
}

function lib:CreateAddon(name, db, defaultDB, loc, defaultLoc, ignoreError, charDB, defaultCharDB)
    defaultLoc = defaultLoc or "enUS"
    if self.RegisteredAddons[name] and not ignoreError then
        error("This addon name is already taken!", 2)
    end
    ---@class RasuAddonBase : RasuBaseMixin
    local addon = CreateFromMixins(AddonBase)
    self.RegisteredAddons[name] = addon
    addon.Version = C_AddOns.GetAddOnMetadata(name, "Version") or "1.0.0"
    addon.Name = name
    addon.DisplayName = C_AddOns.GetAddOnMetadata(name, "Title") or name
    addon.Database = db
    addon.DefaultDatabase = defaultDB
    addon.CharDatabase = charDB
    addon.DefaultCharDatabase = defaultCharDB

    if loc and (loc[GetLocale()] or defaultLoc) then
        local isLocSet = false
        for lang, langInfo in pairs(loc) do
            if langInfo.isEditing then
                addon:FPrint("You're currently editing the localization for '%s'", lang)
                addon.Loc = langInfo
                isLocSet = true
            end
        end
        if not isLocSet then
            addon.Loc = loc[GetLocale()] or loc[defaultLoc]
        end
    end

    local addonEvents = CreateFrame("Frame")
    addonEvents:RegisterEvent("ADDON_LOADED")
    addonEvents:RegisterEvent("PLAYER_LOGIN")
    addonEvents:RegisterEvent("PLAYER_LOGOUT")
    addonEvents:SetScript("OnEvent", function(_, ...)
        addon:OnEvent(...)
    end)
    addon.EventsFrame = addonEvents

    if IsLoggedIn() then
        addon:InitializeAddon()
        addon:EnableAddon()
    end
    return addon
end

function lib:GetAddon(name)
    return self.RegisteredAddons[name]
end

---@param event RasuEvent
---@param name string
---@param callbackFunc fun(self:RasuAddonBase, event:string, ...:any)
---@param args table|?
---@param cleuSubEvents table|?
---@return string
function AddonBase:RegisterEventCallback(event, name, callbackFunc, args, cleuSubEvents)
    if not self.EventCallbacks[event] then
        self.EventCallbacks[event] = {}
    end
    if self.EventCallbacks[event][name] then
        error("This callback name is already taken!", 3)
    end
    local subEvents
    if cleuSubEvents then
        subEvents = {}
        for _, subEventName in ipairs(cleuSubEvents) do
            subEvents[subEventName] = true
        end
    end
    self.EventCallbacks[event][name] = {
        func = callbackFunc,
        args = args or {},
        subEvents = subEvents,
    }
    return name
end

---@param event RasuEvent
---@param name string
---@return table|nil
function AddonBase:GetEventCallback(event, name)
    if not self.EventCallbacks[event] then return end
    return self.EventCallbacks[event][name]
end

---@param event RasuEvent
---@param name string
function AddonBase:UnregisterEventCallback(event, name)
    if self:GetEventCallback(event, name) then
        wipe(self.EventCallbacks[event][name])
        self.EventCallbacks[event][name] = nil
    end
end

---@param event RasuEvent
---@param callbackName string
---@param func string|fun(self:RasuAddonBase, event:string, ...:any)|?
---@param args table|?
---@param cleuSubEvents table|?
function AddonBase:RegisterEvent(event, callbackName, func, args, cleuSubEvents)
    if event == "EVERY_FRAME" then
        self.EventsFrame:SetScript("OnUpdate", function(_, ...)
            self:OnEvent("EVERY_FRAME", ...)
        end)
    else
        ---@cast event WowEvent
        self.EventsFrame:RegisterEvent(event)
    end
    if not callbackName then return end
    local callbackFunc = type(func) == "function" and func or type(func) == "string" and self[func] or self[event]
    ---@cast callbackFunc function
    self:RegisterEventCallback(event, callbackName, callbackFunc, args, cleuSubEvents)
end

---@param event RasuEvent
function AddonBase:UnregisterEvent(event)
    if event == "EVERY_FRAME" then
        self.EventsFrame:SetScript("OnUpdate", nil)
    else
        ---@cast event WowEvent
        self.EventsFrame:UnregisterEvent(event)
    end
end

---@param msg string
---@return table
local function msgToArgs(msg)
    msg = msg:lower()
    local args = {}
    for arg in msg:gmatch("%S+") do
        table.insert(args, arg)
    end
    return args
end

---@param commands table
---@param func string|fun(self:RasuBaseMixin, args:table)
function AddonBase:RegisterCommand(commands, func)
    local name = "RASU_" .. commands[1]:upper()
    if type(func) == "string" then
        SlashCmdList[name] = function(msg)
            self[func](self, msgToArgs(msg))
        end
    else
        SlashCmdList[name] = function(msg)
            func(self, msgToArgs(msg))
        end
    end
    for index, command in ipairs(commands) do
        _G["SLASH_" .. name .. index] = "/" .. command:lower()
    end
    self.Commands[commands[1]] = name
end

---@param command string
function AddonBase:UnregisterCommand(command)
    local name = self.Commands[command]
    if name then
        SlashCmdList[name] = nil
        _G["SLASH_" .. name .. "1"] = nil
        hash_SlashCmdList["/" .. command:upper()] = nil
        self.Commands[command] = nil
    end
end

function AddonBase:InitializeAddon()
    if type(self.Database) == "string" then
        _G[self.Database] = _G[self.Database] or self.DefaultDatabase
        self.Database = _G[self.Database]
    end
    if type(self.CharDatabase) == "string" then
        _G[self.CharDatabase] = _G[self.CharDatabase] or self.DefaultCharDatabase
        self.CharDatabase = _G[self.CharDatabase]
    end

    if self.OnInitialize then
        self:OnInitialize()
    end
end

function AddonBase:EnableAddon()
    if self.OnEnable then
        self:OnEnable()
    end
end

function AddonBase:DisableAddon()
    if self.OnDisable then
        self:OnDisable()
    end
end

---@param message string
---@param ... string
function AddonBase:ThrowError(message, ...)
    error(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.DisplayName), message, ... or ""), 2)
end

---@param ... string
function AddonBase:Print(...)
    local args = ""
    for _, val in ipairs({ ... }) do
        args = args .. " " .. tostring(val)
    end
    print(string.format("%s: %s", self.PrefixColor:WrapTextInColorCode(self.DisplayName), args))
end

---@param message string
---@param ... string
function AddonBase:FPrint(message, ...)
    self:Print(... and string.format(message, ...) or message or "")
end

---@param ... table
---@return table
function AddonBase:MergeTables(...)
    local mergedTable = {}
    for _, tbl in pairs({ ... }) do
        for _, value in pairs(tbl) do
            tinsert(mergedTable, value)
        end
    end
    return mergedTable
end

---@param event RasuEvent
---@param ... any
function AddonBase:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName == self.Name then
            self:InitializeAddon()
        end
    elseif event == "PLAYER_LOGIN" then
        self:EnableAddon()
    elseif event == "PLAYER_LOGOUT" then
        self:DisableAddon()
    end
    if self.EventCallbacks[event] then
        local cleuArgs = {}
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            cleuArgs = { CombatLogGetCurrentEventInfo() }
        end
        for entryName, callbackEntry in pairs(self.EventCallbacks[event]) do
            if event == "COMBAT_LOG_EVENT_UNFILTERED" and callbackEntry.subEvents then
                if not callbackEntry.subEvents[cleuArgs[2]] then
                    return
                end
            end
            local callbackArgs = self:MergeTables(callbackEntry.args, { ... }, cleuArgs)
            if callbackEntry.func then
                callbackEntry.func(self, event, unpack(callbackArgs))
            end
        end
    end
end

---@param databasePath string
---@param silent boolean|?
---@param useCharDB boolean|?
---@return unknown value
function AddonBase:GetDatabaseValue(databasePath, silent, useCharDB)
    local dbValue = useCharDB and self.CharDatabase or self.Database
    if type(dbValue) ~= "table" then
        if silent then return nil end
        error("Database is not a table!", 2)
    end
    for step in databasePath:gmatch("[^%.]+") do
        if type(dbValue) == "table" then
            dbValue = dbValue[step]
        else
            if silent then return nil end
            error(string.format("Couldn't find %s!", step), 2)
        end
    end
    return dbValue
end

---@param databasePath string
---@param newValue any
---@param useCharDB boolean|?
function AddonBase:SetDatabaseValue(databasePath, newValue, useCharDB)
    local dbTable = useCharDB and self.CharDatabase or self.Database
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    if self:InitDatabasePath(databasePath, newValue, useCharDB) then return end
    local keys = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(keys, step)
    end

    local lastKey = keys[#keys]
    local parentTable = self:GetParentTable(dbTable, keys)

    if parentTable then
        parentTable[lastKey] = newValue
    else
        error("Invalid database path!", 2)
    end

    if self.DatabaseCallbacks[databasePath] then
        for _, callback in ipairs(self.DatabaseCallbacks[databasePath]) do
            callback(databasePath, newValue)
        end
    end
end

---@param tbl table
---@param keys table
---@return table|?
function AddonBase:GetParentTable(tbl, keys)
    local parentTable = tbl
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(parentTable[key]) == "table" then
            parentTable = parentTable[key]
        else
            return nil
        end
    end
    return parentTable
end

---@param databasePath string
---@param callback fun(path:string, value:any)
function AddonBase:CreateDatabaseCallback(databasePath, callback)
    if not self.DatabaseCallbacks[databasePath] then
        self.DatabaseCallbacks[databasePath] = {}
    end
    tinsert(self.DatabaseCallbacks[databasePath], callback)
    callback(databasePath, self:GetDatabaseValue(databasePath))
end

---@param databasePath string
---@param forceState boolean?
---@param useCharDB boolean|?
function AddonBase:ToggleDatabaseValue(databasePath, forceState, useCharDB)
    self:SetDatabaseValue(databasePath, forceState ~= nil and forceState or not self:GetDatabaseValue(databasePath, false, useCharDB), useCharDB)
end

---@param databasePath string
---@param defaultValue any
---@param useCharDB boolean|?
---@return boolean? wasDefaultSet
function AddonBase:InitDatabasePath(databasePath, defaultValue, useCharDB)
    local dbTable = useCharDB and self.CharDatabase or self.Database
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    local steps = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(steps, step)
    end

    for i, step in ipairs(steps) do
        if dbTable[step] == nil then
            if i == #steps then
                dbTable[step] = defaultValue
                return true
            else
                dbTable[step] = {}
            end
        end
        dbTable = dbTable[step]
    end
end

function AddonBase:CopyTable(originalTbl)
    local tbl = {}
    for key, value in pairs(originalTbl) do
        if type(value) == "table" then
            tbl[key] = self:CopyTable(value)
        else
            tbl[key] = value
        end
    end
    return tbl
end
