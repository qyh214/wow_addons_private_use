local env          = select(2, ...)
local Struct       = env.WPM:Import("wpm_modules/struct").New
local UIKit_Define = env.WPM:New("wpm_modules/ui-kit/define")


-- Values
--------------------------------

UIKit_Define.Num = Struct{
    value = nil
}

UIKit_Define.Percentage = Struct{
    value    = nil,
    operator = nil,
    delta    = nil
}

UIKit_Define.Fit = Struct{
    delta = nil
}

UIKit_Define.Fill = Struct{
    -- Apply padding to all sides
    delta  = nil,

    -- or, apply padding to each sides
    left   = nil,
    right  = nil,
    top    = nil,
    bottom = nil
}


-- Color
--------------------------------

UIKit_Define.Color_RGBA = Struct{
    r = 0,
    g = 0,
    b = 0,
    a = 1
}

UIKit_Define.Color_HEX = Struct{
    hex = "ffffffff"
}


-- Texture
--------------------------------

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
    -- Atlas info
    path      = nil,
    inset     = nil,
    scale     = nil,
    sliceMode = nil,

    -- Texture info (Recommended to declare as a substruct)
    left      = nil,
    top       = nil,
    right     = nil,
    bottom    = nil
}
