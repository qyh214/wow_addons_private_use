local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

ns.Debug = ns.Debug or {
    ForceQuestsUnlearned = false,
    ForceAchievementsUncompleted = false,
}

function ns.IsAchievementCompleted(achievementID)
    if ns.DevMode() then
        if IsAltKeyDown() then return false end
        if ns.Debug.ForceAchievementsUncompleted then return false end
    end
    local _, _, _, completed = GetAchievementInfo(achievementID)
    return completed and true or false
end


function ns.IsQuestLearned(questIDs)
    if ns.DevMode() then 
        if IsAltKeyDown() then return false end
        if ns.Debug.ForceQuestsUnlearned then return false end
    end
    return C_QuestLog.IsQuestFlaggedCompleted(questIDs)
end

local MN_PendingQuestPrint = {}
local MN_Event = CreateFrame("Frame")
MN_Event:RegisterEvent("QUEST_DATA_LOAD_RESULT")
MN_Event:SetScript("OnEvent", function(_, _, questID, success)
    if success and MN_PendingQuestPrint[questID] then
        local name = C_QuestLog.GetTitleForQuestID(questID)
        if name then
            ns.printQuestWithName(questID, name, true)
        end
        MN_PendingQuestPrint[questID] = nil
    end
end)

function ns.getQuestName(node, questID)
    if node then
        for i = 1, 10 do
            if tonumber(node["questIDs"..i]) == tonumber(questID) then
                return node["wwwNames"..i] or C_QuestLog.GetTitleForQuestID(questID)
            end
        end
        if tonumber(node.questID) == tonumber(questID) and node.wwwName then
            return node.wwwName
        end
    end
    return C_QuestLog.GetTitleForQuestID(questID)
end

function ns.printQuestWithName(questID, explicitName, fromCallback)
    local name = explicitName or C_QuestLog.GetTitleForQuestID(questID)
    if name then
        print("|cffff0000Map|r|cff00ccffNotes|r",  "|cffffff00"..LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..":".."|r", "https://www.wowhead.com/quest="..questID.." ("..name..")")
    elseif not fromCallback then
        MN_PendingQuestPrint[questID] = true
        C_QuestLog.RequestLoadQuestByID(questID)
    end
end

function ns.printAchievement(achievementID, explicitName)
    local name = explicitName
    if not name then
        local _, n = GetAchievementInfo(achievementID)
        name = n
    end

    local suffix = name and (" ("..name..")") or ""
    print("|cffff0000Map|r|cff00ccffNotes|r", "|cffffff00"..LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..":".."|r", "https://www.wowhead.com/achievement="..achievementID..suffix)
end

function ns.mnIDsANDquestIDsTooltip(tooltip, nodeData)
  --local IsCompleted = C_QuestLog.IsQuestFlaggedCompleted

    local ANYmnIDs = false
    for i = 1, 10 do
        local mnIDs = nodeData["mnIDs"..i]
        local questIDs = nodeData["questIDs"..i]
        if mnIDs then
            local info = C_Map.GetMapInfo(mnIDs)
            if info and info.name then
                ANYmnIDs = true
                local learned = questIDs and ns.IsQuestLearned(questIDs)
                if learned then
                    tooltip:AddDoubleLine(" ==> " .. info.name, ALREADY_LEARNED, 1,1,1, 0,1,0)
                elseif learned == false then
                    tooltip:AddDoubleLine(" ==> " .. info.name, L["Has not been unlocked yet"], 1,1,1, 1,0,0)
                end
            end
        end
    end

    if ANYmnIDs then
        tooltip:AddLine(" ")
    end

    local anyShown = false
    local function showCopyHint()
        if ns.Addon.db.profile.CreateAndCopyLinks then
            tooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. "|cff00ff00 " .. L["Middle mouse button to post the link in the chat"] .. " " .. TextIconMNL4:GetIconString(), nil, nil, false)
        else
            tooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. "|cff00ff00  " .. L["Enable „Link“ in MapNotes („General“ - „Chat-Options“)"] .. "  " .. TextIconMNL4:GetIconString() .. "\n " .. TextIconMNL4:GetIconString() .. "|cff00ff00  " .. L["to create clickable quest or achievement links in chat"] .. "  " .. TextIconMNL4:GetIconString(), nil, nil, false)
        end
    end

    local function showLink(wwwLinks)
        tooltip:AddDoubleLine("|cffffffff" .. (wwwLinks or ""), nil, nil, false)
        tooltip:AddLine(L["Has not been unlocked yet"], 1, 0, 0)
        tooltip:AddLine(" ")
        anyShown = true
    end

    if nodeData.questID then -- single questID
        local learned = ns.IsQuestLearned(nodeData.questID)
        if not learned then
            local questName = nodeData.wwwName or C_QuestLog.GetTitleForQuestID(nodeData.questID)
            if questName then
                tooltip:AddDoubleLine("\n|cffffff00" .. questName, nil, nil, false)
            end
            if nodeData.showWWW and (nodeData.wwwLink or nodeData.wwwLink1) then
                showLink(nodeData.wwwLink or nodeData.wwwLink1)
            elseif nodeData.showWWW then
                showLink("https://www.wowhead.com/quest=" .. nodeData.questID)
            end
        elseif nodeData.hideLink then
            tooltip:AddLine("\n" .. ALREADY_LEARNED .. "\n", 0, 1, 0)
        end
    end

    for i = 1, 10 do
        local questIDs   = nodeData["questIDs"..i]
        local wwwLinks = nodeData["wwwLinks"..i]

        if questIDs then
            local learned = ns.IsQuestLearned(questIDs)
            if not learned and nodeData.showWWW then
                local questName = nodeData["wwwNames"..i] or C_QuestLog.GetTitleForQuestID(questIDs)
                if questName then
                  tooltip:AddDoubleLine("|cffffff00" .. questName, nil, nil, false)
                end
                showLink(wwwLinks or ("https://www.wowhead.com/quest=" .. questIDs))
            end
    
        elseif wwwLinks and nodeData.showWWW then
            local questName = nodeData["wwwNames"..i]
            if not questName then
                local id = tonumber((wwwLinks or ""):match("quest=(%d+)"))
                if id then questName = C_QuestLog.GetTitleForQuestID(id) end
            end
            if questName then
                tooltip:AddDoubleLine("|cffffff00" .. questName, nil, nil, false)
            end
            showLink(wwwLinks)
        end
    end

    if nodeData.achievementID then -- achievementID
        local achCompleted = ns.IsAchievementCompleted(nodeData.achievementID)
        if not achCompleted and nodeData.showWWW then
            local _, achName, _, _, _, _, _, description = GetAchievementInfo(nodeData.achievementID)
            local nameToShow = nodeData.wwwName or achName
            if nameToShow then
                tooltip:AddLine(" ")
                tooltip:AddDoubleLine("|cffffff00" .. nameToShow, nil, nil, false)
            end

            local link = nodeData.wwwLink or ("https://www.wowhead.com/achievement=" .. nodeData.achievementID)
            showLink(link)

            if description and description ~= "" then
                tooltip:AddLine(description, nil, nil, false)
            end
        end
    end

    if anyShown then
        showCopyHint()
    end

end