-- $Id: DB.lua 69 2017-07-02 14:44:27Z arith $
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
-- Functions
local _G = getfenv(0)
local pairs = _G.pairs;
-- Libraries
-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local LibStub = _G.LibStub
local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name);

local function GetLocaleLibBabble(typ)
	local rettab = {}
	local tab = LibStub(typ):GetBaseLookupTable()
	local loctab = LibStub(typ):GetUnstrictLookupTable()
	for k,v in pairs(loctab) do
		rettab[k] = v;
	end
	for k,v in pairs(tab) do
		if not rettab[k] then
			rettab[k] = v;
		end
	end
	return rettab;
end
local BZ = GetLocaleLibBabble("LibBabble-SubZone-3.0")

local function mapFile(mapID)
	return HandyNotes:GetMapIDtoMapFile(mapID)
end

local DB = {}

private.DB = DB

DB.points = {
	--[[ structure:
	[mapFile] = { -- "_terrain1" etc will be stripped from attempts to fetch this
		[coord] = {
			label = [string], 		-- label: text that'll be the label, optional
			npc = [id], 				-- related npc id, used to display names in tooltip
			type = [string], 			-- the pre-define icon type which can be found in Constant.lua
			class = [CLASS NAME],		-- specified the class name so that this node will only be available for this class
			note=[string],			-- additional notes for this node
		},
	},
	--]]
	[mapFile(1021)] = {
		-- /////////////////////////////////
		-- ramp
		-- /////////////////////////////////
		[67843399] = {
			label = format(L["Ramp to %s"], BZ["Screaming Cliffs"]),
			ramp = true,
		},
		[60503315] = {
			label = format(L["Ramp to %s"], BZ["Screaming Cliffs"]),
			ramp = true,
		},
		[71503528] = {
			label = format(L["Ramp to %s"], BZ["Moonlight Ascent"]),
			ramp = true,
		},
		[46833318] = {
			label = format(L["Ramp to %s"], BZ["Broken Valley"]),
			ramp = true,
		},
		-- /////////////////////////////////
		-- Others
		-- /////////////////////////////////
		[47836734] = {
			label = L["Peculiar Rope"],
			note = format(L["Entrance to %s"], BZ["Secret Treasure Lair"]),
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
			hide_indoor = true,
		},
		[44566304] = {
			label = L["Legionfall Construction Table"],
			npc = 122082,
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
			hide_indoor = true,
		},
		[46326193] = {
			label = _G["72_BROKENSHORE_BUILDING_MAGETOWER"],
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
			hide_indoor = true,
		},
		[43746426] = {
			label = _G["72_BROKENSHORE_BUILDING_COMMANDCENTER"],
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
			hide_indoor = true,
		},
		[41526357] = {
			label = _G["72_BROKENSHORE_BUILDING_NETHERDISRUPTOR"],
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
			hide_indoor = true,
		},
		[37177141] = {
			npc = 102695,
			label = L["Drak'thul"],
			others = true,
			icon = private.constants.icon_texture["yellowButton"],
			scale = 0.6,
		},
		[46402066] = {
			npc = 117950,
			label = L["Madam Viciosa <Master Pet Tamer>"],
			note = format("%s: %s, %s, %s", SHOW_PET_BATTLES_ON_MAP_TEXT, BATTLE_PET_DAMAGE_NAME_1, BATTLE_PET_DAMAGE_NAME_6, BATTLE_PET_DAMAGE_NAME_1),
			tamer = true,
			icon = private.constants.icon_texture["blueButton"],
			scale = 0.6
		},
		[39487197] = {
			npc = 117951,
			label = L["Nameless Mystic <Master Pet Tamer>"],
			note = format("%s: %s, %s, %s", SHOW_PET_BATTLES_ON_MAP_TEXT, BATTLE_PET_DAMAGE_NAME_6, BATTLE_PET_DAMAGE_NAME_6, BATTLE_PET_DAMAGE_NAME_7),
			tamer = true,
			icon = private.constants.icon_texture["blueButton"],
			scale = 0.6
		},
		[70004761] = {
			npc = 117934,
			label = L["Sissix <Master Pet Tamer>"],
			note = format("%s: %s, %s, %s", SHOW_PET_BATTLES_ON_MAP_TEXT, BATTLE_PET_DAMAGE_NAME_7, BATTLE_PET_DAMAGE_NAME_9, BATTLE_PET_DAMAGE_NAME_4),
			tamer = true,
			icon = private.constants.icon_texture["blueButton"],
			scale = 0.6
		},
	},
}

-- /////////////////////////////////
-- Veiled Wyrmtongue Chest
-- /////////////////////////////////
DB.treasures = {
	[43364692] = { note=L["Inside the tower"] }, 
	[41543460] = { note=L["Inside the tower"] }, 
	[46175067] = { note=L["Inside the tower"] }, 
	[48881860] = { }, 
	[53321945] = { }, 
	[31113202] = { }, -- Hidden Wyrmtongue Cache
	[32903227] = { }, 
	[30923319] = { }, 
	[30894949] = { note = L["Inside the ship"] }, 
	[33885395] = { note = L["Inside the ship, on the middle deck"] }, 
	[85782973] = { }, 
	[82343119] = { }, 
	[74642968] = { }, -- Hidden Wyrmtongue Cache 
	[70733176] = { }, 
	[69423801] = { }, 
	[67894206] = { }, 
	[78933724] = { }, 
	[76003588] = { }, 
	[72094068] = { }, 
	[73703640] = { }, 
	[72803841] = { note=format(L["Inside %s"], BZ["The Lost Temple"]) },
	[71634155] = { note=format(L["Inside %s"], BZ["The Lost Temple"]) },
--	[71704150] = { }, 
	[82534593] = { }, 
	[85415396] = { }, 
	[60811167] = { }, 
	[64341805] = { }, 
	[70041911] = { }, 
	[68371961] = { }, 
	[63002480] = { }, 
	[60692844] = { note=format(L["Inside %s"], BZ["Felbreach Hollow"]), },
	[63913090] = { note=format(L["Inside %s"], BZ["Felsworn Vault"]), }, 
	[61733145] = { }, 
	[61923303] = { }, 
	[58023097] = { }, 
	[53542790] = { }, 
	[52302990] = { }, 
	[36542434] = { }, 
	[44613358] = { }, 
	[47593475] = { }, 
	[61943917] = { note=L["Inside the tower"] }, 
	[64704550] = { }, 
	[57434353] = { note=L["Inside the tower"] }, 
	[52024150] = { }, 
	[53674568] = { }, 
	[46054346] = { }, 
	[45784677] = { }, 
	[47494687] = { }, 
	[43545217] = { hide_indoor = true, }, 
	[61404996] = { }, 
	[63215176] = { }, 
	[62855389] = { }, 
	[62805260] = { }, 
	[62435501] = { note = L["Inside the ship"] }, 
	[56975687] = { }, 
	[52465950] = { }, 
	[50805970] = { }, 
	[39045828] = { }, 
	[37806130] = { }, 
	[40126099] = { note=format(L["Inside %s"], L["the cave in Stonefin Shoals"]) },
	[42796199] = { note=format(L["Inside %s"], BZ["The Pit of Agony"]) }, 
	[45906380] = { hide_indoor = true, }, 
	[47306700] = { hide_indoor = true, }, 
	[56316504] = { }, 
	[36807161] = { }, 
	[51737059] = { }, 
	[54607400] = { }, 
	[51907700] = { }, 
	[53008180] = { },
	[70003756] = { },
	[55245973] = { },
	[77062089] = { },
	[84962312] = { },
	[48113412] = { },
	[37934293] = { },
	[29486004] = { },
	[58897297] = { },
	[67326740] = { }, -- Hidden Wyrmtongue Cache
	[84556563] = { },
	[30106690] = { },
	[30665770] = { },
	[41941575] = { note=L["On top of the tower"] },
	[57051408] = { },
	[68785685] = { },
	[50018531] = { },
	[40657288] = { },
	[41996717] = { note=format(L["Inside %s"], BZ["The Pit of Agony"]) }, 
	[49087396] = { note = L["Inside the ship"] }, 
	[90555868] = { },
	[89634694] = { },
	[61424307] = { },
	[49844639] = { },
	[50324989] = { },
	[42004277] = { },
	[38613456] = { note=format(L["Inside %s"], BZ["Blood Nest"]),},
	[41373654] = { },
	[41943452] = { },
	[43332648] = { },
	[48273706] = { },
	[28506050] = { },
	[57235293] = { },
	[60985844] = { },
	[58005611] = { note=format(L["Inside %s"], BZ["Feldust Cavern"]) }, 
	[58155875] = { note=format(L["Inside %s"], BZ["Maw of Corruption"]) }, 
	[41105122] = { },
}

for k, v in pairs(DB.treasures) do
	DB.points[mapFile(1021)][k] = v
	DB.points[mapFile(1021)][k]["treasure"] = true
end

-- /////////////////////////////////
-- rare mobs
-- /////////////////////////////////
DB.rares = {
	[57085649] = { npc = 117096, quest = 46094, label = L["Potionmaster Gloop"], },
	[60474504] = { npc = 119718, quest = 46313, label = L["Imp Mother Bruva"], },
	[78322747] = { npc = 121134, quest = 47036, label = L["Duke Sithizi"], },
	[78334004] = { npc = 121046, quest = 47001, label = L["Brother Badatin"], },
	[40385977] = { npc = 120998, quest = 46951, label = L["Flllurlokkr"], note=format(L["Inside %s"], BZ["The Pit of Agony"]), alpha = 0.4 },
	[31315933] = { npc = 121112, quest = 47028, label = L["Somber Dawn"], },
	[39553265] = { npc = 121029, quest = 46965, label = L["Brood Mother Nix"], note = format(L["Inside %s"], BZ["Blood Nest"]), alpha = 0.4 },
	[41601723] = { npc = 121107, quest = 47026, label = L["Lady Eldrathe"], },
	[49553794] = { npc = 117136, quest = 46097, label = L["Doombringer Zar'thoz"], },
	[89473084] = { npc = 117103, quest = 46102, label = L["Felcaller Zelthae"], },
	[51814293] = { npc = 117086, quest = 46093, label = L["Emberfire"], },
	[39194241] = { npc = 117091, quest = 46095, label = L["Felmaw Emberfiend"], },
	[44645317] = { npc = 119629, quest = 46304, label = L["Lord Hel'Nurath"], hide_indoor = true, },
	[58294288] = { npc = 117093, quest = 46099, label = L["Felbringer Xar'thok"], },
	[77842292] = { npc = 121037, quest = 46995, label = L["Grossir"], }, 
	[61913840] = { npc = 117089, quest = 46096, label = L["Inquisitor Chillbane"], },
	[57793148] = { npc = 117095, quest = 46098, label = L["Dreadblade Annihilator"], },
	[59692724] = { npc = 117141, quest = 46090, label = L["Malgrazoth"], note = format(L["Inside %s"], BZ["Felbreach Hollow"]), alpha = 0.4 },
	[54027882] = { npc = 121016, quest = 46953, label = L["Aqueux"], },
	[65233182] = { npc = 117140, quest = 46091, label = L["Salethan the Broodwalker"], hide_indoor = true,},
	-- [54564848] = { npc = 120968, label = L["Bonegnasher the Petrifying"] }, 
	[40348045] = { npc = 118993, quest = 46202, label = L["Dreadeye"], },
	[49114800] = { npc = 117090, quest = 46100, label = L["Xorogun the Flamecarver"], },
	[42404282] = { npc = 117094, quest = 46092, label = L["Malorus the Soulkeeper"], },
	[64443020] = { npc = 116166, quest = 47068, label = L["Eye of Gurgh"], note = format(L["Inside %s"], BZ["Felsworn Vault"]), alpha = 0.4 },
	[60965330] = { npc = 116953, quest = 46101, label = L["Corrupted Bonebreaker"], },
}

for k, v in pairs(DB.rares) do
	DB.points[mapFile(1021)][k] = v
	DB.points[mapFile(1021)][k]["rare"] = true
end

-- /////////////////////////////////
-- Entrance
-- /////////////////////////////////
DB.entrances = {
	[39236010] = { label = format(L["Entrance of %s"], L["the cave in Stonefin Shoals"]), },
	[45456709] = { label = format(L["Entrance of %s"], BZ["The Pit of Agony"]), },
	[55206304] = { label = format(L["Entrance of %s"], BZ["Maw of Corruption"]), },
	[76513982] = { label = format(L["Entrance of %s"], BZ["The Lost Temple"]), },
	[66633456] = { label = format(L["Entrance of %s"], BZ["Felsworn Vault"]), },
	[39713002] = { label = format(L["Entrance of %s"], BZ["Blood Nest"]), },
	[51421720] = { label = format(L["Entrance of %s"], L["Ancient Tomb"]), object = 267640, },
	[56162724] = { label = format(L["Entrance of %s"], BZ["Felbreach Hollow"]), },
	[58555401] = { label = format(L["Entrance of %s"], BZ["Feldust Cavern"]), },
}

for k, v in pairs(DB.entrances) do
	DB.points[mapFile(1021)][k] = v
	DB.points[mapFile(1021)][k]["entrance"] = true
end

-- /////////////////////////////////
-- Ancient Shrine
-- /////////////////////////////////
DB.shrines = {
	[39926032] = { note=format(L["Inside %s"], L["the cave in Stonefin Shoals"]) },
	[33476083] = { },
	[56046540] = { },
	[46006952] = { },
	[40006731] = { },
	[63015318] = { },
	[61324055] = { },
	[45931523] = { },
	[55992764] = { },
	[67844458] = { },
	[73943866] = { },
	[79762779] = { },
	[54631864] = { },
}

for k, v in pairs(DB.shrines) do
	DB.points[mapFile(1021)][k] = v
	--DB.points[mapFile(1021)][k]["label"] = L["Ancient Shrine"]
	DB.points[mapFile(1021)][k]["shrine"] = true
	DB.points[mapFile(1021)][k]["type"] = "greenButton"
	DB.points[mapFile(1021)][k]["object"] = 268435
	DB.points[mapFile(1021)][k]["spell"] = 239933
	DB.points[mapFile(1021)][k]["scale"] = 0.7
end

-- /////////////////////////////////
-- Smoldering Infernal Core
-- /////////////////////////////////
DB.infernalCores = {
	[41524993] = { },
	[33952901] = { },
	[36542880] = { },
	[46263981] = { },
	[46425318] = { hide_indoor = true, },
	[52833097] = { },
	[47625761] = { hide_indoor = true, },
	[54032693] = { },
	[57173114] = { },
}

for k, v in pairs(DB.infernalCores) do
	DB.points[mapFile(1021)][k] = v
	DB.points[mapFile(1021)][k]["infernalCore"] = true
	DB.points[mapFile(1021)][k]["type"] = "redButton"
	DB.points[mapFile(1021)][k]["spell"] = 193713
	DB.points[mapFile(1021)][k]["scale"] = 0.7
end

-- /////////////////////////////////
-- Nether Portal
-- /////////////////////////////////
DB.netherPortals = {
	[54756868] = { },
	[35875749] = { },
	[54344098] = { },
	[56903555] = { },
	[62295847] = { },
	[66394273] = { },
	[46946726] = { },
	[68832629] = { },
	[65843212] = { note = format(L["Inside %s"], BZ["Felsworn Vault"]) },
	[44817662] = { },
	[55592608] = { },
	[55204623] = { },
	--[74572905] = { },
	[74173022] = { }, 
	[41814931] = { },
	[37884518] = { }, 
	[85835436] = { }, 
	
	[67413527] = { }, 
	[61465629] = { }, -- (cave) Lambent Felhunter
	[58005500] = { }, -- (cave)
	[43594284] = { }, 
	[52411096] = { }, -- (crescent ruins)
	[74043414] = { }, 
	[86782758] = { }, 
	
	[36202380] = { },
	[57205610] = { },
	[63302640] = { },
	[62604110] = { },
	
	[41971776] = { },
	
}

for k, v in pairs(DB.netherPortals) do
	DB.points[mapFile(1021)][k] = v
	DB.points[mapFile(1021)][k]["netherPortal"] = true
	DB.points[mapFile(1021)][k]["type"] = "netherPortal"
	--DB.points[mapFile(1021)][k]["spell"] = 240605
	DB.points[mapFile(1021)][k]["npc"] = 120751
end

-- /////////////////////////////////
-- Doom Shroom
-- /////////////////////////////////

DB.shrooms = {
	[66743705] = { },
	[55264636] = { },
}
