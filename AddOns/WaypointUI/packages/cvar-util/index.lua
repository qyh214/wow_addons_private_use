local env = select(2, ...)
local CVarUtil = env.modules:New("packages\\cvar-util")

local GetCVar = GetCVar
local SetCVar = SetCVar
local wipe = table.wipe

CVarUtil.Enum = {
    TemporaryType = {
        Permanent           = 1,
        UntilLogout         = 2,
        UntilCombatOrLogout = 3,
        ManualOrLogout      = 4
    }
}

local untilLogoutList = {}
local untilCombatOrLogoutList = {}
local manualOrLogoutList = {}

local LIST_LOOKUP = {
    [CVarUtil.Enum.TemporaryType.UntilLogout]         = untilLogoutList,
    [CVarUtil.Enum.TemporaryType.UntilCombatOrLogout] = untilCombatOrLogoutList,
    [CVarUtil.Enum.TemporaryType.ManualOrLogout]      = manualOrLogoutList
}

local function AddToTemporaryList(temporaryType, name, originalValue)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        list[name] = originalValue
    end
end

function CVarUtil.ClearTemporaryList(temporaryType)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        wipe(list)
    end
end

function CVarUtil.RemoveFromTemporaryList(temporaryType, name)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        list[name] = nil
    end
end

function CVarUtil.WashList(temporaryType)
    local list = LIST_LOOKUP[temporaryType]
    if list then
        for k, v in pairs(list) do
            SetCVar(k, v)
        end
        wipe(list)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDONS_UNLOADING")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDONS_UNLOADING" then
        CVarUtil.WashList(CVarUtil.Enum.TemporaryType.UntilLogout)
        CVarUtil.WashList(CVarUtil.Enum.TemporaryType.UntilCombatOrLogout)
        CVarUtil.WashList(CVarUtil.Enum.TemporaryType.ManualOrLogout)
    elseif event == "PLAYER_REGEN_DISABLED" then
        CVarUtil.WashList(CVarUtil.Enum.TemporaryType.UntilCombatOrLogout)
    end
end)


function CVarUtil.GetCVar(name)
    return GetCVar(name)
end

function CVarUtil.SetCVar(name, value, temporaryType)
    local previousValue = GetCVar(name)
    SetCVar(name, value)

    if temporaryType ~= CVarUtil.Enum.TemporaryType.Permanent then
        AddToTemporaryList(temporaryType, name, previousValue)
    end
end

function CVarUtil.ResetManualCVars()
    CVarUtil.WashList(CVarUtil.Enum.TemporaryType.ManualOrLogout)
end
