
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

    local run = addon.Compress.GetLastRun()
    if (not run) then
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

    if (addon.GetSelectedRunIndex() == 1) then
        addon.RefreshOpenScoreBoard()
    end
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
    LikePlayer(sender, data.playerLiked)
end
