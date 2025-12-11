
--mythic+ extension for Details! Damage Meter
local Details = Details
local detailsFramework = DetailsFramework
local _

---@type string, private
local tocFileName, private = ...

---@type detailsmythicplus
local addon = private.addon

--localization
local L = detailsFramework.Language.GetLanguageTable(tocFileName)
local Translit = LibStub("LibTranslit-1.0")

function addon.PreparePlayerName(name)
    name = detailsFramework:RemoveRealmName(name)
    return addon.profile.translit and Translit:Transliterate(name, "!") or name
end

local LikePlayer = function (whoLiked, playerLiked)
    if (not playerLiked) then
        return
    end

    playerLiked = Ambiguate(playerLiked, "none")
    if (playerLiked == whoLiked) then
        return
    end

    local run, runHeader = addon.Compress.GetLastRun()
    if (not run or not runHeader) then
        return
    end

    if (not run.combatData.groupMembers[playerLiked]) then
        private.log("unable to match gg from " .. whoLiked .. " for " .. playerLiked .. " to a player in the group")
        return
    end

    if (not run.combatData.groupMembers[playerLiked].likedBy) then
        addon.Compress.SetValue(1, "combatData.groupMembers." .. playerLiked .. ".likedBy", {[whoLiked] = true})
    else
        addon.Compress.SetValue(1, "combatData.groupMembers." .. playerLiked .. ".likedBy." .. whoLiked, true)
    end

    runHeader.likesGiven[whoLiked] = runHeader.likesGiven[whoLiked] or {}
    runHeader.likesGiven[whoLiked][playerLiked] = true

    local runOkay, errorText = pcall(function() --don't stop the flow if new code gives errors
        if (UnitIsUnit(whoLiked, "player")) then
            addon.profile.likes_given[playerLiked] = addon.profile.likes_given[playerLiked] or {} --store a list of runIds
            table.insert(addon.profile.likes_given[playerLiked], 1, runHeader.runId) --add the runId where the like was given
        end
    end)

    if (not runOkay) then
        print("Details! M+ Extension error on LikePlayer(): ", errorText)
    end

    if (addon.GetSelectedRunIndex() == 1) then
        addon.RefreshOpenScoreBoard()
    end

    addon.FireEvent("PlayerLiked", DetailsMythicPlus.GetLatestRunId(), playerLiked)
end

function addon.LikePlayer(playerLiked)
    local myName = UnitName("player")
    if (playerLiked == myName) then
        return
    end

    if (not playerLiked:match("%-")) then
        playerLiked = playerLiked .. "-" .. GetRealmName("player")
    end

    LikePlayer(myName, playerLiked)
    addon.Comm.Send("L", {playerLiked = playerLiked})
end

function addon.ProcessLikePlayer(sender, data)
    if (sender == UnitName("player")) then
        return
    end

    LikePlayer(sender, data.playerLiked)
end
