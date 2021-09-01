local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local format = format
local pairs = pairs

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI

local C_Timer_After = C_Timer.After

function MH:Translate()
    if not self.db or not self.db.enable or not self.db.translate then
        return
    end

    local MDT = _G.MDT

    if not MDT or not MDT.dungeonEnemies or not MDT.dungeonBosses or not MDT.L then
        return
    end

    for mapID, NPCs in pairs(MDT.dungeonEnemies) do
        if mapID >= 29 and NPCs then
            for _, NPC in pairs(NPCs) do
                if NPC["id"] and NPC["name"] then
                    local name = F.GetNPCNameByID(NPC["id"])
                    if name then
                        NPC["name"] = name
                        MDT.L[name] = name
                    end
                end
            end
        end
    end
end

function MH:MDTLoaded()
    if not self.db or not self.db.enable then
        return
    end
    self:Translate()
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
