local env = select(2, ...)
local Config = env.Config

local SetSuperTrackedUserWaypoint   = C_SuperTrack.SetSuperTrackedUserWaypoint
local SetUserWaypoint               = C_Map.SetUserWaypoint
local hooksecurefunc                = hooksecurefunc
local CreateVector2D                = CreateVector2D
local UiMapPoint_CreateFromVector2D = UiMapPoint.CreateFromVector2D


-- Events
--------------------------------

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    local Setting_AutoTrackChatLinkPinEnabled = Config.DBGlobal:GetVariable("AutoTrackChatLinkPinEnabled")
    if not Setting_AutoTrackChatLinkPinEnabled then return end

    local prefix, mapID, x, y = link:match("^(%a+):(%d+):(%d+):(%d+)$")
    if prefix ~= "worldmap" then return end

    x = x / 100
    y = y / 100

    local pos = CreateVector2D(x / 100, y / 100)
    local mapPoint = UiMapPoint_CreateFromVector2D(mapID, pos)

    SetUserWaypoint(mapPoint)
    SetSuperTrackedUserWaypoint(true)
end)
