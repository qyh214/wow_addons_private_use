local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Settings_Preload = env.modules:New("@\\Settings\\Preload")

local ATLAS_TAB_BUTTON = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Settings\\TabButton", inset = 16 }
local ATLAS_CONTAINER = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Settings\\Widget-Container", inset = 18, sliceMode = Enum.UITextureSliceMode.Stretched }
Settings_Preload.UIDEF = {
    UITabButton                     = UIKit.UI.TEXTURE_NIL,
    UITabButton_Highlighted         = ATLAS_TAB_BUTTON{ left = 0 / 256, top = 0 / 128, right = 64 / 256, bottom = 64 / 128, scale = 0.6 },
    UITabButton_Pushed              = ATLAS_TAB_BUTTON{ left = 64 / 256, top = 0 / 128, right = 128 / 256, bottom = 64 / 128, scale = 0.6 },
    UITabButtonSelected             = ATLAS_TAB_BUTTON{ left = 0 / 256, top = 64 / 128, right = 64 / 256, bottom = 128 / 128, scale = 0.6 },
    UITabButtonSelected_Highlighted = ATLAS_TAB_BUTTON{ left = 64 / 256, top = 64 / 128, right = 128 / 256, bottom = 128 / 128, scale = 0.6 },
    UITabButtonSelected_Pushed      = ATLAS_TAB_BUTTON{ left = 128 / 256, top = 64 / 128, right = 192 / 256, bottom = 128 / 128, scale = 0.6 },

    UICContainer                    = ATLAS_CONTAINER{ left = 0 / 128, right = 64 / 128, top = 0 / 64, bottom = 64 / 64, scale = 1 },
    UICSubcontainer                 = ATLAS_CONTAINER{ left = 64 / 128, right = 128 / 128, top = 0 / 64, bottom = 64 / 64, scale = 1 },

    UIWidget                        = UIKit.Define.Texture_NineSlice{ path = Path.Root .. "\\Art\\Settings\\Widget-Background", inset = 14, scale = 0.5, sliceMode = Enum.UITextureSliceMode.Stretched },
    Divider                         = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Primitives\\Box" }
}

Settings_Preload.NAME = env.NAME
Settings_Preload.FRAME_NAME = "WUISettingFrame"
Settings_Preload.DB_GLOBAL_NAME = "WaypointDB_Global"
