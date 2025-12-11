local env = select(2, ...)
local Setting_Enum = env.WPM:New("@/Setting/Enum")

Setting_Enum.WidgetType = {
    Tab           = 1,
    Title         = 2,
    Container     = 3,
    Text          = 4,
    Range         = 5,
    Button        = 6,
    CheckButton      = 7,
    SelectionMenu = 8,
    ColorInput    = 9,
    Input         = 10
}

Setting_Enum.ImageType = {
    Large = 1,
    Small = 2
}
