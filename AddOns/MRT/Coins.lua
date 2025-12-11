local GlobalAddonName, ExRT = ...

if not ExRT.isMoP then
	return
end

local module = ExRT:New("Coins",ExRT.L.Coins)
local ELib,L = ExRT.lib,ExRT.L

local VMRT = nil

local strsplit = strsplit
local GetSpellInfo = ExRT.F.GetSpellInfo or GetSpellInfo
local GetItemInfo, GetItemInfoInstant, GetItemQualityColor = C_Item and C_Item.GetItemInfo or GetItemInfo, C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant, C_Item and C_Item.GetItemQualityColor or GetItemQualityColor

module.db.spellsCoins = {
	[250541] = L.bossName[2076], --"AN - Boss 1",
	[250574] = L.bossName[2074], --"AN - Boss 2",
	[250575] = L.bossName[2064], --"AN - Boss 3",
	[250576] = L.bossName[2070], --"AN - Boss 4",
	[250577] = L.bossName[2075], --"AN - Boss 5",
	[250578] = L.bossName[2082], --"AN - Boss 6",
	[250579] = L.bossName[2069], --"AN - Boss 7",
	[250580] = L.bossName[2088], --"AN - Boss 8",
	[250581] = L.bossName[2073], --"AN - Boss 9",
	[250582] = L.bossName[2063], --"AN - Boss 10",
	[250583] = L.bossName[2092], --"AN - Boss 11",
	
	[247484] = "Seat of the Triumverate - Boss 01",	--7.0 Dungeon - Seat of the Triumverate - Bonus Roll Loot - Boss 01
	[247485] = "Seat of the Triumverate - Boss 02",	--7.0 Dungeon - Seat of the Triumverate - Bonus Roll Loot - Boss 02
	[247486] = "Seat of the Triumverate - Boss 03",	--7.0 Dungeon - Seat of the Triumverate - Bonus Roll Loot - Boss 03
	[247487] = "Seat of the Triumverate - Boss 04",	--7.0 Dungeon - Seat of the Triumverate - Bonus Roll Loot - Boss 04
	
	[244168] = "7.2.5 World Boss",
	[244170] = "7.2.5 World Boss",
	[244171] = "7.2.5 World Boss",
	[244185] = "7.2.5 World Boss",
	[244186] = "7.2.5 World Boss",
	[244187] = "7.2.5 World Boss",
	
	[244777] = "Cathedral of Eternal Night - Boss 01",	--7.0 Dungeon - Cathedral of Eternal Night - Bonus Roll Loot - Boss 01
	[244778] = "Cathedral of Eternal Night - Boss 02",	--7.0 Dungeon - Cathedral of Eternal Night - Bonus Roll Loot - Boss 02
	[244779] = "Cathedral of Eternal Night - Boss 03",	--7.0 Dungeon - Cathedral of Eternal Night - Bonus Roll Loot - Boss 03
	[244781] = "Cathedral of Eternal Night - Boss 04",	--7.0 Dungeon - Cathedral of Eternal Night - Bonus Roll Loot - Boss 04

	[240641] = L.bossName[2032], --"ToS - Boss 1",
	[240643] = L.bossName[2048], --"ToS - Boss 2",
	[240644] = L.bossName[2036], --"ToS - Boss 3",
	[240645] = L.bossName[2037], --"ToS - Boss 4",
	[240646] = L.bossName[2050], --"ToS - Boss 5",
	[240647] = L.bossName[2054], --"ToS - Boss 6",
	[240648] = L.bossName[2052], --"ToS - Boss 7",
	[240650] = L.bossName[2038], --"ToS - Boss 8",
	[240651] = L.bossName[2051], --"ToS - Boss 9",
	
	[242965] = "7.2 World Boss",
	[242966] = "7.2 World Boss",
	[242967] = "7.2 World Boss",
	[242968] = "7.2 World Boss",
	
	[240051] = "Arena (10v10)",
	[240041] = "Arena (2v2)",
	[240047] = "Arena (3v3)",

	[232424] = L.bossName[1849], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 01
	[232426] = L.bossName[1865], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 02
	[232427] = L.bossName[1867], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 03
	[232428] = L.bossName[1871], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 04
	[232429] = L.bossName[1862], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 05 Tich
	[232430] = L.bossName[1842], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 06 Krosus
	[232431] = L.bossName[1886], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 07 Botanist
	[232432] = L.bossName[1863], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 08
	[232433] = L.bossName[1872], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 09
	[232434] = L.bossName[1866], --7.0 Raid Nighthold - Bonus Roll Loot - Boss 10

	[221037] = L.bossName[1853], --7.0 Raid Nightmare Bonus Roll Loot - Boss 01
	[221039] = L.bossName[1873], --7.0 Raid Nightmare Bonus Roll Loot - Boss 02
	[221040] = L.bossName[1876], --7.0 Raid Nightmare Bonus Roll Loot - Boss 03
	[221041] = L.bossName[1841], --7.0 Raid Nightmare Bonus Roll Loot - Boss 04
	[221042] = L.bossName[1854], --7.0 Raid Nightmare Bonus Roll Loot - Boss 05
	[221044] = L.bossName[1877], --7.0 Raid Nightmare Bonus Roll Loot - Boss 06
	[221045] = L.bossName[1864], --7.0 Raid Nightmare Bonus Roll Loot - Boss 07
	
	[232462] = L.bossName[1958], --7.1 Raid Trial of Valor - Bonus Roll Loot - Boss 01
	[232463] = L.bossName[1962], --7.1 Raid Trial of Valor - Bonus Roll Loot - Boss 02
	[232464] = L.bossName[2008], --7.1 Raid Trial of Valor - Bonus Roll Loot - Boss 03

	[232088] = "Karazhan - Boss 01", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 01
	[232089] = "Karazhan - Boss 02", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 02
	[232090] = "Karazhan - Boss 03", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 03
	[232091] = "Karazhan - Boss 04", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 04
	[232092] = "Karazhan - Boss 05", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 05
	[232093] = "Karazhan - Boss 06", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 06
	[232094] = "Karazhan - Boss 07", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 07
	[232095] = "Karazhan - Boss 08", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 08
	[232096] = "Karazhan - Boss 09", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 09
	[232097] = "Karazhan - Boss 10", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 10
	[232098] = "Karazhan - Boss 11", --7.1 Dungeon - Karazhan - Bonus Roll Loot - Boss 11
	
	[226523] = "Darkheart Thicket - Boss 01", --7.0 Dungeon - Darkheart Thicket - Bonus Roll Loot - Boss 01
	[226524] = "Darkheart Thicket - Boss 02", --7.0 Dungeon - Darkheart Thicket - Bonus Roll Loot - Boss 02
	[226525] = "Darkheart Thicket - Boss 03", --7.0 Dungeon - Darkheart Thicket - Bonus Roll Loot - Boss 03
	[226526] = "Darkheart Thicket - Boss 04", --7.0 Dungeon - Darkheart Thicket - Bonus Roll Loot - Boss 04
	[226533] = "Black Rook Hold - Boss 01", --7.0 Dungeon - Black Rook Hold - Bonus Roll Loot - Boss 01
	[226535] = "Black Rook Hold - Boss 02", --7.0 Dungeon - Black Rook Hold - Bonus Roll Loot - Boss 02
	[226536] = "Black Rook Hold - Boss 03", --7.0 Dungeon - Black Rook Hold - Bonus Roll Loot - Boss 03
	[226538] = "Black Rook Hold - Boss 04", --7.0 Dungeon - Black Rook Hold - Bonus Roll Loot - Boss 04
	[226550] = "Court of Stars - Boss 01", --7.0 Dungeon - Court of Stars - Bonus Roll Loot - Boss 01
	[226552] = "Court of Stars - Boss 02", --7.0 Dungeon - Court of Stars - Bonus Roll Loot - Boss 02
	[226553] = "Court of Stars - Boss 03", --7.0 Dungeon - Court of Stars - Bonus Roll Loot - Boss 03
	[226555] = "Eye of Azshara - Boss 05", --7.0 Dungeon - Eye of Azshara - Bonus Roll Loot - Boss 05
	[226557] = "Eye of Azshara - Boss 02", --7.0 Dungeon - Eye of Azshara - Bonus Roll Loot - Boss 02
	[226558] = "Eye of Azshara - Boss 03", --7.0 Dungeon - Eye of Azshara - Bonus Roll Loot - Boss 03
	[226560] = "Eye of Azshara - Boss 04", --7.0 Dungeon - Eye of Azshara - Bonus Roll Loot - Boss 04
	[226564] = "Eye of Azshara - Boss 01", --7.0 Dungeon - Eye of Azshara - Bonus Roll Loot - Boss 01
	[226565] = "Halls of Valor - Boss 01", --7.0 Dungeon - Halls of Valor - Bonus Roll Loot - Boss 01
	[226566] = "Halls of Valor - Boss 02", --7.0 Dungeon - Halls of Valor - Bonus Roll Loot - Boss 02
	[226567] = "Halls of Valor - Boss 03", --7.0 Dungeon - Halls of Valor - Bonus Roll Loot - Boss 03
	[226568] = "Halls of Valor - Boss 04", --7.0 Dungeon - Halls of Valor - Bonus Roll Loot - Boss 04
	[226569] = "Halls of Valor - Boss 05", --7.0 Dungeon - Halls of Valor - Bonus Roll Loot - Boss 05
	[226570] = "Maw of Souls - Boss 01", --7.0 Dungeon - Maw of Souls - Bonus Roll Loot - Boss 01
	[226571] = "Maw of Souls - Boss 02", --7.0 Dungeon - Maw of Souls - Bonus Roll Loot - Boss 02
	[226572] = "Maw of Souls - Boss 03", --7.0 Dungeon - Maw of Souls - Bonus Roll Loot - Boss 03
	[226573] = "Neltharion's Lair - Boss 01", --7.0 Dungeon - Neltharion's Lair - Bonus Roll Loot - Boss 01
	[226574] = "Neltharion's Lair - Boss 02", --7.0 Dungeon - Neltharion's Lair - Bonus Roll Loot - Boss 02
	[226575] = "Neltharion's Lair - Boss 03", --7.0 Dungeon - Neltharion's Lair - Bonus Roll Loot - Boss 03
	[226576] = "Neltharion's Lair - Boss 04", --7.0 Dungeon - Neltharion's Lair - Bonus Roll Loot - Boss 04
	[226577] = "The Arcway - Boss 01", --7.0 Dungeon - The Arcway - Bonus Roll Loot - Boss 01
	[226578] = "The Arcway - Boss 02", --7.0 Dungeon - The Arcway - Bonus Roll Loot - Boss 02
	[226579] = "The Arcway - Boss 03", --7.0 Dungeon - The Arcway - Bonus Roll Loot - Boss 03
	[226580] = "The Arcway - Boss 04", --7.0 Dungeon - The Arcway - Bonus Roll Loot - Boss 04
	[226581] = "The Arcway - Boss 05", --7.0 Dungeon - The Arcway - Bonus Roll Loot - Boss 05
	[226582] = "Vault of the Wardens - Boss 01", --7.0 Dungeon - Vault of the Wardens - Bonus Roll Loot - Boss 01
	[226583] = "Vault of the Wardens - Boss 02", --7.0 Dungeon - Vault of the Wardens - Bonus Roll Loot - Boss 02
	[226584] = "Vault of the Wardens - Boss 03", --7.0 Dungeon - Vault of the Wardens - Bonus Roll Loot - Boss 03
	[226585] = "Vault of the Wardens - Boss 04", --7.0 Dungeon - Vault of the Wardens - Bonus Roll Loot - Boss 04
	[226586] = "Vault of the Wardens - Boss 05", --7.0 Dungeon - Vault of the Wardens - Bonus Roll Loot - Boss 05
	[226587] = "Violet Hold - Boss 01", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 01
	[226588] = "Violet Hold - Boss 02", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 02
	[226589] = "Violet Hold - Boss 03", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 03
	[226590] = "Violet Hold - Boss 04", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 04
	[226591] = "Violet Hold - Boss 05", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 05
	[226592] = "Violet Hold - Boss 06", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 06
	[226593] = "Violet Hold - Boss 07", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 07
	[226594] = "Violet Hold - Boss 08", --7.0 Dungeon - Violet Hold - Bonus Roll Loot - Boss 08
	
	[227117] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227118] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227119] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227120] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227121] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227122] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227123] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227124] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227125] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227126] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll
	[227127] = "World Boss Bonus Roll", --7.0 Raid World Boss Bonus Roll

	[188958] = "6.2 Raid Bonus Roll Loot - Boss 01",
	[188959] = "6.2 Raid Bonus Roll Loot - Boss 02",
	[188960] = "6.2 Raid Bonus Roll Loot - Boss 03",
	[188961] = "6.2 Raid Bonus Roll Loot - Boss 04",
	[188962] = "6.2 Raid Bonus Roll Loot - Boss 05",
	[188963] = "6.2 Raid Bonus Roll Loot - Boss 06",
	[188964] = "6.2 Raid Bonus Roll Loot - Boss 07",
	[188965] = "6.2 Raid Bonus Roll Loot - Boss 08",
	[188966] = "6.2 Raid Bonus Roll Loot - Boss 09",
	[188967] = "6.2 Raid Bonus Roll Loot - Boss 10",
	[188968] = "6.2 Raid Bonus Roll Loot - Boss 11",
	[188969] = "6.2 Raid Bonus Roll Loot - Boss 12",
	[188970] = "6.2 Raid Bonus Roll Loot - Boss 13",

	[188971] = "6.2 Raid Bonus Roll Loot - World Boss 01",

	[177510] = "Gruul",
	[177511] = "Oregorger",
	[177517] = "Beastlord Darmac",
	[177515] = "Flamebender Ka'graz",
	[177513] = "Hans'gar & Franzok",
	[177518] = "Operator Thogar",
	[177512] = "Blast Furnace",
	[177516] = "Kromog",
	[177519] = "The Iron Maidens",
	[177520] = "Blackhand",

	[177503] = "Kargath Bladefist",
	[177504] = "Butcher",
	[177505] = "Tectus",
	[177506] = "Brackenspore",
	[177507] = "Twin Ogron",
	[177508] = "Ko'ragh",
	[177509] = "Imperator Mar'gok",

	[163435] = "Immerseus",
	[163533] = "Fallen Protectors",
	[165021] = "Norushen",
	[165037] = "Sha of Pride",
	[165038] = "Galakras",
	[165041] = "Iron Juggernaut",
	[165043] = "Dark Shaman",
	[165044] = "General Nazgrim",
	[165045] = "Malkorok",
	[165048] = "Siegecrafter Blackfuse",
	[165046] = "Spoils of Pandaria",
	[165047] = "Thok the Bloodthirsty",
	[165049] = "Klaxxi Paragons",
	[165050] = "Garrosh Hellscream",

	[145923] = "Immerseus",
	[145924] = "Fallen Protectors",
	[145925] = "Norushen",
	[145926] = "Sha of Pride",
	[145927] = "Galakras",
	[145928] = "Iron Juggernaut",
	[145929] = "Dark Shaman",
	[145930] = "General Nazgrim",
	[145931] = "Malkorok",
	[145932] = "Siegecrafter Blackfuse",
	[145933] = "Spoils of Pandaria",
	[145934] = "Thok the Bloodthirsty",
	[145935] = "Klaxxi Paragons",
	[145936] = "Garrosh Hellscream",

	[139673] = "Jin'rokh the Breaker",
	[139659] = "Horridon",
	[139661] = "Zandalari Troll Council",
	[139662] = "Tortos",
	[139663] = "Magaera",
	[139664] = "Ji'kun, the Ancient Mother",
	[139665] = "Durumu the Forgotten",
	[139666] = "Primordious",
	[139667] = "Dark Animus",
	[139669] = "Iron Qon",
	[139670] = "The Empyreal Queens",
	[139671] = "Lei Shen, The Thunder King",
	[139668] = "Ra-den",

	[125145] = "Stone Guard",
	[132171] = "Feng the Accursed",
	[132172] = "Gara'jal the Spiritbinder",
	[132173] = "Spirit Kings",
	[132174] = "Elegon",
	[132175] = "Will of the Emperor",

	[132176] = "Imperial Vizier Zor'lok",
	[132177] = "Blade Lord Tayak",
	[132178] = "Garalon",
	[132179] = "Wind Lord Mel'jarak",
	[132180] = "Amber-Shaper Un'sok",
	[132181] = "Grand Empress Shek'zeer",

	[132182] = "Protectors of the Endless",
	[132186] = "Protectors of the Endless (Elite)",
	[132183] = "Tsulong",
	[132184] = "Lei Shi",
	[132185] = "Sha of Fear",
}
module.db.endCoinTimer = nil
module.db.bonusLootChat = nil
module.db.bonusLootChatSelf = nil
module.db.classNames = ExRT.GDB.ClassList

local function deformat(str)
	str = str:gsub("%.","%%.")
	str = str:gsub("%%s","(.+)")
	
	return str
end

function module.main:ADDON_LOADED()
	VMRT = _G.VMRT
	VMRT.Coins = VMRT.Coins or {}
	VMRT.Coins.list = VMRT.Coins.list or {}
	VMRT.Coins.itemlink = VMRT.Coins.itemlink or {}
	
	module:RegisterEvents('ENCOUNTER_END','ENCOUNTER_START','BOSS_KILL')
	
	module.db.bonusLootChat = deformat(LOOT_ITEM_BONUS_ROLL)
	module.db.bonusLootChatSelf = deformat(LOOT_ITEM_BONUS_ROLL_SELF)
end

do
	local function CoinsTimerEnd()
		module.db.endCoinTimer = nil
		module:UnregisterEvents('UNIT_SPELLCAST_SUCCEEDED','CHAT_MSG_LOOT')
	end
	local BossKillTimer = nil
	function module.main:ENCOUNTER_END(encounterID,encounterName,difficultyID,groupSize,success)
		if success == 1 then
			module:RegisterEvents('CHAT_MSG_LOOT','UNIT_SPELLCAST_SUCCEEDED')
			module.db.endCoinTimer = ExRT.F.ScheduleETimer(module.db.endCoinTimer, CoinsTimerEnd, 180)
		end
		if encounterID == 1594 then
			module:UnregisterEvents('CHAT_MSG_MONSTER_YELL')
		end	
	end
	function module.main:BOSS_KILL(encounterID)
		ExRT.F.Timer(module.main.ENCOUNTER_END, .5, module.main, encounterID, 0, 0, 0, 1, true)
	end
end

function module.main:CHAT_MSG_LOOT(msg, ...)
	if msg:find(module.db.bonusLootChatSelf) then
		local unitName = UnitName("player")
		local itemID = msg:match("|Hitem:(%d+)")
		local class = select(3,UnitClass("player"))
		local itemLink = msg:match("|Hitem:[^|]+|")
		local affixes,numAffixes = ExRT.F.GetItemBonuses(itemLink)
		if numAffixes > 0 then
			affixes = ":"..numAffixes..":"..affixes
		end
		if itemID and itemID ~= "144297" and itemID ~= "147581" then
			VMRT.Coins.list[#VMRT.Coins.list + 1] = "!"..ExRT.F.tohex(class or 0,1)..unitName..time()
			VMRT.Coins.itemlink[#VMRT.Coins.list] = itemLink
		end	
	elseif msg:find(module.db.bonusLootChat) then
		local unitName = msg:match(module.db.bonusLootChat)
		local itemID = msg:match("|Hitem:(%d+)")
		local class
		if unitName and itemID and itemID ~= "144297" and itemID ~= "147581" then
			if UnitName(unitName) then
				class = select(3,UnitClass(unitName))
			end
			local itemLink = msg:match("|Hitem:[^|]+|")
			local affixes,numAffixes = ExRT.F.GetItemBonuses(itemLink)
			if numAffixes > 0 then
				affixes = ":"..numAffixes..":"..affixes
			end
			VMRT.Coins.list[#VMRT.Coins.list + 1] = "!"..ExRT.F.tohex(class or 0,1)..unitName..time()
			VMRT.Coins.itemlink[#VMRT.Coins.list] = itemLink
		end
	end	
end

function module.main:ENCOUNTER_START(encounterID,encounterName,difficultyID,groupSize)
	if encounterID == 1594 then
		module:RegisterEvents('CHAT_MSG_MONSTER_YELL')
	end
end

function module.main:CHAT_MSG_MONSTER_YELL(msg, ...)
	if msg:find(L.CoinsSpoilsOfPandariaWinTrigger) then
		module.main:ENCOUNTER_END(1594,nil,nil,nil,1)
	end	
end

do
	local module_db_spellsCoins = module.db.spellsCoins
	function module.main:UNIT_SPELLCAST_SUCCEEDED(unitID,_,spellID)
		if module_db_spellsCoins[spellID] and unitID:find("^raid%d+$") then
			local name = ExRT.F.UnitCombatlogname(unitID)
			if name then
				local _,className,class = UnitClass(unitID)
				VMRT.Coins.list[#VMRT.Coins.list + 1] = ExRT.F.tohex(class or 0,1)..spellID..name..time()
				
				if VMRT.Coins.ShowMessage then
					local msg = L.CoinsMessage
					print( msg:format( "|c"..ExRT.F.classColor( className or "?" )..name.."|r" ) )
				end
			end
		end
	end
end

function module.options:Load()
	local historyBoxUpdate = nil
	
	self:CreateTilte()

	--ELib:Text(self,L.WaringToRemoveExport,11):Point("BOTTOMLEFT",self.title,"BOTTOMRIGHT",10,0):Color(1,.3,.3):Size(400,0)

	local LINES_COUNT = 50
	local FONT_SIZE = 11
	local currFilter = nil
	
	self.shtml1 = ELib:Text(self,L.CoinsHelp,11):Size(550,200):Point(10,-30):Top()
	
	self.clearButton = ELib:Button(self,L.MarksClear):Size(100,20):Point("TOPRIGHT",-5,-30):Tooltip(L.CoinsClear):OnClick(function() 
		StaticPopupDialogs["EXRT_COINS_CLEAR"] = {
			text = L.CoinsClearPopUp,
			button1 = L.YesText,
			button2 = L.NoText,
			OnAccept = function()
				table.wipe(VMRT.Coins.list)
				table.wipe(VMRT.Coins.itemlink)
				if module.options.textList.ScrollBar:GetValue() == 1 then
					historyBoxUpdate(1)
				else
					module.options.textList.ScrollBar:SetValue(1)
				end
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("EXRT_COINS_CLEAR")
	end) 
	
	local function OptionsScheduledItemInfoEventCancel()
		module.options.GET_ITEM_INFO_RECEIVED_cancel = nil
		module.options:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
	end
	
	local function HandleString(str,itemLink)
		local unitClass,spellID,unitName,timestamp = str:match("^([^!])(%d+)([^0-9]+)(%d+)")
		if spellID and unitClass and unitName and timestamp then
			local spellName = module.db.spellsCoins[tonumber(spellID) or 0]
			if type(spellName) ~= "string" then
				spellName = GetSpellInfo(spellID)
			end
			local classColor = ExRT.F.classColor( module.db.classNames[ tonumber(unitClass,16) ] or "?")
			return date("%d/%m/%y %H:%M:%S ",timestamp),classColor,unitName,spellName,spellID
		else
			local unitClass,unitName,timestamp = str:match("^!(.)(%d+)([^0-9]+)(%d+)(:?.*)")
			if itemLink and unitClass and unitName and timestamp then
				local itemID = tonumber(itemLink:match("item:(%d+)"),10)
				local itemName,_,itemQuality,_,itemReqLevel,_,_,_,_,itemTexture = GetItemInfo(itemLink)
				local itemColor = select(4,GetItemQualityColor(itemQuality or 4))
				local classColor = ExRT.F.classColor( module.db.classNames[ tonumber(unitClass,16) ] or "?")
				return date("%d/%m/%y %H:%M:%S ",timestamp),classColor,unitName,itemLink,itemID,true
			end
		end
		--[[
		/run print'-----'local q,a,s=VMRT.Coins.list,{},{} for i=1,#q do local w,e,r,t,y,u=Q(q[i])if u then a[r]=(a[r] or 0)+1 else s[r]=(s[r] or 0)+1 end end for w,e in pairs(a)do if s[w] and s[w]>20 then print(w,e/s[w],e,s[w])end end
		Q = HandleString
		]]
	end
	local function IsMatchFilter(unitName,spell,spellID,timestamp)
		if unitName:lower():match(currFilter) then
			return 1
		elseif (spell and spell:lower():match(currFilter)) then
			return 2
		elseif (spellID and (tostring(spellID)):match(currFilter) ) then
			return 3
		elseif timestamp and timestamp:lower():match(currFilter) then
			return 4
		end
	end

	local historyBoxUpdateTable = {}
	function historyBoxUpdate(val)
		ExRT.F.table_wipe(historyBoxUpdateTable)
		module.options:RegisterEvent("GET_ITEM_INFO_RECEIVED")
		module.options.GET_ITEM_INFO_RECEIVED_cancel = ExRT.F.ScheduleETimer(module.options.GET_ITEM_INFO_RECEIVED_cancel, OptionsScheduledItemInfoEventCancel, 1.5)
		if currFilter then
			local count = 0
			for i=#VMRT.Coins.list,1,-1 do
				local timestamp,classColor,unitName,spellOrLink,itemIDorSpellID,isItem = HandleString(VMRT.Coins.list[i],VMRT.Coins.itemlink[i])
				local isMatchFilter = IsMatchFilter(unitName,spellOrLink,itemIDorSpellID,timestamp)
				if not isMatchFilter and isItem and VMRT.Coins.list[i-1] then
					local timestamp2,_,unitName2,spell2,spellID2 = HandleString(VMRT.Coins.list[i-1],VMRT.Coins.itemlink[i-1])
					if unitName == unitName2 and IsMatchFilter(unitName2,spell2,spellID2,timestamp2) then
						isMatchFilter = true
					end
				end
				
				if isMatchFilter then
					count = count + 1
					if count >= val and timestamp then
						historyBoxUpdateTable [#historyBoxUpdateTable + 1] = timestamp.."|c"..classColor..unitName.."|r: "..(spellOrLink or "???")
					end
				end
			
				if #historyBoxUpdateTable >= LINES_COUNT then
					break
				end
			end
		else
			for i=(#VMRT.Coins.list-val+1),1,-1 do
				local timestamp,classColor,unitName,spellOrLink,itemIDorSpellID,isItem = HandleString(VMRT.Coins.list[i],VMRT.Coins.itemlink[i])
				local isMatchFilter = not currFilter or IsMatchFilter(unitName,spellOrLink,itemIDorSpellID,timestamp)
				if not isMatchFilter and isItem and VMRT.Coins.list[i-1] then
					local timestamp2,_,unitName2,spell2,spellID2 = HandleString(VMRT.Coins.list[i-1],VMRT.Coins.itemlink[i-1])
					if unitName == unitName2 and IsMatchFilter(unitName2,spell2,spellID2,timestamp2) then
						isMatchFilter = true
					end
				end
				
				if isMatchFilter and timestamp then
					historyBoxUpdateTable [#historyBoxUpdateTable + 1] = timestamp.."|c"..classColor..unitName.."|r: "..(spellOrLink or "???")
				end
			
				if #historyBoxUpdateTable >= LINES_COUNT then
					break
				end
			end
		end
		
		if #historyBoxUpdateTable > 0 then
			module.options.textList:SetText(strjoin("\n",unpack(historyBoxUpdateTable)))
		elseif not currFilter then
			module.options.textList:SetText(L.CoinsEmpty)
		else 
			module.options.textList:SetText(BROWSE_NO_RESULTS)
		end
	end
	
	local function OptionsScheduledItemInfoEventUpdate()
		self.GET_ITEM_INFO_RECEIVED = nil
		historyBoxUpdate( floor(module.options.textList.ScrollBar:GetValue() / FONT_SIZE) + 1 ) 
	end
	self:SetScript("OnEvent",function ()
		if not self.GET_ITEM_INFO_RECEIVED then
			self.GET_ITEM_INFO_RECEIVED = ExRT.F.ScheduleTimer(OptionsScheduledItemInfoEventUpdate, 0.1)
		end
	end)
	
	local function historyBoxShow()
		module.options.textList.ScrollBar:Range(1,max((#VMRT.Coins.list - 40) * FONT_SIZE,1))
		if module.options.textList.ScrollBar:GetValue() == 1 then
			historyBoxUpdate(1)
		else
			module.options.ScrollBar:SetValue(1)
		end
		module.options.textList.ScrollBar:UpdateButtons()
	end
	
	self.filterEditBox = ELib:Edit(self):Size(678,16):Point("TOP",0,-60):Tooltip(FILTER):OnChange(function (self)
		local text = self:GetText()
		local count
		if text == "" then
			currFilter = nil
			count = #VMRT.Coins.list
		else
			currFilter = text:lower()
			count = 0
			local i = 1
			local max = #VMRT.Coins.list
			while true do
				local timestamp,_,unitName,spellName,spellID,isItem = HandleString(VMRT.Coins.list[i],VMRT.Coins.itemlink[i])
				local isMatchFilter = IsMatchFilter(unitName,spellName,spellID,timestamp)
				if isMatchFilter then
					count = count + 1
				end
				i = i + 1
				if isMatchFilter == 2 and not isItem and VMRT.Coins.list[i] then
					local _,_,unitName2,_,_,isItem2 = HandleString(VMRT.Coins.list[i],VMRT.Coins.itemlink[i])
					if isItem2 and unitName2 == unitName then
						count = count + 1
						i = i + 1
					end
				end
				if i > max then
					break
				end
			end
		end
		
		module.options.textList.ScrollBar:Range(1,max((count-40) * FONT_SIZE,1))
		historyBoxUpdate(1)
	end)
	
	self.textList = ELib:MultiEdit2(self):Size(690,510):Point("TOP",0,-85):Font('x',FONT_SIZE):Hyperlinks()
	self.textList.ScrollBar:Range(1,1)
	self.textList.wheelRange = FONT_SIZE

	ELib:Border(self.textList,0)
	
	self.textList.ScrollBar:SetScript("OnShow",historyBoxShow)
	self.textList.ScrollBar:SetScript("OnValueChanged",function (self,val)
		module.options.textList:SetVerticalScroll((val % FONT_SIZE))
		val = floor(val / FONT_SIZE) + 1
		self:UpdateButtons()
		historyBoxUpdate(val)
	end)
	
	self.showMessageChk = ELib:Check(self,L.CoinsShowMessage,VMRT.Coins.ShowMessage):Point("TOPLEFT",self.textList,"BOTTOMLEFT",2,-7):OnClick(function(self,event) 
		if self:GetChecked() then
			VMRT.Coins.ShowMessage = true
		else
			VMRT.Coins.ShowMessage = nil
		end
	end)
	self.showMessageChk:Hide()
	
	self.buttonExport = ELib:Button(self,L.Export):Point("TOPRIGHT",self.textList,"BOTTOMRIGHT",-3,-7):Size(100,20):OnClick(function()
		local text = ""
		local pos = 1
		for i=1,#VMRT.Coins.list do
			local timestamp,classColor,unitName,spellOrLink,itemIDorSpellID,isItem = HandleString(VMRT.Coins.list[pos],VMRT.Coins.itemlink[pos])
			if timestamp then
				local isMatchFilter = not currFilter or IsMatchFilter(unitName,spellOrLink,itemIDorSpellID,timestamp)

				if isItem then
					pos = pos - 1
				end
				
				local itemStr = nil
				if VMRT.Coins.list[pos+1] then
					local timestamp2,classColor2,unitName2,spellOrLink2,itemIDorSpellID2,isItem2 = HandleString(VMRT.Coins.list[pos+1],VMRT.Coins.itemlink[pos+1])
					if isItem2 and unitName2 == unitName then
						local bonus,itemName = spellOrLink2:match(UnitLevel('player')..":0:0:0:(.-)|h%[(.-)%]")
						if not bonus then
							itemStr = '=hyperlink("http://wowhead.com/item='..itemIDorSpellID2..'";"'..itemIDorSpellID2..'")'
						else
							if bonus == '0' then
								bonus = ''
							else
								local newbonus = '&bonus='
								local bonusNum,bonusRest = bonus:match("^([0-9]+):(.+)$")
								bonus = bonusRest
								bonusNum = tonumber(bonusNum)
								for i=1,bonusNum do
									local bonusNow = bonus:match("^([0-9]+)")
									if bonusNow then
										newbonus = newbonus .. bonusNow .. ":"
									end
									bonus = bonus:match("^[0-9]+:(.+)$")
									if not bonus then
										break
									end
								end
								bonus = newbonus:sub(1,-2)
							end
							itemStr = '=hyperlink("http://wowhead.com/item='..itemIDorSpellID2..bonus..'";"'..itemName..'")'
						end
						
						pos = pos + 1
					end
				end
				
				if isMatchFilter then
					local className = nil
					for classN,data in pairs(RAID_CLASS_COLORS) do
						if classColor == data.colorStr then
							className = classN
							break
						end
					end
					text = text .. timestamp.."\t"..unitName.."\t"..(className or "unk").."\t"..spellOrLink.."\t"..(itemStr or "").."\n"
				end
			end
			pos = pos + 1
			if not VMRT.Coins.list[pos] then
				break
			end
		end
		if text ~= "" then
			text = text:sub(1,-2)
		end
		ExRT.F:Export(text)
	end)
	
	historyBoxShow()
end