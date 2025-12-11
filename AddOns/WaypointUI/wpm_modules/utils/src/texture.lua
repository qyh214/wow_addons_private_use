local env           = select(2, ...)

local CreateFrame   = CreateFrame

local Utils_Texture = env.WPM:New("wpm_modules/utils/texture")


-- API
--------------------------------

function Utils_Texture.PreloadAsset(texturePath)
    CreateFrame("Frame"):CreateTexture():SetTexture(texturePath)
end
