local env                = select(2, ...)
local Struct             = env.WPM:Import("wpm_modules/struct").New
local Setting_Define      = env.WPM:New("@/Setting/Define")

Setting_Define.TitleInfo  = Struct{
    imagePath = nil,
    text      = nil,
    subtext   = nil
}

Setting_Define.Descriptor = Struct{
    imageType   = nil,
    imagePath   = nil,
    description = nil
}
