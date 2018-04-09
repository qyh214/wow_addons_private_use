--- Kaliel's Tracker
--- Copyright (c) 2012-2018, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_AddonOthers")
KT.AddonOthers = M

local MSQ = LibStub("Masque", true)
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local _G = _G

local db
local OTF = ObjectiveTrackerFrame
local msqGroup1, msqGroup2

local KTwarning = "|cff00ffffAddon "..KT.title.." is active."

StaticPopupDialogs[addonName.."_ReloadUI"] = {
    text = KTwarning,
    button1 = "Reload UI",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    preferredIndex = 3,
}

--------------
-- Internal --
--------------

-- Masque
local function Masque_SetSupport()
    if db.addonMasque and MSQ then
        msqGroup1 = MSQ:Group(KT.title, "Quest Item Button")
        msqGroup2 = MSQ:Group(KT.title, "Active Button")
        hooksecurefunc(msqGroup2, "Enable", function(self)
            for button in pairs(self.Buttons) do
                if button.Style then
                    button.Style:SetAlpha(0)
                end
            end
        end)
        hooksecurefunc(msqGroup2, "Disable", function(self)
            for button in pairs(self.Buttons) do
                if button.Style then
                    button.Style:SetAlpha(1)
                end
            end
        end)
    end
end

-- ElvUI
local function ElvUI_SetSupport()
    if KT:CheckAddOn("ElvUI", "10.73", true) then
        local E = unpack(_G.ElvUI)
        E.Blizzard.SetObjectiveFrameHeight = function() end
        E.Blizzard.MoveObjectiveFrame = function() end
        hooksecurefunc(E, "ToggleConfig", function(self)
            local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
            if ACD.OpenFrames[self.name] then
                local options = self.Options.args.general.args.objectiveFrameGroup.args
                options.objectiveFrameHeight.disabled = true
                options.bonusObjectivePosition.disabled = true
                options[addonName.."Warning"] = {
                    name = KTwarning,
                    type = "description",
                    order = options.objectiveFrameHeader.order + 0.5
                }
                ACD["Open"](ACD, self.name)
            end
        end)
    end
end

-- Tukui
local function Tukui_SetSupport()
    if KT:CheckAddOn("Tukui", "17.17", true) then
        local T = unpack(_G.Tukui)
        T.Miscellaneous.ObjectiveTracker.Enable = function() end
    end
end

-- RealUI
local function RealUI_SetSupport()
    if KT:CheckAddOn("nibRealUI", "8.1 r20h", true) then
        local R = _G.RealUI
        R:SetModuleEnabled("Objectives Adv.", false)
        -- Fade
        local bck_UIFrameFadeIn = UIFrameFadeIn
        function UIFrameFadeIn(frame, ...)
            if frame ~= OTF then bck_UIFrameFadeIn(frame, ...) end
        end
        local bck_UIFrameFadeOut = UIFrameFadeOut
        function UIFrameFadeOut(frame, ...)
            if frame ~= OTF then bck_UIFrameFadeOut(frame, ...) end
        end
        -- Replace original function!
        function R:UPDATE_PENDING_MAIL()
            self:UnregisterEvent("UPDATE_PENDING_MAIL")
            _G.CancelEmote()   -- Cancel Map Holding animation
        end
    end
end

-- SyncUI
local function SyncUI_SetSupport()
    if KT:CheckAddOn("SyncUI", "1.5.4", true) then
        SyncUI_ObjTracker.Show = function() end
        SyncUI_ObjTracker:Hide()
        SyncUI_ObjTracker:SetScript("OnLoad", nil)
        SyncUI_ObjTracker:SetScript("OnEvent", nil)
        SyncUI_UnregisterDragFrame(_G["SyncUI_ObjTracker"])
    end
end

-- SpartanUI
local function SpartanUI_SetSupport()
    if KT:CheckAddOn("SpartanUI", "4.4.0", true) then
        local S = LibStub("AceAddon-3.0"):GetAddon("SpartanUI")
        local ACD = LibStub("AceConfigDialog-3.0")
        DB.EnabledComponents.Objectives = false
        local bck_ACD_Open = ACD.Open
        function ACD:Open(name, ...)
            if name == "SpartanUI" then
                local options = S.opt.args.ModSetting.args.Enabled.args.Components.args
                options.Objectives.disabled = true
                options[addonName.."Warning"] = {
                    name = KTwarning,
                    type = "description",
                }
            end
            bck_ACD_Open(self, name, ...)
        end
    end
end

-- SuperVillain UI
local function SVUI_SetSupport()
    if KT:CheckAddOn("SVUI_!Core", "1.4.2", true) then
        if IsAddOnLoaded("SVUI_QuestTracker") then
            DisableAddOn("SVUI_QuestTracker")
            StaticPopup_Show(addonName.."_ReloadUI")
        end
    end
end

--------------
-- External --
--------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    KT:CheckAddOn("Masque", "7.3.0")
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    Masque_SetSupport()
    ElvUI_SetSupport()
    Tukui_SetSupport()
    RealUI_SetSupport()
    SyncUI_SetSupport()
    SpartanUI_SetSupport()
    SVUI_SetSupport()
end

-- Masque
function KT:Masque_AddButton(button, group)
    if db.addonMasque and MSQ and msqGroup1 then
        if not group or group == 1 then
            group = msqGroup1
        elseif group == 2 then
            group = msqGroup2
        end
        group:AddButton(button)
        if button.Style then
            if not group.db.Disabled then
                button.Style:SetAlpha(0)
            end
        end
    end
end