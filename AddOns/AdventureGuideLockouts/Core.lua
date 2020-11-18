local _G = _G
local pairs = pairs
local print = print
local select = select
local tinsert = tinsert
local tonumber = tonumber

local C_ContributionCollector_GetState = C_ContributionCollector.GetState
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_TaskQuest_GetQuestTimeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes
local CreateFrame = CreateFrame
local EJ_GetEncounterInfo = EJ_GetEncounterInfo
local EJ_GetInstanceInfo = EJ_GetInstanceInfo
local Enum_ContributionState = Enum.ContributionState
local GetAchievementInfo = GetAchievementInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceChatLink = GetSavedInstanceChatLink
local GetSavedInstanceEncounterInfo = GetSavedInstanceEncounterInfo
local GetSavedInstanceInfo = GetSavedInstanceInfo
local hooksecurefunc = hooksecurefunc
local RequestRaidInfo = RequestRaidInfo
local UnitFactionGroup = UnitFactionGroup

local BOSS_ALIVE = BOSS_ALIVE
local BOSS_DEAD = BOSS_DEAD
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local RAID_INFO_WORLD_BOSS = RAID_INFO_WORLD_BOSS
local GRAY_FONT_COLOR = GRAY_FONT_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local RED_FONT_COLOR = RED_FONT_COLOR

local ADDON_NAME, AddOn = ...

local function debug(...)
  _G[ADDON_NAME] = _G[ADDON_NAME] or AddOn
  if not ... then return end
  if type(...) == "table" then
    print("|cff33ff99" .. ADDON_NAME .. " DEBUG:|r")
    LoadAddOn("Blizzard_DebugTools")
    DevTools_Dump(...)
  else
    print("|cff33ff99" .. ADDON_NAME .. " DEBUG:|r", ...)
  end
end

local function error(err, debugTable)
  AddOn.errors = AddOn.errors or {}
  if not AddOn.errors[err] then
    print("|cffff0000" .. ADDON_NAME .. " ERROR:|r", err)
    debug(debugTable)
    AddOn.errors[err] = true
  end
end

local function debug(...)
  _G[ADDON_NAME] = _G[ADDON_NAME] or AddOn
  if not ... then return end
  if type(...) == "table" then
    print("|cff33ff99" .. ADDON_NAME .. ":|r")
    LoadAddOn("Blizzard_DebugTools")
    DevTools_Dump(...)
  else
    print("|cff33ff99" .. ADDON_NAME .. ":|r", ...)
  end
end

function AddOn:RequestWarfrontInfo()
  local stromgardeState = C_ContributionCollector_GetState(self.faction == "Horde" and 116 or 11)
  local darkshoreState = C_ContributionCollector_GetState(self.faction == "Horde" and 117 or 118)

  self.isStromgardeAvailable = stromgardeState == Enum_ContributionState.Building or stromgardeState == Enum_ContributionState.Active
  self.isDarkshoreAvailable = darkshoreState == Enum_ContributionState.Building or darkshoreState == Enum_ContributionState.Active
end

---@param instanceIndex number
---@return string, number, boolean, string, number, number, number @ instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty
function AddOn:GetSavedWorldBossInfo(instanceIndex)
  local instanceID = self.worldBosses[instanceIndex].instanceID
  local instanceName = EJ_GetInstanceInfo(instanceID)
  local difficulty = 2
  local locked = false
  local difficultyName = RAID_INFO_WORLD_BOSS
  local numEncounters = 0
  local numCompleted = 0

  for encounterIndex = 1, #self.worldBosses[instanceIndex].encounters do
    local encounter = self.worldBosses[instanceIndex].encounters[encounterIndex]
    local isDefeated = C_QuestLog_IsQuestFlaggedCompleted(encounter.questID)
    if instanceIndex == 5 and encounterIndex == 4 then
      isDefeated = isDefeated and self.isStromgardeAvailable
    elseif instanceIndex == 5 and encounterIndex == 8 then
      isDefeated = isDefeated and self.isDarkshoreAvailable
    end
    if isDefeated then
      locked = true
      numCompleted = numCompleted + 1
    end
  end

  return instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty
end

---@param instanceIndex number
---@param encounterIndex number
---@return string, boolean @ bossName, isKilled
function AddOn:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex)
  if encounterIndex > #self.worldBosses[instanceIndex].encounters then return end
  local bossName
  local isKilled = C_QuestLog_IsQuestFlaggedCompleted(self.worldBosses[instanceIndex].encounters[encounterIndex].questID)
  if self.worldBosses[instanceIndex].encounters[encounterIndex].name == "" then
    bossName = (select(2, GetAchievementInfo(7333))) -- Localize "The Four Celestials"
  elseif not self.worldBosses[instanceIndex].encounters[encounterIndex].name then
    bossName = EJ_GetEncounterInfo(self.worldBosses[instanceIndex].encounters[encounterIndex].encounterID)
  end
  return bossName, isKilled
end

---@param instanceIndex number
---@return table @ instanceLockout
function AddOn:GetInstanceLockout(instanceIndex)
  local instanceName, _, _, instanceDifficulty, locked, extended, _, _, _, difficultyName, numEncounters, numCompleted = GetSavedInstanceInfo(instanceIndex)
  if not locked and not extended then return end
  local instanceLink = GetSavedInstanceChatLink(instanceIndex)
  local instanceMatch = instanceLink:match("%b::(%d+)")
  local instanceID = self.instances[tonumber(instanceMatch)]
  if not instanceID then
    local debugTable = {
      instanceLink = instanceLink,
      instanceMatch = instanceMatch
    }
    error("instanceID is nil. Please report following values at https://github.com/Meivyn/AdventureGuideLockouts/issues", debugTable)
    return
  end

  if instanceID == 777 then
    numEncounters = 3 -- Fixes wrong encounters count for Assault on Violet Hold
  elseif instanceID == 1023 then
    numEncounters = 4 -- Fixes https://github.com/Meivyn/AdventureGuideLockouts/issues/1
  end

  local _, _, isHeroic, _, displayHeroic, displayMythic, _, isLFR = GetDifficultyInfo(instanceDifficulty)
  local difficulty = 2

  if displayMythic then
    difficulty = 4
  elseif isHeroic or displayHeroic then
    difficulty = 3
  elseif isLFR then
    difficulty = 1
  end

  local encounters = {}
  local encounterIndex = 1

  while GetSavedInstanceEncounterInfo(instanceIndex, encounterIndex) do
    if instanceID == 1023 then
      if self.faction == "Alliance" and encounterIndex == 1 or self.faction == "Horde" and encounterIndex == 2 then
        encounterIndex = encounterIndex + 1 -- Fixes https://github.com/Meivyn/AdventureGuideLockouts/issues/1
      end
    end
    local bossName, _, isKilled = GetSavedInstanceEncounterInfo(instanceIndex, encounterIndex)
    tinsert(encounters, {
      bossName = bossName,
      isKilled = isKilled
    })
    encounterIndex = encounterIndex + 1
  end

  return {
    encounters = encounters,
    instanceName = instanceName,
    instanceID = instanceID,
    difficulty = difficulty,
    difficultyName = difficultyName,
    numEncounters = numEncounters,
    numCompleted = numCompleted,
    progress = numCompleted .. "/" .. numEncounters,
    complete = numCompleted == numEncounters
  }
end

---@param instanceIndex number
---@return table @ instanceLockout
function AddOn:GetWorldBossLockout(instanceIndex)
  local instanceName, instanceID, locked, difficultyName, numEncounters, numCompleted, difficulty = self:GetSavedWorldBossInfo(instanceIndex)
  if not locked then return end

  local encounters = {}
  local encounterIndex = 1

  while self:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex) do
    local bossName, isKilled = self:GetSavedWorldBossEncounterInfo(instanceIndex, encounterIndex)
    local isAvailable = true
    if instanceIndex == 5 and encounterIndex == 4 then
      isAvailable = self.isStromgardeAvailable
      isKilled = isKilled and isAvailable
    elseif instanceIndex == 5 and encounterIndex == 8 then
      isAvailable = self.isDarkshoreAvailable
      isKilled = isKilled and isAvailable
    elseif instanceIndex == 5 then
      isAvailable = C_TaskQuest_GetQuestTimeLeftMinutes(self.worldBosses[instanceIndex].encounters[encounterIndex].questID) ~= nil
    end
    tinsert(encounters, {
      bossName = bossName,
      isKilled = isKilled,
      isAvailable = isAvailable
    })
    numEncounters = (isAvailable or isKilled) and numEncounters + 1 or numEncounters
    encounterIndex = encounterIndex + 1
  end

  return {
    encounters = encounters,
    instanceName = instanceName,
    instanceID = instanceID,
    difficulty = difficulty,
    difficultyName = difficultyName,
    numEncounters = numEncounters,
    numCompleted = numCompleted,
    progress = numCompleted .. "/" .. numEncounters,
    complete = numCompleted == numEncounters
  }
end

function AddOn:UpdateSavedInstances()
  self.instancesLockouts = {}

  local savedInstances = GetNumSavedInstances()

  for instanceIndex = 1, savedInstances + #self.worldBosses do
    local lockout

    if instanceIndex <= savedInstances then
      lockout = self:GetInstanceLockout(instanceIndex)
    else
      lockout = self:GetWorldBossLockout(instanceIndex - savedInstances)
    end

    if lockout then
      self.instancesLockouts[lockout.instanceID] = self.instancesLockouts[lockout.instanceID] or {}
      tinsert(self.instancesLockouts[lockout.instanceID], lockout)
    end
  end
end

---@param instanceButton Button
---@param difficulty number
---@return Frame @ statusFrame
function AddOn:CreateStatusFrame(instanceButton, difficulty)
  local statusFrame = CreateFrame("Frame", nil, instanceButton)
  statusFrame:SetSize(38, 46)
  statusFrame:SetScript("OnEnter", function(frame)
    _G.GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    _G.GameTooltip:SetText(frame.instanceInfo.instanceName .. " (" .. frame.instanceInfo.difficultyName .. ")")
    for i = 1, #frame.instanceInfo.encounters do
      local encounter = frame.instanceInfo.encounters[i]
      local r, g, b = GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b
      local bossStatus = BOSS_ALIVE
      if encounter.isKilled then
        r, g, b = RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b
        bossStatus = BOSS_DEAD
      elseif encounter.isAvailable == false then
        r, g, b = GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
        bossStatus = QUEUE_TIME_UNAVAILABLE
      end
      _G.GameTooltip:AddDoubleLine(encounter.bossName, bossStatus, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, r, g, b)
    end
    _G.GameTooltip:Show()
  end)
  statusFrame:SetScript("OnLeave", function()
    _G.GameTooltip:Hide()
  end)

  statusFrame.texture = statusFrame:CreateTexture(nil, "ARTWORK")
  statusFrame.texture:SetPoint("CENTER")
  statusFrame.texture:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
  statusFrame.texture:SetSize(64, 46)

  if difficulty == 4 then
    statusFrame.texture:SetTexCoord(0.25, 0.5, 0.0703125, 0.4296875)
  elseif difficulty == 3 then
    statusFrame.texture:SetTexCoord(0, 0.25, 0.0703125, 0.4296875)
  else
    statusFrame.texture:SetTexCoord(0, 0.25, 0.5703125, 0.9296875)
  end

  local completeFrame = CreateFrame("Frame", nil, statusFrame)
  completeFrame:SetSize(16, 16)

  completeFrame.texture = completeFrame:CreateTexture(nil, "ARTWORK", "GreenCheckMarkTemplate")
  completeFrame.texture:ClearAllPoints()
  completeFrame.texture:SetPoint("CENTER")

  local progressFrame = statusFrame:CreateFontString(nil, nil, "GameFontNormalSmallLeft")

  if difficulty == 1 or difficulty == 2 then
    completeFrame:SetPoint("CENTER", statusFrame, "CENTER", 0, -1)
    progressFrame:SetPoint("CENTER", statusFrame, "CENTER", 0, 5)
  else
    completeFrame:SetPoint("CENTER", statusFrame, "CENTER", 0, -12)
    progressFrame:SetPoint("CENTER", statusFrame, "CENTER", 0, -9)
  end

  statusFrame.completeFrame = completeFrame
  statusFrame.progressFrame = progressFrame

  self.statusFrames[instanceButton:GetName()] = self.statusFrames[instanceButton:GetName()] or {}
  self.statusFrames[instanceButton:GetName()][difficulty] = statusFrame

  return statusFrame
end

---@param instanceButton Button
function AddOn:UpdateStatusFramePosition(instanceButton)
  local savedFrames = self.statusFrames[instanceButton:GetName()]
  local lfrVisible = savedFrames and savedFrames[1] and savedFrames[1]:IsVisible()
  local normalVisible = savedFrames and savedFrames[2] and savedFrames[2]:IsVisible()
  local heroicVisible = savedFrames and savedFrames[3] and savedFrames[3]:IsVisible()
  local mythicVisible = savedFrames and savedFrames[4] and savedFrames[4]:IsVisible()

  if mythicVisible then
    savedFrames[4]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -12)
  end

  if heroicVisible then
    if mythicVisible then
      savedFrames[3]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -12)
    else
      savedFrames[3]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -12)
    end
  end

  if normalVisible then
    if heroicVisible and mythicVisible then
      savedFrames[2]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -60, -23)
    elseif heroicVisible or mythicVisible then
      savedFrames[2]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -23)
    else
      savedFrames[2]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -23)
    end
  end

  if lfrVisible then
    if normalVisible and heroicVisible and mythicVisible then
      savedFrames[1]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -92, -23)
    elseif heroicVisible and mythicVisible or heroicVisible and normalVisible or mythicVisible and normalVisible then
      savedFrames[1]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -60, -23)
    elseif normalVisible or heroicVisible or mythicVisible then
      savedFrames[1]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -23)
    else
      savedFrames[1]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -23)
    end
  end
end

---@param instanceButton Button
function AddOn:UpdateInstanceStatusFrame(instanceButton)
  self.statusFrames = self.statusFrames or {}

  if self.statusFrames[instanceButton:GetName()] then
    for _, frame in pairs(self.statusFrames[instanceButton:GetName()]) do
      frame:Hide()
    end
  end

  local instances = self.instancesLockouts[instanceButton.instanceID]
  if not instances then return end

  for i = 1, #instances do
    local instance = instances[i]
    local frame = (self.statusFrames[instanceButton:GetName()] and self.statusFrames[instanceButton:GetName()][instance.difficulty]) or self:CreateStatusFrame(instanceButton, instance.difficulty)
    if instance.complete then
      frame.completeFrame:Show()
      frame.progressFrame:Hide()
      frame:Show()
    elseif instance.progress then
      frame.completeFrame:Hide()
      frame.progressFrame:SetText(instance.progress)
      frame.progressFrame:Show()
      frame:Show()
    else
      frame:Hide()
    end
    frame.instanceInfo = instance
  end

  self:UpdateStatusFramePosition(instanceButton)
end

local function UpdateFrames()
  local b1 = _G.EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1
  if b1 then
    AddOn:UpdateInstanceStatusFrame(b1)
  end
  for i = 1, 100 do
    local b = _G["EncounterJournalInstanceSelectScrollFrameinstance" .. i]
    if b then
      AddOn:UpdateInstanceStatusFrame(b)
    end
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BOSS_KILL")
frame:RegisterEvent("UPDATE_INSTANCE_INFO")
frame:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" then
    AddOn.faction = UnitFactionGroup("player")
    AddOn.worldBosses[5].encounters[4].encounterID = AddOn.faction == "Horde" and 2212 or 2213
    AddOn.worldBosses[5].encounters[4].questID =  AddOn.faction == "Horde" and 52848 or 52847
    AddOn.worldBosses[5].encounters[8].encounterID = AddOn.faction == "Horde" and 2329 or 2345
    AddOn.worldBosses[5].encounters[8].questID =  AddOn.faction == "Horde" and 54896 or 54895
  elseif event == "ADDON_LOADED" and arg1 == "Blizzard_EncounterJournal" then
    _G.EncounterJournal:HookScript("OnShow", UpdateFrames)
    hooksecurefunc("EncounterJournal_ListInstances", UpdateFrames)
  elseif event == "BOSS_KILL" then
    RequestRaidInfo()
  elseif event == "UPDATE_INSTANCE_INFO" then
    AddOn:RequestWarfrontInfo()
    AddOn:UpdateSavedInstances()
    UpdateFrames()
  end
end)
