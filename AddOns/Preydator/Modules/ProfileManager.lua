---@diagnostic disable

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable

local ProfileManagerModule = {}
Preydator:RegisterModule("ProfileManager", ProfileManagerModule)

local api = Preydator.API or {}

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local out = {}
    for k, v in pairs(value) do
        out[DeepCopy(k)] = DeepCopy(v)
    end
    return out
end

local function GetDbRoot()
    _G.PreydatorDB = _G.PreydatorDB or {}
    return _G.PreydatorDB
end

local function EnsureProfileRoot()
    local db = GetDbRoot()

    if type(db.profiles) ~= "table" then
        local legacy = {}
        for key, value in pairs(db) do
            if key ~= "profiles" and key ~= "activeProfile" then
                legacy[key] = DeepCopy(value)
            end
        end

        db.profiles = {
            Default = legacy,
        }
        db.activeProfile = "Default"

        for key in pairs(db) do
            if key ~= "profiles" and key ~= "activeProfile" then
                db[key] = nil
            end
        end
    end

    if type(db.activeProfile) ~= "string" or db.activeProfile == "" then
        db.activeProfile = "Default"
    end

    if type(db.profiles[db.activeProfile]) ~= "table" then
        db.profiles[db.activeProfile] = {}
    end

    if type(db.profiles.Default) ~= "table" then
        db.profiles.Default = {}
    end

    return db
end

local function GetActiveProfileName()
    local db = EnsureProfileRoot()
    return db.activeProfile
end

local function GetActiveProfileTable()
    local db = EnsureProfileRoot()
    return db.profiles[db.activeProfile]
end

local function ApplyActiveProfileRuntime()
    if type(api.ApplyRuntimeSettings) == "function" then
        api.ApplyRuntimeSettings(GetActiveProfileTable(), true, true)
        return
    end

    if type(api.RequestBarRefresh) == "function" then
        api.RequestBarRefresh()
    end
end

local function GetAllProfileNames()
    local db = EnsureProfileRoot()
    local names = {}
    for name in pairs(db.profiles) do
        names[#names + 1] = tostring(name)
    end
    table.sort(names, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    return names
end

local function SwitchToProfile(name)
    local db = EnsureProfileRoot()
    name = tostring(name or "")
    if name == "" then
        return false, "Profile name is required."
    end
    if type(db.profiles[name]) ~= "table" then
        return false, "Profile does not exist."
    end

    db.activeProfile = name
    ApplyActiveProfileRuntime()
    return true
end

local function ResetCurrentProfile()
    local db = EnsureProfileRoot()
    local active = db.activeProfile
    local defaults = type(api.GetDefaults) == "function" and api.GetDefaults() or {}
    db.profiles[active] = DeepCopy(defaults)
    ApplyActiveProfileRuntime()
    return true
end

local function CreateProfile(name, copyFrom)
    local db = EnsureProfileRoot()
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        return false, "Please enter a profile name."
    end
    if db.profiles[name] ~= nil then
        return false, "A profile with that name already exists."
    end

    local sourceName = copyFrom and tostring(copyFrom) or nil
    local source = sourceName and db.profiles[sourceName] or nil
    if type(source) == "table" then
        db.profiles[name] = DeepCopy(source)
    else
        local defaults = type(api.GetDefaults) == "function" and api.GetDefaults() or {}
        db.profiles[name] = DeepCopy(defaults)
    end

    return true
end

local function DeleteProfile(name)
    local db = EnsureProfileRoot()
    name = tostring(name or "")
    if name == "" then
        return false, "Profile name is required."
    end
    if name == db.activeProfile then
        return false, "Cannot delete the active profile."
    end
    if db.profiles[name] == nil then
        return false, "Profile does not exist."
    end

    db.profiles[name] = nil
    if next(db.profiles) == nil then
        db.profiles.Default = {}
        db.activeProfile = "Default"
    end

    if db.profiles.Default == nil then
        db.profiles.Default = {}
    end

    return true
end

local function CopyProfileFrom(sourceName)
    local db = EnsureProfileRoot()
    sourceName = tostring(sourceName or "")
    if sourceName == "" then
        return false, "Source profile is required."
    end

    local source = db.profiles[sourceName]
    if type(source) ~= "table" then
        return false, "Source profile does not exist."
    end

    db.profiles[db.activeProfile] = DeepCopy(source)
    ApplyActiveProfileRuntime()
    return true
end

Preydator.ProfileSystem = {
    EnsureProfiles = EnsureProfileRoot,
    GetActiveProfileName = GetActiveProfileName,
    GetActiveProfileTable = GetActiveProfileTable,
    GetAllProfileNames = GetAllProfileNames,
    SwitchToProfile = SwitchToProfile,
    ResetCurrentProfile = ResetCurrentProfile,
    CreateProfile = CreateProfile,
    DeleteProfile = DeleteProfile,
    CopyProfileFrom = CopyProfileFrom,
}

api.GetActiveProfileName = GetActiveProfileName
api.GetAllProfileNames = GetAllProfileNames
api.SwitchToProfile = SwitchToProfile
api.ResetCurrentProfile = ResetCurrentProfile
api.CreateProfile = CreateProfile
api.DeleteProfile = DeleteProfile
api.CopyProfileFrom = CopyProfileFrom

function ProfileManagerModule:OnAddonLoaded()
    EnsureProfileRoot()
end
