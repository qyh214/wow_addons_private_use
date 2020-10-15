--[[
    Confirmation Dialogue Name: CONFIRM_PLAYER_CHOICE   Are you sure you wish to join this Covenant?
    Quest: Choose Your Purpose  57878 Speak to the Covenants: Preview covenant abilities, descriptions
    C_QuestLog.IsQuestFlaggedCompleted(57878)
    Events: COVENANT_CHOSEN
    Blizzard_CovenantChoiceToast.lua

    local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
    C_Covenants.GetCovenantData(covenantID) --  .name: 1.Kyrian 2.Venthyr 3.Night Fae 4.Necrolord


    C_GossipInfo.GetText()
    strlenutf8()    --Count letters
--]]

local List = {
    {
        name = "CovenantWalkthrough",
        type = "Duration",
        flagType = "Quest",
        flagArg = 57878,
        startEvent = "Quest",
        startArg = 57878,
        startEvent = "ADDON_LOADED",
        stopArg = "Blizzard_PlayerChoiceUI",
    },

    {
        name = "CovenantDecision",
        type = "Duration",
        flagType = "Quest",
        flagArg = 57878,
        startEvent = "ADDON_LOADED",
        startArg = "Blizzard_PlayerChoiceUI",
        stopEvent = "COVENANT_CHOSEN",
    },

    {
        name = "LevelingTime",
        type = "ExactTime",
        flagType = "Function",
        flagArg = function() return UnitLevel("player") == GetMaxLevelForExpansionLevel( GetExpansionLevel() ) end,
        isRepeated = true,
        startEvent = "PLAYER_LEVEL_UP",
    },
};


local StatManager = {};

function StatManager:LoadData()
    if not NarciStatisticsDB then
        NarciStatisticsDB = {};
    end
    if not NarciStatisticsDB_PC then
        NarciStatisticsDB_PC = {};
    end
end

local IsTrackingComplete = false;
local events = {"GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_ACCEPTED", "QUEST_TURNED_IN", "ADDON_LOADED", "PLAYER_CHOICE_UPDATE", "PLAYER_CHOICE_CLOSE"}
local EventListener = CreateFrame("Frame");
EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");

for i = 1, #events do
    --EventListener:RegisterEvent(events[i]);
end

EventListener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        StatManager:LoadData()
    end
    --print(event);
    --print(...)
end)

--[[
hooksecurefunc("StaticPopup_Show", function(name)
    print(name)
end)
--]]