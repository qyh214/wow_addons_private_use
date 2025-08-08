local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

addon.Migrations = {
    function ()
        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- structure was changed to use just numbers instead of a table with extra info
        for _, run in pairs(addon.profile.saved_runs) do
            for i, timeline in pairs(run.combatTimeline) do
                run.combatTimeline[i] = timeline.time
            end
        end
    end,

    function ()
        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- structure was changed to only store the last 7
        for _, run in pairs(addon.profile.saved_runs) do
            for _, damageTakenList in pairs(run.combatData.groupMembers) do
                local newDamageTakeFromSpells = {}
                for i, damageTaken in pairs(damageTakenList.damageTakenFromSpells) do
                    if (i > 7) then
                        break
                    end
                    newDamageTakeFromSpells[i] = damageTaken
                end
                damageTakenList.damageTakenFromSpells = newDamageTakeFromSpells
            end
        end
    end,

    function ()
        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- runId was introduced so external addons can link info to our runs without having to save it in this addon
        for _, run in pairs(addon.profile.saved_runs) do
            if (run.runId == nil) then
                addon.profile.last_run_id = addon.profile.last_run_id + 1
                run.runId = addon.profile.last_run_id
            end
        end
    end,

    function ()
        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- Sundering is not a CC in 99.99% of the PvE scenarios, especially in M+. For now we remove the data from
        -- existing runs
        for _, run in pairs(addon.profile.saved_runs) do
            for _, playerInfo in pairs(run.combatData.groupMembers) do
                local ccTotal = 0
                local ccUsed = {}

                for spellName, casts in pairs(playerInfo.crowdControlSpells) do
                    local spellInfo = C_Spell.GetSpellInfo(spellName)
                    local spellId = spellInfo and spellInfo.spellID or openRaidLib.GetCCSpellIdBySpellName(spellName)
                    if (spellId ~= 197214) then
                        ccUsed[spellName] = casts
                        ccTotal = ccTotal + casts
                    end
                end

                playerInfo.totalCrowdControlCasts = ccTotal
                playerInfo.crowdControlSpells = ccUsed
            end
        end
    end,

    function ()
        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- Some spell data contains invalid values, we can't reconstruct this
        for _, run in pairs(addon.profile.saved_runs) do
            for _, playerInfo in pairs(run.combatData.groupMembers) do
                for _, spellData in pairs(playerInfo.damageDoneBySpells) do
                    if (type(spellData) == "number") then
                        playerInfo.damageDoneBySpells = {}
                    end

                    break
                end
            end
        end
    end,
    function ()
        -- 1 save only last run, everything else can just go *10 due to being compressed
        if (addon.profile.saved_runs_limit > 1) then
            addon.profile.saved_runs_limit = addon.profile.saved_runs_limit * 10
        end

        -- from a time before compressed runs
        if (not addon.profile.saved_runs) then
            return
        end

        -- we moved to saving each run as a compressed string to save storage
        -- move old runs to this storage, and merge possibly missing loot (this is probably only an issue on alpha)
        local runDataToMigrate = {}
        for index, run in pairs(addon.profile.saved_runs) do
            ---@type runinfo
            local runInfo = run
            runDataToMigrate[runInfo.runId] = {
                index = index,
                loot = {}
            }
            for _, playerInfo in pairs(runInfo.combatData.groupMembers) do
                if (playerInfo.loot and playerInfo.loot ~= "") then
                    runDataToMigrate[runInfo.runId].loot[playerInfo.name] = playerInfo.loot
                end
            end
        end

        for index, runHeader in pairs(addon.profile.saved_runs_compressed_headers) do
            ---@type runinfocompressed_header
            local header = runHeader
            if (runDataToMigrate[header.runId] and runDataToMigrate[header.runId].loot) then
                for playerName, itemLink in pairs(runDataToMigrate[header.runId].loot) do
                    addon.Compress.SetValue(index, "combatData.groupMembers." .. playerName .. ".loot", itemLink)
                end

                runDataToMigrate[header.runId] = nil
            end
        end

        for _, run in pairs(runDataToMigrate) do
            local newIndex = 1
            ---@type runinfo
            local thisRun = addon.profile.saved_runs[run.index]
            for index, runHeader in pairs(addon.profile.saved_runs_compressed_headers) do
                ---@type runinfocompressed_header
                local header = runHeader
                newIndex = index
                if (header.startTime < thisRun.startTime) then
                    addon.Compress.CompressAndSaveRun(thisRun, newIndex)
                    break
                end
            end
        end

        -- permanently delete old runs
        addon.profile.saved_runs = nil
    end,
}
