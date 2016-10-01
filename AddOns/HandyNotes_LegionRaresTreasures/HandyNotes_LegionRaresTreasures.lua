LegionRaresTreasures = LibStub("AceAddon-3.0"):NewAddon("LegionRaresTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)

if not HandyNotes then return end

local iconDefaults = {
    skull_grey = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIcon.blp",
    skull_blue = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconBlue.blp",
	default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
--[[swprare = "Interface\\Icons\\Trade_Archaeology_Fossil_SnailShell",
    shrine = "Interface\\Icons\\inv_misc_statue_02",
    glider = "Interface\\Icons\\inv_feather_04",
    rocket = "Interface\\Icons\\ability_mount_rocketmount",
    unknown = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\chest_normal_daily.tga",
    skull_green = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconGreen.tga", 
    skull_orange = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconOrange.tga",
    skull_purple = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconPurple.tga",
    skull_red = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconRed.tga",
    skull_yellow = "Interface\\Addons\\HandyNotes_LegionRaresTreasures\\Artwork\\RareIconYellow.tga",]]
}
local PlayerFaction, _ = UnitFactionGroup("player")
LegionRaresTreasures.nodes = { }

local nodes = LegionRaresTreasures.nodes
local isTomTomloaded = false
local isDBMloaded = false

nodes["Azsuna"] = {
	[58381229]={ "37980", "Treasure Chest", "Artifact Power", "You need to use a ley portal at 58.7 to 14.1", "default", "treasure_azs","131751"},
    [57901220]={ "37958", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[51502435]={ "42289", "Treasure Chest", "Artifact Power", "Inside a cave, entrance is at 47.8 to 23.7", "default", "treasure_azs","138783"},
	[56443481]={ "38251", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs","132950"},
	[58364378]={ "37830", "Glimmering Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[53543982]={ "42284", "Small Treasure Chest", "Artifact Power", "There are two treasures in the temple", "default", "treasure_azs","131795"},
	[53543982]={ "42285", "Small Treasure Chest", "Artifact Power", "There are two treasures in the temple", "default", "treasure_azs","131795"},
    [42600810]={ "38367", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[55905690]={ "38365", "Disputed Treasure", "Artifact Power", "", "default", "treasure_azs","138783"},
	[62405840]={ "42273", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[63005420]={ "42278", "Small Treasure Chest", "Artifact Power", "cave entrance at 64.0 to 52.9", "default", "treasure_azs","138783"},
	[65462961]={ "42958", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[53504545]={ "42283", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs","138783"},
	[47860773]={ "42295", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[55621855]={ "40711", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[53611813]={ "44104", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[63231521]={ "37832", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[68872973]={ "44103", "Small Treasure Chest", "Artifact Power", "in an underwater cave, entrance is at the east side of the cliff", "default", "treasure_azs", "138783"},
	[56892499]={ "42338", "Small Treasure Chest", "Artifact Power", "cave entrance is at 55.7 to 25.4", "default", "treasure_azs", "138783"},
	[55362774]={ "42288", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[57153106]={ "38419", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[54313633]={ "42287", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[53033726]={ "37596", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[66064345]={ "40751", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[62814479]={ "42294", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[50465211]={ "44081", "Trecherous Stallions", "Artifact Power", "You need to take the ley portal at 60.35 to 46.31 to get to them. a small treasure chest spawns after killing both stallions", "default", "treasure_azs", "140685"},
	[58645340]={ "40752", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[59876316]={ "42272", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[65066978]={ "38239", "Seemingly Unguarded Treasure", "Crit Ring", "5 Enemies spawn after clicking. defeat them and loot the treasure again", "default", "treasure_azs", "129070"},
	[53176444]={ "37829", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[49415800]={ "38370", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[54875214]={ "44405", "Small Treasure Chest", "Artifact Power", "all npcs in the area will be aggro", "default", "treasure_azs", "138783"},
	[49384536]={ "37828", "Treasure Chest", "Artifact Power + Toy", "", "default", "treasure_azs", "122681"},
	[50215029]={ "42290", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[52004210]={ "42281", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[53684396]={ "42282", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[63653919]={ "42293", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[49653448]={ "37831", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[44473946]={ "37713", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[40575767]={ "38316", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[26254713]={ "44105", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[41393075]={ "42292", "Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[34583556]={ "44102", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[43392242]={ "42297", "Glimmering Treasure Chest", "Artifact Power", "the path up the mountain starts at 39.14 to 32.84", "default", "treasure_azs", "138783"},
	[52842059]={ "42339", "Treasure Chest", "Artifact Power", "cave entrance is at 53.95 to 22.43 | The bears will keep sleeping unless you disturb them", "default", "treasure_azs", "138783"},

	[52382304]={ "38268", "Cailyn Paledoom", "Haste/Mastery Leather Helmet", "", "skull_grey", "rare_azs", "129063"},
	[43172813]={ "38352", "Doomlord Kazrok", "Int/Crit  Trinket", "", "skull_grey", "rare_azs", "129056"},
	[34963391]={ "42505", "Arcanist Shal'iman", "Crit/Haste Cloth Bracer", "circles the pool", "skull_grey", "rare_azs", "141868"},
	[30774799]={ "42286", "Houndmaster Stroxis", "Crit/Haste Mail Belt", "", "skull_grey", "rare_azs", "141873"},
	[29275366]={ "42417", "Bilebrain", "Crit/Haste Leather Boots", "", "skull_grey", "rare_azs", "129079"},
	[37374318]={ "42280", "Vorthax", "Crit/Mastery Mail Chest", "", "skull_grey", "rare_azs", "141875"},
	[32292972]={ "38238", "Beacher", "Haste/Versatility Plate Shoulder", "patrols the beach", "skull_grey", "rare_azs", "129067"},
	[49105519]={ "37909", "Warbringer Mox'na", "Crit/Haste Mail Wrist", "patrols on the road with to felhunters", "skull_grey", "rare_azs", "129069"},
	[49500880]={ "37928", "Normantis the Deposed", "Crit/Haste Cloth Helmet", "", "skull_grey", "rare_azs", "129061"},
	[56102906]={ "38061", "Pridelord Meowl", "Haste/Mastery Leather Helmet", "", "skull_grey", "rare_azs", "138395"},
	[35305030]={ "38037", "Infernal Lord", "Crit/Mastery Plate Helmet", "Cache of Infernals", "skull_grey", "rare_azs","129083"},
	[32604880]={ "44108", "Ragemaw", "Haste/Mastery Cloak", "", "skull_grey", "rare_azs","129075"},
	[47303460]={ "37726", "Valyaka the Stormbringer", "Haste/Mastery Cloth Gloves", "", "skull_grey", "rare_azs","129082"},
	[50803160]={ "37869", "Daggerbeak", "Haste/Mastery Leather Pants", "", "skull_grey", "rare_azs","129084"},
	[59601230]={ "37932", "Arcavellus", "Crit/Haste Cloth Shoulder", "Defeat multiple waves of mobs after activating the unbound rift", "skull_grey", "rare_azs","129085"},
	[45305780]={ "37824", "Flog the Captain-Eater", "Crit/Haste Cloak", "", "skull_grey", "rare_azs","129090"},
	[65545679]={ "42221", "Chief Bitterbrine", "Crit/Haste Ring", "", "skull_grey", "rare_azs","129073"},
	[61306200]={ "38217", "Tide Behemoth", "Haste/Versatility Mail Helmet", "", "skull_grey", "rare_azs","129062"},
	[59705520]={ "37822", "The Oracle", "Crit/Mastery Cloth Pants", "", "skull_grey", "rare_azs","129065"},
	[41054178]={ "37537", "Ravyn-Drath", "Haste/Mastery Leather Gloves", "", "skull_grey", "rare_azs","129080"},
	[67105140]={ "37989", "Syphonus/Leodrath", "Crit/Haste Plate Pants", "!!! LEVEL 110 !!!", "skull_blue", "rare_azs","129064"},
    [50003440]={ "37823", "Mrrgrl the Tidereaver", "Crit/Haste Necklace", "", "skull_grey", "rare_azs","129072"},
	[53404400]={ "37821", "Captain Volo'ren", "Haste/Mastery Leather Shoulder", "", "skull_grey", "rare_azs","129066"},
	[55104590]={ "42450", "Brawlgoth", "Haste/Mastery Plate Belt", "", "skull_grey", "rare_azs","129086"},
	[65164000]={ "37820", "Golza the Iron Fin", "Agility/Mastery Trinket", "", "skull_grey", "rare_azs","129091"},
	[59304630]={ "38212", "Brogozog", "Haste/Mastery Mail Shoulder", "on top of the mountain", "skull_grey", "rare_azs", "129068"},
	[33404120]={ "44670", "Broodmother Lizax", "Haste/Mastery Leather Chest", "", "skull_grey", "rare_azs", "141869"},
	[43572444]={ "42069", "Felwing", "Crit/Mastery Leather Bracer", "the path up the mountain starts at 39.14 to 32.84", "skull_grey", "rare_azs", "129087"},
}

nodes["Valsharah"] = {
	[65867918]={ "38391", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[56008376]={ "38861", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[56225730]={ "39072", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[62707040]={ "39069", "Small Treasure Chest", "Artifact Power", "On the balcony on the second floor", "default", "treasure_val","138783"},
	[63007700]={ "39070", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[61657372]={ "39087", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[38456530]={ "39080", "Small Treasure Chest", "Artifact Power", "In the cellar. Requires the Quest -The Farmsteads- to reach", "default", "treasure_val","138783"},
	[45106114]={ "39083", "Small Treasure Chest", "Artifact Power", "Up on the tree", "default", "treasure_val","138783"},
	[63904556]={ "44139", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[54506048]={ "39097", "Treasure Chest", "Artifact Power", "in a cave", "default", "treasure_val","130152"},
	[54187061]={ "39093", "Small Treasure Chest", "Artifact Power", "in a cave", "default", "treasure_val","138783"},
	[54417419]={ "38359", "Small Treasure Chest", "Artifact Power", "in the house behind the wooden curtain", "default", "treasure_val","138783"},
	[51247777]={ "38388", "Small Treasure Chest", "Artifact Power", "Cave entrance at 50.9 to 77", "default", "treasure_val","138783"},
	[54958054]={ "38861", "Small Treasure Chest", "Artifact Power", "in a cave underwater", "default", "treasure_val","138783"},
	[48998615]={ "38886", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[46448630]={ "38277", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[44358257]={ "38387", "Treasure Chest", "Artifact Power", "in a cave below the inn, entrance is right behind the building one floor down", "default", "treasure_val","141892"},
	[43068822]={ "44138", "Treasure Chest", "Artifact Power", "Cave entrance at 43.7 to 89.9", "default", "treasure_val","138783"},
	[48687379]={ "38366", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[43397589]={ "38363", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[33815826]={ "39081", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[42665801]={ "39077", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[38626718]={ "39079", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[43225488]={ "39084", "Treasure Chest", "Artifact Power", "On top of the wall", "default", "treasure_val","138783"},
	[39945460]={ "38369", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[41404560]={ "39085", "Small Treasure Chest", "Artifact Power", "Entrance is on top of the wall at 41.4 to 45.6", "default", "treasure_val","138783"},
	[41404560]={ "39086", "Glimmering Treasure Chest", "Artifact Power", "Entrance is on top of the wall at 41.4 to 45.6", "default", "treasure_val","138783"},
	[55557762]={ "38466", "Unguarded Thistlemaw Treasure", "Pet", "It isn't really unguarded", "default", "treasure_val","130147"},
	[61073421]={ "39088", "Treasure Chest", "Artifact Power", "underwater in the roots", "default", "treasure_val","138783"},
	[68334060]={ "39073", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[66284122]={ "39108", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[67215928]={ "38782", "Treasure Chest", "Artifact Power", "cave entrace at 65.9 to 56.3", "default", "treasure_val","138783"},
	[70225704]={ "38783", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[69475999]={ "38781", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[67395342]={ "38386", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[64715126]={ "38355", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[54003489]={ "38390", "Glimmering Treasure Chest", "Artifact Power", "cave entrance at 53.2 to 38.0", "default", "treasure_val","141891"},
	[62076737]={ "39071", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[63277401]={ "39102", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[61017917]={ "39089", "Glimmering Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[62708526]={ "44136", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[64608546]={ "38900", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[60498216]={ "38893", "Small Treasure Chest", "Artifact Power", "cave entrance at 62.1 to 86.16", "default", "treasure_val","138783"},
	[65398629]={ "39074", "Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	[59887228]={ "38943", "Small Treasure Chest", "Artifact Power", "upstairs, right stairwell", "default", "treasure_val", "138783"},
	[73835437]={ "44135", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val", "138783"},
	[73803227]={ "38371", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val", "138783"},
	[63378841]={ "38389", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_val","138783"},
	
	[60359065]={ "38887", "Elindya Featherlight", "Haste/Mastery Cloth Boots", "Ress her then follow her and kill Skul'vrax", "skull_grey", "rare_val","130115"},
	[59747747]={ "38468", "Gorebeak", "Pet", "Speak to Lorel Sagefeather to summon him", "skull_grey", "rare_val","130154"},
	[52788750]={ "38889", "Shivering Ashmaw Cub", "Pet", "", "skull_grey", "rare_val","128690"},
	[65805344]={ "40126", "Grelda the Hag", "Crit/Haste Necklace", "", "skull_grey", "rare_val","130122"},
	[62604750]={ "38780", "Thondrax", "Crit/Mastery Mail Bracer", "", "skull_grey", "rare_val","130121"},
	[60314427]={ "39858", "Dreadbog", "Crit/Haste Cloak", "", "skull_grey", "rare_val","130125"},
	[44145209]={ "38767", "Darkshade", "Pet", "bottom floor, roams a bit but not far", "skull_grey", "rare_val","130166"},
	[61056940]={ "39596", "Perrexx the Corruptor", "Crit/Mastery Mail Shoulder", "", "skull_grey", "rare_val","130137"},
	[45598879]={ "43446", "Bahagar", "Versatility/Mastery Leather Pants", "", "skull_grey", "rare_val","130135"},
	[47225802]={ "39357", "Mad Henryk", "Toy", "", "skull_grey", "rare_val","130214"},
	[34425828]={ "39121", "Kiranys Duskwhisper", "Artifact Power", "", "skull_grey", "rare_val","141876"},
	[58773402]={ "40080", "Ironbranch", "Order Resources", "", "skull_grey", "rare_val","1220"},
	[61792954]={ "40079", "Lyrath Moonfeather", "Crit/Haste Cloth Gloves", "", "skull_grey", "rare_val","130118"},
	[66873686]={ "39856", "Wraithtalon", "Haste/Mastery Leather Gloves", "", "skull_grey", "rare_val","130116"}, --second QuestID 43447
	[67166962]={ "43176", "Undergrell Attack", "Haste/Mastery Plate Helmet", "", "skull_grey", "rare_val","130133"},
	[38065281]={ "38772", "Theryssia", "Versatility/Mastery Cloth Chest", "", "skull_grey", "rare_val", "130136"},
	[41647827]={ "38479", "Seersei", "Toy", "", "skull_grey", "rare_val", "130171"},
	[67504510]={ "39130", "Pollous the Fetid", "Pet", "", "skull_grey", "rare_val", "130168"},
}

nodes["Highmountain"] = {
	[54174159]={ "40483", "Glimmering Treasure Chest", "Artifact Power", "Cave entrace at 55.1 to 44.3", "default", "treasure_hmn","138783"},
	[52023241]={ "40505", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn","138783"},
	[39704830]={ "39494", "Floating Treasure", "Artifact Power", "Floating on the river", "default", "treasure_hmn","131763"},
	[55134965]={ "40487", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn","138783"},
	[43582510]={ "40478", "Treasure Chest", "Artifact Power", "Cave entrace at 42.5 to 25.4", "default", "treasure_hmn","138783"},
	[49647128]={ "39606", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn","138783"},
	[39376229]={ "40474", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[53035224]={ "40493", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[53454352]={ "40484", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[53063946]={ "40499", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[50983880]={ "40498", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[50013714]={ "39466", "Treasure Chest", "One of 4 Parts for the broken isles slow fall toy", "", "default", "treasure_hmn", "131927"},
	[42203482]={ "40480", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[37353381]={ "40477", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[45573462]={ "40481", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[55134964]={ "40487", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[39307621]={ "40473", "Treasure Chest", "Artifact Power", "seems to have slight phasing issues, you can reach the treasure from behind the totem", "default", "treasure_hmn", "138783"},  
	[46227340]={ "40489", "Treasure Chest", "Artifact Power", "cave", "default", "treasure_hmn", "138783"},  
	[43757275]={ "40510", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[36616213]={ "40488", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"}, 
	[53414868]={ "40500", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[52305141]={ "39766", "Totally Safe Treasure Chest", "Artifact Power", "Click the chest to spawn the treasure worm", "default", "treasure_hmn", "131802"},  
	[42212730]={ "40479", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[45192746]={ "44279", "Small Treasure Chest", "Artifact Power", "in an underwater cave", "default", "treasure_hmn", "138783"},  
	[46682810]={ "40482", "Glimmering Treasure Chest", "Artifact Power", "On top of the building", "default", "treasure_hmn", "138783"},    
	[50983647]={ "40496", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[50243861]={ "40497", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[50813504]={ "40506", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[46814013]={ "40507", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},  
	[47644406]={ "39503", "Treasure Chest", "One of 4 Parts for the broken isles slow fall toy", "", "default", "treasure_hmn", "131926"},  
	[53615103]={ "39824", "Treasure Chest", "One of 4 Parts for the broken isles slow fall toy", "On a ledge directly above the boxer rare", "default", "treasure_hmn", "131810"},  
	
	[54394112]={ "40414", "Devouring Darkness", "Haste/Mastery Cloth Boots", "Cave entrace at 55.1 to 44.3 | Blow out the candles to summon it", "skull_grey", "rare_hmn","131780"},
	[53755123]={ "39872", "Taurson", "Crit/Haste Plate Belt", "His loot is in his chest", "skull_grey", "rare_hmn","131800"},
	[41513184]={ "40175", "Slumber", "Crit/Haste Necklace", "", "skull_grey", "rare_hmn","131921"},
	[46643144]={ "39646", "Majestic Elderhorn", "Mount Buff for Highmountain", "", "skull_grey", "rare_hmn","131900"},
	[49202709]={ "40242", "Mellok, Son of Torok", "Artifact Power", "", "skull_grey", "rare_hmn","131808"},	
	[40975775]={ "39963", "Flamescale", "Haste/Mastery Mail Chest", "Click on the abandoned Fishing Pole", "skull_grey", "rare_hmn","131773"},
	[45705500]={ "40681", "Sekhan", "Haste/Mastery Leather Belt", "", "skull_grey", "rare_hmn","131730"},
	[51074825]={ "39802", "Hartli the Snatcher", "Artifact Power", "", "skull_grey", "rare_hmn","138783"},
	[43164800]={ "40413", "Amateur hunters", "Crit/Mastery Plate Boots", "Their loot is in a chest", "skull_grey", "rare_hmn","131781"},
	[54447454]={ "40773", "Frostshard", "Order Resources", "!!! LEVEL 110 !!!", "skull_blue", "rare_hmn","1220"},
	[51463189]={ "39465", "Skullhat", "Crit/Versatility Cloth Bracer", "", "skull_grey", "rare_hmn","131769"},
	[41944149]={ "39782", "Tenpak Flametotem", "Pet", "", "skull_grey", "rare_hmn","129175"},
	[48605000]={ "39784", "Beastmaster Pao'lek", "Crit/Haste Mail Gloves", "", "skull_grey", "rare_hmn","131756"},
	[37704570]={ "40405", "Bristlemaul", "Haste/Mastery Leather Helmet", "", "skull_grey", "rare_hmn","131761"},
	[44201210]={ "39994", "Crab Rider Grmlrml", "Haste/Mastery Leather Chest", "He roams the area", "skull_grey", "rare_hmn","131798"},
	[46500744]={ "40096", "Mrrklr", "Crit Ring", "", "skull_grey", "rare_hmn","131797"},
	[56406050]={ "40347", "Gurbog da Basher", "Crit/Haste Plate Chest", "He roams the area", "skull_grey", "rare_hmn","131775"},
	[56357250]={ "39235", "Brogul the Mighty", "Haste/Mastery Mail Boots", "", "skull_grey", "rare_hmn", "138396"},
	[36741635]={ "40084", "Bodash the Hoarder", "Strength Trinket with Mastery Proc", "", "skull_grey", "rare_hmn", "131799"},
	[48502546]={ "39646", "Majestic Elderhorn", "Mount Buff Toy", "it runs around the whole area", "skull_grey", "rare_hmn", "131900"},
	[51062570]={ "39762", "Shara Felbreath", "Haste/Mastery Cloth Chest", "", "skull_grey", "rare_hmn", "131791"},
	[48414015]={ "39806", "Crawshuk the Hungry", "One of 4 Parts for the broken isles slow fall toy", "", "skull_grey", "rare_hmn", "131809"},
	[54504060]={ "39866", "Mynta Talonscreech", "Crit/Haste Cloak", "on top of the mountain - talk to the npc", "skull_grey", "rare_hmn", "131792"},
	[50803460]={ "40406", "Luggut the Eggeater", "Crit/Mastery Mail Belt", "in a cave", "skull_grey", "rare_hmn", "131776"},
 }
 
nodes["Stormheim"] = {
	[35725407]={ "38677", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[31105600]={ "38676", "Small Treasure Chest", "Order Resources", "", "default", "treasure_sth","1220"},
	[27335749]={ "38529", "Treasure Chest", "Artifact Power", "Cave entrace at 31.4 to 57.1", "default", "treasure_sth","138783"},
	[32054719]={ "43196", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[41744604]={ "38488", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[50314100]={ "38483", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[48137421]={ "38476", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[42616579]={ "38474", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[46768040]={ "38481", "Treasure Chest", "Artifact Power", "Requires the Stormforged Grapple Launcher", "default", "treasure_sth","138783"},
	[61404440]={ "40093", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[60834273]={ "40094", "Small Treasure Chest", "Artifact Power", "Requires the Stormforged Grapple Launcher", "default", "treasure_sth","138783"},
	[55004716]={ "40095", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[67935774]={ "40083", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[69144478]={ "38637", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[73334150]={ "40085", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[61836289]={ "40089", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[57946321]={ "40090", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth","138783"},
	[49777801]={ "38485", "Small Treasure Chest", "Artifact Power", "Requires the Stormforged Grapple Launcher", "default", "treasure_sth", "138783"},
	[65364310]={ "43205", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[52018058]={ "38480", "Small Treasure Chest", "Artifact Power", "Requires the Stormforged Grapple Launcher", "default", "treasure_sth", "138783"},
	[72135489]={ "42628", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[65585737]={ "43187", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[62667362]={ "40091", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[39571934]={ "38498", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[35924792]={ "38680", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[33143607]={ "38495", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[35033660]={ "38487", "Treasure Chest", "Artifact Power", "cave entrance at 34.8 to 34.23", "default", "treasure_sth", "138783"},
	[32742791]={ "38490", "Treasure Chest", "Artifact Power", "cave entrance at 33.65 to 27.35", "default", "treasure_sth", "138783"},
	[43164049]={ "43238", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[44983823]={ "43240", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[47463412]={ "43255", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[42473407]={ "43189", "Treasure Chest", "Artifact Power", "entrance to the statue at 42.24 to 34.87", "default", "treasure_sth", "141896"},
	[37183865]={ "43208", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[61933255]={ "38744", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[68462959]={ "40108", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[58044751]={ "40082", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[64293956]={ "43302", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[68974183]={ "40086", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[74414182]={ "43306", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[71924425]={ "43305", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[73154570]={ "43194", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[73965223]={ "42632", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[75164949]={ "42629", "Treasure Chest", "Artifact Power", "on top of the sail", "default", "treasure_sth", "138783"},
	[73975858]={ "43237", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[75676060]={ "43304", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[82405451]={ "43191", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[81876750]={ "40099", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[69986719]={ "43188", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[59305846]={ "40088", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[78427138]={ "43307", "Treasure Chest", "Artifact Power", "a lot of grappling", "default", "treasure_sth", "138783"},
	[50554125]={ "43246", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[39486518]={ "38486", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[35176898]={ "38478", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[40656852]={ "38475", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[44166997]={ "38489", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[43708009]={ "43239", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[42336112]={ "38477", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[46606496]={ "38681", "Small Treasure Chest", "Artifact Power", "cave entrance is at 48.16 to 65.24", "default", "treasure_sth", "138783"},
	[49085999]={ "43207", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[47986237]={ "38738", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[50061816]={ "43195", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[49694731]={ "38763", "Glimmering Treasure Chest", "Artifact Power", "Be prepared to fight the two Vault Keepers", "default", "treasure_sth", "132897"},
	[53229314]={ "43190", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	
	[40677238]={ "38424", "Thane Irglov the Merciless", "Toy", "", "skull_grey", "rare_sth", "129113"},
	[38454305]={ "38626", "Bloodstalker", "Versatility Trinket", "", "skull_grey", "rare_sth", "129101"},
	[54802941]={ "42437", "Starbuck", "Crit/Haste Leather Bracer", "", "skull_grey", "rare_sth", "130132"},
	[63707422]={ "37908", "Inquisitor Ernstenbok", "Crit/Haste Leather Shoulders", "", "skull_grey", "rare_sth", "140686"},
	[73454763]={ "40109", "Kottr Vondyr", "Haste/Mastery Leather Bracer", "", "skull_grey", "rare_sth", "138419"},
	[78626116]={ "40113", "Grrvrgull the Conqueror", "Haste/Mastery Mail Belt", "", "skull_grey", "rare_sth", "138421"},
	[36505250]={ "38472", "Whitewater Typhoon", "Crit/Mastery Mail Gloves", "", "skull_grey", "rare_sth","138418"},
	[47174983]={ "38774", "Tiptog the Lost", "Strength Trinket", "", "skull_grey", "rare_sth","129163"},
	[46828406]={ "38425", "Fathnyr", "Crit Ring", "", "skull_grey", "rare_sth", "129206"},
	[64805176]={ "38847", "Urgev the Flayer", "Haste/Mastery Cloth Bracer", "", "skull_grey", "rare_sth","129219"},
	[73906060]={ "43343", "Dread-Rider Cortis", "Haste/Mastery Mail Legs", "", "skull_grey", "rare_sth","130134"},
	[62036049]={ "39120", "Isel the Hammer", "Crit/Haste Mail Helmet", "", "skull_grey", "rare_sth","129133"},
	[59826807]={ "39031", "Ivory Sentinel", "Mastery Trinket with Int proc", "", "skull_grey", "rare_sth","132895"},
	[41476702]={ "38333", "Glimar Ironfist", "Crit/Mastery Plate Belt", "", "skull_grey", "rare_sth","129291"},
	[49507175]={ "38423", "Stormdrake Matriarch", "Pet", "", "skull_grey", "rare_sth","129208"},
	[51607465]={ "42591", "Hannval the Butcher", "Crit/Mastery Leather Chest", "", "skull_grey", "rare_sth","138417"},
	[45877736]={ "38431", "Bladesquall", "Crit/Haste Cloth Chest", "", "skull_grey", "rare_sth","129048"},
	[61534333]={ "40081", "Tarben", "Crit/Haste Necklace", "", "skull_grey", "rare_sth","129199"},
	[58004516]={ "38642", "Captain Brvet", "Haste/Mastery Mail Chest", "", "skull_grey", "rare_sth","129123"},
	[58353392]={ "43342", "Roteye", "Haste/Mastery Mail Legs", "", "skull_grey", "rare_sth","139387"},
	[72504991]={ "38837", "Mordvigbjorn", "Mastery/Versatility Cloak", "", "skull_grey", "rare_sth","129035"},
	[67303990]={ "38685", "The Nameless King", "Haste/Mastery Cloth Helmet", "", "skull_grey", "rare_sth","129041"},
	[41773411]={ "40068", "Egyl the Enduring", "Haste/Mastery Plate Boots", "", "skull_grey", "rare_sth", "132898"},
}

nodes["Suramar"] = {
	[23414880]={ "43842", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[25958548]={ "43831", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[29768817]={ "43748", "Shimmering Ancient Mana Cluster", "Ancient Mana", "", "default", "treasure_sur", "141655"},
	[38138712]={ "43830", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[51503859]={ "43855", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[46552599]={ "43744", "Shimmering Ancient Mana Cluster", "Ancient Mana", "", "default", "treasure_sur", "141655"},
	[52733130]={ "40767", "Dusty Coffer", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[44302289]={ "43850", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[16602974]={ "43846", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[22863574]={ "43838", "Temple of Fal'adora", "", "two treasures inside", "default", "treasure_sur", ""},
	[21425446]={ "42842", "Kel'danath's Manaflask", "+100 maximum Ancient Mana", "", "default", "treasure_sur", "136269"},
	[17275462]={ "43844", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[44053194]={ "43856", "Glimmering Treasure Chest", "Ancient Mana", "cave entrance is behind a waterfall at 42.25 to 29.97", "default", "treasure_sur", "139786"},
	[29271622]={ "43848", "Treasure Chest", "Artifact Power/Ancient Mana etc", "", "default", "treasure_sur", "138783"},
	[35561209]={ "43989", "Arcane Power Unit", "+100 maximum Ancient Mana", "", "default", "treasure_sur", "140329"},
	[41961919]={ "43746", "Shimmering Ancient Mana Cluster", "Ancient Mana", "", "default", "treasure_sur", "139786"},
	[42051968]={ "43849", "Glimmering Treasure Chest", "Ancient Mana", "", "default", "treasure_sur", "139786"},
	[26831696]={ "43847", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[48143399]={ "43853", "Small Treasure Chest", "Ancient Mana", "", "default", "treasure_sur", ""},
	[67315511]={ "43858", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[79647289]={ "43741", "Shimmering Ancient Mana Cluster", "Ancient Mana", "", "default", "treasure_sur", "141655"},
	[83126933]={ "43863", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[83975764]={ "43862", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[61365550]={ "43872", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[54326033]={ "43875", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[57686197]={ "43874", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[57326039]={ "43873", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[60356851]={ "43876", "Glimmering Treasure Chest", "Ancient Mana", "", "default", "treasure_sur", "139786"},
	[49988493]={ "43864", "Small Treasure Chest", "Artifact Power", "You need to use a grapple point on top of the house at 50.06 to 84.46", "default", "treasure_sur", "138783"},
	[48117321]={ "43865", "Small Treasure Chest", "Artifact Power", "There are multiple grapplepoints at this house", "default", "treasure_sur", "138783"},
	[48288261]={ "43866", "Small Treasure Chest", "Artifact Power", "You need to use a grapple point on top of the house at 48.39 to 82.23", "default", "treasure_sur", "138783"},
	[48957379]={ "43867", "Treasure Chest", "Artifact Power", "on the second floor. the stairs are to the right", "default", "treasure_sur", "138783"},
	[51908214]={ "43868", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[44387587]={ "43869", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[42577668]={ "43870", "Small Treasure Chest", "Artifact Power", "upstairs in the bedroom", "default", "treasure_sur", "138783"},
	[48587217]={ "44323", "Treasure Chest", "Artifact Power", "up the stairs on the left inside the building", "default", "treasure_sur", "138783"},
	[50068061]={ "44325", "Treasure Chest", "Artifact Power", "top floor in the building", "default", "treasure_sur", "138783"},
	[48297121]={ "44324", "Treasure Chest", "Artifact Power", "Jump on the bookcase, over to the ledge to the right and then directly towards the treasure", "default", "treasure_sur", "138783"},
	[55685480]={ "43871", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[31956249]={ "43831", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[44803100]={ "43986", "Enchanted Burial Urn", "+100 maximum ancient mana", "", "default", "treasure_sur", "140326"},
	[26877073]={ "43987", "Kyrtos's Research Notes", "+100 maximum ancient mana", "cave entrance at 27.29 to 72.87", "default", "treasure_sur", "140327"},
	[76876150]={ "43860", "Small Treasure Chest", "Artifact Power", "in a shipwreck", "default", "treasure_sur", "138783"},
	[71464975]={ "43859", "Small Treasure Chest", "Artifact Power", "on the tower", "default", "treasure_sur", "138783"},
	[52292990]={ "43854", "Small Treasure Chest", "Artifact Power", "cave entrance at 49.5 to 33.9", "default", "treasure_sur", "138783"},
	[81965745]={ "43861", "Small Treasure Chest", "Artifact Power", "entrance at 79.3 to 57.4", "default", "treasure_sur", "138783"},
	[63654911]={ "43857", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[19791604]={ "43845", "Small Treasure Chest", "Artifact Power", "cave entrance at 19.4 to 19.4", "default", "treasure_sur", "138783"},
	[32277708]={ "43834", "Treasure Chest", "Artifact Power", "Only available after completing Breaking the Lightbreaker Suramar campaign. Otherwise you can't use the portal at 31.0 to 85.1", "default", "treasure_sur", "138783"},
	
	[24393517]={ "44071", "Maia the White Wolf", "Crit/Haste Cloak", "", "skull_grey", "rare_sur", "139897"},
	[16532656]={ "43996", "Shadowquill", "Ancient Mana", "", "skull_grey", "rare_sur", "140401"},
	[13535344]={ "44124", "Mar'tura", "Ancient Mana", "Quest ID is bugged, gives both Mar'tura and Tideclaw QuestID", "skull_grey", "rare_sur", "140949"},
	[18676104]={ "43542", "Tideclaw", "Ancient Mana", "", "skull_grey", "rare_sur", "140399"},
	[36183381]={ "43718", "Matron Hagatha", "Ancient Mana", "", "skull_grey", "rare_sur", "140390"},
	[33781509]={ "43717", "Artificer Lothaire", "Artifact Power", "", "skull_grey", "rare_sur", "140372"},
	[75525729]={ "44003", "Reef Lord Raj'his", "Haste/Mastery Ring", "", "skull_grey", "rare_sur", "121801"},
	[80157000]={ "40680", "Rok'nash", "Crit/Haste Plate Bracer", "roams around a trench on the ocean floor", "skull_grey", "rare_sur", "140019"},
	[67677106]={ "41136", "Har'kess the Insatiable", "Artifact Power", "cave entrance is at 72.39 to 68.08", "skull_grey", "rare_sur", "140381"},
	[54435612]={ "43792", "Degren", "Agility Trinket", "", "skull_grey", "rare_sur", "121808"},
	[54806376]={ "43794", "Ambassador D'vwinn", "Haste/Mastery Cloth Chest", "", "skull_grey", "rare_sur", "139918"},
	[34176099]={ "43351", "Mal'Dreth the Corruptor", "Artifact Power", "", "skull_grey", "rare_sur", "140386"},
	[62564808]={ "43495", "Cadraeus", "Crit/Haste Mail Helmet", "", "skull_grey", "rare_sur", "139969"},
	[61663958]={ "43993", "Hertha Grimdottir", "Haste/Mastery Mail Boots", "", "skull_grey", "rare_sur", "121737"},
	[68175896]={ "41135", "Cora'Kar", "Crit/Mastery Leather Chest", "cave entrance at 69.95 to 56.98", "skull_grey", "rare_sur", "139952"},
	[66656713]={ "43968", "Pinchshank", "Toy", "", "skull_grey", "rare_sur", "140314"},
	[40963282]={ "43358", "Myonix", "Crit/Haste Leather Gloves", "", "skull_grey", "rare_sur", "121739"},
	[33725123]={ "43954", "Anax", "Pet", "", "skull_grey", "rare_sur","140934"},
	[26104077]={ "42831", "Shal'an", "Haste/Mastery Cloth Bracer", "", "skull_grey", "rare_sur","139926"},
	[24574740]={ "43449", "Oreth the Vile", "Artifact Power", "", "skull_grey", "rare_sur","140388"},
	[22135178]={ "41319", "Elfbane", "Mastery Trinket with Strength proc", "", "skull_grey", "rare_sur","121806"},
	[87846248]={ "41786", "King Morgalash", "Artifact Power", "", "skull_grey", "rare_sur", "140384"},
	[38042278]={ "43369", "Siegemaster Aedrin", "Ancient Mana", "", "skull_grey", "rare_sur", "140406"},
	[53193021]={ "40897", "Garvrulg", "Crit/Mastery Mail Shoulder", "", "skull_grey", "rare_sur", "121755"},
	[42175641]={ "43580", "Apothecary Faldren", "Crit/Mastery Cloth Shoulder", "", "skull_grey", "rare_sur", "121754"},
	[48075637]={ "40905", "Lieutenant Strathmar", "Crit/Mastery Plate Boots", "", "skull_grey", "rare_sur", "121735"},
	--[67065161]={ "99999", "Broodmother Shu'malis", "Order Resources", "marked as rare but seems to have no questID yet", "skull_grey", "rare_sur", "1220"},
	[27776547]={ "43992", "Gorgroth", "Crit/Haste Plate Pants", "click on the Portal Key", "skull_grey", "rare_sur", "121747"},
	[62506369]={ "43793", "Miatsu", "Haste Trinket", "", "skull_grey", "rare_sur", "121810"},
	[65575914]={ "43481", "Arcanist Lylandre", "Ancient Mana", "", "skull_grey", "rare_sur", "140403"},
	[61015298]={ "43597", "Guardian Thor'el", "Ancient Mana", "roams a little bit", "skull_grey", "rare_sur", "140404"},
	[49607900]={ "43603", "Randril", "Artifact Power", "", "skull_grey", "rare_sur", "140396"},
	[24052542]={ "43484", "Rauren", "Haste/Mastery Leather Belt", "", "skull_grey", "rare_sur", "121759"},
	[42058005]={ "43348", "Magister Phaedris", "Ancient Mana", "", "skull_grey", "rare_sur", "140405"},
	[29395330]={ "44676", "Llorian", "Artifact Power", "cave entrance at 29.29 to 50.71", "skull_grey", "rare_sur", "138839"},
	[35236723]={ "44675", "Lady Rivantas", "Versatility/Mastery Cloth Gloves", "", "skull_grey", "rare_sur", "141866"},
}

nodes["Darkpens"] = {
	[42018849]={ "39085", "Small Treasure Chest", "Artifact Power", "Entrance is on top of the wall at 41.4 to 45.6", "default", "treasure_val","138783"},
	[50905168]={ "39086", "Glimmering Treasure Chest", "Artifact Power", "Entrance is on top of the wall at 41.4 to 45.6", "default", "treasure_val","138783"},
}

nodes["OceanusCove"] = {
	[69294839]={ "37649", "Glimmering Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
	[45346686]={ "42291", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_azs", "138783"},
}

nodes["BitestoneEnclave"] = {
	[85213787]={ "40489", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}

nodes["LifespringCavern"] = {
	[53102392]={ "40476", "Glimmering Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}

nodes["Helheim"] = {
	[85085031]={ "38461", "Fenri", "Mastery Trinket", "", "skull_grey", "rare_sth", "129044"},
	[28186375]={ "39870", "Soulthirster", "Pet", "", "skull_grey", "rare_sth", "129188"},
	[79842471]={ "38510", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[83322456]={ "38503", "Treasure Chest", "Artifact Power", "under water in a ship", "default", "treasure_sth", "138783"},
	[60845332]={ "38383", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
	[19634698]={ "38516", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
}

nodes["ThunderTotem"] = {
	[13715555]={ "40491", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[63435929]={ "39531", "A Steamy Jewelry Box", "Trash", "", "default", "treasure_hmn", "141322"},
	[50667537]={ "40472", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[32354174]={ "40475", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[31843842]={ "44352", "Treasure Chest", "Artifact Power", "in an underwater cave", "default", "treasure_hmn", "138783"},
}

nodes["ThunderTotemInterior"] = {
	[62946793]={ "40471", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}

nodes["NeltharionsVault"] = {
	[63733725]={ "39606", "Treasures of Deathwing", "Artifact Power", "use the titan waygate at the bottom of the cave to get to the event", "default", "treasure_hmn", "138783"},
	[40215031]={ "40509", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
	[60425458]={ "40508", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}

nodes["SuramarLegionScar"] = {
	[40502903]={ "40902", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[54573780]={ "43835", "Small Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
}

nodes["StonedarkGrotto"] = {
	[35987235]={ "40478", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}

nodes["MucksnoutDen"] = {
	[60592533]={ "40494", "Treasure Chest", "Artifact Power", "", "default", "treasure_hmn", "138783"},
}


nodes["MardumtheShatteredAbyss"] = {
	[34857020]={ "39970", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[45017785]={ "39971", "Small Treasure Chest", "Reusable Flask", "", "default", "treasure_dh", "129192"},
	[41763761]={ "40759", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[51135079]={ "40743", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[76243899]={ "40338", "Small Treasure Chest", "", "cave entrance at 77.0 to 41.4", "default", "treasure_dh", "129210"},
	[82075043]={ "40820", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[78755047]={ "40274", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[73494892]={ "39975", "Small Treasure Chest", "", "", "default", "treasure_dh", "129195"},
	[42194916]={ "40223", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[23065389]={ "40797", "Small Treasure Chest", "", "cave entrance at 23.6 to 54.2", "default", "treasure_dh", "129210"},
	[66922767]={ "39974", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[74285453]={ "39977", "Small Treasure Chest", "", "cave entrance at 70.7 to 54.0", "default", "treasure_dh", "129210"},
	[69704240]={ "39976", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	
	[68852759]={ "40234", "General Volroth", "", "", "skull_grey", "rare_dh", "128947"},
	[81034124]={ "40233", "Overseer Brutarg", "", "", "skull_grey", "rare_dh", "133580"},
	[74475731]={ "40232", "King Voras", "", "", "skull_grey", "rare_dh", "128944"},
}

nodes["CrypticHollow"] = {
	[48761530]={ "39972", "Small Treasure Chest", "", "", "default", "treasure_dh", "129196"},
	[54855845]={ "39973", "Small Treasure Chest", "", "", "default", "treasure_dh", "128946"},
}

nodes["SoulEngine"] = {
	[50304964]={ "40772", "Small Treasure Chest", "", "", "default", "treasure_dh", "129210"},
	[51235740]={ "40231", "Count Nefarious", "", "", "skull_grey", "rare_dh", "128948"},
}

nodes["VaultOfTheWardensDH"] = {
	[58693475]={ "40909", "Small Treasure Chest", "", "First Stage", "default", "treasure_dh", "129210"},
	[47325464]={ "38690", "Small Treasure Chest", "", "First Stage", "default", "treasure_dh", "129210"},
	[32104817]={ "40911", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129196"},
	[41506361]={ "40914", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129196"},
	[56994013]={ "40913", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129210"},
	[41413287]={ "40912", "Small Treasure Chest", "", "Second Stage", "default", "treasure_dh", "129210"},
	[24421005]={ "40915", "Small Treasure Chest", "", "Third Stage", "default", "treasure_dh", "129210"},
	[23268157]={ "40916", "Small Treasure Chest", "", "Third Stage", "default", "treasure_dh", "129210"},
	
	[68743628]={ "40301", "Wrath-Lord Lekos", "", "", "skull_grey", "rare_dh", "128958"},
	[49543284]={ "40251", "Kethrazor", "", "", "skull_grey", "rare_dh", "128945"},
}

nodes["StormDrakeDen"] = {
	[20134125]={ "38529", "Treasure Chest", "Artifact Power", "", "default", "treasure_sth", "138783"},
}

nodes["NarthalasAcademy"] = {
	[53643981]={ "42284", "Small Treasure Chest", "Artifact Power", "Inside the temple", "default", "treasure_azs", "138783"},
	[54413487]={ "42285", "Small Treasure Chest", "Artifact Power", "You need to do a questline to open the door leading to the treasure", "default", "treasure_azs", "138783"},
}

nodes["FalanaarTunnels"] = {
	[35513253]={ "43747", "Manachest", "Ancient Mana", "", "default", "treasure_sur", "139786"},
	[48644258]={ "43839", "Small Treasure Chest", "Artifact Power", "up a ledge reachable via the spider webs", "default", "treasure_sur", "138783"},
	[23354815]={ "43840", "Treasure Chest", "Artifact Power", "", "default", "treasure_sur", "138783"},
	[35525280]={ "43988", "Volatile Leyline Crystal", "+100 maximum Ancient Mana", "bottom floor in the temple of fal'adora | can't display it correctly right now, sorry!", "default", "treasure_sur", "140328"},
	[38605414]={ "43838", "Small Treasure Chest", "Artifact Power", "bottom floor in the temple of fal'adora | can't display it correctly right now, sorry!", "default", "treasure_sur", "138783"},
}


if (PlayerFaction == "Alliance") then
  nodes["Stormheim"][44202296]={ "38630", "Horde Kill Squad", "Crit/Versatility Plate Gloves", "Alliance only", "skull_grey", "rare_sth", "129266"}
  nodes["Stormheim"][42015767]={ "38625", "Hook and Sinker", "Crit/Mastery Cloth Belt", "", "skull_grey", "rare_sth", "129100"}
end

if (PlayerFaction == "Horde") then
  nodes["Stormheim"][44202296]={ "38627", "Worgen Stalkers", "Crit/Mastery Plate Gloves", "Horde only", "skull_grey", "rare_sth", "129264"}
  nodes["Stormheim"][47205710]={ "38712", "Houndmaster Ely", "Haste/Mastery Cloth Pants", "", "skull_grey", "rare_sth", "129037"}
end

local function GetItem(ID)
    if (ID == "1220") then
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

function LegionRaresTreasures:OnEnter(mapFile, coord)
    if (not nodes[mapFile][coord]) then return end
    
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

    if ( self:GetCenter() > UIParent:GetCenter() ) then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    tooltip:SetText(nodes[mapFile][coord][2])
    if (nodes[mapFile][coord][3] ~= nil) and (LegionRaresTreasures.db.profile.show_loot == true) then
        if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
            tooltip:AddLine(("Loot: " .. GetItem(nodes[mapFile][coord][7])), nil, nil, nil, true)

            if ((nodes[mapFile][coord][3] ~= nil) and (nodes[mapFile][coord][3] ~= "")) then
                tooltip:AddLine(("Lootinfo: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
            end
        else
            tooltip:AddLine(("Loot: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
        end
    end

    if (nodes[mapFile][coord][4] ~= "") and (LegionRaresTreasures.db.profile.show_notes == true) then
     tooltip:AddLine(("Notes: " .. nodes[mapFile][coord][4]), nil, nil, nil, true)
    end

    tooltip:Show()
end

local isMoving = false
local info = {}
local clickedMapFile = nil
local clickedCoord = nil

local function generateMenu(button, level)
    if (not level) then return end

    for k in pairs(info) do info[k] = nil end

    if (level == 1) then
        info.isTitle = 1
        info.text = "LegionRaresTreasures"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
        info.disabled = nil
        info.isTitle = nil
        info.notCheckable = nil
        info.text = "Remove this Object from the Map"
        info.func = LRTDisableTreasure
        info.arg1 = clickedMapFile
        info.arg2 = clickedCoord
        UIDropDownMenu_AddButton(info, level)
        
        if isTomTomloaded == true then
            info.text = "Add this location to TomTom waypoints"
            info.func = LRTaddtoTomTom
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
        end

        if isDBMloaded == true then
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

local HandyNotes_LegionRaresTreasuresDropdownMenu = CreateFrame("Frame", "HandyNotes_LegionRaresTreasuresDropdownMenu")
HandyNotes_LegionRaresTreasuresDropdownMenu.displayMode = "MENU"
HandyNotes_LegionRaresTreasuresDropdownMenu.initialize = generateMenu

function LegionRaresTreasures:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and down then
        clickedMapFile = mapFile
        clickedCoord = coord
        ToggleDropDownMenu(1, nil, HandyNotes_LegionRaresTreasuresDropdownMenu, self, 0, 0)
    end
end

function LegionRaresTreasures:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local options = {
    type = "group",
    name = "LegionRaresTreasures",
    desc = "Locations of treasures on the broken isles",
    get = function(info) return LegionRaresTreasures.db.profile[info.arg] end,
    set = function(info, v) LegionRaresTreasures.db.profile[info.arg] = v; LegionRaresTreasures:Refresh() end,
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
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_treasures",
            order = 1,
        },
        icon_scale_rares = {
            type = "range",
            name = "Icon Scale for Rares",
            desc = "The scale of the icons",
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_rares",
            order = 2,
        },
        icon_alpha = {
            type = "range",
            name = "Icon Alpha",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha",
            order = 20,
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
                        groupAZS = {
                            type = "header",
                            name = "Azsuna",
                            desc = "Azsuna",
                            order = 0,
                        },
                        treasureAZS = {
                            type = "toggle",
                            arg = "treasure_azs",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            order = 1,
                            width = "normal",
                        },
                        rareAZS = {
                            type = "toggle",
                            arg = "rare_azs",
                            name = "Rares",
                            desc = "Rare spawns",
                            order = 2,
                            width = "normal",
                        },
                        groupVAL = {
                            type = "header",
                            name = "Val'Sharah",
                            desc = "Val'Sharah",
                            order = 10,
                        },  
                        treasureVAL = {
                            type = "toggle",
                            arg = "treasure_val",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 11,
                        },
                        rareVAL = {
                            type = "toggle",
                            arg = "rare_val",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 12,
                        },
                        groupHMN = {
                            type = "header",
                            name = "Highmountain",
                            desc = "Highmountain",
                            order = 20,
                        },  
                        treasureHMN = {
                            type = "toggle",
                            arg = "treasure_hmn",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 21,
                        },
                        rareHMN = {
                            type = "toggle",
                            arg = "rare_hmn",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 22,
                        },  
                        groupSTH = {
                            type = "header",
                            name = "Stormheim",
                            desc = "Stormheim",
                            order = 30,
                        },  
                        treasureSTH = {
                            type = "toggle",
                            arg = "treasure_sth",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 31,
                        },
                        rareSTH = {
                            type = "toggle",
                            arg = "rare_sth",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 32,
                        },  
                        groupSUR = {
                            type = "header",
                            name = "Suramar",
                            desc = "Suramar",
                            order = 40,
                        },    
                        treasureSUR = {
                            type = "toggle",
                            arg = "treasure_sur",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 41,
                        },
                        rareSUR = {
                            type = "toggle",
                            arg = "rare_sur",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 42,
                        },
						groupDH = {
                            type = "header",
                            name = "Demon Hunter",
                            desc = "Demon Hunter only zones",
                            order = 50,
                        },    
                        treasureDH = {
                            type = "toggle",
                            arg = "treasure_dh",
                            name = "Treasures",
                            desc = "Treasures that give various items",
                            width = "normal",
                            order = 51,
                        },
                        rareDH = {
                            type = "toggle",
                            arg = "rare_dh",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 52,
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
                    desc = "Shows the Loot for each Treasure/Rare",
                    order = 102,
                },
                show_notes = {
                    type = "toggle",
                    arg = "show_notes",
                    name = "Show Notes",
                    desc = "Shows the notes each Treasure/Rare if available",
                    order = 103,
                },
            },
        },
    },
}

function LegionRaresTreasures:OnInitialize()
    local defaults = {
        profile = {
            icon_scale_treasures = 1.5,
            icon_scale_rares = 2.0,
            icon_alpha = 1.00,
            alwaysshowrares = false,
            alwaysshowtreasures = false,
            save = true,
            treasure_azs = true,
            treasure_val = true,
            treasure_hmn = true,
            treasure_sth = true,
            treasure_sur = true,
			treasure_dh = true,
            rare_azs = true,
            rare_val = true,
            rare_hmn = true,
			rare_sth = true,
            rare_sur = true,
			rare_dh = true,
            show_loot = true,
            show_notes = true,
        },
    }

    self.db = LibStub("AceDB-3.0"):New("LegionRaresTreasuresDB", defaults, "Default")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "WorldEnter")
end

function LegionRaresTreasures:WorldEnter()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:ScheduleTimer("QuestCheck", 5)
    self:ScheduleTimer("RegisterWithHandyNotes", 8)
	self:ScheduleTimer("LoadCheck", 6)
end

function LegionRaresTreasures:QuestCheck()
    do
		if (IsQuestFlaggedCompleted(41246)) then
			nodes["Highmountain"][52556638]={ "42453", "Treasure Chest", "Artifact Power", "Only reachable after completing the high mountain storyline up to Highmountain Stands", "default", "treasure_hmn", "138783"}
		end
    end
end

function LegionRaresTreasures:RegisterWithHandyNotes()
    do
        local function iter(t, prestate)
            if not t then return nil end

            local state, value = next(t, prestate)

            while state do

                -- QuestID[1], Name[2], Loot[3], Notes[4], Icon[5], Tag[6], ItemID[7]
                if (value[1] and self.db.profile[value[6]] and not LegionRaresTreasures:HasBeenLooted(value)) then
                    if ((value[7] ~= nil) and (value[7] ~= "")) then
                        GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
                    end

                    if ((value[5] == "default") or (value[5] == "unknown")) then
                        if ((value[7] ~= nil) and (value[7] ~= "")) then
                            return state, nil, GetIcon(value[7]), LegionRaresTreasures.db.profile.icon_scale_treasures, LegionRaresTreasures.db.profile.icon_alpha
                        else
                            return state, nil, iconDefaults[value[5]], LegionRaresTreasures.db.profile.icon_scale_treasures, LegionRaresTreasures.db.profile.icon_alpha
                        end
                    end

                    return state, nil, iconDefaults[value[5]], LegionRaresTreasures.db.profile.icon_scale_rares, LegionRaresTreasures.db.profile.icon_alpha
                end

                state, value = next(t, state)
            end
        end

        function LegionRaresTreasures:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
            return iter, nodes[mapFile], nil
        end
    end

    HandyNotes:RegisterPluginDB("LegionRaresTreasures", self, options)
    self:RegisterBucketEvent({ "LOOT_CLOSED" }, 2, "Refresh")
    self:Refresh()
end
 
function LegionRaresTreasures:Refresh()
    self:SendMessage("HandyNotes_NotifyUpdate", "LegionRaresTreasures")
end

function LRTResetDB()
    table.wipe(LegionRaresTreasures.db.char)
    LegionRaresTreasures:Refresh()
end

function LegionRaresTreasures:HasBeenLooted(value)
    if (self.db.profile.alwaysshowtreasures and (string.find(value[6], "treasure") ~= nil)) then return false end
    if (self.db.profile.alwaysshowrares and (string.find(value[6], "treasure") == nil)) then return false end
    if (LegionRaresTreasures.db.char[value[1]] and self.db.profile.save) then return true end
    if (IsQuestFlaggedCompleted(value[1])) then
        return true
    end

    return false
end

function LRTDisableTreasure(button, mapFile, coord)
    if (nodes[mapFile][coord][1] ~= nil) then
        LegionRaresTreasures.db.char[nodes[mapFile][coord][1]] = true;
    end

    LegionRaresTreasures:Refresh()
end

function LRTaddtoTomTom(button, mapFile, coord)
    if isTomTomloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (LegionRaresTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLoot Info: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
        end

        if (nodes[mapFile][coord][4] ~= "") and (LegionRaresTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end

        TomTom:AddMFWaypoint(mapId, nil, x, y, {
            title = desc,
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end

function LRTAddDBMArrow(button, mapFile, coord)
    if isDBMloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (LegionRaresTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLootinfo: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
        end

        if (nodes[mapFile][coord][4] ~= "") and (LegionRaresTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end

        if not DBMArrow.Desc:IsShown() then
            DBMArrow.Desc:Show()
        end

        x = x*100
        y = y*100
        DBMArrow.Desc:SetText(desc)
        DBM.Arrow:ShowRunTo(x, y, nil, nil, true)
    end
end

function LRTHideDBMArrow()
    DBM.Arrow:Hide(true)
end

function LegionRaresTreasures:LoadCheck()
	if (IsAddOnLoaded("TomTom")) then 
		isTomTomloaded = true
	end

	if (IsAddOnLoaded("DBM-Core")) then 
		isDBMloaded = true
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
