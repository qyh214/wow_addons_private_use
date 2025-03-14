---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.savedInstance = {}

---@class SavedInstance
local SI = BigFootSync.savedInstance

local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetSavedInstanceEncounterInfo = GetSavedInstanceEncounterInfo

function SI:GetSavedInstanceInfo()
    local savedInstances = {}
    for i = 1, GetNumSavedInstances() do
        -- name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId
        local name, lockoutId, reset, difficulty, locked, extended, _, _, _, difficultyName, numEncounters = GetSavedInstanceInfo(i)
        if name and (locked or extended) then
            -- instance
            local t = {
                name = name,
                difficulty = difficultyName,
                lockoutID = lockoutId,
                time = time() + reset,
            }

            -- bosses
            t.bosses = {}
            if numEncounters then
                for j = 1, numEncounters do
                    local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                    tinsert(t.bosses, {bossName, isKilled})
                end
            end

            tinsert(savedInstances, t)
        end
    end
    return savedInstances
end