local env = select(2, ...)
local UIAnim_Enum = env.modules:New("packages\\ui-anim\\enum")

UIAnim_Enum.Easing = {
    Linear       = "Linear",
    SineIn       = "SineIn",
    SineOut      = "SineOut",
    SineInOut    = "SineInOut",
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
    Reset = 1,
    Yoyo  = 2
}

UIAnim_Enum.Property = {
    Alpha    = 1,
    Width    = 2,
    Height   = 3,
    PosX     = 4,
    PosY     = 5,
    Scale    = 6,
    Rotation = 7
}
