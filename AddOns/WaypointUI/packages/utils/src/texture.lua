local env = select(2, ...)
local Utils_Texture = env.modules:New("packages\\utils\\texture")

local CreateFrame = CreateFrame

function Utils_Texture.Preload(texturePath)
    CreateFrame("Frame"):CreateTexture():SetTexture(texturePath)
end
