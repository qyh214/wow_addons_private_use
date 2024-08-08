
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local _
local GameCooltip = GameCooltip
local unpack = unpack

local GetSpellInfo = GetSpellInfo or function(...)
    local result = C_Spell.GetSpellInfo(...)
    if result then
        return result.name, 1, result.iconID
    end
end

function advancedDeathLogs.RegisterDetailsHook()
    hooksecurefunc(Details, "ShowDeathTooltipFunction", function(instance, lineFrame, combatObject, deathTable)
        --in cases where the deathTable is from a copy, e.g. Overall Data, the cooldown_usage might not be available
        if (not deathTable.cooldown_usage) then
            return
        end

        local deathEvents = deathTable[1]
        local timeOfDeath = deathTable[2]
        local gameCooltip = GameCooltip

        local causeOfDeath = {}

        for i = 1, #deathEvents do
            local event = deathEvents[i]
            local evType = event[1]

            --check if this death event is a debuff or if a enemy spell cast
            if (type(evType) == "number" and (evType == 4 or evType == 6)) then
                local spellId = event[2]
                local source = Details:GetOnlyName(event[6] or "")
                local amountOfDamage = event[3]

                --findsubtable arguments: table, index of the sub table, any value to find on that index in the sub table
                local alreadyExistsOnIndex = detailsFramework.table.findsubtable(causeOfDeath, 1, spellId)
                if (alreadyExistsOnIndex) then
                    causeOfDeath[alreadyExistsOnIndex][2] = causeOfDeath[alreadyExistsOnIndex][2] + amountOfDamage
                else
                    causeOfDeath[#causeOfDeath+1] = {spellId, amountOfDamage, source}
                end
            end

            if (type(evType) == "boolean" and evType == true) then
                --this is a damage event
                local spellId = event[2]
                if (spellId ~= 1) then
                    local amountOfDamage = event[3]
                    local source = Details:GetOnlyName(event[6] or "")

                    --findsubtable arguments: table, index of the sub table, any value to find on that index in the sub table
                    local alreadyExistsOnIndex = detailsFramework.table.findsubtable(causeOfDeath, 1, spellId)
                    if (alreadyExistsOnIndex) then
                        causeOfDeath[alreadyExistsOnIndex][2] = causeOfDeath[alreadyExistsOnIndex][2] + amountOfDamage
                    else
                        causeOfDeath[#causeOfDeath+1] = {spellId, amountOfDamage, source}
                    end
                end
            end
        end

        table.sort(causeOfDeath, function(a, b)
            return a[2] > b[2]
        end)

        gameCooltip:AddLine("Spell Description:", "", 2, "yellow", "white", 14)
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)

        local alreadyAddedToDeathCause = {}
        for i = 1, 5 do
            if (causeOfDeath[i]) then
                local spellId, amountOfDamage, source = unpack(causeOfDeath[i] or {})
                local spellName, spellRank, spellIcon, castTime, minRange, maxRange = GetSpellInfo(spellId)

                if (not alreadyAddedToDeathCause[spellId] and not alreadyAddedToDeathCause[spellName]) then
                    alreadyAddedToDeathCause[spellId] = true
                    alreadyAddedToDeathCause[spellName] = true

                    local GetSpellDescription = C_Spell and C_Spell.GetSpellDescription or GetSpellDescription
                    local spellDescription = GetSpellDescription(spellId)

                    if (spellDescription == "" and spellId ~= 149356) then
                        spellDescription = _G.SEARCH_LOADING_TEXT
                    end

                    gameCooltip:AddLine(spellName, "", 2, 1, 1, 1, 1, 1, 1, 1, 1, 12)
                    gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)

                    --two problems: 1) the spell description isn't breaking into a second line, 2) spell icon isn't showing in the second spell name line
                    --solved the problem 1) by adding a fixed width and height size to the text added with AddLine
                    --solved the problem 2) by adding an icon to each line

                    gameCooltip:AddLine(spellDescription, nil, 2, 1, 1, 1, 1, 1, 1, 1, 1, 10, nil, nil, 190, 90)
                    gameCooltip:AddIcon("", 2, 1, 1, 1, .1, .9, .1, .9)

                    gameCooltip:AddLine("", "", 2, "white")
                    gameCooltip:AddIcon("", 2, 1, 4, 4, .1, .9, .1, .9)
                end
            end
        end

        --[=[
        gameCooltip:AddLine("Used Before Death:", "", 2, "white")
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)

        for spellId, cdTime in pairs(deathTable.cooldown_usage) do
            local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
            local timeOfUse = math.floor(timeOfDeath - cdTime)
            if (timeOfUse < 0 and timeOfUse > -60) then
                gameCooltip:AddLine(spellName, detailsFramework:IntegerToTimer(timeOfUse) .. "s", 2, "white")
                gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
            end
        end

        gameCooltip:AddLine(" ", "", 2, "white")
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)
        --]=]

        gameCooltip:AddLine("", "", 2)
        gameCooltip:AddIcon("", 2, 1)

        gameCooltip:AddLine("Cooldown Received:", "", 2, "yellow", "white", 14)
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)
        local cooldownsReceived = deathTable["cooldown_received"] or {}

        for i = 1, #cooldownsReceived do
            local spellId, time, sourceName = unpack(cooldownsReceived[i])
            local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
            local timeOfUseBeforeDeath = math.floor(time - timeOfDeath)

            if (timeOfUseBeforeDeath < 0 and timeOfUseBeforeDeath > -60) then
                spellName = spellName:sub(1, 12)
                sourceName = detailsFramework:RemoveRealmName(sourceName):sub(1, 10)
                local name = spellName .. " (" .. sourceName .. ")"
                gameCooltip:AddLine(name, timeOfUseBeforeDeath .. "s", 2, "white")
                gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
            end
        end

        gameCooltip:AddLine(" ", "", 2, "white")
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)

        gameCooltip:AddLine("Cooldown Status:", "", 2, "yellow", "white", 14)
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)

        for spellId, cooldownInfo in pairs(deathTable.cooldown_status) do
            local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
            spellName = spellName:sub(1, 24)

            local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
            if (openRaidLib) then
                local timeLeft, charges, timeOffset, duration, updateTime = openRaidLib.GetCooldownTimeFromCooldownInfo(cooldownInfo)
                if (timeLeft == 0) then
                    gameCooltip:AddLine(spellName, "|cFF11FF11was ready|r", 2, "white")
                    gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
                else
                    gameCooltip:AddLine(spellName, "-" .. detailsFramework:IntegerToTimer(timeLeft), 2, "white")
                    gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
                end
            end
        end

        gameCooltip:SetOption("FixedWidthSub", 210)
    end)

    -------------------------------------------------------------------------
    --cooldown state and usage history

    local cdTracker = {
        Cooldowns = {
            Usage = {},
            Received = {},
        }
    }

    function cdTracker.Cooldowns.RegisterCooldownUsage()
        cdTracker.Cooldowns.Usage = {} --will store [unitName] = {spellId = time, spellId = time, spellId = time}
        local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true, true)
        if (openRaidLib) then
            function cdTracker.Cooldowns.OnReceiveSingleCooldownUpdate(unitId, spellId, cooldownInfo, unitCooldows, allUnitsCooldowns)
                local unitName = GetUnitName(unitId, true)
                if (not unitName) then
                    return
                end

                --if details! isn't in combat, return
                if (not Details.in_combat) then
                    return
                end

                --local bIsReady, percent, timeLeft, charges, minValue, maxValue, currentValue, duration = openRaidLib.GetCooldownStatusFromCooldownInfo(cooldownInfo)

                --add the cooldown used into the table
                cdTracker.Cooldowns.Usage[unitName] = cdTracker.Cooldowns.Usage[unitName] or {}
                cdTracker.Cooldowns.Usage[unitName][spellId] = time()
            end

            --register a callback to be notified when a cooldown is used
            openRaidLib.RegisterCallback(cdTracker.Cooldowns, "CooldownUpdate", "OnReceiveSingleCooldownUpdate")
        end
    end

    local cooldownListener = Details:CreateEventListener()
    cdTracker.Cooldowns.RegisterCooldownUsage()

    function cooldownListener:WipeCooldownUsage()
        wipe(cdTracker.Cooldowns.Usage)
        wipe(cdTracker.Cooldowns.Received)
    end

    cooldownListener:RegisterEvent("GROUP_ONENTER", "WipeCooldownUsage")
    cooldownListener:RegisterEvent("GROUP_ONLEAVE", "WipeCooldownUsage")
    cooldownListener:RegisterEvent("COMBAT_ENCOUNTER_START", "WipeCooldownUsage")
    cooldownListener:RegisterEvent("COMBAT_ENCOUNTER_END", "WipeCooldownUsage")

    local onDeathEvent = function(_, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, deathTable, lastCooldown, combatElapsedTime, maxHealth)
        local cooldownUsage = {}

        local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
        if (openRaidLib) then
            local unitCooldowns = openRaidLib.GetUnitCooldowns(targetName, "defensive-personal,defensive-raid,itemheal")
            cooldownUsage = cdTracker.Cooldowns.Usage[targetName] or {}

            deathTable["cooldown_usage"] = cooldownUsage --list of cooldowns the player used before dying
            deathTable["cooldown_status"] = unitCooldowns --list of cooldowns the player had when died

            local targetedPersonalCooldowns = {}
            local cooldownsReceived = cdTracker.Cooldowns.Received[targetName] or {}
            for i = 1, #cooldownsReceived do
                local spellId, thisTime = unpack(cooldownsReceived[i])
                if (time - 20 < thisTime) then
                    targetedPersonalCooldowns[#targetedPersonalCooldowns+1] = cooldownsReceived[i]
                end
            end
            deathTable["cooldown_received"] = targetedPersonalCooldowns --list of cooldowns received from other players
        end
    end

    local onCooldownEvent = function(_, token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, spellId, spellName)
        if (sourceSerial and targetSerial) then
            if (sourceName and targetName) then
                local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
                if (openRaidLib) then
                    local cooldownData = LIB_OPEN_RAID_COOLDOWNS_INFO[spellId]
                    if (cooldownData and cooldownData.type == 3) then
                        --this is a defensive cooldown
                        cdTracker.Cooldowns.Received[targetName] = cdTracker.Cooldowns.Received[targetName] or {}
                        table.insert(cdTracker.Cooldowns.Received[targetName], {spellId, time, sourceName})
                    end
                end
            end
        end
    end

    Details:InstallHook(DETAILS_HOOK_DEATH, onDeathEvent)
    Details:InstallHook(DETAILS_HOOK_COOLDOWN, onCooldownEvent)
end