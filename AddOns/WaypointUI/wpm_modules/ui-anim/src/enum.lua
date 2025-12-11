local env         = select(2, ...)
local UIAnim_Enum = env.WPM:New("wpm_modules/ui-anim/enum")


UIAnim_Enum.Easing = {
    Linear       = "Linear",
    QuadIn       = "QuadIn",
    QuadOut      = "QuadOut",
    QuadInOut    = "QuadInOut",
    CubicIn      = "CubicIn",
    CubicOut     = "CubicOut",
    CubicInOut   = "CubicInOut",
    QuartIn      = "QuartIn",
    QuartOut     = "QuartOut",
    QuartInOut   = "QuartInOut",
    QuintIn      = "QuintIn",
    QuintOut     = "QuintOut",
    QuintInOut   = "QuintInOut",
    ExpoIn       = "ExpoIn",
    ExpoOut      = "ExpoOut",
    ExpoInOut    = "ExpoInOut",
    CircIn       = "CircIn",
    CircOut      = "CircOut",
    CircInOut    = "CircInOut",
    BackIn       = "BackIn",
    BackOut      = "BackOut",
    BackInOut    = "BackInOut",
    ElasticIn    = "ElasticIn",
    ElasticOut   = "ElasticOut",
    ElasticInOut = "ElasticInOut",
    BounceIn     = "BounceIn",
    BounceOut    = "BounceOut",
    BounceInOut  = "BounceInOut",
    SmoothStep   = "SmoothStep",
    SmootherStep = "SmootherStep"
}

UIAnim_Enum.Looping = {
    Reset = "reset",
    Yoyo  = "yoyo"
}

UIAnim_Enum.Property = {
    Alpha  = "alpha",
    Width  = "width",
    Height = "height",
    PosX   = "x",
    PosY   = "y",
    Scale  = "scale"
}
