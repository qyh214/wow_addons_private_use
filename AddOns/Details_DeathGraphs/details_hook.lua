
local addonId, advancedDeathLogs = ...
local Details = Details
local detailsFramework = DetailsFramework
local _
local GameCooltip = GameCooltip
local unpack = unpack

function advancedDeathLogs.RegisterDetailsHook()
    hooksecurefunc(Details, "ShowDeathTooltipFunction", function(instance, lineFrame, combatObject, deathTable)
        --in cases where the deathTable is from a copy, e.g. Overall Data, the cooldown_usage might not be available
        if (not deathTable.cooldown_usage) then
            return
        end

        local timeOfDeath = deathTable[2]
        local gameCooltip = GameCooltip
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

        gameCooltip:AddLine("Cooldown Received:", "", 2, "white")
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

        gameCooltip:AddLine("Cooldown Status:", "", 2, "white")
        gameCooltip:AddIcon("", 2, 1, 2, 2, .1, .9, .1, .9)

        for spellId, cooldownInfo in pairs(deathTable.cooldown_status) do
            local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
            spellName = spellName:sub(1, 24)

            local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
            if (openRaidLib) then
                local timeLeft, charges, timeOffset, duration, updateTime = openRaidLib.GetCooldownTimeFromCooldownInfo(cooldownInfo)
                if (timeLeft == 0) then
                    gameCooltip:AddLine(spellName, "|cFF11FF11good|r", 2, "white")
                    gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
                else
                    gameCooltip:AddLine(spellName, "-" .. detailsFramework:IntegerToTimer(timeLeft), 2, "white")
                    gameCooltip:AddIcon(spellIcon, 2, 1, 16, 16, .1, .9, .1, .9)
                end
            end
        end

        gameCooltip:SetOption("FixedWidthSub", 200)
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