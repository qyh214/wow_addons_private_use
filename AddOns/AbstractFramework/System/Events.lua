---@class AbstractFramework
local AF = _G.AbstractFramework

AF.AddEventHandler(AF)

---------------------------------------------------------------------
-- login
---------------------------------------------------------------------
AF:RegisterEvent("PLAYER_LOGIN", AF.GetFireFunc("AF_PLAYER_LOGIN"))

---------------------------------------------------------------------
-- instance
---------------------------------------------------------------------
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local IsDelveInProgress = C_PartyInfo.IsDelveInProgress
local IsDelveComplete = C_PartyInfo.IsDelveComplete
local wasInInstance = nil

--* AF_INSTANCE_STATE_CHANGE / AF_INSTANCE_ENTER / AF_INSTANCE_LEAVE
-- payload: instanceInfo
-- instanceInfo.wasInInstance:
--     nil if first time after login
--     true if the player was in an instance before
--     false if not

local instanceInfo = {}
setmetatable(instanceInfo, {
    __tostring = function(t)
        return AF.WrapTextInColor(t.name or _G.UNKNOWN, t.isIn and "green" or "red") .. "||" ..  (t.instanceType or "none")
    end
})

local function CheckInstanceStatus(_, event)
    local isIn, iType = IsInInstance()

    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()

    -- if IsDelveInProgress() or IsDelveComplete() then
    if difficultyID == 208 then -- https://warcraft.wiki.gg/wiki/DifficultyID
        isIn = true
        iType = "delve"
    else
        isIn, iType = IsInInstance()
    end

    instanceInfo.isIn = isIn
    instanceInfo.wasIn = wasInInstance
    instanceInfo.name = name
    instanceInfo.instanceType = iType
    instanceInfo.difficultyID = difficultyID
    instanceInfo.difficultyName = difficultyName
    instanceInfo.maxPlayers = maxPlayers
    instanceInfo.dynamicDifficulty = dynamicDifficulty
    instanceInfo.isDynamic = isDynamic
    instanceInfo.instanceID = instanceID
    instanceInfo.instanceGroupSize = instanceGroupSizew
    instanceInfo.LfgDungeonID = LfgDungeonID

    if isIn ~= wasInInstance then
        AF.Fire("AF_INSTANCE_STATE_CHANGE", instanceInfo)
    end

    if isIn and not wasInInstance then
        AF.Fire("AF_INSTANCE_ENTER", instanceInfo)
    elseif not isIn and wasInInstance then
        AF.Fire("AF_INSTANCE_LEAVE", instanceInfo)
    end

    wasInInstance = isIn
end
AF:RegisterEvent("SCENARIO_UPDATE", AF.GetDelayedInvoker(1, CheckInstanceStatus))

local function AF_PLAYER_ENTERING_WORLD(_, _, isInitialLogin, isReloadingUi)
    AF.Fire("AF_PLAYER_ENTERING_WORLD", isInitialLogin, isReloadingUi)
    AF.DelayedInvoke(0.5, CheckInstanceStatus)
end
AF:RegisterEvent("PLAYER_ENTERING_WORLD", AF_PLAYER_ENTERING_WORLD)

function AF.IsInInstance()
    return instanceInfo.isIn
end

---@return string name
---@return string instanceType
---@return number difficultyID
---@return string difficultyName
---@return number maxPlayers
---@return number dynamicDifficulty
---@return boolean? isDynamic
---@return number instanceID
---@return number instanceGroupSize
---@return number? lfgDungeonID
function AF.GetInstanceInfo()
    return instanceInfo.name, instanceInfo.instanceType, instanceInfo.difficultyID,
        instanceInfo.difficultyName, instanceInfo.maxPlayers, instanceInfo.dynamicDifficulty,
        instanceInfo.isDynamic, instanceInfo.instanceID, instanceInfo.instanceGroupSize,
        instanceInfo.LfgDungeonID
end

---------------------------------------------------------------------
-- combat
--------------------------------------------------------------------
--* AF_COMBAT_ENTER / AF_COMBAT_LEAVE
AF:RegisterEvent("PLAYER_REGEN_DISABLED", AF.GetFireFunc("AF_COMBAT_ENTER"))
AF:RegisterEvent("PLAYER_REGEN_ENABLED", AF.GetFireFunc("AF_COMBAT_LEAVE"))