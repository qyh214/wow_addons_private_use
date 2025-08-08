---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- colors
---------------------------------------------------------------------
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClassBase = UnitClassBase
local UnitGUID = UnitGUID

local ACCENT_COLOR = {["hex"] = "ffff6600", ["t"] = {1, 0.4, 0, 1}, ["normal"] = {1, 0.4, 0, 0.3}, ["hover"] = {1, 0.4, 0, 0.6}}
local ACCENT_COLOR_ALT = {["hex"] = "ffff0066", ["t"] = {1, 0, 0.4, 1}, ["normal"] = {1, 0, 0.4, 0.3}, ["hover"] = {1, 0, 0.4, 0.6}}

local COLORS = {
    -- accent
    ["accent"] = AF.Copy(ACCENT_COLOR),

    -- default accent
    ["blazing_tangerine"] = AF.Copy(ACCENT_COLOR), -- 炽热橘
    ["vivid_raspberry"] = AF.Copy(ACCENT_COLOR_ALT), -- 炫莓粉

    -- for regions
    ["background"] = {["hex"] = "d91a1a1a", ["t"] = {0.1, 0.1, 0.1, 0.85}},
    ["border"] = {["hex"] = "ff000000", ["t"] = {0, 0, 0, 1}},
    ["header"] = {["hex"] = "ff202020", ["t"] = {0.127, 0.127, 0.127, 1}}, -- header background
    ["widget"] = {["hex"] = "ff262626", ["t"] = {0.15, 0.15, 0.15, 1}}, -- widget background
    ["mask"] = {["hex"] = "b3333333", ["t"] = {0.2, 0.2, 0.2, 0.7}},
    ["combat_mask"] = {["hex"] = "bf332b2b", ["t"] = {0.2, 0.17, 0.17, 0.75}},
    ["disabled"] = {["hex"] = "ff666666", ["t"] = {0.4, 0.4, 0.4, 1}},
    ["none"] = {["hex"] = "00000000", ["t"] = {0, 0, 0, 0}},
    ["yellow_text"] = {["hex"] = "ffffd100", ["t"] = {1, 0.82, 0, 1}},
    ["shadow"] = {["hex"] = "3f000000", ["t"] = {0, 0, 0, 0.25}},

    -- sheet
    ["sheet_normal"] = {["t"] = {0.15, 0.15, 0.15, 0.9}}, -- row/column normal
    ["sheet_normal2"] = {["t"] = {0.17, 0.17, 0.17, 0.9}}, -- row/column normal
    ["sheet_highlight"] = {["t"] = {0.2, 0.2, 0.2, 0.9}}, -- row/column highlight
    ["sheet_cell_highlight"] = {["t"] = {0.3, 0.3, 0.3, 0.9}},

    -- common
    ["red"] = {["hex"] = "ffff0000", ["t"] = {1, 0, 0, 1}},
    ["yellow"] = {["hex"] = "ffffff00", ["t"] = {1, 1, 0, 1}},
    ["green"] = {["hex"] = "ff00ff00", ["t"] = {0, 1, 0, 1}},
    ["cyan"] = {["hex"] = "ff00ffff", ["t"] = {0, 1, 1, 1}},
    ["blue"] = {["hex"] = "ff0000ff", ["t"] = {0, 0, 1, 1}},
    ["purple"] = {["hex"] = "ffff00ff", ["t"] = {1, 0, 1, 1}},
    ["white"] = {["hex"] = "ffffffff", ["t"] = {1, 1, 1, 1}},
    ["black"] = {["hex"] = "ff000000", ["t"] = {0, 0, 0, 1}},

    -- coin colors
    ["coin_gold"] = {["hex"] = "ffffd300", ["t"] = {1, 0.827, 0, 1}},
    ["coin_silver"] = {["hex"] = "ffb2b2b2", ["t"] = {0.7, 0.7, 0.7, 1}},
    ["coin_copper"] = {["hex"] = "ffcc7f3f", ["t"] = {0.8, 0.5, 0.25, 1}},

    -- others
    ["darkgray"] = {["hex"] = "ff919191", ["t"] = {0.57, 0.57, 0.57, 1}},
    ["gray"] = {["hex"] = "ffb2b2b2", ["t"] = {0.7, 0.7, 0.7, 1}},
    ["lightgray"] = {["hex"] = "ffd3d3d3", ["t"] = {0.83, 0.83, 0.83, 1}},
    ["sand"] = {["hex"] = "ffeccc68", ["t"] = {0.93, 0.8, 0.41, 1}},
    ["gold"] = {["hex"] = "ffffd300", ["t"] = {1, 0.827, 0, 1}},
    ["darkred"] = {["hex"] = "ff402020", ["t"] = {0.17, 0.13, 0.13, 1}},
    ["orange"] = {["hex"] = "ffffa502", ["t"] = {1, 0.65, 0.01, 1}},
    ["orangered"] = {["hex"] = "ffff4f00", ["t"] = {1, 0.31, 0, 1}},
    ["firebrick"] = {["hex"] = "ffff3030", ["t"] = {1, 0.19, 0.19, 1}},
    ["coral"] = {["hex"] = "ffff7f50", ["t"] = {1, 0.5, 0.31, 1}},
    ["tomato"] = {["hex"] = "ffff6348", ["t"] = {1, 0.39, 0.28, 1}},
    ["lightred"] = {["hex"] = "ffff4757", ["t"] = {1, 0.28, 0.34, 1}},
    ["classicrose"] = {["hex"] = "fffbcce7", ["t"] = {0.98, 0.8, 0.91, 1}},
    ["lavender"] = {["hex"] = "fff5baff", ["t"] = {0.96, 0.73, 1, 1}},
    ["pink"] = {["hex"] = "fffb7299", ["t"] = {0.98, 0.45, 0.6, 1}},
    ["hotpink"] = {["hex"] = "ffff4466", ["t"] = {1, 0.27, 0.4, 1}},
    ["softlime"] = {["hex"] = "ff7bed9f", ["t"] = {0.48, 0.93, 0.62, 1}},
    ["lime"] = {["hex"] = "ff2ed573", ["t"] = {0.18, 0.84, 0.45, 1}},
    ["brightgreen"] = {["hex"] = "ff66ff00", ["t"] = {0.4, 1, 0, 1}},
    ["chartreuse"] = {["hex"] = "ff80ff00", ["t"] = {0.502, 1, 0, 1}},
    ["lightblue"] = {["hex"] = "ffadd8e6", ["t"] = {0.68, 0.85, 0.9, 1}},
    ["skyblue"] = {["hex"] = "ff00ccff", ["t"] = {0, 0.8, 1, 1}},
    ["vividblue"] = {["hex"] = "ff1e90ff", ["t"] = {0.12, 0.56, 1, 1}},
    ["softblue"] = {["hex"] = "ff5352ed", ["t"] = {0.33, 0.32, 0.93, 1}},
    ["brightblue"] = {["hex"] = "ff3742fa", ["t"] = {0.22, 0.26, 0.98, 1}},
    ["guild"] = {["hex"] = "ff40ff40", ["t"] = {0.251, 1, 0.251, 1}},

    -- class (data from RAID_CLASS_COLORS)
    ["DEATHKNIGHT"] = {["hex"] = "ffc41e3a", ["t"] = {0.7686275243759155, 0.1176470667123795, 0.2274509966373444}},
    ["DEMONHUNTER"] = {["hex"] = "ffa330c9", ["t"] = {0.6392157077789307, 0.1882353127002716, 0.7882353663444519}},
    ["DRUID"] = {["hex"] = "ffff7c0a", ["t"] = {1, 0.4862745404243469, 0.03921568766236305}},
    ["EVOKER"] = {["hex"] = "ff33937f", ["t"] = {0.2000000178813934, 0.5764706134796143, 0.4980392456054688}},
    ["HUNTER"] = {["hex"] = "ffaad372", ["t"] = {0.6666666865348816, 0.8274510502815247, 0.4470588564872742}},
    ["MAGE"] = {["hex"] = "ff3fc7eb", ["t"] = {0.2470588386058807, 0.7803922295570374, 0.9215686917304993}},
    ["MONK"] = {["hex"] = "ff00ff98", ["t"] = {0, 1, 0.5960784554481506}},
    ["PALADIN"] = {["hex"] = "fff48cba", ["t"] = {0.9568628072738647, 0.5490196347236633, 0.729411780834198}},
    ["PRIEST"] = {["hex"] = "ffffffff", ["t"] = {1, 1, 1}},
    ["ROGUE"] = {["hex"] = "fffff468", ["t"] = {1, 0.9568628072738647, 0.4078431725502014}},
    ["SHAMAN"] = {["hex"] = "ff0070dd", ["t"] = {0, 0.4392157196998596, 0.8666667342185974}},
    ["WARLOCK"] = {["hex"] = "ff8788ee", ["t"] = {0.529411792755127, 0.5333333611488342, 0.9333333969116211}},
    ["WARRIOR"] = {["hex"] = "ffc69b6d", ["t"] = {0.7764706611633301, 0.6078431606292725, 0.4274510145187378}},
    ["UNKNOWN"] = {["hex"] = "ff666666", ["t"] = {0.4, 0.4, 0.4}},

    ["PET"] = {["hex"] = "ff7f7fff", ["t"] = {0.5, 0.5, 1}},
    ["VEHICLE"] = {["hex"] = "ff00ff33", ["t"] = {0, 1, 0.2}},
    ["NPC"] = {["hex"] = "ff00ff33", ["t"] = {0, 1, 0.2}},

    -- faction
    ["Horde"] = {["hex"] = "ffc70000", ["t"] = {0.78, 0, 0}},
    ["Alliance"] = {["hex"] = "ff1a80ff", ["t"] = {0.1, 0.5, 1}},

    -- role
    ["TANK"] = {["hex"] = "ff627ee2", ["t"] = {0.38, 0.49, 0.89}},
    ["HEALER"] = {["hex"] = "ff4baa4e", ["t"] = {0.29, 0.67, 0.31}},
    ["DAMAGER"] = {["hex"] = "ffa74c4d", ["t"] = {0.65, 0.3, 0.3}},

    -- reaction
    ["FRIENDLY"] = {["hex"] = "ff4ab04d", ["t"] = {0.29, 0.69, 0.3}},
    ["NEUTRAL"] = {["hex"] = "ffd9c45c", ["t"] = {0.85, 0.77, 0.36}},
    ["HOSTILE"] = {["hex"] = "ffc74040", ["t"] = {0.78, 0.25, 0.25}},

    -- aura
    ["aura_curse"] = {["hex"] = "ff9900ff", ["t"] = {0.6, 0, 1}},
    ["aura_disease"] = {["hex"] = "ff996600", ["t"] = {0.6, 0.4, 0}},
    ["aura_magic"] = {["hex"] = "ff3399ff", ["t"] = {0.2, 0.6, 1}},
    ["aura_poison"] = {["hex"] = "ff009900", ["t"] = {0, 0.6, 0}},
    ["aura_bleed"] = {["hex"] = "ffff3399", ["t"] = {1, 0.2, 0.6}},
    ["aura_none"] = {["hex"] = "ffcc0000", ["t"] = {0.8, 0, 0}},
    ["aura_castbyme"] = {["hex"] = "ff00cc00", ["t"] = {0, 0.8, 0}},
    ["aura_dispellable"] = {["hex"] = "ffffff00", ["t"] = {1, 1, 0}},

    -- power color (color from PowerBarColor & ElvUI)
    ["MANA"] = {["hex"] = "ff007fff", ["t"] = {0, 0.5, 1}}, -- 0, 0, 1
    ["RAGE"] = {["hex"] = "ffff0000", ["t"] = {1, 0, 0}},
    ["FOCUS"] = {["hex"] = "ffff7f3f", ["t"] = {1, 0.50, 0.25}},
    ["ENERGY"] = {["hex"] = "ffffff00", ["t"] = {1, 1, 0}},
    ["COMBO_POINTS"] = {["hex"] = "fffff468", ["t"] = {1, 0.96, 0.41}},
    ["RUNE_BLOOD"] = {["hex"] = "ffff4040", ["t"] = {1, 0.25, 0.25}},
    ["RUNE_FROST"] = {["hex"] = "ff5798db", ["t"] = {0.34, 0.6, 0.86}},
    ["RUNE_UNHOLY"] = {["hex"] = "ff99d144", ["t"] = {0.6, 0.82, 0.27}},
    ["RUNIC_POWER"] = {["hex"] = "ff00d1ff", ["t"] = {0, 0.82, 1}},
    ["SOUL_SHARDS"] = {["hex"] = "ff9482c9", ["t"] = {0.58, 0.51, 0.79}}, --{["hex"]="ff7f518c", ["t"]={0.50, 0.32, 0.55}}
    ["LUNAR_POWER"] = {["hex"] = "ff4c84e5", ["t"] = {0.30, 0.52, 0.90}},
    ["HOLY_POWER"] = {["hex"] = "fff2e54d", ["t"] = {0.95, 0.9, 0.3}}, -- {["hex"]="fff2e599", ["t"]={0.95, 0.90, 0.60}},
    ["MAELSTROM"] = {["hex"] = "ff007fff", ["t"] = {0, 0.5, 1}},
    ["INSANITY"] = {["hex"] = "ff9933ff", ["t"] = {0.6, 0.2, 1}}, -- 0.40, 0, 0.80
    ["CHI"] = {["hex"] = "ffb5ffea", ["t"] = {0.71, 1, 0.92}},
    ["ESSENCE"] = {["hex"] = "FF76DFD1", ["t"] = {0.46, 0.87, 0.82}, ["start"] = {0.71, 0.82, 1}, ["end"] = {1, 0.75, 0.75}},
    ["ARCANE_CHARGES"] = {["hex"] = "ff009eff", ["t"] = {0, 0.62, 1}}, -- {["hex"]="ff1919f9", ["t"]={0.10, 0.10, 0.98}}
    ["FURY"] = {["hex"] = "ffc842fc", ["t"] = {0.788, 0.259, 0.992}},
    ["PAIN"] = {["hex"] = "ffff9c00", ["t"] = {1, 0.612, 0}},
    -- vehicle colors
    ["AMMOSLOT"] = {["hex"] = "ffcc9900", ["t"] = {0.80, 0.60, 0}},
    ["FUEL"] = {["hex"] = "ff008c7f", ["t"] = {0.0, 0.55, 0.5}},
    -- alternate power bar colors
    ["EBON_MIGHT"] = {["hex"] = "ffe58c4c", ["t"] = {0.9, 0.55, 0.3}},
    ["STAGGER_GREEN"] = {["hex"] = "ff84ff84", ["t"] = {0.52, 1, 0.52,}},
    ["STAGGER_YELLOW"] = {["hex"] = "fffff9b7", ["t"] = {1, 0.98, 0.72}},
    ["STAGGER_RED"] = {["hex"] = "ffff6b6b", ["t"] = {1, 0.42, 0.42}},

    -- default quality colors https://warcraft.wiki.gg/wiki/Quality
    ["Poor"] = {["hex"] = "ff9d9d9d", ["t"] = {0.615686297416687, 0.615686297416687, 0.615686297416687, 1}}, -- ITEM_QUALITY0_DESC
    ["Common"] = {["hex"] = "ffffffff", ["t"] = {1, 1, 1, 1}}, -- ITEM_QUALITY1_DESC
    ["Uncommon"] = {["hex"] = "ff1eff00", ["t"] = {0.1176470667123795, 1, 0, 1}}, -- ITEM_QUALITY2_DESC
    ["Rare"] = {["hex"] = "ff0070dd", ["t"] = {0, 0.4392157196998596, 0.8666667342185974, 1}}, -- ITEM_QUALITY3_DESC
    ["Epic"] = {["hex"] = "ffa335ee", ["t"] = {0.6392157077789307, 0.207843154668808, 0.9333333969116211, 1}}, -- ITEM_QUALITY4_DESC
    ["Legendary"] = {["hex"] = "ffff8000", ["t"] = {1, 0.501960813999176, 0, 1}}, -- ITEM_QUALITY5_DESC
    ["Artifact"] = {["hex"] = "ffe6cc80", ["t"] = {0.9019608497619629, 0.8000000715255737, 0.501960813999176, 1}}, -- ITEM_QUALITY6_DESC
    ["Heirloom"] = {["hex"] = "ff00ccff", ["t"] = {0, 0.8000000715255737, 1, 1}}, -- ITEM_QUALITY7_DESC
    ["WoWToken"] = {["hex"] = "ff00ccff", ["t"] = {0, 0.8000000715255737, 1, 1}}, -- ITEM_QUALITY8_DESC
}

---@param color string
---@return boolean
function AF.HasColor(color)
    return COLORS[color] and true or false
end

---@param color string
---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetColorRGB(color, alpha, saturation)
    if color:find("^#") then
        return AF.ConvertHEXToRGB(color)
    end

    assert(COLORS[color], "no such color:", color)

    saturation = saturation or 1
    alpha = alpha or COLORS[color]["t"][4] or 1
    return COLORS[color]["t"][1] * saturation, COLORS[color]["t"][2] * saturation, COLORS[color]["t"][3] * saturation, alpha
end

---@param color string
---@param alpha? number
---@param saturation? number
---@return table
function AF.GetColorTable(color, alpha, saturation)
    if color:find("^#") then
        return {AF.ConvertHEXToRGB(color)}
    end

    assert(COLORS[color], "no such color:", color)

    saturation = saturation or 1
    alpha = alpha or COLORS[color]["t"][4]

    return {COLORS[color]["t"][1] * saturation, COLORS[color]["t"][2] * saturation, COLORS[color]["t"][3] * saturation, alpha}
end

---@param color string
---@return string hexColor \"rrggbb\" or \"aarrggbb\"
function AF.GetColorHex(color)
    if color:find("^#") then
        return color:gsub("#", "")
    end

    assert(COLORS[color], "no such color:", color)

    if not COLORS[color]["hex"] then
        COLORS[color]["hex"] = AF.ConvertRGB256ToHEX(AF.ConvertToRGB256(unpack(COLORS[color]["t"])))
    end
    return COLORS[color]["hex"]
end

---@param color string
---@return string colorStr |caarrggbb
function AF.GetColorStr(color)
    local hex = AF.GetColorHex(color)

    if #hex == 8 then
        return "|c" .. hex
    else
        return "|cff" .. hex
    end
end

---@param auraType string
---@param alpha? number
---@return number r
---@return number g
---@return number b
function AF.GetAuraTypeColor(auraType, alpha)
    auraType = auraType and "aura_" .. strlower(auraType)
    if COLORS[auraType] then
        return AF.GetColorRGB(auraType, alpha)
    else
        return AF.GetColorRGB("black", alpha)
    end
end

local GetItemQualityColor = C_Item.GetItemQualityColor
---@param quality number
---@return number r
---@return number g
---@return number b
function AF.GetItemQualityColor(quality)
    local r, g, b = GetItemQualityColor(quality)
    return r, g, b
end

local ADDONS = AF.REGISTERED_ADDONS
local GetAddon = AF.GetAddon

local function BuildColorTable(color)
    if type(color) == "string" then
        if COLORS[color] then
            return COLORS[color]
        else
            color = color:gsub("#", "")
            color = strlower(color)
            local hex = strlen(color) == 6 and "ff" .. color or color
            return {["hex"] = hex, ["t"] = {AF.ConvertHEXToRGB(hex)}}
        end
    elseif type(color) == "table" then
        if #color == 3 then
            color[4] = 1
        end
        return {["hex"] = AF.ConvertRGBToHEX(AF.UnpackColor(color)), ["t"] = color}
    end
end

AF.RegisterCallback("AF_LOADED", function()
    if type(AFConfig.customAccentColor) == "table" then
        COLORS["accent"] = AFConfig.customAccentColor
    end
end, "high")

---@param color string|table colorName, colorHex, colorTable
---@param buttonNormalColor? string|table
---@param buttonHoverColor? string|table
function AF.SetAccentColor(color, buttonNormalColor, buttonHoverColor)
    local t = BuildColorTable(color)

    -- normal
    local normal
    if buttonNormalColor then
        normal = BuildColorTable(buttonNormalColor)["t"]
    else
        normal = AF.Copy(t["t"])
        normal[4] = 0.3
    end

    -- hover
    local hover
    if buttonHoverColor then
        hover = BuildColorTable(buttonHoverColor)["t"]
    else
        hover = AF.Copy(t["t"])
        hover[4] = 0.6
    end

    COLORS["accent"] = {["hex"] = t["hex"], ["t"] = t["t"], ["normal"] = normal, ["hover"] = hover}
    AFConfig.customAccentColor = COLORS["accent"]
end

function AF.ResetAccentColor()
    COLORS["accent"] = AF.Copy(ACCENT_COLOR)
    AFConfig.customAccentColor = nil
end

---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetAccentColorRGB(alpha, saturation)
    return AF.GetColorRGB("accent", alpha, saturation)
end

---@param alpha? number
---@param saturation? number
---@return table
function AF.GetAccentColorTable(alpha, saturation)
    return AF.GetColorTable("accent", alpha, saturation)
end

---@param alpha? number
---@param saturation? number
---@return string
function AF.GetAccentColorHex(alpha, saturation)
    return AF.GetColorHex("accent", alpha, saturation)
end

---@param color string|table colorName, colorHex, colorTable
---@param buttonNormalColor? string|table
---@param buttonHoverColor? string|table
function AF.SetAddonAccentColor(addon, color, buttonNormalColor, buttonHoverColor)
    addon = addon or GetAddon()
    assert(type(addon) == "string", "no registered addon found")

    local t = BuildColorTable(color)

    -- normal
    local normal
    if buttonNormalColor then
        normal = BuildColorTable(buttonNormalColor)["t"]
    else
        normal = AF.Copy(t["t"])
        normal[4] = 0.3
    end

    -- hover
    local hover
    if buttonHoverColor then
        hover = BuildColorTable(buttonHoverColor)["t"]
    else
        hover = AF.Copy(t["t"])
        hover[4] = 0.6
    end

    COLORS[addon] = {["hex"] = t["hex"], ["t"] = t["t"], ["normal"] = normal, ["hover"] = hover}

    if type(AF.REGISTERED_ADDONS[addon]) == "string" then
        COLORS[AF.REGISTERED_ADDONS[addon]] = COLORS[addon]
    end
end

---@param addon? string
---@return string accentColorName registered addon folder name or "accent"
function AF.GetAddonAccentColorName(addon)
    addon = addon or GetAddon()
    if addon and COLORS[addon] then
        return addon
    end
    return "accent"
end

---@param alpha? number
---@param saturation? number
---@return table
function AF.GetAddonAccentColorTable(addon, alpha, saturation)
    return AF.GetColorTable(AF.GetAddonAccentColorName(addon), alpha, saturation)
end

---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetAddonAccentColorRGB(addon, alpha, saturation)
    return AF.GetColorRGB(AF.GetAddonAccentColorName(addon), alpha, saturation)
end

---@param alpha? number
---@param saturation? number
---@return string
function AF.GetAddonAccentColorHex(addon, alpha, saturation)
    return AF.GetColorHex(AF.GetAddonAccentColorName(addon), alpha, saturation)
end

---@param class string capitalized class name
---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetClassColor(class, alpha, saturation)
    saturation = saturation or 1

    if COLORS[class] then
        return AF.GetColorRGB(class, alpha, saturation)
    end

    if RAID_CLASS_COLORS[class] then
        local r, g, b = RAID_CLASS_COLORS[class]:GetRGB()
        return r * saturation, g * saturation, b * saturation, alpha or 1
    end

    return AF.GetColorRGB("UNKNOWN")
end

---@param unit string
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetUnitClassColor(unit)
    local class
    if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then -- player
        class = UnitClassBase(unit)
    elseif AF.IsPet(unit) then -- pet
        class = "PET"
    elseif AF.IsVehicle(UnitGUID(unit)) then -- vehicle
        class = "VEHICLE"
    else
        class = "NPC"
    end
    return AF.GetClassColor(class)
end

---@param unit string unitId
---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetReactionColor(unit, alpha, saturation)
    --! reaction to player, MUST use UnitReaction(unit, "player")
    --! NOT UnitReaction("player", unit)
    local reaction = UnitReaction(unit, "player") or 0
    if reaction <= 2 then
        return AF.GetColorRGB("HOSTILE", alpha, saturation)
    elseif reaction <= 4 then
        return AF.GetColorRGB("NEUTRAL", alpha, saturation)
    else
        return AF.GetColorRGB("FRIENDLY", alpha, saturation)
    end
end

---@param power string capitalized power token
---@param unit string unitId
---@param alpha? number
---@param saturation? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.GetPowerColor(power, unit, alpha, saturation)
    saturation = saturation or 1

    if COLORS[power] then
        if COLORS[power]["start"] then -- gradient
            return COLORS[power]["start"][1] * saturation, COLORS[power]["start"][2] * saturation, COLORS[power]["start"][3] * saturation, alpha,
                COLORS[power]["end"][1] * saturation, COLORS[power]["end"][2] * saturation, COLORS[power]["end"][3] * saturation, alpha
        else
            return AF.GetColorRGB(power, alpha, saturation)
        end
    end

    if unit then
        local r, g, b = select(3, UnitPowerType(unit))
        if r then
            return r, g, b, alpha
        end
    end

    return AF.GetColorRGB("MANA", alpha, saturation)
end

---add new COLORS to the color table with specific name
---@param name any
---@param color table|string \"{r, g, b, a}\" or \"rrggbb\" or \"aarrggbb\"
function AF.AddColor(name, color)
    if type(color) == "string" then
        color = color:gsub("#", "")
        color = strlower(color)
        local hex = strlen(color) == 6 and "ff" .. color or color
        COLORS[name] = {["hex"] = hex, ["t"] = {AF.ConvertHEXToRGB(hex)}}
    elseif type(color) == "table" then
        if #color == 3 then
            color[4] = 1
        end
        COLORS[name] = {["t"] = color, ["hex"] = AF.ConvertRGBToHEX(AF.UnpackColor(color))}
    end
end

---add new COLORS to the color table
---@param t table {["name"] = {r, g, b, a}|"rrggbb"|"aarrggbb", ...}
function AF.AddColors(t)
    for k, v in pairs(t) do
        AF.AddColor(k, v)
    end
end

---@param t table
---@param alpha? number
---@return number r
---@return number g
---@return number b
---@return number a
function AF.UnpackColor(t, alpha)
    return t[1], t[2], t[3], alpha or t[4] or 1
end

---@param t table {r = number, g = number, b = number, a = number}
---@return number r
---@return number g
---@return number b
---@return number a
function AF.ExtractColor(t, alpha)
    return t.r, t.g, t.b, alpha or t.a or 1
end

---------------------------------------------------------------------
-- coloring
---------------------------------------------------------------------
---@param fs FontString
---@param color string|table
function AF.ColorFontString(fs, color)
    local r, g, b, a
    if type(color) == "string" then
        r, g, b, a = AF.GetColorRGB(color)
    elseif type(color) == "table" then
        r, g, b, a = AF.UnpackColor(color)
    else
        r, g, b, a = 1, 1, 1, 1
    end
    fs:SetTextColor(r, g, b, a)
end

---@param text string
---@param name string colorName in COLORS
---@return string coloredText \"|caarrggbbtext|r\"
function AF.WrapTextInColor(text, name)
    if not COLORS[name] then
        return text
    end
    return AF.WrapTextInColorCode(text, AF.GetColorHex(name))
end

---@param text string
---@param r number
---@param g number
---@param b number
---@param a number|nilDSS
---@return string coloredText \"|cffrrggbbtext|r\"
function AF.WrapTextInColorRGB(text, r, g, b)
    return AF.WrapTextInColorCode(text, AF.ConvertRGBToHEX(r, g, b, 1))
end

---@param text string
---@param quality number
---@return string coloredText \"|cffaarrggbbtext|r\"
function AF.WrapTextInQualityColor(text, quality)
    local hex = select(4, GetItemQualityColor(quality))
    return format("|c%s%s|r", hex, text)
end

---comment
---@param text string
---@param colorHexString string \"rrggbb\" or \"aarrggbb\"
---@return string coloredText \"|caarrggbbtext|r\"
function AF.WrapTextInColorCode(text, colorHexString)
    colorHexString = colorHexString:gsub("#", "")
    colorHexString = colorHexString or "ffffffff"
    if #colorHexString == 6 then
        colorHexString = "ff" .. colorHexString
    end
    return format("|c%s%s|r", colorHexString, text)
end

---@param text string
---@param startColor string colorName or hexColor
---@param endColor string colorName or hexColor
---@return string gradientText
function AF.GetGradientText(text, startColor, endColor)
    local gradient = ""
    local length = #text
    local r1, g1, b1, r2, g2, b2

    if COLORS[startColor] then
        r1, g1, b1 = AF.ConvertHEXToRGB256(AF.GetColorHex(startColor))
    else
        r1, g1, b1 = AF.ConvertHEXToRGB256(startColor)
    end

    if COLORS[endColor] then
        r2, g2, b2 = AF.ConvertHEXToRGB256(AF.GetColorHex(endColor))
    else
        r2, g2, b2 = AF.ConvertHEXToRGB256(endColor)
    end

    local r, g, b, hex
    for i = 0, length - 1 do
        r = AF.Interpolate(r1, r2, i, length - 1)
        g = AF.Interpolate(g1, g2, i, length - 1)
        b = AF.Interpolate(b1, b2, i, length - 1)
        hex = AF.ConvertRGB256ToHEX(r, g, b)
        gradient = gradient .. "|cff" .. hex .. text:sub(i + 1, i + 1) .. "|r"
    end

    return gradient
end

---------------------------------------------------------------------
-- button colors
---------------------------------------------------------------------
local BUTTON_COLOR_NORMAL = COLORS.widget.t
local BUTTON_COLOR_TRANSPARENT = COLORS.none.t
local BUTTON_COLORS = {
    -- ["accent"] = {["normal"] = COLORS["accent"]["normal"], ["hover"] = COLORS["accent"]["hover"]},
    -- ["accent_hover"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = COLORS["accent"]["hover"]},
    -- ["accent_transparent"] = {["normal"] = BUTTON_COLOR_TRANSPARENT, ["hover"] = COLORS["accent"]["hover"]},
    ["static"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = BUTTON_COLOR_NORMAL},
    ["none"] = {["normal"] = BUTTON_COLOR_TRANSPARENT, ["hover"] = BUTTON_COLOR_TRANSPARENT},
    ["gray_hover"] = {["normal"] = BUTTON_COLOR_TRANSPARENT, ["hover"] = {1, 1, 1, 0.1}},
    ["red"] = {["normal"] = {0.6, 0.1, 0.1, 0.6}, ["hover"] = {0.6, 0.1, 0.1, 1}},
    -- ["red_hover"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = {0.6, 0.1, 0.1, 1}},
    ["green"] = {["normal"] = {0.1, 0.6, 0.1, 0.6}, ["hover"] = {0.1, 0.6, 0.1, 1}},
    -- ["green_hover"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = {0.1, 0.6, 0.1, 1}},
    ["blue"] = {["normal"] = {0, 0.5, 0.8, 0.6}, ["hover"] = {0, 0.5, 0.8, 1}},
    -- ["blue_hover"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = {0, 0.5, 0.8, 1}},
    -- ["yellow"] = {["normal"] = {0.7, 0.7, 0, 0.6}, ["hover"] = {0.7, 0.7, 0, 1}},
    -- ["yellow_hover"] = {["normal"] = BUTTON_COLOR_NORMAL, ["hover"] = {0.7, 0.7, 0, 1}},
    -- ["hotpink"] = {["normal"] = {1, 0.27, 0.4, 0.6}, ["hover"] = {1, 0.27, 0.4, 1}},
    -- ["lime"] = {["normal"] = {0.8, 1, 0, 0.35}, ["hover"] = {0.8, 1, 0, 0.65}},
    -- ["lavender"] = {["normal"] = {0.96, 0.73, 1, 0.35}, ["hover"] = {0.96, 0.73, 1, 0.65}},
}

---@param name string color name
---@return table normalColor {r, g, b, a}
function AF.GetButtonNormalColor(name)
    name = name or GetAddon() or "accent"

    if BUTTON_COLORS[name] then
        return BUTTON_COLORS[name]["normal"]
    end

    if name:find("transparent$") then
        return BUTTON_COLOR_TRANSPARENT
    end

    if name:find("hover$") then
        return BUTTON_COLOR_NORMAL
    end

    if name:find("^accent") then
        return COLORS["accent"]["normal"]
    end

    if COLORS[name] then
        if COLORS[name]["normal"] then
            return COLORS[name]["normal"]
        else
            return {COLORS[name]["t"][1], COLORS[name]["t"][2], COLORS[name]["t"][3], min(0.3, COLORS[name]["t"][4] or 1)}
        end
    end

    error("no such button normal color: " .. name)
end

---@param name string color name
---@return table hoverColor {r, g, b, a}
function AF.GetButtonHoverColor(name)
    name = name or GetAddon() or "accent"

    local baseName = name:gsub("_hover$", ""):gsub("_transparent$", "")

    if BUTTON_COLORS[name] then
        return BUTTON_COLORS[name]["hover"]
    elseif BUTTON_COLORS[baseName] then
        return BUTTON_COLORS[baseName]["hover"]
    end

    if name:find("^accent") then
        return COLORS["accent"]["hover"]
    end

    if COLORS[name] then
        if COLORS[name]["hover"] then
            return COLORS[name]["hover"]
        else
            return {COLORS[name]["t"][1], COLORS[name]["t"][2], COLORS[name]["t"][3], min(0.6, COLORS[name]["t"][4] or 1)}
        end
    elseif COLORS[baseName] then
        if COLORS[baseName]["hover"] then
            return COLORS[baseName]["hover"]
        else
            return {COLORS[baseName]["t"][1], COLORS[baseName]["t"][2], COLORS[baseName]["t"][3], min(0.6, COLORS[baseName]["t"][4] or 1)}
        end
    end

    error("no such button hover color: " .. name)
end

---@param name string color name
---@param normalColor table {r, g, b, a}
---@param hoverColor table {r, g, b, a}
function AF.AddButtonColor(name, normalColor, hoverColor)
    BUTTON_COLORS[name] = {["normal"] = normalColor, ["hover"] = hoverColor}
end

---@param t table {["name"] = {normal = {r, g, b, a}, hover = {r, g, b, a}}, ...}
function AF.AddButtonColors(t)
    for k, v in pairs(t) do
        AF.AddColor(k, v.normalColor, v.hoverColor)
    end
end