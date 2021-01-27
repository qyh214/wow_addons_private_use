CovenantMissionHelper, CMH = ...

local BlizzEventType, EffectType = Enum.GarrAutoMissionEventType, CMH.DataTables.EffectTypeEnum
local CombatLogEvents = {}


local function getBlizzardEventType(effectType, spellID)
    if spellID == 11 then
        return BlizzEventType.MeleeDamage -- 0
    elseif spellID == 15 then
        return BlizzEventType.RangeDamage -- 1
    elseif effectType == EffectType.Damage or effectType == EffectType.Damage_2 then
        return BlizzEventType.SpellMeleeDamage -- or EventType.SpellRangeDamage?  2
    elseif effectType == EffectType.DoT then
        return BlizzEventType.PeriodicDamage -- 5
    elseif effectType == EffectType.Heal or effectType == EffectType.Heal_2 then
        return BlizzEventType.Heal -- 4
    elseif effectType == EffectType.HoT then
        return BlizzEventType.PeriodicHeal -- 6
    elseif effectType == EffectType.Died then
        return BlizzEventType.Died -- 9
    elseif effectType == EffectType.RemoveAura then
        return BlizzEventType.RemoveAura -- 8
    else
        return BlizzEventType.ApplyAura -- 7
    end
end


function MissionHelper:addRound()
    table.insert(CombatLogEvents, {events = {}})
    --print('round ' .. #CombatLogEvents)
end

function MissionHelper:addEvent(spellID, effectType, casterBoardIndex, targetInfo)
    table.insert(CombatLogEvents[#CombatLogEvents].events, {
                casterBoardIndex = casterBoardIndex,
                spellID = spellID,
                type = getBlizzardEventType(effectType, spellID),
                targetInfo = targetInfo
            })
    --print('event ' .. #CombatLogEvents[#CombatLogEvents].events)
end

CMH.Board.CombatLogEvents = CombatLogEvents
