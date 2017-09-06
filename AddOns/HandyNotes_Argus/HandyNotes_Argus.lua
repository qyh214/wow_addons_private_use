-- Credits: Katjes (HandyNotes_LegionRaresTreasures)
local Argus = LibStub("AceAddon-3.0"):NewAddon("ArgusRaresTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local iconDefaults = {
    skull_grey = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\RareWhite.blp",
    skull_purple = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\RarePurple.blp",
    skull_blue = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\RareBlue.blp",
    skull_yellow = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\RareYellow.blp",
    battle_pet = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\BattlePet.blp",
	treasure = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\Treasure.blp",
	portal = "Interface\\Addons\\HandyNotes_Argus\\Artwork\\Portal.blp",
	default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
}
local itemTypeMisc = 0;
local itemTypePet = 1;
local itemTypeMount = 2;
local itemTypeToy = 3;
local itemTypeTransmog = 4;

Argus.nodes = { }

local nodes = Argus.nodes
local isTomTomloaded = false
local isDBMloaded = false
local isCanIMogItloaded = false

-- [XXXXYYYY] = { questId, icon, group, label, loot, note, search },
-- /run local find="Crimson Slavermaw"; for i,mid in ipairs(C_MountJournal.GetMountIDs()) do local n,_,_,_,_,_,_,_,_,_,c,j=C_MountJournal.GetMountInfoByID(mid); if ( n == find ) then print(j .. " " .. n); end end
-- /run local find="Uuna's Doll"; for i=0,2500 do local n=C_PetJournal.GetPetInfoBySpeciesID(i); if ( n == find ) then print(i .. " " .. n); end end

-- Antoran Wastes
nodes["ArgusCore"] = {
	[52702950] = { questId=48822, icon="skull_grey", group="rare_aw", label="Watcher Aival", search="aival", loot=nil, note=nil },
	[63902090] = { questId=48809, icon="skull_blue", group="rare_aw", label="Puscilla", search="puscilla", loot={ { 152903, itemTypeMount, 981 } }, note="Entrance to the cave is south east - use the eastern bridge to get there." },
	[53103580] = { questId=48810, icon="skull_blue", group="rare_aw", label="Vrax'thul", search="vrax", loot={ { 152903, itemTypeMount, 981 } }, note=nil },
	[63225754] = { questId=48811, icon="skull_grey", group="rare_aw", label="Ven'orn", search="ven", loot=nil, note="The entrance to the cave is north east from here in the spider area at 66, 54.1" },
	[64304820] = { questId=48812, icon="skull_blue", group="rare_aw", label="Varga", search="varga", loot={ { 153190, itemTypeMisc } }, note=nil },
	[62405380] = { questId=48813, icon="skull_grey", group="rare_aw", label="Lieutenant Xakaar", search="xakaar", loot=nil, note=nil },
	[61906430] = { questId=48814, icon="skull_blue", group="rare_aw", label="Wrath-Lord Yarez", search="yarez", loot={ { 153126, itemTypeToy } }, note=nil },
	[60674831] = { questId=48815, icon="skull_grey", group="rare_aw", label="Inquisitor Vethroz", search="vethroz", loot={ { 151543, itemTypeMisc } }, note=nil },
	[80206230] = { questId=48816, icon="portal", group="rare_aw", label="Portal to Commander Texlaz", loot=nil, note=nil },
	[82006600] = { questId=48816, icon="skull_grey", group="rare_aw", label="Commander Texlaz", search="texlaz", loot=nil, note="Use the portal at 80.2, 62.3 to get on the ship" },
	[73207080] = { questId=48817, icon="skull_blue", group="rare_aw", label="Admiral Rel'var", search="rel", loot={ { 153324, itemTypeTransmog, "Shield" } }, note=nil },
	[75605650] = { questId=48818, icon="skull_grey", group="rare_aw", label="All-Seer Xanarian", search="xana", loot=nil, note=nil },
	[50905530] = { questId=48820, icon="skull_blue", group="rare_aw", label="Worldsplitter Skuul", search="skuul", loot={ { 153312, itemTypeTransmog, "2h Sword" } }, note="May be flying around in circles. Will be near ground sometimes. Not on every round though." },
	[63812199] = { questId=48821, icon="skull_blue", group="rare_aw", label="Houndmaster Kerrax", search="kerrax", loot={ { 152790, itemTypeMount, 955 } }, note=nil },
	[55702190] = { questId=48824, icon="skull_blue", group="rare_aw", label="Void Warden Valsuran", search="valsuran", loot={ { 153319, itemTypeTransmog, "2h Mace" } }, note=nil },
	[60902290] = { questId=48865, icon="skull_grey", group="rare_aw", label="Chief Alchemist Munculus", search="munculus", loot=nil, note=nil },
	[54003800] = { questId=48966, icon="skull_blue", group="rare_aw", label="The Many-Faced Devourer", search="face", loot={ { 153195, itemTypePet, 2136 } }, note=nil },
	[77177319] = { questId=48967, icon="portal", group="rare_aw", label="Portal to Squadron Commander Vishax", loot=nil, note="First find a Smashed Portal Generator from Immortal Netherwalker. Then collect Conductive Sheath, Arc Circuit and Power Cell from Eredar War-Mind and Felsworn Myrmidon. Use the Smashed Portal Generator to unlock the portal to Vishax." },
	[84368118] = { questId=48967, icon="skull_blue", group="rare_aw", label="Squadron Commander Vishax", search="vishax", loot={ { 153253, itemTypeToy } }, note="Use portal at 77.2, 73.2 to get up on the ship" },
	[58001200] = { questId=48968, icon="skull_blue", group="rare_aw", label="Doomcaster Suprax", search="suprax", loot={ { 153194, itemTypeToy } }, note=nil },
	[66981777] = { questId=48970, icon="skull_blue", group="rare_aw", label="Mother Rosula", search="rosula", loot={ { 152903, itemTypeMount, 981 }, { 153252, itemTypePet, 2135 } }, note="Inside cave. Use the eastern bridge. Collect 100 Imp Meat which drop from the imps inside the cave. Use it and place the Disgusting Feast into the green soup at the marked spot." },
	[64948290] = { questId=48971, icon="skull_blue", group="rare_aw", label="Rezira the Seer", search="rezira", loot={ { 153293, itemTypeToy } }, note="Use Observer's Locus Resonator to open a portal to him. Orix the All-Seer (60.2, 45.4) sells it for 500 Intact Demon Eyes." },
	[61703720] = { questId=49183, icon="skull_blue", group="rare_aw", label="Blistermaw", search="blister", loot={ { 152905, itemTypeMount, 979 } }, note=nil },
	[57403290] = { questId=49240, icon="skull_blue", group="rare_aw", label="Mistress Il'thendra", search="thendra", loot={ { 153327, itemTypeTransmog, "Dagger" } }, note=nil },
	[56204550] = { questId=49241, icon="skull_grey", group="rare_aw", label="Gar'zoth", search="zoth", loot=nil, note=nil },


	[59804030] = { questId=0, icon="battle_pet", group="pet_aw", label="One-of-Many", loot=nil, note=nil },
	[76707390] = { questId=0, icon="battle_pet", group="pet_aw", label="Minixis", loot=nil, note=nil },
	[51604140] = { questId=0, icon="battle_pet", group="pet_aw", label="Watcher", loot=nil, note=nil },
	[56605420] = { questId=0, icon="battle_pet", group="pet_aw", label="Bloat", loot=nil, note=nil },
	[56102870] = { questId=0, icon="battle_pet", group="pet_aw", label="Earseeker", loot=nil, note=nil },
	[64106600] = { questId=0, icon="battle_pet", group="pet_aw", label="Pilfer", loot=nil, note=nil },

	-- 48382
	[67546980] = { questId=48382, icon="treasure", group="treasure_aw", label="48382", loot=nil, note="Inside building" },
	[67466226] = { questId=48382, icon="treasure", group="treasure_aw", label="48382", loot=nil, note=nil },
	[71326946] = { questId=48382, icon="treasure", group="treasure_aw", label="48382", loot=nil, note="Next to Hadrox" },
	[58066806] = { questId=48382, icon="treasure", group="treasure_aw", label="48382", loot=nil, note=nil }, -- Doe
	[68026624] = { questId=48382, icon="treasure", group="treasure_aw", label="48382", loot=nil, note="Inside legion structure" },
	-- 48383
	[56903570] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[57633179] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[52182918] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[58174021] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[51863409] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[55133930] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	[58413097] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note="Inside building, floor level" },
	[53753556] = { questId=48383, icon="treasure", group="treasure_aw", label="48383", loot=nil, note=nil },
	-- 48384
	[60872900] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note=nil },
	[61332054] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note="Inside Munculus building" },
	[59081942] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note="Inside building" },
	[64152305] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note="Inside Houndmaster Kerrax cave" },
	[66621709] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note="Inside Imp cave, next to Mother Rosula" },
	[63682571] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note=nil },
	[61862236] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note="Outside, next to Chief Alchemist Munculus" },
	[64132738] = { questId=48384, icon="treasure", group="treasure_aw", label="48384", loot=nil, note=nil }, -- Doe
	-- 48385
	[50605720] = { questId=48385, icon="treasure", group="treasure_aw", label="48385", loot=nil, note=nil },
	[50655715] = { questId=48385, icon="treasure", group="treasure_aw", label="48385", loot=nil, note=nil },
	[55544743] = { questId=48385, icon="treasure", group="treasure_aw", label="48385", loot=nil, note=nil },
	[57135124] = { questId=48385, icon="treasure", group="treasure_aw", label="48385", loot=nil, note=nil },
	[55915425] = { questId=48385, icon="treasure", group="treasure_aw", label="48385", loot=nil, note=nil }, -- Doe
	-- 48387
	[69403965] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note=nil },
	[66643654] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note=nil },
	[68983342] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note=nil },
	[65522831] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note="Under the bridge" },
	[63613643] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note=nil }, -- Doe
	[73404669] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note="Jump over the ooze" },
	[67954006] = { questId=48387, icon="treasure", group="treasure_aw", label="48387", loot=nil, note=nil },
	-- 48388
	[51502610] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note=nil },
	[59261743] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note=nil },
	[55921387] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note=nil },
	[55841722] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note=nil },
	[55622042] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note="Near Valsuran, jump up the rocky slope" },
	[59661398] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note=nil }, -- Doe
	[54102803] = { questId=48388, icon="treasure", group="treasure_aw", label="48388", loot=nil, note="Near Aivals plattform" },
	-- 48389
	[64305040] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note="In Vargas cave" },
	[60254351] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note=nil },
	[65514081] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note=nil },
	[60304675] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note=nil },
	[65345192] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note="In cave behind Varga" },
	[64114242] = { questId=48389, icon="treasure", group="treasure_aw", label="48389", loot=nil, note="Under rocks" },
	-- 48390
	[81306860] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note="On ship" },
	[80406152] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note=nil },
	[82566503] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note="On ship" },
	[73316858] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note="Top level next to Admiral Rel'var" },
	[77127529] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note="Next to Vishax Portal" },
	[72527293] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note="Behind Rel'var" },
	[77255876] = { questId=48390, icon="treasure", group="treasure_aw", label="48390", loot=nil, note=nil },
	-- 48391
	[64135867] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="In Ven'orn spider cave" },
	[67404790] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note=nil },
	[63615622] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="In Ven'orn spider cave" },
	[65005049] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="Outside in spider area" },
	[63035762] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="In Ven'orn spider cave" },
	[65185507] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="Upper entrance to spider area" },
	[68095075] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="Inside small cave in spider area" },
	[69815522] = { questId=48391, icon="treasure", group="treasure_aw", label="48391", loot=nil, note="Outside in spider area" },
	-- Shoot First, Loot Later
	-- Requires 48201 Reinforce Light's Purchase
	[58765894] = { questId=49017, icon="treasure", group="treasure_aw", label="Forgotten Legion Supplies", loot=nil, note="Rocks block the way. Use Cracked Radinax Control Gem to get past them. (Use Lightforged Warframe when available.)" },
	[65973977] = { questId=49018, icon="treasure", group="treasure_aw", label="Ancient Legion War Cache", loot={ { 153308, itemTypeTransmog, "1h Mace" } }, note="Carefully jump down to reach the little cave. Gilder helps a lot. Remove rocks with Lights's Judgment." },
	[52192708] = { questId=49019, icon="treasure", group="treasure_aw", label="Fel-Bound Chest", loot=nil, note="Start a little south east, at 53.7, 30.9. Jump over the rocks to reach the cave. Rocks block the way into the cave. Remove them with Lights's Judgment." },
	[75595267] = { questId=49021, icon="treasure", group="treasure_aw", label="Timeworn Fel Chest", loot=nil, note="Start at All-Seer Xanarian. Run past his building on the left side. Hop down a few rocks to reach the chest surrounded by green ooze." },

}

-- Krokuun
nodes["ArgusSurface"] = {
	[44390734] = { questId=48561, icon="skull_blue", group="rare_kr", label="Khazaduum", search="khaz", loot={ { 153316, itemTypeTransmog, "2h Sword" } }, note="Entrance is south east at 50.3, 17.3" },
	[33007600] = { questId=48562, icon="skull_grey", group="rare_kr", label="Commander Sathrenael", search="sathr", loot=nil, note=nil },
	[44505870] = { questId=48564, icon="skull_blue", group="rare_kr", label="Commander Endaxis", search="endax", loot={ { 153255, itemTypeTransmog, "1h Mace" } }, note=nil },
	[53403090] = { questId=48565, icon="skull_blue", group="rare_kr", label="Sister Subversia", search="subv", loot={ { 153124, itemTypeToy } }, note=nil },
	[58007480] = { questId=48627, icon="skull_grey", group="rare_kr", label="Siegemaster Voraan", search="vora", loot=nil, note=nil },
	[55508020] = { questId=48628, icon="skull_blue", group="rare_kr", label="Talestra the Vile", search="talestra", loot={ { 153329, itemTypeTransmog, "Dagger" } }, note=nil },
	[38145920] = { questId=48563, icon="skull_blue", group="rare_kr", label="Commander Vecaya", search="vecaya", loot={ { 153299, itemTypeTransmog, "1h Sword" } }, note="The path up to her starts east at 42, 57.1" },
	[60802080] = { questId=48629, icon="skull_grey", group="rare_kr", label="Vagath the Betrayed", search="vagat", loot=nil, note=nil },
	[69605750] = { questId=48664, icon="skull_blue", group="rare_kr", label="Tereck the Selector", search="tere", loot={ { 153263, itemTypeTransmog, "1h Axe" } }, note=nil },
	[69708050] = { questId=48665, icon="skull_grey", group="rare_kr", label="Tar Spitter", search="tar", loot=nil, note=nil },
	[41707020] = { questId=48666, icon="skull_grey", group="rare_kr", label="Imp Mother Laglath", search="lagla", loot=nil, note=nil },
	[70503370] = { questId=48667, icon="skull_blue", group="rare_kr", label="Naroua", search="naroua", loot={ { 153190, itemTypeMisc } }, note=nil },

	[43005200] = { questId=0, icon="battle_pet", group="pet_kr", label="Baneglow", loot=nil, note=nil },
	[51506380] = { questId=0, icon="battle_pet", group="pet_kr", label="Foulclaw", loot=nil, note=nil },
	[66847263] = { questId=0, icon="battle_pet", group="pet_kr", label="Ruinhoof", loot=nil, note=nil },
	[29605790] = { questId=0, icon="battle_pet", group="pet_kr", label="Deathscreech", loot=nil, note=nil },
	[39606650] = { questId=0, icon="battle_pet", group="pet_kr", label="Gnasher", loot=nil, note=nil },
	[58302970] = { questId=0, icon="battle_pet", group="pet_kr", label="Retch", loot=nil, note=nil },

	-- 47752
	[56108050] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note=nil }, -- todo:verify
	[55555863] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Jump on the rocks, start slightly west" },
	[52185431] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Run the path up to the top where you've first seen Alleria" },
	[50405122] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Run the path up to the top where you've first seen Alleria" },
	[53265096] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Run the path up to the top where you've first seen Alleria. On the other side of the green ooze. Fel hurts!" },
	[57005472] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Under the rock outcropping, on the tiny lip of land" }, -- Doe
	[59695196] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note="Near to Xeth'tal, behind the rocks." }, -- todo:verify
	[51425958] = { questId=47752, icon="treasure", group="treasure_kr", label="47752", loot=nil, note=nil },
	-- 47753
	[53137304] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note=nil },
	[55228114] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note=nil },
	[59267341] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note=nil },
	[56118037] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note="Outside Talestra building" },
	[58597958] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note="Behind demon spike" },
	[58197157] = { questId=47753, icon="treasure", group="treasure_kr", label="47753", loot=nil, note=nil }, -- Doe
	-- 47997
	[45876777] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note="Under rock, next to bridge" },
	[45797753] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note=nil }, -- Doe
	[43858139] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note="Path starts at 49.1, 69.3. Follow the ridge southwards till you reach the chest." },
	[43816689] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note="Under rocks. Jump down from path near bridge." },
	[40687531] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note=nil }, -- Doe
	[46996831] = { questId=47997, icon="treasure", group="treasure_kr", label="47997", loot=nil, note="On top of serpent skull" },
	-- 47999
	[62592581] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note=nil },
	[59763951] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note=nil },
	[59071884] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note="Up, behind rocks" },
	[61643520] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note=nil },
	[61463580] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note="Inside building" },
	[59603052] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note="Bridge level" },
	[60891852] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note="Inside hut behind Vagath" },
	[49063350] = { questId=47999, icon="treasure", group="treasure_kr", label="47999", loot=nil, note=nil },
	-- 48000
	[70907370] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil },
	[74136790] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil },
	[75166435] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note="Back end of cave" },
	[69605772] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil },
	[69787836] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note="Jump up the slope next to it" },
	[68566054] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note="In front of Tereck the Selector's cave" },
	[72896482] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil },
	[71827536] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil }, -- Doe
	[73577146] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note=nil }, -- Doe
	[71846166] = { questId=48000, icon="treasure", group="treasure_kr", label="48000", loot=nil, note="Climb up the tipped pillar" },
	-- 48336
	[33515510] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note=nil },
	[32047441] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note=nil },
	[27196668] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note=nil },
	[31936750] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note=nil },
	[35415637] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note="Ground level, in front of bottom entrance to the Xenedar" },
	[29645761] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note="Inside cave" },
	[40526067] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note="Inside yellow hut" }, -- Doe
	[36205543] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note="Inside the Xenadar, upper level" }, -- Doe
	[25996814] = { questId=48336, icon="treasure", group="treasure_kr", label="48336", loot=nil, note=nil },
	-- 48339
	[68533891] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },
	[63054240] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },
	[64964156] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },
	[73393438] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },
	[72213234] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note="Behind the giant skull" }, -- Doe
	[65983499] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },
	[64934217] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note="Inside tree trunk" },
	[67713454] = { questId=48339, icon="treasure", group="treasure_kr", label="48339", loot=nil, note=nil },

	-- Shoot First, Loot Later
	[51407622] = { questId=48884, icon="treasure", group="treasure_kr", label="Krokul Emergency Cache", loot={ { 153304, itemTypeTransmog, "1h Axe" } }, note="Cave is up on the cliffs. Rocks block the way. Use Cracked Radinax Control Gem to get past them. (Use Lightforged Warframe when available.)" },
	[62783753] = { questId=48885, icon="treasure", group="treasure_kr", label="Legion Tower Chest", loot=nil, note="On the path to Naroua there are boulders blocking the way to this chest. Remove them with Light's Judgement." },
	[48555894] = { questId=48886, icon="treasure", group="treasure_kr", label="Lost Krokul Chest", loot=nil, note="In little cave along the path. Use Light's Judgment to remove the boulders." },
}

nodes["ArgusCitadelSpire"] = {
	[38954032] = { questId=48561, icon="skull_grey", group="rare_kr", label="Khazaduum", loot=nil, note=nil },
}

-- Mac'Aree
nodes["ArgusMacAree"] = {
	[55705990] = { questId=0, icon="skull_blue", group="rare_ma", label="Wrangler Kravos", loot=nil, note=nil },
	[43806020] = { questId=0, icon="skull_grey", group="rare_ma", label="Baruut the Bloodthirsty", loot=nil, note=nil },
	[36302360] = { questId=0, icon="skull_grey", group="rare_ma", label="Vigilant Thanos", loot=nil, note=nil },
	[33704750] = { questId=0, icon="skull_blue", group="rare_ma", label="Venomtail Skyfin", loot=nil, note=nil },
	[27202980] = { questId=0, icon="skull_grey", group="rare_ma", label="Captain Faruq", loot=nil, note=nil },
	[30304040] = { questId=0, icon="skull_grey", group="rare_ma", label="Ataxon", loot=nil, note=nil },
	[35505870] = { questId=0, icon="skull_grey", group="rare_ma", label="Herald of Chaos", loot=nil, note="He's on the 2nd floor." },
	[48504090] = { questId=0, icon="skull_grey", group="rare_ma", label="Jed'hin Champion Vorusk", loot=nil, note=nil },
	[58003090] = { questId=0, icon="skull_grey", group="rare_ma", label="Overseer Y'Sorna", loot=nil, note=nil },
	[61405020] = { questId=0, icon="skull_grey", group="rare_ma", label="Instructor Tarahna", loot=nil, note=nil },
	[56801450] = { questId=0, icon="skull_grey", group="rare_ma", label="Commander Xethgar", loot=nil, note=nil },
	[49505280] = { questId=0, icon="skull_grey", group="rare_ma", label="Slithon the Last", loot=nil, note=nil },
	[44607160] = { questId=0, icon="skull_grey", group="rare_ma", label="Shadowcaster Voruun", loot=nil, note=nil },
	[65306750] = { questId=0, icon="skull_grey", group="rare_ma", label="Soultwisted Monstrosity", loot=nil, note=nil },
	[38705580] = { questId=0, icon="skull_blue", group="rare_ma", label="Kaara the Pale", loot=nil, note=nil },
	[41301160] = { questId=0, icon="skull_grey", group="rare_ma", label="Feasel the Muffin Thief", loot=nil, note=nil },
	[63806460] = { questId=0, icon="skull_grey", group="rare_ma", label="Vigilant Kuro", loot=nil, note=nil },
	[39206660] = { questId=0, icon="skull_grey", group="rare_ma", label="Turek the Lucid", loot=nil, note=nil },
	[35203720] = { questId=0, icon="skull_grey", group="rare_ma", label="Umbraliss", loot=nil, note=nil },
	[70404670] = { questId=0, icon="skull_grey", group="rare_ma", label="Sorolis the Ill-Fated", loot=nil, note=nil },
	[44204980] = { questId=0, icon="skull_blue", group="rare_ma", label="Sabuul", loot=nil, note=nil },
	[59203770] = { questId=0, icon="skull_grey", group="rare_ma", label="Overseer Y'Beda", loot=nil, note=nil },
	[60402970] = { questId=0, icon="skull_grey", group="rare_ma", label="Overseer Y'Morna", loot=nil, note=nil },
	[64002950] = { questId=0, icon="skull_grey", group="rare_ma", label="Zul'tan the Numerous", loot=nil, note=nil },
	[49700990] = { questId=0, icon="skull_blue", group="rare_ma", label="Skreeg the Devourer", loot=nil, note=nil },

	[60007110] = { questId=0, icon="battle_pet", group="pet_ma", label="Gloamwing", loot=nil, note=nil },
	[67604390] = { questId=0, icon="battle_pet", group="pet_ma", label="Bucky", loot=nil, note=nil },
	[74703620] = { questId=0, icon="battle_pet", group="pet_ma", label="Mar'cuus", loot=nil, note=nil },
	[69705190] = { questId=0, icon="battle_pet", group="pet_ma", label="Snozz", loot=nil, note=nil },
	[31903120] = { questId=0, icon="battle_pet", group="pet_ma", label="Corrupted Blood of Argus", loot=nil, note=nil },
	[36005410] = { questId=0, icon="battle_pet", group="pet_ma", label="Shadeflicker", loot=nil, note=nil },
}


local function GetItem(ID)
    if (ID == "1220" or ID == "1508") then
        local currency, _, _ = GetCurrencyInfo(ID)

        if (currency ~= nil) then
            return currency
        else
            return "Error loading CurrencyID"
        end
    else
        local _, item, _, _, _, _, _, _, _, _ = GetItemInfo(ID)

        if (item ~= nil) then
            return item
        else
            return "Error loading ItemID"
        end
    end
end 

local function GetIcon(ID)
    if (ID == "1220") then
        local _, _, icon = GetCurrencyInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    else
		local _, _, _, _, icon = GetItemInfoInstant(ID)
        --local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    end
end

function Argus:OnEnter(mapFile, coord)
    if (not nodes[mapFile][coord]) then return end
    
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

    if ( self:GetCenter() > UIParent:GetCenter() ) then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    tooltip:SetText(nodes[mapFile][coord]["label"])
    if (	( Argus.db.profile.show_loot == true ) and
			( nodes[mapFile][coord]["loot"] ~= nil ) and
			( type(nodes[mapFile][coord]["loot"]) == "table" ) ) then
		local ii;
		local loot = nodes[mapFile][coord]["loot"];
		for ii = 1, #loot do
			-- loot
			if ( loot[ii][2] == itemTypeMount ) then
				-- check mount known
				local n,_,_,_,_,_,_,_,_,_,c,j=C_MountJournal.GetMountInfoByID( loot[ii][3] );
				if ( c == true ) then
					tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFF00FF00Mount known|r)"), nil, nil, nil, true)
				else
					tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFFFF0000Mount missing|r)"), nil, nil, nil, true)
				end
			elseif ( loot[ii][2] == itemTypePet ) then
				-- check pet quantity
				local n,m = C_PetJournal.GetNumCollectedInfo( loot[ii][3] );
				tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (Pet " .. n .. "/" .. m .. ")"), nil, nil, nil, true)
			elseif ( loot[ii][2] == itemTypeToy ) then
				-- check toy known
				if ( PlayerHasToy( loot[ii][1] ) == true ) then
					tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFF00FF00Toy known|r)"), nil, nil, nil, true)
				else
					tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFFFF0000Toy missing|r)"), nil, nil, nil, true)
				end
			elseif ( isCanIMogItloaded == true and loot[ii][2] == itemTypeTransmog ) then
				-- check transmog known with canimogit
				local _,itemLink = GetItemInfo( loot[ii][1] );
				if ( itemLink ~= nil ) then
					if ( CanIMogIt:PlayerKnowsTransmog( itemLink ) ) then
						tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFF00FF00" .. loot[ii][3] .. "|r)"), nil, nil, nil, true)
					else
						tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (|cFFFF0000" .. loot[ii][3] .. "|r)"), nil, nil, nil, true)
					end
				else
					tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (" .. loot[ii][3] .. ")"), nil, nil, nil, true)
				end
			elseif ( loot[ii][2] == itemTypeTransmog ) then
				-- show transmog without check
				tooltip:AddLine(("" .. GetItem(loot[ii][1]) .. " (" .. loot[ii][3] .. ")"), nil, nil, nil, true)
			else
				-- default show itemLink
				tooltip:AddLine(("" .. GetItem(loot[ii][1])), nil, nil, nil, true)
			end
		end
    end
	if ( Argus.db.profile.show_notes == true and nodes[mapFile][coord]["note"] and nodes[mapFile][coord]["note"] ~= nil ) then
		-- note
		tooltip:AddLine(("" .. nodes[mapFile][coord]["note"]), nil, nil, nil, true)
	end

    tooltip:Show()
end

local isMoving = false
local info = {}
local clickedMapFile = nil
local clickedCoord = nil

local function LRTHideDBMArrow()
    DBM.Arrow:Hide(true)
end

local function LRTDisableTreasure(button, mapFile, coord)
    if (nodes[mapFile][coord]["questId"] ~= nil) then
        Argus.db.char[mapFile .. coord .. nodes[mapFile][coord]["questId"]] = true;
    end

    Argus:Refresh()
end

local function LRTResetDB()
    table.wipe(Argus.db.char)
    Argus:Refresh()
end

local function LRTaddtoTomTom(button, mapFile, coord)
    if isTomTomloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord]["label"];

        TomTom:AddMFWaypoint(mapId, nil, x, y, {
            title = desc,
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end

local function LRTAddDBMArrow(button, mapFile, coord)
    if isDBMloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if not DBMArrow.Desc:IsShown() then
            DBMArrow.Desc:Show()
        end

        x = x*100
        y = y*100
        DBMArrow.Desc:SetText(desc)
        DBM.Arrow:ShowRunTo(x, y, nil, nil, true)
    end
end

local finderFrame = CreateFrame("Frame");
finderFrame:SetScript("OnEvent", function( self, event )
	self:UnregisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	-- LFGListFrame.SearchPanel.SearchBox:SetText(self.search);
end );

local function LRTLFRsearch( button, search, label )
	if ( search ~= nil ) then
		finderFrame.search = search;
		local c,zone,_,_,name = C_LFGList.GetActiveEntryInfo();
		if c == true then
			if ( UnitIsGroupLeader("player") ) then
				print( "Old group delisted. Click again to search groups for " .. label .. "." );
				C_LFGList.RemoveListing();
			else
				print( "Insufficient rights. You are not the group leader." );
			end
		else
			if not GroupFinderFrame:IsVisible() then
				PVEFrame_ShowFrame("GroupFinderFrame");
			end
			GroupFinderFrameGroupButton4:Click();
			LFGListFrame.SearchPanel.SearchBox:SetText( search );
			LFGListCategorySelection_SelectCategory( LFGListFrame.CategorySelection, 6, 0 );
			LFGListFrame.SearchPanel.SearchBox:SetText( search );
			LFGListCategorySelectionFindGroupButton_OnClick( LFGListFrame.CategorySelection.FindGroupButton );			
			LFGListFrame.SearchPanel.SearchBox:SetText( search );
			
			finderFrame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
		end
	end
end

local function LRTLFRcreate( button, label )
	local c,zone,_,_,name = C_LFGList.GetActiveEntryInfo();
	if c == true and name ~= label then
		if ( UnitIsGroupLeader("player") ) then
			print( "Old group delisted. Click again to search groups for " .. label .. "." );
			C_LFGList.RemoveListing();
		else
			print( "Insufficient rights. You are not the group leader." );
		end
	elseif ( c == false ) then
		print( "Created group for " .. label .. "." );
		-- 16 = custom
		C_LFGList.CreateListing(16,label,0,0,"","Created with HandyNotes_Argus",true)
	end
end

local function generateMenu(button, level)
    if (not level) then return end

    for k in pairs(info) do info[k] = nil end

    if (level == 1) then
        info.isTitle = 1
        info.text = "Argus"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
        info.disabled = nil
        info.isTitle = nil
        info.notCheckable = nil

		if ( (string.find(nodes[clickedMapFile][clickedCoord]["group"], "rare") ~= nil)) then
			info.text = "Find group"
			if ( nodes[clickedMapFile][clickedCoord]["search"] ~= nil ) then
				info.func = LRTLFRsearch
				info.arg1 = nodes[clickedMapFile][clickedCoord]["search"]
				info.arg2 = nodes[clickedMapFile][clickedCoord]["label"]
				UIDropDownMenu_AddButton(info, level)
			end

			info.text = "Create group finder listing"
			info.func = LRTLFRcreate
			info.arg1 = nodes[clickedMapFile][clickedCoord]["label"]
			UIDropDownMenu_AddButton(info, level)
		end

        info.text = "Remove this Object from the Map"
        info.func = LRTDisableTreasure
        info.arg1 = clickedMapFile
        info.arg2 = clickedCoord
        UIDropDownMenu_AddButton(info, level)
        
        if isTomTomloaded == true and false then
            info.text = "Add this location to TomTom waypoints"
            info.func = LRTaddtoTomTom
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
        end

        if isDBMloaded == true and false then
            info.text = "Add this treasure as DBM Arrow"
            info.func = LRTAddDBMArrow
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
            
            info.text = "Hide DBM Arrow"
            info.func = LRTHideDBMArrow
            UIDropDownMenu_AddButton(info, level)
        end

        info.text = CLOSE
        info.func = function() CloseDropDownMenus() end
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = "Restore Removed Objects"
        info.func = LRTResetDB
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
    end
end

local HandyNotes_ArgusDropdownMenu = CreateFrame("Frame", "HandyNotes_ArgusDropdownMenu")
HandyNotes_ArgusDropdownMenu.displayMode = "MENU"
HandyNotes_ArgusDropdownMenu.initialize = generateMenu

function Argus:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and down then
		-- context menu
        clickedMapFile = mapFile
        clickedCoord = coord
        ToggleDropDownMenu(1, nil, HandyNotes_ArgusDropdownMenu, self, 0, 0)
	elseif button == "MiddleButton" and down then
		-- create group
		if ( (string.find(nodes[mapFile][coord]["group"], "rare") ~= nil)) then
			LRTLFRcreate( nil, nodes[mapFile][coord]["label"] );
		end
	elseif button == "LeftButton" and down then
		-- find group
		LRTLFRsearch( nil, nodes[mapFile][coord]["search"], nodes[mapFile][coord]["label"] );
    end
end

function Argus:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local options = {
    type = "group",
    name = "Argus Rares & Treasures",
    desc = "Locations of treasures on Argus",
    get = function(info) return Argus.db.profile[info.arg] end,
    set = function(info, v) Argus.db.profile[info.arg] = v; Argus:Refresh() end,
    args = {
        desc = {
            name = "General Settings",
            type = "description",
            order = 0,
        },
        icon_scale_treasures = {
            type = "range",
            name = "Icon Scale for Treasures",
            desc = "The scale of the icons",
            min = 0.25, max = 10, step = 0.01,
            arg = "icon_scale_treasures",
            order = 1,
        },
        icon_alpha_treasures = {
            type = "range",
            name = "Icon Alpha for Treasures",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha_treasures",
            order = 2,
        },
        icon_scale_rares = {
            type = "range",
            name = "Icon Scale for Rares",
            desc = "The scale of the icons",
            min = 0.25, max = 10, step = 0.01,
            arg = "icon_scale_rares",
            order = 3,
        },
        icon_alpha_rares = {
            type = "range",
            name = "Icon Alpha for Rares",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha_rares",
            order = 4,
        },
        icon_scale_pets = {
            type = "range",
            name = "Icon Scale for Battle Pets",
            desc = "The scale of the icons",
            min = 0.25, max = 10, step = 0.01,
            arg = "icon_scale_pets",
            order = 5,
        },
        icon_alpha_pets = {
            type = "range",
            name = "Icon Alpha for Battle Pets",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha_pets",
            order = 6,
        },
        VisibilityOptions = {
            type = "group",
            name = "Visibility Settings",
            desc = "Visibility Settings",
            args = {
                VisibilityGroup = {
                    type = "group",
                    order = 0,
                    name = "Select what to show:",
                    inline = true,
                    args = {
                        groupAW = {
                            type = "header",
                            name = "Antoran Wastes",
                            desc = "Antoran Wastes ",
                            order = 0,
                        },
                        treasureAW = {
                            type = "toggle",
                            arg = "treasure_aw",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            order = 1,
                            width = "normal",
                        },
                        rareAW = {
                            type = "toggle",
                            arg = "rare_aw",
                            name = "Rares",
                            desc = "Rare spawns",
                            order = 2,
                            width = "normal",
                        },
                        petAW = {
                            type = "toggle",
                            arg = "pet_aw",
                            name = "Battle Pets",
                            order = 3,
                            width = "normal",
                        },
                        groupKR = {
                            type = "header",
                            name = "Krokuun",
                            desc = "Krokuun",
                            order = 10,
                        },  
                        treasureKR = {
                            type = "toggle",
                            arg = "treasure_kr",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 11,
                        },
                        rareKR = {
                            type = "toggle",
                            arg = "rare_kr",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 12,
                        },
                        petKR = {
                            type = "toggle",
                            arg = "pet_kr",
                            name = "Battle Pets",
                            width = "normal",
                            order = 13,
                        },
                        groupMA = {
                            type = "header",
                            name = "Mac'Aree",
                            desc = "Mac'Aree",
                            order = 20,
                        },  
                        treasureMA = {
                            type = "toggle",
                            arg = "treasure_ma",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 21,
                        },
                        rareMA = {
                            type = "toggle",
                            arg = "rare_ma",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 22,
                        },  
                        petMA = {
                            type = "toggle",
                            arg = "pet_ma",
                            name = "Battle Pets",
                            width = "normal",
                            order = 23,
                        },  
                    },
                },
                alwaysshowrares = {
                    type = "toggle",
                    arg = "alwaysshowrares",
                    name = "Also show already looted Rares",
                    desc = "Show every rare regardless of looted status",
                    order = 100,
                    width = "full",
                },
                alwaysshowtreasures = {
                    type = "toggle",
                    arg = "alwaysshowtreasures",
                    name = "Also show already looted Treasures",
                    desc = "Show every treasure regardless of looted status",
                    order = 101,
                    width = "full",
                },
                show_loot = {
                    type = "toggle",
                    arg = "show_loot",
                    name = "Show Loot",
                    desc = "Add loot information to the tooltip",
                    order = 102,
                },
                show_notes = {
                    type = "toggle",
                    arg = "show_notes",
                    name = "Show Notes",
                    desc = "Add helpful notes to the tooltip if available",
                    order = 103,
                },
            },
        },
    },
}

function Argus:OnInitialize()
    local defaults = {
        profile = {
            icon_scale_treasures = 2,
            icon_scale_rares = 1.5,
            icon_scale_pets = 1.5,
            icon_alpha_treasures = 0.5,
			icon_alpha_rares = 1.0,
			icon_alpha_pets = 1.0,
            alwaysshowrares = false,
            alwaysshowtreasures = false,
            save = true,
            treasure_aw = true,
            treasure_kr = true,
            treasure_ma = true,
            rare_aw = true,
            rare_kr = true,
            rare_ma = true,
			pet_aw = true,
			pet_kr = true,
			pet_ma = true,
            show_loot = true,
            show_notes = true,
        },
    }

    self.db = LibStub("AceDB-3.0"):New("HandyNotesArgusDB", defaults, "Default")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "WorldEnter")
end

function Argus:WorldEnter()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:ScheduleTimer("RegisterWithHandyNotes", 8)
	self:ScheduleTimer("LoadCheck", 6)
end

function Argus:RegisterWithHandyNotes()
    do
		local currentMapFile = "";
        local function iter(t, prestate)
            if not t then return nil end

            local coord, node = next(t, prestate)

            while coord do
                if (node["questId"] and self.db.profile[node["group"]] and not Argus:HasBeenLooted(currentMapFile,coord,node)) then
					-- preload items
                    if ((node["loot"] ~= nil) and (type(node["loot"]) == "table")) then
						local ii
						for ii = 1, #node["loot"] do
							GetIcon(node["loot"][ii][1])
						end
                    end

					local iconScale = 1;
					local iconAlpha = 1;
					if ( (string.find(node["group"], "rare") ~= nil)) then
						iconScale = Argus.db.profile.icon_scale_rares;
						iconAlpha = Argus.db.profile.icon_alpha_rares;
					elseif ( (string.find(node["group"], "treasure") ~= nil)) then
						iconScale = Argus.db.profile.icon_scale_treasures;
						iconAlpha = Argus.db.profile.icon_alpha_treasures;
					elseif ( (string.find(node["group"], "pet") ~= nil)) then
						iconScale = Argus.db.profile.icon_scale_pets;
						iconAlpha = Argus.db.profile.icon_alpha_pets;
					end
                    return coord, nil, iconDefaults[node["icon"]], iconScale, iconAlpha
                end

                coord, node = next(t, coord)
            end
        end

        function Argus:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
			currentMapFile = mapFile;
            return iter, nodes[mapFile], nil
        end
    end

    HandyNotes:RegisterPluginDB("HandyNotesArgus", self, options)
    self:RegisterBucketEvent({ "LOOT_CLOSED" }, 2, "Refresh")
    self:Refresh()
end
 
function Argus:Refresh()
    self:SendMessage("HandyNotes_NotifyUpdate", "HandyNotesArgus")
end

function Argus:HasBeenLooted(mapFile,coord,node)
    if (self.db.profile.alwaysshowtreasures and (string.find(node["group"], "treasure") ~= nil)) then return false end
    if (self.db.profile.alwaysshowrares and (string.find(node["group"], "rare") ~= nil)) then return false end
    if (node["questId"] and node["questId"] == 0) then return false end
    if (Argus.db.char[mapFile .. coord .. node["questId"]] and self.db.profile.save) then return true end
    if (IsQuestFlaggedCompleted(node["questId"])) then
        return true
    end

    return false
end

function Argus:LoadCheck()
	if (IsAddOnLoaded("TomTom")) then 
		isTomTomloaded = true
	end

	if (IsAddOnLoaded("DBM-Core")) then 
		isDBMloaded = true
	end

	if (IsAddOnLoaded("CanIMogIt")) then 
		isCanIMogItloaded = true
	end

	if isDBMloaded == true then
		local ArrowDesc = DBMArrow:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		ArrowDesc:SetWidth(400)
		ArrowDesc:SetHeight(100)
		ArrowDesc:SetPoint("CENTER", DBMArrow, "CENTER", 0, -35)
		ArrowDesc:SetTextColor(1, 1, 1, 1)
		ArrowDesc:SetJustifyH("CENTER")
		DBMArrow.Desc = ArrowDesc
	end
end
