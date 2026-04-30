
--mythic+ extension for Details! Damage Meter
local Details = Details
local _

---@type string, private
local tocFileName, private = ...
local addon = private.addon

---@type detailsframework
local detailsFramework = DetailsFramework

function addon.InitializeEvents()
    if detailsFramework.IsAddonApocalypseWow() then
        local e = CreateFrame("Frame")
        e:RegisterEvent("PLAYER_REGEN_ENABLED")
        e:RegisterEvent("PLAYER_REGEN_DISABLED")
        e:RegisterEvent("ENCOUNTER_START")
        e:RegisterEvent("ENCOUNTER_END")
        e:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        e:RegisterEvent("CHALLENGE_MODE_START")

        e:SetScript("OnEvent", function(self, event, ...)
            if (event == "PLAYER_REGEN_ENABLED") then
                addon.OnPlayerLeaveCombat(...)
            elseif (event == "PLAYER_REGEN_DISABLED") then
                addon.OnPlayerEnterCombat(...)
            elseif (event == "ENCOUNTER_START") then
                addon.OnEncounterStart(...)
            elseif (event == "ENCOUNTER_END") then
                addon.OnEncounterEnd(...)
            elseif (event == "CHALLENGE_MODE_START") then
                private.log(event)
                addon.OnMythicDungeonStart(...)
            elseif (event == "CHALLENGE_MODE_COMPLETED") then
                private.log(event)
                addon.OnMythicDungeonEnd(...)
            end
        end)
    end

    --event listener:
    local detailsEventListener = addon.detailsEventListener

    if detailsEventListener then
        function detailsEventListener.OnDetailsEvent(contextObject, event, ...)
            if detailsFramework.IsAddonApocalypseWow() then
                return
            end
            if (event == "COMBAT_MYTHICDUNGEON_START") then
                private.log(event)
                addon.OnMythicDungeonStart(...)
            elseif (event == "COMBAT_MYTHICDUNGEON_END") then
                private.log(event)
                addon.OnMythicDungeonEnd(...)
            elseif (event == "COMBAT_MYTHICDUNGEON_CONTINUE") then
                private.log(event)
                addon.OnMythicDungeonContinue(...)
            elseif (event == "COMBAT_MYTHICPLUS_OVERALL_READY") then
                private.log(event)
                addon.OnMythicPlusOverallReady(...) --Details! entry point
            elseif (event == "COMBAT_ENCOUNTER_START") then
                addon.OnEncounterStart(...)
            elseif (event == "COMBAT_ENCOUNTER_END") then
                addon.OnEncounterEnd(...)
            elseif (event == "COMBAT_PLAYER_ENTER") then
                addon.OnPlayerEnterCombat(...)
            elseif (event == "COMBAT_PLAYER_LEAVE") then
                addon.OnPlayerLeaveCombat(...)
            end
        end
    end

    function addon.ApocalypseSegmentCreated(segment)
        private.log("Apocalypse segment received from CreateOBFS.")
        addon.OnMythicPlusOverallReady(segment)
    end

    function addon.OnMythicPlusOverallReady(segment) --only from Details!, called from scoreboard when no apocalypse
        local mythicPlusOverallSegment
        if detailsFramework.IsAddonApocalypseWow() then
            mythicPlusOverallSegment = segment
        else
            mythicPlusOverallSegment = Details:GetCurrentCombat()
        end

        local okay, errorText = pcall(function()
            local runInfo = addon.CreateRunInfo(mythicPlusOverallSegment)
            if (runInfo) then
                addon.SetSelectedRunIndex(1)
                addon.profile.has_last_run = true

                if (addon.profile.when_to_automatically_open_scoreboard == "COMBAT_MYTHICPLUS_OVERALL_READY") then
                    addon.OpenScoreBoardAtEnd()
                end

                addon.FireEvent("RunFinished", runInfo.runId)
            end
        end)

        if (not okay) then
            private.log("Error on CreateRunInfo(): ", errorText)
        end

        if (not addon.profile.keep_information_for_debugging) then
            addon.profile.last_run_data = {}
        end
    end

    function addon.OnMythicDungeonStart(...) --shared
        if (addon.IsParsing()) then --for midnight, Parsing does nothing
            -- edge case because COMBAT_MYTHICDUNGEON_END is not fired when
            -- abandoning a run and then starting a new one
            private.log("OnMythicDungeonStart: IsParsing = true")
            addon.StopParser()
        end

        private.SaveGroupMembersKeystoneAndRatingLevel()

        addon.profile.has_last_run = false
        addon.profile.is_run_ongoing = true
        addon.profile.last_run_data.reloaded = false
        addon.profile.last_run_data.start_time = time()
        addon.profile.last_run_data.time_lost_to_deaths = 0
        addon.profile.last_run_data.map_id = private.Details.challengeModeMapId or C_ChallengeMode.GetActiveChallengeMapID()
        addon.profile.last_run_data.incombat_timeline = {time()} --store the first value in the in combat timeline.
        addon.profile.last_run_data.encounter_timeline = {}
        addon.profile.last_run_data.interrupt_spells_cast = {}
        addon.profile.last_run_data.interrupt_cast_overlap_done = {}
        addon.profile.last_run_data.player_ratings = CopyTable(private.PlayerRatings)

        addon.StartParser()

        if detailsFramework.IsAddonApocalypseWow() then
            if not Details then
                --reset the ingame damage meter
                C_DamageMeter.ResetAllCombatSessions()
            end
        end
    end

    function addon.OnMythicDungeonEnd(...) --shared, apocalypse entry point
        addon.profile.is_run_ongoing = false
        addon.profile.last_run_data.end_time = time()
        local combatTimeline = addon.profile.last_run_data.incombat_timeline
        local totalTimes = #combatTimeline

        if (totalTimes % 2 == 0) then
            if (combatTimeline[totalTimes -1] == combatTimeline[totalTimes]) then
                --remove this last segment
                table.remove(combatTimeline)
            else
                table.insert(combatTimeline, addon.profile.last_run_data.end_time)
            end
        end

        addon.StopParser()

        if detailsFramework.IsAddonApocalypseWow() then
            C_Timer.After(2, function()
                if not private.Segments.IsServerInCombat() then
                    private.Segments.CreateOBFS() -- <- entry point
                else
                    private.Segments.WaitServerDropCombat() --calls CreateOBFS after combat ends
                end
            end)
        end
    end

    function addon.OnMythicDungeonContinue(...) --only from Details!, only called here
        if (not addon.profile.is_run_ongoing) then
            private.log("Detected run continue, but the run is not marked as ongoing. Not starting the parser")
            return
        end

        private.log("Detected run continue with ongoing run, continue parsing")
        Details.MythicPlus.IsRestoredState = nil

        addon.StartParser()
    end

    function addon.OnEncounterStart(dungeonEncounterId, encounterName, difficultyId, raidSize) --shared
        if (not addon.profile.is_run_ongoing) then
            return
        end

        ---@type detailsmythicplus_encounterinfo
        local currentEncounterInfo = {
            dungeonEncounterId = dungeonEncounterId,
            encounterName = encounterName,
            startTime = time(),
            endTime = 0,
            defeated = false,
        }

        table.insert(addon.profile.last_run_data.encounter_timeline, currentEncounterInfo)

        private.log("Encounter started: ", encounterName)
    end

    function addon.OnEncounterEnd(dungeonEncounterId, encounterName, difficultyId, raidSize, endStatus) --shared
        if (not addon.profile.is_run_ongoing) then
            return
        end

        ---@type detailsmythicplus_encounterinfo
        local currentEncounterInfo = addon.profile.last_run_data.encounter_timeline[#addon.profile.last_run_data.encounter_timeline]

        --if the current encounter is nil, then we did miss the encounter start event
        if (not currentEncounterInfo) then
            return
        end

        currentEncounterInfo.endTime = time()
        currentEncounterInfo.defeated = endStatus == 1

        private.log("Encounter ended: ", encounterName, " defeated: ", endStatus == 1)
    end

    function addon.OnPlayerEnterCombat(...) --shared
        if (addon.profile.is_run_ongoing) then
            table.insert(addon.profile.last_run_data.incombat_timeline, time())
        end
    end

    function addon.OnPlayerLeaveCombat(...) --shared
        if (addon.profile.is_run_ongoing) then
            table.insert(addon.profile.last_run_data.incombat_timeline, time())
        end
    end

end
