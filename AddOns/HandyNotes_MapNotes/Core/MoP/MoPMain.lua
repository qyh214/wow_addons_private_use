local ADDON_NAME, ns = ...

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

ns.RestoreStaticPopUps()

function MapNotesMiniButton:OnInitialize() --mmb.lua
  self.db = LibStub("AceDB-3.0"):New("MNMiniMapButtonMoPDB", { profile = { minimap = { hide = false, }, }, }) 
  MNMMBIcon:Register("MNMiniMapButton", ns.miniButton, self.db.profile.minimap)
end

function ns.MiniMapPlayerArrow()
    if MMPA then return MMPA end

    local scale = ns.Addon.db.profile.MinimapArrowScale or 1
    local baseSize = 20
    local size = baseSize * scale

    MMPA = CreateFrame("Frame", "MMPA", Minimap)
    MMPA:SetSize(size, size)
    MMPA:SetFrameStrata("MEDIUM")
    MMPA:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    MMPA.texture = MMPA:CreateTexture(nil, "OVERLAY")
    MMPA.texture:SetTexture("Interface\\Minimap\\MinimapArrow")
    MMPA.texture:SetSize(size, size)
    MMPA.texture:SetPoint("CENTER", MMPA, "CENTER", 0, 0)
    MMPA.texture:SetTexelSnappingBias(0)
    MMPA.texture:SetSnapToPixelGrid(false)
    MMPA.elapsed = 0
    MMPA.facing = nil

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

      local facing = GetPlayerFacing()
      if not facing then
        self.texture:Hide()
        return
      end

      self.texture:Show()
      if facing and facing ~= self.facing and facing > 0 then
        self.facing = facing
        self.texture:SetRotation(facing)
      end
    end)

    if ns.Addon.db.profile.activate.MinimapArrow then
      MMPA:Show()
    else
      MMPA:Hide()
    end

    C_Timer.After(1, function()
      local facing = GetPlayerFacing()
      if facing and MMPA and MMPA.texture then
        MMPA.facing = facing
        MMPA.texture:SetRotation(facing)
      end
    end)

  return MMPA
end

function ns.UpdateMinimapArrow()
    local scale = ns.Addon.db.profile.MinimapArrowScale or 1
    local baseSize = 20
    local size = baseSize * scale

    if MMPA and MMPA.texture then
        MMPA:SetSize(size, size)
        MMPA.texture:SetSize(size, size)

        if ns.Addon.db.profile.activate.MinimapArrow then
            MMPA:Show()
        else
            MMPA:Hide()
        end
    end
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

local instanceInfoInitFrame = CreateFrame("Frame")
  instanceInfoInitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  instanceInfoInitFrame:SetScript("OnEvent", function()
  updateextraInformation()
end)

local function ExtraToolTip()
  local show = ns.Addon.db.profile.TooltipInformations and WorldMapFrame:IsShown()
  ns.Addon.db.profile.ExtraTooltip = show or false
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

  C_Timer.After(0.3, function()
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
  end)
end

local pluginHandler = { }
ns.pluginHandler = pluginHandler
function ns.pluginHandler:OnEnter(uiMapId, coord)
  ns.nodes[uiMapId][coord] = nodes[uiMapId][coord]
  ns.minimap[uiMapId][coord] = minimap[uiMapId][coord]

  local nodeData = nil
  local GetCurrentMapID = WorldMapFrame:GetMapID()

  -- Highlight 
  if not self.highlight then
    self.highlight = self:CreateTexture(nil, "OVERLAY")
    self.highlight:SetBlendMode("ADD")
    self.highlight:SetAlpha(1)
    self.highlight:SetAllPoints()
  end
  self.highlight:SetTexture(self.texture:GetTexture())
  self.highlight:Show()

  if self.highlight and self.highlight.SetDrawLayer then
    self.highlight:SetDrawLayer("OVERLAY", 6)
  end

  if self.texture and self.texture.SetDrawLayer then
    self.texture:SetDrawLayer("OVERLAY", 5)
  end

  if (minimap[uiMapId] and minimap[uiMapId][coord]) then
    nodeData = minimap[uiMapId][coord]
   end

	if (nodes[uiMapId] and nodes[uiMapId][coord]) then
	  nodeData = nodes[uiMapId][coord]
	end
	
	if (not nodeData) then return end
	
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

  if ns.Addon.db.profile.BossNames then
    if nodeData.id and type(nodeData.id) == "table" then
      tooltip:AddLine(L["Multiple instances"])
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
      if ns.DeveloperMode == true then
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

    if nodeData.TransportName then -- outputs transport name for TomTom to the tooltip
      tooltip:AddDoubleLine(nodeData.TransportName, nil, nil, false)
    end

    if nodeData.dnID then -- outputs the names we set and displays it in the tooltip
      tooltip:AddDoubleLine(nodeData.dnID, nil, nil, false)
    end

    if (nodeData.dnID and nodeData.mnID) and not nodeData.mnID2 and not nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(" => " .. mnIDname, nil, nil, false)
      end
    end

    if nodeData.mnID and nodeData.mnID2 or nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine("\n" .. KEY_BUTTON1 .. " => " .. mnIDname, nil, nil, false)
      end
    end

    if nodeData.mnID2 then
      local mnID2name = C_Map.GetMapInfo(nodeData.mnID2).name
      if mnID2name then 
        tooltip:AddDoubleLine(KEY_BUTTON2 .. " => " .. mnID2name, nil, nil, false)
      end
    end

    if nodeData.mnID3 then
      local mnID3name = C_Map.GetMapInfo(nodeData.mnID3).name
      if mnID3name then 
        tooltip:AddDoubleLine(KEY_BUTTON3 .. " => " .. mnID3name, nil, nil, false)
      end
    end

    if not nodeData.dnID and nodeData.mnID and not nodeData.id and not nodeData.TransportName and not nodeData.wwwName then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(" => " .. mnIDname, nil, nil, false)
      end
    end

    if nodeData.wwwName then
      tooltip:AddDoubleLine(nodeData.wwwName, nil, nil, false)
    end

    if nodeData.www and nodeData.showWWW == true then
      tooltip:AddDoubleLine(nodeData.www, nil, nil, false)
    end

    local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
    if nodeData.questID then

      if IsQuestFlaggedCompleted(nodeData.questID) == false then
      
        if nodeData.wwwLink and nodeData.showWWW == true then
          tooltip:AddDoubleLine("|cffffffff" .. nodeData.wwwLink, nil, nil, false)
          tooltip:AddLine("\n" .. L["Has not been unlocked yet"] .. "\n" .. "\n", 1, 0, 0)
          if ns.Addon.db.profile.ExtraTooltip then
            tooltip:AddDoubleLine("|cff00ff00".. "< " .. L["Activate the „Link“ function from MapNotes in the General tab to create clickable links and email addresses in the chat"] .. " >" .. "\n" .. "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
          end
        end
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
          if ns.Addon.db.profile.ExtraTooltip then
            tooltip:AddDoubleLine("\n" .. "|cff00ff00".. "< " .. L["Activate the 'Link' function in the MapNotes menu to generate a clickable web link"] .. " >" .. "\n" .. "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
          end
        end
        
      end
      

      -- if wasEarnedByMe == true and completed == true then
      if completed == true then
        nodeData.showWWW = false
        nodeData.wwwName = false
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

     	tooltip:Show()
  end
end

SLASH_DeveloperMode1 = "/mndev";
function SlashCmdList.DeveloperMode(msg, editbox)
  if ns.DeveloperMode == true then
    ns.DeveloperMode = false
    print("MapNotes DeveloperMode = Off")
  else
    ns.DeveloperMode = true 
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
	local tablepool = setmetatable({}, {__mode = 'uiMapId'})

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

	local function iter(t, prestate) -- Azeroth / Zone / Minimap / Inside Dungeon settings

		if not t then return end

		local data = t.data
		local state, value = next(data, prestate)
    local GetCurrentMapID = WorldMapFrame:GetMapID()
    local GetBestMapForUnit = C_Map.GetBestMapForUnit("player")

		while value do
			local alpha
      local scale
			local icon = ns.icons[value.type]
      local mapInfo = C_Map.GetMapInfo(t.uiMapId)

			local allLocked = true
			local anyLocked = false

      ns.SyncWithMinimapScaleAlpha() -- sync Capitals with Capitals - Minimap and/or Zones with Minimap Alpha/Scale
      ns.ChangeToClassicImages() -- function to change the icon style from new images to old images

      ns.paths = value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR"

      ns.professions = value.type == "Alchemy" or value.type == "Engineer" or value.type == "Cooking" or value.type == "Fishing" or value.type == "Archaeology" or value.type == "Mining" or value.type == "Jewelcrafting" or value.type == "Blacksmith" or value.type == "Leatherworking" or value.type == "Skinning" or value.type == "Tailoring" or value.type == "Herbalism" or value.type == "Inscription" or value.type == "Enchanting" or value.type == "FishingClassic" or value.type == "ProfessionOrders" or value.type == "FirstAid"

      ns.instances = value.type == "Dungeon" or value.type == "Raid" or value.type == "PassageDungeon" or value.type == "PassageDungeonRaidMulti" or value.type == "PassageRaid" or value.type == "VInstance" or value.type == "PassageDungeon" or value.type == "Multiple" or value.type == "LFR" or value.type == "Gray"

      ns.transports = value.type == "Portal" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" or value.type == "PassageAPortal" or value.type == "PassagePortal" or value.type == "Zeppelin" or value.type == "HZeppelin" or value.type == "AZeppelin" or value.type == "Ship" or value.type == "AShip" or value.type == "HShip" or value.type == "Carriage" or value.type == "TravelL" or value.type == "TravelH" or value.type == "TravelA" or value.type == "Tport2" or value.type == "OgreWaygate" or value.type == "WayGateGreen" or value.type == "Ghost" or value.type == "DarkMoon"

      ns.capitalgenerals = value.type == "Exit" or value.type == "PassageUpL" or value.type == "PassageDownL" or value.type == "PassageRightL" or value.type == "PassageLeftL" or value.type == "Innkeeper" or value.type == "Auctioneer" or value.type == "Bank" or value.type == "MNL" or value.type == "Barber" or value.type == "Transmogger" or value.type == "ItemUpgrade" or value.type == "PvPVendor" or value.type == "PvEVendor" or value.type == "MNL" or value.type == "DragonFlyTransmog" or value.type == "Catalyst" or value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR" or value.type == "BlackMarket" or value.type == "Mailbox"

      ns.CapitalIDs = GetCurrentMapID == 84 or GetCurrentMapID == 87 or GetCurrentMapID == 89 or GetCurrentMapID == 103 or GetCurrentMapID == 85 or GetCurrentMapID == 90 
                      or GetCurrentMapID == 86 or GetCurrentMapID == 88 or GetCurrentMapID == 110 or GetCurrentMapID == 111 or GetCurrentMapID == 125 or GetCurrentMapID == 126 
                      or GetCurrentMapID == 391 or GetCurrentMapID == 392 or GetCurrentMapID == 393 or GetCurrentMapID == 394 or GetCurrentMapID == 407 or GetCurrentMapID == 503 
                      or GetCurrentMapID == 582 or GetCurrentMapID == 590 or GetCurrentMapID == 622 or GetCurrentMapID == 624 or GetCurrentMapID == 626 or GetCurrentMapID == 627 
                      or GetCurrentMapID == 628 or GetCurrentMapID == 629 or GetCurrentMapID == 1161 or GetCurrentMapID == 1163 or GetCurrentMapID == 1164 or GetCurrentMapID == 1165 
                      or GetCurrentMapID == 1670 or GetCurrentMapID == 1671 or GetCurrentMapID == 1672 or GetCurrentMapID == 1673 or GetCurrentMapID == 2112 or GetCurrentMapID == 2339
                      or GetCurrentMapID == 499 or GetCurrentMapID == 500 or GetCurrentMapID == 2266

      ns.CapitalMiniMapIDs = GetBestMapForUnit == 84 or GetBestMapForUnit == 87 or GetBestMapForUnit == 89 or GetBestMapForUnit == 103 or GetBestMapForUnit == 85 or GetBestMapForUnit == 90 
                      or GetBestMapForUnit == 86 or GetBestMapForUnit == 88 or GetBestMapForUnit == 110 or GetBestMapForUnit == 111 or GetBestMapForUnit == 125 or GetBestMapForUnit == 126 
                      or GetBestMapForUnit == 391 or GetBestMapForUnit == 392 or GetBestMapForUnit == 393 or GetBestMapForUnit == 394 or GetBestMapForUnit == 407 or GetBestMapForUnit == 503 
                      or GetBestMapForUnit == 582 or GetBestMapForUnit == 590 or GetBestMapForUnit == 622 or GetBestMapForUnit == 624 or GetBestMapForUnit == 626 or GetBestMapForUnit == 627 
                      or GetBestMapForUnit == 628 or GetBestMapForUnit == 629 or GetBestMapForUnit == 1161 or GetBestMapForUnit == 1163 or GetBestMapForUnit == 1164 or GetBestMapForUnit == 1165 
                      or GetBestMapForUnit == 1670 or GetBestMapForUnit == 1671 or GetBestMapForUnit == 1672 or GetBestMapForUnit == 1673 or GetBestMapForUnit == 2112 or GetBestMapForUnit == 2339
                      or GetBestMapForUnit == 499 or GetBestMapForUnit == 500 or GetBestMapForUnit == 2266

      ns.ContinentIDs = GetCurrentMapID == 12 -- Kalimdor
                      or GetCurrentMapID == 13 -- Eastern Kingdom
                      or GetCurrentMapID == 1467 -- Outland Classic+
                      or GetCurrentMapID == 101 -- Outland Retail
                      or GetCurrentMapID == 113 -- Nordend
                      or GetCurrentMapID == 948 -- The Maelstrom
                      or GetCurrentMapID == 424 -- Pandaria
                      or GetCurrentMapID == 619 -- Broken Isles
                      or GetCurrentMapID == 875 -- Zandalar
                      or GetCurrentMapID == 876 -- Kul'Tiras
                      or GetCurrentMapID == 905 -- Argus
                      or GetCurrentMapID == 572 -- Draenor
                      or GetCurrentMapID == 1550 -- Shadowlands
                      or GetCurrentMapID == 1978 -- Dragon Isles                      
                      or GetCurrentMapID == 2274 -- Khaz Algar


			if value.name == nil then value.name = value.id or value.mnID end
      
			local instances = { strsplit("\n", value.name) }
			for i, v in pairs(instances) do
				if (not extraInformations[v] and not extraInformations[lfgIDs[v]]) then
					allLocked = false
				else
					anyLocked = true
				end
			end

      if (anyLocked and db.graymultipleID) or ((allLocked and not db.graymultipleID) and db.assignedgray) then
        icon = ns.icons["Gray"]
      end

      if (value.type == "LFR") then
        icon = ns.icons["LFR"]
      end

      if (value.type == "HIcon") then
        icon = ns.icons["HIcon"]
      end

      if (value.type == "AIcon") then
        icon = ns.icons["AIcon"]
      end

      if (anyLocked and db.invertlockout) or ((allLocked and not db.invertlockout) and db.uselockoutalpha) then
				alpha = db.mapnoteAlpha
      else
				alpha = db.mapnoteAlpha
			end

      scale = db.zoneScale
      alpha = db.zoneAlpha
      if t.minimapUpdate then -- Minimap Zone
          scale = db.minimapScale
          alpha = db.minimapAlpha
      end

      -- Profession icons in Capitals
      if ns.professions and ns.CapitalIDs and (value.showOnMinimap == false) then
        scale = db.CapitalsProfessionsScale
        alpha = db.CapitalsProfessionsAlpha
      end

      -- Profession Minimap icons in Capitals
      if ns.CapitalMiniMapIDs and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsScale
        alpha = db.MinimapCapitalsAlpha
      end
      
      -- inside Dungeon
      mapInfo = C_Map.GetMapInfo(t.uiMapId)
      if mapInfo and mapInfo.mapType == 4 and not ns.CapitalIDs then 
          scale = db.dungeonScale
          alpha = db.dungeonAlpha
      end

      -- Instance icons World
      if ns.instances and (not value.showOnMinimap == true) then
        scale = db.instanceScale
        alpha = db.instanceAlpha
      end

      -- Profession Minimap icons in Capitals
      if ns.professions and ns.CapitalMiniMapIDs and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsProfessionsScale
        alpha = db.MinimapCapitalsProfessionsAlpha
      end

      -- Capitals Minimap Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalMiniMapIDs and ns.transports and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsTransportScale
        alpha = db.MinimapCapitalsTransportAlpha
      end

      -- Capitals Minimap Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalMiniMapIDs and ns.instances and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsInstanceScale
        alpha = db.MinimapCapitalsInstanceAlpha
      end

      -- Capitals Minimap General (Innkeeper/Exit/Passage) icons
      if ns.CapitalMiniMapIDs and ns.capitalgenerals and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsGeneralScale
        alpha = db.MinimapCapitalsGeneralAlpha
      end

      -- Capitals General (Innkeeper/Exit/Passage) icons
      if ns.CapitalMiniMapIDs and ns.capitalgenerals and (value.showOnMinimap == false) then
        scale = db.CapitalsGeneralScale
        alpha = db.CapitalsGeneralAlpha
      end

      -- Capitals Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalIDs and ns.transports and (value.showOnMinimap == false) then
        scale = db.CapitalsTransportScale
        alpha = db.CapitalsTransportAlpha
      end

      -- Capitals Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalIDs and ns.instances and (value.showOnMinimap == false) then
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
        or (not ns.CapitalIDs and mapInfo.mapType == 3 and ns.dbChar.MinimapZoneDeletedIcons[t.minimapId] and not ns.dbChar.MinimapZoneDeletedIcons[t.minimapId][state] and value.showOnMinimap) -- Minimap Zones
      then
        return state, nil, icon, scale, alpha
      end

      if (ns.ContinentIDs and mapInfo.mapType == 2 and value.showOnContinent) then
        return state, nil, icon, db.continentScale, db.continentAlpha
      end

			state, value = next(data, state)
		end
		wipe(t)
		tablepool[t] = true
	end

	local function iterCont(t, prestate) -- continent settings
		if not t then return end
    --if not db.activate.Continent then return end

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

          if (anyLocked and db.graymultipleID) or ((allLocked and not db.graymultipleID) and db.assignedgray) then   
						icon = ns.icons["Gray"]
					end

          if (value.type == "LFR") then
            icon = ns.icons["LFR"]
          end
    
          if (value.type == "HIcon") then
            icon = ns.icons["HIcon"]
          end
    
          if (value.type == "AIcon") then
            icon = ns.icons["AIcon"]
          end

          if (anyLocked and db.invertlockout) or ((allLocked and not db.invertlockout) and db.uselockoutalpha) then
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

  if IsAddOnLoaded("TomTom") and TomTom and type(TomTom.AddWaypoint) == "function" then
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
  end
end

function ns.pluginHandler:OnClick(button, pressed, uiMapId, coord, value)

local mnID = nodes[uiMapId][coord].mnID
local mnID2 = nodes[uiMapId][coord].mnID2
local mnID3 = nodes[uiMapId][coord].mnID3
local wwwLink = nodes[uiMapId][coord].wwwLink
ns.achievementID = nodes[uiMapId][coord].achievementID
ns.questID = nodes[uiMapId][coord].questID

local mapInfo = C_Map.GetMapInfo(uiMapId)
local GetCurrentMapID = WorldMapFrame:GetMapID()
local CapitalIDs = GetCurrentMapID == 1454 or GetCurrentMapID == 1456 or GetCurrentMapID == 1458 or GetCurrentMapID == 1954 
                   or GetCurrentMapID == 1947 or GetCurrentMapID == 1457 or GetCurrentMapID == 1453 or GetCurrentMapID == 1455
                   or GetCurrentMapID == 1955 or GetCurrentMapID == 86 or GetCurrentMapID == 125 or GetCurrentMapID == 126

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

  if (button == "RightButton" and ns.Addon.db.profile.WayPoints and IsShiftKeyDown()) then
      setWaypoint(uiMapId, coord)
      return
  end

  if (button == "LeftButton") and IsAltKeyDown() then
    StaticPopup_Show ("Delete_Icon?")
  end

  if (button == "LeftButton" and mnID and mnID2 or mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then
    WorldMapFrame:SetMapID(mnID)
  end

  if (button == "RightButton" and mnID2 and not IsShiftKeyDown() and not IsAltKeyDown()) then
    WorldMapFrame:SetMapID(mnID2)
  end

  if (button == "MiddleButton" and mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then
      WorldMapFrame:SetMapID(mnID3)
  end


  if (not pressed) then return end

  if (button == "MiddleButton") then
    if wwwLink and not (ns.achievementID or ns.questID) then
      print(wwwLink)
    elseif ns.questID then
      print("|cffff0000Map|r|cff00ccffNotes|r", "|cffffff00" .. LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK .. ":" .. "|r", "https://www.wowhead.com/quest=" .. ns.questID)
    elseif ns.achievementID then
      print("|cffff0000Map|r|cff00ccffNotes|r", "|cffffff00" .. LOOT_JOURNAL_LEGENDARIES_SOURCE_ACHIEVEMENT, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK .. ":" .. "|r", "https://www.wowhead.com/achievement=" .. ns.achievementID)
    end
  end

  if (button == "LeftButton" and db.journal and not IsAltKeyDown()) then

    if mnID then
      WorldMapFrame:SetMapID(mnID)
    if (not EncounterJournal_OpenJournal) then 
      UIParentLoadAddOn('Blizzard_EncounterJournal')
    end
      _G.EncounterJournal:SetScript("OnShow", nil)
      return
    end

    if nodes[uiMapId][coord].mnID and nodes[uiMapId][coord].id then
      mnID = nodes[uiMapId][coord].mnID[1] --change id function to mnID function
    else
      mnID = nodes[uiMapId][coord].mnID --single coords function
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
    local difficulty = string.match(link, 'journal:.-:.-:(.-)|h') 
    if (not dungeonID or not difficulty) then return end

    if (not EncounterJournal_OpenJournal) then 
      UIParentLoadAddOn('Blizzard_EncounterJournal')
    end
    if WorldMapFrame:IsMaximized() then 
      WorldMapFrame:Minimize() 
    end
    EncounterJournal_OpenJournal(difficulty, dungeonID)
    _G.EncounterJournal:SetScript("OnShow", nil)
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
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " ..
      TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been changed"])
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

function Addon:PLAYER_LOGIN()

  ns.LoadOptions(self)
  ns.Addon = Addon

  -- Register Database Profile
  self.db = LibStub("AceDB-3.0"):New("HandyNotes_MapNotesMistsDB", ns.defaults)
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

  -- Check for Professions
  ns.AutomaticProfessionDetection()

  if ns.Addon.db.profile.activate.HideMMB then -- minimap button
    MNMMBIcon:Hide("MNMiniMapButton")
  end

  -- Register Worldmapbutton
  ns.WorldMapButton = LibStub('Krowi_WorldMapButtons-1.4'):Add(ADDON_NAME .. "WorldMapOptionsButtonTemplate","BUTTON")
  if ns.Addon.db.profile.activate.HideWMB
    then ns.WorldMapButton:Hide()
    else ns.WorldMapButton:Show()
  end

  -- Remove Blizzard POIs for MapNotes icons function
  function ns.RemoveBlizzPOIs()
      if ns.Addon.db.profile.activate.HideMapNote then return end
  
      if ns.Addon.db.profile.activate.RemoveBlizzPOIs and not ns.BlizzAreaPoisLookup then
          ns.BlizzAreaPoisLookup = {}
          for _, poiID in pairs(ns.BlizzAreaPoisInfo) do
              ns.BlizzAreaPoisLookup[poiID] = true
          end
      end
    
      if ns.Addon.db.profile.activate.RemoveBlizzPOIsCities and not ns.BlizzAreaPoisLookupCities then
          ns.BlizzAreaPoisLookupCities = {}
          for _, poiID in pairs(ns.BlizzAreaPoisInfoCities) do
              ns.BlizzAreaPoisLookupCities[poiID] = true
          end
      end
    
      for pin in WorldMapFrame:EnumeratePinsByTemplate("AreaPOIPinTemplate") do
          local areaPoiID = pin.areaPoiID
      
          if ns.Addon.db.profile.activate.RemoveBlizzPOIs and ns.BlizzAreaPoisLookup[areaPoiID] then
              WorldMapFrame:RemovePin(pin)
          
          elseif ns.Addon.db.profile.activate.RemoveBlizzPOIsCities and ns.BlizzAreaPoisLookupCities[areaPoiID] then
              WorldMapFrame:RemovePin(pin)
          end
      end
  end
  
  for dp in pairs(WorldMapFrame.dataProviders) do
      if type(dp.GetPinTemplate) == "function" and dp:GetPinTemplate() == "AreaPOIPinTemplate" then
          hooksecurefunc(dp, "RefreshAllData", ns.RemoveBlizzPOIs)
      end
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

  ns.LoadMapNotesNodesInfo() -- load nodes\MapNotesNodesInfo.lua
  ns.LoadMapNotesMinimapInfo() -- load nodes\MapNotesMinimapNodesInfo.lua

  ns.LoadMoPMiniMapInfo(self) -- load nodes\MoP\MoPMiniMapInfo.lua
  ns.LoadMoPZoneInfo(self) -- load nodes\MoP\MoPWorldMapInfo.lua
  ns.LoadMoPContinentInfo(self) -- load nodes\MoP\MoPContinentInfo.lua
  ns.LoadMoPWorldMapInfo(self) -- load nodes\MoP\MoPWorldMapInfo.lua
  ns.LoadMoPZoneFPInfo(self) -- load nodes\MoP\MoPZoneFPInfo.lua
  ns.LoadMoPMinimapFPInfo(self) -- load nodes\MoP\MoPMinimapFPInfo.lua
  ns.LoadMoPZoneGhostInfo(self) -- load nodes\MoP\MoPZoneGhostInfo.lua
  ns.LoadMoPMinimapGhostInfo(self) -- load nodes\MoP\MoPMinimapGhostInfo.lua

  ns.LoadGeneralZoneLocationinfo(self) -- load nodes\MoP\MoPGeneralZoneNodes.lua
  ns.LoadGeneralMiniMapLocationinfo(self) -- load nodes\MoP\MoPGeneralMiniMapNodes.lua

  ns.LoadPathsZoneLocationinfo(self)
  ns.LoadPathsMiniMapLocationinfo(self)

  ns.LoadMoPInsideDungeonNodesLocationInfo(self) -- load nodes\MoPInsideDungeonNodesLocation.lua

  ns.LoadMoPCapitalsLocationinfo(self) -- load nodes\MoP\MoPCapitals.lua
  ns.LoadMoPMinimapCapitalsLocationinfo(self) -- load nodes\MoP\MoPMinimapCapitals.lua
end

function Addon:UpdateInstanceNames(node)
  local dungeonInfo = EJ_GetInstanceInfo
    local id = node.id

      if (node.lfgid) then
        dungeonInfo = GetLFGDungeonInfo
        id = node.lfgid 
      end

      if (type(id) == "table") then
        for i,v in pairs(node.id) do
          local name = dungeonInfo(v)
            self:UpdateAlter(v, name)
          if (node.name) then
            node.name = node.name .. "\n" .. name
          else
            node.name = name
          end
        end
      elseif (id) then
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