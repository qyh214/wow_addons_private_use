local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local UICCommonPreload = env.modules:New("packages\\uic-common\\preload")

Utils_Texture.Preload(Path.Root .. "\\packages\\uic-common\\resources\\common")
UICCommonPreload.ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\packages\\uic-common\\resources\\common" }
