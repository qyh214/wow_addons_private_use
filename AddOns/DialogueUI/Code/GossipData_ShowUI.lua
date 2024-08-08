-- Show UIParent immediately after clicking on this option
-- These options usually open other Blizzard Interface, which may not work correctly if the UIParent is hidden  

local _, addon = ...
local GossipDataProvider = addon.GossipDataProvider;
local IsTargetAdventureMap = addon.API.IsTargetAdventureMap;

local ShowUIGossip = {
    [64058] = true,     --Iskaaran Fishing Gear
    [55556] = true,     --Iskaara Renown
    [54514] = true,     --Maruuk Renown
    [55557] = true,     --Valdrakken Renown
    [54632] = true,     --Dragonscale Renown   
};

function GossipDataProvider:DoesOptionOpenUI(gossipOptionID)
    --if IsTargetAdventureMap() then
    --    return true
    --end

    return gossipOptionID and ShowUIGossip[gossipOptionID] == true
end