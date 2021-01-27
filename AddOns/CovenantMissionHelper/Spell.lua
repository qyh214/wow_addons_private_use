CovenantMissionHelper, CMH = ...

local Spell = {}
function Spell:new(autoCombatSpell)
    local newObj = {}
    --SELECTED_CHAT_FRAME:AddMessage('autoCombatSpellID: ' .. autoCombatSpell.autoCombatSpellID)
    newObj.ID = autoCombatSpell.autoCombatSpellID
    newObj.name = autoCombatSpell.name
    newObj.duration = autoCombatSpell.duration
    newObj.cooldown = autoCombatSpell.cooldown
    newObj.currentCooldown = self:isStartsOnCooldown(newObj.ID) and newObj.cooldown or 0
    --CMH:debug_log('currentCooldown: ' .. newObj.currentCooldown .. ' duration = ' .. tostring(newObj.duration))
    self.__index = self
    setmetatable(newObj, self)
    newObj:setEffects()

    return newObj
end

function Spell:isStartsOnCooldown(spellID)
    for _, ID in ipairs(CMH.DataTables.startsOnCooldownSpells) do
        if ID == spellID then return true end
    end

    return false
end

function Spell:setEffects()
    local effects = CMH.DataTables.SpellEffects[self.ID]
    if effects then
        self.effects = effects
    else
        -- TODO: add logs/warnings
        self.effects = {}
    end
end

function Spell:isAvailable()
    return self.currentCooldown == 0
end

function Spell:startCooldown()
    self.currentCooldown = self.cooldown + 1
end

function Spell:decreaseCooldown()
    if self.currentCooldown > 0 then
        self.currentCooldown = self.currentCooldown - 1
    end
end

function Spell:isAutoAttack()
    return self.ID == 11 or self.ID == 15
end

local Buff = {}
function Buff:new(effect, effectBaseValue, sourceIndex, duration, name)
    local newBuff = {}
    for k,v in pairs(effect) do
        newBuff[k] = v
    end
    newBuff.Period = math.max(newBuff.Period - 1, 0)
    newBuff.currentPeriod = math.max(newBuff.Period, 0)
    newBuff.baseValue = effectBaseValue
    newBuff.sourceIndex = sourceIndex
    newBuff.duration = duration
    newBuff.name = name
    self.__index = self
    return setmetatable(newBuff, self)
end

function Buff:decreaseRestTime()
    self.duration = math.max(self.duration - 1, 0)
    self.currentPeriod = self.currentPeriod == 0 and self.Period or math.max(self.currentPeriod - 1, 0)
    return self.duration
end

CMH.Spell = Spell
CMH.Buff = Buff
