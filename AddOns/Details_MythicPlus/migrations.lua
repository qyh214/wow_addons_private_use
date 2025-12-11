local addonName, private = ...
---@type detailsmythicplus
local addon = private.addon

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

        local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)

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
    function ()
        -- update the default setting for those who set it to a very low value as it doesn't take up much space anymore
        if (addon.profile.saved_runs_limit < 500) then
            addon.profile.saved_runs_limit = 500
        end
    end,
}

addon.MigrationsPerCharacter = {
    function (migrationIndex)
        if (not addon.profile.migrations_data[migrationIndex]) then
            addon.profile.migrations_data[migrationIndex] = {}
        end

        --get all stored runs
        local allRuns = addon.Compress.GetSavedRuns()
        if (not allRuns) then
            return
        end

        --reset for development
        if (not addon.profile.migrations_data.repeat_index_one) then
            addon.profile.migrations_data.repeat_index_one = true
            table.wipe(addon.profile.migrations_data[migrationIndex])

            for headerIndex = 1, #allRuns do
                local thisRun = addon.Compress.UncompressedRun(headerIndex)
                local thisHeader = addon.Compress.GetRunHeader(headerIndex)
                if (thisRun and thisHeader) then
                    if (thisHeader.likesGiven) then
                        table.wipe(thisHeader.likesGiven) --clear the likes given table
                    end
                end
            end
        end

        --if this migration was already done for this character, skip
        local migrationsRan = addon.profile.migrations_data[migrationIndex][UnitName("player")]
        if (migrationsRan and migrationsRan > 0) then
            return
        end

        --iterate among all run infos and all to the runHeader the players who liked them
        --iterate among all run infos and add to addon.profile.likes_given all the players whose the Player Himself liked
        local playersWhosePlayerHimSelfLiked = addon.profile.likes_given
        --local playerName = "Neverious" or UnitName("player") --development debug
        local playerName = UnitName("player")

        for headerIndex = 1, #allRuns do
            local thisRun = addon.Compress.UncompressedRun(headerIndex)
            local thisHeader = addon.Compress.GetRunHeader(headerIndex)
            if (thisRun and thisHeader) then
                local groupMembersOfThisRun = thisRun.combatData.groupMembers
                for playerNameWhoReceveidLikes, playerInfo in pairs(groupMembersOfThisRun) do
                    local likedBy = playerInfo.likedBy --who liked this player
                    if (likedBy) then
                        for playerNameOfWhoLiked in pairs(likedBy) do
                            if (not thisHeader.likesGiven) then
                                thisHeader.likesGiven = {}
                            end
                            thisHeader.likesGiven[playerNameOfWhoLiked] = thisHeader.likesGiven[playerNameOfWhoLiked] or {}
                            thisHeader.likesGiven[playerNameOfWhoLiked][playerNameWhoReceveidLikes] = true

                            --this need to run once for each character the player logins
                            --this add the like the player himself gave into the main profile, will work cross all characters the player has
                            if (playerNameOfWhoLiked == playerName) then
                                playersWhosePlayerHimSelfLiked[playerNameWhoReceveidLikes] = playersWhosePlayerHimSelfLiked[playerNameWhoReceveidLikes] or {}
                                table.insert(playersWhosePlayerHimSelfLiked[playerNameWhoReceveidLikes], thisHeader.runId) --add the runId where the like was given
                                private.log("Migration: added playerHimselfLike to player " .. playerNameWhoReceveidLikes .. " for runId " .. thisHeader.runId)
                            end
                        end
                    end
                end
            end
        end

        if (not migrationsRan) then
            migrationsRan = 0
        end
        addon.profile.migrations_data[migrationIndex][UnitName("player")] = migrationsRan + 1
    end,

}
