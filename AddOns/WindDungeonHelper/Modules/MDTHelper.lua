local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local format = format
local pairs = pairs

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI

local C_Timer_After = C_Timer.After

local currentPatchMaps = {
    [3] = true, -- Court of Stars
    [4] = true, -- Darkheart Thicket
    [6] = true, -- Halls of Valor
    [8] = true, -- Neltharion's Lair
    [15] = true, -- The Arcway
    [16] = true, -- Freehold
    [22] = true, -- The Underrot
    [42] = true, -- Ruby Life Pools
    [43] = true, -- The Nokhud Offensive
    [44] = true, -- The Azure Vault
    [45] = true, -- Algeth’ar Academy
    [46] = true, -- Shadowmoon Burial Grounds
    [47] = true, -- Temple of the Jade Serpent
    [48] = true, -- Brackenhide Hollow
    [49] = true, -- Halls of Infusion
    [50] = true, -- Neltharus
    [51] = true, -- Uldaman: Legacy of Tyr
    [77] = true, -- The Vortex Pinnacle
    [100] = true, -- Dawn of the Infinite Lower
    [101] = true, -- Dawn of the Infinite Upper
    [102] = true, -- Waycrest Manor
    [103] = true, -- Black Rook Hold
    [104] = true, -- The Everbloom
    [105] = true -- Throne of Tides
}

function MH:Translate()
    if not self.db or not self.db.enable or not self.db.translate then
        return
    end

    local MDT = _G.MDT

    if not MDT or not MDT.dungeonEnemies or not MDT.L then
        return
    end

    for mapID, NPCs in pairs(MDT.dungeonEnemies) do
        if mapID and currentPatchMaps[mapID] and NPCs then
            for _, NPC in pairs(NPCs) do
                if NPC.id and NPC.name then
                    F.HandleNPCNameByID(
                        NPC.id,
                        function(name)
                            MDT.L[NPC.name] = name
                        end
                    )
                end
            end
        end
    end
end

function MH:ProfileUpdate()
    self.db = W.db.mdtHelper

    if not self.db or not self.db.enable then
        return
    end

    if IsAddOnLoaded("MythicDungeonTools") then
        self:Translate()
    else
        self:RegisterEvent("ADDON_LOADED", "Translate")
    end
end

MH.OnInitialize = MH.ProfileUpdate
