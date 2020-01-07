-------------------------------------------
----ModelFileIDs and Names by Peterodox----
-------------------------------------------
--Creature DisplayID
--/dump NarciNPCModelFrame2:GetModelFileID()
--/run NarciNPCModelFrame4:EquipItem(120978)

local _G = _G;

function Narci:SetModelByDisplayID(index, displayID)
    if not index or not displayID then
        print("Format: (index, displayID)");
        return;
    end

    local model = _G["NarciNPCModelFrame"..index] or _G["NarciPlayerModelFrame"..index];
    if model then
        model:SetDisplayInfo(displayID);
    else
        print("Can't find model frame #"..displayID)
    end
end

--[[
local ModelFileIDName = {
    --#8.2.5
    --Caching Issue
    {"921844", "928144"}, --Shandris Feathermoon Sheathed Dagger
    {"1734034"},       --Magister Umbric
    {""},       --Genn Greymane Human form


    --Confirmed No Caching Issue
    {"1245874"},    --Sylvanas Windrunner
    {"1624825"},    --Alleria Windrunner Regular
    {"1738454"},    --High Overlord Saurfang

}
--]]