---@class AbstractFramework
local AF = _G.AbstractFramework

local format = string.format

---------------------------------------------------------------------
-- get icon
---------------------------------------------------------------------
---@param icon string fileName
---@param addon? string addonFolderName
---@return string iconPath
function AF.GetIcon(icon, addon)
    if AF.IsBlank(icon) then return "" end

    if addon then
        return "Interface\\AddOns\\" .. addon .. "\\Media\\Icons\\" .. icon
    else
        return "Interface\\AddOns\\AbstractFramework\\Media\\Icons\\" .. icon
    end
end

---@param icon string fileName
---@param height? number
---@param width? number
---@param addon? string addonFolderName
---@return string iconString "|T..|t" escape sequence
function AF.GetIconString(icon, height, width, addon)
    return AF.EscapeIcon(AF.GetIcon(icon, addon), height, width)
end

-- refer to TextureUtil.lua, this should not work anymore
-- local function EscapeIconWithColor(iconPath, height, width, color)
--     local r, g, b
--     if type(color) == "string" then
--         r, g, b = AF.GetColorRGB(color)
--     elseif type(color) == "table" then
--         r, g, b = AF.UnpackColor(color)
--     end

--     assert(r and g and b, "Invalid color format. Use string or table with RGB values.")

--     r, g, b = AF.ConvertToRGB256(r, g, b)

--     if not height then
--         return format("|T%s:0:0:::::::::%d:%d:%d|t", iconPath, r, g, b)
--     elseif not width then
--         -- NOTE: "aspectRatio" only works when height is set to 0
--         return format("|T%s:%s::::::::::%d:%d:%d|t", iconPath, height, r, g, b)
--     else
--         return format("|T%s:%s:%s:::::::::%d:%d:%d|t", iconPath, height, width, r, g, b)
--     end
-- end

---@param iconPath string
---@param height? number
---@param width? number
---@return string iconString "|T..|t" escape sequence
function AF.EscapeIcon(iconPath, height, width)
    if AF.IsBlank(iconPath) then return "" end

    if not height then
        return format("|T%s:0:aspectRatio|t", iconPath)
    elseif not width then
        -- NOTE: "aspectRatio" only works when height is set to 0
        return format("|T%s:%s|t", iconPath, height)
    else
        return format("|T%s:%s:%s|t", iconPath, height, width)
    end
end

function AF.EscapeAtlas(atlas, width, height)
    return format("|A:%s:%d:%d|a", atlas, height or 0, width or 0)
end

function AF.EscapeRaidIcon(raidIconIndex)
    raidIconIndex = raidIconIndex - 1
    local left, right, top, bottom
    local coordIncrement = 64 / 256
    left = mod(raidIconIndex, 4) * coordIncrement
    right = left + coordIncrement
    top = floor(raidIconIndex / 4) * coordIncrement
    bottom = top + coordIncrement
    return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcons:0:0:0:0:64:64:%d:%d:%d:%d|t", left * 64, right * 64, top * 64, bottom * 64)
end

function AF.GetLogo(brand)
    return "Interface\\AddOns\\AbstractFramework\\Media\\Logos\\" .. brand
end

---------------------------------------------------------------------
-- get texture
---------------------------------------------------------------------
---@param texture string fileName
---@param addon? string addonFolderName
---@return string texturePath
function AF.GetTexture(texture, addon)
    if addon then
        return "Interface\\AddOns\\" .. addon .. "\\Media\\Textures\\" .. texture
    else
        return "Interface\\AddOns\\AbstractFramework\\Media\\Textures\\" .. texture
    end
end

---------------------------------------------------------------------
-- get plain texture
---------------------------------------------------------------------
---@return string plainTexturePath
function AF.GetPlainTexture()
    return "Interface\\AddOns\\AbstractFramework\\Media\\Textures\\White"
end

---------------------------------------------------------------------
-- get empty texture
---------------------------------------------------------------------
---@return string emptyTexturePath
function AF.GetEmptyTexture()
    return "Interface\\AddOns\\AbstractFramework\\Media\\Textures\\Empty"
end

---------------------------------------------------------------------
-- get sound
---------------------------------------------------------------------
---@param sound string fileName
---@param addon? string addonFolderName
---@return string soundPath
function AF.GetSound(sound, addon)
    if addon then
        return "Interface\\AddOns\\" .. addon .. "\\Media\\Sounds\\" .. sound .. ".ogg"
    else
        return "Interface\\AddOns\\AbstractFramework\\Media\\Sounds\\" .. sound .. ".ogg"
    end
end

---------------------------------------------------------------------
-- play sound
---------------------------------------------------------------------
---@param channel string Master|Music|SFX|Ambience|Dialog
---@return boolean willPlay
---@return number soundHandle
function AF.PlaySound(sound, addon, channel)
    return PlaySoundFile(AF.GetSound(sound, addon), channel or "Master")
end

---------------------------------------------------------------------
-- get fonts
---------------------------------------------------------------------
---@param font string fileName
---@param addon? string addonFolderName
---@return string fontPath
function AF.GetFont(font, addon)
    if addon then
        return "Interface\\AddOns\\" .. addon .. "\\Media\\Fonts\\" .. font .. ".ttf"
    else
        return "Interface\\AddOns\\AbstractFramework\\Media\\Fonts\\" .. font .. ".ttf"
    end
end

---------------------------------------------------------------------
-- get profession icon
---------------------------------------------------------------------
local professions = {
    [171] = "Alchemy",
    [164] = "Blacksmithing",
    [333] = "Enchanting",
    [202] = "Engineering",
    [773] = "Inscription",
    [755] = "Jewelcrafting",
    [165] = "Leatherworking",
    [393] = "Skinning",
    [197] = "Tailoring",
    [182] = "Herbalism",
    [186] = "Mining",
    [185] = "Cooking",
    [356] = "Fishing",
    [794] = "Archaeology",
    [129] = "FirstAid",
}

---@param profession number|string professionID or professionName(EN)
function AF.GetProfessionIcon(profession)
    if type(profession) == "number" then
        profession = professions[profession]
    end
    if profession then
        return AF.GetIcon("Profession_" .. profession)
    else
        return AF.GetIcon("QuestionMark")
    end
end