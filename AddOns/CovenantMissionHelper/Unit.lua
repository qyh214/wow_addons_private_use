CovenantMissionHelper, CMH = ...

local Unit = {}
local EffectTypeEnum, EffectType = CMH.DataTables.EffectTypeEnum, CMH.DataTables.EffectType

local function isDamageEffect(effect, isAppliedBuff)
    return effect.Effect == EffectTypeEnum.Damage
            or effect.Effect == EffectTypeEnum.Damage_2
            or (
                (effect.Effect == EffectTypeEnum.DoT or effect.Effect == EffectTypeEnum.Reflect or effect.Effect == EffectTypeEnum.Reflect_2)
                and isAppliedBuff == true
            )
end

function Unit:new(blizzardUnitInfo)
    local newObj = {
        -- use for unusual attack only, blizz dont store combatantID in mission's tables
        ID = blizzardUnitInfo.garrFollowerID ~= nil and blizzardUnitInfo.garrFollowerID
                or blizzardUnitInfo.portraitFileDataID or blizzardUnitInfo.portraitIconID,
        followerGUID = blizzardUnitInfo.followerGUID,
        name = blizzardUnitInfo.name,
        maxHealth = blizzardUnitInfo.maxHealth,
        currentHealth = blizzardUnitInfo.health,
        attack = blizzardUnitInfo.attack,
        isAutoTroop = blizzardUnitInfo.isAutoTroop,
        boardIndex = blizzardUnitInfo.boardIndex,
        role = blizzardUnitInfo.role,
        tauntedBy = nil,
        untargetable = false,
        reflect = 0,
        isLoseLvlUp = blizzardUnitInfo.isLoseLvlUp,
        isWinLvlUp = blizzardUnitInfo.isWinLvlUp,
        buffs = {}
    }

    self.__index = self
    setmetatable(newObj, self)
    newObj:setSpells(blizzardUnitInfo.autoCombatSpells)


    return newObj
end

function Unit:getAttackType()
    if CMH.DataTables.UnusualAttackType[self.ID] ~= nil then
        return CMH.DataTables.UnusualAttackType[self.ID]
    elseif self.role == 1 or self.role == 5 then -- melee and tank
        return 11
    else
        return 15
    end
end

function Unit:setSpells(autoCombatSpells)
    self.spells = {}
    -- auto attack is spell
    local autoAttack = {
        autoCombatSpellID = self:getAttackType(),
        name = 'Auto Attack',
        duration = 0,
        cooldown = 0,
        flags = 0
    }
    local autoAttackSpell = CMH.Spell:new(autoAttack)
    table.insert(self.spells, autoAttackSpell)

    for _, autoCombatSpell in pairs(autoCombatSpells) do
        --broken spells
        if autoCombatSpell.autoCombatSpellID ~= 91 and autoCombatSpell.autoCombatSpellID ~= 109 and autoCombatSpell.autoCombatSpellID ~= 122 then
            table.insert(self.spells, CMH.Spell:new(autoCombatSpell))
        end
    end
end

function Unit:isAlive()
    return self.currentHealth > 0
end

function Unit:getEffectBaseValue(effect)
    --isn't work in game
    if effect.Effect == EffectTypeEnum.DamageDealtMultiplier then
        return 0
    elseif effect.Effect == EffectTypeEnum.DamageDealtMultiplier_2
            or effect.Effect == EffectTypeEnum.DamageTakenMultiplier
            or effect.Effect == EffectTypeEnum.DamageTakenMultiplier_2
            or effect.Effect == EffectTypeEnum.Reflect then
                return effect.Points
    elseif effect.Flags == 1 or effect.Flags == 3 then
        return math.floor(effect.Points * self.attack)
    else
        return effect.Points
    end
end

function Unit:calculateEffectValue(targetUnit, effect)
    local value
    if effect.Effect == EffectTypeEnum.Reflect or effect.Effect == EffectTypeEnum.Reflect_2 then
        value = self.reflect
    elseif effect.Flags == 0 or effect.Flags == 2 then
        value = math.floor(effect.Points * targetUnit.maxHealth)
    else
        value = math.floor(effect.Points * self.attack)
    end

    if isDamageEffect(effect, true) then
        local multiplier, positive_multiplier = self:getDamageMultiplier(targetUnit)
        value = multiplier * (value + self:getAdditionalDamage(targetUnit))
    end

    return math.max(math.floor(value + .00000000001), 0)
end

function Unit:manageDoTHoT(sourceUnit, buff, isInitialPeriod)
    if isInitialPeriod == nil then isInitialPeriod = false end
    --CMH:log(string.format('sourceUnit = %s, duration = %s, period = %s',
      --          tostring(sourceUnit.boardIndex), tostring(buff.duration), tostring(buff.currentPeriod)))
    if (buff.Effect == EffectTypeEnum.DoT or buff.Effect == EffectTypeEnum.HoT) and (buff.currentPeriod == 0 or isInitialPeriod) then
        sourceUnit:castSpellEffect(self, buff, {}, true)
    end
end

function Unit:applyBuff(targetUnit, effect, effectBaseValue, duration, name)
    table.insert(targetUnit.buffs, CMH.Buff:new(effect, effectBaseValue, self.boardIndex, duration, name))
    if effect.Effect == EffectTypeEnum.Taunt then
        targetUnit.tauntedBy = self.boardIndex
    elseif effect.Effect == EffectTypeEnum.Untargetable then
        targetUnit.untargetable = true
    elseif effect.Effect == EffectTypeEnum.Reflect or effect.Effect == EffectTypeEnum.Reflect_2 then
        targetUnit.reflect = effectBaseValue
    end

    -- extra initial period
    if effect.Flags == 2 or effect.Flags == 3 then
        targetUnit:manageDoTHoT(self, effect, true)
    end
end

function Unit:getDamageMultiplier(targetUnit)
    local buffs = {}
    local multiplier, positive_multiplier = 1, 1
    for _, buff in pairs(self.buffs) do
        if buff.Effect == EffectTypeEnum.DamageDealtMultiplier or buff.Effect == EffectTypeEnum.DamageDealtMultiplier_2 then
            CMH:debug_log(string.format('self buff. effect = %s, baseValue = %s, spellID = %s, source = %s ',
                    CMH.DataTables.EffectType[buff.Effect], buff.baseValue, buff.SpellID, buff.sourceIndex))
            if buffs[buff.SpellID] == nil then
                buffs[buff.SpellID] = buff.baseValue
            else
                buffs[buff.SpellID] = buffs[buff.SpellID] + buff.baseValue
            end
        end
    end

    for _, buff in pairs(targetUnit.buffs) do
        if buff.Effect == EffectTypeEnum.DamageTakenMultiplier or buff.Effect == EffectTypeEnum.DamageTakenMultiplier_2 then
            CMH:debug_log('target buff ' .. CMH.DataTables.EffectType[buff.Effect] .. ' ' .. buff.baseValue)
            if buffs[buff.SpellID] == nil then
                buffs[buff.SpellID] = buff.baseValue
            else
                buffs[buff.SpellID] = buffs[buff.SpellID] + buff.baseValue
            end
        end
    end

    for _, value in pairs(buffs) do
        multiplier = multiplier * (1 + value)
        if value > 0 then positive_multiplier = positive_multiplier * (1 + value) end
    end

    if multiplier ~= 1 then CMH:debug_log('damage multiplier = ' .. multiplier .. ' pos. multiplier = ' .. positive_multiplier) end
    return math.max(multiplier, 0), positive_multiplier
end

function Unit:getAdditionalDamage(targetUnit)
    local result = 0
    for _, buff in pairs(self.buffs) do
        if buff.Effect == EffectTypeEnum.AdditionalDamageDealt then
            result = result + buff.baseValue
        end
    end

    for _, buff in pairs(targetUnit.buffs) do
        if buff.Effect == EffectTypeEnum.AdditionalTakenDamage then
            result = result + buff.baseValue
        end
    end
    if result ~= 0 then CMH:debug_log('additional damage = ' .. result) end
    return result
end

function Unit:castSpellEffect(targetUnit, effect, spell, isAppliedBuff)
    local oldTargetHP = targetUnit.currentHealth
    local value = 0
    local color = (isAppliedBuff == false and spell:isAutoAttack()) and '00FFFFFF' or '0066CCFF'

    -- deal damage
    if isDamageEffect(effect, isAppliedBuff) then
        value = self:calculateEffectValue(targetUnit, effect)
        targetUnit.currentHealth = math.max(0, targetUnit.currentHealth - value)
        CMH:log(string.format('|c%s%s %s %s for %s. (HP %s -> %s)|r',
            color, self.name, EffectType[effect.Effect], targetUnit.name, value, oldTargetHP, targetUnit.currentHealth))

    -- heal
    elseif effect.Effect == EffectTypeEnum.Heal or effect.Effect == EffectTypeEnum.Heal_2
            or (effect.Effect == EffectTypeEnum.HoT and isAppliedBuff == true) then
        value = self:calculateEffectValue(targetUnit, effect)
        targetUnit.currentHealth = math.min(targetUnit.maxHealth, targetUnit.currentHealth + value)
        CMH:log(string.format('|c%s%s %s %s for %s. (HP %s -> %s)|r',
            color, self.name, EffectType[effect.Effect], targetUnit.name, value, oldTargetHP, targetUnit.currentHealth))

    -- Maximum health multiplier
    elseif effect.Effect == EffectTypeEnum.MaxHPMultiplier then
        value = self:calculateEffectValue(targetUnit, effect)
        targetUnit.maxHealth = targetUnit.maxHealth + value
        CMH:log(string.format('|c%s%s %s %s for %s|r',
            color, self.name, EffectType[effect.Effect], targetUnit.name, value))
    else
        value = self:getEffectBaseValue(effect)
        self:applyBuff(targetUnit, effect, value, spell.duration, spell.name)
        CMH:log(string.format('|c%s%s %s %s (%s)|r',
            color, self.name, 'apply ' .. EffectType[effect.Effect], targetUnit.name, value))
    end

    return {
        boardIndex = targetUnit.boardIndex,
        maxHealth = targetUnit.maxHealth,
        oldHealth = oldTargetHP,
        newHealth = targetUnit.currentHealth,
        points = value
    }
end

function Unit:getAvailableSpells()
    -- Return autoAttack's and all spell's effects
    local result = {}

    for _, spell in pairs(self.spells) do
        if spell:isAvailable() then table.insert(result, spell) end
    end

    return result
end

function Unit:startSpellCooldown(spellID)
    --CMH:log('Start Cooldown. SpellID = ' .. spellID .. '. name = ' .. type(spellID))
    for _, spell in ipairs(self.spells) do
        if spell.ID == spellID then
            spell:startCooldown()
            break
        end
    end
end

function Unit:decreaseSpellsCooldown()
    for _, spell in pairs(self.spells) do spell:decreaseCooldown() end
end

function Unit:manageBuffs(sourceUnit)
    local i = 1
    local removed_buffs = {}
    --if #self.buffs > 0 then CMH:debug_log('unit = ' .. self.boardIndex .. ' buffs = ' .. #self.buffs) end
    while i <= #self.buffs do
        local buff = self.buffs[i]
        if buff.sourceIndex == sourceUnit.boardIndex then
            CMH:debug_log('targetUnit = ' .. self.boardIndex ..
                    ' buff effect = ' .. buff.Effect .. ' duration = ' .. tostring(buff.duration) ..
                    ' period = ' .. tostring(buff.currentPeriod))
            self:manageDoTHoT(sourceUnit, buff, false)
            buff:decreaseRestTime()
        end

        if buff.sourceIndex == sourceUnit.boardIndex and buff.duration == 0 then
            table.insert(removed_buffs, {
                buff = buff,
                targetBoardIndex = self.boardIndex,
            })
            CMH:log(string.format('|c000088CC%s remove %s from %s|r',
                    tostring(sourceUnit.name), tostring(buff.name), tostring(self.name)))
            table.remove(self.buffs, i)
            if buff.Effect == EffectTypeEnum.Taunt then
                self.tauntedBy = nil
            elseif buff.Effect == EffectTypeEnum.Untargetable then
                self.untargetable = false
            elseif buff.Effect == EffectTypeEnum.Reflect or buff.Effect == EffectTypeEnum.Reflect_2 then
                self.reflect = 0
            end
        else
            i = i + 1
        end
    end

    return removed_buffs
end

CMH.Unit = Unit
