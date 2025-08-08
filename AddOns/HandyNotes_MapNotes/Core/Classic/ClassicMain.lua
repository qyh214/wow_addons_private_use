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

ns.RestoreStaticPopUps()

function MapNotesMiniButton:OnInitialize() --mmb.lua
  self.db = LibStub("AceDB-3.0"):New("MNMiniMapButtonClassicDB", { profile = { minimap = { hide = false, }, }, }) 
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

local pluginHandler = { }
ns.pluginHandler = pluginHandler
function ns.pluginHandler:OnEnter(uiMapId, coord)
  ns.nodes[uiMapId][coord] = nodes[uiMapId][coord]
  ns.minimap[uiMapId][coord] = minimap[uiMapId][coord]

  local nodeData = nil
  local GetCurrentMapID = WorldMapFrame:GetMapID()

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


	for i, v in pairs(instances) do
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
      
        if nodeData.wwwName then
          tooltip:AddDoubleLine("\n" .. nodeData.wwwName, nil, nil, false)
        end

        if nodeData.wwwLink and nodeData.showWWW == true then
          tooltip:AddDoubleLine("|cffffffff" .. nodeData.wwwLink, nil, nil, false)
          tooltip:AddLine("\n" .. L["Has not been unlocked yet"] .. "\n" .. "\n", 1, 0, 0)
          if ns.Addon.db.profile.ExtraTooltip then
            tooltip:AddDoubleLine("\n" .. "|cff00ff00".. "< " .. L["Activate the 'Link' function in the MapNotes menu to generate a clickable web link"] .. " >" .. "\n" .. "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
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
            tooltip:AddDoubleLine("|cff00ff00".. "< " .. L["Activate the „Link“ function from MapNotes in the General tab to create clickable links and email addresses in the chat"] .. " >" .. "\n" .. "< " .. L["Middle mouse button to post the link in the chat"] .. " >", nil, nil, false)
          end
        end
        
      end

      -- if wasEarnedByMe == true and completed == true then
      if completed == true then
        nodeData.showWWW = false
        nodeData.wwwName = false
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
    self.highlight:SetTexture(nil)
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
		  local icon = ns.icons[value.type]
      local scale
      local mapInfo = C_Map.GetMapInfo(t.uiMapId)

			local allLocked = true
			local anyLocked = false
      
      ns.SyncWithMinimapScaleAlpha() -- sync Capitals with Capitals - Minimap and/or Zones with Minimap Alpha/Scale
      ns.ChangeToClassicImages() -- function to change the icon style from new images to old images

      ns.paths = value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR"
      
      ns.professions = value.type == "Alchemy" or value.type == "Engineer" or value.type == "Cooking" or value.type == "Fishing" or value.type == "Archaeology" or value.type == "Mining" or value.type == "Jewelcrafting" or value.type == "Blacksmith" or value.type == "Leatherworking" or value.type == "Skinning" or value.type == "Tailoring" or value.type == "Herbalism" or value.type == "Inscription" or value.type == "Enchanting" or value.type == "FirstAid" or value.type == "FishingClassic" or value.type == "ProfessionOrders"

      ns.instances = value.type == "Dungeon" or value.type == "Raid" or value.type == "PassageDungeon" or value.type == "PassageDungeonRaidMulti" or value.type == "PassageRaid" or value.type == "VInstance" or value.type == "PassageDungeon" or value.type == "Multiple" or value.type == "LFR" or value.type == "Gray"

      ns.transports = value.type == "Portal" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "PassageHPortal" or value.type == "PassageAPortal" or value.type == "PassagePortal" or value.type == "Zeppelin" or value.type == "HZeppelin" or value.type == "AZeppelin" or value.type == "Ship" or value.type == "AShip" or value.type == "HShip" or value.type == "Carriage" or value.type == "TravelL" or value.type == "TravelH" or value.type == "TravelA" or value.type == "Tport2" or value.type == "OgreWaygate" or value.type == "WayGateGreen" or value.type == "Ghost" or value.type == "DarkMoon"

      ns.capitalgenerals = value.type == "Exit" or value.type == "PassageUpL" or value.type == "PassageDownL" or value.type == "PassageRightL" or value.type == "PassageLeftL" or value.type == "Innkeeper" or value.type == "Auctioneer" or value.type == "Bank" or value.type == "MNL" or value.type == "Barber" or value.type == "Transmogger" or value.type == "ItemUpgrade" or value.type == "PvPVendor" or value.type == "PvEVendor" or value.type == "MNL" or value.type == "DragonFlyTransmog" or value.type == "Catalyst" or value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR" or value.type == "BlackMarket" or value.type == "Mailbox"

      ns.classes = value.type == "Druid" or value.type == "Hunter" or value.type == "Mage" or value.type == "Paladin" or value.type == "Priest" or value.type == "Rogue" or value.type == "Shaman" or value.type == "Warlock" or value.type == "Warrior"
      
      ns.CapitalIDs =
        --Cataclysm
        GetCurrentMapID == 1454 or -- Orgrimmar
        GetCurrentMapID == 1456 or -- Thunder Bluff
        GetCurrentMapID == 1458 or -- Undercity
        GetCurrentMapID == 1954 or -- Silvermoon
        GetCurrentMapID == 1947 or -- Exodar
        GetCurrentMapID == 1457 or -- Darnassus
        GetCurrentMapID == 1453 or -- Stormwind
        GetCurrentMapID == 1455 or -- Ironforge
        GetCurrentMapID == 1955 or -- Shattrath
        --Retail & Cataclysm
        GetCurrentMapID == 86 or -- Ragefire Chasmn
        GetCurrentMapID == 125 or  -- Dalaran Northrend
        GetCurrentMapID == 126   -- Dalaran Northrend Basement

      ns.CapitalMiniMapIDs =
        --Cataclysm
        GetBestMapForUnit == 1454 or -- Orgrimmar
        GetBestMapForUnit == 1456 or -- Thunder Bluff
        GetBestMapForUnit == 1458 or -- Undercity
        GetBestMapForUnit == 1954 or -- Silvermoon
        GetBestMapForUnit == 1947 or -- Exodar
        GetBestMapForUnit == 1457 or -- Darnassus
        GetBestMapForUnit == 1453 or -- Stormwind
        GetBestMapForUnit == 1455 or -- Ironforge
        GetBestMapForUnit == 1955 or -- Shattrath
        --Retail & Cataclysm
        GetBestMapForUnit == 86 or -- Ragefire Chasmn
        GetBestMapForUnit == 125 or  -- Dalaran Northrend
        GetBestMapForUnit == 126   -- Dalaran Northrend Basement
      
			if value.name == nil then value.name = value.id or value.mnID end
      
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

      -- Instance Minimap icons
      if ns.instances and (value.showOnMinimap == true) then
        scale = db.instanceMiniMapScale
        alpha = db.instanceMiniMapAlpha
      end

      -- Profession icons in Capitals
      if ns.professions and ns.CapitalIDs and (value.showOnMinimap == false) then
        scale = db.CapitalsProfessionsScale
        alpha = db.CapitalsProfessionsAlpha
      end

      -- inside Dungeon
      if (mapInfo.mapType == 4 or mapInfo.mapType == 6) and not ns.CapitalIDs then 
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

      -- Capitals Classes icons
      if ns.CapitalMiniMapIDs and ns.classes and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsClassesScale
        alpha = db.MinimapCapitalsClassesAlpha
      end

      -- Capitals Minimap General (Innkeeper/Exit/Passage) icons
      if ns.CapitalMiniMapIDs and ns.capitalgenerals and (value.showOnMinimap == true) then
        scale = db.MinimapCapitalsGeneralScale
        alpha = db.MinimapCapitalsGeneralAlpha
      end

      -- Capitals General (Innkeeper/Exit/Passage) icons
      if ns.CapitalIDs and ns.capitalgenerals and (value.showOnMinimap == false) then
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

      -- Capitals Classes icons
      if ns.CapitalIDs and ns.classes and (value.showOnMinimap == false) then
        scale = db.CapitalsClassesScale
        alpha = db.CapitalsClassesAlpha
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
        or GetCurrentMapID == 2274 -- PTR: Khaz Algar - The War Within. Continent Scale atm on Beta a Zone not a Continent!!
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
    whileDead = true,
    hideOnEscape = true,
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

  if (button == "LeftButton" and not IsAltKeyDown()) then

    local mnID = nodes[uiMapId][coord].mnID
    if mnID then
      WorldMapFrame:SetMapID(mnID)
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
  end

end

local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...)end)

local function updateStuff()
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
  end
    updateStuff()
end

function Addon:PLAYER_LOGIN()

  ns.LoadOptions(self)
  ns.Addon = Addon

  -- Register Database Profile
  self.db = LibStub("AceDB-3.0"):New("HandyNotes_MapNotesClassicEraDB", ns.defaults)
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

  if ns.Addon.db.profile.activate.HideMMB then -- minimap button
    MNMMBIcon:Hide("MNMiniMapButton")
  end

  -- Register Worldmapbutton
  ns.WorldMapButton = LibStub('Krowi_WorldMapButtons-1.4'):Add(ADDON_NAME .. "WorldMapOptionsButtonTemplate","BUTTON")
  if ns.Addon.db.profile.activate.HideWMB
    then ns.WorldMapButton:Hide()
    else ns.WorldMapButton:Show()
  end

  --remove BlizzPOIs for MapNotes icons function
  function ns.RemoveBlizzPOIs()
    if (ns.Addon.db.profile.activate.HideMapNote) then return end

    for pin in WorldMapFrame:EnumeratePinsByTemplate("AreaPOIPinTemplate") do

      if ns.Addon.db.profile.activate.RemoveBlizzPOIs then
        if not ns.BlizzAreaPoisLookup then
            ns.BlizzAreaPoisLookup = {}
            for _, poiID in pairs(ns.BlizzAreaPoisInfo) do
                ns.BlizzAreaPoisLookup[poiID] = true
            end
        end

        for _, poiID in pairs(ns.BlizzAreaPoisInfo) do
          local poi = C_AreaPoiInfo.GetAreaPOIInfo(WorldMapFrame:GetMapID(), pin.areaPoiID)
          if (poi ~= nil and poi.areaPoiID == poiID) then
              WorldMapFrame:RemovePin(pin)
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

  ns.LoadClassicMiniMapInfo(self) -- load nodes\Classic\ClassicMiniMapInfo.lua
  ns.LoadClassicZoneInfo(self) -- load nodes\Classic\ClassicZoneInfo.lua
  ns.LoadClassicZoneFPInfo(self) -- load nodes\Classic\ClassicZoneFPInfo.lua
  ns.LoadClassicMinimapFPInfo(self) -- load nodes\Classic\ClassicMinimapFPInfo.lua
  ns.LoadClassicZoneGhostInfo(self) -- load nodes\Classic\ClassicZoneGhostInfo.lua
  ns.LoadClassicMinimapGhostInfo(self) -- load nodes\Classic\ClassicMinimapGhostInfo.lua
  ns.LoadClassicContinentInfo(self) -- load nodes\Classic\ClassicContinentInfo.lua
  ns.LoadClassicWorldMapInfo(self) -- load nodes\Classic\ClassicWorldMapInfo.lua

  ns.LoadPathsZoneLocationinfo(self) -- load nodes\Classic\ClassicPathsZoneNodes.lua
  ns.LoadPathsMiniMapLocationinfo(self) -- load nodes\Classic\ClassicPathsMiniMapNodes.lua

  ns.LoadClassicCapitalsLocationinfo(self) -- load nodes\Classic\ClassicCapitals.lua
  ns.LoadClassicMinimapCapitalsLocationinfo(self) -- load nodes\Classic\ClassicMinimapCapitals.lua
end

function Addon:UpdateInstanceNames(node)
  local dungeonInfo = EJ_GetInstanceInfo
    local id = node.id

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

function Addon:FullUpdate()
  self:PopulateTable()
  self:PopulateMinimap()
end

C_Timer.After(0, function()
  ns.AreaMapFrame = BattlefieldMapFrame
end)