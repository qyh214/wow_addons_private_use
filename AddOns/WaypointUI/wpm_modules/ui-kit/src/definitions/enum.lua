local env        = select(2, ...)
local UIKit_Enum = env.WPM:New("wpm_modules/ui-kit/enum")


-- Prop
--------------------------------

UIKit_Enum.FrameStrata = {
    Tooltip          = "TOOLTIP",
    FullscreenDialog = "FULLSCREEN_DIALOG",
    Fullscreen       = "FULLSCREEN",
    Dialog           = "DIALOG",
    High             = "HIGH",
    Medium           = "MEDIUM",
    Low              = "LOW",
    Background       = "BACKGROUND",
    World            = "WORLD"
}

UIKit_Enum.Point       = {
    Top         = "TOP",
    TopLeft     = "TOPLEFT",
    TopRight    = "TOPRIGHT",
    Center      = "CENTER",
    Left        = "LEFT",
    Right       = "RIGHT",
    Bottom      = "BOTTOM",
    BottomLeft  = "BOTTOMLEFT",
    BottomRight = "BOTTOMRIGHT"
}

UIKit_Enum.BlendMode   = {
    Disable  = "DISABLE",
    Blend    = "BLEND",
    AlphaKey = "ALPHAKEY",
    Add      = "ADD",
    Mod      = "MOD"
}

UIKit_Enum.Direction   = {
    Both       = "BOTH",
    Vertical   = "VERTICAL",
    Horizontal = "HORIZONTAL",
    Leading    = "LEADING",
    Justified  = "JUSTIFIED",
    Trailing   = "TRAILING"
}

UIKit_Enum.Orientation = {
    Horizontal = "HORIZONTAL",
    Vertical   = "VERTICAL"
}


-- Flag
--------------------------------

UIKit_Enum.UpdateMode = {
    None                      = "NONE",
    ChildrenVisibilityChanged = "CHILDREN_VISIBILITY_CHANGED",
    ExcludeVisibilityChanged  = "EXCLUDE_VISIBILITY_CHANGED",
    UserUpdate                = "USER_UPDATE",
    All                       = "ALL"
}
