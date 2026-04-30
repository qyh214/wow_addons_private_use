local env = select(2, ...)
local Struct = env.modules:Import("packages\\struct").New
local UIKit_Define = env.modules:New("packages\\ui-kit\\define")

UIKit_Define.Percentage = Struct{
    value    = nil,
    operator = nil,
    delta    = nil
}

UIKit_Define.Fit = Struct{
    delta = nil
}

UIKit_Define.Fill = Struct{
    -- Uniform padding
    delta  = nil,

    -- Per-side padding
    left   = nil,
    right  = nil,
    top    = nil,
    bottom = nil
}

UIKit_Define.Color_RGBA = Struct{
    r = 0,
    g = 0,
    b = 0,
    a = 1
}

UIKit_Define.Color_HEX = Struct{
    hex = "ffffffff"
}

UIKit_Define.Texture = Struct{
    path = nil
}

UIKit_Define.Texture_NineSlice = Struct{
    path      = nil,
    inset     = nil,
    scale     = nil,
    sliceMode = nil
}

UIKit_Define.Texture_Backdrop = Struct{
    bgFile   = nil,
    edgeFile = nil,
    tile     = nil,
    tileSize = nil,
    edgeSize = nil,
    insets   = nil
}

UIKit_Define.Texture_Atlas = Struct{
    -- Atlas
    path      = nil,
    inset     = nil,
    scale     = nil,
    sliceMode = nil,

    -- Texture coordinates (optional)
    left      = nil,
    top       = nil,
    right     = nil,
    bottom    = nil
}
