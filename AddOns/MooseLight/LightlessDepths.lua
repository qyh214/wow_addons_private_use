local addon, ns = ... 
if not (ns.LDActive == true) then return end

local GetInstanceInfo, GetSubZoneText = GetInstanceInfo, GetSubZoneText
local C_UnitAuras_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local SetCVar = C_CVar.SetCVar

local LD = CreateFrame("Frame")  --Lightless Depths

-- 減益對應數值 亮度 / 對比 / Gamma
local candleSpell = {
    [420307] = true,
    [420807] = true,
}

local candle = { Brightness = 60, Contrast = 70, Gamma = 1.5, id = "candle" }
local dark  = { Brightness = 60, Contrast = 75, Gamma = 2.0, id = "dark"  }
local defaults  = { Brightness = 50, Contrast = 50, Gamma = 1.2, }
local currentState

local function applySettings(cfg)
    if currentState == cfg.id then return end

    SetCVar("Brightness", cfg.Brightness)
    SetCVar("Contrast",   cfg.Contrast)
    SetCVar("Gamma",      cfg.Gamma)
    
    currentState = cfg.id
end

local function restoreDefaults()
    if not currentState then return end
    for k, v in pairs(defaults) do SetCVar(k, v) end
    currentState = nil
end

local function checkAura()
    local haveCandle = false
    for spellID in pairs(candleSpell) do
        if C_UnitAuras_GetPlayerAuraBySpellID(spellID) then
            haveCandle = true
            break
        end
    end
    applySettings(haveCandle and candle or dark)
end

local function zoneCheck()
    local instanceID = select(8, GetInstanceInfo())
    local name = GetSubZoneText()
    local inDepths = ns.ignoreID[instanceID] and ns.subName[name]

    if inDepths then
        LD:RegisterUnitEvent("UNIT_AURA", "player")
        checkAura()
    else
        LD:UnregisterEvent("UNIT_AURA")
        restoreDefaults()
    end
end

local function OnEvent(self, event)
    if event == "UNIT_AURA" then
        checkAura()
    else
        zoneCheck()
    end
end

LD:SetScript("OnEvent", OnEvent)
LD:RegisterEvent("PLAYER_ENTERING_WORLD")
LD:RegisterEvent("ZONE_CHANGED_NEW_AREA")
LD:RegisterEvent("ZONE_CHANGED_INDOORS")
LD:RegisterEvent("ZONE_CHANGED")
