--[[
Things to do
 Lump close dungeon/raids into one, (nexus/oculus/eoe) (DONE)
 Maybe implement lockout info on tooltip (Don't know if I want too, better addons for tracking it exist) (DONE anyway)
]]--

local DEBUG = false

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_DungeonLocations")

local iconDefault = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS"
--local iconDungeon = "Interface\\Addons\\HandyNotes_DungeonLocations\\dungeon.tga"
--local iconRaid = "Interface\\Addons\\HandyNotes_DungeonLocations\\raid.tga"
local iconDungeon = "Interface\\MINIMAP\\Dungeon"
local iconRaid = "Interface\\MINIMAP\\Raid"
local iconMixed = "Interface\\Addons\\HandyNotes_DungeonLocations\\merged.tga"
local iconGray = "Interface\\Addons\\HandyNotes_DungeonLocations\\gray.tga"

local db
local mapToContinent = { }
local nodes = { }
local minimap = { } -- For nodes that need precise minimap locations but would look wrong on zone or continent maps
local alterName = { }
local extraInfo = { }
local mapLevels = { } -- Bad juju, I use this to hide nodes from appearing on the wrong map levels.  e.g the new Dalaran; definitely probably a better way to do this
local legionInstancesDiscovered = { } -- Extrememly bad juju
--local lockouts = { }

if (DEBUG) then
 HNDL_NODES = nodes
 HNDL_MINIMAP = minimap
 HNDL_ALTERNAME = alterName
 --HNDL_LOCKOUTS = lockouts
 
end

local internalNodes = {  -- List of zones to be excluded from continent map
 ["BlackrockMountain"] = true,
 ["CavernsofTime"] = true,
 ["DeadminesWestfall"] = true,
 ["Dalaran"] = true,
 ["MaraudonOutside"] = true,
 ["NewTinkertownStart"] = true,
 ["ScarletMonasteryEntrance"] = true,
 ["WailingCavernsBarrens"] = true,
}

local continents = {
	["Azeroth"] = true, -- Eastern Kingdoms
	["Draenor"] = true,
	["Expansion01"] = true, -- Outland
	["Kalimdor"] = true,
	["Northrend"] = true,
	["Pandaria"] = true,
 ["BrokenIsles"] = true,
}

local LOCKOUTS = { }
local function updateLockouts()
 table.wipe(LOCKOUTS)
 for i=1,GetNumSavedInstances() do
  local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
  if (locked) then
   --print(name, difficultyName, numEncounters, encounterProgress)
   if (not LOCKOUTS[name]) then
    LOCKOUTS[name] = { }
   end
   LOCKOUTS[name][difficultyName] = encounterProgress .. "/" .. numEncounters
  end
 end
end

local pluginHandler = { }
function pluginHandler:OnEnter(mapFile, coord) -- Copied from handynotes
 --GameTooltip:AddLine("text" [, r [, g [, b [, wrap]]]])
 -- Maybe check for situations where minimap and node coord overlaps
    local nodeData = nil
	
    --if (not nodes[mapFile][coord]) then return end
	if (minimap[mapFile] and minimap[mapFile][coord]) then
	 nodeData = minimap[mapFile][coord]
	end
	if (nodes[mapFile] and nodes[mapFile][coord]) then
	 nodeData = nodes[mapFile][coord]
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
	

	updateLockouts()
	
	for i, v in pairs(instances) do
	 --print(i, v)
	 if (db.lockouts and (LOCKOUTS[v] or (alterName[v] and LOCKOUTS[alterName[v]]))) then
 	  if (LOCKOUTS[v]) then
	   --print("Dungeon/Raid is locked")
	   for a,b in pairs(LOCKOUTS[v]) do
		--tooltip:AddLine(v .. ": " .. a .. " " .. b, nil, nil, nil, false)
		tooltip:AddDoubleLine(v, a .. " " .. b, 1, 1, 1, 1, 1, 1)
 	   end
	  end
	  if (alterName[v] and LOCKOUTS[alterName[v]]) then
	   for a,b in pairs(LOCKOUTS[alterName[v]]) do
		--tooltip:AddLine(v .. ": " .. a .. " " .. b, nil, nil, nil, false)
		tooltip:AddDoubleLine(v, a .. " " .. b, 1, 1, 1, 1, 1, 1)
 	   end
	  end
	 else
	  tooltip:AddLine(v, nil, nil, nil, false)
	 end
	end
	tooltip:Show()
end

function pluginHandler:OnLeave(mapFile, coord)
 if self:GetParent() == WorldMapButton then
  WorldMapTooltip:Hide()
 else
  GameTooltip:Hide()
 end
end

do
 local scale, alpha = 1, 1
 local function iter(t, prestate)
  if not t then return nil end
		
  local state, value = next(t, prestate)
  while state do
   if (db.show[value.type]) then -- Only show types that are set to be shown in the options
	local icon
    if (value.type == "Dungeon") then
     icon = iconDungeon
    elseif (value.type == "Raid") then
     icon = iconRaid
    elseif (value.type == "Mixed") then
     icon = iconMixed
    else
     icon = iconDefault
    end
  
    local allLocked = true
    local anyLocked = false
    local instances = { strsplit("\n", value.name) }
    for i, v in pairs(instances) do
     if (not LOCKOUTS[v] and not LOCKOUTS[alterName[v]]) then
 	 allLocked = false
     else
	  anyLocked = true
	 end
    end
  
    -- I feel like this inverted lockout thing could be done far better
    if ((anyLocked and db.invertlockout) or (allLocked and not db.invertlockout) and db.lockoutgray) then   
     icon = iconGray
    end
    if ((anyLocked and db.invertlockout) or (allLocked and not db.invertlockout) and db.uselockoutalpha) then
     alpha = db.lockoutalpha
    else
     alpha = isContinent and db.continentAlpha or db.zoneAlpha
    end
		
    return state, nil, icon, scale, alpha
   end
  state, value = next(t, state)
  end 
 end
 function pluginHandler:GetNodes(mapFile, isMinimapUpdate, mapLevel)
  if (DEBUG) then
   print(mapFile, mapLevel, isMinimapUpdate)
   if (mapLevels[mapFile]) then
    for k, v in pairs(mapLevels[mapFile]) do
     print(k, v)
    end
   end
  end
  if (mapLevels[mapFile] and not mapLevels[mapFile][mapLevel]) then -- I put this here to stop nodes from showing up on other maplevels for certain zones e.g the new Dalaran
   return iter
  end
  local isContinent = continents[mapFile]
  scale = isContinent and db.continentScale or db.zoneScale
  alpha = isContinent and db.continentAlpha or db.zoneAlpha
  
  if (isMinimapUpdate and minimap[mapFile]) then
   return iter, minimap[mapFile]
  end
  if (isContinent and not db.continent) then
   return iter
  else
   return iter, nodes[mapFile]
  end
 end
end

local waypoints = {}
local function setWaypoint(mapFile, coord)
	local dungeon = nodes[mapFile][coord]

	local waypoint = nodes[dungeon]
	if waypoint and TomTom:IsValidWaypoint(waypoint) then
		return
	end

	local title = dungeon.name
	local zone = HandyNotes:GetMapFiletoMapID(mapFile)
	local x, y = HandyNotes:getXY(coord)
	waypoints[dungeon] = TomTom:AddMFWaypoint(zone, nil, x, y, {
		title = dungeon.name,
		persistent = nil,
		minimap = true,
		world = true
	})
end

function pluginHandler:OnClick(button, pressed, mapFile, coord)
 if (not pressed) then return end
 if (button == "RightButton" and db.tomtom and TomTom) then
  setWaypoint(mapFile, coord)
  return
 end
 if (button == "LeftButton" and db.journal) then
  if (not EncounterJournal_OpenJournal) then
   UIParentLoadAddOn('Blizzard_EncounterJournal')
  end
  local dungeonID
  if (type(nodes[mapFile][coord].id) == "table") then
   dungeonID = nodes[mapFile][coord].id[1]
  else
   dungeonID = nodes[mapFile][coord].id
  end
  if (not dungeonID) then return end
  local name, _, _, _, _, _, _, link = EJ_GetInstanceInfo(dungeonID)
  local difficulty = string.match(link, 'journal:.-:.-:(.-)|h') 
  if (not dungeonID or not difficulty) then return end
  EncounterJournal_OpenJournal(difficulty, dungeonID)
 end
end

local defaults = {
 profile = {
  zoneScale = 3,
  zoneAlpha = 1,
  continentScale = 3,
  continentAlpha = 1,
  continent = true,
  tomtom = true,
  journal = true,
  lockouts = true,
  lockoutgray = true,
  uselockoutalpha = false,
  lockoutalpha = 1,
  invertlockout = false,
  hideVanilla = false,
  hideOutland = false,
  hideNorthrend = false,
  hideCata = false,
  hidePandaria = false,
  hideDraenor = false,
  hideBrokenIsles = false,
  show = {
   Dungeon = true,
   Raid = true,
   Mixed = true,
  },
 },
}

local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

local function updateStuff()
 updateLockouts()
 HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations")
end

function Addon:PLAYER_ENTERING_WORLD()
 --print("PLAYER_ENTERING_WORLD Fired!")
 self:CheckForPOIs()
 updateStuff()
end

function Addon:UPDATE_INSTANCE_INFO()
 self:CheckForPOIs()
 updateStuff()
end

function Addon:PLAYER_LOGIN()
 local options = {
 type = "group",
 name = "DungeonLocations",
 desc = "Locations of dungeon and raid entrances.",
 get = function(info) return db[info[#info]] end,
 set = function(info, v) db[info[#info]] = v HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
 args = {
  desc = {
   name = L["These settings control the look and feel of the icon."],
   type = "description",
   order = 0,
  },
  zoneScale = {
   type = "range",
   name = L["Zone Scale"],
   desc = L["The scale of the icons shown on the zone map"],
   min = 0.2, max = 12, step = 0.1,
   order = 10,
  },
  zoneAlpha = {
   type = "range",
   name = L["Zone Alpha"],
   desc = L["The alpha of the icons shown on the zone map"],
   min = 0, max = 1, step = 0.01,
   order = 20,
  },
  continentScale = {
   type = "range",
   name = L["Continent Scale"],
   desc = L["The scale of the icons shown on the continent map"],
   min = 0.2, max = 12, step = 0.1,
   order = 10,
  },
  continentAlpha = {
   type = "range",
   name = L["Continent Alpha"],
   desc = L["The alpha of the icons shown on the continent map"],
   min = 0, max = 1, step = 0.01,
   order = 20,
  },
  continent = {
   type = "toggle",
   name = L["Show on Continent"],
   desc = L["Show icons on continent map"],
   order = 1,
  },
  tomtom = {
   type = "toggle",
   name = L["Enable TomTom integration"],
   desc = L["Allow right click to create waypoints with TomTom"],
   order = 2,
  },
  journal = {
   type = "toggle",
   name = L["Journal Integration"],
   desc = L["Allow left click to open journal to dungeon or raid"],
   order = 2,
  },
  showheader = {
   type = "header",
   name = L["Filter Options"],
   order = 24,
  },
  showDungeons = {
   type = "toggle",
   name = L["Show Dungeons"],
   desc = L["Show dungeon locations on the map"],
   order = 24.1,
   get = function() return db.show["Dungeon"] end,
   set = function(info, v) db.show["Dungeon"] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  showRaids = {
   type = "toggle",
   name = L["Show Raids"],
   desc = L["Show raid locations on the map"],
   order = 24.2,
   get = function() return db.show["Raid"] end,
   set = function(info, v) db.show["Raid"] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  showMixed = {
   type = "toggle",
   name = L["Show Mixed"],
   desc = L["Show mixed (dungeons + raids) locations on the map"],
   order = 24.2,
   get = function() return db.show["Mixed"] end,
   set = function(info, v) db.show["Mixed"] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  lockoutheader = {
   type = "header",
   name = L["Lockout Options"],
   order = 25,
  },
  lockouts = {
   type = "toggle",
   name = L["Lockout Tooltip"],
   desc = L["Show lockout information on tooltips"],
   order = 25.1,
  },
  lockoutgray = {
   type = "toggle",
   name = L["Lockout Gray Icon"],
   desc = L["Use gray icon for dungeons and raids that are locked to any extent"],
   order = 25.11,
  },
  uselockoutalpha = {
   type = "toggle",
   name = L["Use Lockout Alpha"],
   desc = L["Use a different alpha for dungeons and raids that are locked to any extent"],
   order = 25.2,
  },
  lockoutalpha = {
   type = "range",
   name = L["Lockout Alpha"],
   desc = L["The alpha of dungeons and raids that are locked to any extent"],
   min = 0, max = 1, step = 0.01,
   order = 25.3,
  },
  invertlockout = {
   type = "toggle",
   name = L["Invert Lockout"],
   desc = L["Turn mixed icons grey when ANY dungeon or raid listed is locked"],
   order = 25.4,
  },
  hideheader = {
   type = "header",
   name = L["Hide Instances"],
   order = 26,
  },
  hideVanilla = {
   type = "toggle",
   name = L["Hide Vanilla"],
   desc = L["Hide all Vanilla nodes from the map"],
   order = 26.1,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hideOutland = {
   type = "toggle",
   name = L["Hide Outland"],
   desc = L["Hide all Outland nodes from the map"],
   order = 26.2,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hideNorthrend = {
   type = "toggle",
   name = L["Hide Northrend"],
   desc = L["Hide all Northrend nodes from the map"],
   order = 26.3,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hideCata = {
   type = "toggle",
   name = L["Hide Cataclysm"],
   desc = L["Hide all Cataclysm nodes from the map"],
   order = 26.4,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hidePandaria = {
   type = "toggle",
   name = L["Hide Pandaria"],
   desc = L["Hide all Pandaria nodes from the map"],
   order = 26.5,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hideDraenor = {
   type = "toggle",
   name = L["Hide Draenor"],
   desc = L["Hide all Draenor nodes from the map"],
   order = 26.6,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
  hideBrokenIsles = {
   type = "toggle",
   name = L["Hide Broken Isles"],
   desc = L["Hide all Broken Isle nodes from the map"],
   order = 26.7,
   set = function(info, v) db[info[#info]] = v self:FullUpdate() HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
  },
 },
}


 HandyNotes:RegisterPluginDB("DungeonLocations", pluginHandler, options)
 self.db = LibStub("AceDB-3.0"):New("HandyNotes_DungeonLocationsDB", defaults, true)
 db = self.db.profile
 
 self:PopulateTable()
 self:PopulateMinimap()
 self:ProcessTable()
 --self:ProcessExtraInfo()
 
 --name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceInfo([instanceID])
 -- Populate Dungeon/Raid names based on Journal
 
 updateLockouts()
 Addon:RegisterEvent("PLAYER_ENTERING_WORLD") -- Check for any lockout changes when we zone
 Addon:RegisterEvent("UPDATE_INSTANCE_INFO")
 --Addon:RegisterEvent("WORLD_MAP_UPDATE") -- For the mess that is the legion stuff I've done
end

-- I only put a few specific nodes on the minimap, so if the minimap is used in a zone then I need to add all zone nodes to it except for the specific ones
-- This could also probably be done better maybe
-- Looks like this function used to rely on the map id, changed so it doesn't error but needs further testing
function Addon:PopulateMinimap() -- This use to ignore duplicate dungeon's but now it doesn't
 local temp = { }
 for k,v in pairs(nodes) do
  if (minimap[k]) then
   for a,b in pairs(minimap[k]) do -- Looks at the nodes we already have on the minimap and marks them down in a temp table
	temp[a] = true
   end
   for c,d in pairs(v) do -- Looks at the nodes in the normal node table and if they are also not in the temp table then add them to the minimap
    if (not temp[c] and not d.hideOnMinimap) then
	 minimap[k][c] = d
	end
   end
  end
 end
end

function Addon:PopulateTable()
table.wipe(nodes)
table.wipe(minimap)

-- [COORD] = { Dungeonname/ID, Type(Dungeon/Raid/Mixed), hideOnContinent(Bool), LFGDungeonID if Applicable, nil placeholder for id later, other dungeons }
-- I feel like I should change all this to something like:
-- [COORD] = {
--  name = "Dungeon Name", -- after processing, wouldn't exist before
--  ids = { }, -- Either one id for single or multiple id's in table for merged ones
--  hideOnContinent = true/false
--  hideOnMinimap = true/false, since I've redid some things, the function that puts nodes on the minimap only considers nodes to be the same if the have the same coordinates
--  lfgid = { }, Either one id for single or multiple id's in table; though I don't know if tables gaurantee order
    
-- },
-- VANILLA
if (not self.db.profile.hideVanilla) then
nodes["AhnQirajTheFallenKingdom"] = {
 [59001430] = {
  id = 743,
  type = "Raid",
  hideOnContinent = true
 }, -- Ruins of Ahn'Qiraj Silithus 36509410, World 42308650
 [46800750] = { id = 744,
  type = "Raid",
  hideOnContinent = true
 }, -- Temple of Ahn'Qiraj Silithus 24308730, World 40908570
}
nodes["Ashenvale"] = {
 --[16501100] = { 227,  type = "Dungeon" }, -- Blackfathom Deeps 14101440 May look more accurate
 [14001310] = {
  id = 227,
  type = "Dungeon",
 }, -- Blackfathom Deeps, not at portal but look
}
nodes["Badlands"] = {
 [41801130] = { 
  id = 239,
  type = "Dungeon",
 }, -- Uldaman
}
nodes["Barrens"] = {
[42106660] = {
 id = 240,
 type = "Dungeon",
 }, -- Wailing Caverns
}
nodes["BurningSteppes"] = {
 [20303260] = {
  id = { 66, 228, 229, 559, 741, 742 },
  type = "Mixed", 
  hideOnContinent = true,
 }, -- Blackrock mountain dungeons and raids
 [23202630] = {
  id = 73,
  type = "Raid",
  hideOnContinent = true,
 }, -- Blackwind Descent
}
nodes["DeadwindPass"] = {
 [46907470] = {
  id = 745,
  type = "Raid",
  hideOnContinent = true,
 }, -- Karazhan
 [46707020] = {
  id = 860,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Return to Karazhan
}
nodes["Desolace"] = {
 [29106250] = {
  id = 232,
  type = "Dungeon",
 }, -- Maraudon 29106250 Door at beginning
}
nodes["DunMorogh"] = {
 [29903560] = {
  id = 231,
  type = "Dungeon",
 }, -- Gnomeregan
}
nodes["Dustwallow"] = {
 [52907770] = {
  id = 760,
  type = "Raid",
 }, -- Onyxia's Lair
}
nodes["EasternPlaguelands"] = {
 [27201160] = {
  id = 236,
  lfgid = 40,
  type = "Dungeon",
 }, -- Stratholme World 52902870
 [43401940] = {
  id = 236,
  lfgid = 274,
  type = "Dungeon", -- Stratholme Service Entrance
 },
}
nodes["Feralas"] = {
 [65503530] = {
  id = 230,
  lfgid = 34,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Dire Maul, probably dire maul east
 [60403070] = {
  id = 230,
  lfgid = 36,
  type = "Dungeon",
  hideOnContinent = true,
  hideOnMinimap = true,
 }, -- Dire Maul West (probably) One spot between the two actual entrances
 -- Captial Gardens, 60.3 31.3; 60.4 30.7; 60.3 30.1; 429
 -- North Maybe?, 62.5 24.9; 
 [62502490] = {
  id = 230,
  lfgid = 38,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Dire Maul, probaly dire maul north
}
nodes["Orgrimmar"] = {
 [52405800] = {
  id = 226,
  type = "Dungeon",
 }, -- Ragefire Chasm Cleft of Shadow 70104880
}
nodes["SearingGorge"] = {
 [41708580] = {
  id = { 66, 228, 229, 559, 741, 742 },
  type = "Mixed",
  hideOnContinent = true,
 },
 [43508120] = {
  id = 73,
  type = "Raid",
  hideOnContinent = true,
 }, -- Blackwind Descent
}
nodes["Silithus"] = {
 [36208420] = {
  id = 743,
  type = "Raid",
 }, -- Ruins of Ahn'Qiraj
 [23508620] =  {
  id = 744,
  type = "Raid",
 }, -- Temple of Ahn'Qiraj
}
nodes["Silverpine"] = {
 [44806780] = {
  id = 64,
  type = "Dungeon",
 }, -- Shadowfang Keep
}
nodes["SouthernBarrens"] = {
 [40909450] = {
  id = 234,
  type = "Dungeon",
 }, -- Razorfen Kraul
}
nodes["StormwindCity"] = {
 [50406640] = {
  id = 238,
  type = "Dungeon",
 }, -- The Stockade
}
nodes["StranglethornJungle"] = {
 [72203290] = {
  id = 76,
  type = "Dungeon",
 }, -- Zul'Gurub
}
nodes["StranglethornVale"] = { -- Jungle and Cape are subzones of this zone (weird)
 [63402180] = {
  id = 76,
  type = "Dungeon",
 }, -- Zul'Gurub
}
nodes["SwampOfSorrows"] = {
 [69505250] = {
  id = 237,
  type = "Dungeon",
 }, -- The Temple of Atal'hakkar
}
nodes["Tanaris"] = {
 [65604870] = {
  id = { 279, 255, 251, 750, 184, 185, 186, 187 },
  type = "Mixed",
 },
 --[[[61006210] = { "The Culling of Stratholme",
  type = "Dungeon" },  --65604870 May look more accurate and merge all CoT dungeons/raids
 [57006230] = { "The Black Morass",  type = "Dungeon" },
 [54605880] = { 185,  type = "Dungeon" }, -- Well of Eternity
 [55405350] = { "The Escape from Durnholde",  type = "Dungeon" },
 [57004990] = { "The Battle for Mount Hyjal",  type = "Raid" },
 [60905240] = { 184,  type = "Dungeon" }, -- End Time
 [61705190] = { 187,  type = "Raid" }, -- Dragon Soul
 [62705240] = { 186,  type = "Dungeon" }, -- Hour of Twilight Merge END ]]--
 [39202130] = {
  id = 241,
  type = "Dungeon",
 }, -- Zul'Farrak
}
nodes["Tirisfal"] = {
 [85303220] = {
  id = 311,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Scarlet Halls
 [84903060] = {
  id = 316,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Scarlet Monastery
}
nodes["ThousandNeedles"] = {
 [47402360] = {
  id = 233,
  type = "Dungeon",
 }, -- Razorfen Downs
}
nodes["WesternPlaguelands"] = {
 [69007290] = {
  id = 246,
  type = "Dungeon",
 }, -- Scholomance World 50903650
}
nodes["Westfall"] = {
 --[38307750] = { 63,  type = "Dungeon" }, -- Deadmines 43707320  May look more accurate
 [43107390] = {
  id = 63,
  type = "Dungeon",
 }, -- Deadmines
}

-- Vanilla Continent, For things that should be shown or merged only at the continent level
 nodes["Azeroth"] = {
  [46603050] = {
   id = { 311, 316 },
   type = "Dungeon",
  }, -- Scarlet Halls/Monastery
  [47316942] = {
   id = { 66, 73, 228, 229, 559, 741, 742 },
   type = "Mixed",
  }, -- Blackrock mount instances, merged in blackwind descent at continent level
  --[38307750] = { 63,  type = "Dungeon" }, -- Deadmines 43707320,
  [49508190] = {
   id = { 745, 860 }, 
   type = "Mixed",
  }, -- Karazhan/Return to Karazhan
 }
 nodes["Kalimdor"] = {
  [44006850] = {
   id = 230,
   type = "Dungeon"
  }, -- Dire Maul
 }
 minimap["Feralas"] = {
  [65503530] = {
   id = 230,
   lfgid = 34,
   type = "Dungeon",
   hideOnContinent = true,
  }, -- Dire Maul - Warpwood Quarter
  [62502490] = {
   id = 230,
   lfgid = 38,
   type = "Dungeon",
   hideOnContinent = true,
  }, -- Dire Maul, probaly dire maul north
  [60303130] = {
   id = 230,
   lfgid = 36,
   type = "Dungeon",
   hideOnContinent = true,
  }, -- Dire Maul, probably dire maul west, two entrances to same dungeon
  [60303010] = {
   id = 230,
   lfgid = 36,
   type = "Dungeon",
   hideOnContinent = true,
  }, -- Dire Maul, probably dire maul west
 }

-- Vanilla Subzone maps
nodes["BlackrockMountain"] = {
 [71305340] = {
  id = 66,
  type = "Dungeon",
 }, -- Blackrock Caverns
 [38701880] = {
  id = 228,
  type = "Dungeon",
 }, -- Blackrock Depths
 [80504080] = {
  id = 229,
 type = "Dungeon",
 }, -- Lower Blackrock Spire
 [79003350] = {
  id = 559,
  type = "Dungeon",
 }, -- Upper Blackrock Spire
 [54208330] = {
  id = 741,
  type = "Raid",
 }, -- Molten Core
 [64207110] = {
  id = 742,
  type = "Raid",
 }, -- Blackwing Lair
}
nodes["CavernsofTime"] = {
 [57608260] = {
  id = 279,
  type = "Dungeon",
 }, -- The Culling of Stratholme
 [36008400] = {
  id = 255,
  type = "Dungeon",
 }, -- The Black Morass
 [26703540] = {
  id = 251,
  type = "Dungeon",
 }, -- Old Hillsbrad Foothills
 [35601540] = {
  id = 750,
  type = "Raid",
 }, -- The Battle for Mount Hyjal
 [57302920] = {
  id = 184,
  type = "Dungeon",
 }, -- End Time
 [22406430] = {
  id = 185,
  type = "Dungeon",
 }, -- Well of Eternity
 [67202930] = {
  id = 186,
  type = "Dungeon",
 }, -- Hour of Twilight
 [61702640] = {
  id = 187,
  type = "Raid",
 }, -- Dragon Soul
}
nodes["DeadminesWestfall"] = {
 [25505090] = {
  id = 63,
  type = "Dungeon",
 }, -- Deadmines
}
nodes["MaraudonOutside"] = {
 [52102390] = {
  id = 232,
  lfgid = 272,
  type = "Dungeon"
 }, -- Maraudon 30205450 
 [78605600] = {
  id = 232,
  lfgid = 26,
  type = "Dungeon",
 }, -- Maraudon 36006430
 [44307680] = {
  id = 232,
  lfgid = 273,
  type = "Dungeon",
 },  -- Maraudon
}
nodes["NewTinkertownStart"] = {
 [31703450] = {
  id = 231,
  type = "Dungeon",
 }, -- Gnomeregan
}
nodes["ScarletMonasteryEntrance"] = { -- Internal Zone
 [68802420] = {
  id = 316,
  type = "Dungeon",
 }, -- Scarlet Monastery
 [78905920] = {
  id = 311,
  type = "Dungeon",
 }, -- Scarlet Halls
}
nodes["WailingCavernsBarrens"] = {
 [55106640] = {
  id = 240,
  type = "Dungeon",
 }, -- Wailing Caverns
}
end

-- OUTLAND
if (not self.db.profile.hideOutland) then
nodes["BladesEdgeMountains"] = {
 [69302370] = {
  id = 746,
  type = "Raid",
 }, -- Gruul's Lair World 45301950
}
nodes["Ghostlands"] = {
 [85206430] = {
  id = 77,
  type = "Dungeon",
 }, -- Zul'Aman World 58302480
}
nodes["Hellfire"] = {
 --[47505210] = { 747,type = "Raid" }, -- Magtheridon's Lair World 56705270
 --[47605360] = { 248,  type = "Dungeon" }, -- Hellfire Ramparts World 56805310 Stone 48405240 World 57005280
 --[47505200] = { 259,  type = "Dungeon" }, -- The Shattered Halls World 56705270
 --[46005180] = { 256,  type = "Dungeon" }, -- The Blood Furnace World 56305260
 [47205220] = {
  id = { 248, 256, 259, 747 },
  type = "Mixed",
  hideOnMinimap = true,
 }, -- Hellfire Ramparts, The Blood Furnace, The Shattered Halls, Magtheridon's Lair
}
nodes["Netherstorm"] = {
 [71705500] = {
  id = 257,
  type = "Dungeon",
 }, -- The Botanica
 [70606980] = {
  id = 258,
  type = "Dungeon",
 }, -- The Mechanar World 65602540
 [74405770] = {
  id = 254,
  type = "Dungeon",
 }, -- The Arcatraz World 66802160
 [73806380] = {
  id = 749,
  type = "Raid",
 }, -- The Eye World 66602350
}
nodes["TerokkarForest"] = {
 [34306560] = {
  id = 247,
  type = "Dungeon",
 }, -- Auchenai Crypts World 44507890
 [39705770] = {
  id = 250,
  type = "Dungeon",
 }, -- Mana-Tombs World 46107640
 [44906560] = {
  id = 252,
  type = "Dungeon",
 }, -- Sethekk Halls World 47707890  Summoning Stone For Auchindoun 39806470, World: 46207860 
 [39607360] = {
  id = 253,
  type = "Dungeon",
 }, -- Shadow Labyrinth World 46108130
}
nodes["ShadowmoonValley"] = {
 [71004660] = {
  id = 751,
  type = "Raid",
 }, -- Black Temple World 72608410
}
nodes["Sunwell"] = {
 [61303090] = {
  id = 249,
  type = "Dungeon",
 }, -- Magisters' Terrace
 [44304570] = {
  id = 752,
  type = "Raid",
 }, -- Sunwell Plateau World 55300380
}
nodes["Zangarmarsh"] = {
 --[54203450] = { 262,  type = "Dungeon" }, -- Underbog World 35804330
 --[48903570] = { 260,  type = "Dungeon" }, -- Slave Pens World 34204370
 --[51903280] = { 748,  type = "Raid" }, -- Serpentshrine Cavern World 35104280
 [50204100] = {
  id = { 260, 262, 748 },
  type = "Mixed",
  hideOnMinimap = true,
 }, -- Mixed Location
}
minimap["Hellfire"] = {
 [47605360] = {
  id = 248,
  type = "Dungeon",
 }, -- Hellfire Ramparts World 56805310 Stone 48405240 World 57005280
 [46005180] = {
  id = 256,
  type = "Dungeon",
 }, -- The Blood Furnace World 56305260
 [48405180] = {
  id = 259,
  type = "Dungeon",
 }, -- The Shattered Halls World 56705270, Old 47505200.  Adjusted for clarity
 [46405290] = {
  id = 747,
  type = "Raid",
 }, -- Magtheridon's Lair World 56705270, Old 47505210.  Adjusted for clarity
}
minimap["Zangarmarsh"] = {
 [48903570] = {
  id = 260,
  type = "Dungeon",
 }, -- Slave Pens World 34204370
 [50303330] = {
  id = 261,
  type = "Dungeon",
 }, -- The Steamvault
 [54203450] = {
  id = 262,
  type = "Dungeon",
 }, -- Underbog World 35804330
 [51903280] = {
  id = 748,
  type = "Raid",
 }, -- Serpentshrine Cavern World 35104280
}
end

-- NORTHREND (16 Dungeons, 9 Raids)
if (not self.db.profile.hideNorthrend) then
nodes["BoreanTundra"] = {
 [27602660] = {
  id = { 282, 756, 281 },
  type = "Mixed",
 },
 -- Oculus same as eye of eternity
 --[27502610] = { "The Nexus",  type = "Dungeon" },
}
nodes["CrystalsongForest"] = {
 [28203640] = {
  id = 283,
  type = "Dungeon",
 }, -- The Violet Hold
}
nodes["Dragonblight"] = {
 [28505170] = {
  id = 271,
  type = "Dungeon",
 }, -- Ahn'kahet: The Old Kingdom
 [26005090] = {
  id = 272,
  type = "Dungeon",
 }, -- Azjol-Nerub
 [87305100] = {
  id = 754,
  type = "Raid",
 }, -- Naxxramas
 [61305260] = {
  id = 761,
  type = "Raid",
 }, -- The Ruby Sanctum
 [60005690] = {
  id = 755,
  type = "Raid",
 }, -- The Obsidian Sanctum
}
nodes["HowlingFjord"] = {
 --[57304680] = { 285,  type = "Dungeon" }, -- Utgarde Keep, more accurate but right underneath Utgarde Pinnacle
 [58005000] = {
  id = 285,
  type = "Dungeon",
 }, -- Utgarde Keep, at doorway entrance
 [57204660] = {
  id = 286,
  type = "Dungeon",
 }, -- Utgarde Pinnacle
}
nodes["IcecrownGlacier"] = { 
 [54409070] = {
  id = { 276, 278, 280 },
  type = "Dungeon",
  hideOnMinimap = true,
 }, -- The Forge of Souls, Halls of Reflection, Pit of Saron
 [74202040] = {
  id = 284,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Trial of the Champion
 [75202180] = {
  id = 757,
  type = "Raid",
  hideOnContinent = true,
 }, -- Trial of the Crusader
 [53808720] = {
  id = 758,
  type = "Raid",
 }, -- Icecrown Citadel
}
nodes["LakeWintergrasp"] = {
 [50001160] = {
  id = 753,
  type = "Raid",
 }, -- Vault of Archavon
}
nodes["TheStormPeaks"] = {
 [45302140] = {
  id = 275,
  type = "Dungeon",
 }, -- Halls of Lightning
 [39602690] = {
  id = 277,
  type = "Dungeon",
 }, -- Halls of Stone
 [41601770] = {
  id = 759,
  type = "Raid",
 }, -- Ulduar
}
nodes["ZulDrak"] = {
 [28508700] = {
  id = 273,
  type = "Dungeon",
 }, -- Drak'Tharon Keep 17402120 Grizzly Hills
 [76202110] = {
  id = 274,
  type = "Dungeon",
 }, -- Gundrak Left Entrance
 [81302900] = {
  id = 274,
  type = "Dungeon",
 }, -- Gundrak Right Entrance
}
nodes["Dalaran"] = {
 [68407000] = {
  id = 283,
  type = "Dungeon",
 }, -- The Violet Hold
}

-- NORTHREND MINIMAP, For things that would be too crowded on the continent or zone maps but look correct on the minimap
minimap["IcecrownGlacier"] = {
 [54908980] = {
  id = 280,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- The Forge of Souls
 [55409080] = {
  id = 276,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Halls of Reflection
 [54809180] = {
  id = 278,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Pit of Saron 54409070 Summoning stone in the middle of last 3 dungeons
}

-- NORTHREND CONTINENT, For things that should be shown or merged only at the continent level
nodes["Northrend"] = {
 --[80407600] = { 285,  type = "Dungeon", false, 286 }, -- Utgarde Keep, Utgarde Pinnacle CONTINENT MERGE Location is slightly incorrect
 [47501750] = {
  id = { 757, 284 },
  type = "Mixed",
 }, -- Trial of the Crusader and Trial of the Champion
}
end

-- CATACLYSM
if (not self.db.profile.hideCata) then
nodes["Deepholm"] = {
 [47405210] = {
  id = 67,
  type = "Dungeon",
 }, -- The Stonecore (Maelstrom: 51002790)
}
nodes["Hyjal"] = {
 [47307810] = {
  id = 78,
  type = "Raid",
 }, -- Firelands
}
nodes["TolBarad"] = {
 [46104790] = {
  id = 75,
  type = "Raid",
 }, -- Baradin Hold
}
nodes["TwilightHighlands"] = {
 [19105390] = {
  id = 71,
  type = "Dungeon",
 }, -- Grim Batol World 53105610
 [34007800] = {
  id = 72,
  type = "Raid",
 }, -- The Bastion of Twilight World 55005920
}
nodes["Uldum"] = {
 [76808450] = {
  id = 68,
  type = "Dungeon",
 }, -- The Vortex Pinnacle
 [60506430] = {
  id = 69,
  type = "Dungeon",
 }, -- Lost City of Tol'Vir
 [69105290] = {
  id = 70,
  type = "Dungeon",
 }, -- Halls of Origination
 [38308060] = {
  id = 74,
  type = "Raid",
 }, -- Throne of the Four Winds
}
nodes["Vashjir"] = {
 [48204040] =  {
  id = 65,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Throne of Tides
}
nodes["VashjirDepths"] = {
 [69302550] = {
  id = 65,
  type = "Dungeon",
 }, -- Throne of Tides
}
end

-- PANDARIA
if (not self.db.profile.hidePandaria) then
nodes["DreadWastes"] = {
 [38803500] = {
  id = 330,
  type = "Raid",
 }, -- Heart of Fear
}
nodes["IsleoftheThunderKing"] = {
 [63603230] = {
  id = 362,
  type = "Raid",
  hideOnContinent = true
 }, -- Throne of Thunder
}
nodes["KunLaiSummit"] = {
 [59503920] = {
  id = 317,
  type = "Raid",
 }, -- Mogu'shan Vaults
 [36704740] = {
  id = 312,
  type = "Dungeon",
 }, -- Shado-Pan Monastery
}
nodes["TheHiddenPass"] = {
 [48306130] = {
  id = 320,
  type = "Raid",
 }, -- Terrace of Endless Spring
}
nodes["TheJadeForest"] = {
 [56205790] = {
  id = 313,
  type = "Dungeon",
 }, -- Temple of the Jade Serpent
}
nodes["TownlongWastes"] = {
 [34708150] = {
  id = 324,
  type = "Dungeon",
 }, -- Siege of Niuzao Temple
}
nodes["ValeofEternalBlossoms"] = {
 [15907410] = {
  id = 303,
  type = "Dungeon",
 }, -- Gate of the Setting Sun
 [80803270] = {
  id = 321,
  type = "Dungeon",
 }, -- Mogu'shan Palace
 [74104200] = {
  id = 369,
  type = "Raid",
 }, -- Siege of Orgrimmar
}
nodes["ValleyoftheFourWinds"] = {
 [36106920] = {
  id = 302,
  type = "Dungeon",
 }, -- Stormstout Brewery
}

-- PANDARIA Continent, For things that should be shown or merged only at the continent level
nodes["Pandaria"] = {
 [23100860] = {
  id = 362,
  type = "Raid",
 }, -- Throne of Thunder, looked weird so manually placed on continent
}
end

-- DRAENOR
if (not self.db.profile.hideDraenor) then
nodes["FrostfireRidge"] = {
 [49902470] = {
  id = 385,
  type = "Dungeon",
 }, -- Bloodmaul Slag Mines
}
nodes["Gorgrond"] = {
 [51502730] = {
  id = 457,
  type = "Raid",
 }, -- Blackrock Foundry
 [55103160] = {
  id = 536,
  type = "Dungeon",
 }, -- Grimrail Depot
 [59604560] = {
  id = 556,
  type = "Dungeon",
 }, -- The Everbloom
 [45401350] = {
  id = 558,
  type = "Dungeon",
 }, -- Iron Docks
}
nodes["NagrandDraenor"] = {
 [32903840] = {
  id = 477,
  type = "Raid",
 }, -- Highmaul
}
nodes["ShadowmoonValleyDR"] = {
 [31904260] = {
  id = 537,
  type = "Dungeon",
 }, -- Shadowmoon Burial Grounds
}
nodes["SpiresOfArak"] = {
 [35603360] = {
  id = 476,
  type = "Dungeon",
 }, -- Skyreach
}
nodes["Talador"] = {
 [46307390] = {
  id = 547,
  type = "Dungeon",
 }, -- Auchindoun
}
nodes["TanaanJungle"] = {
 [45605360] = {
  id = 669,
  type = "Raid",
 }, -- Hellfire Citadel
}
end

-- Adding Zones and things to this will hide nodes from all but the listed mapLevels
mapLevels["Dalaran70"] = { [10] = true, }
mapLevels["CavernsofTime"] = { [18] = true, }

if (not self.db.profile.hideBrokenIsles) then
-- Legion Dungeons/Raids for minimap and continent map for consistency
-- This seems to be the only legion dungeon/raid that isn't shown at all
-- I have made this into an ugly abomination

 nodes["BrokenIsles"] = { }
 nodes["BrokenIsles"][35402850] = {
  id = { 762, 768 },
  type = "Mixed",
  hideOnMinimap = true,
 } -- The Emerald Nightmare 35102910
 nodes["BrokenIsles"][65003870] = {
  id = { 721, 861 },
  type = "Mixed",
  hideOnMinimap = true,
 } -- Halls of Valor/Trial of Valor
 nodes["BrokenIsles"][46704780] = {
  id = { 726, 786 },
  type = "Mixed",
  hideOnMinimap = true,
 }
  nodes["BrokenIsles"][46606550] = {
  id = 777,
  type = "Dungeon",
  hideOnMinimap = true,
 } -- Assault on Violet Hold
 nodes["BrokenIsles"][56506240] = { -- Always show because merged
  id = { 875, 900 },
  type = "Mixed",
  hideOnMinimap = true,
 } -- Tomb of Sargeras and Cathedral of the Night


nodes["Dalaran70"] = {
 [66406850] = {
  id = 777,
  type = "Dungeon",
  hideOnContinent = true,
 }, -- Assault on Violet Hold
}

if (not legionInstancesDiscovered[946]) then
nodes["ArgusCore"] = {
 [54786241] = {
  id = 946,
  type = "Raid",
 }, -- Antorus, the burning throne
}
else
 minimap["ArgusCore"] = {
  [54786241] = {
   id = 946,
   type = "Raid",
  }, -- Antorus, the burning throne
 }
end
if (not legionInstancesDiscovered[945]) then
nodes["ArgusMacAree"] = {
 -- 22.20 55.84
 [22205584] = {
  id = 945,
  type = "Dungeon",
 }, -- Seat of the Triumvirate
}
else
minimap["ArgusMacAree"] = {
 -- 22.20 55.84
 [22205584] = {
  id = 945,
  type = "Dungeon",
 }, -- Seat of the Triumvirate
}
end
if (not legionInstancesDiscovered[716]) then
 nodes["Azsuna"] = { }
 nodes["Azsuna"][61204110] = {
  id = 716,
  type = "Dungeon",
 }
else
 minimap["Azsuna"] = { }
 minimap["Azsuna"][61204110] = {
  id = 716,
  type = "Dungeon",
 }
 nodes["BrokenIsles"][38805780] = {
  id = 716,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[707]) then
 if (not nodes["Azsuna"]) then
  nodes["Azsuna"] = { }
 end
 nodes["Azsuna"][48308030] = {
  id = 707,
  type = "Dungeon"
 }
else
 if (not minimap["Azsuna"]) then
  minimap["Azsuna"] = { }
 end
 minimap["Azsuna"][48308030] = {
  id = 707,
  type = "Dungeon"
 }
 nodes["BrokenIsles"][34207210] = {
  id = 707,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[875]) then
 nodes["BrokenShore"] = { }
 nodes["BrokenShore"][64602070] = {
  id = 875,
  type = "Raid",
  hideOnContinent = true,
 }
else
 minimap["BrokenShore"] = {
  [64602070] = {
   id = 875,
   type = "Raid",
  },
 }
end
if (not legionInstancesDiscovered[900]) then
 if (not nodes["BrokenShore"]) then
  nodes["BrokenShore"] = { }
 end
 nodes["BrokenShore"][64701660] = {
  id = 900,
  type = "Dungeon",
  hideOnContinent = true,
 }
else
 if (not minimap["BrokenShore"]) then
  minimap["BrokenShore"] = { }
 end
 minimap["BrokenShore"][64701660] = {
  id = 900,
  type = "Dungeon",
 }
end
if (not legionInstancesDiscovered[767]) then
 nodes["Highmountain"] = {
  [49606860] = {
   id = 767,
   type = "Dungeon",
  },
 }
else
 minimap["Highmountain"] = {
  [49606860] = {
   id = 767,
   type = "Dungeon",
  },
 }
 nodes["BrokenIsles"][47302810] = {
  id = 767,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[861]) then
 nodes["Stormheim"] = { }
 nodes["Stormheim"][71107280] = {
  id = 861,
  type = "Raid",
  hideOnContinent = true,
 }
else
 minimap["Stormheim"] = {
  [71107280] = {
   id = 861,
   type = "Raid",
  },
 }
end
if (not legionInstancesDiscovered[721]) then
 if (not nodes["Stormheim"]) then
  nodes["Stormheim"] = { }
 end
 nodes["Stormheim"][72707050] = {
  id = 721,
  type = "Dungeon",
  hideOnContinent = true,
 }
else
 if (not minimap["Stormheim"]) then
  minimap["Stormheim"] = { }
 end
 minimap["Stormheim"][72707050] = {
  id = 721,
  type = "Dungeon",
 }
end
if (not legionInstancesDiscovered[727]) then
 if (not nodes["Stormheim"]) then
  nodes["Stormheim"] = { }
 end
 nodes["Stormheim"][52504530] = {
  id = 727,
  type = "Dungeon",
 }
else
 if (not minimap["Stormheim"]) then
  minimap["Stormheim"] = { }
 end
 minimap["Stormheim"][52504530] = {
  id = 727,
  type = "Dungeon",
 }
 nodes["BrokenIsles"][59003060] = {
  id = 727,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[726]) then
 nodes["Suramar"] = {
  [41106170] = {
   id = 726,
   type = "Dungeon",
   hideOnContinent = true,
  },
 }
else
 minimap["Suramar"] = {
  [41106170] = {
   id = 726,
   type = "Dungeon",
  },
 }
end
if (not legionInstancesDiscovered[800]) then
 if (not nodes["Suramar"]) then
  nodes["Suramar"] = { }
 end
 nodes["Suramar"][50806550] = {
  id = 800,
  type = "Dungeon",
 }
else
 if (not minimap["Suramar"]) then
  minimap["Suramar"] = { }
 end
 minimap["Suramar"][50806550] = {
  id = 800,
  type = "Dungeon",
 }
 nodes["BrokenIsles"][49104970] = {
  id = 800,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[786]) then
 if (not nodes["Suramar"]) then
  nodes["Suramar"] = { }
 end
 nodes["Suramar"][44105980] = {
  id = 786,
  type = "Raid",
  hideOnContinent = true,
 }
else
 if (not minimap["Suramar"]) then
  minimap["Suramar"] = { }
 end
 minimap["Suramar"][44105980] = {
  id = 786,
  type = "Raid",
 }
end
if (not legionInstancesDiscovered[740]) then
 nodes["Valsharah"] = {
  [37205020] = {
   id = 740,
   type = "Dungeon",
  },
 }
else
 minimap["Valsharah"] = {
  [37205020] = {
   id = 740,
   type = "Dungeon",
  },
 }
 nodes["BrokenIsles"][29403300] = {
  id = 740,
  type = "Dungeon",
  hideOnMinimap = true,
 }
end
if (not legionInstancesDiscovered[762]) then
 if (not nodes["Valsharah"]) then
  nodes["Valsharah"] = { }
 end
 nodes["Valsharah"][59003120] = {
  id = 762,
  type = "Dungeon",
  hideOnContinent = true,
 }
else
 if (not minimap["Valsharah"]) then
  minimap["Valsharah"] = { }
 end
 minimap["Valsharah"][59003120] = {
  id = 762,
  type = "Dungeon",
 }

end
if (not legionInstancesDiscovered[768]) then
 if (not nodes["Valsharah"]) then
  nodes["Valsharah"] = { }
 end
 nodes["Valsharah"][56303680] = {
  id = 768,
  type = "Raid",
  hideOnContinent = true,
 }
else
if (not minimap["Valsharah"]) then
  minimap["Valsharah"] = { }
 end
 minimap["Valsharah"][56303680] = {
  id = 768,
  type = "Raid",
 }
end
end
end



function Addon:ProcessTable()
table.wipe(alterName)

-- These are the same on the english client, I put them here cause maybe they change in other locales.  This list was somewhat automatically generated
-- I may be over thinking this
alterName[321] = 1467 -- Mogu'shan Palace
alterName[758] = 280 -- Icecrown Citadel
alterName[476] = 1010 -- Skyreach
alterName[233] = 20 -- Razorfen Downs
alterName[751] = 196 -- Black Temple
alterName[536] = 1006 -- Grimrail Depot
alterName[861] = 1439 -- Trial of Valor
alterName[756] = 1423 -- The Eye of Eternity
alterName[716] = 1175 -- Eye of Azshara
alterName[76] = 334 -- Zul'Gurub
alterName[77] = 340 -- Zul'Aman
alterName[757] = 248 -- Trial of the Crusader
alterName[236] = 1458 -- Stratholme
alterName[745] = 175 -- Karazhan
alterName[271] = 1016 -- Ahn'kahet: The Old Kingdom
alterName[330] = 534 -- Heart of Fear
alterName[186] = 439 -- Hour of Twilight
alterName[229] = 32 -- Lower Blackrock Spire
alterName[279] = 210 -- The Culling of Stratholme
alterName[385] = 1005 -- Bloodmaul Slag Mines
alterName[253] = 181 -- Shadow Labyrinth
alterName[276] = 256 -- Halls of Reflection
alterName[69] = 1151 -- Lost City of the Tol'vir
alterName[187] = 448 -- Dragon Soul
alterName[274] = 1017 -- Gundrak
alterName[252] = 180 -- Sethekk Halls
alterName[65] = 1150 -- Throne of the Tides
alterName[70] = 321 -- Halls of Origination
alterName[707] = 1044 -- Vault of the Wardens
--alterName[283] = 1297 -- The Violet Hold (This likely points to the hunter scenario within)
alterName[283] = 221 -- The Violet Hold -> Violet Hold
alterName[875] = 1527 -- Tomb of Sargeras
alterName[75] = 329 -- Baradin Hold
alterName[800] = 1319 -- Court of Stars
alterName[64] = 327 -- Shadowfang Keep
alterName[760] = 257 -- Onyxia's Lair
alterName[777] = 1209 -- Assault on Violet Hold
alterName[311] = 473 -- Scarlet Halls
alterName[755] = 238 -- The Obsidian Sanctum
alterName[726] = 1190 -- The Arcway
alterName[275] = 1018 -- Halls of Lightning
alterName[277] = 213 -- Halls of Stone
alterName[241] = 24 -- Zul'Farrak
alterName[762] = 1202 -- Darkheart Thicket
alterName[786] = 1353 -- The Nighthold
alterName[727] = 1192 -- Maw of Souls
alterName[362] = 634 -- Throne of Thunder
alterName[759] = 244 -- Ulduar
alterName[317] = 532 -- Mogu'shan Vaults
alterName[272] = 241 -- Azjol-Nerub
alterName[558] = 1007 -- Iron Docks
alterName[247] = 178 -- Auchenai Crypts
alterName[273] = 215 -- Drak'Tharon Keep
alterName[324] = 1465 -- Siege of Niuzao Temple
alterName[754] = 227 -- Naxxramas
alterName[753] = 240 -- Vault of Archavon
alterName[286] = 1020 -- Utgarde Pinnacle
alterName[280] = 252 -- The Forge of Souls
alterName[67] = 1148 -- The Stonecore
alterName[747] = 176 -- Magtheridon's Lair
alterName[258] = 192 -- The Mechanar
alterName[281] = 1019 -- The Nexus
alterName[369] = 766 -- Siege of Orgrimmar
alterName[184] = 1152 -- End Time
alterName[740] = 1205 -- Black Rook Hold
alterName[742] = 50 -- Blackwing Lair
alterName[457] = 900 -- Blackrock Foundry
alterName[313] = 1469 -- Temple of the Jade Serpent
alterName[556] = 1003 -- The Everbloom
alterName[248] = 188 -- Hellfire Ramparts
alterName[768] = 1350 -- The Emerald Nightmare
alterName[721] = 1473 -- Halls of Valor
alterName[231] = 14 -- Gnomeregan
alterName[900] = 1488 -- Cathedral of Eternal Night
alterName[257] = 191 -- The Botanica
alterName[302] = 1466 -- Stormstout Brewery
alterName[669] = 989 -- Hellfire Citadel
alterName[559] = 1004 -- Upper Blackrock Spire
alterName[741] = 48 -- Molten Core
alterName[78] = 362 -- Firelands
alterName[547] = 1008 -- Auchindoun
alterName[537] = 1009 -- Shadowmoon Burial Grounds
alterName[477] = 897 -- Highmaul
alterName[261] = 185 -- The Steamvault
alterName[746] = 177 -- Gruul's Lair
alterName[303] = 1464 -- Gate of the Setting Sun
alterName[66] = 323 -- Blackrock Caverns
alterName[249] = 1154 -- Magisters' Terrace
alterName[278] = 1153 -- Pit of Saron
alterName[73] = 314 -- Blackwing Descent
alterName[316] = 474 -- Scarlet Monastery
alterName[246] = 472 -- Scholomance
alterName[226] = 4 -- Ragefire Chasm
alterName[63] = 326 -- Deadmines
alterName[227] = 10 -- Blackfathom Deeps
alterName[285] = 242 -- Utgarde Keep
alterName[185] = 437 -- Well of Eternity
alterName[250] = 1013 -- Mana-Tombs
alterName[312] = 1468 -- Shado-Pan Monastery
alterName[748] = 194 -- Serpentshrine Cavern
alterName[320] = 834 -- Terrace of Endless Spring
alterName[284] = 249 -- Trial of the Champion
alterName[234] = 16 -- Razorfen Kraul
alterName[240] = 1 -- Wailing Caverns
alterName[68] = 1147 -- The Vortex Pinnacle
alterName[74] = 318 -- Throne of the Four Winds
alterName[767] = 1207 -- Neltharion's Lair
alterName[72] = 316 -- The Bastion of Twilight
alterName[239] = 22 -- Uldaman
alterName[282] = 1296 -- The Oculus
alterName[71] = 1149 -- Grim Batol
alterName[254] = 1011 -- The Arcatraz

-- This is a list of the ones that absolutely do not match in the english client
alterName[743] = 160 -- Ruins of Ahn'Qiraj -> Ahn'Qiraj Ruins
alterName[749] = 193 -- The Eye -> Tempest Keep

alterName[761] = 1502 -- The Ruby Sanctum -> Ruby Sanctum
alterName[744] = 161 -- Temple of Ahn'Qiraj -> Ahn'Qiraj Temple

for i,v in pairs(nodes) do
  for j,u in pairs(v) do
   self:UpdateInstanceNames(u)
  end
 end
 
 for i,v in pairs(minimap) do
  for j,u in pairs(v) do
   if (not u.name) then -- Don't process if node was already handled above
	self:UpdateInstanceNames(u)
   end
  end
 end
 
 local HereBeDragons = LibStub("HereBeDragons-1.0") -- Phanx
 local continents = { GetMapContinents() }
 local temp = { } -- I switched to the temp table because modifying the nodes table while iterating over it sometimes stopped it short for some reason
 for mapFile, coords in pairs(nodes) do
  if not continents[mapFile] and not (internalNodes[mapFile]) then
   if (DEBUG) then print(mapFile) end
   local continentMapID = continents[2 * HandyNotes:GetCZ(mapFile) - 1]
   local continentMapFile = HandyNotes:GetMapIDtoMapFile(continentMapID)
   mapToContinent[mapFile] = continentMapFile
   for coord, criteria in next, coords do
    if (not criteria.hideOnContinent) then
     local x, y = HandyNotes:getXY(coord)
     x, y = HereBeDragons:GetWorldCoordinatesFromZone(x, y, mapFile)
     x, y = HereBeDragons:GetZoneCoordinatesFromWorld(x, y, continentMapID)
     if x and y then
      temp[continentMapFile] = temp[continentMapFile] or {}
      temp[continentMapFile][HandyNotes:getCoord(x, y)] = criteria
	 end
	end
   end
  end
 end
 for mapFile, coords in pairs(temp) do
   nodes[mapFile] = coords
 end
end

-- Takes ids and fetchs and stores data to node.name
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


-- The goal here is to have a table of IDs that correspond between the GetLFGDungeonInfo and EJ_GetInstanceInfo functions
-- I check if the names are different and if so then use both when checking for lockouts
-- This can probably be done better but I don't know how
-- I'm putting this in because on the english client, certain raids have a different lockout name than their journal counterpart e.g The Eye and Tempest Keep
-- If it's messed up in english then it's probably messed up elsewhere and I don't even know if this will help
function Addon:UpdateAlter(id, name)
 if (alterName[id]) then
  local alternativeName = GetLFGDungeonInfo(alterName[id])
  if (alternativeName) then
   if (alternativeName == name) then
    --print("EJ and LFG names both match, removing", name, "from table")
	--alterName[id] = nil
   else
    alterName[id] = nil
    alterName[name] = alternativeName
    --print("Changing",id,"to",name,"and setting alter value to",alternativeName)
   end
  end
 end
end

function Addon:ProcessExtraInfo() -- Could use this to add required levels and things, may do later or not
 table.wipe(extraInfo)
 if (true) then return end
 
--[[ for i=1,2000 do -- Do this less stupidly
  local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, bonusRepAmount, minPlayers, isTimeWalker, name2, minGearLevel = GetLFGDungeonInfo(i)
 end]]
end

function Addon:FullUpdate()
 self:PopulateTable()
 self:PopulateMinimap()
 self:ProcessTable()
 --self:ProcessExtraInfo()
end

-- Looks through the legions maps and checks if the default blizzard thingies are visible.
function Addon:CheckForPOIs()
 if (WorldMapFrame:IsVisible()) then return end -- This function will interrupt the user if map is open while we do stuff
 local needsUpdate = false
 local LegionInstanceMapIDs = { 1015, 1017, 1018, 1024, 1033, 1170, 1171 }
 for k,v in pairs(LegionInstanceMapIDs) do
  SetMapByID(v)  
  for i=1,GetNumMapLandmarks() do
   local landmarkType, name, description, _, _, _, mapLinkID = C_WorldMap.GetMapLandmarkInfo(i)
   if (landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE) then
   --print(name, description, mapLinkID)
    if (not legionInstancesDiscovered[mapLinkID]) then needsUpdate = true end
	legionInstancesDiscovered[mapLinkID] = true
    --print (name, mapLinkID, landmarkType, description)
   end
  end
 end 
 
 if (needsUpdate) then self:FullUpdate() end
end
