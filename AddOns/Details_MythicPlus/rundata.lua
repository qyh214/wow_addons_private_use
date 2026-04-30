
--this file is responsable to copy the necessary data from a details! combat into an object that can be used by the addon
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon
local _ = nil
local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)

local CONST_MAX_DEATH_EVENTS = 3
local CONST_LAST_RUN_TIMEOUT = 5 * 60

---@alias playername string

--primaryAffix seens to not exists
--local dungeonName, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengemodecompletioninfo.mapChallengeModeID)

function addon.WipeLikeCache()
    table.wipe(addon.recentLikes)
    for i = 1, #addon.LikesAmountFontString do
        addon.LikesAmountFontString[i]:SetText("0")
        addon.LikesAmountFontString[i].amount = 0
    end
end

---runs on details! event COMBAT_MYTHICPLUS_OVERALL_READY
function addon.CreateRunInfo(mythicPlusOverallSegment)
    local completionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
    if (completionInfo.mapChallengeModeID == 0) then
        private.log("MythicPlus Scoreboard M+ Missing completionInfo.mapChallengeModeID, possibly due to and error or reload after the key completed")
        return
    end

    local combatTime = mythicPlusOverallSegment:GetCombatTime()

    addon.WipeLikeCache()

    --debug
    if (not addon.profile.last_run_data.encounter_timeline) then
        print("MythicPlus Scoreboard M+ addon.profile.last_run_data.encounter_timeline is nil")
        private.log("MythicPlus Scoreboard M+ addon.profile.last_run_data.encounter_timeline is nil")
    end

    if (not addon.profile.last_run_data.incombat_timeline) then
        print("MythicPlus Scoreboard M+ addon.profile.last_run_data.incombat_timeline is nil")
        private.log("MythicPlus Scoreboard M+ addon.profile.last_run_data.incombat_timeline is nil")
    end

    addon.profile.last_run_id = addon.profile.last_run_id + 1

    ---@type runinfo
    local runInfo = {
        runId = addon.profile.last_run_id,
        seasonId = addon.GetCurrentSeasonId(),
        combatId = mythicPlusOverallSegment:GetCombatUID(),
        combatData = {
            groupMembers = {} --done
        },
        completionInfo = { --done
            mapChallengeModeID = completionInfo.mapChallengeModeID,
            level = completionInfo.level,
            time = completionInfo.time,
            onTime = completionInfo.onTime,
            keystoneUpgradeLevels = completionInfo.keystoneUpgradeLevels,
            practiceRun = completionInfo.practiceRun,
            oldOverallDungeonScore = completionInfo.oldOverallDungeonScore,
            newOverallDungeonScore = completionInfo.newOverallDungeonScore,
            isEligibleForScore = completionInfo.isEligibleForScore,
            isMapRecord = completionInfo.isMapRecord,
            isAffixRecord = completionInfo.isAffixRecord,
            members = completionInfo.members,
        },
        encounters = detailsFramework.table.copy({}, addon.profile.last_run_data.encounter_timeline),
        combatTimeline = detailsFramework.table.copy({}, addon.profile.last_run_data.incombat_timeline),
        timeInCombat = combatTime,
        timeWithoutDeaths = 0,
        dungeonName = "", --done
        dungeonId = 0, --done
        instanceId = select(8, GetInstanceInfo()),
        dungeonTexture = 0, --done
        dungeonBackgroundTexture = 0, --done
        timeLimit = 0, --done
        startTime = addon.profile.last_run_data.start_time,
        endTime = time(),
        timeLostToDeaths = addon.profile.last_run_data.time_lost_to_deaths,
        mapId = completionInfo.mapChallengeModeID or addon.profile.last_run_data.map_id,
        reloaded = addon.profile.last_run_data.reloaded,
    }

    local dungeonName, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(runInfo.mapId)
    runInfo.dungeonName = dungeonName
    runInfo.dungeonId = id
    runInfo.mapId = id
    runInfo.timeLimit = timeLimit
    runInfo.dungeonTexture = texture
    runInfo.dungeonBackgroundTexture = backgroundTexture

    local damageContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_DAMAGE or 1)
    local healingContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_HEAL or 2)
    local utilityContainer = mythicPlusOverallSegment:GetContainer(DETAILS_ATTRIBUTE_MISC or 4)

    for _, actorObject in damageContainer:ListActors() do
        ---@cast actorObject actordamage

        if (actorObject:IsPlayer() and actorObject:Class() ~= "UNGROUPPLAYER") then
            local unitName = actorObject:Name()
            local damageTakenFromSpells = {}
            for i, damageTaken in pairs(mythicPlusOverallSegment:GetDamageTakenBySpells(unitName)) do
                if (i > 7) then
                    break
                end
                table.insert(damageTakenFromSpells, damageTaken)
            end

            local avoidableDamageTakenFromSpells = {}
            for _, spellTable in pairs(actorObject.spells_damage_avoidable._ActorTable) do
            	table.insert(avoidableDamageTakenFromSpells, spellTable)
            end
            table.sort(avoidableDamageTakenFromSpells, function(a, b) return a.total > b.total end)

            local guid = actorObject:GetGUID()

			local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitName)
			local currentScore = summary and summary.currentSeasonScore
			local previousScore = addon.profile.last_run_data.player_ratings[unitName] or 0

			if (previousScore == 0 and currentScore > 450) then
				-- in case there's an issue and the actual score is incorrectly set to 0
				-- it'll show "1530" instead of "1530 (+1530)"
				previousScore = currentScore
			end

            ---@type playerinfo
            local playerInfo = {
                name = unitName,
                class = actorObject:Class(),
                spec = private.Details:GetSpecFromSerial(guid) or actorObject:Spec() or 0,
                role = UnitGroupRolesAssigned(unitName) or "DAMAGER",
                guid = guid,
                loot = "",
                score = 0,
                playerOwns = UnitIsUnit(unitName, "player"),
                activityTimeDamage = 0,
                activityTimeHeal = 0,
                totalDeaths = 0,
                totalDamage = actorObject.total,
                totalHeal = 0,
                totalDamageTaken = actorObject.damage_taken,
                totalAvoidableDamageTaken = actorObject.damage_taken_avoidable,
                totalHealTaken = 0,
                totalDispels = 0,
                totalInterrupts = 0,
                totalInterruptsCasts = 0,
                totalCrowdControlCasts = 0,
                healDoneBySpells = {}, --done
                damageTakenFromSpells = damageTakenFromSpells,
                avoidableDamageTakenFromSpells = avoidableDamageTakenFromSpells,
                damageDoneBySpells = {}, --done
                dispelWhat = {}, --done
                interruptWhat = {}, --done
                interruptCastOverlapDone = addon.profile.last_run_data.interrupt_cast_overlap_done[unitName] or 0,
                crowdControlSpells = {}, --done
                ilevel = private.Details:GetItemLevelFromGuid(guid),
                deathEvents = {}, --information about when the player died
                deathLastHits = {}, --information for the tooltip when the player died
                likedBy = {},
                score = currentScore,
                scorePrevious = previousScore,
                activityTimeDamage = actorObject:Tempo(),
                totalDeaths = #mythicPlusOverallSegment:GetPlayerDeaths(unitName),
            }

            runInfo.combatData.groupMembers[unitName] = playerInfo

            local deathTable = mythicPlusOverallSegment:GetDeaths()
            for i = 1, #deathTable do
                local thisDeathTable = deathTable[i]
                --deathTime is time()
                local playerName, playerClass, deathTime, deathCombatTime, deathTimeString, playerMaxHealth, deathEvents, lastCooldown, spec = private.Segments.UnpackDeathTable(thisDeathTable)
                if (playerName == unitName) then
                    playerInfo.deathEvents[#playerInfo.deathEvents+1] = {
                        type = addon.Enum.ScoreboardEventType.Death,
                        timestamp = thisDeathTable[2],
                        arguments = {}, --playerData = playerInfo, can't assign here as it will save playerInfo twice in the saved variables (or cause a loop)
                    }

                    local countDamageEventsFound = 0

                    ---@type death_last_hits[]
                    local thisDeathLastEvents = {}

                    for j = #deathEvents, 1, -1 do
                        ---@type deathtable
                        local thisEvent = deathEvents[j]
                        local evType, spellId, amount, eventTime, heathPercent, sourceName, absorbed, spellSchool, friendlyFire, overkill, criticalHit, crushing = private.Segments.UnpackDeathEvent(thisEvent)

                        if (evType == true) then --a boolean true means a damage event
                            ---@type death_last_hits
                            local deathLastHit = {
                                spellId = spellId,
                                sourceName = sourceName,
                                totalDamage = amount,
                            }
                            thisDeathLastEvents[#thisDeathLastEvents+1] = deathLastHit
                            countDamageEventsFound = countDamageEventsFound + 1

                            if (countDamageEventsFound == CONST_MAX_DEATH_EVENTS) then
                                break
                            end
                        end
                    end

                    playerInfo.deathLastHits[#playerInfo.deathLastHits+1] = thisDeathLastEvents
                end

            end

            --spell damage done
            local spellsUsed = actorObject:GetActorSpells()
            local temp = {}
            for _, spellTable in pairs(spellsUsed) do
                table.insert(temp, {spellTable.id, spellTable.total})
            end

            table.sort(temp, function(a, b) return a[2] > b[2] end)
            playerInfo.damageDoneBySpells = temp

            --heal
            for _, healActorObject in healingContainer:ListActors() do
                ---@cast actorObject actorheal
                if (healActorObject:Name() == unitName) then
                    playerInfo.totalHeal = healActorObject.total
                    playerInfo.totalHealTaken = healActorObject.healing_taken
                    playerInfo.activityTimeHeal = actorObject:Tempo()

                    --spell heal done
                    local temp = {}
                    local spellsUsedToHeal = healActorObject:GetActorSpells()
                    for _, spellTable in pairs(spellsUsedToHeal) do
                        table.insert(temp, {spellTable.id, spellTable.total})
                    end

                    table.sort(temp, function(a, b) return a[2] > b[2] end)
                    playerInfo.healDoneBySpells = temp
                end
            end

            --utility
            for _, utilityActorObject in utilityContainer:ListActors() do
                ---@cast utilityActorObject actorutility
                if (utilityActorObject:Name() == unitName) then
                    local ccTotal = 0
                    local ccUsed = {}

                    if not detailsFramework.IsAddonApocalypseWow() then
                        if (private.Details:GetCoreVersion() < 166) then
                            for spellName, casts in pairs(mythicPlusOverallSegment:GetCrowdControlSpells(unitName)) do
                                local spellInfo = C_Spell.GetSpellInfo(spellName)
                                local spellId = spellInfo and spellInfo.spellID or (openRaidLib and openRaidLib.GetCCSpellIdBySpellName(spellName) or 0)
                                if (spellId ~= 197214) then
                                    ccUsed[spellName] = casts
                                    ccTotal = ccTotal + casts
                                end
                            end
                        else
                            --at 166, Details! now uses the spellId instead of the spellName for crowd controls
                            for spellId, casts in pairs(mythicPlusOverallSegment:GetCrowdControlSpells(unitName)) do
                                if (spellId ~= 197214) then
                                    ccUsed[spellId] = casts
                                    ccTotal = ccTotal + casts
                                end
                            end
                        end
                    end

                    playerInfo.totalDispels = utilityActorObject.dispell
                    playerInfo.totalInterrupts = utilityActorObject.interrupt

                    if not detailsFramework.IsAddonApocalypseWow() then
                        playerInfo.totalInterruptsCasts = mythicPlusOverallSegment:GetInterruptCastAmount(unitName)
                    end

                    playerInfo.totalCrowdControlCasts = ccTotal
                    playerInfo.dispelWhat = detailsFramework.table.copy({}, utilityActorObject.dispell_oque or {})
                    playerInfo.interruptWhat = detailsFramework.table.copy({}, utilityActorObject.interrompeu_oque or {})
                    playerInfo.crowdControlSpells = ccUsed
                end
            end
        end
    end

    local compressedOkay, errorText = pcall(function() addon.Compress.CompressAndSaveRun(runInfo) end)
    if (not compressedOkay) then
        private.log("Error compressing run info: " .. errorText)
    end

    return runInfo
end

---set the index of the latest selected run info
---@param index number
function addon.SetSelectedRunIndex(index)
    addon.WipeLikeCache()
    addon.profile.saved_runs_selected_index = index
    --call refresh on the score board
    addon.RefreshOpenScoreBoard()
end

---get the runId passed and return the index of the run by iterating the headers
---@param runId number
---@return number|nil
function addon.GetRunIndexById(runId)
    local allHeaders = addon.Compress.GetHeaders()

    for i, runHeader in ipairs(allHeaders) do
        if (runHeader.runId == runId) then
            return i
        end
    end

    return nil
end

---get the index of the latest selected run info
---@return number
function addon.GetSelectedRunIndex()
    return addon.profile.saved_runs_selected_index
end

---return the date when the run ended in format of a string with hour:minute day as number/month as 3letters/year as number
---@param runInfo runinfo
---@return string
function addon.GetRunDate(runInfo)
    return date("%d/%b/%Y", runInfo.endTime)
end

---return a table with subtables of type death_last_hits which tells the last hits that killed the player
---@param runInfo runinfo
---@param unitName playername
---@param deathIndex number
---@return death_last_hits[]|nil
function addon.GetPlayerDeathReason(runInfo, unitName, deathIndex)
    local playerInfo = runInfo.combatData.groupMembers[unitName]
    if (playerInfo) then
        local deathLastHits = playerInfo.deathLastHits[deathIndex]
        if (deathLastHits) then
            return deathLastHits
        end
    end
end

---return the average item level of the 5 players in the run
---@param runInfo runinfo
---@return number
function addon.GetRunAverageItemLevel(runInfo)
    local total = 0
    local players = 0
    for _, playerInfo in pairs(runInfo.combatData.groupMembers) do
        if (playerInfo.ilevel > 0) then
            total = total + playerInfo.ilevel
            players = players + 1
        end
    end

    if (players == 0) then
        return 0
    end

    return total / players
end

---return the average damage per second
---@param runInfo runinfo
---@param timeType combattimetype
---@return number
function addon.GetRunAverageDamagePerSecond(runInfo, timeType)
    local total = 0
    for _, playerInfo in pairs(runInfo.combatData.groupMembers) do
        total = total + playerInfo.totalDamage
    end

    if (addon.Enum.CombatType.RunTime == timeType) then
        return total / (runInfo.endTime - runInfo.startTime)
    elseif (addon.Enum.CombatType.CombatTime == timeType) then
        return total / runInfo.timeInCombat
    end

    --default return as run time
    return total / (runInfo.endTime - runInfo.startTime)
end

---return the average healing per second
---@param runInfo runinfo
---@param timeType combattimetype
function addon.GetRunAverageHealingPerSecond(runInfo, timeType)
    local total = 0
    for _, playerInfo in ipairs(runInfo.combatData.groupMembers) do
        total = total + playerInfo.totalHeal
    end

    if (addon.Enum.CombatType.RunTime == timeType) then
        return total / (runInfo.endTime - runInfo.startTime)
    elseif (addon.Enum.CombatType.CombatTime == timeType) then
        return total / runInfo.timeInCombat
    end

    --default return as run time
    return total / (runInfo.endTime - runInfo.startTime)
end

--run data is also saved compressed to save space, when doing so, a header is created for it
--a 'run header' is a table with a small portion of the run data. this data is used to show in the dropdown menu which runs are available to be selected

---@class compressrun : table
---@field CompressAndSaveRun fun(runInfo:runinfo) : string receives a runInfo, encode it, compress and save it to the saved_runs_compressed. also creates a header for the run.
---@field GetSavedRuns fun() : string[] return a table with compressed run info where the first index in the newest run
---@field GetHeaders fun() : runinfocompressed_header[] return a table with headers where the first index in the newest run
---@field GetRunHeader fun(headerIndex:number) : runinfocompressed_header? return the compressed header from the saved run
---@field GetRunHeaderById fun(runId:number) : runinfocompressed_header? return the header from the saved runId
---@field UncompressedRun fun(headerIndex:number) : runinfo? return the uncompressed run data from the compressed run data
---@field GetSelectedRun fun() : runinfo return the uncompressed run data from the compressed run data
---@field SetValue fun(headerIndex:number, path:string, value:any) : boolean
---@field CompressRun fun(runInfo:runinfo) : string? compresses the run info and returns the compressed data
---@field HasLastRun fun() : boolean checks if there's run info for GetLastRun
---@field GetLastRun fun() : runinfo?, runinfocompressed_header? return the run info for the last run finished before the next one starts

---@diagnostic disable-next-line: missing-fields
addon.Compress = {}

---return a table with compressed run info where the first index in the newest run
---@return string[]
function addon.Compress.GetSavedRuns()
    return addon.profile.saved_runs_compressed
end

---return the run info for the last run finished before the next one starts
---@return boolean
function addon.Compress.HasLastRun()
    return addon.profile.has_last_run
        and addon.profile.saved_runs_compressed_headers[1]
        and addon.profile.saved_runs_compressed_headers[1].endTime + CONST_LAST_RUN_TIMEOUT > time()
        and true or false
end

---return the run info for the last run finished before the next one starts
---@return runinfo?
---@return runinfocompressed_header?
function addon.Compress.GetLastRun()
    if (addon.Compress.HasLastRun()) then
        local umcompressedRun = addon.Compress.UncompressedRun(1)
        local runHeader = addon.Compress.GetRunHeader(1)
        return umcompressedRun, runHeader
    end
end

---return a table with headers where the first index in the newest run
---@return runinfocompressed_header[]
function addon.Compress.GetHeaders()
    return addon.profile.saved_runs_compressed_headers
end

---return the header for the given runId
---@param runId number
---@return runinfocompressed_header|nil
function addon.Compress.GetRunHeaderById(runId)
    local headers = addon.Compress.GetHeaders()
    for i, header in ipairs(headers) do
        if (header.runId == runId) then
            return header
        end
    end
    return nil
end

---return the header for a compressed run info
---@param headerIndex number
---@return runinfocompressed_header|nil
function addon.Compress.GetRunHeader(headerIndex)
    return addon.profile.saved_runs_compressed_headers[headerIndex]
end

---return a table with the uncompressed run data
---@param headerIndex number
---@return runinfo|nil
function addon.Compress.UncompressedRun(headerIndex)
    assert(type(headerIndex) == "number", "UncompressedRun(headerIndex): headerIndex must be a number.")
    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local compressedRuns = addon.Compress.GetSavedRuns()

    local runData = compressedRuns[headerIndex]
    if (not runData) then
        private.log("UncompressedRun(headerIndex): runData not found for index " .. headerIndex)
        return nil
    end

    local dataDecoded = C_EncodingUtil.DecodeBase64(runData)
    if (not dataDecoded) then
        private.log("UncompressedRun(headerIndex): C_EncodingUtil.DecodeBase64 failed")
        return nil
    end

    local dataDecompressed = C_EncodingUtil.DecompressString(dataDecoded, Enum.CompressionMethod.Deflate)
    if (not dataDecompressed) then
        private.log("UncompressedRun(headerIndex): C_EncodingUtil.DecompressString failed")
        return nil
    end

    local runInfo = C_EncodingUtil.DeserializeCBOR(dataDecompressed)
    if (not runInfo) then
        private.log("UncompressedRun(headerIndex): C_EncodingUtil.DeserializeCBOR failed")
        return nil
    end

    return runInfo
end

function addon.Compress.SetValue(headerIndex, path, value)
    assert(type(headerIndex) == "number", "UncompressedRun(headerIndex): headerIndex must be a number.")
    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local runInfo = addon.Compress.UncompressedRun(headerIndex)
    if (runInfo) then
        detailsFramework.table.setfrompath(runInfo, path, value)

        local runInfoCompressed = addon.Compress.CompressRun(runInfo)
        if (not runInfoCompressed) then
            private.log("SetValue: CompressRun failed")
            return false
        end

        --save the compressed run info
        local savedRuns = addon.Compress.GetSavedRuns()
        savedRuns[headerIndex] = runInfoCompressed
    end

    return true
end

function addon.Compress.CompressRun(runInfo)
    if (not runInfo) then
        private.log("CompressRun: runInfo is nil")
        return false
    end

    assert(C_EncodingUtil, "C_EncodingUtil is nil")

    local dataSerialized = C_EncodingUtil.SerializeCBOR(runInfo)
    if (not dataSerialized) then
        private.log("CompressRun: C_EncodingUtil.SerializeCBOR failed")
        return false
    end

    local dataCompressed = C_EncodingUtil.CompressString(dataSerialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    if (not dataCompressed) then
        private.log("CompressRun: C_EncodingUtil.CompressString failed")
        return false
    end

    local dataEncoded = C_EncodingUtil.EncodeBase64(dataCompressed)
    if (not dataEncoded) then
        private.log("CompressRun: C_EncodingUtil.EncodeBase64 failed")
        return false
    end

    return dataEncoded
end

---receives a runInfo, encode it, compress and save it to the saved_runs_compressed
---@param runInfo runinfo
---@param atIndex number|nil
---@return boolean success
function addon.Compress.CompressAndSaveRun(runInfo, atIndex)
    atIndex = atIndex and atIndex > 0 and atIndex or 1
    if (atIndex > addon.profile.saved_runs_limit) then
        return
    end

    local runInfoCompressed = addon.Compress.CompressRun(runInfo)
    if (not runInfoCompressed) then
        private.log("CompressAndSaveRun: CompressRun failed")
        return false
    end

    --save the compressed run info
    table.insert(addon.profile.saved_runs_compressed, atIndex, runInfoCompressed)

    ---@type runinfocompressed_header
    local header = {
        dungeonName = runInfo.dungeonName,
        startTime = runInfo.startTime,
        endTime = runInfo.endTime,
        keyLevel = runInfo.completionInfo.level,
        keyUpgradeLevels = runInfo.completionInfo.keystoneUpgradeLevels,
        onTime = runInfo.completionInfo.onTime or false,
        mapId = runInfo.mapId,
        dungeonId = runInfo.dungeonId,
        playerName = UnitName("player"),
        playerClass = select(2, UnitClass("player")),
        runId = runInfo.runId,
        seasonId = runInfo.seasonId,
        instanceId = runInfo.instanceId,
        groupMembers = {},
        likesGiven = {}, --table<playername, true>
    }

    for playerName, playerInfo in pairs(runInfo.combatData.groupMembers) do
        header.groupMembers[playerName] = playerInfo.class
    end

    table.insert(addon.profile.saved_runs_compressed_headers, atIndex, header)

    addon.Compress.YeetRunsOverStorageLimit()

    return true
end

function addon.Compress.YeetRunsOverStorageLimit()
    while #addon.profile.saved_runs_compressed > addon.profile.saved_runs_limit do
        table.remove(addon.profile.saved_runs_compressed, addon.profile.saved_runs_limit + 1)
    end

    while #addon.profile.saved_runs_compressed_headers > addon.profile.saved_runs_limit do
        table.remove(addon.profile.saved_runs_compressed_headers, addon.profile.saved_runs_limit + 1)
    end

    --TODO: erase the runId from the likes given to players in the addon.profile.likes_given
end

---uncompress the runInfo and return it
---@return runinfo?
function addon.Compress.GetSelectedRun()
    local savedRuns = addon.Compress.GetSavedRuns()
    local selectedRunIndex = addon.GetSelectedRunIndex()
    local compressedRunInfo = savedRuns[selectedRunIndex]

    if (compressedRunInfo == nil) then
        --if no run is selected, select the first run
        addon.SetSelectedRunIndex(1)
        selectedRunIndex = 1
    end

    return addon.Compress.UncompressedRun(selectedRunIndex)
end

--given a table T, iterate among the values and create another table where the keys that are numbers, get converted to string
local stringuifyTableKeys = function(T)
    local newTable = {}
    for k,v in pairs(T) do
        if (type(k) == "number") then
            k = tostring(k)
        end
        newTable[k] = v
    end
    return newTable
end

function addon.ExportToJson(headerIndex)
    local runInfo = addon.Compress.UncompressedRun(headerIndex)
    if (not runInfo) then
        return
    end

    local t = {}
    for k,v in pairs(runInfo) do
        if (type(v) ~= "table") then
            t[k] = v
        end
    end

    local combatData = {
        groupMembers = {},
    }

    for playerName, playerInfo in pairs(runInfo.combatData.groupMembers) do
        local thisPlayerInfo = {}

        for k,v in pairs(playerInfo) do
            if (type(v) ~= "table") then
                thisPlayerInfo[k] = v
            end
        end

        thisPlayerInfo.likedBy = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.likedBy))
        thisPlayerInfo.damageDoneBySpells = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.damageDoneBySpells))
        thisPlayerInfo.deathEvents = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.deathEvents))
        thisPlayerInfo.dispelWhat = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.dispelWhat))
        thisPlayerInfo.deathLastHits = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.deathLastHits))
        thisPlayerInfo.interruptWhat = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.interruptWhat))
        thisPlayerInfo.crowdControlSpells = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.crowdControlSpells))
        thisPlayerInfo.damageTakenFromSpells = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.damageTakenFromSpells))
        thisPlayerInfo.healDoneBySpells = C_EncodingUtil.SerializeJSON(stringuifyTableKeys(playerInfo.healDoneBySpells))

        combatData.groupMembers[playerName] = thisPlayerInfo
    end

    t["combatData"] = combatData --can't export
    t["combatTimeline"] = runInfo.timeInCombat --okay
    t["encounters"] = runInfo.encounters --okay
    t["completionInfo"] = runInfo.completionInfo --okay

    local jsonString = C_EncodingUtil.SerializeJSON(t)
    if (not jsonString) then
        return ""
    end

    return jsonString
end
