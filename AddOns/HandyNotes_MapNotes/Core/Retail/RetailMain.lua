local ADDON_NAME, ns = ...
local buildVersion, buildNumber, buildDate, interfaceVersion, localizedVersion, buildInfo = GetBuildInfo()
ns.version = buildVersion -- ns.version == "11.1.0"

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local ADDON_NAME = "HandyNotes_MapNotes"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
ns.COLORED_ADDON_NAME = "|cffff0000Map|r|cff00ccffNotes|r"

local MapNotesMiniButton = LibStub("AceAddon-3.0"):NewAddon("MNMiniMapButton", "AceConsole-3.0")
local MNMMBIcon = LibStub("LibDBIcon-1.0", true)

local db = { }
local nodes = { }
local minimap = { }
local lfgIDs = { }
local extraInformations = { }

ns.RestoreStaticPopUpsRetail()

function MapNotesMiniButton:OnInitialize() --mmb.lua
  self.db = LibStub("AceDB-3.0"):New("MNMiniMapButtonRetailDB", { profile = { minimap = { hide = false, }, }, }) 
  MNMMBIcon:Register("MNMiniMapButton", ns.miniButton, self.db.profile.minimap)
end

local function updateextraInformation()
  table.wipe(extraInformations)

  for i = 1, GetNumSavedInstances() do
    local name, _, _, _, locked, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
    if locked then
      local entry = extraInformations[name]
      if not entry then
        entry = {}
        extraInformations[name] = entry
      end
      entry[difficultyName] = {
        progress = encounterProgress,
        total = numEncounters
      }
    end
  end
end

local alreadyWarned = {}
function ns.ValidateNodeEntry(value, coord, uiMapID, sourceFile)

  local warnKey = tostring(uiMapID) .. ":" .. tostring(coord)
  if alreadyWarned[warnKey] then return end

  local missing = {}
  if not value.name and not value.id then
    table.insert(missing, "'name =' or 'id ='")
  end
  if not value.type then
    table.insert(missing, "'type ='")
  end

  local hideInAllViews = (value.showInZone == false or value.showInZone == nil) and (value.showOnContinent == false or value.showOnContinent == nil) and (value.showOnMinimap == false or value.showOnMinimap == nil)
  local coordStr = coord and tostring(coord) or "?"
  local source = sourceFile or ns._currentSourceFile or "?"
  local dataSource = "?"
  if ns.nodes and ns.nodes[uiMapID] then
    dataSource = "nodes[" .. uiMapID .. "]"
  elseif ns.minimap and ns.minimap[uiMapID] then
    dataSource = "minimap[" .. uiMapID .. "]"
  end

  if #missing > 0 then
    print("|cffff0000[MapNotes]|r Error: Missing entry: " .. table.concat(missing, " and ") .. "\n • type[mapID][coords]: " .. dataSource .. "[" .. coordStr .. "]" .. "\n • File: " .. source)
    alreadyWarned[warnKey] = true
    return nil
  end

  if hideInAllViews then
    print("|cffff0000[MapNotes]|r Error: showInZone, showOnContinent, showOnMinimap are all set to false!" .. "\n • type[mapID][coords]: " .. dataSource .. "[" .. coordStr .. "]" .. "\n • File: " .. source)
    alreadyWarned[warnKey] = true
  end

  local visibleEverywhere = value.showInZone and value.showOnContinent and value.showOnMinimap
  if visibleEverywhere then
    print("|cffffff00[MapNotes]|r Hinweis: Icon ist überall sichtbar!" .. "\n • type[mapID][coords]: " .. dataSource .. "[" .. coordStr .. "]" .. "\n • File: " .. source)
    alreadyWarned[warnKey] = true
  end
end

local function LoadAndCheck(loadFunc, self)

  if type(loadFunc) == "function" then
    loadFunc(self)
  end

  -- no DeveloperMode active
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
    return
  end

  local previousNodes = ns.nodes
  local tempNodes = {}

  setmetatable(tempNodes, {
    __index = function(t, k)
      local new = {}
      rawset(t, k, new)
      return new
    end
  })

  ns.nodes = tempNodes

  local previousSource = ns._currentSourceFile
  ns._currentSourceFile = nil

  loadFunc(self)

  local currentSource = ns._currentSourceFile or previousSource or "?"

  for mapID, mapNodes in pairs(tempNodes) do
    for coord, value in pairs(mapNodes) do
      ns.ValidateNodeEntry(value, coord, mapID, currentSource)
    end
  end

  for mapID, mapNodes in pairs(tempNodes) do
      previousNodes[mapID] = previousNodes[mapID] or {}
      for coord, value in pairs(mapNodes) do
          value.sourceFile = currentSource
          previousNodes[mapID][coord] = value
      end
  end

  ns.nodes = previousNodes
  ns._currentSourceFile = previousSource
end



function ns.MiniMapPlayerArrow()
    if MMPA then return MMPA end

    MMPA = CreateFrame("Frame", "MMPA", Minimap)
    MMPA:SetFrameStrata("MEDIUM")
    MMPA:SetPoint("CENTER")
    MMPA:SetSize(10, 10)
    MMPA.texture = MMPA:CreateTexture(nil, "OVERLAY")
    MMPA.texture:SetAtlas("UI-HUD-Minimap-Arrow-Player", true)
    MMPA.texture:SetScale(ns.Addon.db.profile.MinimapArrowScale)
    MMPA.texture:SetPoint("CENTER")
    MMPA.texture:SetTexelSnappingBias(0)
    MMPA.texture:SetSnapToPixelGrid(false)
    MMPA.elapsed = 0

    MMPA:SetScript("OnEnter", function(self)
      if ns.Addon.db.profile.activate.MinimapArrowOnEnter and ns.Addon.db.profile.activate.MinimapArrow then
        self:Hide()
      end
    end)

    MMPA:SetScript("OnLeave", function(self)
      if ns.Addon.db.profile.activate.MinimapArrowOnEnter and ns.Addon.db.profile.activate.MinimapArrow  then
        C_Timer.After(ns.Addon.db.profile.activate.MinimapArrowOnEnterTime, function()
          self:Show()
        end)
      end
    end)

    MMPA:SetScript("OnUpdate", function(self, elapsed)
      self.elapsed = self.elapsed + elapsed
      if self.elapsed < 0.05 then return end
      self.elapsed = 0

      if GetCVar("rotateMinimap") == "1" then
        self.texture:SetRotation(0)
        self.texture:Show()
        return
      end

      local facing = GetPlayerFacing()
      if not facing then
        self.texture:Hide()
        return
      end

      self.texture:Show()
      if facing ~= self.facing then
        self.facing = facing
        self.texture:SetRotation(facing)
      end

    end)

    if ns.Addon.db.profile.activate.MinimapArrow then
        MMPA:Show()
    else
        MMPA:Hide()
    end

    return MMPA
end

function ns.UpdateMinimapArrow()
  ns.Addon.db.profile.MinimapArrowScale = db.MinimapArrowScale
  if MMPA and MMPA.texture then
      MMPA.texture:SetScale(ns.Addon.db.profile.MinimapArrowScale)

      if ns.Addon.db.profile.activate.MinimapArrow then
          MMPA:Show()
      else
          MMPA:Hide()
      end
  end
end

local instanceInfoInitFrame = CreateFrame("Frame")
  instanceInfoInitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  instanceInfoInitFrame:SetScript("OnEvent", function()
  updateextraInformation()
end)

local function ExtraToolTip() -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed
  local show = ns.Addon.db.profile.TooltipInformations and WorldMapFrame:IsShown()
  ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen = show or false
end

ns.bossNameCache = ns.bossNameCache or {}

local function ShowBossNames(instanceID, tooltip)
  if ns.bossNameCache[instanceID] then
    for _, boss in ipairs(ns.bossNameCache[instanceID]) do
      tooltip:AddLine("• " .. boss, 1, 1, 1)
    end
    return
  end

  if not EJ_GetEncounterInfoByIndex then
    LoadAddOn("Blizzard_EncounterJournal")
  end

  EJ_SelectInstance(instanceID)

  local bosses = {}
  local i = 1
  while true do
    local bossName = EJ_GetEncounterInfoByIndex(i)
    if not bossName then break end
    bosses[#bosses + 1] = bossName
    tooltip:AddLine("• " .. bossName, 1, 1, 1)
    i = i + 1
  end
  ns.bossNameCache[instanceID] = bosses
  tooltip:Show()

end

local pluginHandler = { }
ns.pluginHandler = pluginHandler
function ns.pluginHandler.OnEnter(self, uiMapId, coord)

  local nodeData = nil
  local GetCurrentMapID = WorldMapFrame:GetMapID()

  ns.nodes[uiMapId][coord] = nodes[uiMapId][coord]
  ns.minimap[uiMapId][coord] = minimap[uiMapId][coord]

  if (minimap[uiMapId] and minimap[uiMapId][coord]) then
    nodeData = minimap[uiMapId][coord]
  end

	if (nodes[uiMapId] and nodes[uiMapId][coord]) then
	  nodeData = nodes[uiMapId][coord]
	end

	if (not nodeData) then return end

  -- Highlight 
  if not self.highlight then
    self.highlight = self:CreateTexture(nil, "OVERLAY")
    self.highlight:SetBlendMode("ADD")
    self.highlight:SetAlpha(1)
    self.highlight:SetAllPoints()
  end

  if self.highlight:GetTexture() ~= self.texture:GetTexture() then
    self.highlight:SetTexture(self.texture:GetTexture())
  end

  self.highlight:Show()

  -- highlight icon level
  if self.highlight and self.highlight.SetDrawLayer then
    self.highlight:SetDrawLayer("OVERLAY", 6)
  end

  -- icon level himself
  if self.texture and self.texture.SetDrawLayer then
    self.texture:SetDrawLayer("OVERLAY", 5)
  end

	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
	  tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

  if (not nodeData.name) then return end

	local instances = { strsplit("\n", nodeData.name) }

  ExtraToolTip()
	updateextraInformation()

  if nodeData.type and not ns.MapType0 then -- multi tooltips for instances above id names

    local mixedMultiTypes = {
      ["PassageDungeonRaidMulti"] = true,
      ["MultipleM"] = true,
      ["MultiVInstance"] = true,
    }

    if nodeData.type == "MultipleR" or nodeData.type == "PassageRaidMulti" or nodeData.type == "MultiVInstanceR" then
      tooltip:AddDoubleLine("|cffffffff" .. RAIDS .. "\n" .. " ")
    end

    if nodeData.type == "MultipleD" or nodeData.type == "PassageDungeonMulti" or nodeData.type == "MultiVInstanceD" then
      tooltip:AddDoubleLine("|cffffffff" .. DUNGEONS .. "\n" .. " ")
    end

    if mixedMultiTypes[nodeData.type] and nodeData.mnID then
      tooltip:AddDoubleLine("|cffffffff" .. RAIDS .. " & " .. DUNGEONS .. "\n" .. " ")
    end
  
  end

  if ns.Addon.db.profile.BossNames and nodeData.type ~= "LFR" and nodeData.type ~= "PassageLFR" then
    if nodeData.id and type(nodeData.id) == "table" then
      tooltip:AddLine(L["Multiple instances"])
      tooltip:AddLine(" ")
      tooltip:AddLine("|cffff0000" .. L["Too many boss names – click on this icon and then choose one of the dungeons or raids"], 1, 1, 1, true)
      tooltip:AddLine(" ")
    end
  end

	for i, v in pairs(instances) do
    --print(i, v)
	  if (db.KilledBosses and (extraInformations[v] or (lfgIDs[v] and extraInformations[lfgIDs[v]]))) then
 	    if (extraInformations[v]) then
        --print("Dungeon/Raid is locked")
	      for a,b in pairs(extraInformations[v]) do
          --tooltip:AddLine(v .. ": " .. a .. " " .. b, nil, nil, nil, false)
	        tooltip:AddDoubleLine(v, a .. " " .. b.progress .. "/" .. b.total, 1, 1, 1, 1, 1, 1)
 	      end
	    end
      if (lfgIDs[v] and extraInformations[lfgIDs[v]]) then
        for a,b in pairs(extraInformations[lfgIDs[v]]) do
          --tooltip:AddLine(v .. ": " .. a .. " " .. b, nil, nil, nil, false)
          tooltip:AddDoubleLine(v, a .. " " .. b.progress .. "/" .. b.total, 1, 1, 1, 1, 1, 1)
        end
      end
	  else
	    tooltip:AddLine(v, nil, nil, nil, false)
      if ns.Addon.db.profile.DeveloperMode then
        if nodeData.dnID then
          tooltip:AddLine("Type:  " .. nodeData.dnID, nil, nil, false)
        end
        if nodeData.type then
          tooltip:AddLine("IconName:  " .. nodeData.type, nil, nil, false)
        end
        tooltip:AddDoubleLine("uiMapID:  " .. uiMapId, "Coord:  " .. coord, nil, nil, false)
        tooltip:AddDoubleLine("uiMapID:  " .. uiMapId, "==>   " .. C_Map.GetMapInfo(uiMapId).name, nil, nil, false)
        if nodeData.mnID then
          tooltip:AddDoubleLine("mnID:  " .. nodeData.mnID,"==>   " .. C_Map.GetMapInfo(nodeData.mnID).name, nil, nil, false)
        end
        if nodeData.mnID2 then
          tooltip:AddDoubleLine("mnID2:  " .. nodeData.mnID2, C_Map.GetMapInfo(nodeData.mnID2).name, nil, nil, false)
        end
        if nodeData.mnID3 then
          tooltip:AddDoubleLine("mnID3:  " .. nodeData.mnID3, C_Map.GetMapInfo(nodeData.mnID3).name, nil, nil, false)
        end
        tooltip:AddLine(" ", nil, nil, false)
      end
	  end

    if nodeData.delveID and ns.icons["Delves"] then -- Delves
      local delveIDname = C_Map.GetMapInfo(nodeData.delveID).name
      if delveIDname then
        tooltip:AddDoubleLine("|cffffffff" .. delveIDname, nil, nil, false)
        tooltip:AddDoubleLine(nodeData.TransportName, nil, nil, false)
      end
    end

    ns.NpcTooltips(tooltip, nodeData) -- npc tooltips vn RetailNpC

    if nodeData.TransportName and not nodeData.delveID then
      tooltip:AddDoubleLine(nodeData.TransportName, nil, nil, false)
    end

    if nodeData.dnID then -- outputs the names we set and displays it in the tooltip
      tooltip:AddDoubleLine(nodeData.dnID, nil, nil, false)
    end

    if (nodeData.dnID and nodeData.mnID) and not nodeData.mnID2 and not nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine("==> " .. mnIDname, nil, nil, false)
      end
    end

    if not ns.Addon.db.profile.activate.SwapButtons then -- Original Buttons
      if nodeData.mnID and nodeData.mnID2 or nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
        local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
        if mnIDname then
          tooltip:AddDoubleLine("\n" .. KEY_BUTTON1 .. " ==> " .. mnIDname, nil, nil, false)
        end
      end

      if nodeData.mnID2 then
        local mnID2name = C_Map.GetMapInfo(nodeData.mnID2).name
        if mnID2name then 
          tooltip:AddDoubleLine(KEY_BUTTON3 .. " ==> " .. mnID2name, nil, nil, false)
        end
      end

      if nodeData.mnID3 then
        local mnID3name = C_Map.GetMapInfo(nodeData.mnID3).name
        if mnID3name then 
          tooltip:AddDoubleLine(KEY_BUTTON3 .. " ==> " .. mnID3name, nil, nil, false)
        end
      end
    end

    if ns.Addon.db.profile.activate.SwapButtons then -- SwapButtons
      if nodeData.mnID and nodeData.mnID2 or nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
        local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
        if mnIDname then
          tooltip:AddDoubleLine("\n" .. KEY_BUTTON2 .. " ==> " .. mnIDname, nil, nil, false)
        end
      end

      if nodeData.mnID2 then
        local mnID2name = C_Map.GetMapInfo(nodeData.mnID2).name
        if mnID2name then 
          tooltip:AddDoubleLine(KEY_BUTTON3 .. " ==> " .. mnID2name, nil, nil, false)
        end
      end

      if nodeData.mnID3 then
        local mnID3name = C_Map.GetMapInfo(nodeData.mnID3).name
        if mnID3name then 
          tooltip:AddDoubleLine(KEY_BUTTON3 .. " ==> " .. mnID3name, nil, nil, false)
        end
      end
    end

    if not nodeData.dnID and nodeData.mnID and not nodeData.id and not nodeData.TransportName and not nodeData.wwwName and not ns.icons["Delves"] then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(" ==> " .. mnIDname, nil, nil, false)
      end
    end

    if nodeData.mnID and not (nodeData.dnID or nodeData.id or nodeData.TransportName) then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      local type = nodeData.typem
      if mnIDname then
        tooltip:AddDoubleLine(" ==> " .. mnIDname, nil, nil, false)
      end
    end

    local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted

    if nodeData.questID then

      if IsQuestFlaggedCompleted(nodeData.questID) == false then
      
        if nodeData.wwwName then
          tooltip:AddDoubleLine("\n" .. nodeData.wwwName, nil, nil, false)
        end

        if nodeData.wwwLink and nodeData.showWWW == true then
          tooltip:AddDoubleLine("|cffffffff" .. nodeData.wwwLink, nil, nil, false)
          tooltip:AddLine("\n" .. L["Has not been unlocked yet"] .. "\n" .. "\n", 1, 0, 0)
          if ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen then -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed
            tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00".. "< " .. L["Activate the „Link“ function from MapNotes in the General tab to create clickable links and email addresses in the chat"] .. " >" .. "\n" .. TextIconInfo:GetIconString() .. " " .. "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
          end
        end

      end

      if IsQuestFlaggedCompleted(nodeData.questID) == true and nodeData.hideLink == true then
        tooltip:AddLine("\n" .. ALREADY_LEARNED .. "\n" .. "\n", 0, 1, 0)
      end

      if IsQuestFlaggedCompleted(nodeData.questID) then
          nodeData.showWWW = false
          nodeData.wwwName = false
      end

    end

    if nodeData.achievementID then
      local _, name, _, completed, _, _, _, description, _, _, _, _, wasEarnedByMe = GetAchievementInfo(nodeData.achievementID)

      --if wasEarnedByMe == false or completed == false then
      if completed == false then
        tooltip:AddLine("\n" .. description, nil, nil, false)

        if nodeData.wwwName then
          tooltip:AddDoubleLine(nodeData.wwwName, nil, nil, false)
        end

        if nodeData.wwwLink and nodeData.showWWW == true then
          tooltip:AddDoubleLine("|cffffffff" .. nodeData.wwwLink, nil, nil, false)
          tooltip:AddLine("\n" .. L["Has not been unlocked yet"], 1, 0, 0)
          if ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen then -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed
            tooltip:AddDoubleLine("\n" .. TextIconInfo:GetIconString() .. " " .. "|cff00ff00".. "< " .. L["Activate the 'Link' function in the MapNotes menu to generate a clickable web link"] .. " >" .. "\n" .. TextIconInfo:GetIconString() .. " " ..  "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
          end
        end
        
      end

      -- if wasEarnedByMe == true and completed == true then
      if completed == true then
        nodeData.showWWW = false
        nodeData.wwwName = false
      end

    end

    if nodeData.type and not ns.MapType0 then -- single tooltips for instances under id names

      if nodeData.type == "Raid" or nodeData.type == "PassageRaid" or nodeData.type == "VInstanceR" then
        tooltip:AddDoubleLine("|cffffffff" .. CALENDAR_TYPE_RAID)
      end

      if nodeData.type == "Dungeon" or nodeData.type == "PassageDungeon" or nodeData.type == "VInstanceD" then
        tooltip:AddDoubleLine("|cffffffff" .. CALENDAR_TYPE_DUNGEON)
      end
    
    end

    -- Boss names
    if ns.Addon.db.profile.BossNames then
      if nodeData.id and type(nodeData.id) ~= "table" then
        local instanceID = nodeData.id
        tooltip:AddLine(" ")

        local typeTextMap = {
          Raid = L["Bosses in this raid"],
          PassageRaid = L["Bosses in this raid"],
          PassageRaidMulti = L["Bosses in this raid"],
          VInstanceR = L["Bosses in this raid"],
          MultipleR = L["Bosses in this raid"],
          MultiVInstanceR = L["Bosses in this raid"],

          Dungeon = L["Bosses in this dungeon"],
          PassageDungeon = L["Bosses in this dungeon"],
          PassageDungeonMulti = L["Bosses in this dungeon"],
          VInstanceD = L["Bosses in this dungeon"],
          MultiVInstanceD = L["Bosses in this dungeon"],
          MultipleD = L["Bosses in this dungeon"],

          MultiVInstance = L["Bosses in this instance"],
        }

        tooltip:AddLine(typeTextMap[nodeData.type] or L["Bosses in this instance"])
        ShowBossNames(instanceID, tooltip)
      end
    end

    -- Extra Tooltip
    if ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen then -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed

      if nodeData.id and not nodeData.mnID then  -- instance entrances
        if ns.Addon.db.profile.journal and not ns.CapitalIDs then
          if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
            tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to open Adventure Guide >"], nil, nil, false) -- instance entrances into adventure guide
          else -- -- Original Buttons
            tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click to open Adventure Guide >"], nil, nil, false) -- instance entrances into adventure guide
          end
        end
        if ns.Addon.db.profile.WayPoints and not ns.CapitalIDs then
          if ns.Addon.db.profile.WayPointsShift then -- Shift
            if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            else -- Original Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            end
          else
            if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            else -- Original Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            end
          end
        end
      end

      if nodeData.mnID or nodeData.delveID or nodeData.dnID then

        if not nodeData.hideInfo == true and not ns.MapType0 then
          if nodeData.mnID then
            if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to show map >"], nil, nil, false)
            else -- Original Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click to show map >"], nil, nil, false)
            end
          end

          if nodeData.delveID then
            if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click to show delve map >"], nil, nil, false)
            else -- Original Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to show delve map >"], nil, nil, false)
            end
          end

          if not (ns.MapType1 or ns.MapType0 or ns.icons["Delves"]) then
            if ns.Addon.db.profile.WayPoints and not ns.CapitalIDs then
              if ns.Addon.db.profile.WayPointsShift then -- Shift
                if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                else
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                end
              else
                if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                else
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                end
              end
            end
          end
        end


        if not (ns.MapType1 or ns.MapType0 or ns.icons["Delves"]) then
          if ns.Addon.db.profile.WayPoints and not ns.CapitalIDs then
            if ns.Addon.db.profile.WayPointsShift then -- Shift
              if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
              else
                tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
              end
            else
              if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
              else
                tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
              end
            end
          end
        end

        if ns.Addon.db.profile.WayPoints then
          if ns.AllZoneIDs or GetCurrentMapID == 12 or GetCurrentMapID == 13 or GetCurrentMapID == 101 or GetCurrentMapID == 113 or GetCurrentMapID == 424 or GetCurrentMapID == 619
          or GetCurrentMapID == 875 or GetCurrentMapID == 876 or GetCurrentMapID == 905 or GetCurrentMapID == 1978 or GetCurrentMapID == 1550 or GetCurrentMapID == 572
          or GetCurrentMapID == 2274 or GetCurrentMapID == 948 then
            if (not nodeData.hideInfo == true) then
              if ns.Addon.db.profile.WayPointsShift then -- Shift
                if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                else -- Original Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                end
              else
                if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                else -- Original Buttons
                  tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
                end
              end
            end
          end
        end

      end

      if nodeData.mnID and nodeData.leaveDelve and ns.icons["Delves"] then

        if ns.Addon.db.profile.WayPoints then
          if ns.Addon.db.profile.WayPointsShift then -- Shift
            if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            else
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            end
          else
              if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            else
              tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"], nil, nil, false)
            end
          end
        end

        tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. "< " .. MIDDLE_BUTTON_STRING .. " " .. INSTANCE_LEAVE .. " (" .. DELVES_LABEL .. ") >", nil, nil, false)
      end
    end

    if ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen then -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed
      if ns.Addon.db.profile.DeleteIcons then
        if not nodeData.hideInfo == true and not ns.MapType0 then
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cffff0000" .. L["< Alt + Right click to delete this icon >"], nil, nil, false)
        end
      end
    end

    tooltip:Show()
  end
end

SLASH_DeveloperMode1 = "/mndevmode";
function SlashCmdList.DeveloperMode(msg, editbox)
  if ns.Addon.db.profile.DeveloperMode == true then
    ns.Addon.db.profile.DeveloperMode = false
    print("MapNotes DeveloperMode = Off")
  else
    ns.Addon.db.profile.DeveloperMode = true 
    print("MapNotes DeveloperMode = On")
  end
end

function ns.pluginHandler:OnLeave(uiMapId, coord)
  if self:GetParent() == WorldMapButton then
    WorldMapTooltip:Hide()
  else
    GameTooltip:Hide()
  end

  if self.highlight then
    self.highlight:Hide()
  end

  if self.texture then
    self.texture:SetDrawLayer("OVERLAY", 5)
  end
end


do
  local tablepool = setmetatable({}, {__mode = "k"})

	local function deepCopy(object)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end

			local new_table = {}
			  lookup_table[object] = new_table
			for index, value in pairs(object) do
				new_table[_copy(index)] = _copy(value)
			end

			return setmetatable(new_table, getmetatable(object))
		end
			return _copy(object)
	end

	local function iter(t, prestate, uiMapID) -- Azeroth / Zone / Minimap / Inside Dungeon settings

		if not t then return end

		local data = t.data
		local state, value = next(data, prestate)
    local GetCurrentMapID = WorldMapFrame:GetMapID()
    local GetBestMapForUnit = C_Map.GetBestMapForUnit("player")

		while value do
			local alpha
		  local icon = ns.icons[value.type]
      local scale
      local mapInfo = C_Map.GetMapInfo(t.uiMapId)

			local allLocked = true
			local anyLocked = false

      ns.SyncSingleScaleAlpha() -- synch single Icons
      ns.SyncWithMinimapScaleAlpha() -- sync Capitals with Capitals - Minimap and/or Zones with Minimap Alpha/Scale
      ns.ChangeToClassicImagesRetail() -- function to change the icon style from new images to old images

      ns.pathIcons = value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR"
      
      ns.professionIcons = value.type == "Alchemy" or value.type == "Engineer" or value.type == "Cooking" or value.type == "Fishing" or value.type == "Archaeology" or value.type == "Mining" or value.type == "Jewelcrafting" 
                            or value.type == "Blacksmith" or value.type == "Leatherworking" or value.type == "Skinning" or value.type == "Tailoring" or value.type == "Herbalism" or value.type == "Inscription"
                            or value.type == "Enchanting" or value.type == "FishingClassic" or value.type == "ProfessionOrders" or value.type == "ProfessionsMixed"

      ns.instanceIcons = value.type == "Dungeon" or value.type == "Raid" or value.type == "PassageDungeon" or value.type == "PassageDungeonRaidMulti" or value.type == "PassageRaid" or value.type == "VInstance" or value.type == "MultiVInstance" 
                          or value.type == "Multiple" or value.type == "LFR" or value.type == "Gray" or value.type == "VKey1" or value.type == "Delves" or value.type == "VInstanceD" or value.type == "VInstanceR" or value.type == "MultiVInstanceD" 
                          or value.type == "MultiVInstanceR" or value.type == "DelvesPassage" or value.type == "PassageLFR"

      ns.transportIcons = value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" 
                          or value.type == "PassageAPortal" or value.type == "PassagePortal" or value.type == "Zeppelin" or value.type == "HZeppelin" or value.type == "AZeppelin" or value.type == "Ship" or value.type == "TorghastUp"
                          or value.type == "AShip" or value.type == "HShip" or value.type == "Carriage" or value.type == "TravelL" or value.type == "TravelH" or value.type == "TravelA" or value.type == "Tport2" 
                          or value.type == "OgreWaygate" or value.type == "WayGateGreen" or value.type == "Ghost" or value.type == "DarkMoon" or value.type == "Mirror" or value.type == "TravelM" or value.type == "B11M" 
                          or value.type == "MOrcF" or value.type == "UndeadF" or value.type == "GoblinF" or value.type == "GilneanF" or value.type == "KulM" or value.type == "DwarfF" or value.type == "OrcM" or value.type == "WayGateGolden"
                          or value.type == "MoleMachineDwarf"
                          
      ns.generalIcons = value.type == "Exit" or value.type == "PassageUpL" or value.type == "PassageDownL" or value.type == "PassageRightL" or value.type == "PassageLeftL" or value.type == "Innkeeper" 
                        or value.type == "Auctioneer" or value.type == "Bank" or value.type == "MNL" or value.type == "Barber" or value.type == "Transmogger" or value.type == "ItemUpgrade" or value.type == "PvPVendor" 
                        or value.type == "PvEVendor" or value.type == "DragonFlyTransmog" or value.type == "Catalyst" or value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" 
                        or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR" or value.type == "BlackMarket" or value.type == "Mailbox"
                        or value.type == "StablemasterN" or value.type == "StablemasterH" or value.type == "StablemasterA" or value.type == "HIcon" or value.type == "AIcon" or value.type == "InnkeeperN" 
                        or value.type == "InnkeeperH" or value.type == "InnkeeperA" or value.type == "MailboxN" or value.type == "MailboxH" or value.type == "MailboxA" or value.type == "PvPVendorH" or value.type == "PvPVendorA" 
                        or value.type == "PvEVendorH" or value.type == "PvEVendorA" or value.type == "MMInnkeeperH" or value.type == "MMInnkeeperA" or value.type == "MMStablemasterH" or value.type == "MMStablemasterA"
                        or value.type == "MMMailboxH" or value.type == "MMMailboxA" or value.type == "MMPvPVendorH" or value.type == "MMPvPVendorA" or value.type == "MMPvEVendorH" or value.type == "MMPvEVendorA" 
                        or value.type == "ZonePvEVendorH" or value.type == "ZonePvPVendorH" or value.type == "ZonePvEVendorA" or value.type == "ZonePvPVendorA" or value.type == "TradingPost" or value.type == "PassageCaveUp"
                        or value.type == "PassageCaveDown" or value.type == "MountMerchant"

      ns.AllZoneIDs = ns.KalimdorIDs
                      or ns.EasternKingdomIDs
                      or ns.OutlandIDs
                      or ns.NorthrendIDs
                      or ns.DraenorIDs
                      or ns.PandariaIDs
                      or ns.BrokenIslesIDs
                      or ns.ZandalarIDs
                      or ns.KulTirasIDs
                      or ns.ShadowlandIDs
                      or ns.DragonIsleIDs
                      or ns.KhazAlgar

      ns.MapType0 = mapInfo.mapType == 0 -- Cosmic map
      ns.MapType1 = mapInfo.mapType == 1 -- World map
      ns.MapType2 = mapInfo.mapType == 2 -- Continent maps
      ns.MapType3 = mapInfo.mapType == 3 -- Zone maps
      ns.MapType4 = mapInfo.mapType == 4 -- Dungeon maps
      ns.MapType5 = mapInfo.mapType == 5 -- Micro maps
      ns.MapType6 = mapInfo.mapType == 6 -- Orphan maps

      ns.ContinentIDs = GetCurrentMapID == 12 or GetCurrentMapID == 13 or GetCurrentMapID == 101 or GetCurrentMapID == 113 or GetCurrentMapID == 424 or GetCurrentMapID == 619
                      or GetCurrentMapID == 875 or GetCurrentMapID == 876 or GetCurrentMapID == 905 or GetCurrentMapID == 1978 or GetCurrentMapID == 1550 or GetCurrentMapID == 572
                      or GetCurrentMapID == 2274 or GetCurrentMapID == 948

      ns.CapitalIDs = GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85 or GetCurrentMapID == 90 
                      or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111 or GetCurrentMapID == 125 or GetCurrentMapID == 126 
                      or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 or GetCurrentMapID == 394 or GetCurrentMapID == 407 or GetCurrentMapID == 503 
                      or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 or GetCurrentMapID == 626 or GetCurrentMapID == 627 
                      or GetCurrentMapID == 831 or GetCurrentMapID == 832 or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 
                      or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 
                      or GetCurrentMapID == 2112 or GetCurrentMapID == 2339 or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2266 

      ns.CapitalMiniMapIDs = GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85 or GetBestMapForUnit == 90 
                      or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111 or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 
                      or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 or GetBestMapForUnit == 394 or GetBestMapForUnit == 407 or GetBestMapForUnit == 503 
                      or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 
                      or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetCurrentMapID == 831 or GetCurrentMapID == 832 or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 
                      or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 or GetBestMapForUnit == 1670 or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 
                      or GetBestMapForUnit == 2112 or GetBestMapForUnit == 2339 or GetBestMapForUnit == 499 or GetBestMapForUnit == 500 or GetBestMapForUnit == 2266

      ns.KalimdorIDs = GetCurrentMapID == 1 or GetCurrentMapID == 7 or GetCurrentMapID == 10 or GetCurrentMapID == 11 or GetCurrentMapID == 57 or GetCurrentMapID == 62 
                      or GetCurrentMapID == 63 or GetCurrentMapID == 64 or GetCurrentMapID == 65 or GetCurrentMapID == 66 or GetCurrentMapID == 67 or GetCurrentMapID == 68 
                      or GetCurrentMapID == 69 or GetCurrentMapID == 70 or GetCurrentMapID == 71 or GetCurrentMapID == 74 or GetCurrentMapID == 75 or GetCurrentMapID == 76 
                      or GetCurrentMapID == 77 or GetCurrentMapID == 78 or GetCurrentMapID == 80 or GetCurrentMapID == 81 or GetCurrentMapID == 83 or GetCurrentMapID == 97 
                      or GetCurrentMapID == 106 or GetCurrentMapID == 199 or GetCurrentMapID == 327 or GetCurrentMapID == 460 or GetCurrentMapID == 461 or GetCurrentMapID == 462 
                      or GetCurrentMapID == 468 or GetCurrentMapID == 1527 or GetCurrentMapID == 198 or GetCurrentMapID == 249
          
      ns.EasternKingdomIDs = GetCurrentMapID == 14 or GetCurrentMapID == 15 or GetCurrentMapID == 16 or GetCurrentMapID == 17 or GetCurrentMapID == 18 
                      or GetCurrentMapID == 19 or GetCurrentMapID == 21 or GetCurrentMapID == 22 or GetCurrentMapID == 23 or GetCurrentMapID == 25 or GetCurrentMapID == 26 
                      or GetCurrentMapID == 27 or GetCurrentMapID == 28 or GetCurrentMapID == 30 or GetCurrentMapID == 32 or GetCurrentMapID == 33 or GetCurrentMapID == 34 
                      or GetCurrentMapID == 35 or GetCurrentMapID == 36 or GetCurrentMapID == 37 or GetCurrentMapID == 42 or GetCurrentMapID == 47 or GetCurrentMapID == 48 
                      or GetCurrentMapID == 49 or GetCurrentMapID == 50 or GetCurrentMapID == 51 or GetCurrentMapID == 52 or GetCurrentMapID == 55 or GetCurrentMapID == 56 
                      or GetCurrentMapID == 94 or GetCurrentMapID == 210 or GetCurrentMapID == 224 or GetCurrentMapID == 245 or GetCurrentMapID == 425 or GetCurrentMapID == 427 
                      or GetCurrentMapID == 465 or GetCurrentMapID == 467 or GetCurrentMapID == 469 or GetCurrentMapID == 2070 
                      or GetCurrentMapID == 241 or GetCurrentMapID == 203 or GetCurrentMapID == 204 or GetCurrentMapID == 205 or GetCurrentMapID == 241 or GetCurrentMapID == 244 
                      or GetCurrentMapID == 245 or GetCurrentMapID == 201 or GetCurrentMapID == 95 or GetCurrentMapID == 122 or GetCurrentMapID == 217 or GetCurrentMapID == 226
          
      ns.OutlandIDs = GetCurrentMapID == 100 or GetCurrentMapID == 102 or GetCurrentMapID == 104 or GetCurrentMapID == 105 or GetCurrentMapID == 107 or GetCurrentMapID == 108
                      or GetCurrentMapID == 109
          
      ns.NorthrendIDs = GetCurrentMapID == 114 or GetCurrentMapID == 115 or GetCurrentMapID == 116 or GetCurrentMapID == 117 or GetCurrentMapID == 118 or GetCurrentMapID == 119
                      or GetCurrentMapID == 120 or GetCurrentMapID == 121 or GetCurrentMapID == 123 or GetCurrentMapID == 127 or GetCurrentMapID == 170
          
      ns.PandariaIDs = GetCurrentMapID == 371 or GetCurrentMapID == 376 or GetCurrentMapID == 379 or GetCurrentMapID == 388 or GetCurrentMapID == 390 or GetCurrentMapID == 418
                      or GetCurrentMapID == 422 or GetCurrentMapID == 433 or GetCurrentMapID == 434 or GetCurrentMapID == 504 or GetCurrentMapID == 554 or GetCurrentMapID == 1530
                      or GetCurrentMapID == 507
          
      ns.DraenorIDs = GetCurrentMapID == 525 or GetCurrentMapID == 534 or GetCurrentMapID == 535 or GetCurrentMapID == 539 or GetCurrentMapID == 542 or GetCurrentMapID == 543
                      or GetCurrentMapID == 550 or GetCurrentMapID == 588
          
      ns.BrokenIslesIDs = GetCurrentMapID == 630 or GetCurrentMapID == 634 or GetCurrentMapID == 641 or GetCurrentMapID == 646 or GetCurrentMapID == 650 or GetCurrentMapID == 652
                      or GetCurrentMapID == 750 or GetCurrentMapID == 680 or GetCurrentMapID == 830 or GetCurrentMapID == 882 or GetCurrentMapID == 885 or GetCurrentMapID == 905
                      or GetCurrentMapID == 941 or GetCurrentMapID == 790 or GetCurrentMapID == 971
          
      ns.ZandalarIDs = GetCurrentMapID == 862 or GetCurrentMapID == 863 or GetCurrentMapID == 864 or GetCurrentMapID == 1355 or GetCurrentMapID == 1528
          
      ns.KulTirasIDs = GetCurrentMapID == 895 or GetCurrentMapID == 896 or GetCurrentMapID == 942 or GetCurrentMapID == 1462 or GetCurrentMapID == 1169
          
      ns.ShadowlandIDs = GetCurrentMapID == 1525 or GetCurrentMapID == 1533 or GetCurrentMapID == 1536 or GetCurrentMapID == 1543 or GetCurrentMapID == 1565 or GetCurrentMapID == 1961
                      or GetCurrentMapID == 1970 or GetCurrentMapID == 2016
          
      ns.DragonIsleIDs = GetCurrentMapID == 2022 or GetCurrentMapID == 2023 or GetCurrentMapID == 2024 or GetCurrentMapID == 2025 or GetCurrentMapID == 2026 or GetCurrentMapID == 2133
                      or GetCurrentMapID == 2151 or GetCurrentMapID == 2200 or GetCurrentMapID == 2239
          
      ns.KhazAlgar = GetCurrentMapID == 2248 or GetCurrentMapID == 2214 or GetCurrentMapID == 2215 or GetCurrentMapID == 2255 or  GetCurrentMapID == 2256 or GetCurrentMapID == 2213 
                      or GetCurrentMapID == 2216 or GetCurrentMapID == 2369 or GetCurrentMapID == 2346 or GetCurrentMapID == 2371 or GetCurrentMapID == 2472

      ns.ZoneIDs = GetCurrentMapID == 750 or GetCurrentMapID == 652 or GetCurrentMapID == 2266 or GetCurrentMapID == 2322

			if value.name == nil then value.name = value.id or value.mnID end

			local instances = { strsplit("\n", value.name) }
			for i, v in pairs(instances) do
				if (not extraInformations[v] and not extraInformations[lfgIDs[v]]) then
					allLocked = false
				else
					anyLocked = true
				end
			end

      -- new assigned function single
      if anyLocked and db.graySingleID and allLocked then
        icon = ns.icons["Gray"]
      end

      -- new assigned function multi
      if (anyLocked and db.grayMultipleID) then
        icon = ns.icons["Gray"]
      end

      if (value.type == "LFR") then
        icon = ns.icons["LFR"]
      end

      if (value.type == "PassageLFR") then
        icon = ns.icons["PassageLFR"]
      end

      if (value.type == "HIcon") then
        icon = ns.icons["HIcon"]
      end

      if (value.type == "AIcon") then
        icon = ns.icons["AIcon"]
      end

      if (anyLocked and db.invertlockout) or (allLocked and not db.invertlockout) then
				alpha = db.mapnoteAlpha
      else
				alpha = db.mapnoteAlpha
			end

      -- MiniMap Instance World
      if ns.instanceIcons and (value.showOnMinimap == true) then
        scale = db.MiniMapInstanceScale
        alpha = db.MiniMapInstanceAlpha
      end

      -- MiniMap Transport (Zeppeline/Ship/Carriage) icons
      if not ns.CapitalMiniMapIDs and ns.transportIcons and (value.showOnMinimap == true) then
        scale = db.MiniMapTransportScale
        alpha = db.MiniMapTransportAlpha
      end

      -- Profession Minimap icons in Zone
      if not ns.CapitalMiniMapIDs and ns.professionIcons and (value.showOnMinimap == true) then
        scale = db.MiniMapProfessionsScale
        alpha = db.MiniMapProfessionsAlpha
      end

      -- MiniMap General icons
      if not ns.CapitalMiniMapIDs and ns.generalIcons and (value.showOnMinimap == true) or ns.ZoneIDs and not value.showInZone then
        scale = db.MiniMapGeneralScale
        alpha = db.MiniMapGeneralAlpha
      end

      -- MiniMap single icon scale / alpha
      if not ns.CapitalMiniMapIDs or ns.ZoneIDs and (value.showOnMinimap == true)  then

        -- Instance Icons
        if value.type == "Raid" then
          scale = db.MiniMapScaleRaids
          alpha = db.MiniMapAlphaRaids
        end

        if value.type == "Dungeon" then
          scale = db.MiniMapScaleDungeons
          alpha = db.MiniMapAlphaDungeons
        end        

        if value.type == "PassageDungeon" or value.type == "PassageRaid" or value.type == "DelvesPassage" then
          scale = db.MiniMapScalePassage
          alpha = db.MiniMapAlphaPassage
        end

        if value.type == "Multiple" or value.type == "MultipleM" or value.type == "MultipleR" or value.type == "MultipleD" or value.type == "PassageDungeonRaidMulti" then
          scale = db.MiniMapScaleMultiple
          alpha = db.MiniMapAlphaMultiple
        end

        if value.type == "VInstance" or value.type == "MultiVInstance" or value.type == "VKey1" or value.type == "VInstanceD" or value.type == "VInstanceR" or value.type == "MultiVInstanceD" or value.type == "MultiVInstanceR" then
          scale = db.MiniMapScaleOldVanilla
          alpha = db.MiniMapAlphaOldVanilla
        end

        if value.type == "LFR" or value.type == "PassageLFR" then
          scale = db.MiniMapScaleLFR
          alpha = db.MiniMapAlphaLFR
        end

        -- Transport Icons
        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" 
          or value.type == "PassageAPortal" or value.type == "WayGateGolden" or value.type == "WayGateGreen" or value.type == "DarkMoon" or value.type == "TorghastUp" then
          scale = db.MiniMapScalePortals
          alpha = db.MiniMapAlphaPortals
        end

        if value.type == "DarkMoon" then
          scale = db.MiniMapScaleDarkmoon
          alpha = db.MiniMapAlphaDarkmoon
        end

        if value.type == "MoleMachineDwarf" then
          scale = db.MiniMapScaleRaces
          alpha = db.MiniMapAlphaRaces
        end

        if value.type == "Zeppelin" or value.type == "HZeppelin" or value.type == "AZeppelin" then
          scale = db.MiniMapScaleZeppelins
          alpha = db.MiniMapAlphaZeppelins
        end

        if value.type == "Ship" or value.type == "AShip" or value.type == "HShip" then
          scale = db.MiniMapScaleShips
          alpha = db.MiniMapAlphaShips
        end

        if value.type == "Carriage" or value.type == "TravelM" or value.type == "TravelA" or value.type == "MoleMachine" or value.type == "RocketDrill" then
          scale = db.MiniMapScaleTransport
          alpha = db.MiniMapAlphaTransport
        end

        if value.type == "OgreWaygate" then
          scale = db.MiniMapScaleOgreWaygate
          alpha = db.MiniMapAlphaOgreWaygate
        end

        if value.type == "Tport2" then
          scale = db.MiniMapScaleTeleporter
          alpha = db.MiniMapAlphaTeleporter
        end

        if value.type == "Mirror" then
          scale = db.MiniMapScaleMirror
          alpha = db.MiniMapAlphaMirror
        end

        if value.type == "B11M"  or value.type == "MOrcF" or value.type == "UndeadF" or value.type == "GoblinF" or value.type == "GilneanF" or value.type == "KulM" or value.type == "DwarfF" or value.type == "OrcM" then
          scale = db.MiniMapScaleTravel
          alpha = db.MiniMapAlphaTravel
        end

        -- General Icons
        if value.type == "MNL" then
          scale = db.MiniMapScaleMapNotesIcons
          alpha = db.MiniMapAlphaMapNotesIcons
        end

        if value.type == "HIcon" or value.type == "AIcon" then
          scale = db.MiniMapScaleHordeAllyIcons
          alpha = db.MiniMapAlphaHordeAllyIcons
        end

        if value.type == "Innkeeper" or value.type == "InnkeeperN" or value.type == "InnkeeperH" or value.type == "InnkeeperA" or value.type == "MMInnkeeperH" or value.type == "MMInnkeeperA" then
          scale = db.MiniMapScaleInnkeeper
          alpha = db.MiniMapAlphaInnkeeper
        end

        if value.type == "Auctioneer" or value.type == "BlackMarket" then
          scale = db.MiniMapScaleAuctioneer
          alpha = db.MiniMapAlphaAuctioneer
        end

        if value.type == "Bank" then
          scale = db.MiniMapScaleBank
          alpha = db.MiniMapAlphaBank
        end

        if value.type == "Barber" then
          scale = db.MiniMapScaleBarber
          alpha = db.MiniMapAlphaBarber
        end

        if value.type == "Mailbox" or value.type == "MailboxN" or value.type == "MailboxH" or value.type == "MailboxA" or value.type == "MMMailboxH" or value.type == "MMMailboxA" then
          scale = db.MiniMapScaleMailbox
          alpha = db.MiniMapAlphaMailbox
        end

        if value.type == "PvPVendor" or value.type == "PvPVendorH" or value.type == "PvPVendorA" or value.type == "ZonePvPVendorH" or value.type == "ZonePvPVendorA" then
          scale = db.MiniMapScalePvPVendor
          alpha = db.MiniMapAlphaPvPVendor
        end

        if value.type == "PvEVendor" or value.type == "PvEVendorH" or value.type == "PvEVendorA" or value.type == "ZonePvEVendorH" or value.type == "ZonePvEVendorA" then
          scale = db.MiniMapScalePvEVendor
          alpha = db.MiniMapAlphaPvEVendor
        end

        if value.type == "StablemasterN" or value.type == "StablemasterH" or value.type == "StablemasterA" or value.type == "MMStablemasterH" or value.type == "MMStablemasterA" then
          scale = db.MiniMapScaleStablemaster
          alpha = db.MiniMapAlphaStablemaster
        end

        if value.type == "Catalyst" then
          scale = db.MiniMapScaleCatalyst
          alpha = db.MiniMapAlphaCatalyst
        end

        if value.type == "Zidormi" then
          scale = db.MiniMapScaleZidormi
          alpha = db.MiniMapAlphaZidormi
        end

        if value.type == "Transmogger" then
          scale = db.MiniMapScaleTransmogger
          alpha = db.MiniMapAlphaTransmogger
        end

        if value.type == "ItemUpgrade" then
          scale = db.MiniMapScaleItemUpgrade
          alpha = db.MiniMapAlphaItemUpgrade
        end

        if ns.pathIcons or ns.ZoneIDs and not value.showInZone and not GetCurrentMapID == 2322 then
          scale = db.MiniMapScalePaths
          alpha = db.MiniMapAlphaPaths
        end

      end

      -- inside Dungeon
      if (mapInfo.mapType == 4 or mapInfo.mapType == 6) and not ns.CapitalIDs and not ns.ZoneIDs then
          scale = db.dungeonScale
          alpha = db.dungeonAlpha
      end

      -- Dungeon Single scale / alpha
      if (mapInfo.mapType == 4 or mapInfo.mapType == 6) and not ns.CapitalIDs and not ns.ZoneIDs then

        if value.type == "Exit" then
          scale = db.DungeonMapScaleExit
          alpha = db.DungeonMapAlphaExit
        end

        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" 
          or value.type == "PassageAPortal" then
          scale = db.DungeonMapScalePortal
          alpha = db.DungeonMapAlphaPortal
        end

        if value.type == "PassageUpL" or value.type == "PassageDownL" or value.type == "PassageRightL" or value.type == "PassageLeftL" then
          scale = db.DungeonMapScalePassage
          alpha = db.DungeonMapAlphaPassage
        end

        if value.type == "Tport2" or value.type == "TravelM" or value.type == "TravelL" or value.type == "TravelH" or value.type == "TravelA" then
          scale = db.DungeonMapScaleTransport
          alpha = db.DungeonMapAlphaTransport
        end

        if value.type == "PvEVendor" or value.type == "PvPVendor" then
          scale = db.DungeonMapScaleVendor
          alpha = db.DungeonMapAlphaVendor
        end

      end


      -- Profession Minimap icons in Capitals
      if ns.professionIcons and ns.CapitalMiniMapIDs and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsProfessionsScale
        alpha = db.MinimapCapitalsProfessionsAlpha
      end

      -- Capitals Minimap Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalMiniMapIDs and ns.transportIcons and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsTransportScale
        alpha = db.MinimapCapitalsTransportAlpha
      end

      -- Capitals Minimap Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalMiniMapIDs and ns.instanceIcons and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsInstanceScale
        alpha = db.MinimapCapitalsInstanceAlpha
      end

      -- Capitals Minimap General (Innkeeper/Exit/Passage) icons
      if ns.CapitalMiniMapIDs and ns.generalIcons and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsGeneralScale
        alpha = db.MinimapCapitalsGeneralAlpha
      end

      -- Instance icons World
      if ns.instanceIcons and (not value.showOnMinimap == true) then
        scale = db.ZoneInstanceScale
        alpha = db.ZoneInstanceAlpha
      end

      -- Zone Transport icons
      if not ns.CapitalIDs and ns.transportIcons and (value.showOnMinimap == false) then
        scale = db.ZoneTransportScale
        alpha = db.ZoneTransportAlpha
      end

      -- Zone Profession icons 
      if not ns.CapitalIDs and ns.professionIcons and (value.showOnMinimap == false) then
        scale = db.ZoneProfessionsScale
        alpha = db.ZoneProfessionsAlpha
      end

      -- Zones General icons
      if not ns.CapitalIDs and ns.generalIcons and (value.showOnMinimap == false) then
        scale = db.ZoneGeneralScale
        alpha = db.ZoneGeneralAlpha
      end

      -- Zone single icon scale / alpha
      if not ns.CapitalIDs and (value.showOnMinimap == false) then

        -- Instance Icons
        if value.type == "Raid" then
          scale = db.ZoneScaleRaids
          alpha = db.ZoneAlphaRaids
        end

        if value.type == "Dungeon" then
          scale = db.ZoneScaleDungeons
          alpha = db.ZoneAlphaDungeons
        end        

        if value.type == "PassageDungeon" or value.type == "PassageRaid" then
          scale = db.ZoneScalePassage
          alpha = db.ZoneAlphaPassage
        end

        if value.type == "Multiple" or value.type == "MultipleM" or value.type == "MultipleR" or value.type == "MultipleD" or value.type == "PassageDungeonRaidMulti" then
          scale = db.ZoneScaleMultiple
          alpha = db.ZoneAlphaMultiple
        end

        if value.type == "VInstance" or value.type == "MultiVInstance" or value.type == "VKey1" or value.type == "VInstanceD" or value.type == "VInstanceR" or value.type == "MultiVInstanceD" or value.type == "MultiVInstanceR" then
          scale = db.ZoneScaleOldVanilla
          alpha = db.ZoneAlphaOldVanilla
        end

        if value.type == "LFR" or value.type == "PassageLFR" then
          scale = db.ZoneScaleLFR
          alpha = db.ZoneAlphaLFR
        end

        -- Transport Icons
        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" 
          or value.type == "PassageAPortal" or value.type == "WayGateGolden" or value.type == "WayGateGreen" or value.type == "TorghastUp" then
          scale = db.ZoneScalePortals
          alpha = db.ZoneAlphaPortals
        end

        if value.type == "DarkMoon" then
          scale = db.ZoneScaleDarkmoon
          alpha = db.ZoneAlphaDarkmoon
        end

        if value.type == "MoleMachineDwarf" then
          scale = db.ZoneScaleRaces
          alpha = db.ZoneAlphaRaces
        end

        if value.type == "Zeppelin" or value.type == "HZeppelin" or value.type == "AZeppelin" then
          scale = db.ZoneScaleZeppelins
          alpha = db.ZoneAlphaZeppelins
        end

        if value.type == "Ship" or value.type == "AShip" or value.type == "HShip" then
          scale = db.ZoneScaleShips
          alpha = db.ZoneAlphaShips
        end

        if value.type == "Carriage" or value.type == "TravelM" or value.type == "TravelA" or value.type == "MoleMachine" or value.type == "RocketDrill" then
          scale = db.ZoneScaleTransport
          alpha = db.ZoneAlphaTransport
        end

        if value.type == "OgreWaygate" then
          scale = db.ZoneScaleOgreWaygate
          alpha = db.ZoneAlphaOgreWaygate
        end

        if value.type == "Tport2" then
          scale = db.ZoneScaleTeleporter
          alpha = db.ZoneAlphaTeleporter
        end

        if value.type == "Mirror" then
          scale = db.ZoneScaleMirror
          alpha = db.ZoneAlphaMirror
        end

        if value.type == "B11M"  or value.type == "MOrcF" or value.type == "UndeadF" or value.type == "GoblinF" or value.type == "GilneanF" or value.type == "KulM" or value.type == "DwarfF" or value.type == "OrcM" then
          scale = db.ZoneScaleTravel
          alpha = db.ZoneAlphaTravel
        end

        -- General Icons
        if value.type == "MNL" then
          scale = db.ZoneScaleMapNotesIcons
          alpha = db.ZoneAlphaMapNotesIcons
        end

        if value.type == "HIcon" or value.type == "AIcon" then
          scale = db.ZoneScaleHordeAllyIcons
          alpha = db.ZoneAlphaHordeAllyIcons
        end

        if value.type == "Innkeeper" or value.type == "InnkeeperN" or value.type == "InnkeeperH" or value.type == "InnkeeperA" then
          scale = db.ZoneScaleInnkeeper
          alpha = db.ZoneAlphaInnkeeper
        end

        if value.type == "Auctioneer" or value.type == "BlackMarket" then
          scale = db.ZoneScaleAuctioneer
          alpha = db.ZoneAlphaAuctioneer
        end

        if value.type == "Bank" then
          scale = db.ZoneScaleBank
          alpha = db.ZoneAlphaBank
        end

        if value.type == "Barber" then
          scale = db.ZoneScaleBarber
          alpha = db.ZoneAlphaBarber
        end

        if value.type == "Mailbox" or value.type == "MailboxN" or value.type == "MailboxH" or value.type == "MailboxA" then
          scale = db.ZoneScaleMailbox
          alpha = db.ZoneAlphaMailbox
        end

        if value.type == "PvPVendor" or value.type == "PvPVendorH" or value.type == "PvPVendorA" or value.type == "ZonePvPVendorH" or value.type == "ZonePvPVendorA" then
          scale = db.ZoneScalePvPVendor
          alpha = db.ZoneAlphaPvPVendor
        end

        if value.type == "PvEVendor" or value.type == "PvEVendorH" or value.type == "PvEVendorA" or value.type == "ZonePvEVendorH" or value.type == "ZonePvEVendorA" then
          scale = db.ZoneScalePvEVendor
          alpha = db.ZoneAlphaPvEVendor
        end

        if value.type == "StablemasterN" or value.type == "StablemasterH" or value.type == "StablemasterA" then
          scale = db.ZoneScaleStablemaster
          alpha = db.ZoneAlphaStablemaster
        end

        if value.type == "Catalyst" then
          scale = db.ZoneScaleCatalyst
          alpha = db.ZoneAlphaCatalyst
        end

        if value.type == "Zidormi" then
          scale = db.ZoneScaleZidormi
          alpha = db.ZoneAlphaZidormi
        end

        if value.type == "Transmogger" then
          scale = db.ZoneScaleTransmogger
          alpha = db.ZoneAlphaTransmogger
        end

        if value.type == "ItemUpgrade" then
          scale = db.ZoneScaleItemUpgrade
          alpha = db.ZoneAlphaItemUpgrade
        end

        if ns.pathIcons then
          scale = db.ZoneScalePaths
          alpha = db.ZoneAlphaPaths
        end
        
      end

      -- Capitals Profession icons 
      if ns.CapitalIDs and ns.professionIcons and (value.showOnMinimap == false) then
        scale = db.CapitalsProfessionsScale
        alpha = db.CapitalsProfessionsAlpha
      end

      -- Capitals General (Innkeeper/Exit/Passage) icons
      if ns.CapitalIDs and ns.generalIcons and (value.showOnMinimap == false) then
        scale = db.CapitalsGeneralScale
        alpha = db.CapitalsGeneralAlpha
      end

      -- Capitals Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalIDs and ns.transportIcons and (value.showOnMinimap == false) then
        scale = db.CapitalsTransportScale
        alpha = db.CapitalsTransportAlpha
      end

      -- Capitals Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalIDs and ns.instanceIcons and (value.showOnMinimap == false) then
        scale = db.CapitalsInstanceScale
        alpha = db.CapitalsInstanceAlpha
      end
      
      if t.uiMapId == 947 then-- Azeroth World Map
        scale = db.azerothScale
        alpha = db.azerothAlpha
      end

      if t.uiMapId == 946 then-- Cosmos World Map
        scale = db.cosmosScale
        alpha = db.cosmosAlpha
      end

      -- mapType == X
      -- X = 0 =	Cosmic 	
      -- X = 1 =	World 	
      -- X = 2 =	Continent 	
      -- X = 3 =	Zone 	
      -- X = 4 =	Dungeon 	
      -- X = 5 =	Micro 	
      -- X = 6 =	Orphan 	

      if t.uiMapId == 948 -- Mahlstrom Continent 
        or t.uiMapId == 905 -- Argus Continent
        or (mapInfo.mapType == 0 and (ns.dbChar.AzerothDeletedIcons[t.uiMapId] and not ns.dbChar.AzerothDeletedIcons[t.uiMapId][state])) -- Cosmos
        or (mapInfo.mapType == 1 and (ns.dbChar.AzerothDeletedIcons[t.uiMapId] and not ns.dbChar.AzerothDeletedIcons[t.uiMapId][state])) -- Azeroth
        or (not ns.CapitalIDs and (mapInfo.mapType == 4 or mapInfo.mapType == 6) and (ns.dbChar.DungeonDeletedIcons[t.uiMapId] and not ns.dbChar.DungeonDeletedIcons[t.uiMapId][state])) -- Dungeon
        or (not ns.CapitalIDs and (ns.dbChar.ZoneDeletedIcons[t.uiMapId] and not ns.dbChar.ZoneDeletedIcons[t.uiMapId][state] and value.showInZone) and (mapInfo.mapType == 3 or mapInfo.mapType == 5 )) -- Zone without Capitals
        or (ns.CapitalIDs and (ns.dbChar.CapitalsDeletedIcons[t.uiMapId] and not ns.dbChar.CapitalsDeletedIcons[t.uiMapId][state] and value.showInZone)) -- Capitals
        or (ns.CapitalIDs and ns.dbChar.MinimapCapitalsDeletedIcons[t.minimapId] and not ns.dbChar.MinimapCapitalsDeletedIcons[t.minimapId][state] and value.showOnMinimap) -- Minimap Capitals
        or (not ns.CapitalIDs and (mapInfo.mapType == 3 or mapInfo.mapType == 5) and ns.dbChar.MinimapZoneDeletedIcons[t.minimapId] and not ns.dbChar.MinimapZoneDeletedIcons[t.minimapId][state] and value.showOnMinimap) -- Minimap Zones
      then
        return state, nil, icon, scale, alpha
      end
			state, value = next(data, state)
		end
		wipe(t)
		tablepool[t] = true
	end

	local function iterCont(t, prestate) -- continent settings
		if not t then return end

    local state, value
  	local continent = t.C[t.Z]
    local data = nodes[continent]


		while continent do

			if data then -- Only if there is data for this continent
				state, value = next(data, prestate)

				while state do -- Have we reached the end of this continent?
          local alpha
          local icon = ns.icons[value.type]
          local mapInfo = C_Map.GetMapInfo(WorldMapFrame:GetMapID())

					local allLocked = true
					local anyLocked = false
          
					local instances = { strsplit("\n", value.name) }
					for i, v in pairs(instances) do
						if (not extraInformations[v] and not extraInformations[lfgIDs[v]]) then
							allLocked = false
						else
							anyLocked = true
						end
					end

          -- new assigned function single
          if anyLocked and db.graySingleID and allLocked then
            icon = ns.icons["Gray"]
          end

          -- new assigned function multi
          if (anyLocked and db.grayMultipleID) then
            icon = ns.icons["Gray"]
          end

          if (value.type == "LFR" or value.type == "PassageLFR") then
            icon = ns.icons["LFR"]
          end
    
          if (value.type == "HIcon") then
            icon = ns.icons["HIcon"]
          end
    
          if (value.type == "AIcon") then
            icon = ns.icons["AIcon"]
          end

          if (anyLocked and db.invertlockout) or (allLocked and not db.invertlockout) then
						alpha = db.continentAlpha
          else
            alpha = db.continentAlpha
          end
              
          if (mapInfo.mapType == 2 and (ns.dbChar.ContinentDeletedIcons[t.contId] and not ns.dbChar.ContinentDeletedIcons[t.contId][state]) and value.showOnContinent) then -- Continent
            return state, continent, icon, db.continentScale, alpha
          end

					state, value = next(data, state)  -- Get next data
				end
			end
      -- Get next continent
			t.Z = next(t.C, t.Z)
			continent = t.C[t.Z]
			data = nodes[continent]
			prestate = nil
		end
		wipe(t)
		tablepool[t] = true
	end

function ns.pluginHandler:GetNodes2(uiMapId, isMinimapUpdate)
  --print(uiMapId)
      local C = deepCopy(HandyNotes:GetContinentZoneList(uiMapId)) -- Is this a continent?
      if C then
          table.insert(C, uiMapId)
          local tbl = next(tablepool) or {}
          tablepool[tbl] = nil
          tbl.C = C
          tbl.Z = next(C)
          tbl.contId = uiMapId
          return iterCont, tbl, nil
      else
          if (nodes[uiMapId] == nil) then return iter end 
          local tbl = next(tablepool) or {}
          tablepool[tbl] = nil
          tbl.minimapUpdate = isMinimapUpdate
          tbl.uiMapId = uiMapId
          tbl.minimapId = uiMapId
          if (isMinimapUpdate and minimap[uiMapId]) then
              tbl.data = minimap[uiMapId]
          else
              tbl.data = nodes[uiMapId]
          end
          return iter, tbl, nil
      end
  end
end

local function setWaypoint(uiMapID, coord)

  local function getMNIDName(mnID)
    return C_Map.GetMapInfo(mnID) and C_Map.GetMapInfo(mnID).name or nil
  end

  local dungeon = nodes[uiMapID] and nodes[uiMapID][coord]
  if not dungeon then
      return
  end

  local function getCoordinatesForTomTom(coord)
    local x, y = HandyNotes:getXY(coord)
    return x, y
  end

  if TomTom then
    local x, y = getCoordinatesForTomTom(coord)

    local mnIDName = dungeon.mnID and getMNIDName(dungeon.mnID) or nil
    local title
    if mnIDName and mnIDName ~= "" then
        if dungeon.name and dungeon.name ~= "" then
            title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "\n" .. L["Way to"] .. "\n" .. dungeon.name .. " " .. mnIDName
        else
            title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "\n" .. L["Way to"] .. "\n" .. mnIDName
        end
    elseif dungeon.dnID and dungeon.dnID ~= "" then
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "\n" .. L["Way to"] .. "\n" .. dungeon.dnID
    elseif dungeon.TransportName and dungeon.TransportName ~= "" then
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "\n" .. L["Way to"] .. "\n" .. dungeon.TransportName .. "\n" .. dungeon.name
    elseif dungeon.name and dungeon.name ~= "" then
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "\n" .. L["Way to"] .. "\n" .. dungeon.name
    else
        title = "Unbekannter Titel"  -- Fallback
    end

    TomTom:AddWaypoint(uiMapID, x, y, {
      title = title,
      persistent = nil,
      minimap = true,
      world = true
    })

  else

    local function getCoordinatesForBlizzard(coord)
      local x, y = HandyNotes:getXY(coord)
      return x, y
    end

    local x, y = getCoordinatesForBlizzard(coord)
    local mapInfo = C_Map.GetMapInfo(uiMapID)
    if mapInfo then
        local point = UiMapPoint.CreateFromCoordinates(uiMapID, x, y)
        if point then
            C_Map.SetUserWaypoint(point)
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        end
    end
  end
end

local function CheckWaypointProximity()
  local wp = C_Map.GetUserWaypoint()
  if not wp then return end

  local playerMap = C_Map.GetBestMapForUnit("player")
  if not playerMap or playerMap ~= wp.uiMapID then return end

  local pos = C_Map.GetPlayerMapPosition(playerMap, "player")
  if not pos then return end

  local dx = pos.x - wp.position.x
  local dy = pos.y - wp.position.y
  local distance = math.sqrt(dx*dx + dy*dy)

  if distance < 0.005 then -- distance check
    C_Map.ClearUserWaypoint()
  end
end

-- check distance time in seconds
C_Timer.NewTicker(2, CheckWaypointProximity)

-- Blizzard Waypoint WorldMap-Pin Integration
local BlizzardWaypointProviderMixin = {}
function BlizzardWaypointProviderMixin:OnAdded()
  self:RefreshAllData()
end

function BlizzardWaypointProviderMixin:RefreshAllData()
  local map = self:GetMap()
  if not map then return end

  map:RemoveAllPinsByTemplate("BlizzardWaypointPinTemplate")

  local wp = C_Map.GetUserWaypoint()
  if wp and wp.uiMapID == map:GetMapID() then
    map:AcquirePin("BlizzardWaypointPinTemplate", wp.uiMapID, wp.position.x, wp.position.y)
  end
end

WorldMapFrame:AddDataProvider(Mixin(CreateFromMixins(MapCanvasDataProviderMixin), BlizzardWaypointProviderMixin))

function ns.pluginHandler:OnClick(button, pressed, uiMapId, coord, value)
local delveID = nodes[uiMapId][coord].delveID
local leaveDelve = nodes[uiMapId][coord].leaveDelve
local mnID = nodes[uiMapId][coord].mnID
local mnID2 = nodes[uiMapId][coord].mnID2
local mnID3 = nodes[uiMapId][coord].mnID3
local wwwLink = nodes[uiMapId][coord].wwwLink
ns.achievementID = nodes[uiMapId][coord].achievementID
ns.questID = nodes[uiMapId][coord].questID
ns.hideLink = nodes[uiMapId][coord].hideLink

local mapInfo = C_Map.GetMapInfo(uiMapId)
local GetCurrentMapID = WorldMapFrame:GetMapID()
local CapitalIDs = GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85
                or GetCurrentMapID == 90 or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111
                or GetCurrentMapID == 125 or GetCurrentMapID == 126 or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393
                or GetCurrentMapID == 394 or GetCurrentMapID == 407 or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622
                or GetCurrentMapID == 624 or GetCurrentMapID == 626 or GetCurrentMapID == 627 or GetCurrentMapID == 628 or GetCurrentMapID == 629
                or GetCurrentMapID == 831 or GetCurrentMapID == 832 or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 
                or GetCurrentMapID == 1165 or GetCurrentMapID == 1670 or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 
                or GetCurrentMapID == 2112 or GetCurrentMapID == 2339 or GetCurrentMapID == 503 or GetCurrentMapID == 2266

  StaticPopupDialogs["Delete_Icon?"] = {
    text = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. ": " .. L["Delete this icon"] .. " ? " .. TextIconMNL4:GetIconString(),
    button1 = YES,
    button2 = NO,
    showAlert = true,
    exclusive  = true,
    OnAccept = function()
      if CapitalIDs then
        ns.dbChar.CapitalsDeletedIcons[uiMapId][coord] = true
        ns.dbChar.MinimapCapitalsDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Capitals"] .. " & " .. L["Capitals"] .. " - " .. MINIMAP_LABEL .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
    
      if mapInfo.mapType == 1 then -- Azeroth
        ns.dbChar.AzerothDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", AZEROTH .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
    
      if mapInfo.mapType == 2 then -- Continent
        ns.dbChar.ContinentDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Continents"] .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
    
      if not CapitalIDs and mapInfo.mapType == 3 then -- Zone
        ns.dbChar.ZoneDeletedIcons[uiMapId][coord] = true
        ns.dbChar.MinimapZoneDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Zones"] .. " & " .. MINIMAP_LABEL .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
    
      if not CapitalIDs and (mapInfo.mapType == 4 or mapInfo.mapType == 6) then -- Dungeon
        ns.dbChar.DungeonDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", DUNGEONS .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
      HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
    end,
    OnCancel = function()
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffff00 ".. CALENDAR_DELETE_EVENT .. " " .. "|cffff0000" .. L["canceled"])
    end,
    timeout = 5,
    whileDead = true,
    hideOnEscape = true,
  }

  if (not pressed) then return end

  if ns.Addon.db.profile.activate.SwapButtons then -- New SwapButtons
    if ns.Addon.db.profile.WayPointsShift then -- Shift
      if (button == "LeftButton" and db.WayPoints and IsShiftKeyDown()) then
        if GetCurrentMapID and GetCurrentMapID ~= 946 then
          if TomTom then
                setWaypoint(uiMapId, coord)
                return
          elseif C_Map.GetMapInfo(uiMapId) then
            local x, y = HandyNotes:getXY(coord)
            local mapInfo = C_Map.GetMapInfo(uiMapId)
              if mapInfo then
                  local point = UiMapPoint.CreateFromCoordinates(uiMapId, x, y)
                  if point then
                      C_Map.SetUserWaypoint(point)
                      C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                  end
              end
            return
          end
        end
      end
    else
      if (button == "LeftButton" and db.WayPoints) then
        if GetCurrentMapID and GetCurrentMapID ~= 946 then
          if TomTom then
                setWaypoint(uiMapId, coord)
                return
          elseif C_Map.GetMapInfo(uiMapId) then
            local x, y = HandyNotes:getXY(coord)
            local mapInfo = C_Map.GetMapInfo(uiMapId)
              if mapInfo then
                  local point = UiMapPoint.CreateFromCoordinates(uiMapId, x, y)
                  if point then
                      C_Map.SetUserWaypoint(point)
                      C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                  end
              end
            return
          end
        end
      end
    end

    if (button == "RightButton" and mnID and mnID2 or mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then -- original left
      WorldMapFrame:SetMapID(mnID)
    end
  end

  if not ns.Addon.db.profile.activate.SwapButtons then -- Original
    if ns.Addon.db.profile.WayPointsShift then -- Shift
      if (button == "RightButton" and db.WayPoints and IsShiftKeyDown()) then
        if GetCurrentMapID and GetCurrentMapID ~= 946 then
          if TomTom then
                setWaypoint(uiMapId, coord)
                return
          elseif C_Map.GetMapInfo(uiMapId) then
            local x, y = HandyNotes:getXY(coord)
            local mapInfo = C_Map.GetMapInfo(uiMapId)
              if mapInfo then
                  local point = UiMapPoint.CreateFromCoordinates(uiMapId, x, y)
                  if point then
                      C_Map.SetUserWaypoint(point)
                      C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                  end
              end
            return
          end
        end
      end
    else
      if (button == "RightButton" and db.WayPoints) then
        if GetCurrentMapID and GetCurrentMapID ~= 946 then
          if TomTom then
                setWaypoint(uiMapId, coord)
                return
          elseif C_Map.GetMapInfo(uiMapId) then
            local x, y = HandyNotes:getXY(coord)
            local mapInfo = C_Map.GetMapInfo(uiMapId)
              if mapInfo then
                  local point = UiMapPoint.CreateFromCoordinates(uiMapId, x, y)
                  if point then
                      C_Map.SetUserWaypoint(point)
                      C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                  end
              end
            return
          end
        end
      end
    end

    if (button == "LeftButton" and mnID and mnID2 or mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then -- original left
      WorldMapFrame:SetMapID(mnID)
    end
  end

  if (button == "MiddleButton" and mnID2 and not IsShiftKeyDown() and not IsAltKeyDown()) then
    WorldMapFrame:SetMapID(mnID2)
  end

  -- npc targeting & rangecheck
  if ns.TryCreateTarget(uiMapId, coord, button) then
    return
  end

  if (button == "RightButton") and IsAltKeyDown() then
    if ns.Addon.db.profile.DeleteIcons then
      StaticPopup_Show("Delete_Icon?")
    end
  end

  if (button == "MiddleButton" and mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then
      WorldMapFrame:SetMapID(mnID3)
  end


  if (not pressed) then return end

  if (button == "MiddleButton") and leaveDelve and ns.icons["Delves"] then
    StaticPopup_Show("Leave_Delve?")
  end

  if (button == "MiddleButton") and not IsShiftKeyDown() then
    if wwwLink and not (ns.achievementID or ns.questID) then
      print(wwwLink)
    elseif ns.questID and not ns.hideLink then
      print("|cffff0000Map|r|cff00ccffNotes|r", "|cffffff00" .. LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK .. ":" .. "|r", "https://www.wowhead.com/quest=" .. ns.questID)
    elseif ns.achievementID then
      print("|cffff0000Map|r|cff00ccffNotes|r", "|cffffff00" .. LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK .. ":" .. "|r", "https://www.wowhead.com/achievement=" .. ns.achievementID)
    end
  end

  if ns.Addon.db.profile.activate.SwapButtons then -- New SwapButtons
    if (button == "RightButton" and not IsAltKeyDown()) then

      if mnID then
        WorldMapFrame:SetMapID(mnID)
        return
      end

      if delveID then
        WorldMapFrame:SetMapID(delveID)
        return
      end
    end

    if (button == "RightButton" and db.journal and not IsAltKeyDown()) then

      if nodes[uiMapId][coord].mnID and nodes[uiMapId][coord].id then
        mnID = nodes[uiMapId][coord].mnID[1] --change id function to mnID function
      else
        mnID = nodes[uiMapId][coord].mnID --single coords function
      end

      if nodes[uiMapId][coord].delveIDs then
        mnID = nodes[uiMapId][coord].delveIDs[1] --change id function to mnID function
      else
        mnID = nodes[uiMapId][coord].delveIDs --single coords function
      end

      local dungeonID
      if (type(nodes[uiMapId][coord].id) == "table") then
        dungeonID = nodes[uiMapId][coord].id[1] --multi coords journal function
      else
        dungeonID = nodes[uiMapId][coord].id --single coords function
      end

      if (not dungeonID) then return end

      local name, _, _, _, _, _, _, link = EJ_GetInstanceInfo(dungeonID)
      if not link then return end

      local difficulty = string.match(link, "journal:.-:.-:(.-)|h") 
      if (not dungeonID or not difficulty) then return end

      if (not EncounterJournal_OpenJournal) then
        UIParentLoadAddOn("Blizzard_EncounterJournal")
      end

      if WorldMapFrame:IsMaximized() then
        WorldMapFrame:Minimize()
      end

      EncounterJournal_OpenJournal(difficulty, dungeonID)
      _G.EncounterJournal:SetScript("OnShow", nil)
    end
  end

  if not ns.Addon.db.profile.activate.SwapButtons then -- Original
    if (button == "LeftButton" and not IsAltKeyDown()) then
      if mnID then
        WorldMapFrame:SetMapID(mnID)
        return
      end

      if delveID then
        WorldMapFrame:SetMapID(delveID)
        return
      end
    end

    if (button == "LeftButton" and db.journal and not IsAltKeyDown()) then
      if nodes[uiMapId][coord].mnID and nodes[uiMapId][coord].id then
        mnID = nodes[uiMapId][coord].mnID[1] --change id function to mnID function
      else
        mnID = nodes[uiMapId][coord].mnID --single coords function
      end

      if nodes[uiMapId][coord].delveIDs then
        mnID = nodes[uiMapId][coord].delveIDs[1] --change id function to mnID function
      else
        mnID = nodes[uiMapId][coord].delveIDs --single coords function
      end

      local dungeonID
      if (type(nodes[uiMapId][coord].id) == "table") then
        dungeonID = nodes[uiMapId][coord].id[1] --multi coords journal function
      else
        dungeonID = nodes[uiMapId][coord].id --single coords function
      end

      if (not dungeonID) then return end

      local name, _, _, _, _, _, _, link = EJ_GetInstanceInfo(dungeonID)
      if not link then return end

      local difficulty = string.match(link, "journal:.-:.-:(.-)|h") 
      if (not dungeonID or not difficulty) then return end

      if (not EncounterJournal_OpenJournal) then
        UIParentLoadAddOn("Blizzard_EncounterJournal")
      end

      if WorldMapFrame:IsMaximized() then
        WorldMapFrame:Minimize()
      end

      EncounterJournal_OpenJournal(difficulty, dungeonID)
      _G.EncounterJournal:SetScript("OnShow", nil)
    end
  end

end


local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...)end)

local function updateStuff()
  updateextraInformation()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function Addon:ZONE_CHANGED_NEW_AREA()
  local mapID = C_Map.GetBestMapForUnit("player")
  if mapID then
    if ns.Addon.db.profile.ZoneChanged then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. C_Map.GetMapInfo(mapID).name .. "  <==")
    end
  end
end

local subzone = GetSubZoneText()
function Addon:ZONE_CHANGED_INDOORS()
    if ns.Addon.db.profile.ZoneChanged and ns.Addon.db.profile.ZoneChangedDetail and not ns.CapitalMiniMapIDs then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. "|cff00ff00" .. GetZoneText() .. " " .. "|cff00ccff" .. GetSubZoneText().. "|cff00ff00" .. "  <==")
    end
end

function Addon:ZONE_CHANGED()
  local mapID = C_Map.GetBestMapForUnit("player")
  if mapID then
    if ns.Addon.db.profile.ZoneChanged and ns.Addon.db.profile.ZoneChangedDetail and not ns.CapitalMiniMapIDs then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. GetZoneText() .. " " .. "|cff00ccff" .. GetSubZoneText() .. "|cff00ff00" .. "  <==")
    end
  end
end

function Addon:OnProfileChanged(event, database, profileKeys)
  db = database.profile
  ns.dbChar = database.profile.deletedIcons
  ns.FogOfWar = database.profile.FogOfWarColor

  ns.ApplySavedCoords()
  ns.ReloadAreaMapSettings()
  ns.UpdateMinimapArrow()

  if ns.SetAreaMapMenuVisibility then
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end
  
  HandyNotes:GetModule("FogOfWarButton"):Refresh()
  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been changed"])
  end
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function Addon:OnProfileReset(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  ns.FogOfWar = database.profile.FogOfWarColor

  ns.DefaultPlayerCoords()
  ns.DefaultMouseCoords()
  ns.DefaultPlayerAlpha()
  ns.DefaultMouseAlpha()
  ns.UpdateAreaMapFogOfWar()
  ns.ResetAreaMapToPlayerLocation()
  ns.UpdateMinimapArrow()

  if ns.SetAreaMapMenuVisibility then
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end

  wipe(ns.dbChar.CapitalsDeletedIcons)
  wipe(ns.dbChar.MinimapCapitalsDeletedIcons)
  wipe(ns.dbChar.CapitalsDeletedIcons)
  wipe(ns.dbChar.MinimapCapitalsDeletedIcons)
  wipe(ns.dbChar.AzerothDeletedIcons)
  wipe(ns.dbChar.ContinentDeletedIcons)
  wipe(ns.dbChar.ZoneDeletedIcons)
  wipe(ns.dbChar.MinimapZoneDeletedIcons)
  wipe(ns.dbChar.DungeonDeletedIcons)

  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been reset to default"])
  end
  HandyNotes:GetModule("FogOfWarButton"):Refresh()
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function Addon:OnProfileCopied(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  ns.FogOfWar = database.profile.FogOfWarColor

  ns.ApplySavedCoords()
  ns.ReloadAreaMapSettings()
  ns.UpdateMinimapArrow()

  if ns.SetAreaMapMenuVisibility then
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end

  HandyNotes:GetModule("FogOfWarButton"):Refresh()
  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been adopted"])
  end
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function Addon:OnProfileDeleted(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  ns.FogOfWar = database.profile.FogOfWarColor

  HandyNotes:GetModule("FogOfWarButton"):Refresh()
  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been deleted"])
  end
  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
end

function Addon:PLAYER_ENTERING_WORLD()
  if (not self.faction) then
      self.faction = UnitFactionGroup("player")
      self:PopulateTable()
      self:PopulateMinimap()
      self:ProcessTable()
  end
    updateextraInformation()
    updateStuff()
end

function Addon:PLAYER_LOGIN() -- OnInitialize()
  ns.Addon = Addon
  ns.LoadOptions(self)
  ns.BlizzardDelvesAddTT()
  ns.BlizzardDelvesAddFunction()

  -- Register Database Profile
  self.db = LibStub("AceDB-3.0"):New("HandyNotes_MapNotesRetailDB", ns.defaults)
  self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileCopied")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
  self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileDeleted")

  -- default profile database
  db = self.db.profile
  -- deleted icons database
  ns.dbChar = self.db.profile.deletedIcons
  -- FogOfWar color database
  ns.FogOfWar = self.db.profile.FogOfWarColor

  -- Register options 
  HandyNotes:RegisterPluginDB("MapNotes", ns.pluginHandler, ns.options)
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MapNotes", ns.options)

  -- Get the option table for profiles
  ns.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  -- Check for any lockout changes when we zone
  Addon:RegisterEvent("PLAYER_ENTERING_WORLD")

  -- Check if we changed the Zone
  Addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  Addon:RegisterEvent("ZONE_CHANGED")
  Addon:RegisterEvent("ZONE_CHANGED_INDOORS")

  -- Check for PlayerArrow on Minimap
  ns.MiniMapPlayerArrow()

  -- Check for Links
  ns.CreateAndCopyLink()

  -- Check for Class
  ns.AutomaticClassDetectionCapital()

  -- Check for Professions
  ns.AutomaticProfessionDetection()

  -- Check if Blizz Instance entrances is true then remove Blizzard Pins
  if ns.Addon.db.profile.activate.RemoveBlizzInstances then
    SetCVar("showDungeonEntrancesOnMap", 0)
  elseif not ns.Addon.db.profile.activate.RemoveBlizzInstances then
    SetCVar("showDungeonEntrancesOnMap", 1)
  end

  -- Check if Blizz Delves entrances is true then remove Blizzard Pins
  if ns.Addon.db.profile.activate.ShowBlizzDelves then
    SetCVar("showDelveEntrancesOnMap", 0)
  elseif not ns.Addon.db.profile.activate.ShowBlizzDelves then
    SetCVar("showDelveEntrancesOnMap", 1)
  end

  if ns.Addon.db.profile.activate.HideMMB then -- minimap button
    MNMMBIcon:Hide("MNMiniMapButton")
  end

  -- Register Worldmapbutton
  ns.WorldMapButton = LibStub("Krowi_WorldMapButtons-1.4"):Add(ADDON_NAME .. "WorldMapOptionsButtonTemplate","BUTTON")
  if ns.Addon.db.profile.activate.HideWMB
    then ns.WorldMapButton:Hide()
    else ns.WorldMapButton:Show()
  end

  function ns.RemoveBlizzPOIs()
      if ns.Addon.db.profile.activate.HideMapNote then return end

      if ns.Addon.db.profile.activate.RemoveBlizzPOIs and not ns.BlizzAreaPoisLookup then
          ns.BlizzAreaPoisLookup = {}
          for _, poiID in pairs(ns.BlizzAreaPoisInfo) do
              ns.BlizzAreaPoisLookup[poiID] = true
          end
      end

      if ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi and not ns.BlizzAreaPoisLookupZidormi then
          ns.BlizzAreaPoisLookupZidormi = {}
          for _, poiID in pairs(ns.BlizzAreaPoisInfoZidormi) do
              ns.BlizzAreaPoisLookupZidormi[poiID] = true
          end
      end

      for pinTemplate, pinPool in pairs(WorldMapFrame.pinPools) do
          for pin in pinPool:EnumerateActive() do
              local areaPoiID = pin.areaPoiID or (pin.poiInfo and pin.poiInfo.areaPoiID)

              if ns.Addon.db.profile.activate.RemoveBlizzPOIs and areaPoiID and ns.BlizzAreaPoisLookup[areaPoiID] then
                  pin:Hide()
              end

              if ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi and areaPoiID and ns.BlizzAreaPoisLookupZidormi[areaPoiID] then
                  pin:Hide()
              end

              if ns.Addon.db.profile.activate.RemoveBlizzPOIsZidormi and pin.objectGUID then
                  for _, id in ipairs(ns.BlizzAreaPoisInfoZidormi) do
                      if string.find(pin.objectGUID, tostring(id)) then
                          pin:Hide()
                          break
                      end
                  end
              end
          end
      end

  end

  for dp in pairs(WorldMapFrame.dataProviders) do
      if (not dp.GetPinTemplates and type(dp.GetPinTemplate) == "function") then
          if (dp:GetPinTemplate() == "AreaPOIPinTemplate") then
              hooksecurefunc(dp, "RefreshAllData", ns.RemoveBlizzPOIs)
          end
      end
  end

  -- MapNotes DeveloperMode is active print line
  if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode then
    print(ns.COLORED_ADDON_NAME .. " DeveloperMode is |cff00ff00active|r")
  end

end

function Addon:PopulateMinimap()
  for uiMapId,uiMapIdDetails in pairs(nodes) do
      if (minimap[uiMapId]) then
          for coords,icondetails in pairs(uiMapIdDetails) do 
              if (icondetails.showOnMinimap) then
                  minimap[uiMapId][coords] = icondetails
              end
          end
      end
  end
end

function Addon:PopulateTable()
  ns.nodes = nodes
  ns.minimap = minimap

  table.wipe(nodes)
  table.wipe(minimap)

  ns.SyncWithMinimap(self) -- sync Capitals with Capitals - Minimap and/or Zones with Minimap

  ns.LoadMapNotesNodesInfo() -- load nodes\Retail\RetailMapNotesNodesInfo.lua
  ns.LoadMapNotesMinimapInfo() -- load nodes\Retail\RetailMapNotesMinimapNodesInfo.lua

  LoadAndCheck(ns.LoadMiniMapLocationinfo,self) -- load nodes\Retail\RetailMiniMapNodes.lua
  LoadAndCheck(ns.LoadMiniMapDungeonLocationinfo,self) -- load nodes\Retail\RetailMiniMapDungeonNodes.lua

  LoadAndCheck(ns.LoadAzerothNodesLocationInfo,self) -- load nodes\Retail\RetailAzerothNodeslocation.lua
  LoadAndCheck(ns.LoadContinentNodesLocationinfo,self) -- load nodes\Retail\RetailContinentNodesLocation.lua

  LoadAndCheck(ns.LoadZoneMapNodesLocationinfo, self) -- load nodes\Retail\RetailZoneNodesLocation.lua
  LoadAndCheck(ns.LoadZoneDungeonMapNodesLocationinfo, self) -- load OnlyZoneDungeonNodesLocation.lua

  LoadAndCheck(ns.LoadGeneralZoneLocationinfo,self) -- load nodes\Retail\RetailGeneralZoneNodes.lua
  LoadAndCheck(ns.LoadGeneralMiniMapLocationinfo,self) -- load nodes\Retail\RetailGeneralMiniMapNodes.lua

  LoadAndCheck(ns.LoadPathsZoneLocationinfo,self) -- load nodes\Retail\RetailPathsZoneNodes.lua
  LoadAndCheck(ns.LoadPathsMiniMapLocationinfo,self) -- load nodes\Retail\RetailPathsMiniMapNodes.lua

  LoadAndCheck(ns.LoadInsideDungeonNodesLocationInfo,self) -- load nodes\Retail\RetailInsideDungeonNodesLocation.lua

  LoadAndCheck(ns.LoadWorldNodesLocationInfo, self) -- load nodes\Retail\RetailWorldNodesLocation.lua
  --ns.LoadWorldNodesLocationInfo(self) -- load nodes\Retail\RetailWorldNodesLocation.lua

  LoadAndCheck(ns.LoadCapitalsLocationinfo,self) -- load nodes\Retail\RetailCapitals.lua
  LoadAndCheck(ns.LoadMinimapCapitalsLocationinfo,self) -- load nodes\Retail\RetailMinimapCapitals.lua

  LoadAndCheck(ns.LoadSpecialLocations,self)

end

function Addon:UpdateInstanceNames(node)
  local dungeonInfo = EJ_GetInstanceInfo
  local id = node.id

  if node.lfgid then
    dungeonInfo = GetLFGDungeonInfo
    id = node.lfgid
  end

  if type(id) == "table" then
    local nameList = {}
    for _, v in ipairs(id) do
      local name = dungeonInfo(v)
      if not name or name == "" then name = "..." end
      self:UpdateAlter(v, name)
      table.insert(nameList, name)
    end

    if node.name then
      node.name = node.name .. "\n" .. table.concat(nameList, "\n")
    else
      node.name = table.concat(nameList, "\n")
    end

    if ns.Addon.db.profile.TooltipInformations then
      local tooltipInfo = ""

      local currentMapID = GetCurrentMapID
      if currentMapID and currentMapID ~= 946 then
        if ns.Addon.db.profile.WayPointsShift then -- Shift
          if ns.Addon.db.profile.activate.SwapButtons then -- SwapButtons
            if not ns.Addon.db.profile.DeleteIcons and not ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"]
            elseif ns.Addon.db.profile.DeleteIcons and ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"] .. " \n" .. TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.DeleteIcons then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Shift + Left Click sets a waypoint on a MapNotes icon >"] .. " \n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"]
            end
          else -- Original Buttons
            if not ns.Addon.db.profile.DeleteIcons and not ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"]
            elseif ns.Addon.db.profile.DeleteIcons and ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.DeleteIcons then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Shift + Right Click sets a waypoint on a MapNotes icon >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"]
            end
          end
        else
          if ns.Addon.db.profile.activate.SwapButtons then -- SwapButtons
            if not ns.Addon.db.profile.DeleteIcons and not ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"]
            elseif ns.Addon.db.profile.DeleteIcons and ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"] .. " \n" .. TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.DeleteIcons then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click sets a waypoint on a MapNotes icon >"] .. " \n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click to show map >"]
            end
          else -- Original Buttons
            if not ns.Addon.db.profile.DeleteIcons and not ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"]
            elseif ns.Addon.db.profile.DeleteIcons and ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.DeleteIcons then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cffff0000" .. L["< Alt + Right click to delete this icon >"]
            elseif ns.Addon.db.profile.WayPoints then
              tooltipInfo = TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Right Click sets a waypoint on a MapNotes icon >"] .. "\n" .. TextIconInfo:GetIconString() .. " |cff00ff00" .. L["< Left Click to show map >"]
            end
          end
        end
      end

      node.name = node.name .. "\n" .. tooltipInfo
    end

  elseif id then
    node.name = dungeonInfo(id)
    self:UpdateAlter(id, node.name)
  end
end


function Addon:ProcessTable()
  lfgIDs = ns.lfgIDs

  function Addon:UpdateAlter(id, name)
    if (lfgIDs[id]) then
      local lfgIDs1, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgIDs2 = GetLFGDungeonInfo(lfgIDs[id])
        if (lfgIDs2 and lfgIDs1 == name) then
      	  lfgIDs1 = lfgIDs2
        end

      if (lfgIDs1) then
        if (lfgIDs1 == name) then
        else
        lfgIDs[id] = nil
        lfgIDs[name] = lfgIDs1
        end
      end
    end
  end

  for i,v in pairs(nodes) do
    for j,u in pairs(v) do
      self:UpdateInstanceNames(u)
    end
  end

  for i,v in pairs(minimap) do
    for j,u in pairs(v) do
      if (not u.name) then
	      self:UpdateInstanceNames(u)
      end
    end
  end
end

function Addon:FullUpdate()
  self:PopulateTable()
  self:PopulateMinimap()
  self:ProcessTable()
end

C_Timer.After(0, function()
  ns.AreaMapFrame = BattlefieldMapFrame
end)