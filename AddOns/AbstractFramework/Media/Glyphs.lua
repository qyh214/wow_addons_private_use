---@class AbstractFramework
---@field Glyphs AF_Glyphs
local AF = _G.AbstractFramework

AF.Glyphs = {}

---@class AF_Glyphs
local G = AF.Glyphs

---@param fs FontString
---@param size number
---@param outline "none" | "outline" | "monochrome_outline" | "monochrome"
function G.SetFont(fs, size, outline)
    local flags
    if outline == "none" then
        flags = ""
    elseif outline == "outline" then
        flags = "OUTLINE"
    elseif outline == "monochrome_outline" then
        flags = "OUTLINE,MONOCHROME"
    elseif outline == "monochrome" then
        flags = "MONOCHROME"
    end

    fs:SetFont(AF.GetFont("Glyphs"), size, flags)
end

---@param fs FontString
---@param glyph table AF.Glyphs.Faction.Horde | AF.Glyphs.Role.TANK | AF.Glyphs.Group.leader | AF.Glyphs.Marker[1] | AF.Glyphs.Combat | etc.
function G.SetGlyph(fs, glyph)
    if type(glyph) == "table" then
        fs:SetText(glyph.char)
        fs:SetTextColor(AF.UnpackColor(glyph.color))
    else
        fs:SetText("")
    end
end

---------------------------------------------------------------------
-- glyphs
---------------------------------------------------------------------
--! CodePoints -> Unicode -> Decimal
-- https://onlinetools.com/unicode/convert-code-points-to-unicode

G.Faction = {
    Horde = {char = "\238\128\128", color = AF.GetColorTable("Horde")},
    Alliance = {char = "\238\128\129", color = AF.GetColorTable("Alliance")},
}

G.Role  = {
    TANK = {char = "\238\128\130", color = AF.GetColorTable("TANK")},
    HEALER = {char = "\238\128\131", color = AF.GetColorTable("HEALER")},
    DAMAGER = {char = "\238\128\132", color = AF.GetColorTable("DAMAGER")},
}

G.Group = {
    leader = {char = "\238\128\133", color = {0.95, 0.86, 0.03}},
    assistant = {char = "\238\128\134", color = {0.95, 0.86, 0.03}},
}

G.Marker = {
    {char = "\238\128\135", color = {1, 1, 0.25}}, -- star
    {char = "\238\128\136", color = {1, 0.49, 0}}, -- circle
    {char = "\238\128\137", color = {0.91, 0.31, 0.98}}, -- diamond
    {char = "\238\128\138", color = {0.03, 0.88, 0}}, -- triangle
    {char = "\238\128\139", color = {0.83, 0.95, 1}}, -- moon
    {char = "\238\128\140", color = {0, 0.68, 1}}, -- square
    {char = "\238\128\141", color = {1, 0.27, 0.18}}, -- cross
    {char = "\238\128\142", color = {0.95, 0.95, 0.95}}, -- skull
}

G.Combat = {char = "\238\128\143", color = {0.85, 0.85, 0.85}}