CovenantMissionHelper, CMH = ...

local TargetManager = {}
local TargetTypeEnum = CMH.DataTables.TargetTypeEnum

local function getTargetPriority(sourceIndex, targetType, mainTarget)
    local targets = CMH.DataTables.TargetPriorityByType[targetType][sourceIndex]
    if mainTarget ~= nil then table.insert(targets, 1, mainTarget) end
    return targets
end

local function getMainTarget(priority, boardUnits)
    for _, unitIndex in pairs(priority) do
        if boardUnits[unitIndex] then return unitIndex end
    end
end

local function getSelfTarget(sourceIndex, targetType, boardUnits) return {sourceIndex} end

local function getSimpleTarget(sourceIndex, targetType, boardUnits, mainTarget)
    -- adjacent ally, closest enemy, furthest enemy
    local priority
    if mainTarget ~= nil and (targetType == TargetTypeEnum.closestEnemy or targetType == TargetTypeEnum.furthestEnemy) then return {mainTarget} end
    priority = getTargetPriority(sourceIndex, targetType)
    mainTarget = getMainTarget(priority, boardUnits)
    return {mainTarget}
end

local function getAllAllies(sourceIndex, targetType, boardUnits)
    local targets = {}
    if sourceIndex <=4 then
            for i = 0, 4 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        else
            for i = 5, 12 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    return targets
end

local function getAllEnemies(sourceIndex, targetType, boardUnits)
    local targets = {}
    if sourceIndex <=4 then
            for i = 5, 12 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        else
            for i = 0, 4 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    return targets
end

local function getAllAdjacentAllies(sourceIndex, targetType, boardUnits)
    local targets = {}
    local adjacentTargets = CMH.DataTables.AdjacentAllies[sourceIndex]
    for i = 1, #adjacentTargets do
        if boardUnits[adjacentTargets[i]] then
            table.insert(targets, adjacentTargets[i])
        end
    end
    return targets
end

local function getAllAdjacentEnemies(sourceIndex, targetType, boardUnits, mainTarget)
    -- TODO: if taunt?
    local targets = {}
    local targetInfo = CMH.DataTables.AdjacentEnemies[sourceIndex]
    local aliveBlockerUnit = getMainTarget(targetInfo.blockerUnits, boardUnits)

    if aliveBlockerUnit ~= nil then
        for _, boardIndex in ipairs(targetInfo.aliveBlockerUnitGroup) do
            if boardUnits[boardIndex] then table.insert(targets, boardIndex) end
        end
    else
        -- one cleave group
        if type(targetInfo.deadBlockerUnitGroup[1]) == 'number' then
            for _, boardIndex in ipairs(targetInfo.deadBlockerUnitGroup) do
                if boardUnits[boardIndex] then table.insert(targets, boardIndex) end
            end

            --many cleave groups
        elseif type(targetInfo.deadBlockerUnitGroup[1]) == 'table' then
            for _, group in ipairs(targetInfo.deadBlockerUnitGroup) do
                for _, boardIndex in ipairs(group) do
                    if boardUnits[boardIndex] then table.insert(targets, boardIndex) end
                    if #targets > 0 then return targets end
                end
            end
        end
    end

    if #targets == 0 then
        local singleTarget = getMainTarget(targetInfo.aloneUnits, boardUnits)
        if singleTarget ~= nil then table.insert(targets, singleTarget) end
    end

    return targets
end

local function getClosestAllyCone(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    mainTarget = getSimpleTarget(sourceIndex, TargetTypeEnum.closestEnemy, boardUnits, mainTarget)[1]
    if mainTarget == nil then return {} end
    local coneTargets = CMH.DataTables.ConeAllies[mainTarget]
    for i = 1, #coneTargets do
        if boardUnits[coneTargets[i]] then
            table.insert(targets, coneTargets[i])
        end
    end
    return targets
end

local function getClosestEnemyCone(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    mainTarget = getSimpleTarget(sourceIndex, TargetTypeEnum.closestEnemy, boardUnits, mainTarget)[1]
    if mainTarget == nil then return {} end
    local coneTargets = CMH.DataTables.ConeEnemies[mainTarget]
    for i = 1, #coneTargets do
        if boardUnits[coneTargets[i]] then
            table.insert(targets, coneTargets[i])
        end
    end
    return targets
end

local function getClosestEnemyLine(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    mainTarget = getSimpleTarget(sourceIndex, TargetTypeEnum.closestEnemy, boardUnits, mainTarget)[1]
    if mainTarget == nil then return {} end
    local lineTargets = CMH.DataTables.LineEnemies[mainTarget]
    for i = 1, #lineTargets do
        if boardUnits[lineTargets[i]] then
            table.insert(targets, lineTargets[i])
        end
    end
    return targets
end

local function getAllMeleeAllies(sourceIndex, targetType, boardUnits)
    local targets = {}
    if sourceIndex <= 4 then
        for i = 2, 4 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 0, 1 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end

    else
        for i = 5, 8 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 9, 12 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    end

    return targets
end

local function getAllMeleeEnemies(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    if sourceIndex <= 4 then
        for i = 5, 8 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 9, 12 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end

    else
        for i = 2, 4 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 0, 1 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    end

    if mainTarget ~= nil then table.insert(targets, 1, mainTarget) end
    return targets
end

local function getAllRangedAllies(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    if sourceIndex <= 4 then
        for i = 0, 1 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 2, 4 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end

    else
        for i = 9, 12 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 5, 8 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    end

    return targets
end

local function getAllRangedEnemies(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    if sourceIndex <= 4 then
        for i = 9, 12 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 5, 8 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end

    else
        for i = 0, 1 do
            if boardUnits[i] then
                table.insert(targets, i)
            end
        end
        if #targets == 0 then
            for i = 2, 4 do
                if boardUnits[i] then
                    table.insert(targets, i)
                end
            end
        end
    end

    if mainTarget ~= nil then table.insert(targets, 1, mainTarget) end
    return targets
end

local function notImplemented(sourceIndex, targetType, boardUnits, mainTarget)
    -- TODO: logs
    return {sourceIndex}
end

local function getRandomEnemy(sourceIndex, targetType, boardUnits, mainTarget)
    if mainTarget ~= nil then return {mainTarget} end
    local targets = {}
    for i, v in ipairs(boardUnits) do
        if (sourceIndex <= 4 and i > 4 and v == true) or (sourceIndex > 4 and i <= 4 and v == true) then table.insert(targets, i) end
    end

    if #targets == 0 then return {} end
    return {targets[random(#targets)]}
end

local function getRandomAlly(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    for i, v in ipairs(boardUnits) do
        if (sourceIndex <= 4 and i <= 4 and v == true) or (sourceIndex > 4 and i > 4 and v == true) then table.insert(targets, i) end
    end

    if #targets == 0 then return {} end
    return {targets[random(#targets)]}
end

local function getEnvAllAllies(sourceIndex, targetType, boardUnits, mainTarget)
    return {0, 1, 2, 3, 4}
end

local function getEnvAllEnemies(sourceIndex, targetType, boardUnits, mainTarget)
    return {5, 6, 7, 8, 9, 10, 11, 12}
end

local function getAlliesExpectSelf(sourceIndex, targetType, boardUnits, mainTarget)
    local targets = {}
    if sourceIndex <=4 then
            for i = 0, 4 do
                if boardUnits[i] and i ~= sourceIndex then
                    table.insert(targets, i)
                end
            end
        else
            for i = 5, 12 do
                if boardUnits[i] and i ~= sourceIndex then
                    table.insert(targets, i)
                end
            end
        end
    return targets
end

local FunctionTable = {
    [0] = notImplemented,
    [1] = getSelfTarget,
    [2] = getSimpleTarget,
    [3] = getSimpleTarget,
    [5] = getSimpleTarget,
    [6] = getAllAllies,
    [7] = getAllEnemies,
    [8] = getAllAdjacentAllies,
    [9] = getAllAdjacentEnemies,
    [10] = getClosestAllyCone,
    [11] = getClosestEnemyCone,
    [13] = getClosestEnemyLine,
    [14] = getAllMeleeAllies,
    [15] = getAllMeleeEnemies,
    [16] = getAllRangedAllies,
    [17] = getAllRangedEnemies,
    [19] = getRandomEnemy,
    [20] = getRandomEnemy,
    [21] = getRandomAlly,
    [22] = getAlliesExpectSelf,
    [23] = getEnvAllAllies,
    [24] = getEnvAllEnemies
}

function TargetManager:getTargetIndexes(sourceIndex, targetType, boardUnits, mainTarget)
    local func = FunctionTable[targetType]
    return func(sourceIndex, targetType, boardUnits, mainTarget)
end

CMH.TargetManager = TargetManager
