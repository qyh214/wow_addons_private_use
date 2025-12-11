local ADDON_NAME, DTH = ...;

local L = DTH.L;

local QUEST_NPC_ALLIANCE = 248854;
local MAP_ALLIANCE = 2352;
local QUEST_NPC_HORDE = 253596;
local MAP_HORDE = 2351;

local addonTitle = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title");
local tomtomWaypointUid;

local function SetWaypoint(x, y)
    local mapId = C_Map.GetBestMapForUnit("player");
    if (not mapId or (mapId ~= MAP_HORDE and mapId ~= MAP_ALLIANCE) ) then
        return;
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapId, x, y));
    C_SuperTrack.SetSuperTrackedUserWaypoint(true);

    if (TomTom and TomTom.AddWaypoint) then
        tomtomWaypointUid = TomTom:AddWaypoint(mapId, x, y, { title = addonTitle });
    end

    print("|cffe6c619" .. addonTitle .. ":|r " .. L.WAYPOINT_SET);
end

local function ClearWaypoint()
    C_Map.ClearUserWaypoint();

    if (TomTom and TomTom.RemoveWaypoint) then
        TomTom:RemoveWaypoint(tomtomWaypointUid);
    end
end

local function OnEvent(self, event, questId)
    if (event == "ADDON_LOADED" and questId == ADDON_NAME) then
        self:UnregisterEvent(event);

        if (DecorTreasureHuntDB == nil) then
            DecorTreasureHuntDB = {
                autoAccept = true,
                autoTurnIn = true
            };
        end

        return;
    end

    if (event == "QUEST_COMPLETE") then
        if (not DTH.QuestData[GetQuestID()] or IsShiftKeyDown() or not DecorTreasureHuntDB.autoTurnIn) then
            return;
        end

        self:UnregisterEvent(event);
        GetQuestReward(1);
        print("|cffe6c619" .. addonTitle .. ":|r " .. L.QUEST_TURNIN);

        return;
    end

    if (event == "QUEST_DETAIL") then
        AcceptQuest();
        print("|cffe6c619" .. addonTitle .. ":|r " .. L.QUEST_ACCEPTED);

        return;
    end

    if (event == "QUEST_FINISHED") then
        self:UnregisterEvent("QUEST_DETAIL");
        return;
    end

    if (event == "GOSSIP_SHOW") then
        local guid = UnitGUID("npc");
        if (not guid or IsShiftKeyDown() or not DecorTreasureHuntDB.autoAccept) then
            return;
        end

        local npcId = tonumber((select(6, strsplit("-", guid))));
        if (npcId == QUEST_NPC_HORDE or npcId == QUEST_NPC_ALLIANCE) then
            for _, info in ipairs(C_GossipInfo.GetAvailableQuests() or {}) do
                if (DTH.QuestData[info.questID]) then
                    self:RegisterEvent("QUEST_DETAIL");
                    C_GossipInfo.SelectAvailableQuest(info.questID);
                    break;
                end
            end
        end

        return;
    end

    local data = DTH.QuestData[questId];

    if (event == "PLAYER_ENTERING_WORLD") then
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i);
            if (info and not info.isHeader) then
                data = DTH.QuestData[info.questID];

                if (data) then
                    questId = info.questID;
                    event = "QUEST_ACCEPTED";
                    break;
                end
            end
        end
    end

    if (not data) then
        return;
    end

    if (event == "QUEST_ACCEPTED") then
        SetWaypoint(data[1], data[2]);
        self:RegisterEvent("QUEST_COMPLETE");
    elseif (event == "QUEST_REMOVED") then
        ClearWaypoint();
        self:UnregisterEvent("QUEST_COMPLETE");
    end
end

local Handler = CreateFrame("Frame");
Handler:RegisterEvent("QUEST_ACCEPTED");
Handler:RegisterEvent("QUEST_REMOVED");
Handler:RegisterEvent("PLAYER_ENTERING_WORLD");
Handler:RegisterEvent("GOSSIP_SHOW");
Handler:RegisterEvent("QUEST_FINISHED");
Handler:RegisterEvent("ADDON_LOADED");
Handler:SetScript("OnEvent", OnEvent);
