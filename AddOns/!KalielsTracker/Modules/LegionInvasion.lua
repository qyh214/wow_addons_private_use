--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_LegionInvasion")
KT.LegionInvasion = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local format = string.format
local ipairs = ipairs
local strfind = string.find
local tinsert = table.insert

local db
local OTF = ObjectiveTrackerFrame

local mapIDs = { 181, 11, 161, 27, 24, 39 }
local monitorBlock
local name, timeLeftMinutes, rewardQuestID
local timer = 0
local timerDuration = 60
local imprint = ""
local tmpImprint = ""

local eventFrame

LEGION_INVASION_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable()

--------------
-- Internal --
--------------

local function Init()
    local monitorHeader = CreateFrame("Frame", nil, OTF.BlocksFrame, "ObjectiveTrackerHeaderTemplate")
    monitorHeader:Hide()

    monitorBlock = CreateFrame("Frame", nil, OTF.BlocksFrame)
    monitorBlock.texture = monitorBlock:CreateTexture()
    monitorBlock.texture:SetAtlas("legioninvasion-map-icon-portal-large")
    monitorBlock.texture:SetSize(34, 38)
    monitorBlock.texture:SetPoint("LEFT", -40, -2)

    LEGION_INVASION_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_ALL
    LEGION_INVASION_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_ALL
    LEGION_INVASION_TRACKER_MODULE:SetHeader(monitorHeader, "Legion Invasion")
    LEGION_INVASION_TRACKER_MODULE.blockOffsetX = 30

    monitorBlock:SetSize(232 - LEGION_INVASION_TRACKER_MODULE.blockOffsetX, 10)
    monitorBlock:Hide()
end

local function LegionInvasionTrackerModule_OnUpdate(self, elapsed)
    timer = timer + elapsed
    if timer >= timerDuration then
        ObjectiveTracker_Update()
        if tmpImprint ~= imprint then
            KT:ToggleEmptyTracker(true)
            imprint = tmpImprint
        end
        timer = 0
    end
end

local function SetFrames()
    -- Event frame
    eventFrame = CreateFrame("Frame")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "SCENARIO_UPDATE" then
            local scenarioType = select(10, C_Scenario.GetInfo())
            if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
                local newStage = ...
                KT:ToggleEmptyTracker(newStage)
            end
        elseif event == "SCENARIO_COMPLETED" then
            timer = timerDuration
        elseif event == "WORLD_MAP_UPDATE" then
            timer = timerDuration
            self:UnregisterEvent(event)
        end
    end)
    eventFrame:SetScript("OnUpdate", LegionInvasionTrackerModule_OnUpdate)
    eventFrame:RegisterEvent("SCENARIO_UPDATE")
    eventFrame:RegisterEvent("SCENARIO_COMPLETED")
end

local function SetHooks()
    hooksecurefunc("ObjectiveTracker_Initialize", function(self)
        tinsert(self.MODULES, 2, LEGION_INVASION_TRACKER_MODULE)
    end)
end

--------------
-- External --
--------------

function LEGION_INVASION_TRACKER_MODULE:GetBlock()
    local block = monitorBlock
    block.module = self
    block.used = true
    block.height = 0
    block.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH - self.blockOffsetX
    block.currentLine = nil
    if block.lines then
        for _, line in ipairs(block.lines) do
            line.used = nil
        end
    else
        block.lines = {}
    end
    return block
end

function LEGION_INVASION_TRACKER_MODULE:Update()
    self:BeginLayout()

    local block = self:GetBlock()
    local i = 0
    tmpImprint = ""

    for _, id in ipairs(mapIDs) do
        name, timeLeftMinutes = GetInvasionInfoByMapAreaID(id)
        if name then
            tmpImprint = tmpImprint .. id
            i = i + 1
            local _, _, location = strfind(name, ".*:%s?(.*)")
            local timeLeft = ""
            if timeLeftMinutes then
                local hoursLeft = floor(timeLeftMinutes / 60)
                local minutesLeft = timeLeftMinutes % 60
                timeLeft = format(" - "..INVASION_TIME_FORMAT, hoursLeft, minutesLeft)
            end
            self:AddObjective(block, i, (location or name)..timeLeft, nil, nil, OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE)
            if i == 1 and timeLeftMinutes == 0 then
                eventFrame:RegisterEvent("WORLD_MAP_UPDATE")
            end
        end
    end

    if i > 0 then
        block:SetHeight(block.height)
        if ObjectiveTracker_AddBlock(block) then
            block:Show()
            self:FreeUnusedLines(block)
            if i > 2 then
                block.texture:SetPoint("TOPLEFT", -40, 2)
            else
                block.texture:SetPoint("LEFT", -40, -2)
            end
        else
            block.used = false
        end
    end

    self:EndLayout()
    M.used = (i > 0)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile

    self.used = false
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
    SetFrames()
    Init()
end