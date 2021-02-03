local W, F, L, P, O = unpack(select(2, ...))

local _G = _G

local format = format
local print = print
local select = select
local type = type

local CreateFrame = CreateFrame
local GetClassColor = GetClassColor

local function RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function F.CreateColorString(text, r, g, b)
    if not text or not type(text) == "string" then
        print("Cannot find the text.")
        return
    end

    local hex

    if r and g and b then
        hex = RGBToHex(r, g, b)
    else
        hex = RGBToHex(52 / 255, 152 / 255, 219 / 255)
    end

    return "|cff" .. hex .. text .. "|r"
end

function F.CreateClassColorString(text, englishClass)
    if not text or not type(text) == "string" then
        print("Cannot find the text.")
        return
    end
    if not englishClass or type(englishClass) ~= "string" then
        print("Cannot find the class text.")
        return
    end

    local r, g, b = GetClassColor(englishClass)
    return F.CreateColorString(text, r, g, b)
end

function F.Round(number, decimals)
    return format(format("%%.%df", decimals), number)
end

function F.GetNPCNameByID(id)
    local cache = W.Database.locale

    if cache.mdtHelper then
        cache.mdtHelper = nil
    end

    if not cache.npcNames then
        cache.npcNames = {}
    end

    if cache.npcNames[id] then
        return cache.npcNames[id]
    end

    if not _G.WDHScanTooltip then
        CreateFrame("GameTooltip", "WDHScanTooltip", _G.UIParent, "GameTooltipTemplate")
        _G.WDHScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
    end
    _G.WDHScanTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d", id))

    if _G.WDHScanTooltipTextLeft1 and _G.WDHScanTooltipTextLeft1.GetText then
        local name = _G.WDHScanTooltipTextLeft1:GetText()
        cache.npcNames[id] = name
        return name
    end
end
