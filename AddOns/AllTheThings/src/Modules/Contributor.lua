-- Contributor Module
-- Provides additional functionality which may be opted-into by the end user to help in crowd-sourcing
-- or further improvement to ATT data or logic
local _, app = ...;

-- Globals
local ipairs,pairs,tostring,setmetatable
	= ipairs,pairs,tostring,setmetatable
local GetQuestID,C_QuestLog_IsOnQuest
	= GetQuestID,C_QuestLog.IsOnQuest

-- Modules
local DelayedCallback = app.CallbackHandlers.DelayedCallback
local round = app.round

local api = {};
app.Modules.Contributor = api;
-- Events - a collection of Game Events which should trigger additional logic
api.Events = {}
local Reports = setmetatable({}, { __index = function(t,key)
	local reportType = setmetatable({}, { __index = function(t,key)
		local typeIDReport = {}
		t[key] = typeIDReport
		return typeIDReport
	end})
	reportType.__type = key
	t[key] = reportType
	return reportType
end})
app.AddEventHandler("OnReportReset", function() wipe(Reports) end)

-- Allows adding an Event handler function for in-game events when Contributor is enabled
local function AddEventFunc(event, func)
	api.Events[event] = func
end

local function GetReportPlayerLocation()
	local mapID, px, py, fake = app.GetPlayerPosition()
	if fake then
		return UNKNOWN..", "..UNKNOWN..", "..tostring(mapID or UNKNOWN).." ("..(app.GetMapName(mapID) or "??")..")"
	end
	-- floor coords to nearest tenth
	if px then px = round(px, 1) end
	if py then py = round(py, 1) end
	return tostring(px or UNKNOWN)..", "..tostring(py or UNKNOWN)..", "..tostring(mapID or UNKNOWN).." ("..(app.GetMapName(mapID) or "??")..")"
end

local function DoReport(reporttype, id)
	local dialogID = reporttype.."_"..id
	-- app.PrintDebug("Contributor.DoReport",reporttype,id)

	local reportData = Reports[reporttype][id]
	-- keyed report data
	local keyedData = {}
	for k,v in pairs(reportData) do
		keyedData[#keyedData + 1] = tostring(k)..": \""..tostring(v).."\""
	end
	-- common report data
	reportData[#reportData + 1] = "### "..reporttype..":"..id
	reportData[#reportData + 1] = "```elixir"	-- discord fancy box start
	for _,text in pairs(keyedData) do
		reportData[#reportData + 1] = text
	end
	-- common report data
	reportData[#reportData + 1] = "---- User Info ----"
	reportData[#reportData + 1] = "PlayerLocation: "..GetReportPlayerLocation()
	reportData[#reportData + 1] = "L:"..app.Level.." R:"..app.RaceID.." ("..app.Race..") C:"..app.ClassIndex.." ("..app.Class..")"
	reportData[#reportData + 1] = "ver: "..app.Version
	reportData[#reportData + 1] = "build: "..app.GameBuildVersion
	reportData[#reportData + 1] = "```";	-- discord fancy box end

	if app:SetupReportDialog(dialogID, "Contributor Report: " .. dialogID, reportData) then
		app.print(app:Linkify("Contributor Report: "..dialogID, app.Colors.ChatLinkError, "dialog:" .. dialogID));
		app.Audio:PlayReportSound();
	end
end

local function AddReportData(reporttype, id, data)
	-- app.PrintDebug("Contributor.AddReportData",reporttype,id)
	-- app.PrintTable(data)
	local reportData = Reports[reporttype][id]
	if type(data) == "table" then
		for k,v in pairs(data) do
			reportData[k] = v
		end
	else
		reportData[#reportData + 1] = tostring(data)
	end
	-- after adding data for a report, we will trigger that report shortly afterwards in case more data is added elsewhere within
	-- that timeframe
	DelayedCallback(DoReport, 0.25, reporttype, id)
end

api.DoReport = function(id, text)
	AddReportData("test", id, text)
end

-- Used to override the precision of coord accuracy based on irregularly sized maps
-- typically we don't want the report to trigger even when interacting from max range
-- so can adjust here
local MapPrecisionOverrides = {
	 [629] = 3,	-- Aegwynn's Gallery
	[1164] = 3,	-- Dazar'alor
	[1176] = 3,	-- Breath Of Pa'ku
	[1177] = 3,	-- Breath Of Pa'ku
	[1699] = 3,	-- Sinfall
	[1700] = 3,	-- Sinfall
	[2328] = 3,	-- The Proscenium
}

local function Check_coords(objRef, id, maxCoordDistance)
	-- check coord distance
	local mapID, px, py, fake = app.GetPlayerPosition()
	-- fake player coords (instances, etc.) cannot be checked
	if fake then return true end

	if not objRef or not objRef.coords then return end

	local dist, sameMap, check
	local closest = 9999
	maxCoordDistance = MapPrecisionOverrides[mapID] or maxCoordDistance or 1
	for _, coord in ipairs(objRef.coords) do
		if mapID == coord[3] then
			sameMap = mapID
			dist = app.distance(px, py, coord[1], coord[2])
			-- app.PrintDebug("coords @",dist)
			if dist < closest then closest = dist end
		end
	end
	if sameMap then
		-- quest has an accurate coord on accurate map
		if closest > maxCoordDistance then
			-- round to the tenth
			closest = round(closest, 1)
			AddReportData(objRef.__type,id,{
				[objRef.key or "ID"] = id,
				VerifyOrAddCoords = "Closest existing Coordinates are off by: "..tostring(closest).." on mapID: "..mapID,
			})
			check = 1
		end
	else
		AddReportData(objRef.__type,id,{
			[objRef.key or "ID"] = id,
			MissingMap = "No Coordinates on current Map!",
		})
		check = 1
	end
	return check or true
end

-- Temporary implementation until better, global DB(s) provides similar data references
-- These should be NPCs which are mobile in that they can have completely variable coordinates in game
-- either by following the player or having player-based decisions that cause them to have any coordinates
local MobileDB = {}
MobileDB.Creature = {
	   [715] = true,	-- Hemet Nesingwary Jr.
	   [718] = true,	-- Sir S. J. Erlgadin
	   [951] = true,	-- Brother Paxton
	  [2545] = true,	-- "Pretty Boy" Duncan
	  [2608] = true,	-- Commander Amaren
	 [14626] = true,	-- Taskmaster Scrange
	 [19644] = true,	-- Image of Archmage Vargoth
	 [19935] = true,	-- Soridormi
	 [23870] = true,	-- Ember Clutch Ancient
	 [26206] = true,	-- Keristrasza
	 [29795] = true,	-- Kolitra Deathweaver (Orgrim's Hammer)
	 [30216] = true,	-- Vile
	 [34653] = true,	-- Bountiful Table Hostess
	 [37172] = true,	-- Detective Snap Snagglebolt
	 [38066] = true,	-- Inspector Snip Snagglebolt
	 [42736] = true,	-- Lashtail Hatchling
	 [43300] = true,	-- Messner
	 [43302] = true,	-- Danforth
	 [43303] = true,	-- Krakauer
	 [43305] = true,	-- Jorgensen
	 [43556] = true,	-- "Dead-Eye" Drederick McGumm
	 [43885] = true,	-- Emerine Junis
	 [43929] = true,	-- Blingtron 4000
	 [44043] = true,	-- Kinnel
	 [44100] = true,	-- Goris
	 [45451] = true,	-- Argus Highbeacon
	 [45574] = true,	-- Vex'tul
	 [45736] = true,	-- Deacon Andaal
	 [46664] = true,	-- Dr. Hieronymus Blam
	 [47280] = true,	-- Lunk
	 [47332] = true,	-- Lunk
	 [48346] = true,	-- John J. Keeshan
	 [52234] = true,	-- Bwemba
	 [55497] = true,	-- Zin'Jun
	 [64337] = true,	-- Nomi
	 [67153] = true,	-- Zin'Jun
	 [67976] = true,	-- Tinkmaster Overspark
	 [77789] = true,	-- Blingtron 5000
	 [79815] = true,	-- Grun'lek
	 [83858] = true,	-- Khadgar's Servant
	 [87991] = true,	-- Cro Threadstrong
	 [87992] = true,	-- Olaf
	 [87994] = true,	-- Moroes <Tower Steward>
	 [87995] = true,	-- Fleet Master Seahorn
	 [87996] = true,	-- Lillian Voss
	 [87997] = true,	-- Leonid Barthalomew the Revered
	 [87998] = true,	-- Sunwalker Dezco
	 [87999] = true,	-- Skylord Omnuron
	 [88000] = true,	-- Pip Quickwit
	 [88001] = true,	-- Maximillian of Northshire
	 [88002] = true,	-- Highlord Darion Mograine
	 [88003] = true,	-- Cowled Ranger
	 [88004] = true,	-- Zen'kiki
	 [88005] = true,	-- Lorewalker Cho
	 [88006] = true,	-- Lonika Stillblade
	 [88007] = true,	-- Gamon
	 [88009] = true,	-- Millhouse Manastorm
	 [88013] = true,	-- Lunk
	 [88017] = true,	-- Budd
	 [88022] = true,	-- Johnny Awesome
	 [88023] = true,	-- Taoshi
	 [88024] = true,	-- Oralius
	 [88025] = true,	-- Mylune
	 [88026] = true,	-- John J. Keeshan
	 [88027] = true,	-- Impsy
	[101527] = true,	-- Blingtron 6000
	[105637] = true,	-- Scowling Rosa <Texts and Specialty Goods>
	[115785] = true,	-- Direbeak Hatchling
	[117475] = true,	-- Lord Darius Crowley
	[126576] = true,	-- Razgaji (You can accept quests as he's walking back to his start position)
	[129514] = true,	-- Warguard Rakera
	[130474] = true,	-- Reckless Vulpera (Nisha)
	[133302] = true,	-- Wardruid Loti
	[141602] = true,	-- Thomas Zelling
	[145005] = true,	-- Lor'themar Theron
	[146462] = true,	-- Rexxar
	[146536] = true,	-- Lost Wisp
	[145707] = true,	-- Advisor Belgrum
	[153897] = true,	-- Blingtron 7000
	[158544] = true,	-- Lord Herne
	[158635] = true,	-- Xolartios <Eternal Traveler>
	[161261] = true,	-- Kael'thas Sunstrider
	[161427] = true,	-- Kael'thas Sunstrider
	[161431] = true,	-- Kael'thas Sunstrider
	[161436] = true,	-- Kael'thas Sunstrider
	[161439] = true,	-- Kael'thas Sunstrider
	[172854] = true,	-- Dredger Butler
	[181085] = true,	-- Stratholme Supply Crate
	[185749] = true,	-- Gnoll Mon-Ark
	[191494] = true,	-- Khanam Matra Sarest
	[193985] = true,	-- Initiate Zorig
	-- #if BEFORE 10.2.7
	[205127] = true,	-- Newsy
	-- #endif
	[209681] = true,	-- Squally
	[211444] = true,	-- Flynn Fairwind
	[213560] = true,	-- Inspector Snip Snagglebolt
	[214707] = true,	-- Detective Snap Snagglebolt
	[214890] = true,	-- Magni Bronzebeard
	[214892] = true,	-- Dagran Thaurissan II
	[215597] = true,	-- Alleria Winderunner
	[220307] = true,	-- Holiday Enthusiast
	[220859] = true,	-- Amy Lychenstone
	[221492] = true,	-- Baron Sybaestan Braunpyke
	[221539] = true,	-- Alleria Winderunner
	[221867] = true,	-- Mereldar Child
	[221980] = true,	-- Faerin Lothar
	[222239] = true,	-- Scrit
	[224618] = true,	-- Danagh's Cogwalker
	[226934] = true,	-- Jojo Gobdre
	[232660] = true,	-- Alleria Winderunner
	[235849] = true,	-- Fleet Master Seahorn
}
-- These should be GameObjects which are mobile in that they can have completely variable coordinates in game
-- either by following the player or having player-based decisions that cause them to have any coordinates
-- but also quests objects that are not sourced elsewhere..
-- Legend: q - Quest, dq - Daily Quest, wq - World Quest, [A] - Alliance, [H] - Horde
MobileDB.GameObject = {
		[57] = true,	-- Bloodscalp Lore Tablet (q:26744)
	   [119] = true,	-- Abercrombie's Crate (q:26680)
	   [759] = true,	-- The Holy Spring (q:26817)
	  [2068] = true,	-- Pupellyverbos Port (q:26486)
	  [2086] = true,	-- Bloodsail Charts (q:26612)
	  [2087] = true,	-- Bloodsail Orders (q:26612)
	  [2689] = true,	-- Stone of West Binding (q:26041)
	  [2690] = true,	-- Stone of Outer Binding (q:26041)
	  [2691] = true,	-- Stone of East Binding (q:26041)
	  [2712] = true,	-- Calcified Elven Gem (q:26051)
	  [2716] = true,	-- Trelane's Chest (q:26038)
	  [2717] = true,	-- Trelane's Footlocker (q:26038)
	  [2718] = true,	-- Trelane's Lockbox (q:26038)
	  [3659] = true,	-- Barrel of Melon Juice
	  [3695] = true,	-- Food Crate
	 [17155] = true,	-- Large Battered Chest (Deadmines)
	 [19019] = true,	-- Box of Assorted Parts
	 [19020] = true,	-- Box of Assorted Parts
	 [22550] = true,	-- Draenethyst Crystals (q:27840)
	 [30854] = true,	-- Atal'ai Artifact (q:27694)
	 [30855] = true,	-- Atal'ai Artifact (q:27694)
	 [30856] = true,	-- Atal'ai Artifact (q:27694)
	 [74448] = true,	-- Large Solid Chest
	[148499] = true,	-- Felix's Box (q:3361)
	[169243] = true,	-- Chest of The Seven (BRD)
	[176208] = true,	-- Horgus' Skull (q:27387)
	[176209] = true,	-- Shattered Sword of Marduk (q:27387)
	[176224] = true,	-- Supply Crate (Stratholme)
	[177789] = true,	-- Augustus' Receipt Book (q:27534)
	[178084] = true,	-- Felix's Chest (q:3361)
	[178144] = true,	-- Troll Chest (q:13874 [A], q:6462 [H])
	[179828] = true,	-- Dark Iron Pillow (q:28057)
	[179832] = true,	-- Pillamaster's Ornate Pillow (starts q:28058)
	[179922] = true,	-- Vessel of Tainted Blood (starts q:26524)
	[182053] = true,	-- Glowcap
	[195012] = true,	-- Sunken Scrap Metal (q:13883)
	[195077] = true,	-- Moon-kissed Clay (q:13942)
	[195135] = true,	-- Locking Bolt (q:13983)
	[195136] = true,	-- Bronze Cog (q:13983)
	[195138] = true,	-- Copper Plating (q:13983)
	[201615] = true,	-- Ooze Release Valve (Rotface)
	[201616] = true,	-- Gas Release Valve (Festergut)
	[203071] = true,	-- Night Elf Archaeology Find
	[203179] = true,	-- Sediment Deposit (q:25722)
	[203182] = true,	-- Fenberries (q:25725)
	[203247] = true,	-- Fitzsimmon's Mead (q:25815)
	[203283] = true,	-- Swiftgear Gizmo (q:25853)
	[203285] = true,	-- Swiftgear Gizmo (q:25855)
	[203286] = true,	-- Swiftgear Gizmo (q:25855)
	[203287] = true,	-- Swiftgear Gizmo (q:25855)
	[203288] = true,	-- Swiftgear Gizmo (q:25855)
	[203264] = true,	-- Wobbling Raptor Egg (q:25854)
	[203972] = true,	-- Fresh Dirt (q:26230)
	[203989] = true,	-- Ooze-coated Supply Crate (q:26492)
	[204087] = true,	-- Mosh'Ogg Bounty (q:26782)
	[204102] = true,	-- Shadraspawn Egg (q:26641)
	[204120] = true,	-- Cache of Shadra (q:26529)
	[204133] = true,	-- Cache of Shadra (q:26528)
	[204336] = true,	-- Naga Icon (q:26820)
	[204432] = true,	-- Lime Crate (q:26634)
	[204433] = true,	-- Bloodsail Cannonball (q:26635)
	[204817] = true,	-- Lightforged Rod (ends q:26725, starts q:26753)
	[204824] = true,	-- Lightforged Arch (ends q:26753, starts q:26722)
	[204826] = true,	-- Kurzen Compound Prison Records (q:26735)
	[204827] = true,	-- Kurzen Compound Officers' Dossier (q:26735)
	[205089] = true,	-- Stabthistle Seed (q:27025)
	[205092] = true,	-- Nascent Elementium (q:27077)
	[205216] = true,	-- Neptulon's Cache (Throne of the Tides)
	[205423] = true,	-- Banshee's Bells (q:27369)
	[205537] = true,	-- Open Prayer Book (q:27488)
	[205545] = true,	-- Stray Land Mine (q:27536)
	[205558] = true,	-- Flesh Giant Foot (q:27531)
	[205559] = true,	-- Rotberry Bush (q:27531)
	[205560] = true,	-- Disembodied Arm (q:27531)
	[205826] = true,	-- Thousand-Thread-Count Fuse (q:27600)
	[205827] = true,	-- Extra-Pure Blasting Powder (q:27600)
	[205828] = true,	-- Stack of Questionable Publications (q:27600)
	[205890] = true,	-- Highvale Report (q:27626)
	[205891] = true,	-- Highvale Records (q:27626)
	[205892] = true,	-- Highvale Notes (q:27626)
	[206320] = true,	-- Wild Black Dragon Egg (q:27766)
	[206388] = true,	-- Angor's Coffer (q:27824)
	[206391] = true,	-- Stonard Supplies (q:27851)
	[206498] = true,	-- Dustbelcher Meat (q:27825)
	[206499] = true,	-- Dustbelcher Chest (q:27825)
	[206503] = true,	-- Prayerbloom (q:27875)
	[206573] = true,	-- Dark Ember (q:27964)
	[206597] = true,	-- Twilight's Hammer Crate (q:27985)
	[206659] = true,	-- Dark Iron Bullets (q:28030)
	[206853] = true,	-- Obsidian-Flecked Mud (q:28179)
	[206881] = true,	-- Slumber Sand (q:28181)
	[206882] = true,	-- Fel Slider Cider (q:28181)
	[206947] = true,	-- Tailor's Table (q:28202)
	[206971] = true,	-- War Reaver Parts (q:28226)
	[206972] = true,	-- War Reaver Parts (q:28226)
	[206973] = true,	-- War Reaver Parts (q:28226)
	[206974] = true,	-- War Reaver Parts (q:28226)
	[206977] = true,	-- Blackrock Boots (q:28245)
	[207125] = true,	-- Crate of Left Over Supplies (q:28322)
	[207320] = true,	-- Hero's Call Board
	[207472] = true,	-- Silverbound Treasure Chest
	[207473] = true,	-- Silverbound Treasure Chest
	[207474] = true,	-- Silverbound Treasure Chest
	[207476] = true,	-- Silverbound Treasure Chest
	[207485] = true,	-- Sturdy Treasure Chest
	[207486] = true,	-- Sturdy Treasure Chest
	[207487] = true,	-- Sturdy Treasure Chest
	[207488] = true,	-- Sturdy Treasure Chest
	[207489] = true,	-- Sturdy Treasure Chest
	[207498] = true,	-- Dark Iron Treasure Chest
	[207513] = true,	-- Silken Treasure Chest
	[209275] = true,	-- Tonk Scrap (q:29518)
	[209283] = true,	-- Discarded Weapon (q:29510)
	[209284] = true,	-- Darkblossom (q:29514)
	[209287] = true,	-- Bit of Glass, (q:29516)
	[209366] = true,	-- Portal Energy Focus (Well of Eternity)
	[209447] = true,	-- Portal Energy Focus (Well of Eternity)
	[209448] = true,	-- Portal Energy Focus (Well of Eternity)
	[209506] = true,	-- Stolen Treats, (q:7043 [A], q:6983 [H])
	[216150] = true,	-- Horde Supply Crate (q:32144)
	[220908] = true,	-- Mist-Covered Treasure Chest
	[221689] = true,	-- Ripe Crispfruit
	[221690] = true,	-- Sand-Covered Egg
	[221763] = true,	-- Fire Poppy
	[222684] = true,	-- Glinting Sand
	[222685] = true,	-- Crane Nest
	[241726] = true,	-- Leystone Deposit
	[241743] = true,	-- Felslate Deposit
	[245324] = true,	-- Rich Leystone Deposit
	[245325] = true,	-- Rich Felslate Deposit
	[247875] = true,	-- Boom Bait (q:41278)
	[253280] = true,	-- Leystone Seam
	[253993] = true,	-- Crusty Kvaldir Chest (Maw of Souls)
	[254003] = true,	-- Legion Cache (Vault of the Wardens)
	[255344] = true,	-- Felslate Seam
	[259764] = true,	-- Love Potion No. 13
	[269026] = true,	-- Ancient Gong
	[270040] = true,	-- Nearly-hatching Pterrordax Egg
	[270902] = true,	-- Weathered Shrine
	[270918] = true,	-- Soothing Lilybud (q:47259)
	[271014] = true,	-- Tarkaj's Warblade (q:47317)
	[271554] = true,	-- Veiled Wyrmtongue Chest
	[271561] = true,	-- Dwarf Trap
	[271648] = true,	-- Stolen Idol of Krag'wa
	[271667] = true,	-- Naga Cage
	[271809] = true,	-- Gate (q:47310)
	[271839] = true,	-- Sethrak Cage (q:47317)
	[271840] = true,	-- Sethrak Cage (q:47317)
	[272409] = true,	-- Message Rocket (q:47245)
	[272622] = true,	-- Cursed Treasure
	[272768] = true,	-- Empyrium Deposit
	[272778] = true,	-- Rich Empyrium Deposit
	[272780] = true,	-- Empyrium Seam
	[272782] = true,	-- Astral Glory
	[273443] = true,	-- Void-Seeped Cache
	[273537] = true,	-- Gravebloom (q:51787)
	[273660] = true,	-- Mysterious Trashpile
	[273679] = true,	-- Sethrak Cage
	[273836] = true,	-- Backpack (q:48585)
	[273837] = true,	-- Supply Pouch (q:48585)
	[275074] = true,	-- Small Treasure Chest (Tiragarde Sound)
	[275099] = true,	-- Saurolisk Egg
	[275071] = true,	-- Small Treasure Chest (Tiragarde Sound)
	[275076] = true,	-- Small Treasure Chest (Tiragarde Sound)
	[276236] = true,	-- Star Moss
	[276237] = true,	-- Akunda's Bite
	[276238] = true,	-- Winter's Kiss
	[276616] = true,	-- Monelite Deposit
	[276617] = true,	-- Storm Silver Deposit
	[276618] = true,	-- Platinum Deposit
	[276620] = true,	-- Storm Silver Seam
	[277336] = true,	-- Treasure Chest
	[277526] = true,	-- Freshly Dug Sand (q:49138)
	[277876] = true,	-- Sethrak Cage (q:49334)
	[277899] = true,	-- Sethrak War Banner (q:49327)
	[278716] = true,	-- Treasure Chest (Zuldazar)
	[278150] = true,	-- Pile of Wood (Warfronts)
	[278189] = true,	-- Nazeshi Cage
	[278456] = true,	-- Treasure Chest (Zuldazar)
	[278459] = true,	-- Treasure Chest (Zuldazar)
	[278462] = true,	-- Treasure Chest (Zuldazar)
	[278685] = true,	-- Sethrak Skull (q:49676)
	[278694] = true,	-- Treasure Chest (Zuldazar)
	[278795] = true,	-- Treasure Chest (Zuldazar)
	[279044] = true,	-- Zandalari Rushes
	[279293] = true,	-- Sweetleaf Bush
	[279325] = true,	-- Treasure Chest (Nazmir)
	[279346] = true,	-- Urn of Voices
	[279352] = true,	-- Treasure Chest (Nazmir)
	[279366] = true,	-- Treasure Chest (Nazmir)
	[279378] = true,	-- Treasure Chest (Nazmir)
	[279379] = true,	-- Treasure Chest (Nazmir)
	[280603] = true,	-- Ritual Effigy (q:51657)
	[280611] = true,	-- Ancient Gong (q:50076)
	[281024] = true,	-- Idol of Rezan (q:47738)
	[281079] = true,	-- Star Moss
	[281173] = true,	-- Mysterious Trashpile
	[281385] = true,	-- Mysterious Trashpile
	[281256] = true,	-- Mysterious Trashpile
	[281303] = true,	-- Pterrodax Nest
	[281469] = true,	-- Raptor's Eggs (q:50497)
	[281608] = true,	-- Relic of the Keepers (q:48871)
	[281867] = true,	-- Star Moss
	[281868] = true,	-- Star Moss
	[281870] = true,	-- Riverbud
	[281903] = true,	-- Treasure Chest (Zuldazar)
	[281905] = true,	-- Treasure Chest (Zuldazar)
	[282721] = true,	-- Treasure Chest (Nazmir)
	[282722] = true,	-- Treasure Chest (Nazmir)
	[282723] = true,	-- Treasure Chest (Nazmir)
	[284408] = true,	-- Treasure Chest (Vol'dun)
	[284411] = true,	-- Treasure Chest (Vol'dun)
	[284412] = true,	-- Treasure Chest (Vol'dun)
	[284413] = true,	-- Treasure Chest (Vol'dun)
	[284417] = true,	-- Treasure Chest (Vol'dun)
	[284418] = true,	-- Treasure Chest (Vol'dun)
	[284419] = true,	-- Treasure Chest (Vol'dun)
	[284420] = true,	-- Treasure Chest (Vol'dun)
	[287006] = true,	-- Faithless Weapon Rack (q:49665)
	[287314] = true,	-- Disturbed Sand
	[287490] = true,	-- Cursed Treasure
	[287493] = true,	-- Cursed Treasure
	[288601] = true,	-- Inconspicuous Seaforium Bomb
	[288604] = true,	-- Treasure Chest (Zuldazar)
	[290678] = true,	-- Altar of Gonk
	[290708] = true,	-- Anchor Chains (q:51592)
	[290709] = true,	-- Crate of Canvas (q:51592)
	[290710] = true,	-- Canvas Bolt (q:51592)
	[290711] = true,	-- Anchor Chain (q:51592)
	[290712] = true,	-- Sandworn Blade (q:51602)
	[290718] = true,	-- Place Trap (q:51619 & q:51767)
	[290747] = true,	-- Jambani Stockpile
	[290748] = true,	-- Jambani Stockpile
	[290749] = true,	-- Jambani Stockpile
	[290750] = true,	-- Jambani Stockpile
	[290770] = true,	-- Treasure Chest (Vol'dun)
	[290773] = true,	-- Altar of Akunda
	[290776] = true,	-- Gunpowder Crate (q:51596)
	[290803] = true,	-- Gunpowder Crate (q:51599)
	[290842] = true,	-- Odoriferous Stew (q:51677)
	[290903] = true,	-- Horde Banner (q:51438)
	[290975] = true,	-- Silver Nugget (q:51707 & q:51743)
	[290996] = true,	-- Temple of Rezan Map (q:51679)
	[291213] = true,	-- Small Treasure Chest (Drustvar)
	[291222] = true,	-- Small Treasure Chest (Drustvar)
	[291234] = true,	-- Steaming Fresh Carrion (q:47272)
	[291235] = true,	-- Steaming Fresh Carrion (q:47272)
	[291236] = true,	-- Steaming Fresh Carrion (q:47272)
	[291246] = true,	-- Small Treasure Chest (Stormsong Valley)
	[291261] = true,	-- Woven Idol
	[292764] = true,	-- Metal Scraps (q:52142 & q:52160)
	[292765] = true,	-- Discarded Toolbox (q:52142 & q:52160)
	[292390] = true,	-- Horde Banner (q:52127)
	[292535] = true,	-- Altar of Kimbul (q:47578)
	[293121] = true,	-- Horde Banner (q:52276)
	[293211] = true,	-- Stolen Idol of Krag'wa
	[293297] = true,	-- Horde Banner (q:52314)
	[293314] = true,	-- Horde Banner (q:52320)
	[293351] = true,	-- Truffle
	[293445] = true,	-- Truffle
	[293446] = true,	-- Truffle
	[293449] = true,	-- Truffle
	[293550] = true,	-- Horde Banner (q:52479)
	[293734] = true,	-- Horde Banner (q:52777)
	[296855] = true,	-- Truffle
	[305839] = true,	-- Shortfuse Special
	[307028] = true,	-- Azerite Grenades (q:53950)
	[308100] = true,	-- Engine Gearing (q:53885)
	[308103] = true,	-- Azerite Cannon Balls (q:53885)
	[311174] = true,	-- Volatile Azerite Weapons (q:54177)
	[311182] = true,	-- Crawler Mine Parts (q:54189)
	[311183] = true,	-- Remote Mine Controls (q:54189)
	[312293] = true,	-- Mana Crystal
	[315945] = true,	-- Prisoner Cage (q:54008)
	[315946] = true,	-- Prisoner Cage (q:54008)
	[315947] = true,	-- Prisoner Cage (q:54008)
	[316399] = true,	-- Azerite Chest (q:54644)
	[316434] = true,	-- Azerite Chest
	[322020] = true,	-- Pile of Coins (Armored Vaultbot)
	[322358] = true,	-- Waterlogged Alliance Crate (q:57331)
	[322413] = true,	-- Glimmering Chest
	[322787] = true,	-- Shrine of Torcali (q:55252)
	[325874] = true,	-- Osmenite Seam
	[325875] = true,	-- Osmenite Deposit
	[326594] = true,	-- Arcane Tome
	[326598] = true,	-- Zin'anthid
	[327230] = true,	-- Jelly Deposit
	[327576] = true,	-- Glimmering Chest
	[327577] = true,	-- Glimmering Chest
	[327578] = true,	-- Glimmering Chest
	[334732] = true,	-- Glimmering Chest
	[334733] = true,	-- Glimmering Chest
	[334734] = true,	-- Glimmering Chest
	[334735] = true,	-- Glimmering Chest
	[334736] = true,	-- Glimmering Chest
	[349136] = true,	-- Forgotten Memorandum (q:59717)
	[349274] = true,	-- Forgotten Memorandum (q:59717)
	[350978] = true,	-- Queen's Conservatory Cache
	[352095] = true,	-- Soulbreaker Trap
	[352433] = true,	-- Cache of Eyes
	[353195] = true,	-- Locked Door @ 61.2 60.3 REVENDRETH (q:58391)
	[353947] = true,	-- Discarded Vial
	[354649] = true,	-- Relic Hoard
	[355971] = true,	-- Stoneborn Glaive (q:61402)
	[356560] = true,	-- Explosive Animastore (q:60532)
	[356561] = true,	-- Everburn Lantern (q:60532)
	[356562] = true,	-- Emberlight Lantern (q:60532)
	[356563] = true,	-- Sanguine Rose (q:60532)
	[356596] = true,	-- Feather Cap (q:61406)
	[356597] = true,	-- Lacy Bell Morel (q:61406)
	[368604] = true,	-- Mawsworn Cage
	[375241] = true,	-- Bubble Poppy
	[375290] = true,	-- Cypher Bound Chest
	[375530] = true,	-- Forgotten Treasure Vault
	[376587] = true,	-- Expedition Scout's Pack
	[378802] = true,	-- Corrupted Dragon Egg
	[381042] = true,	-- Shimmering Chest
	[381154] = true,	-- Writhebark
	[381207] = true,	-- Saxifrage
	[381213] = true,	-- Windswept Hochenblume
	[381214] = true,	-- Frigid Hochenblume
	[381515] = true,	-- Hardened Serevite Deposit
	[381519] = true,	-- Infurious Serevite Deposit
	[383732] = true,	-- Tuskarr Tacklebox
	[386521] = true,	-- Toxin Antidote
	[387725] = true,	-- Glowing Crystal (q:74518)
	[387727] = true,	-- Sulfuric Crystal (q:74518)
	[387729] = true,	-- Magma Crystal (q:74518)
	[401844] = true,	-- Smelly Trash Pile
	[403458] = true,	-- Dauntless Draught
	[403740] = true,	-- Cleanbrass Bolts
	[404923] = true,	-- Lost Chest (Hallowfall)
	[405303] = true,	-- Dreamseed Cache
	[405320] = true,	-- Dreamseed Cache
	[405321] = true,	-- Dreamseed Cache
	[405487] = true,	-- Dreamseed Cache
	[405488] = true,	-- Dreamseed Cache
	[405929] = true,	-- Dreamseed Cache
	[405930] = true,	-- Dreamseed Cache
	[405931] = true,	-- Dreamseed Cache
	[405932] = true,	-- Dreamseed Cache
	[406106] = true,	-- Dreamseed Cache
	[406107] = true,	-- Dreamseed Cache
	[406116] = true,	-- Dreamseed Cache
	[406117] = true,	-- Dreamseed Cache
	[406118] = true,	-- Dreamseed Cache
	[406119] = true,	-- Dreamseed Cache
	[406120] = true,	-- Dreamseed Cache
	[406121] = true,	-- Dreamseed Cache
	[406123] = true,	-- Dreamseed Cache
	[406124] = true,	-- Dreamseed Cache
	[406128] = true,	-- Dreamseed Cache
	[406129] = true,	-- Dreamseed Cache
	[406130] = true,	-- Dreamseed Cache
	[406134] = true,	-- Dreamseed Cache
	[406135] = true,	-- Dreamseed Cache
	[406138] = true,	-- Dreamseed Cache
	[406139] = true,	-- Dreamseed Cache
	[406142] = true,	-- Dreamseed Cache
	[406143] = true,	-- Dreamseed Cache
	[406147] = true,	-- Dreamseed Cache
	[406148] = true,	-- Dreamseed Cache
	[406354] = true,	-- Dreamseed Cache
	[406355] = true,	-- Dreamseed Cache
	[406356] = true,	-- Dreamseed Cache
	[406954] = true,	-- Dreamseed Cache
	[406955] = true,	-- Dreamseed Cache
	[406956] = true,	-- Dreamseed Cache
	[406977] = true,	-- Dreamseed Cache
	[406998] = true,	-- Dreamseed Cache
	[407001] = true,	-- Dreamseed Cache
	[407006] = true,	-- Dreamseed Cache
	[409220] = true,	-- Dreamseed Cache
	[409221] = true,	-- Dreamseed Cache
	[409223] = true,	-- Dreamseed Cache
	[409224] = true,	-- Dreamseed Cache
	[409225] = true,	-- Dreamseed Cache
	[409226] = true,	-- Dreamseed Cache
	[409227] = true,	-- Dreamseed Cache
	[409228] = true,	-- Dreamseed Cache
	[409844] = true,	-- Dreamseed Cache
	[409847] = true,	-- Dreamseed Cache
	[409848] = true,	-- Dreamseed Cache
	[408720] = true,	-- Laden Somnut
	[410994] = true,	-- Map of Shadowfang Keep Security (q:78332 [A], q:78982 [H])
	[410998] = true,	-- Formula: Intoxicating Toxic Perfume (q:78332 [A], q:78982 [H])
	[410999] = true,	-- Memo from Apothecary Hummel (q:78332 [A], q:78982 [H])
	[411560] = true,	-- Lavenbloom (q:78565 & q:78986)
	[411561] = true,	-- Sugar Orchid (q:78565 & q:78986)
	[411562] = true,	-- Orange Illicium (q:78565 & q:78986)
	[411656] = true,	-- Hallowfall Scythe
	[411755] = true,	-- Flickerflame Candles (q:78635, q:82519)
	[411930] = true,	-- Blackpowder Barrel
	[413126] = true,	-- Box of Artisanal Goods (q:78369 [A], q:78984 [H])
	[413246] = true,	-- Elemental Silt Mound
	[413590] = true,	-- Bountiful Coffer
	[414701] = true,	-- Cold Coffee
	[416418] = true,	-- Harvest Seed Supply
	[414699] = true,	-- Darkroot Persimmon
	[415296] = true,	-- Repair Kit
	[416448] = true,	-- Lush Lavenbloom (q:78565 & q:78986)
	[416449] = true,	-- Lush Sugar Orchid (q:78565 & q:78986)
	[416450] = true,	-- Lush Orange Illicium (q:78565 & q:78986)
	[419657] = true,	-- Abandoned Tools
	[419696] = true,	-- Waxy Lump
	[421070] = true,	-- Remnent Satchel
	[423714] = true,	-- Duskstem Stalk
	[433370] = true,	-- War Supply Chest
	[434861] = true,	-- Ever-Blossoming Fungi
	[437195] = true,	-- Titan Artifact @ 79.3, 29, 2248 (q:81465)
	[437758] = true,	-- Alliance Weapon Rack (q:82153)
	[437761] = true,	-- Supplies (q:82153)
	[439314] = true,	-- Camp Supplies
	[441181] = true,	-- Research Cache (q:81908)
	[441225] = true,	-- Deepwalker Crate (q:81908)
	[443754] = true,	-- Earthen Coffer
	[444798] = true,	-- Arathi Treasure Hoard
	[444799] = true,	-- Potent Concentrated Shadow
	[444800] = true,	-- Sureki Strongbox
	[444801] = true,	-- Brimming Arathi Treasure Hoard
	[444802] = true,	-- Kobyss Ritual Cache
	[444804] = true,	-- Concentrated Shadow
	[444866] = true,	-- Overflowing Kobyss Ritual Cache
	[446495] = true,	-- Pile of Refuse
	[446496] = true,	-- Enormous Pile of Refuse
	[449528] = true,	-- Opal-Mining Tools
	[451579] = true,	-- Used Fuel Drum (Ringing Deeps)
	[452696] = true,	-- Machine Speaker's Reliquary
	[452706] = true,	-- Deep-Lost Satchel
	[452893] = true,	-- Kaja'mite Stockpile
	[452923] = true,	-- Chillburst Canister (q:83148)
	[452972] = true,	-- Fallow Corn
	[454311] = true,	-- Redberry
	[454312] = true,	-- Redberry
	[455759] = true,	-- Hulking Raptorial Claw
	[456665] = true,	-- Ore Sample
	[456781] = true,	-- Darkfuse Safe
	[457143] = true,	-- Kaja'Cola Can
	[457144] = true,	-- Abandoned Pickaxe
	[457154] = true,	-- Kaja'Cola Can
	[457181] = true,	-- Interesting Notes @ 39, 51.3, 2369 / 67.3, 61.1, 2369 (q:83932)
	[457287] = true,	-- Essence of Death (q:83641)
	[457291] = true,	-- Skull (q:83641)
	[457292] = true,	-- Essence of Death (q:83641)
	[461478] = true,	-- For Rent Sign
	[462533] = true,	-- Spare Excavation Rocket
	[465067] = true,	-- Faded Pages
	[465064] = true,	-- Old Scroll
	[465208] = true,	-- Crystal Chunk (q:84430)
	[467447] = true,	-- G.E.T.A. Needs You! (q: 84885)
	[469857] = true,	-- Overflowing Dumpster
	[469858] = true,	-- Shiny Trash Can
	[473943] = true,	-- Salvageable Scrap (q:85051)
	[474030] = true,	-- Salvageable Scrap (q:85051)
	[474033] = true,	-- Salvageable Scrap (q:85051)
	[474084] = true,	-- Salvageable Scrap (q:85051)
	[474086] = true,	-- Salvageable Scrap (q:85051)
	[474822] = true,	-- Runed Storm Cache (Treasure)
	[475990] = true,	-- Junk Pile
	[478443] = true,	-- Mislaid Curiosity (delve object)
	[478679] = true,	-- Salvage Part
	[479594] = true,	-- Depleted Hotrod Battery
	[487825] = true,	-- Ruffled Pages (q:85589)
	[494499] = true,	-- Seafarer's Cache
	[495091] = true,	-- Improvised Explosive
	[499620] = true,	-- Runed Storm Cache @ 68.4, 73.8, 2369 (q:84726)
	[499863] = true,	-- Runed Storm Cache @ 39.4, 20.1, 2369 (q:84726)
	[499928] = true,	-- Darkfuse Research Notes
	[500096] = true,	-- Unseemly Growth
	[500203] = true,	-- Resold Goods
	[500407] = true,	-- Runed Storm Cache (Treasure)
	[500581] = true,	-- Container of Highly Profitable Sludge
	[500582] = true,	-- Crate of Somewhat Profitable Sludge
	[500583] = true,	-- Box of Lightly Profitable Sludge
	[500640] = true,	-- Metal Scrap (q:86274)
	[500682] = true,	-- Seafarer's Cache
	[500683] = true,	-- Seafarer's Cache
	[500684] = true,	-- Seafarer's Cache
	[500685] = true,	-- Seafarer's Cache
	[500686] = true,	-- Seafarer's Cache
	[503044] = true,	-- Ultra-Pasteurized Flesh Substitute
	[503050] = true,	-- Complainer Container 9000
	[503056] = true,	-- Customer Retrival Harpoons
	[503329] = true,	-- Corroded Plaque
	[503440] = true,	-- Discarded Goods
	[503450] = true,	-- Chunk of Charged Glass
	[503868] = true,	-- Nemesis Strongbox
	[503869] = true,	-- Nemesis Strongbox
	[503870] = true,	-- Nemesis Strongbox
	[503871] = true,	-- Nemesis Strongbox
	[506498] = true,	-- Gilded Stash
	[506640] = true,	-- Faded Journal Page @ 39.3, 54.2, 2369 (q:85571)
	[506696] = true,	-- Buried Treasure
	[507768] = true,	-- Jettisoned Pile of Goblin-Bucks
	[507867] = true,	-- Soggy Journal Page @ 51.4, 75.8, 2369 (q:85571)
	[507868] = true,	-- Stained Journal Page @ 55.8, 14.7, 2369 (q:85571)
	[507869] = true,	-- Torn Journal Page @ 46.1, 47.1, 2369 (q:85571)
	[507870] = true,	-- Weathered Journal Page @ 71, 59.2, 2369 (q:85571)
	[508727] = true,	-- Partially-Drained Battery
	[516163] = true,	-- Half-Empty Bag
	[517672] = true,	-- Emergency Exit (qs: 75874, 83121, 83123, 84121)
}

local ReturnEmptyFunctionMeta = { __index = function() return app.ReturnFalse end}
local EmptyFunctionTable = setmetatable({}, ReturnEmptyFunctionMeta)
local ReturnEmptyTableMeta = { __index = function() return EmptyFunctionTable end}
local IgnoredChecksByType = setmetatable({
	Item = setmetatable({
		coord = app.ReturnTrue,
		provider = app.ReturnTrue,
	}, ReturnEmptyFunctionMeta),
	Player = setmetatable({
		coord = app.ReturnTrue,
		provider = app.ReturnTrue
	}, ReturnEmptyFunctionMeta),
	Creature = setmetatable({
		coord = function(id) return MobileDB.Creature[id] end,
	}, ReturnEmptyFunctionMeta),
	GameObject = setmetatable({
		coord = function(id) return MobileDB.GameObject[id] end,
	}, ReturnEmptyFunctionMeta),
	Vehicle = setmetatable({
		coord = app.ReturnTrue,
	}, ReturnEmptyFunctionMeta),
}, ReturnEmptyTableMeta)

local GuidTypeProviders = {
	Item = "i",
	GameObject = "o",
	Creature = "n",
}

local ProviderTypeChecks = {
	n = function(objID, objRef, providers, providerID)
		-- app.PrintDebug("Check.n",objID,providerID,app:SearchLink(objRef))
		-- app.PrintTable(providers)
		-- app.PrintTable(objRef.qgs)
		local found
		-- n providers are turned into qgs on quest objects
		local qgs = objRef.qgs
		if qgs then
			for _,qg in ipairs(qgs) do
				if qg == providerID then found = 1 break end
			end
		end
		if not found and providers then
			for _,provider in ipairs(providers) do
				if provider[1] == "n" and provider[2] == providerID then found = 1 break end
			end
		end
		if not found then
			local questParent = objRef.parent
			-- this quest is listed directly under an NPC then compare that NPCID
			-- e.g. Garrison NPCs Bronzebeard/Saurfang
			if questParent and questParent.__type == "NPC" and questParent.npcID == providerID then
				found = 1
			end
		end
		if not found then
			AddReportData(objRef.__type,objID, {
				[objRef.key or "ID"] = objID,
				QuestGiver = "Missing Quest Giver: "..providerID..", -- "..(app.NPCNameFromID[providerID] or UNKNOWN),
			})
		end
	end,
	o = function(objID, objRef, providers, providerID)
		if not providers then
			AddReportData(objRef.__type,objID, {
				[objRef.key or "ID"] = objID,
				QuestGiver = "Missing Object Provider: "..providerID..", -- "..(app.ObjectNames[providerID] or UNKNOWN),
			})
			return
		end
		local found
		for _,provider in ipairs(providers) do
			if provider[1] == "o" and provider[2] == providerID then found = 1 break end
		end
		if not found then
			AddReportData(objRef.__type,objID, {
				[objRef.key or "ID"] = objID,
				QuestGiver = "Missing Object Provider: "..providerID..", -- "..(app.ObjectNames[providerID] or UNKNOWN),
			})
		end
	end,
	-- TODO: Items are weird, maybe handle eventually
	-- i = function(objID, objRef, providers, providerID)
	-- end,
}

local function Check_providers(objID, objRef, providerType, id)
	local providerTypeCheck = ProviderTypeChecks[providerType]
	if providerTypeCheck then
		providerTypeCheck(objID, objRef, objRef.providers, id)
	end
end

-- Add a check when interacting with a Quest Giver NPC to verify coordinates of the related Quest
local function OnQUEST_DETAIL(...)
	-- local questStartItemID = ...;
	local questID = GetQuestID();
	-- app.PrintDebug("Contributor.OnQUEST_DETAIL",questID,...)
	if questID == 0 then return end
	-- only check logic when the player is not actually on this quest
	if C_QuestLog_IsOnQuest(questID) then return end
	local objRef = app.SearchForObject("questID", questID, "field")
	-- app.PrintDebug("Contributor.OnQUEST_DETAIL.ref",objRef and objRef.hash)
	if not objRef then
		-- this is reported from Quest class
		return
	end

	local guid = UnitGUID("questnpc") or UnitGUID("npc")
	local providerid, guidtype, _
	if not guid then
		app.print("No Quest check performed for Quest #", questID,"[GUID]")
		return
	end
	-- TODO: would need to be fixed for Item type
	guidtype, _, _, _, _, providerid = ("-"):split(guid)
	providerid = tonumber(providerid)
	if not providerid or not guidtype then
		-- app.print("Unknown Quest Provider",guidtype,providerid,"during Contribute check!")
		if not IgnoredChecksByType[guidtype].provider() then
			app.print("No Quest check performed for Quest #", questID,"[ProviderID]")
		end
		return
	end
	app.PrintDebug(guidtype,providerid,app.NPCNameFromID[providerid] or app.ObjectNames[providerid]," => Quest #", questID)

	-- check coords
	if not IgnoredChecksByType[guidtype].coord(providerid) then
		if not Check_coords(objRef, objRef[objRef.key]) then
			-- is this quest listed directly under an NPC which has coords instead? check that NPC for coords
			-- e.g. Garrison NPCs Bronzebeard/Saurfang
			local questParent = objRef.parent
			if questParent and questParent.__type == "NPC" then
				if not Check_coords(questParent, questParent[questParent.key]) then
					AddReportData(objRef.__type,questID,{
						[objRef.key or "ID"] = questID,
						MissingCoords = "No Coordinates for this quest under NPC!",
					})
				end
			else
				AddReportData(objRef.__type,questID,{
					[objRef.key or "ID"] = questID,
					MissingCoords = "No Coordinates for this quest!",
				})
			end
		end
	end

	-- check provider
	if not IgnoredChecksByType[guidtype].provider(providerid) then
		Check_providers(questID, objRef, GuidTypeProviders[guidtype], providerid)
	end
	-- app.PrintDebug("Contributor.OnQUEST_DETAIL.Done")
end
AddEventFunc("QUEST_DETAIL", OnQUEST_DETAIL)
AddEventFunc("QUEST_PROGRESS", OnQUEST_DETAIL)
AddEventFunc("QUEST_COMPLETE", OnQUEST_DETAIL)

-- PLAYER_SOFT_INTERACT_CHANGED
local LastSoftInteract = {}
local RegisterUNIT_SPELLCAST_START, UnregisterUNIT_SPELLCAST_START
-- Allows automatically tracking nearby ObjectID's and running check functions on them for data verification
local function OnPLAYER_SOFT_INTERACT_CHANGED(previousGuid, newGuid)
	-- app.PrintDebug("PLAYER_SOFT_INTERACT_CHANGED",previousGuid,newGuid)

	-- previousGuid == newGuid when the player distance becomes close enough or far enough to change interaction cursor
	if not newGuid or previousGuid ~= newGuid then
		LastSoftInteract.GuidType = nil
		LastSoftInteract.ID = nil
		UnregisterUNIT_SPELLCAST_START()
		return
	end

	local id, guidtype, _
	guidtype, _, _, _, _, id = ("-"):split(newGuid)
	id = tonumber(id)
	LastSoftInteract.GuidType = guidtype
	LastSoftInteract.ID = id
	-- app.PrintDebug(guidtype,id)

	-- only check object soft-interact (for now)
	if guidtype ~= "GameObject" then return end

	-- close enough to an object to open, track potential looting via mouseclick for a few seconds
	RegisterUNIT_SPELLCAST_START(10)

	local objRef = app.SearchForObject("objectID", id)
	-- only check sourced objects
	if not objRef then return end
	-- app.PrintDebug("GameObject",app:SearchLink(objRef))

	-- check sourced object coords
	if not IgnoredChecksByType[guidtype].coord(id) then
		-- object auto-detect can happen from rather far, so using 2 distance
		local objID = objRef[objRef.key]
		if not Check_coords(objRef, objID, 2) then
			AddReportData(objRef.__type,objID,{
				[objRef.key or "ID"] = objID,
				["objectID"] = id,
				MissingCoords = ("No Coordinates for this %s!"):format(objRef.__type),
			})
		end
	end
end
AddEventFunc("PLAYER_SOFT_INTERACT_CHANGED", OnPLAYER_SOFT_INTERACT_CHANGED)

-- UNIT_SPELLCAST_START
-- Allows handling some special logic in special cases for special spell casts
local SpellIDHandlers = {
	-- Opening (on Objects)
	[6478] = function(source)
		if source ~= "player" then return end

		-- Verify 'Opening' cast, report ObjectID if not Sourced
		local id = LastSoftInteract.ID
		if not id or IgnoredChecksByType.GameObject.coord(id) then return end

		local objRef = app.SearchForObject("objectID", id)
		-- if it's Sourced, we've already checked it via PLAYER_SOFT_INTERACT_CHANGED
		if objRef then return end

		local tooltipName = GameTooltipTextLeft1:GetText()
		objRef = app.CreateObject(id)
		local objID = objRef[objRef.key]
		-- report openable object
		AddReportData(objRef.__type,objID,{
			[objRef.key or "ID"] = objID,
			["objectID"] = id,
			NotSourced = "Openable Object not Sourced!",
			Name = tooltipName or "(No Tooltip Text Available)",
		})
	end
}
-- Other 'Opening' spells
SpellIDHandlers[3365] = SpellIDHandlers[6478]

local RegisteredUNIT_SPELLCAST_START
local function OnUNIT_SPELLCAST_START(...)
	-- app.PrintDebug("UNIT_SPELLCAST_START",...)
	local source, _, id = ...
	local spellHandler = SpellIDHandlers[id]
	if not spellHandler then return end

	spellHandler(source)
end
UnregisterUNIT_SPELLCAST_START = function()
	-- app.PrintDebug("Unregister.UNIT_SPELLCAST_START")
	app:UnregisterEvent("UNIT_SPELLCAST_START")
	RegisteredUNIT_SPELLCAST_START = nil
end
RegisterUNIT_SPELLCAST_START = function(secTilRemove)
	if RegisteredUNIT_SPELLCAST_START then return end
	RegisteredUNIT_SPELLCAST_START = true
	-- app.PrintDebug("Register.UNIT_SPELLCAST_START",secTilRemove)
	app:RegisterFuncEvent("UNIT_SPELLCAST_START",OnUNIT_SPELLCAST_START)
	app.CallbackHandlers.DelayedCallback(UnregisterUNIT_SPELLCAST_START, secTilRemove or 0.5)
end

-- PLAYER_SOFT_TARGET_INTERACTION
-- Allows handling when the player succeeds in interacting with a soft-interact
-- This happens when the player presses the keybind while a soft-interact is active, but not necessarily when it's within range
local function OnPLAYER_SOFT_TARGET_INTERACTION()
	-- app.PrintDebug("PLAYER_SOFT_TARGET_INTERACTION",LastSoftInteract.GuidType,LastSoftInteract.ID)

	-- currently only track interacts on objects
	if LastSoftInteract.GuidType ~= "GameObject" then return end
	-- if ignore check on coords, then also ignore for unsourced
	if IgnoredChecksByType.GameObject.coord(LastSoftInteract.ID) then return end

	-- If the player attempts to interact, hook for spell cast start event
	RegisterUNIT_SPELLCAST_START()
end
AddEventFunc("PLAYER_SOFT_TARGET_INTERACTION", OnPLAYER_SOFT_TARGET_INTERACTION)

-- Contribution setup
local function Contribute(contrib)
	app.Contributor = contrib == 1 and true or nil
	AllTheThingsSavedVariables.Contributor = app.Contributor and 1 or 0
	local contribModule = app.Modules.Contributor or app.EmptyTable
	if app.Contributor then
		app.print("Thanks for helping to contribute to ATT! There may be additional chat and report sounds to help with finding additional discrepancies in ATT data.")
		if contribModule.Events then
			for event,func in pairs(contribModule.Events) do
				-- app.PrintDebug("Contribute.RegisterFuncEvent",event)
				app:RegisterFuncEvent(event,func)
			end
		end
	elseif app.IsReady then
		app.print("Not showing ATT contribution information.")
		if contribModule.Events then
			for event,func in pairs(contribModule.Events) do
				-- app.PrintDebug("Contribute.UnregisterEventClean",event)
				app:UnregisterEventClean(event)
			end
		end
	end
end
-- Allows a user to use /att contribute
-- to opt-in/out of seeing additional reporting/chat/sound functionality to help with refining ATT data
app.ChatCommands.Add("contribute", function(args)
	Contribute(not app.Contributor and 1)
	return true
end, {
	"Usage : /att contribute"
})
app.AddEventHandler("OnReady", function()
	Contribute(AllTheThingsSavedVariables.Contributor)
end)
