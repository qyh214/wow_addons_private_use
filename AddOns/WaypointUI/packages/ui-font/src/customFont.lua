local env = select(2, ...)

local sort = table.sort
local wipe = table.wipe
local tinsert = table.insert

local UIFont_CustomFont = env.modules:New("packages\\ui-font\\custom-font")


local LibSharedMedia = nil

local function GetLibSharedMedia()
    if not LibSharedMedia and LibStub then
        LibSharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true)
    end
    return LibSharedMedia ~= nil
end


local fonts = { names = {}, paths = {} }

function UIFont_CustomFont.RefreshFontList()
    wipe(fonts.names)
    wipe(fonts.paths)

    -- Always add the default game font first
    local gameFontPath = GameFontNormal:GetFont()
    tinsert(fonts.names, "Game Font")
    tinsert(fonts.paths, gameFontPath)

    -- Populate LibSharedMedia fonts
    if GetLibSharedMedia() then
        local lsmFonts = {}
        for name, path in pairs(LibSharedMedia:HashTable("font")) do
            tinsert(lsmFonts, { name = name, path = path })
        end

        sort(lsmFonts, function(a, b) return a.name < b.name end)

        for _, font in ipairs(lsmFonts) do
            tinsert(fonts.names, font.name)
            tinsert(fonts.paths, font.path)
        end
    end
end

function UIFont_CustomFont.GetFontNames()
    return fonts.names
end

function UIFont_CustomFont.GetFontPaths()
    return fonts.paths
end

function UIFont_CustomFont.GetFontPathForIndex(index)
    if fonts.paths[index] == nil then
        return fonts.paths[1]
    end
    return fonts.paths[index]
end

function UIFont_CustomFont.GetFontIndexForPath(path)
    if not path then return end

    for i = 1, #fonts.paths do
        if fonts.paths[i] == path then
            return i
        end
    end
end

function UIFont_CustomFont.FontExists(path)
    if not path then return end
    return UIFont_CustomFont.GetFontIndexForPath(path) ~= nil
end

function UIFont_CustomFont.GetFontInfoForIndex(index)
    if index < 1 or index > #fonts.names then return end
    return fonts.names[index], fonts.paths[index]
end
