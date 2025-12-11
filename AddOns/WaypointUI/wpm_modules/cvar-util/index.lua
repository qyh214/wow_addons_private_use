local env      = select(2, ...)

local GetCVar  = GetCVar
local SetCVar  = SetCVar
local wipe     = table.wipe
local tinsert  = table.insert

local CVarUtil = env.WPM:New("wpm_modules/cvar-util")

CVarUtil.Enum  = {
    TemporaryType = {
        Permanent           = 1,
        UntilLogout         = 2,
        UntilCombatOrLogout = 3,
        ManualOrLogout      = 4
    }
}


-- Temporary cvar handler
--------------------------------

local untilLogoutList = {}
local untilCombatOrLogoutList = {}
local manualOrLogoutList = {}

local LIST_LOOKUP = {
    [CVarUtil.Enum.TemporaryType.UntilLogout]         = untilLogoutList,
    [CVarUtil.Enum.TemporaryType.UntilCombatOrLogout] = untilCombatOrLogoutList,
    [CVarUtil.Enum.TemporaryType.ManualOrLogout]      = manualOrLogoutList
}

local function addToTemporaryList(temporaryType, name, originalValue)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        list[name] = originalValue
    end
end

local function clearTemporaryList(temporaryType)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        wipe(list)
    end
end

local function removeFromTemporaryList(temporaryType, name)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        list[name] = nil
    end
end

local function washList(temporaryType)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        for k, v in pairs(list) do
            SetCVar(k, v)
        end
        wipe(list)
    end
end

local TemporaryEL = CreateFrame("Frame")
TemporaryEL:RegisterEvent("ADDONS_UNLOADING")
TemporaryEL:RegisterEvent("PLAYER_REGEN_DISABLED")
TemporaryEL:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDONS_UNLOADING" then
        washList(CVarUtil.Enum.TemporaryType.UntilLogout)
        washList(CVarUtil.Enum.TemporaryType.UntilCombatOrLogout)
        washList(CVarUtil.Enum.TemporaryType.ManualOrLogout)
    elseif event == "PLAYER_REGEN_DISABLED" then
        washList(CVarUtil.Enum.TemporaryType.UntilCombatOrLogout)
    end
end)


-- Protected event handler
--------------------------------

--[[
local dirtyNames = {}
local dirtyValues = {}
local dirtyTemporaryTypes = {}

local function wash()
    if InCombatLockdown() or not dirtyNames or not dirtyValues or not dirtyTemporaryTypes then return end

    for i = 1, #dirtyNames do
        local name = dirtyNames[i]
        local value = dirtyValues[i]
        local temporaryType = dirtyTemporaryTypes[i]

        SetCVar(name, value)

        if temporaryType ~= CVarUtil.Enum.TemporaryType.Permanent then
            addToTemporaryList(temporaryType, name, previousValue)
        end
    end

    wipe(dirtyNames)
    wipe(dirtyValues)
    wipe(dirtyTemporaryTypes)
end

local ProtectedEL = CreateFrame("Frame")
ProtectedEL:RegisterEvent("PLAYER_REGEN_ENABLED")
ProtectedEL:SetScript("OnEvent", wash)
]]

-- API
--------------------------------

function CVarUtil.GetCVar(name)
    return GetCVar(name)
end

function CVarUtil.SetCVar(name, value, temporaryType)
    local previousValue = GetCVar(name)
    SetCVar(name, value)

    if temporaryType ~= CVarUtil.Enum.TemporaryType.Permanent then
        addToTemporaryList(temporaryType, name, previousValue)
    end
end

function CVarUtil.ResetManualCVars()
    washList(CVarUtil.Enum.TemporaryType.ManualOrLogout)
end

CVarUtil.ClearTemporaryList      = clearTemporaryList
CVarUtil.RemoveFromTemporaryList = removeFromTemporaryList
CVarUtil.WashList                = washList
