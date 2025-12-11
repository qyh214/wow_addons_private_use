local _, ns = ...
local buildVersion, buildNumber, buildDate, interfaceVersion, localizedVersion, buildInfo = GetBuildInfo()
ns.version = buildVersion -- ns.version == "11.2.0"

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
local extraInformations = { }

ns.RestoreStaticPopUpsRetail() -- StaticPopUps.lua
if ns.ErrorMessages then ns.ErrorMessages() end -- RetailErrorMessage.lua

function ns.deleteCharacterSavedVariables() -- delete only activ profile
  local db = ns.Addon and ns.Addon.db
  if not db then return end

  db:SetProfile("Default")

  local current = db:GetCurrentProfile()
  if current and current ~= "Default" then
    db:DeleteProfile(current, true)
  else
    db:ResetProfile()
  end

  if HandyNotes_MapNotesRetailDB and HandyNotes_MapNotesRetailDB.char then
    HandyNotes_MapNotesRetailDB.char[current] = nil
  end

  local mmButton = _G["MNMiniMapButtonRetailDB"]
  if type(mmButton) == "table" then
    if mmButton.profileKeys then
      mmButton.profileKeys[current] = nil
    end
    if mmButton.profiles then
      mmButton.profiles[current] = nil
    end
  end
end

function ns.keepOnlyCurrentSavedVariables() -- keep activ profile, delete all others
  local db = ns.Addon and ns.Addon.db
  if not db then return end

  local currentProfile = db:GetCurrentProfile()
  if not currentProfile then return end

  local charKey = UnitName("player") .. " - " .. GetRealmName()
  if db.keys and db.keys.profileKeys then
    for key in pairs(db.keys.profileKeys) do
      if key ~= charKey then
        db.keys.profileKeys[key] = nil
      end
    end
    db.keys.profileKeys[charKey] = currentProfile
  end

  for profileName in pairs(db.profiles) do
    if profileName ~= currentProfile then
      db:DeleteProfile(profileName, true)
    end
  end

  local wipeTables = { "FogOfWarColorDB", "HandyNotes_MapNotesRetailChangelogDB" }
  for _, svName in ipairs(wipeTables) do
    if type(_G[svName]) == "table" then
      wipe(_G[svName])
    end
  end

  local mmButton = _G["MNMiniMapButtonRetailDB"]
  if type(mmButton) == "table" then

    if mmButton.profileKeys then
      for key in pairs(mmButton.profileKeys) do
        if key ~= charKey then
          mmButton.profileKeys[key] = nil
        end
      end
      mmButton.profileKeys[charKey] = currentProfile
    end

    if mmButton.profiles then
      for key in pairs(mmButton.profiles) do
        if key ~= currentProfile then
          mmButton.profiles[key] = nil
        end
      end
    end
  end
end

function ns.deleteALLSavedVariables() -- delete all profiles
  local db = ns.Addon and ns.Addon.db
  if not db then return end

  db:SetProfile("Default")

  for profileName in pairs(db.profiles) do
    if profileName ~= "Default" then
      db:DeleteProfile(profileName, true)
    end
  end

  db:ResetDB("Default")

  local wipeTables = { "HandyNotes_MapNotesRetailNpcCacheDB", "FogOfWarColorDB", "HandyNotes_MapNotesRetailChangelogDB", "MNMiniMapButtonRetailDB" }
  for _, svName in ipairs(wipeTables) do
    if type(_G[svName]) == "table" then
      wipe(_G[svName])
    end
    _G[svName] = nil
  end
end

function MapNotesMiniButton:OnInitialize() --mmb.lua
  self.db = LibStub("AceDB-3.0"):New("MNMiniMapButtonRetailDB", { profile = { minimap = { hide = false, }, }, }) 
  MNMMBIcon:Register("MNMiniMapButton", ns.miniButton, self.db.profile.minimap)
end

function ns.DevMode()
  return ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode
end

ns.alreadyWarned = ns.alreadyWarned or {}
SLASH_DeveloperMode1 = "/mndevmode";
function SlashCmdList.DeveloperMode(msg, editbox)
  if ns.Addon.db.profile.DeveloperMode then
    ns.Addon.db.profile.DeveloperMode = false
    print("MapNotes DeveloperMode = Off")
  else
    ns.Addon.db.profile.DeveloperMode = true
    print("MapNotes DeveloperMode = On")

    if ns.alreadyWarned then
      table.wipe(ns.alreadyWarned)
    end

    if ns.MN_dbgSeen then
      table.wipe(ns.MN_dbgSeen)
    end

    ns.RunDeveloperValidation()
  end
end

function ns.RunDeveloperValidation()
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile.DeveloperMode) then return end

  for mapID, mapNodes in pairs(ns.nodes or {}) do
    for coord, value in pairs(mapNodes) do
      ns.ValidateNodeEntry(value, coord, mapID, value and value.sourceFile or "?")
    end
  end

  for mapID, mapNodes in pairs(ns.minimap or {}) do
    for coord, value in pairs(mapNodes) do
      ns.ValidateNodeEntry(value, coord, mapID, value and value.sourceFile or "?")
    end
  end
end

ns.CANONICAL_KEYS = {
  name = "name",
  id = "id",
  type = "type",
  npcid = "npcID",
  showinzone = "showInZone",
  showoncontinent = "showOnContinent",
  showonminimap = "showOnMinimap",
  mnid = "mnID",
  transportname = "TransportName",
  delveid = "delveID",
  dnid = "dnID",
  mnid2 = "mnID2",
  mnid3 = "mnID3",
  taxiid = "taxiID",
  wwwname = "wwwName",
  leavedelve = "leaveDelve",
}

function ns.ValidateNodeEntry(value, coord, uiMapID, sourceFile)
  if not (ns.Addon and ns.Addon.db and ns.Addon.db.profile.DeveloperMode) then return end
  ns.alreadyWarned = ns.alreadyWarned or {}

  local fromMinimap = ns.minimap and ns.minimap[uiMapID] and ns.minimap[uiMapID][coord] == value
  local fromNodes = ns.nodes and ns.nodes[uiMapID] and ns.nodes[uiMapID][coord] == value
  local dataSource = "?"
  if fromMinimap then
    dataSource = "minimap[" .. tostring(uiMapID) .. "]"
  elseif fromNodes then
    dataSource = "nodes[" .. tostring(uiMapID) .. "]"
  elseif ns.minimap and ns.minimap[uiMapID] then
    dataSource = "minimap[" .. tostring(uiMapID) .. "]"
  elseif ns.nodes and ns.nodes[uiMapID] then
    dataSource = "nodes[" .. tostring(uiMapID) .. "]"
  end

  local coordStr = coord and tostring(coord) or "?"
  local warnKey = tostring(dataSource) .. ":" .. tostring(coordStr)
  if ns.alreadyWarned[warnKey] then return end

  ns.validatedOnce = ns.validatedOnce or {}
  if ns.validatedOnce[warnKey] then return true end

  local source = sourceFile or ns.currentSourceFile or "?"
  local typoForRequired = false
  for key in pairs(value) do
    if type(key) == "string" then
      local lower = key:lower()
      local canonical = ns.CANONICAL_KEYS[lower]
      if canonical and key ~= canonical then
        local typoWarnKey = warnKey .. ":typo:" .. key
        if not ns.alreadyWarned[typoWarnKey] then
          print(ns.COLORED_ADDON_NAME, ERRORS .. " '" .. key .. "= ' → richtig wäre: '" .. canonical .. " ='" .. "\n • Datei: " .. tostring(source) .. " • Zeile: " .. tostring(dataSource) .. "[" .. coordStr .. "]")
          ns.alreadyWarned[typoWarnKey] = true
        end
        if canonical == "name" or canonical == "id" then
          typoForRequired = true
        end
      end
    end
  end
  ns.validatedOnce[warnKey] = true

  if value.type and ns.icons and not ns.icons[value.type] then
    ns.alreadyWarned = ns.alreadyWarned or {}
    local badKey = warnKey .. ":badtype:" .. tostring(value.type)
    if not ns.alreadyWarned[badKey] then
      print(ns.COLORED_ADDON_NAME, ERRORS .. " • 'type = " .. tostring(value.type) .. "'" .. "\n • Datei: " .. tostring(source) .. " • Zeile: " .. tostring(dataSource) .. "[" .. coordStr .. "]")
      ns.alreadyWarned[badKey] = true
    end
  end

  local missing = {}
  if not value.name and not value.id then
    if not typoForRequired then
      table.insert(missing, "'name =' or 'id ='")
    end
  end
  if not value.type then
    table.insert(missing, "'type ='")
  end

  if #missing > 0 then
    print(ns.COLORED_ADDON_NAME, ERRORS .. " • Datei: " .. tostring(source) .. " • Zeile: " .. tostring(dataSource) .. "[" .. coordStr .. "]" .. " • Grund: " .. table.concat(missing, ", ") .. " fehlt!")
    ns.alreadyWarned[warnKey] = true
    return nil
  end

  local hideInAllViews = (value.showInZone == false or value.showInZone == nil) and (value.showOnContinent == false or value.showOnContinent == nil) and (value.showOnMinimap == false or value.showOnMinimap == nil)
  if hideInAllViews then
    print(ns.COLORED_ADDON_NAME, ERRORS .. " • showInZone, showOnContinent, showOnMinimap alles zugleich deaktiviert!" .. "\n • Datei: " .. tostring(source) .. " • Zeile: " .. tostring(dataSource) .. "[" .. coordStr .. "]")
    ns.alreadyWarned[warnKey] = true
  end

  local visibleEverywhere = (value.showInZone) and (value.showOnContinent) and value.showOnMinimap
  if visibleEverywhere then
    print(ns.COLORED_ADDON_NAME, ERRORS .. " • showInZone, showOnContinent, showOnMinimap alles zugleich aktiviert!" .. "\n • Datei: " .. tostring(source) .. " • Zeile: " .. tostring(dataSource) .. "[" .. coordStr .. "]")
    ns.alreadyWarned[warnKey] = true
  end

  return true
end

local function LoadAndCheck(loadFunc, self)
  local prevNodes, prevMinimap = ns.nodes, ns.minimap
  local function newAuto() return setmetatable({}, { __index = function(t,k) local v={} rawset(t,k,v); return v end }) end
  local tempNodes, tempMinimap = newAuto(), newAuto()
  ns.nodes, ns.minimap = tempNodes, tempMinimap

  local prevSource = ns.currentSourceFile
  ns.currentSourceFile = nil
  if type(loadFunc) == "function" then loadFunc(self) end

  local currentSource = ns.currentSourceFile or prevSource or "?"
  local function mergeAndTag(temp, dest)
    for mapID, mapNodes in pairs(temp) do
      dest[mapID] = dest[mapID] or {}
      for coord, value in pairs(mapNodes) do
        value.sourceFile = currentSource
        dest[mapID][coord] = value
        if ns.DevMode() then
          ns.ValidateNodeEntry(value, coord, mapID, currentSource)
        end
      end
    end
  end

  mergeAndTag(tempNodes, prevNodes)
  mergeAndTag(tempMinimap, prevMinimap)

  ns.nodes, ns.minimap = prevNodes, prevMinimap
  ns.currentSourceFile = prevSource
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

  local BossData = pcall(EJ_SelectInstance, instanceID)
  if not BossData then
    tooltip:AddLine("|cffffffff" .. L["No boss data available for this instance"])
    return
  end

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
  local CurrentMapID = WorldMapFrame:GetMapID()

  if ns.nodes[uiMapId] and nodes[uiMapId] then ns.nodes[uiMapId][coord] = nodes[uiMapId][coord] end
  if ns.minimap[uiMapId] and minimap[uiMapId] then ns.minimap[uiMapId][coord] = minimap[uiMapId][coord] end

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
  if type(nodeData.name) ~= "string" then return end
	local instances = { strsplit("\n", nodeData.name) }

  ExtraToolTip()
	updateextraInformation()
  ns.AddTaxiStatusToTooltip(tooltip, nodeData.taxiID) -- TaxiIDNames.lua

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

  ns.isMulti = (nodeData.id and type(nodeData.id) == "table")
  ns.total = ns.isMulti and #instances or 1
	for idx, v in pairs(instances) do

    --print(i, v)
	  if (db.KilledBosses and (extraInformations[v])) then
 	    if (extraInformations[v]) then
        --print("Dungeon/Raid is locked")
	      for a,b in pairs(extraInformations[v]) do
          --tooltip:AddLine(v .. ": " .. a .. " " .. b, nil, nil, nil, false)
	        tooltip:AddDoubleLine(v, a .. " " .. b.progress .. "/" .. b.total, 1, 1, 1, 1, 1, 1)
 	      end
	    end
	  else
	    tooltip:AddLine(v, nil, nil, nil, false)
      if ns.DevMode() then

        if nodeData.dnID then
          tooltip:AddLine("Type:  " .. nodeData.dnID, nil, nil, false)
        end

        if nodeData.type then
          tooltip:AddLine("IconName:  " .. nodeData.type, nil, nil, false)
        end

        tooltip:AddDoubleLine("uiMapID:  " .. uiMapId, "Coord:  " .. coord, nil, nil, false)
        tooltip:AddDoubleLine("uiMapID:  " .. uiMapId, "==>   " .. C_Map.GetMapInfo(uiMapId).name, nil, nil, false)

        local npcID = tonumber(nodeData.npcID)
        if npcID and npcID > 0 then
          tooltip:AddDoubleLine(("npcID:  %d"):format(npcID), "", nil, nil, nil)
        end

        if nodeData.npcIDs1 then
          tooltip:AddDoubleLine("npcIDs1:  " .. nodeData.npcIDs1, C_Map.GetMapInfo(nodeData.npcIDs1), nil, nil, false)
        end

        if nodeData.npcIDs2 then
          tooltip:AddDoubleLine("npcIDs2:  " .. nodeData.npcIDs2, C_Map.GetMapInfo(nodeData.npcIDs2), nil, nil, false)
        end

        if nodeData.npcIDs3 then
          tooltip:AddDoubleLine("npcIDs3:  " .. nodeData.npcIDs3, C_Map.GetMapInfo(nodeData.npcIDs3), nil, nil, false)
        end

        if nodeData.npcIDs4 then
          tooltip:AddDoubleLine("npcIDs4:  " .. nodeData.npcIDs4, C_Map.GetMapInfo(nodeData.npcIDs4), nil, nil, false)
        end

        if nodeData.npcIDs5 then
          tooltip:AddDoubleLine("npcIDs5:  " .. nodeData.npcIDs5, C_Map.GetMapInfo(nodeData.npcIDs5), nil, nil, false)
        end

        if nodeData.npcIDs6 then
          tooltip:AddDoubleLine("npcIDs6:  " .. nodeData.npcIDs6, C_Map.GetMapInfo(nodeData.npcIDs6), nil, nil, false)
        end

        if nodeData.npcIDs7 then
          tooltip:AddDoubleLine("npcIDs7:  " .. nodeData.npcIDs7, C_Map.GetMapInfo(nodeData.npcIDs7), nil, nil, false)
        end

        if nodeData.npcIDs8 then
          tooltip:AddDoubleLine("npcIDs8:  " .. nodeData.npcIDs8, C_Map.GetMapInfo(nodeData.npcIDs8), nil, nil, false)
        end

        if nodeData.npcIDs9 then
          tooltip:AddDoubleLine("npcIDs9:  " .. nodeData.npcIDs9, C_Map.GetMapInfo(nodeData.npcIDs9), nil, nil, false)
        end
        if nodeData.npcIDs10 then
          tooltip:AddDoubleLine("npcIDs10:  " .. nodeData.npcIDs10, C_Map.GetMapInfo(nodeData.npcIDs10), nil, nil, false)
        end

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

    if (nodeData.dnID and nodeData.mnID) and not (nodeData.mnID2 or nodeData.mnID3 or nodeData.hideTTmnID) then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine("==> " .. mnIDname, nil, nil, false)
      end
    end

    if not ns.Addon.db.profile.activate.SwapButtons then -- Original Buttons
      if nodeData.mnID and nodeData.mnID2 or nodeData.mnID3 then -- outputs the Zone or Dungeonmap name and displays it in the tooltip
        local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
        if mnIDname then
          tooltip:AddDoubleLine("\n" .. KEY_BUTTON1 .. " - " .. mnIDname, nil, nil, false)
        end
      end

      if nodeData.mnID2 then
        local mnID2name = C_Map.GetMapInfo(nodeData.mnID2).name
        if mnID2name then 
          tooltip:AddDoubleLine(KEY_BUTTON2 .. " - " .. mnID2name, nil, nil, false)
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
          tooltip:AddDoubleLine(KEY_BUTTON1 .. " ==> " .. mnID2name, nil, nil, false)
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

    if nodeData.mnID and not (nodeData.dnID or nodeData.id or nodeData.TransportName or nodeData.hideTTmnID) 
      and not (nodeData.type == "Portal" or nodeData.type == "PortalS" or nodeData.type == "HPortal" or nodeData.type == "APortal" or nodeData.type == "HPortalS" or nodeData.type == "APortalS" or nodeData.type == "HPortalGray" 
      or nodeData.type == "APortalGray" or nodeData.type == "HPortalSGray" or nodeData.type == "APortalSGray" or nodeData.type == "PassageHPortal" or nodeData.type == "PassageAPortal" or nodeData.type == "PassagePortal" 
      or nodeData.type == "WayGateGreen" or nodeData.type == "TorghastUp" or nodeData.type == "WayGateGolden" 
      or nodeData.type == "MoleMachine"
      or nodeData.type == "RocketDrill"
      or nodeData.type == "Zeppelin" or nodeData.type == "HZeppelin"
      or nodeData.type == "Ship" or nodeData.type == "AShip" or nodeData.type == "HShip") 
    then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(" ==> " .. mnIDname, nil, nil, false)
      end
    end

    if (nodeData.mnID and not nodeData.TransportName) and (nodeData.type == "Portal" or nodeData.type == "PortalS" or nodeData.type == "HPortal" or nodeData.type == "APortal" or nodeData.type == "HPortalS" or nodeData.type == "APortalS" or nodeData.type == "HPortalGray" 
      or nodeData.type == "APortalGray" or nodeData.type == "HPortalSGray" or nodeData.type == "APortalSGray" or nodeData.type == "PassageHPortal" or nodeData.type == "PassageAPortal" or nodeData.type == "PassagePortal" 
      or nodeData.type == "WayGateGreen" or nodeData.type == "TorghastUp" or nodeData.type == "WayGateGolden")
    then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(mnIDname .. " (" .. L["Portal"] ..")", nil, nil, false) -- only Portals name tooltips
      end
    end

    if (nodeData.mnID and not nodeData.TransportName) and (nodeData.type == "MoleMachine")
    then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(mnIDname .. " (" .. L["Mole Machine"] ..")", nil, nil, false) -- only Mole Machine name tooltips
      end
    end

        if (nodeData.mnID and not nodeData.TransportName) and (nodeData.type == "RocketDrill")
    then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(mnIDname .. " (" .. L["Rocket drill"] ..")", nil, nil, false) -- only Rocket drill name tooltips
      end
    end

    if (nodeData.mnID and not nodeData.TransportName) and (nodeData.type == "Zeppelin" or nodeData.type == "HZeppelin") then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(mnIDname .. " (" .. L["Zeppelin"] ..")", nil, nil, false) -- only Zeppelin name tooltips
      end
    end

    if (nodeData.mnID and not nodeData.TransportName) and (nodeData.type == "Ship" or nodeData.type == "AShip" or nodeData.type == "HShip") then
      local mnIDname = C_Map.GetMapInfo(nodeData.mnID).name
      if mnIDname then
        tooltip:AddDoubleLine(mnIDname .. " (" .. L["Ship"] ..")", nil, nil, false) -- Ship name tooltips
      end
    end

    ns.mnIDsANDquestIDsTooltip(tooltip, nodeData)

    if nodeData.type and not ns.MapType0 then -- single tooltips for instances under id names

      if nodeData.type == "Raid" or nodeData.type == "PassageRaid" or nodeData.type == "VInstanceR" then
        tooltip:AddDoubleLine("|cffffffff" .. CALENDAR_TYPE_RAID)
      end

      if nodeData.type == "Dungeon" or nodeData.type == "PassageDungeon" or nodeData.type == "VInstanceD" then
        tooltip:AddDoubleLine("|cffffffff" .. CALENDAR_TYPE_DUNGEON)
      end

      if nodeData.type == "PetBattleDungeon" then
        tooltip:AddDoubleLine("|cffffffff" .. TOOLTIP_BATTLE_PET .. " " .. CALENDAR_TYPE_DUNGEON)
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

    -- if ToggleMap or UseInBattle not active tooltip
    if not ns.Addon.db.profile.activate.ToggleMap and ns.Addon.db.profile.activate.ToggleMapInfo and WorldMapFrame:IsShown() and (not ns.isMulti or idx == ns.total) then
      if (nodeData.mnID and nodeData.leaveDelve and ns.icons["Delves"]) or nodeData.mnID then
        tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. "|cff00ff00 " .. L["Toggle Maps function is disabled"], nil, nil, false)
      end
    end

    -- delveID tooltips
    if nodeData.delveID and WorldMapFrame:IsShown() then
      tooltip:AddDoubleLine(TextIconMNL4:GetIconString() .. " " .. "|cff00ff00" .. "< " .. KEY_BUTTON3 .. " " .. L["to show delve map"] .. " > " .. TextIconMNL4:GetIconString(), nil, nil, false)       
    end

    -- Extra Tooltip
    if ns.OnlyDisplayedIfTheWorldmapIsAlsoOpen and (not ns.isMulti or idx == ns.total) then -- only show tooltips if worldmap is opend and hide it on all icons if worldmap is closed
      local mapInfo = C_Map.GetMapInfo(uiMapId)
      local isCosmicAndAzeroth = mapInfo and (mapInfo.mapType == 0 or mapInfo.mapType == 1) or false
      local isCosmic = mapInfo and mapInfo.mapType == 0 or false
      local isAzeroth  = mapInfo and mapInfo.mapType == 1 or false

      -- Adventure Guide tooltip
      if not ns.Addon.db.profile.journal then
        if nodeData.id and not nodeData.mnID then
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. "|cff00ff00 " .. L["Adventure guide function is disabled"], nil, nil, false)
        end
      end

      if nodeData.mnID and (ns.Addon.db.profile.activate.ToggleMap or ns.Addon.db.profile.activate.UseInBattle) and not nodeData.delveID then -- show mnID map change information with ToggleMap or UseInBattle
        if ns.Addon.db.profile.activate.SwapButtons then -- Swap Buttons
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to show map >"], nil, nil, false)
        else -- Original Buttons
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click to show map >"], nil, nil, false)
        end
      end
    
      if nodeData.id and not nodeData.mnID and ns.Addon.db.profile.journal then -- "id = " instance entrances
        if ns.Addon.db.profile.activate.SwapButtons and ns.Addon.db.profile.journal then -- Swap Buttons
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Right Click to open Adventure Guide >"], nil, nil, false) -- instance entrances into adventure guide
        else -- -- Original Buttons
          tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. L["< Left Click to open Adventure Guide >"], nil, nil, false) -- instance entrances into adventure guide
        end
      end


      if ns.Addon.db.profile.WayPoints and not isCosmicAndAzeroth then -- do not show on Cosmic 946 and Azeroth 947 map
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

      if nodeData.mnID and nodeData.leaveDelve and ns.icons["Delves"] and (ns.Addon.db.profile.activate.ToggleMap or ns.Addon.db.profile.activate.UseInBattle) then -- inside delves to leave them with ToggleMap or UseInBattle
        tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cff00ff00" .. "< " .. MIDDLE_BUTTON_STRING .. " " .. INSTANCE_LEAVE .. " (" .. DELVES_LABEL .. ") >", nil, nil, false)
      end

      if ns.Addon.db.profile.DeleteIcons and not isCosmic then -- do not show on Cosmic 946 map
        tooltip:AddDoubleLine(TextIconInfo:GetIconString() .. " " .. "|cffff0000" .. L["< Alt + Right click to delete this icon >"], nil, nil, false)
      end
    end

    tooltip:Show()
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
    local CurrentMapID = WorldMapFrame:GetMapID()
    local PlayerMapID = C_Map.GetBestMapForUnit("player")

		while value do
			local alpha
		  local icon = ns.icons[value.type]
      local scale
      local mapInfo = C_Map.GetMapInfo(t.uiMapId)

			local allLocked = true
			local anyLocked = false

      ns.SyncSingleScaleAlpha() -- synch single Icons
      ns.SyncWithMinimapScaleAlpha() -- syncWithMinimap.lua - sync Capitals with Capitals - Minimap and/or Zones with Minimap Alpha/Scale
      ns.ChangeToClassicImagesRetail() -- ClassicImages.lua - function to change the icon style from new images to old images

      ns.pathIcons = value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR"
                          or value.type == "RedPathO" or value.type == "RedPathRO" or value.type == "RedPathLO" or value.type == "RedPathU" or value.type == "RedPathLU" or value.type == "RedPathRU" or value.type == "RedPathL" or value.type == "RedPathR"
      
      ns.professionIcons = value.type == "Alchemy" or value.type == "Engineer" or value.type == "Cooking" or value.type == "Fishing" or value.type == "Archaeology" or value.type == "Mining" or value.type == "Jewelcrafting" 
                          or value.type == "Blacksmith" or value.type == "Leatherworking" or value.type == "Skinning" or value.type == "Tailoring" or value.type == "Herbalism" or value.type == "Inscription"
                          or value.type == "Enchanting" or value.type == "FishingClassic" or value.type == "ProfessionOrders" or value.type == "ProfessionsMixed"

      ns.instanceIcons = value.type == "Dungeon" or value.type == "Raid" or value.type == "PassageDungeon" or value.type == "PassageDungeonRaidMulti" or value.type == "PassageRaid" or value.type == "VInstance" or value.type == "MultiVInstance" 
                          or value.type == "Multiple" or value.type == "LFR" or value.type == "Gray" or value.type == "VKey1" or value.type == "Delves" or value.type == "VInstanceD" or value.type == "VInstanceR" or value.type == "MultiVInstanceD" 
                          or value.type == "MultiVInstanceR" or value.type == "DelvesPassage" or value.type == "PassageLFR" or value.type == "PetBattleDungeon"

      ns.transportIcons = value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "HPortalGray" or value.type == "APortalGray" 
                          or value.type == "HPortalSGray" or value.type == "APortalSGray" or value.type == "PassageHPortal" or value.type == "PassageAPortal" or value.type == "PassagePortal" or value.type == "Zeppelin" or value.type == "HZeppelin" 
                          or value.type == "AZeppelin" or value.type == "Ship" or value.type == "TorghastUp" or value.type == "AShip" or value.type == "HShip" or value.type == "Carriage" or value.type == "TravelL" or value.type == "TravelH" 
                          or value.type == "TravelA" or value.type == "Tport2" or value.type == "OgreWaygate" or value.type == "WayGateGreen" or value.type == "Ghost" or value.type == "DarkMoon" or value.type == "Mirror" or value.type == "TravelM"
                          or value.type == "WayGateGolden" or value.type == "MoleMachineDwarf" or value.type == "PortalPetBattleDungeon" or value.type == "PortalHPetBattleDungeon" or value.type == "PortalAPetBattleDungeon" or value.type == "B11M" 
                          or value.type == "B11F" or value.type == "MOrcM" or value.type == "MOrcF" or value.type == "UndeadM" or value.type == "UndeadF" or value.type == "GoblinM" or value.type == "GoblinF" or value.type == "GilneanM" or value.type == "GilneanF" 
                          or value.type == "KulM" or value.type == "KulF" or value.type == "DwarfM" or value.type == "DwarfF" or value.type == "OrcM" or value.type == "OrcF" or value.type == "GnomeM" or value.type == "GnomeF" or value.type == "DraneiM"
                          or value.type == "DraneiF" or value.type == "N11M" or value.type == "N11F" or value.type == "TrollM" or value.type == "TrollF"
                          
      ns.generalIcons = value.type == "Exit" or value.type == "PassageUpL" or value.type == "PassageDownL" or value.type == "PassageRightL" or value.type == "PassageLeftL" or value.type == "Innkeeper" 
                        or value.type == "Auctioneer" or value.type == "Bank" or value.type == "MNL" or value.type == "Barber" or value.type == "Transmogger" or value.type == "ItemUpgrade" or value.type == "PvPVendor" 
                        or value.type == "PvEVendor" or value.type == "DragonFlyTransmog" or value.type == "Catalyst" or value.type == "PathO" or value.type == "PathRO" or value.type == "PathLO" 
                        or value.type == "PathU" or value.type == "PathLU" or value.type == "PathRU" or value.type == "PathL" or value.type == "PathR" or value.type == "BlackMarket" or value.type == "Mailbox"
                        or value.type == "StablemasterN" or value.type == "StablemasterH" or value.type == "StablemasterA" or value.type == "HIcon" or value.type == "AIcon" or value.type == "InnkeeperN" 
                        or value.type == "InnkeeperH" or value.type == "InnkeeperA" or value.type == "MailboxN" or value.type == "MailboxH" or value.type == "MailboxA" or value.type == "PvPVendorH" or value.type == "PvPVendorA" 
                        or value.type == "PvEVendorH" or value.type == "PvEVendorA" or value.type == "MMInnkeeperH" or value.type == "MMInnkeeperA" or value.type == "MMStablemasterH" or value.type == "MMStablemasterA"
                        or value.type == "MMMailboxH" or value.type == "MMMailboxA" or value.type == "MMPvPVendorH" or value.type == "MMPvPVendorA" or value.type == "MMPvEVendorH" or value.type == "MMPvEVendorA" 
                        or value.type == "ContinentPvPVendorH" or value.type == "ContinentPvPVendorA" or value.type == "ContinentPvEVendorH" or value.type == "ContinentPvEVendorA"
                        or value.type == "ZonePvEVendorH" or value.type == "ZonePvPVendorH" or value.type == "ZonePvEVendorA" or value.type == "ZonePvPVendorA" or value.type == "TradingPost" or value.type == "PassageCaveUp"
                        or value.type == "PassageCaveDown" or value.type == "MountMerchant" or value.type == "ScoutingMap" or value.type == "RenownQuartermaster" or value.type == "RenownQuartermasterH" or value.type == "RenownQuartermasterA"
                        or value.type == "MMRenownQuartermasterH" or value.type == "MMRenownQuartermasterA" or value.type == "ZoneRenownQuartermasterH" or value.type == "ZoneRenownQuartermasterA" or value.type == "ContinentRenownQuartermasterH" or value.type == "ContinentRenownQuartermasterA"
                        or value.type == "PassageElevatorUp" or value.type == "PassageElevatorDown"

      ns.classHallIcons = value.type == "CHMountMerchant" or value.type == "CHUpgrade" or value.type == "CHScoutingMap" or value.type == "CHMailbox" or value.type == "RedPathO" or value.type == "RedPathRO" or value.type == "RedPathLO" or value.type == "RedPathU" 
                      or value.type == "RedPathLU" or value.type == "RedPathRU" or value.type == "RedPathL" or value.type == "RedPathR" or value.type == "CHTravel" or value.type == "CHPortal" or value.type == "ArtifactForge" or value.type == "Recruit" 
                      or value.type == "CHVendor" or value.type == "CHStablemasterN" or value.type == "Archivar" or value.type == "CHDeathknight" or value.type == "CHDemonhunter" or value.type == "CHDracyr" or value.type == "CHDruid" or value.type == "CHHunter" 
                      or value.type == "CHMage" or value.type == "CHMonk" or value.type == "CHPaladin" or value.type == "CHPriest" or value.type == "CHRogue" or value.type == "CHShaman" or value.type == "CHWarlock" or value.type == "CHWarrior" 

      ns.raceIcons = value.type == "B11M" or value.type == "B11F" or value.type == "MOrcM" or value.type == "MOrcF" or value.type == "UndeadM" or value.type == "UndeadF" or value.type == "GoblinM" or value.type == "GoblinF" or value.type == "GilneanM" 
                      or value.type == "GilneanF" or value.type == "KulM" or value.type == "KulF" or value.type == "DwarfM" or value.type == "DwarfF" or value.type == "OrcM" or value.type == "OrcF" or value.type == "GnomeM" or value.type == "GnomeF" 
                      or value.type == "DraneiM" or value.type == "DraneiF" or value.type == "N11M" or value.type == "N11F" or value.type == "TrollM" or value.type == "TrollF" or value.type == "TaureM" or value.type == "TaureF" or value.type == "PandaM" 
                      or value.type == "PandaF" or value.type == "HMTaurenM" or value.type == "HMTaurenF" or value.type == "LFDraeneiM" or value.type == "LFDraeneiF" or value.type == "LN11BorneM" or value.type == "LN11BorneF" or value.type == "Void11M" 
                      or value.type == "Void11F" or value.type == "DarkDwarfM" or value.type == "DarkDwarfF" or value.type == "DracthyrM" or value.type == "DracthyrF" or value.type == "VulperaM" or value.type == "VulperaF" or value.type == "MechaGnomeM" 
                      or value.type == "MechaGnomeM" or value.type == "ZandalariTrollM" or value.type == "ZandalariTrollF"

      ns.MapType0 = mapInfo.mapType == 0 -- Cosmic map
      ns.MapType1 = mapInfo.mapType == 1 -- World map
      ns.MapType2 = mapInfo.mapType == 2 -- Continent maps
      ns.MapType3 = mapInfo.mapType == 3 -- Zone maps
      ns.MapType4 = mapInfo.mapType == 4 -- Dungeon maps
      ns.MapType5 = mapInfo.mapType == 5 -- Micro maps
      ns.MapType6 = mapInfo.mapType == 6 -- Orphan maps

      ns.ContinentIDs = CurrentMapID == 12 or CurrentMapID == 13 or CurrentMapID == 101 or CurrentMapID == 113 or CurrentMapID == 424 or CurrentMapID == 619
                      or CurrentMapID == 875 or CurrentMapID == 876 or CurrentMapID == 905 or CurrentMapID == 1978 or CurrentMapID == 1550 or CurrentMapID == 572
                      or CurrentMapID == 2274 or CurrentMapID == 948

      ns.ClassHallIDs = CurrentMapID == 24 or CurrentMapID == 626 or CurrentMapID == 627 or CurrentMapID == 628 -- Class Hall
                      or CurrentMapID == 646 or CurrentMapID == 647 or CurrentMapID == 648 or CurrentMapID == 695 or CurrentMapID == 720 -- Class Hall
                      or CurrentMapID == 702 or CurrentMapID == 709 or CurrentMapID == 717 or CurrentMapID == 721 or CurrentMapID == 726 or CurrentMapID == 739 -- Class Hall
                      or CurrentMapID == 734 or CurrentMapID == 735 or CurrentMapID == 747 -- Class Hall

      ns.CapitalIDs = CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 85 or CurrentMapID == 90 
                      or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 111 or CurrentMapID == 125 or CurrentMapID == 126 
                      or CurrentMapID == 391 or CurrentMapID == 392 or CurrentMapID == 393 or CurrentMapID == 394 or CurrentMapID == 407 or CurrentMapID == 503 
                      or CurrentMapID == 582 or CurrentMapID == 590 or CurrentMapID == 622 or CurrentMapID == 624 or CurrentMapID == 627 
                      or CurrentMapID == 831 or CurrentMapID == 832 or CurrentMapID == 628 or CurrentMapID == 629 or CurrentMapID == 1161 or CurrentMapID == 1163 
                      or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 1670 or CurrentMapID == 1671 or CurrentMapID == 1672 or CurrentMapID == 1673 
                      or CurrentMapID == 2112 or CurrentMapID == 2339 or CurrentMapID == 499 or CurrentMapID == 500 or CurrentMapID == 2266
                            
      ns.AllianceCapitalIDs = CurrentMapID == 84 or CurrentMapID == 87 or CurrentMapID == 89 or CurrentMapID == 103 or CurrentMapID == 393 or CurrentMapID == 394
                      or CurrentMapID == 1161 or CurrentMapID == 622 or CurrentMapID == 582

      ns.HordeCapitalsIDs = CurrentMapID == 85 or CurrentMapID == 86 or CurrentMapID == 88 or CurrentMapID == 110 or CurrentMapID == 90 or CurrentMapID == 392
                      or CurrentMapID == 391 or CurrentMapID == 1163 or CurrentMapID == 1164 or CurrentMapID == 1165 or CurrentMapID == 624 or CurrentMapID == 590

      ns.NeutralCapitalIDs = CurrentMapID == 626 or CurrentMapID == 747 -- Class Hall
                      or CurrentMapID == 2339 or CurrentMapID == 111 or CurrentMapID == 1670 or CurrentMapID == 1671 or CurrentMapID == 1673 or CurrentMapID == 1672
                      or CurrentMapID == 125 or CurrentMapID == 126 or CurrentMapID == 627 or CurrentMapID == 628 or CurrentMapID == 269 or CurrentMapID == 2112 
                      or CurrentMapID == 407

      ns.CapitalMiniMapIDs = PlayerMapID == 84 or PlayerMapID == 87 or PlayerMapID == 89 or PlayerMapID == 103 or PlayerMapID == 85 or PlayerMapID == 90 
                      or PlayerMapID == 86 or PlayerMapID == 88 or PlayerMapID == 110 or PlayerMapID == 111 or PlayerMapID == 125 or PlayerMapID == 126 
                      or PlayerMapID == 391 or PlayerMapID == 392 or PlayerMapID == 393 or PlayerMapID == 394 or PlayerMapID == 407 or PlayerMapID == 503 
                      or PlayerMapID == 582 or PlayerMapID == 590 or PlayerMapID == 622 or PlayerMapID == 624 or PlayerMapID == 627 
                      or PlayerMapID == 831 or PlayerMapID == 832 or PlayerMapID == 628 or PlayerMapID == 629 or PlayerMapID == 1161 or PlayerMapID == 1163 
                      or PlayerMapID == 1164 or PlayerMapID == 1165 or PlayerMapID == 1670 or PlayerMapID == 1671 or PlayerMapID == 1672 or PlayerMapID == 1673 
                      or PlayerMapID == 2112 or PlayerMapID == 2339 or PlayerMapID == 499 or PlayerMapID == 500 or PlayerMapID == 2266

      ns.KalimdorIDs = CurrentMapID == 1 or CurrentMapID == 7 or CurrentMapID == 10 or CurrentMapID == 11 or CurrentMapID == 57 or CurrentMapID == 62 
                      or CurrentMapID == 63 or CurrentMapID == 64 or CurrentMapID == 65 or CurrentMapID == 66 or CurrentMapID == 67 or CurrentMapID == 68 
                      or CurrentMapID == 69 or CurrentMapID == 70 or CurrentMapID == 71 or CurrentMapID == 74 or CurrentMapID == 75 or CurrentMapID == 76 
                      or CurrentMapID == 77 or CurrentMapID == 78 or CurrentMapID == 80 or CurrentMapID == 81 or CurrentMapID == 83 or CurrentMapID == 97 
                      or CurrentMapID == 106 or CurrentMapID == 199 or CurrentMapID == 327 or CurrentMapID == 460 or CurrentMapID == 461 or CurrentMapID == 462 
                      or CurrentMapID == 468 or CurrentMapID == 1527 or CurrentMapID == 198 or CurrentMapID == 249
          
      ns.EasternKingdomIDs = CurrentMapID == 14 or CurrentMapID == 15 or CurrentMapID == 16 or CurrentMapID == 17 or CurrentMapID == 18 
                      or CurrentMapID == 19 or CurrentMapID == 21 or CurrentMapID == 22 or CurrentMapID == 23 or CurrentMapID == 25 or CurrentMapID == 26 
                      or CurrentMapID == 27 or CurrentMapID == 28 or CurrentMapID == 30 or CurrentMapID == 32 or CurrentMapID == 33 or CurrentMapID == 34 
                      or CurrentMapID == 35 or CurrentMapID == 36 or CurrentMapID == 37 or CurrentMapID == 42 or CurrentMapID == 47 or CurrentMapID == 48 
                      or CurrentMapID == 49 or CurrentMapID == 50 or CurrentMapID == 51 or CurrentMapID == 52 or CurrentMapID == 55 or CurrentMapID == 56 
                      or CurrentMapID == 94 or CurrentMapID == 210 or CurrentMapID == 224 or CurrentMapID == 245 or CurrentMapID == 425 or CurrentMapID == 427 
                      or CurrentMapID == 465 or CurrentMapID == 467 or CurrentMapID == 469 or CurrentMapID == 2070 
                      or CurrentMapID == 241 or CurrentMapID == 203 or CurrentMapID == 204 or CurrentMapID == 205 or CurrentMapID == 241 or CurrentMapID == 244 
                      or CurrentMapID == 245 or CurrentMapID == 201 or CurrentMapID == 95 or CurrentMapID == 122 or CurrentMapID == 217 or CurrentMapID == 226
          
      ns.OutlandIDs = CurrentMapID == 100 or CurrentMapID == 102 or CurrentMapID == 104 or CurrentMapID == 105 or CurrentMapID == 107 or CurrentMapID == 108
                      or CurrentMapID == 109
          
      ns.NorthrendIDs = CurrentMapID == 114 or CurrentMapID == 115 or CurrentMapID == 116 or CurrentMapID == 117 or CurrentMapID == 118 or CurrentMapID == 119
                      or CurrentMapID == 120 or CurrentMapID == 121 or CurrentMapID == 123 or CurrentMapID == 127 or CurrentMapID == 170
          
      ns.PandariaIDs = CurrentMapID == 371 or CurrentMapID == 376 or CurrentMapID == 379 or CurrentMapID == 388 or CurrentMapID == 390 or CurrentMapID == 418
                      or CurrentMapID == 422 or CurrentMapID == 433 or CurrentMapID == 434 or CurrentMapID == 504 or CurrentMapID == 554 or CurrentMapID == 1530
                      or CurrentMapID == 507
          
      ns.DraenorIDs = CurrentMapID == 525 or CurrentMapID == 534 or CurrentMapID == 535 or CurrentMapID == 539 or CurrentMapID == 542 or CurrentMapID == 543
                      or CurrentMapID == 550 or CurrentMapID == 588
          
      ns.BrokenIslesIDs = CurrentMapID == 630 or CurrentMapID == 634 or CurrentMapID == 641 or CurrentMapID == 646 or CurrentMapID == 650 or CurrentMapID == 652
                      or CurrentMapID == 750 or CurrentMapID == 680 or CurrentMapID == 830 or CurrentMapID == 882 or CurrentMapID == 885 or CurrentMapID == 905
                      or CurrentMapID == 941 or CurrentMapID == 790 or CurrentMapID == 971
          
      ns.ZandalarIDs = CurrentMapID == 862 or CurrentMapID == 863 or CurrentMapID == 864 or CurrentMapID == 1355 or CurrentMapID == 1528
          
      ns.KulTirasIDs = CurrentMapID == 895 or CurrentMapID == 896 or CurrentMapID == 942 or CurrentMapID == 1462 or CurrentMapID == 1169
          
      ns.ShadowlandIDs = CurrentMapID == 1525 or CurrentMapID == 1533 or CurrentMapID == 1536 or CurrentMapID == 1543 or CurrentMapID == 1565 or CurrentMapID == 1816
                      or CurrentMapID == 1961 or CurrentMapID == 1970 or CurrentMapID == 2016
          
      ns.DragonIsleIDs = CurrentMapID == 2022 or CurrentMapID == 2023 or CurrentMapID == 2024 or CurrentMapID == 2025 or CurrentMapID == 2026 or CurrentMapID == 2133
                      or CurrentMapID == 2151 or CurrentMapID == 2200 or CurrentMapID == 2239
          
      ns.KhazAlgar = CurrentMapID == 2248 or CurrentMapID == 2214 or CurrentMapID == 2215 or CurrentMapID == 2255 or  CurrentMapID == 2256 or CurrentMapID == 2213 
                      or CurrentMapID == 2216 or CurrentMapID == 2369 or CurrentMapID == 2346 or CurrentMapID == 2371 or CurrentMapID == 2472

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

      -- Special mapIDs that are actually zones/subzones but are considered dungeons/microdungeons by the game are hereby correctly recognized as zones in the addon (no capitals)
      ns.ZoneIDs = CurrentMapID == 750 or CurrentMapID == 652 or CurrentMapID == 2266 or CurrentMapID == 2322

      if value.name == nil then value.name = value.id or value.mnID end

      local nameForSplit = value.name
      if type(nameForSplit) ~= "string" or nameForSplit == "" then
        nameForSplit = tostring(value.id or value.mnID or "")
      end
      local instances = (nameForSplit ~= "" and { strsplit("\n", nameForSplit) } or {})

			for i, v in pairs(instances) do
				if not extraInformations[v] then
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
			end

      -- MiniMap Instance World
      if ns.instanceIcons and value.showOnMinimap then
        scale = db.MiniMapInstanceScale
        alpha = db.MiniMapInstanceAlpha
      end

      -- MiniMap Transport (Zeppeline/Ship/Carriage) icons
      if not ns.CapitalMiniMapIDs and ns.transportIcons and value.showOnMinimap then
        scale = db.MiniMapTransportScale
        alpha = db.MiniMapTransportAlpha
      end

      -- Profession Minimap icons in Zone
      if not ns.CapitalMiniMapIDs and ns.professionIcons and value.showOnMinimap then
        scale = db.MiniMapProfessionsScale
        alpha = db.MiniMapProfessionsAlpha
      end

      -- MiniMap General icons
      if not ns.CapitalMiniMapIDs and ns.generalIcons and value.showOnMinimap or ns.ZoneIDs and not value.showInZone then
        scale = db.MiniMapGeneralScale
        alpha = db.MiniMapGeneralAlpha
      end

      -- MiniMap single icon scale / alpha
      if not ns.CapitalMiniMapIDs or ns.ZoneIDs and value.showOnMinimap  then

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

        if value.type == "PetBattleDungeon" then
          scale = db.MiniMapScalePetBattleDungeons
          alpha = db.MiniMapAlphaPetBattleDungeons
        end

        -- Transport Icons
        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "HPortalGray" 
          or value.type == "APortalGray" or value.type == "HPortalSGray" or value.type == "APortalSGray" or value.type == "PassageHPortal" or value.type == "PassageAPortal" or value.type == "WayGateGolden" or value.type == "WayGateGreen" 
          or value.type == "DarkMoon" or value.type == "TorghastUp" or value.type == "PortalPetBattleDungeon" or value.type == "PortalHPetBattleDungeon" or value.type == "PortalAPetBattleDungeon" 
        then
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

        if value.type == "RenownQuartermaster" or value.type == "MMRenownQuartermasterH" or value.type == "MMRenownQuartermasterA" then
          scale = db.MiniMapScaleRenownQuartermaster
          alpha = db.MiniMapAlphaRenownQuartermaster
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

        if ns.pathIcons or ns.ZoneIDs and not value.showInZone and not CurrentMapID == 2322 then
          scale = db.MiniMapScalePaths
          alpha = db.MiniMapAlphaPaths
        end

      end

      -- inside Dungeon
      if (mapInfo.mapType == 4 or mapInfo.mapType == 6) and not (ns.CapitalIDs or ns.ClassHallIDs) and not ns.ZoneIDs then
          scale = db.dungeonScale
          alpha = db.dungeonAlpha
      end

      -- Dungeon Single scale / alpha
      if (mapInfo.mapType == 4 or mapInfo.mapType == 6) and not (ns.CapitalIDs or ns.ClassHallIDs) and not ns.ZoneIDs then

        if value.type == "Exit" then
          scale = db.DungeonMapScaleExit
          alpha = db.DungeonMapAlphaExit
        end

        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" 
          or value.type == "HPortalGray" or value.type == "APortalGray" or value.type == "HPortalSGray" or value.type == "APortalSGray" or value.type == "PassageHPortal" 
          or value.type == "PassageAPortal" or value.type == "PortalPetBattleDungeon" or value.type == "PortalHPetBattleDungeon" or value.type == "PortalAPetBattleDungeon" 
        then
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

        if value.type == "PvEVendor" or value.type == "PvPVendor" or value.type == "RenownQuartermaster" or value.type == "RenownQuartermasterH" or value.type == "RenownQuartermasterA" then
          scale = db.DungeonMapScaleVendor
          alpha = db.DungeonMapAlphaVendor
        end

      end


      -- Profession Minimap icons in Capitals
      if ns.professionIcons and ns.CapitalMiniMapIDs and value.showOnMinimap then
        scale = db.MinimapCapitalsProfessionsScale
        alpha = db.MinimapCapitalsProfessionsAlpha
      end

      -- Capitals Minimap Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalMiniMapIDs and ns.transportIcons and value.showOnMinimap then
        scale = db.MinimapCapitalsTransportScale
        alpha = db.MinimapCapitalsTransportAlpha
      end

      -- Capitals Minimap Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalMiniMapIDs and ns.instanceIcons and value.showOnMinimap then
        scale = db.MinimapCapitalsInstanceScale
        alpha = db.MinimapCapitalsInstanceAlpha
      end

      -- Capitals Minimap General (Innkeeper/Exit/Passage) icons
      if ns.CapitalMiniMapIDs and ns.generalIcons and value.showOnMinimap then
        scale = db.MinimapCapitalsGeneralScale
        alpha = db.MinimapCapitalsGeneralAlpha
      end

      -- Capitals Minimap Class Halls icons
      if (ns.ClassHallIDs and ns.classHallIcons and value.showOnMinimap) or (not ns.CapitalMiniMapIDs and ns.classHallIcons and value.showOnMinimap) then
        scale = db.MinimapCapitalsClassHallScale
        alpha = db.MinimapCapitalsClassHallAlpha
      end

      -- Instance icons World
      if ns.instanceIcons and not value.showOnMinimap then
        scale = db.ZoneInstanceScale
        alpha = db.ZoneInstanceAlpha
      end

      -- Zone Transport icons
      if not (ns.CapitalIDs or ns.ClassHallIDs) and ns.transportIcons and value.showOnMinimap == false then
        scale = db.ZoneTransportScale
        alpha = db.ZoneTransportAlpha
      end

      -- Zone Profession icons 
      if not (ns.CapitalIDs or ns.ClassHallIDs) and ns.professionIcons and value.showOnMinimap == false then
        scale = db.ZoneProfessionsScale
        alpha = db.ZoneProfessionsAlpha
      end

      -- Zones General icons
      if not (ns.CapitalIDs or ns.ClassHallIDs) and ns.generalIcons and value.showOnMinimap == false then
        scale = db.ZoneGeneralScale
        alpha = db.ZoneGeneralAlpha
      end

      -- Zone single icon scale / alpha
      if not (ns.CapitalIDs or ns.ClassHallIDs) and value.showOnMinimap == false then

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

        if value.type == "PetBattleDungeon" then
          scale = db.ZoneScalePetBattleDungeons
          alpha = db.ZoneAlphaPetBattleDungeons
        end

        -- Transport Icons
        if value.type == "Portal" or value.type == "PortalS" or value.type == "HPortal" or value.type == "APortal" or value.type == "HPortalS" or value.type == "APortalS" or value.type == "HPortalGray" or value.type == "APortalGray" 
          or value.type == "HPortalSGray" or value.type == "APortalSGray" or value.type == "PassageHPortal" or value.type == "PassageAPortal" or value.type == "WayGateGolden" or value.type == "WayGateGreen" or value.type == "TorghastUp" 
          or value.type == "PortalPetBattleDungeon" or value.type == "PortalHPetBattleDungeon" or value.type == "PortalAPetBattleDungeon" 
        then
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

        if value.type == "RenownQuartermaster" or value.type == "ZoneRenownQuartermasterH" or value.type == "ZoneRenownQuartermasterA" then
          scale = db.ZoneScaleRenownQuartermaster
          alpha = db.ZoneAlphaRenownQuartermaster
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
      if ns.CapitalIDs and ns.professionIcons and value.showOnMinimap == false then
        scale = db.CapitalsProfessionsScale
        alpha = db.CapitalsProfessionsAlpha
      end

      -- Capitals General (Innkeeper/Exit/Passage) icons
      if ns.CapitalIDs and ns.generalIcons and value.showOnMinimap == false then
        scale = db.CapitalsGeneralScale
        alpha = db.CapitalsGeneralAlpha
      end

      -- Capitals Class Halls icons
      if (ns.ClassHallIDs and ns.classHallIcons and value.showOnMinimap == false ) or (not (ns.CapitalIDs or ns.ClassHallIDs) and ns.classHallIcons and value.showOnMinimap == false) then
        scale = db.CapitalsClassHallScale
        alpha = db.CapitalsClassHallAlpha
      end

      -- Capitals Transport (Zeppeline/Ship/Carriage) icons
      if ns.CapitalIDs and ns.transportIcons and value.showOnMinimap == false then
        scale = db.CapitalsTransportScale
        alpha = db.CapitalsTransportAlpha
      end

      -- Capitals Instance (Dungeon/Raid/Passage/Multi) icons
      if ns.CapitalIDs and ns.instanceIcons and value.showOnMinimap == false then
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

      if (value.type == "PassageElevatorDown" or value.type == "PassageElevatorUp") and value.showInZone and (mapInfo.mapType == 3 or mapInfo.mapType == 5) then -- zone fixed value for PassageElevator Up & Down!
        scale = 2
        alpha = 1
      end

      if (value.type == "Delves" or value.type == "DelvesPassage") and value.showInZone and (mapInfo.mapType == 3 or mapInfo.mapType == 5) then -- zone fixed value for delves!
        scale = 2
        alpha = 1
      end

      if (value.type == "Delves" or value.type == "DelvesPassage") and value.showOnMinimap then -- minimap fixed value for delves!
        scale = 1.5
        alpha = 1
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
        or (not (ns.CapitalIDs or ns.ClassHallIDs) and (mapInfo.mapType == 4 or mapInfo.mapType == 6) and (ns.dbChar.DungeonDeletedIcons[t.uiMapId] and not ns.dbChar.DungeonDeletedIcons[t.uiMapId][state])) -- Dungeon
        or (not (ns.CapitalIDs or ns.ClassHallIDs) and (ns.dbChar.ZoneDeletedIcons[t.uiMapId] and not ns.dbChar.ZoneDeletedIcons[t.uiMapId][state] and value.showInZone) and (mapInfo.mapType == 3 or mapInfo.mapType == 5 )) -- Zone without Capitals
        or ((ns.CapitalIDs or ns.ClassHallIDs) and (ns.dbChar.CapitalsDeletedIcons[t.uiMapId] and not ns.dbChar.CapitalsDeletedIcons[t.uiMapId][state] and value.showInZone)) -- Capitals
        or ((ns.CapitalIDs or ns.ClassHallIDs) and ns.dbChar.MinimapCapitalsDeletedIcons[t.minimapId] and not ns.dbChar.MinimapCapitalsDeletedIcons[t.minimapId][state] and value.showOnMinimap) -- Minimap Capitals
        or (not (ns.CapitalIDs or ns.ClassHallIDs) and (mapInfo.mapType == 3 or mapInfo.mapType == 5) and ns.dbChar.MinimapZoneDeletedIcons[t.minimapId] and not ns.dbChar.MinimapZoneDeletedIcons[t.minimapId][state] and value.showOnMinimap) -- Minimap Zones
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
          local alpha = db.continentAlpha
          local scale = db.continentScale
          local icon = ns.icons[value.type]
          local mapInfo = C_Map.GetMapInfo(WorldMapFrame:GetMapID())

					local allLocked = true
					local anyLocked = false
          
					local nameForSplit = value.name
          if type(nameForSplit) ~= "string" or nameForSplit == "" then
            nameForSplit = tostring(value.id or value.mnID or "")
          end

          local instances = (nameForSplit ~= "" and { strsplit("\n", nameForSplit) } or {})
					for i, v in pairs(instances) do
						if not extraInformations[v] then
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
          end
                  
          if (value.type == "Delves" or value.type == "DelvesPassage") and value.showOnContinent and mapInfo.mapType == 2 then -- continent fixed value for delves!
            scale = 2.1
            alpha = 1
          end
              
          if (mapInfo.mapType == 2 and (ns.dbChar.ContinentDeletedIcons[t.contId] and not ns.dbChar.ContinentDeletedIcons[t.contId][state]) and value.showOnContinent) then -- Continent
            return state, continent, icon, scale, alpha
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
    local npcID_npcIDs1 = dungeon.npcID or dungeon.npcIDs1

    local nodeName = dungeon.name
    if (not nodeName or nodeName == "") and npcID_npcIDs1 then
      local nameFromInfo = ns.GetNpcInfo and select(1, ns.GetNpcInfo(npcID_npcIDs1)) or nil
      nodeName = nameFromInfo or (ns.GetNPCName and ns.GetNPCName(npcID_npcIDs1)) or tostring(npcID_npcIDs1)
    end

    if npcID_npcIDs1 and nodeName and nodeName ~= "" then
      local _, npcTitle = ns.GetNpcInfo and ns.GetNpcInfo(npcID_npcIDs1) or nil, nil
      if not npcTitle and ns.npcNameCache then
        local t = ns.npcNameCache[npcID_npcIDs1]; npcTitle = t and t[2]
      end
      if npcTitle and npcTitle ~= "" and not npcTitle:match("%?%?+") then
        nodeName = nodeName .. "\n" .. "|cffffd200(|r" .. npcTitle .. "|cffffd200)|r"
      end
    end

    local mnIDName = dungeon.mnID and getMNIDName(dungeon.mnID) or nil
    local title
    if mnIDName and mnIDName ~= "" then
      if nodeName and nodeName ~= "" then
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. nodeName .. " " .. mnIDName
      else
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. mnIDName
      end
    elseif npcID_npcIDs1 then
        title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. (nodeName or tostring(npcID_npcIDs1))
    elseif dungeon.dnID and dungeon.dnID ~= "" then
      title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. dungeon.dnID
    elseif dungeon.TransportName and dungeon.TransportName ~= "" then
      title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. dungeon.TransportName .. (nodeName and ("\n" .. nodeName) or "")
    elseif nodeName and nodeName ~= "" then
      title = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. "|cffffd200" .. TARGET .. "|r " .. TextIconMNL4:GetIconString() .. "\n" .. nodeName
    else
      title = " "
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

local function MN_AddWaypointProvider()
  if InCombatLockdown() then return end
  if not WorldMapFrame then return end
  if ns.mnWaypointProviderAdded then return end
  ns.mnWaypointProviderAdded = true
  WorldMapFrame:AddDataProvider(Mixin(CreateFromMixins(MapCanvasDataProviderMixin), BlizzardWaypointProviderMixin))
end

C_Timer.After(0, function()
  if WorldMapFrame then
    WorldMapFrame:HookScript("OnShow", MN_AddWaypointProvider)
  end
end)

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
local CurrentMapID = WorldMapFrame:GetMapID()

  StaticPopupDialogs["Delete_Icon?"] = {
    text = TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. ": " .. L["Delete this icon"] .. " ? " .. TextIconMNL4:GetIconString(),
    button1 = YES,
    button2 = NO,
    showAlert = true,
    exclusive  = true,
    OnAccept = function()
      if ns.CapitalIDs or ns.ClassHallIDs then
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
    
      if not (ns.CapitalIDs or ns.ClassHallIDs) and mapInfo.mapType == 3 then -- Zone
        ns.dbChar.ZoneDeletedIcons[uiMapId][coord] = true
        ns.dbChar.MinimapZoneDeletedIcons[uiMapId][coord] = true
        print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00", L["Zones"] .. " & " .. MINIMAP_LABEL .. " - " .. "|cff00ff00" .. L["A icon has been deleted"])
      end
    
      if not (ns.CapitalIDs or ns.ClassHallIDs) and (mapInfo.mapType == 4 or mapInfo.mapType == 6) then -- Dungeon
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
        if CurrentMapID and CurrentMapID ~= 946 then
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
        if CurrentMapID and CurrentMapID ~= 946 then
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

    if (button == "RightButton" and mnID and not IsShiftKeyDown() and not IsAltKeyDown()) then -- swap right
      ns.MapNotesOpenMap(mnID)
    end

    if (button == "LeftButton" and mnID2 and not IsShiftKeyDown() and not IsAltKeyDown()) then -- swap left
      ns.MapNotesOpenMap(mnID2)
    end
  end

  if not ns.Addon.db.profile.activate.SwapButtons then -- Original
    if ns.Addon.db.profile.WayPointsShift then -- Shift
      if (button == "RightButton" and db.WayPoints and IsShiftKeyDown()) then
        if CurrentMapID and CurrentMapID ~= 946 then
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
        if CurrentMapID and CurrentMapID ~= 946 then
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

    if (button == "LeftButton" and mnID and not IsShiftKeyDown() and not IsAltKeyDown()) then -- original left
      ns.MapNotesOpenMap(mnID)
    end

    if (button == "RightButton" and mnID2 and not IsShiftKeyDown() and not IsAltKeyDown()) then -- original right
      ns.MapNotesOpenMap(mnID2)
    end
  end

  -- npc targeting & rangecheck
  if ns.TryCreateTarget(uiMapId, coord, button) then
    return
  end

  if (button == "RightButton") and IsAltKeyDown() then
    local isCosmic = (mapInfo and mapInfo.mapType == 0) or false -- does not work on comsic map
    if not isCosmic then
      if ns.Addon.db.profile.DeleteIcons then
        StaticPopup_Show("Delete_Icon?")
      end
    end
  end

  if (button == "MiddleButton" and mnID3 and not IsShiftKeyDown() and not IsAltKeyDown()) then -- neutral
    ns.MapNotesOpenMap(mnID3)
  end

  if button == "MiddleButton" and delveID then -- neutral
    ns.MapNotesOpenMap(delveID)
  end

  if (not pressed) then return end

  if (button == "MiddleButton") and leaveDelve and ns.icons["Delves"] then -- neutral
    StaticPopup_Show("Leave_Delve?")
  end

  if (button == "MiddleButton") and not IsShiftKeyDown() then -- create links
    if ns.Addon.db.profile.CreateAndCopyLinks then

    local printed = false

    for i = 1, 10 do -- only wwwlinks without questID
      local wwwLink = nodes[uiMapId][coord]["wwwLinks"..i]
      local questLink = nodes[uiMapId][coord]["questIDs"..i]
      if wwwLink and not questLink then
        print(wwwLink)
        printed = true
      end
    end

    if ns.questID and not ns.IsQuestLearned(ns.questID) then -- single questID
      ns.printQuestWithName(ns.questID, ns.getQuestName(nodes[uiMapId][coord], ns.questID))
      printed = true
    end

    for i = 1, 10 do -- questIDs 1-10
      local questIDs = nodes[uiMapId][coord]["questIDs"..i]
      if questIDs and not ns.IsQuestLearned(questIDs) then
        ns.printQuestWithName(questIDs, ns.getQuestName(nodes[uiMapId][coord], questIDs))
        printed = true
      end
    end

    if ns.achievementID and not ns.IsAchievementCompleted(ns.achievementID) then -- achievementID
      ns.printAchievement(ns.achievementID, nodes[uiMapId][coord].wwwName)
      printed = true
    end

    local wwwLink = nodes[uiMapId][coord].wwwLink or nodes[uiMapId][coord].wwwLink1 -- fallback single wwwlink
    if not printed and wwwLink and not (ns.achievementID or ns.questID) then
      print(wwwLink)
    end

    end

  end

  if ns.Addon.db.profile.activate.SwapButtons then -- New SwapButtons
    if (button == "RightButton" and not IsAltKeyDown()) then
      if mnID then
        ns.MapNotesOpenMap(mnID)
        return
      end
    end

    if (button == "RightButton" and db.journal and not IsAltKeyDown() and not InCombatLockdown()) then

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
        ns.MapNotesOpenMap(mnID)
        return
      end
    end

    if (button == "LeftButton" and db.journal and not IsAltKeyDown() and not InCombatLockdown()) then
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
  local PlayerMapID = C_Map.GetBestMapForUnit("player")
  if PlayerMapID then
    if ns.Addon.db.profile.ZoneTextChanged then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. C_Map.GetMapInfo(PlayerMapID).name .. "  <==")
    end
  end
end

local subzone = GetSubZoneText()
function Addon:ZONE_CHANGED_INDOORS()
    if ns.Addon.db.profile.ZoneTextChanged and ns.Addon.db.profile.ZoneTextChangedDetail and not ns.CapitalMiniMapIDs then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. "|cff00ff00" .. GetZoneText() .. " " .. "|cff00ccff" .. GetSubZoneText().. "|cff00ff00" .. "  <==")
    end
end

function Addon:ZONE_CHANGED()
  local PlayerMapID = C_Map.GetBestMapForUnit("player")
  if PlayerMapID then
    if ns.Addon.db.profile.ZoneTextChanged and ns.Addon.db.profile.ZoneTextChangedDetail and not ns.CapitalMiniMapIDs then
      print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. "|cffffff00" .. " " .. L["Location"] .. ": ", "|cff00ff00" .. "==>  " .. GetZoneText() .. " " .. "|cff00ccff" .. GetSubZoneText() .. "|cff00ff00" .. "  <==")
    end
  end
end

function Addon:OnProfileChanged(event, database, profileKeys)
  db = database.profile
  ns.dbChar = database.profile.deletedIcons
  HandyNotes:GetModule("FogOfWarButton"):SyncColorsFromDB(true)

  ns.ApplySavedCoords() -- RetailCoordsDisplay.lua
  ns.ReloadAreaMapSettings() -- RetailAreaMap.lua
  ns.UpdateMinimapArrow() -- RetailMiniMap.lua
  ns.ApplyWorldMapArrowSize() -- RetailWorldmap.lua
  ns.EnforceActiveHides() -- RetailBlizzardMiniMapTracking.lua

  if ns.SetAreaMapMenuVisibility then -- RetailAreaMap.lua
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end

  if MapNotesMiniButton and MapNotesMiniButton.db then  -- Minimapbutton position
    MapNotesMiniButton.db:SetProfile(database:GetCurrentProfile())
    MNMMBIcon:Refresh("MNMiniMapButton", MapNotesMiniButton.db.profile.minimap)
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")
  
  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been changed"])
  end
end

function Addon:OnProfileReset(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  HandyNotes:GetModule("FogOfWarButton"):SyncColorsFromDB(true)

  ns.DefaultPlayerCoords() -- RetailCoordsDisplay.lua
  ns.DefaultMouseCoords() -- RetailCoordsDisplay.lua
  ns.DefaultPlayerAlpha() --RetailCoordsDisplay.lua
  ns.DefaultMouseAlpha() -- RetailCoordsDisplay.lua
  ns.HidePlayerCoordsFrame() -- RetailCoordsDisplay.lua
  ns.HideMouseCoordsFrame() -- RetailCoordsDisplay.lua  
  ns.UpdateAreaMapFogOfWar() -- RetailAreaMap.lua
  ns.ResetAreaMapToPlayerLocation() -- RetailAreaMap.lua
  ns.UpdateMinimapArrow() -- RetailMiniMap.lua
  ns.ApplyWorldMapArrowSize() -- RetailWorldmap.lua
  ns.EnforceActiveHides() -- RetailBlizzardMiniMapTracking.lua

  if ns.SetAreaMapMenuVisibility then -- RetailAreaMap.lua
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end

  wipe(ns.dbChar.CapitalsDeletedIcons)
  wipe(ns.dbChar.MinimapCapitalsDeletedIcons)
  wipe(ns.dbChar.AzerothDeletedIcons)
  wipe(ns.dbChar.ContinentDeletedIcons)
  wipe(ns.dbChar.ZoneDeletedIcons)
  wipe(ns.dbChar.MinimapZoneDeletedIcons)
  wipe(ns.dbChar.DungeonDeletedIcons)

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")

  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been reset to default"])
  end
end

function Addon:OnProfileCopied(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  HandyNotes:GetModule("FogOfWarButton"):SyncColorsFromDB(true)

  ns.ApplySavedCoords() -- RetailCoordsDisplay.lua
  ns.ReloadAreaMapSettings() -- RetailAreaMap.lua
  ns.UpdateMinimapArrow() -- RetailMiniMap.lua
  ns.ApplyWorldMapArrowSize() -- RetailWorldmap.lua
  ns.EnforceActiveHides() -- RetailBlizzardMiniMapTracking.lua

  if ns.SetAreaMapMenuVisibility then -- RetailAreaMap.lua
    ns.SetAreaMapMenuVisibility(ns.Addon.db.profile.areaMap.showAreaMapDropDownMenu)
  end

  if MapNotesMiniButton and MapNotesMiniButton.db then -- Minimapbutton position
    MapNotesMiniButton.db:SetProfile(database:GetCurrentProfile())
    MapNotesMiniButton.db.profile.minimap = MapNotesMiniButton.db.profile.minimap or {}

    if MapNotesMiniButton.db.profiles and MapNotesMiniButton.db.profiles[profileKeys] and MapNotesMiniButton.db.profiles[profileKeys].minimap then
      for k, v in pairs(MapNotesMiniButton.db.profiles and MapNotesMiniButton.db.profiles[profileKeys] and MapNotesMiniButton.db.profiles[profileKeys].minimap) do
        MapNotesMiniButton.db.profile.minimap[k] = v
      end
    end

    MNMMBIcon:Refresh("MNMiniMapButton", MapNotesMiniButton.db.profile.minimap)
  end

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")

  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been adopted"])
  end
end

function Addon:OnProfileDeleted(event, database, profileKeys)
	db = database.profile
  ns.dbChar = database.profile.deletedIcons
  HandyNotes:GetModule("FogOfWarButton"):SyncColorsFromDB(true)

  ns.Addon:FullUpdate()
  HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "MapNotes")

  if ns.Addon.db.profile.CoreChatMassage then
    print(TextIconMNL4:GetIconString() .. " " .. ns.COLORED_ADDON_NAME .. " " .. TextIconMNL4:GetIconString() .. " " .. "|cffffff00" .. L["Profile has been deleted"])
  end
end

function Addon:PLAYER_ENTERING_WORLD()
  if not self.faction then
      self.faction = UnitFactionGroup("player")
      self:PopulateTable()
      self:PopulateMinimap()
      self:ProcessTable()
  end
  if not self.raceFile then
      local _, raceFile = UnitRace("player")
      self.raceFile = raceFile
      self:PopulateTable()
      self:PopulateMinimap()
      self:ProcessTable()
  end
    updateextraInformation()
    updateStuff()
end

function Addon:PLAYER_LOGIN() -- OnInitialize()
  ns.Addon = Addon
  ns.LoadOptions(self) -- RetailOptions.lua
  ns.BlizzardDelvesAddTT() -- RetailDelves.lua
  ns.BlizzardDelvesAddFunction() -- RetailDelves.lua
  ns.ChangingMapToPlayerZone() -- RetailWorldMap.lua

   C_Timer.After(0, MN_AddWaypointProvider)

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
  HandyNotes:GetModule("FogOfWarButton"):SyncColorsFromDB(true)

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

  -- UseInBattle
  ns.SyncUseInBattleFromDB() -- RetailErrorMessage.lua

  -- Check for PlayerArrow on Minimap
  ns.MiniMapPlayerArrow() -- RetailMiniMap.lua

  -- Check for Links
  ns.CreateAndCopyLink() -- RetailCreateLinks.lua

  -- Check for Class
  ns.AutomaticClassDetectionCapital() -- ClassesDetection.lua

  -- Check for Professions
  ns.AutomaticProfessionDetection() -- ProfessionDetection.lua

  -- Remove& Refresh BlizzardPOIs (ns.BlizzAreaPoisInfo) and ZidormiPOIs (ns.BlizzAreaPoisInfoZidormi)
  ns.RemovePOIs() -- RetailPOIs.lua

  -- Check if Blizz Instance entrances is true then remove Blizzard Pins
  if ns.Addon.db.profile.activate.RemoveBlizzInstances then
    SetCVar("showDungeonEntrancesOnMap", 0)
  elseif not ns.Addon.db.profile.activate.RemoveBlizzInstances then
    SetCVar("showDungeonEntrancesOnMap", 1)
  end

  -- Check if Blizz Delves entrances is true then remove Blizzard Pins
  if ns.Addon.db.profile.activate.HideBlizzDelves then
    SetCVar("showDelveEntrancesOnMap", 0)
  elseif not ns.Addon.db.profile.activate.HideBlizzDelves then
    SetCVar("showDelveEntrancesOnMap", 1)
  end

  if ns.Addon.db.profile.activate.HideMMB then -- minimap button
    MNMMBIcon:Hide("MNMiniMapButton")
  end

  -- Register Worldmapbutton
  ns.WorldMapButton = LibStub("Krowi_WorldMapButtons-1.4"):Add(ADDON_NAME .. "WorldMapOptionsButtonTemplate", "BUTTON")
  if ns.Addon.db.profile.activate.HideWMB
    then ns.WorldMapButton:Hide()
    else ns.WorldMapButton:Show()
  end

  if ns.DevMode() then
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

  ns.SyncWithMinimap(self) -- syncWithMinimap.lua - sync Capitals with Capitals - Minimap and/or Zones with Minimap

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

  LoadAndCheck(ns.LoadCapitalsLocationinfo,self) -- load nodes\Retail\RetailCapitals.lua
  LoadAndCheck(ns.LoadMinimapCapitalsLocationinfo,self) -- load nodes\Retail\RetailMinimapCapitals.lua

  LoadAndCheck(ns.LoadClassHallZoneLocationinfo,self) -- load nodes\Retail\RetailClassHallZone.lua
  LoadAndCheck(ns.LoadClassHallMiniMapLocationinfo,self) -- load nodes\Retail\RetailClassHallMiniMap.lua

  LoadAndCheck(ns.LoadSpecialLocations,self) -- load nodes\Retail\RetailSpecialLocations.lua  

  LoadAndCheck(ns.LoadInsideDungeonNodesLocationInfo,self) -- load nodes\Retail\RetailInsideDungeonNodesLocation.lua

  LoadAndCheck(ns.LoadTaxiMapNodesLocationinfo,self) -- load nodes\Retail\RetailTaxiMapNodes.lua

  LoadAndCheck(ns.LoadWorldNodesLocationInfo, self) -- load nodes\Retail\RetailWorldNodesLocation.lua
end

function Addon:UpdateInstanceNames(node)
  local dungeonInfo = EJ_GetInstanceInfo
  local id = node.id

  if type(id) == "table" then
    local nameList = {}
    for _, v in ipairs(id) do
      local name = dungeonInfo(v)
      if not name or name == "" then name = "..." end
      table.insert(nameList, name)
    end

    if node.name then
      node.name = node.name .. "\n" .. table.concat(nameList, "\n")
    else
      node.name = table.concat(nameList, "\n")
    end

  elseif id then
    node.name = dungeonInfo(id)
  end
end


function Addon:ProcessTable()

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