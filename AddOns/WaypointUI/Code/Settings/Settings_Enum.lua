local env = select(2, ...)
local Settings_Enum = env.modules:New("@\\Settings\\Enum")

Settings_Enum.WidgetType = {
    Tab           = 1,
    Title         = 2,
    Container     = 3,
    Text          = 4,
    Range         = 5,
    Button        = 6,
    CheckButton   = 7,
    SelectionMenu = 8,
    ColorInput    = 9,
    Input         = 10
}

Settings_Enum.ImageType = {
    Large = 1,
    Small = 2
}
