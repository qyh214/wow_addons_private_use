local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local format = format
local pairs = pairs

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI

local C_Timer_After = C_Timer.After

local TypeDict = {
    ["Humanoid"] = L["Humanoid"],
    ["Beast"] = L["Beast"],
    ["Undead"] = L["Undead"],
    ["Elemental"] = L["Elemental"],
    ["Aberration"] = L["Aberration"],
    ["Not specified"] = L["Not specified"],
    ["Mechanical"] = L["Mechanical"],
    ["Dragonkin"] = L["Dragonkin"]
}

function MH:Translate()
    if not self.db or not self.db.enable or not self.db.translate then
        return
    end

    if not _G.MDT or not _G.MDT.dungeonEnemies then
        return
    end

    if _G.MDT.L then
        for _, localeString in pairs(TypeDict) do
            _G.MDT.L[localeString] = localeString
        end
    end

    for mapID, NPCs in pairs(_G.MDT.dungeonEnemies) do
        if mapID >= 29 and NPCs then
            for _, NPC in pairs(NPCs) do
                if NPC.id and NPC.name then
                    local name = F.GetNPCNameByID(NPC.id)
                    if name then
                        NPC.name = name
                        if _G.MDT.L then
                            _G.MDT.L[name] = name
                        end
                    end
                end
                if NPC.creatureType then
                    NPC.creatureType = TypeDict[NPC.creatureType] or NPC.creatureType
                end
            end
        end
    end
end

function MH:MDTLoaded()
    if not self.db or not self.db.enable then
        return
    end
    --self:Translate()
end

function MH:ProfileUpdate()
    self.db = W.db.mdtHelper

    if IsAddOnLoaded("MythicDungeonTools") then
        self:MDTLoaded()
    else
        self:RegisterEvent("ADDON_LOADED", "MDTLoaded")
    end
end

MH.OnInitialize = MH.ProfileUpdate
