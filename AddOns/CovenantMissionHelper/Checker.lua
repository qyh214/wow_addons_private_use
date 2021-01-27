CovenantMissionHelper, CMH = ...
local MissionHelper = _G["MissionHelper"]

local eventFields = {"casterBoardIndex", "spellID", "type"}
local targetFields = {"boardIndex", "maxHealth", "oldHealth", "newHealth", "points"}


function MissionHelper:compareLogs(myLog, blizzLog)
    local checks = {}
    checks["equalsRoundCount"] = (#myLog == #blizzLog)
    for round = 1, math.min(#myLog, #blizzLog) do
        local roundTable = {}
        checks["round" .. round] = roundTable
        roundTable["equalsEventCount"] = (#myLog[round].events == #blizzLog[round].events)

        for event = 1, math.min(#myLog[round].events, #blizzLog[round].events) do
            local eventTable = {}
            roundTable["event" .. event] = eventTable
            local myEvent, blizzEvent = myLog[round].events[event], blizzLog[round].events[event]
            eventTable["equalsTargetCount"] = (#myEvent.targetInfo == #blizzEvent.targetInfo)
            eventTable["equalsCasterBoardIndex"] = (myEvent.casterBoardIndex == blizzEvent.casterBoardIndex)
            eventTable["equalsSpellID"] = (myEvent.spellID == blizzEvent.spellID)

            -- I'm not differ melee spell and range spell. It actually doesn't matter.
            if (myEvent.type == Enum.GarrAutoMissionEventType.SpellMeleeDamage) or (myEvent.type == Enum.GarrAutoMissionEventType.SpellRangeDamage) then
                eventTable["equalsType"] = (blizzEvent.type == Enum.GarrAutoMissionEventType.SpellMeleeDamage or blizzEvent.type == Enum.GarrAutoMissionEventType.SpellRangeDamage)
            -- TODO: Check carefully and fix it. Now just ignore that
            elseif (myEvent.type == Enum.GarrAutoMissionEventType.PeriodicDamage or myEvent.type == Enum.GarrAutoMissionEventType.PeriodicHeal)
                    and blizzEvent.type == Enum.GarrAutoMissionEventType.ApplyAura then
                eventTable["equalsType"] = true
            -- TODO: Check carefully and fix it. Now just ignore that
            elseif (blizzEvent.type == Enum.GarrAutoMissionEventType.PeriodicDamage or blizzEvent.type == Enum.GarrAutoMissionEventType.PeriodicHeal)
                    and myEvent.type == Enum.GarrAutoMissionEventType.ApplyAura then
                eventTable["equalsType"] = true
            else
                eventTable["equalsType"] = (myEvent.type == blizzEvent.type)
            end

            for _, field in pairs(eventFields) do
                eventTable[field] = (myEvent[field] == blizzEvent[field]) and myEvent[field] or tostring(myEvent[field]) .. '|' .. tostring(blizzEvent[field])
            end

            --print(string.format('%s, %s'), round, event)
            for target = 1, math.min(#myEvent.targetInfo, #blizzEvent.targetInfo) do
                local target_table = {}
                eventTable["target" .. target] = target_table
                local myTarget, blizzTarget = myEvent.targetInfo[target], blizzEvent.targetInfo[target]
                target_table["equalsBoardIndex"] = (myTarget.boardIndex == blizzTarget.boardIndex)
                -- blizz may not save maxHP
                target_table["equalsMaxHealth"] = ((myTarget.maxHealth == blizzTarget.maxHealth) or (myTarget.maxHealth ~= 0 and blizzTarget.maxHealth == 0))
                target_table["equalsOldHealth"] = (myTarget.oldHealth == blizzTarget.oldHealth)
                target_table["equalsNewHealth"] = (myTarget.newHealth == blizzTarget.newHealth)

                -- blizzard don't save aura's points, but I do.
                if myEvent.type == Enum.GarrAutoMissionEventType.ApplyAura and blizzEvent.type == Enum.GarrAutoMissionEventType.ApplyAura and blizzTarget.points == nil then
                    target_table["equalsPoints"] = true
                else
                    target_table["equalsPoints"] = (myTarget.points == blizzTarget.points)
                end

                for _, field in pairs(targetFields) do
                    target_table[field] = (myTarget[field] == blizzTarget[field]) and myTarget[field] or tostring(myTarget[field]) .. '|' .. tostring(blizzTarget[field])
                end

                eventTable["equalsTarget" .. target] = target_table["equalsBoardIndex"] and target_table["equalsBoardIndex"]
                        and target_table["equalsMaxHealth"] and target_table["equalsOldHealth"] and target_table["equalsNewHealth"] and target_table["equalsPoints"]
            end

            if #myEvent.targetInfo < #blizzEvent.targetInfo then
                for i = #myEvent.targetInfo + 1, #blizzEvent.targetInfo do eventTable['BlizzTarget' .. i] = blizzEvent.targetInfo[i] end
            elseif #myEvent.targetInfo > #blizzEvent.targetInfo then
                for i = #blizzEvent.targetInfo + 1, #myEvent.targetInfo do eventTable['MyTarget' .. i] = myEvent.targetInfo[i] end
            end
        end

        if #myLog[round].events < #blizzLog[round].events then
                for i = #myLog[round].events + 1, #blizzLog[round].events do roundTable['BlizzEvent' .. i] = blizzLog[round].events[i] end
            elseif #myLog[round].events > #blizzLog[round].events then
                for i = #blizzLog[round].events + 1, #myLog[round].events do roundTable['MyEvent' .. i] = myLog[round].events[i] end
            end

    end

    return checks
end

--[[
function MissionHelper:showFalseValueOnly(tbl, path)
    path = path or '/'
    for i = 1, #tbl do
        if type(tbl[i]) == 'bool' and tbl[i] == false then

        end
    end
end
--]]
