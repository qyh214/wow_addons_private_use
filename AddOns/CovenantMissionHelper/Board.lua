CovenantMissionHelper, CMH = ...

local SIMULATE_ITERATIONS = 100
local MAX_ROUNDS = 100
local MAX_RANDOM_ROUNDS = 50
local LVL_UP_ICON = "|TInterface\\petbattles\\battlebar-abilitybadge-strong-small:0|t"
local SKULL_ICON = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t"

local Board = {Errors = {}, CombatLog = {}, HiddenCombatLog = {}, CombatLogEvents = {}}
local TargetTypeEnum, EffectTypeEnum = CMH.DataTables.TargetTypeEnum, CMH.DataTables.EffectTypeEnum

local function arrayForPrint(array)
    if not array then
        for _, text in ipairs(CMH.Board.CombatLog) do print(text) end
        return 'EMPTY ARRAY'
    end
    local result = ''
    for _, e in pairs(array) do
        result = result .. tostring(e) .. ', '
    end
    return result
end

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local function isAura(effectType)
    return effectType >= EffectTypeEnum.DoT and effectType <= EffectTypeEnum.AdditionalTakenDamage
end

function Board:new(missionPage, isCalcRandom)
    local newObj = {
        units = {},
        hasRandomSpells = false,
        probability = 100,
        isMissionOver = false,
        isEmpty = true,
        initialAlliesHP = 0,
        initialEnemiesHP = 0,
        isCalcRandom = isCalcRandom,
        max_rounds = MAX_ROUNDS,
        baseXP = 0,
        winXP = 0,
        --missionPage = missionPage,
    }
    local isCompletedMission = (missionPage.missionInfo == nil)
    local missionInfo = isCompletedMission and _G["CovenantMissionFrame"].MissionComplete.currentMission or missionPage.missionInfo

    newObj.missionID = missionInfo.missionID
    newObj.baseXP = missionInfo.xp
    newObj.winXP = newObj.baseXP
    for _, reward in pairs (missionInfo.rewards) do
        if reward.followerXP then
            newObj.winXP = newObj.winXP + reward.followerXP
        end
    end

    -- set enemy's units
    local enemies = C_Garrison.GetMissionCompleteEncounters(newObj.missionID)
    for i = 1, #enemies do
        local enemyUnit = CMH.Unit:new(enemies[i])
        --SELECTED_CHAT_FRAME:AddMessage("enemyUnitName = " .. enemyUnit.name)
        newObj.units[enemyUnit.boardIndex] = enemyUnit
        newObj.initialEnemiesHP = newObj.initialEnemiesHP + enemyUnit.currentHealth
    end

    --set my team
    -- If completed mission have < 5 followers, "empty" frames isn't empty actually.
    -- It saved from last completed mission.
    local framesByBoardIndex, boardIndexes = {}, {}
    if isCompletedMission then
        -- completed mission
        for _, follower in pairs(_G["CovenantMissionFrame"].MissionComplete.followerGUIDToInfo) do
            table.insert(boardIndexes, follower.boardIndex)
        end
        framesByBoardIndex = _G["CovenantMissionFrame"].MissionComplete.Board.framesByBoardIndex
    else
        boardIndexes = {0, 1, 2, 3, 4}
        framesByBoardIndex = missionPage.Board.framesByBoardIndex
    end

    for _, boardIndex in pairs(boardIndexes) do
        local follower = framesByBoardIndex[boardIndex]
        local info = follower.info
        if info then
            info.boardIndex = follower.boardIndex
            info.maxHealth = info.autoCombatantStats.maxHealth
            info.health = info.autoCombatantStats.currentHealth
            info.attack = info.autoCombatantStats.attack
            info.isAutoTroop = info.isAutoTroop ~= nil and info.isAutoTroop or (info.quality == 0)
            info.followerGUID = follower:GetFollowerGUID()
            local XPToLvlUp = 0
            if info.isAutoTroop then
                info.isLoseLvlUp = false
                info.isWinLvlUp = false
            else
                XPToLvlUp = isCompletedMission and info.maxXP - info.currentXP or info.levelXP - info.xp
                info.isLoseLvlUp = XPToLvlUp < newObj.baseXP
                info.isWinLvlUp = XPToLvlUp < newObj.winXP
            end
            if info.autoCombatSpells == nil then info.autoCombatSpells = follower.autoCombatSpells end
            local myUnit = CMH.Unit:new(info)
            --SELECTED_CHAT_FRAME:AddMessage("myUnitName = " .. myUnit.name)
            newObj.units[follower.boardIndex] = myUnit
            newObj.isEmpty = false
            if myUnit.isAutoTroop == false then newObj.initialAlliesHP = newObj.initialAlliesHP + myUnit.currentHealth end
        end
    end

    self.__index = self
    setmetatable(newObj, self)
    newObj:setHasRandomSpells()
    if self.hasRandomSpells then self.max_rounds = MAX_RANDOM_ROUNDS end
    return newObj
end

function Board:simulate()
    if self.isEmpty then return end

    if self.hasRandomSpells and self.isCalcRandom then
        local new_board = {}
        local win_count = 0
        for i = 1, SIMULATE_ITERATIONS do
            new_board = copy(self)
            new_board:fight()
            if new_board:isWin() then win_count = win_count + 1 end
            CMH.Board.CombatLog = {}
            CMH.Board.HiddenCombatLog = {}
            CMH.Board.CombatLogEvents = {}
        end
        self.probability = math.floor(100 * win_count/SIMULATE_ITERATIONS)
    elseif self.hasRandomSpells then
        return
    end

   self:fight()
end

function Board:fight()
    local round = 1
    while self.isMissionOver == false and round < self.max_rounds do
        CMH:log('\n')
        CMH:log("|c0000FF33Round " .. round .. "|r")
        MissionHelper:addRound()
        local turnOrder = self:getTurnOrder()

        local removed_effects = self:manageBuffsFromDeadUnits()
        local enemy_turn = false
        for _, boardIndex in pairs(turnOrder) do
            CMH:debug_log('turn for index ' .. boardIndex)
            if boardIndex > 4 and enemy_turn == false then
                enemy_turn = true
                CMH:log('\n')
            end
            self:makeUnitAction(round, boardIndex)
        end
        -- unit can die by DoT, but I don't check it inside makeUnitAction
        self.isMissionOver = self:checkMissionOver()
        round = round + 1
    end
end

function Board:setHasRandomSpells()
    for _, unit in pairs(self.units) do
        for _, spell in pairs(unit.spells) do
            for _, effect in pairs(spell.effects) do
                if effect.TargetType == TargetTypeEnum.randomEnemy or effect.TargetType == TargetTypeEnum.randomEnemy_2
                    or effect.TargetType == TargetTypeEnum.randomAlly then
                        self.hasRandomSpells = true
                        return
                end
            end
        end
    end

    self.hasRandomSpells = false
end

--- If one team dead, mission over
function Board:checkMissionOver()
    local isMyTeamAlive = false
    for i = 0, 4 do
        if self:isUnitAlive(i) then
            isMyTeamAlive = true
            break
        end
    end

    local isEnemyTeamAlive = false
    for i = 5, 12 do
        if self:isUnitAlive(i) then
            isEnemyTeamAlive = true
            break
        end
    end

    return not (isMyTeamAlive and isEnemyTeamAlive)
end

function Board:isUnitAlive(boardIndex)
    local unit = self.units[boardIndex]
    if unit then
        return unit:isAlive()
    end
    return false
end

function Board:isTargetableUnit(boardIndex)
    return self:isUnitAlive(boardIndex) and not self.units[boardIndex].untargetable
end

function Board:getTargetableUnits()
    local result = {}
    for i = 0, 12 do
        table.insert(result, i, self:isTargetableUnit(i) and true or false)
    end
    CMH:debug_log("targetableUnits -> " .. arrayForPrint(result))
    return result
end

function Board:getTurnOrder()
    local order = {}
    local sort_table = {}
    for i = 0, 4 do
        if self:isUnitAlive(i) then table.insert(sort_table, self.units[i]) end
    end
    table.sort(sort_table, function (a, b) return (a.currentHealth > b.currentHealth) end)

    for _, unit in pairs(sort_table) do
        table.insert(order, unit.boardIndex)
    end

    sort_table = {}
    for i = 5, 12 do
        if self:isUnitAlive(i) then table.insert(sort_table, self.units[i]) end
    end
    table.sort(sort_table, function (a, b) return (a.currentHealth > b.currentHealth) end)

    for _, unit in pairs(sort_table) do
        table.insert(order, unit.boardIndex)
    end

    CMH:debug_log("turn order -> " .. arrayForPrint(order))
    return order
end

function Board:makeUnitAction(round, boardIndex)
    if self.isMissionOver then return end
    local unit = self.units[boardIndex]
    if not unit:isAlive() then return end

    local targetIndexes, aliveUnits, lastTargetType

    unit:decreaseSpellsCooldown()
    self:manageAppliedBuffs(unit)

    for _, spell in pairs(unit:getAvailableSpells()) do
        if self.isMissionOver then break end
        CMH:debug_log("Spell: " .. spell.name .. ' (' .. #spell.effects .. ')')
        lastTargetType = -1

        for _, effect in pairs(spell.effects) do
            targetIndexes = self:getTargetIndexes(unit, effect.TargetType, lastTargetType, targetIndexes)
            CMH:debug_log("Effect: " .. effect.Effect .. ', TargetType: ' .. effect.TargetType)
            CMH:debug_log("targetIndexes -> " .. arrayForPrint(targetIndexes))

            local targetInfo = {}
            for _, targetIndex in pairs(targetIndexes) do
                local eventTargetInfo = unit:castSpellEffect(self.units[targetIndex], effect, spell, false)
                table.insert(targetInfo, eventTargetInfo)
            end
            MissionHelper:addEvent(spell.ID, isAura(effect.Effect) and EffectTypeEnum.ApplyAura or effect.Effect, boardIndex, targetInfo)

            for _, info in pairs(targetInfo) do
                self:onUnitTakeDamage(spell.ID, boardIndex, info)
            end

            if effect.TargetType ~= TargetTypeEnum.lastTarget then lastTargetType = effect.TargetType end
        end

        unit:startSpellCooldown(spell.ID)

        -- auto attack always has 1 effect and 1 target, so i can check it after cycle
        if #targetIndexes > 0 and spell:isAutoAttack() then
            local targetUnit = self.units[targetIndexes[1]]
            -- dead unit can reflect ...
            if targetUnit.reflect > 0 then
                local eventTargetInfo = targetUnit:castSpellEffect(unit, {Effect = CMH.DataTables.EffectTypeEnum.Reflect, ID = -1}, {}, true)
                MissionHelper:addEvent(spell.ID, CMH.DataTables.EffectTypeEnum.Reflect, targetUnit.boardIndex, {eventTargetInfo})
                self:onUnitTakeDamage(spell.ID, targetUnit.boardIndex, eventTargetInfo)
            end
        end
    end
end

function Board:manageAppliedBuffs(sourceUnit)
    local removed_buffs = {}
    for _, unit in pairs(self.units) do
        if unit:isAlive() then
            local unit_removed_buffs = unit:manageBuffs(sourceUnit)
            for _, buff in pairs(unit_removed_buffs) do
                table.insert(removed_buffs, buff)
            end
        end
    end

    return removed_buffs
end

function Board:manageBuffsFromDeadUnits()
    local removed_buffs = {}
    for _, unit in pairs(self.units) do
        if not self:isUnitAlive(unit.boardIndex) then
            local unit_removed_buffs = self:manageAppliedBuffs(unit)
            for _, buff in pairs(unit_removed_buffs) do
                table.insert(removed_buffs, buff)
            end
        end
    end
end

function Board:onUnitTakeDamage(spellID, casterBoardIndex, eventTargetInfo)
    if eventTargetInfo.newHealth == 0 then
        MissionHelper:addEvent(spellID, CMH.DataTables.EffectTypeEnum.Died, casterBoardIndex, {eventTargetInfo})
        CMH:log(string.format('|cFFFF7700 %s kill %s |r', self.units[casterBoardIndex].name, self.units[eventTargetInfo.boardIndex].name))
        self.isMissionOver = self:checkMissionOver()
    end
end

function Board:getTotalLostHP(isWin)
    local restHP = 0
    local _start, _end, startHP = 0, 4, self.initialAlliesHP
    if not isWin then _start, _end, startHP = 5, 12, self.initialEnemiesHP end
    for i = _start, _end do
        if self.units[i] and self.units[i].isAutoTroop == false then
            if self.units[i].isWinLvlUp then
                restHP = restHP + self.units[i].maxHealth
            elseif self:isUnitAlive(i) then
                restHP = restHP + self.units[i].currentHealth
            end
        end
    end

    return startHP - restHP
end

function Board:getMyTeam()
    local function constructString(unit, isWin)
        local result = unit.name .. '. HP = ' .. unit.currentHealth .. '/' .. unit.maxHealth .. '\n'
        --result = unit.isWinLvlUp and result .. ' (Level Up)\n' or result .. '\n'
        if (isWin and unit.isWinLvlUp) or (not isWin and unit.isLoseLvlUp) then result = LVL_UP_ICON .. result end
        if unit.currentHealth == 0 then result = SKULL_ICON .. result end
        return '    ' .. result
    end

    if self.hasRandomSpells and self.isCalcRandom == false then
        return "Units have random abilities. The mission isn't simulate automatically.\nClick on the button to check the result."
    end

    local isWin = self:isWin()
    local lostHP = self:getTotalLostHP(true)
    local loseOrGain = lostHP >= 0 and 'LOST' or 'RECEIVED'
    local warningText = self.hasRandomSpells and "|cFFFF0000Units have random abilities. Actual rest HP may not be the same as predicted|r\n" or ''

    local text = ''
    for i = 0, 4 do
        if self.units[i] then
            text = text .. constructString(self.units[i], isWin)
        end
    end
    text = string.format("%sMy units:\n%s \n\nTOTAL %s HP = %s", warningText, text, loseOrGain, math.abs(lostHP))

    return text
end

function Board:constructResultString()
    if self.isEmpty then
        return 'Add units on board'
    elseif self.hasRandomSpells and self.isCalcRandom == false then
        return ''
    elseif not self.isMissionOver then
        return string.format('|cFFFF0000More than %s rounds. Winner is undefined|r', self.max_rounds)
    end

    local result = self:isWin()
    if self.probability == 100 and result then
        return '|cFF00FF00 Predicted result: WIN |r'
    elseif self.probability == 0 or (result == false and self.probability == 100) then
        return '|cFFFF0000 Predicted result: LOSE |r'
    else
        return string.format('|cFFFF7700 Predicted result: WIN (~%s%%) |r', self.probability)
    end
end

function Board:isWin()
    for _, unit in pairs(self.units) do
        if unit:isAlive() then
            if unit.boardIndex > 4 then return false else return true
            end
        end
    end
end

function Board:getTargetIndexes(unit, targetType, lastTargetType, lastTargetIndexes)
    -- update targets if skill has different effects target type
    if lastTargetType ~= targetType and targetType ~= TargetTypeEnum.lastTarget then
        local aliveUnits = self:getTargetableUnits()
        return CMH.TargetManager:getTargetIndexes(unit.boardIndex, targetType, aliveUnits, unit.tauntedBy)
    else
        return lastTargetIndexes
    end
end

CMH.Board = Board
