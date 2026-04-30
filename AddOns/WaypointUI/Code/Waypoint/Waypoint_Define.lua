local env = select(2, ...)
local Struct = env.modules:Import("packages\\struct").New
local Waypoint_Define = env.modules:New("@\\Waypoint\\Define")

Waypoint_Define.ContextIconTexture = Struct{
    requestRecolor = false,
    type           = nil,
    path           = nil
}

Waypoint_Define.ObjectiveInfo = Struct{
    objectives       = nil,
    isMultiObjective = nil
}

Waypoint_Define.RedirectInfo = Struct{
    valid = nil,
    x     = nil,
    y     = nil,
    text  = nil
}
