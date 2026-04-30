local appName, app = ...
---@class AbilityTimeline
local private = app
private.sheduledReminders = {}

private.createReminders = function(encounterID)
    local reminders = private.db.profile.reminders and private.db.profile.reminders[encounterID] or {}
    table.sort(reminders, function(a, b)
        return (a.CombatTime or 0) < (b.CombatTime or 0)
    end)

    for _, reminder in ipairs(reminders) do
        local duration = tonumber(reminder.CombatTime) or 0
        local delay = tonumber(reminder.CombatTimeDelay) or 0
        local spellId = reminder.spellId or 0
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        local spellName = spellInfo and spellInfo.name
        local icon = spellInfo and spellInfo.iconID
        if reminder.StartTimerAfter and reminder.StartTimerAfter > 0 then
            local eventinfo = {
                duration = duration - reminder.StartTimerAfter,
                maxQueueDuration = delay,
                overrideName = reminder.name or reminder.spellName or spellName,
                spellID = spellId,
                iconFileID = reminder.iconId or icon or 134400,
                severity = reminder.severity or 1,
                paused = false,
                icons = reminder.effectTypes,
            }
            local timerObject = C_Timer.NewTimer(reminder.StartTimerAfter, function()
                C_EncounterTimeline.AddScriptEvent(eventinfo)
            end)
            table.insert(private.sheduledReminders, timerObject)
        else
            local eventinfo = {
                duration = duration,
                maxQueueDuration = delay,
                overrideName = reminder.name or reminder.spellName or spellName,
                spellID = spellId,
                iconFileID = reminder.iconId or icon or 134400,
                severity = reminder.severity or 1,
                paused = false,
                icons = reminder.effectTypes,
            }
            C_EncounterTimeline.AddScriptEvent(eventinfo)
        end
    end
end

private.cancelSheduledReminders = function()
    for _, timerObject in ipairs(private.sheduledReminders) do
        if timerObject and timerObject.Cancel then
            timerObject:Cancel()
        end
    end
    private.sheduledReminders = {}
end
