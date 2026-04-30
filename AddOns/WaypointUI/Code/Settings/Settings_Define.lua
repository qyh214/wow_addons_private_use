local env = select(2, ...)
local Struct = env.modules:Import("packages\\struct").New
local Settings_Define = env.modules:New("@\\Settings\\Define")

Settings_Define.TitleInfo = Struct{
    imagePath = nil,
    text      = nil,
    subtext   = nil
}

Settings_Define.Descriptor = Struct{
    imageType   = nil,
    imagePath   = nil,
    description = nil
}
