local env                = select(2, ...)

local type               = type
local assert             = assert
local string_gsub        = string.gsub
local CreateAtlasMarkup  = CreateAtlasMarkup

local Utils_InlineIcon   = env.WPM:New("wpm_modules/utils/inlineIcon")


-- API
--------------------------------

function Utils_InlineIcon.InlineIcon(texturePath, height, width, offsetX, offsetY, textureType)
    assert(texturePath, "`InlineIcon`: expected string `path`, got " .. type(texturePath))
    assert(height, "`InlineIcon`: expected number `height`, got " .. type(height))
    assert(width, "`InlineIcon`: expected number `width`, got " .. type(width))

    offsetX = offsetX or 0
    offsetY = offsetY or 0

    if textureType == "Atlas" then
        return CreateAtlasMarkup(texturePath, width, height, offsetX, offsetY)
    end

    return "|T" .. texturePath .. ":" .. height .. ":" .. width .. ":" .. offsetX .. ":" .. offsetY .. "|t"
end

function Utils_InlineIcon.IconOffset(iconString, newOffsetX, newOffsetY)
    return string_gsub(iconString, ":(%d+):(%d+)|a", ":" .. newOffsetX .. ":" .. newOffsetY .. "|a")
end
