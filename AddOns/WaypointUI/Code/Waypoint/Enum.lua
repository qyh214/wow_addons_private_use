local env = select(2, ...)
local Waypoint_Enum = env.WPM:New("@/Waypoint/Enum")


-- General
--------------------------------

Waypoint_Enum.NavigationMode = {
    Hidden    = -1,
    Waypoint  = 1,
    Pinpoint  = 2,
    Navigator = 3
}

Waypoint_Enum.TrackingType = {
    QuestCompleteRecurring = 1,
    QuestCompleteImportant = 2,
    QuestComplete          = 3,
    QuestIncomplete        = 4,
    Corpse                 = 5,
    Other                  = 6
}

Waypoint_Enum.State = {
    Invalid        = 0,
    InvalidRange   = 1,
    QuestProximity = 2,
    QuestArea      = 3,
    Proximity      = 4,
    Area           = 5
}


-- Setting
--------------------------------

Waypoint_Enum.WaypointSystemType = {
    All      = 1,
    Waypoint = 2,
    Pinpoint = 3
}

Waypoint_Enum.WaypointDistanceTextType = {
    All             = 1,
    Distance        = 2,
    ArrivalTime     = 3,
    DestinationName = 4,
    None            = 5
}
