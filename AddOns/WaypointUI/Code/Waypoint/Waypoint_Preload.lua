local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local Waypoint_Preload = env.modules:New("@\\Waypoint\\Preload")

local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Waypoint\\Waypoint" }
Utils_Texture.Preload(Path.Root .. "\\Art\\Waypoint\\Waypoint")
Waypoint_Preload.UIDEF = {
    ContextIcon          = ATLAS{ left = 0 / 1024, right = 128 / 1024, top = 128 / 1024, bottom = 256 / 1024 },
    UIWaypointBeam       = ATLAS{ left = 693/1024, right = 843/1024, top = 0/1024, bottom = 1024/1024 },
    UIWaypointBeamFX     = ATLAS{ left = 896 / 1024, right = 1024 / 1024, top = 0 / 1024, bottom = 1024 / 1024 },
    UIWaypointWave       = ATLAS{ left = 512 / 1792, right = 768 / 1792, top = 256 / 2560, bottom = 512 / 2560 },
    UIWaypointBeamMask   = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Waypoint\\Mask-Beam" },
    UIWaypointBeamFXMask = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Waypoint\\Mask-BeamFX" },
    UIPinpoint           = ATLAS{ inset = 32, scale = 0.25, left = 0 / 1024, right = 256 / 1024, top = 0 / 1024, bottom = 128 / 1024 },
    UIPinpointArrow      = ATLAS{ left = 256 / 1024, right = 384 / 1024, top = 0 / 1024, bottom = 128 / 1024 },
    UINavigatorArrow     = ATLAS{ left = 0 / 1024, right = 128 / 1024, top = 256 / 1024, bottom = 384 / 1024 }
}
