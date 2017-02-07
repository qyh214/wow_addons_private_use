--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_WorldMap")
KT.WorldMap = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local combatLockdown = false

local eventFrame

--------------
-- Internal --
--------------

local function SetHooks()
    local bck_WorldMapFrame_OnHide = WorldMapFrame:GetScript("OnHide")
    WorldMapFrame:SetScript("OnHide", function(self)
        if combatLockdown then return end
        bck_WorldMapFrame_OnHide(self)
    end)

    WorldMapScrollFrame:SetScript("OnMouseWheel", nil)
end

local function SetFrames()
    -- Event frame
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", function(self, event, ...)
            _DBG("Event - "..event)
            if event == "PLAYER_REGEN_ENABLED" and combatLockdown then
                combatLockdown = false
                if not WorldMapFrame:IsShown() then
                    WorldMapFrame_OnHide(WorldMapFrame)
                end
            elseif event == "PLAYER_REGEN_DISABLED" then
                combatLockdown = true
            end
        end)
    end
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
end

--------------
-- External --
--------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetFrames()
    SetHooks()
end