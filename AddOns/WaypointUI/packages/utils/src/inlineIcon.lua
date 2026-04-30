local env = select(2, ...)
local Utils_InlineIcon = env.modules:New("packages\\utils\\inline-icon")

local CreateAtlasMarkup = CreateAtlasMarkup
local type = type
local assert = assert
local gsub = string.gsub
local format = string.format

function Utils_InlineIcon.New(texturePath, height, width, offsetX, offsetY, color)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local r, g, b, a
    if color then
        r, g, b, a = color.r or color[1], color.g or color[2], color.b or color[3], color.a or color[4]
        r, g, b = r or 1, g or 1, b or 1
        a = a or 1
    end

    if type(texturePath) == "table" then
        local atlas = texturePath.atlas
        if atlas then
            return CreateAtlasMarkup(atlas, width, height, offsetX, offsetY)
        end

        local file = texturePath.file or texturePath.path
        local tw = texturePath.width
        local th = texturePath.height
        local texLeft = texturePath.left
        local texRight = texturePath.right
        local texTop = texturePath.top
        local texBottom = texturePath.bottom
        assert(file, "`InlineIcon`: expected table.file for texture coord usage")
        assert(tw and th and texLeft and texRight and texTop and texBottom, "`InlineIcon`: expected width, height, left, right, top, bottom for texture coord usage")

        -- |Ttexture:dispWidth:dispHeight:offX:offY:texWidth:texHeight:texCoordLeft:texCoordRight:texCoordTop:texCoordBottom|r:g:b:a|t
        if r then
            return format("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t", file, width, height, offsetX, offsetY, tw, th, texLeft, texRight, texTop, texBottom, r, g, b, a)
        end
        return format("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t", file, width, height, offsetX, offsetY, tw, th, texLeft, texRight, texTop, texBottom)
    end

    if r then
        return format("|T%s:%d:%d:%d:%d:%g:%g:%g:%g|t", texturePath, width, height, offsetX, offsetY, r, g, b, a)
    end
    return "|T" .. texturePath .. ":" .. height .. ":" .. width .. ":" .. offsetX .. ":" .. offsetY .. "|t"
end

function Utils_InlineIcon.ApplyOffsetToIcon(iconString, newOffsetX, newOffsetY)
    return gsub(iconString, ":(%d+):(%d+)|a", ":" .. newOffsetX .. ":" .. newOffsetY .. "|a")
end

function Utils_InlineIcon.ApplyColorToIcon(iconString, r, g, b, a)
    r, g, b = r or 1, g or 1, b or 1
    a = a or 1
    local hasColor = iconString:match(":%-?[%d%.]+:%-?[%d%.]+:%-?[%d%.]+:%-?[%d%.]+|t$")
    if hasColor then
        iconString = iconString:gsub(":%-?[%d%.]+:%-?[%d%.]+:%-?[%d%.]+:%-?[%d%.]+|t$", "|t", 1)
    end
    return iconString:gsub("|t$", format(":%g:%g:%g:%g|t", r, g, b, a))
end
