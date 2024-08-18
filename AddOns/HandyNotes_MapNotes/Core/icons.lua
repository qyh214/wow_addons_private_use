local ADDON_NAME, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local iconLink = "Interface\\Addons\\" .. ADDON_NAME .. "\\Images\\"

ns.icons = { 
--Addon Logo
["MNL"] = iconLink .. "MNL4",
["DarkMoon"] = iconLink .. "DarkMoon",
--General
["Innkeeper"] = "interface/minimap/tracking/innkeeper.blp",
["InnkeeperN"] = iconLink .. "InnkeeperN",
["InnkeeperA"] = iconLink .. "InnkeeperA",
["InnkeeperH"] = iconLink .. "InnkeeperH",
["Auctioneer"] = iconLink .. "Auctioneer",
["Bank"] = "interface/worldmap/treasurechest_64.blp",
["BankOld"] = "interface/minimap/tracking/banker.blp",
["BankNew"] = "interface/worldmap/treasurechest_64.blp",
["Barber"] = "interface/minimap/tracking/barbershop.blp",
["Transmogger"] = "interface/minimap/tracking/transmogrifier.blp",
["PvPVendor"] = iconLink .. "PvPVendor",
["PvPVendorH"] = iconLink .. "PvPVendorH",
["PvPVendorA"] = iconLink .. "PvPVendorA",
["PvEVendor"] = iconLink .. "PvEVendor",
["PvEVendorH"] = iconLink .. "PvEVendorH",
["PvEVendorA"] = iconLink .. "PvEVendorA",
["ItemUpgrade"] = iconLink .. "ItemUpgrade",
["DragonFlyTransmog"] = iconLink .. "DragonFlyTransmog",
["Catalyst"] = iconLink .. "Catalyst",
["BlackMarket"] = iconLink .. "BlackMarket",
["Mailbox"] = "interface/minimap/tracking/mailbox.blp",
["MailboxN"] = iconLink .. "MailboxN",
["MailboxH"] = iconLink .. "MailboxH",
["MailboxA"] = iconLink .. "MailboxA",
["StablemasterN"] = iconLink .. "StablemasterN",
["StablemasterH"] = iconLink .. "StablemasterH",
["StablemasterA"] = iconLink .. "StablemasterA",
-- Icons if enemy faction is disabled for General zone icons
["OriginalInnkeeperA"] = iconLink .. "InnkeeperA",
["OriginalInnkeeperH"] = iconLink .. "InnkeeperH",
["OriginalStablemasterH"] = iconLink .. "StablemasterH",
["OriginalStablemasterA"] = iconLink .. "StablemasterA",
["OriginalMailboxH"] = iconLink .. "MailboxH",
["OriginalMailboxA"] = iconLink .. "MailboxA",
["OriginalPvPVendorH"] = iconLink .. "PvPVendorH",
["OriginalPvPVendorA"] = iconLink .. "PvPVendorA",
["OriginalPvEVendorH"] = iconLink .. "PvEVendorH",
["OriginalPvEVendorA"] = iconLink .. "PvEVendorA",
-- Icons if enemy faction is disabled for General zone icons
["MMInnkeeperA"] = iconLink .. "InnkeeperA",
["MMInnkeeperH"] = iconLink .. "InnkeeperH",
["MMStablemasterH"] = iconLink .. "StablemasterH",
["MMStablemasterA"] = iconLink .. "StablemasterA",
["MMMailboxH"] = iconLink .. "MailboxH",
["MMMailboxA"] = iconLink .. "MailboxA",
["MMPvPVendorH"] = iconLink .. "PvPVendorH",
["MMPvPVendorA"] = iconLink .. "PvPVendorA",
["MMPvEVendorH"] = iconLink .. "PvEVendorH",
["MMPvEVendorA"] = iconLink .. "PvEVendorA",
["ZonePvEVendorH"] = iconLink .. "PvEVendorH",
["ZonePvPVendorH"] = iconLink .. "PvPVendorH",
["ZonePvEVendorA"] = iconLink .. "PvEVendorA",
["ZonePvPVendorA"] = iconLink .. "PvPVendorA",
--Professions MN New
["ProfessionOrders"] = "interface/minimap/tracking/profession.blp",
["Engineer"] = iconLink .. "Engineering",
["Alchemy"] = iconLink .. "Alchemy",
["Blacksmith"] = iconLink .. "Blacksmithing",
["Skinning"] = iconLink .. "Skinning",
["Enchanting"] = iconLink .. "Enchanting",
["Tailoring"] = iconLink .. "Tailoring",
["Jewelcrafting"] = iconLink .. "Jewelcrafting",
["Leatherworking"] = iconLink .. "Leatherworking",
["Herbalism"] = iconLink .. "Herbalism",
["Mining"] = iconLink .. "Mining",
["Inscription"] = iconLink .. "Inscription",
["Archaeology"] = "interface/archeology/arch-icon-marker.blp",
["Fishing"] = iconLink .. "Fishing",
["Cooking"] = iconLink .. "Cooking",
["FirstAid"] ="interface/icons/spell_holy_sealofsacrifice.blp",
--Professions Original
["OriginalEngineer"] = "interface/icons/ui_profession_engineering.blp",
["OriginalAlchemy"] = "interface/icons/ui_profession_alchemy.blp",
["OriginalBlacksmith"] = "interface/icons/ui_profession_blacksmithing.blp",
["OriginalSkinning"] = "interface/icons/ui_profession_skinning.blp",
["OriginalEnchanting"] = "interface/icons/ui_profession_enchanting.blp",
["OriginalTailoring"] = "interface/icons/ui_profession_tailoring.blp",
["OriginalJewelcrafting"] = "interface/icons/ui_profession_jewelcrafting.blp",
["OriginalLeatherworking"] = "interface/icons/ui_profession_leatherworking.blp",
["OriginalHerbalism"] = "interface/icons/ui_profession_herbalism.blp",
["OriginalMining"] = "interface/icons/ui_profession_mining.blp",
["OriginalInscription"] = "interface/icons/ui_profession_inscription.blp",
["OriginalArchaeology"] = "interface/archeology/arch-icon-marker.blp",
["OriginalFishing"] = "interface/icons/ui_profession_fishing.blp",
["OriginalCooking"] = "interface/icons/ui_profession_cooking.blp",
--Professions Classic Original
["ClassicOriginalEngineer"] = "interface/icons/trade_engineering.blp",
["ClassicOriginalAlchemy"] = "interface/icons/trade_alchemy.blp",
["ClassicOriginalBlacksmith"] = "interface/icons/trade_blacksmithing.blp",
["ClassicOriginalSkinning"] = "interface/icons/inv_misc_pelt_wolf_01.blp",
["ClassicOriginalEnchanting"] = "interface/icons/trade_engraving.blp",
["ClassicOriginalTailoring"] = "interface/icons/trade_tailoring.blp",
["ClassicOriginalJewelcrafting"] = "interface/icons/inv_misc_gem_02.blp",
["ClassicOriginalLeatherworking"] = "interface/icons/trade_leatherworking.blp",
["ClassicOriginalHerbalism"] = "interface/icons/trade_herbalism.blp",
["ClassicOriginalMining"] = "interface/icons/trade_mining.blp",
["ClassicOriginalInscription"] = "interface/icons/inv_inscription_tradeskill01.blp",
["ClassicOriginalArchaeology"] = "interface/archeology/arch-icon-marker.blp",
["ClassicOriginalFishing"] = "interface/icons/trade_fishing.blp",
["ClassicOriginalCooking"] = "interface/icons/inv_misc_food_15.blp",
--Professions New
["ProfessionOrdersNew"] = "interface/minimap/tracking/profession.blp",
["EngineerNew"] = iconLink .. "Engineering",
["AlchemyNew"] = iconLink .. "Alchemy",
["BlacksmithNew"] = iconLink .. "Blacksmithing",
["SkinningNew"] = iconLink .. "Skinning",
["EnchantingNew"] = iconLink .. "Enchanting",
["TailoringNew"] = iconLink .. "Tailoring",
["JewelcraftingNew"] = iconLink .. "Jewelcrafting",
["LeatherworkingNew"] = iconLink .. "Leatherworking",
["HerbalismNew"] = iconLink .. "Herbalism",
["MiningNew"] = iconLink .. "Mining",
["InscriptionNew"] = iconLink .. "Inscription",
["ArchaeologyNew"] = "interface/archeology/arch-icon-marker.blp",
["FishingNew"] = iconLink .. "Fishing",
["CookingNew"] = iconLink .. "Cooking",
--expansion 
["LKalimdor"] = "interface/characterframe/temporaryportrait-male-orc.blp",
["LEK"] = "Interface/CharacterFrame/TemporaryPortrait-Female-Human",
["LBC"] = "Interface/Icons/Achievement_Boss_Illidan",
["LDF"] = "Interface/CharacterFrame/TemporaryPortrait-Male-Dracthyr",
["LZ"] = "Interface/CharacterFrame/TemporaryPortrait-Female-ZandalariTroll",
["LKT"] = "Interface/CharacterFrame/TemporaryPortrait-Male-KulTiran",
["LLG"] = "Interface/Icons/artifactability_HavocDemonHunter_AnguishoftheDeceiver",
["LMOP"] = "Interface/CharacterFrame/TEMPORARYPORTRAIT-FEMALE-PANDAREN",
["LWotlk"] = "interface/lfgframe/ui-lfr-portrait",
["TWW"] = "interface/icons/inv_achievement_raid_progenitorraid_anduin.blp",
--paths
["PathO"] = iconLink .. "PathO",
["PathRO"] = iconLink .. "PathRO",
["PathR"] = iconLink .. "PathR",
["PathRU"] = iconLink .. "PathRU",
["PathU"] = iconLink .. "PathU",
["PathLU"] = iconLink .. "PathLU",
["PathL"] = iconLink .. "PathL",
["PathLO"] = iconLink .. "PathLO",
--instance
["LFR"] = iconLink .. "LFR",
["Dungeon"] = iconLink .. "Dungeon", 
["Raid"] = iconLink .. "Raid", 
["VInstance"] = iconLink .. "vanillaInstance",
["MultiVInstance"] = iconLink .. "multivanillaInstance",
["VKey1"] = iconLink .. "vkey1",
["MultipleM"] = iconLink .. "multipleM",
["MultipleD"] = iconLink .. "multipleD",
["MultipleR"] = iconLink .. "multipleR",
["Gray"] = iconLink .. "gray",
--zeppelin
["Zeppelin"] = iconLink .. "portal",
["HZeppelin"] = iconLink .. "hportal",
--zeppelin Old
["ZeppelinOld"] = iconLink .. "zeppelin",
["HZeppelinOld"] = iconLink .. "zeppelinH",
--zeppelin restore
["ZeppelinNew"] = iconLink .. "portal",
["HZeppelinNew"] = iconLink .. "hportal",
--portal
["Portal"] = iconLink .. "portal",
["PortalS"] = iconLink .. "portalS",
["HPortal"] = iconLink .. "hportal",
["HPortalS"] = iconLink .. "hportalS",
["APortal"] = iconLink .. "aportal",
["APortalS"] = iconLink .. "aportalS",
["PassagePortal"] = iconLink .. "passagePortal",
["PassageHPortal"] = iconLink .. "passageHPortal",
["PassageAPortal"] = iconLink .. "passageAPortal",
--portal Old
["PortalOld"] = iconLink .. "portalOld",
["PortalSOld"] = iconLink .. "portalSOld",
["HPortalOld"] = iconLink .. "hportalOld",
["HPortalSOld"] = iconLink .. "hportalSOld",
["APortalOld"] = iconLink .. "aportalOld",
["APortalSOld"] = iconLink .. "aportalSOld",
["PassagePortalOld"] = iconLink .. "passagePortalOld",
["PassageHPortalOld"] = iconLink .. "passageHPortalOld",
["PassageAPortalOld"] = iconLink .. "passageAPortalOld",
--portal restore nodes
["PortalNew"] = iconLink .. "portal", -- nodes for Classic Icon Style function to get new the new icons back
["PortalSNew"] = iconLink .. "portalS", -- nodes for Classic Icon Style function to get new the new icons back
["HPortalNew"] = iconLink .. "hportal", -- nodes for Classic Icon Style function to get new the new icons back
["HPortalSNew"] = iconLink .. "hportalS", -- nodes for Classic Icon Style function to get new the new icons back
["APortalNew"] = iconLink .. "aportal", -- nodes for Classic Icon Style function to get new the new icons back
["APortalSNew"] = iconLink .. "aportalS", -- nodes for Classic Icon Style function to get new the new icons back
["PassagePortalNew"] = iconLink .. "passagePortal", -- nodes for Classic Icon Style function to get new the new icons back
["PassageHPortalNew"] = iconLink .. "passageHPortal", -- nodes for Classic Icon Style function to get new the new icons back
["PassageAPortalNew"] = iconLink .. "passageAPortal", -- nodes for Classic Icon Style function to get new the new icons back
--ship
["Ship"] = iconLink .. "portal",
["HShip"] = iconLink .. "hportal",
["AShip"] = iconLink .. "aportal",
--ship Old
["ShipOld"] = iconLink .. "shipOld",
["HShipOld"] = iconLink .. "shipHOld",
["AShipOld"] = iconLink .. "shipAOld",
--ship restore nodes
["ShipNew"] = iconLink .. "portal", -- nodes for Classic Icon Style function to get new the new icons back
["HShipNew"] = iconLink .. "hportal", -- nodes for Classic Icon Style function to get new the new icons back
["AShipNew"] = iconLink .. "aportal", -- nodes for Classic Icon Style function to get new the new icons back
--world passage
["PassageDungeonRaid"] = iconLink .. "PassageDungeon",
["PassageDungeon"] = iconLink .. "PassageDungeon", 
["PassageRaid"] = iconLink .. "passageRaid", 
["PassageDungeonRaidMulti"] = iconLink .. "PassageDungeonRaidMulti", 
["PassageRaidMulti"] = iconLink .. "passageRaidMulti",
["PassageDungeonMulti"] = iconLink .. "PassageDungeonMulti",
--inside dungeon icons
["Exit"] = "interface/glues/login/glues-checkbox-check.blp",
["PassageUpL"] = iconLink .. "passageupL",
["PassageDownL"] = iconLink .. "passagedownL",
["PassageRightL"] = iconLink .. "passagerightL",
["PassageLeftL"] = iconLink .. "passageleftL",
--transport
["Tport2"] = iconLink .. "tport2",
["OgreWaygate"] = iconLink .. "ogreWaygate",
["Mirror"] = iconLink .. "mirror",
["WayGateGolden"] = iconLink .. "WayGateGolden",
["WayGateGreen"] = iconLink .. "WayGateGreen",
["Carriage"] = iconLink .. "Carriage",
--travel
["TravelL"] = iconLink .. "travelL",
["TravelM"] = iconLink .. "travelm",
["Travel"] = iconLink .. "travel", -- Horde and Alliance FP
["TravelH"] = iconLink .. "travelH", -- Horde FP
["TravelA"] = iconLink .. "travelA", -- Alliance FP
--special icons
["HIcon"] = iconLink .. "HIcon",
["AIcon"] = iconLink .. "AIcon",
["Ghost"] = iconLink .. "Ghost",
--portrait icons
["B11M"] = "interface/characterframe/temporaryportrait-male-bloodelf",
["MOrcF"] = "interface/characterframe/temporaryportrait-female-magharorc",
["OrcM"] = "interface/characterframe/temporaryportrait-male-orc",
["UndeadF"] = "interface/characterframe/temporaryportrait-female-scourge",
["GoblinF"] = "interface/characterframe/temporaryportrait-female-goblin",
["GilneanF"] = "interface/characterframe/temporaryportrait-female-gilnean",
["KulM"] = "interface/characterframe/temporaryportrait-male-kultiran",
["DwarfF"] = "interface/characterframe/temporaryportrait-female-dwarf",
}

TextIcon = IconClass
TextIconMNL4 = TextIcon(iconLink .. "MNL4", 50, 50, 1, 50, 1, 50)
--General
TextIconInnkeeper = TextIcon("interface/minimap/tracking/innkeeper.blpp", 50, 50, 1, 50, 1, 50)
TextIconInnkeeperN = TextIcon(iconLink .. "InnkeeperN", 50, 50, 1, 50, 1, 50)
TextIconInnkeeperH = TextIcon(iconLink .. "InnkeeperH", 50, 50, 1, 50, 1, 50)
TextIconInnkeeperA = TextIcon(iconLink .. "InnkeeperA", 50, 50, 1, 50, 1, 50)
TextIconAuctioneer = TextIcon(iconLink .. "Auctioneer", 50, 50, 1, 50, 1, 50)
TextIconBlackMarket = TextIcon(iconLink .. "BlackMarket", 50, 50, 1, 50, 1, 50)
TextIconBank = TextIcon("interface/worldmap/treasurechest_64.blp", 50, 50, 1, 50, 1, 50)
TextIconBankOld = TextIcon("interface/minimap/tracking/banker.blp", 50, 50, 1, 50, 1, 50)
TextIconBankNew = TextIcon("interface/worldmap/treasurechest_64.blp", 50, 50, 1, 50, 1, 50)
TextIconBarber = TextIcon("interface/minimap/tracking/barbershop.blp", 50, 50, 1, 50, 1, 50)
TextIconTransmogger = TextIcon("interface/minimap/tracking/transmogrifier.blp", 50, 50, 1 ,50, 1, 50)
TextIconPvPVendor = TextIcon(iconLink .. "PvPVendor", 50, 50, 1 ,50, 1, 50)
TextIconPvPVendorH = TextIcon(iconLink .. "PvPVendorH", 50, 50, 1 ,50, 1, 50)
TextIconPvPVendorA = TextIcon(iconLink .. "PvPVendorA", 50, 50, 1 ,50, 1, 50)
TextIconPvEVendor = TextIcon(iconLink .. "PvEVendor", 50, 50, 1 ,50, 1, 50)
TextIconPvEVendorH = TextIcon(iconLink .. "PvEVendorH", 50, 50, 1 ,50, 1, 50)
TextIconPvEVendorA = TextIcon(iconLink .. "PvEVendorA", 50, 50, 1 ,50, 1, 50)
TextIconItemUpgrade = TextIcon("interface/minimap/tracking/upgradeitem-32x32.blp", 50, 50, 1 ,50, 1, 50)
TextIconDragonFlyTransmog = TextIcon(iconLink .. "DragonFlyTransmog", 50, 50, 1 ,50, 1, 50)
TextIconCatalyst = TextIcon(iconLink .. "Catalyst", 50, 50, 1 ,50, 1, 50)
TextIconMailbox = TextIcon("interface/minimap/tracking/mailbox.blp", 50, 50, 1 ,50, 1, 50)
TextIconMailboxN = TextIcon(iconLink .. "MailboxN", 50, 50, 1 ,50, 1, 50)
TextIconMailboxH = TextIcon(iconLink .. "MailboxH", 50, 50, 1 ,50, 1, 50)
TextIconMailboxA = TextIcon(iconLink .. "MailboxA", 50, 50, 1 ,50, 1, 50)
TextIconStablemasterN = TextIcon(iconLink .. "StablemasterN", 50, 50, 1 ,50, 1, 50)
TextIconStablemasterH = TextIcon(iconLink .. "StablemasterH", 50, 50, 1 ,50, 1, 50)
TextIconStablemasterA = TextIcon(iconLink .. "StablemasterA", 50, 50, 1 ,50, 1, 50)
--Cities
TextIconOrgrimmar = TextIcon("interface/icons/spell_arcane_teleportorgrimmar.blp", 50, 50, 1, 50, 1, 50)
TextIconThunderBluff = TextIcon("interface/icons/spell_arcane_teleportthunderbluff.blp", 50, 50, 1, 50, 1, 50)
TextIconSilvermoon = TextIcon("interface/icons/spell_arcane_teleportsilvermoon.blp", 50, 50, 1, 50, 1, 50)
TextIconUndercity = TextIcon("interface/icons/spell_arcane_teleportundercity.blp", 50, 50, 1, 50, 1, 50)
TextIconStormwind = TextIcon("interface/icons/spell_arcane_teleportstormwind.blp", 50, 50, 1, 50, 1, 50)
TextIconIronforge = TextIcon("interface/icons/spell_arcane_teleportironforge.blp", 50, 50, 1, 50, 1, 50)
TextIconDarnassus = TextIcon("interface/icons/spell_arcane_teleportdarnassus.blp", 50, 50, 1, 50, 1, 50)
TextIconExodar = TextIcon("interface/icons/spell_arcane_teleportexodar.blp", 50, 50, 1, 50, 1, 50)
TextIconShattrath = TextIcon("interface/icons/spell_arcane_teleportshattrath.blp", 50, 50, 1, 50, 1, 50)
TextIconDalaranNorthrend = TextIcon("interface/icons/spell_arcane_teleportdalaran.blp", 50, 50, 1, 50, 1, 50)
TextIconDalaranLegion = TextIcon("interface/icons/spell_arcane_teleportdalaranbrokenisles.blp", 50, 50, 1, 50, 1, 50)
TextIconDazarAlor = TextIcon("interface/icons/spell_arcane_teleportzandalar.blp", 50, 50, 1, 50, 1, 50)
TextIconBoralus = TextIcon("interface/icons/spell_arcane_teleportkultiras.blp", 50, 50, 1, 50, 1, 50)
TextIconSot2M = TextIcon("interface/icons/spell_arcane_teleporthalloftheguardian.blp", 50, 50, 1, 50, 1, 50)
TextIconSot7S = TextIcon("interface/icons/spell_arcane_teleporttolbarad.blp", 50, 50, 1, 50, 1, 50)
TextIconWarspear = TextIcon("interface/icons/spell_arcane_teleportwarspear.blp", 50, 50, 1, 50, 1, 50)
TextIconStormshield = TextIcon("interface/icons/spell_arcane_teleportstormshield.blp", 50, 50, 1, 50, 1, 50)
TextIconOribos = TextIcon("interface/icons/spell_arcane_teleportoribos.blp", 50, 50, 1, 50, 1, 50)
TextIconValdrakken = TextIcon("interface/icons/spell_arcane_teleportvaldrakken.blp", 50, 50, 1, 50, 1, 50)
TextIconDornogal = TextIcon("interface/icons/inv_spell_arcane_telepotdornogal.blp", 50, 50, 1, 50, 1, 50)
TextIconDarkMoon = TextIcon(iconLink .. "DarkMoon", 50, 50, 1, 50, 1, 50)
--profession
TextIconProfessionOrders = TextIcon("interface/minimap/tracking/profession.blp", 50, 50, 1, 50, 1, 50)
TextIconEngineer = TextIcon(iconLink .. "Engineering", 50, 50, 1, 50, 1, 50)
TextIconAlchemy = TextIcon(iconLink .. "Alchemy", 50, 50, 1, 50, 1, 50)
TextIconBlacksmith = TextIcon(iconLink .. "Blacksmithing", 50, 50, 1, 50, 1, 50)
TextIconSkinning = TextIcon(iconLink .. "Skinning", 50, 50, 1, 50, 1, 50)
TextIconTailoring = TextIcon(iconLink .. "Tailoring", 50, 50, 1, 50, 1, 50)
TextIconJewelcrafting = TextIcon(iconLink .. "Jewelcrafting", 50, 50, 1, 50, 1, 50)
TextIconLeatherworking = TextIcon(iconLink .. "Leatherworking", 50, 50, 1, 50, 1, 50)
TextIconHerbalism = TextIcon(iconLink .. "Herbalism", 50, 50, 1, 50, 1, 50)
TextIconMining = TextIcon(iconLink .. "Mining", 50, 50, 1, 50, 1, 50)
TextIconArchaeology = TextIcon("interface/archeology/arch-icon-marker.blp", 50, 50, 1, 50, 1, 50)
TextIconFishing = TextIcon(iconLink .. "Fishing", 50, 50, 1, 50, 1, 50)
TextIconCooking = TextIcon(iconLink .. "Cooking", 50, 50, 1, 50, 1, 50)
TextIconInscription = TextIcon(iconLink .. "Inscription", 50, 50, 1, 50, 1, 50)
TextIconEnchanting = TextIcon(iconLink .. "Enchanting", 50, 50, 1, 50, 1, 50)
TextIconFirstAid = TextIcon("interface/icons/spell_holy_sealofsacrifice.blp", 50, 50, 1, 50, 1, 50)
--profession Original
TextIconOriginalEngineer = TextIcon("interface/icons/ui_profession_engineering.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalAlchemy = TextIcon("interface/icons/ui_profession_alchemy.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalBlacksmith = TextIcon("interface/icons/ui_profession_blacksmithing.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalSkinning = TextIcon("interface/icons/ui_profession_skinning.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalTailoring = TextIcon("interface/icons/ui_profession_tailoring.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalJewelcrafting = TextIcon("interface/icons/ui_profession_jewelcrafting.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalLeatherworking = TextIcon("interface/icons/ui_profession_leatherworking.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalHerbalism = TextIcon("interface/icons/ui_profession_herbalism.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalMining = TextIcon("interface/icons/ui_profession_mining.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalArchaeology = TextIcon("interface/archeology/arch-icon-marker.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalFishing = TextIcon("interface/icons/ui_profession_fishing.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalCooking = TextIcon("interface/icons/ui_profession_cooking.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalInscription = TextIcon("interface/icons/ui_profession_inscription.blp", 50, 50, 1, 50, 1, 50)
TextIconOriginalEnchanting = TextIcon("interface/icons/ui_profession_enchanting.blp", 50, 50, 1, 50, 1, 50)
--profession ClassicOriginal
TextIconClassicOriginalEngineer = TextIcon("interface/icons/trade_engineering.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalAlchemy = TextIcon("interface/icons/trade_alchemy.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalBlacksmith = TextIcon("interface/icons/trade_blacksmithing.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalSkinning = TextIcon("interface/icons/inv_misc_pelt_wolf_01.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalTailoring = TextIcon("interface/icons/trade_tailoring.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalJewelcrafting = TextIcon("interface/icons/inv_misc_gem_02.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalLeatherworking = TextIcon("interface/icons/trade_leatherworking.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalHerbalism = TextIcon("interface/icons/trade_herbalism.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalMining = TextIcon("interface/icons/trade_mining.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalArchaeology = TextIcon("interface/archeology/arch-icon-marker.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalFishing = TextIcon("interface/icons/trade_fishing.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalCooking = TextIcon("interface/icons/inv_misc_food_15.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalInscription = TextIcon("interface/icons/inv_inscription_tradeskill01.blp", 50, 50, 1, 50, 1, 50)
TextIconClassicOriginalEnchanting = TextIcon("interface/icons/trade_engraving.blp", 50, 50, 1, 50, 1, 50)
--portal
TextIconPortal = TextIcon(iconLink .. "portal", 50, 50, 1, 50, 1, 50) 
TextIconHPortal = TextIcon(iconLink .. "hportal", 50, 50, 1, 50, 1, 50)
TextIconAPortal = TextIcon(iconLink .. "aportal", 50, 50, 1, 50, 1, 50)
TextIconPassagePortal = TextIcon(iconLink .. "passagePortal", 50, 50, 1, 50, 1, 50) 
TextIconPassageHPortal = TextIcon(iconLink .. "passageHPortal", 50, 50, 1, 50, 1, 50)
TextIconPassageAPortal = TextIcon(iconLink .. "passageAPortal", 50, 50, 1, 50, 1, 50)
TextIconWayGateGolden = TextIcon(iconLink .. "WayGateGolden", 50, 50, 1, 50, 1, 50)
TextIconWayGateGreen = TextIcon(iconLink .. "WayGateGreen", 50, 50, 1, 50, 1, 50)
--portal Old
TextIconPortalOld = TextIcon(iconLink .. "portalOld", 50, 50, 1, 50, 1, 50) 
TextIconHPortalOld = TextIcon(iconLink .. "hportalOld", 50, 50, 1, 50, 1, 50)
TextIconAPortalOld = TextIcon(iconLink .. "aportalOld", 50, 50, 1, 50, 1, 50)
TextIconPassagePortalOld = TextIcon(iconLink .. "passagePortalOld", 50, 50, 1, 50, 1, 50) 
TextIconPassageHPortalOld = TextIcon(iconLink .. "passageHPortalOld", 50, 50, 1, 50, 1, 50)
TextIconPassageAPortalOld = TextIcon(iconLink .. "passageAPortalOld", 50, 50, 1, 50, 1, 50)
--paths
TextIconPathO = TextIcon(iconLink .. "PathO", 50, 50, 1, 50, 1, 50)
TextIconPathR = TextIcon(iconLink .. "PathR", 50, 50, 1, 50, 1, 50)
TextIconPathU = TextIcon(iconLink .. "PathU", 50, 50, 1, 50, 1, 50)
TextIconPathL = TextIcon(iconLink .. "PathL", 50, 50, 1, 50, 1, 50)
--instance
TextIconLFR = TextIcon(iconLink .. "LFR", 50, 50, 1, 50, 1, 50)
TextIconDungeon = TextIcon(iconLink .. "Dungeon", 50, 50, 1, 50, 1, 50)
TextIconRaid = TextIcon(iconLink .. "Raid", 50, 50, 1, 50, 1, 50)
TextIconVInstance = TextIcon(iconLink .. "vanillaInstance", 50, 50, 1, 50, 1, 50)
TextIconMultiVInstance = TextIcon(iconLink .. "multivanillaInstance", 50, 50, 1, 50, 1, 50)
TextIconVKey1 = TextIcon(iconLink .. "vkey1", 50, 50, 1, 50, 1, 50)
TextIconMultipleM = TextIcon(iconLink .. "multipleM", 50, 50, 1, 50, 1, 50)
TextIconMultipleD = TextIcon(iconLink .. "multipleD", 50, 50, 1, 50, 1, 50)
TextIconMultipleR = TextIcon(iconLink .. "multipleR", 50, 50, 1, 50, 1, 50)
TextIconMultipleMgray = TextIcon(iconLink .. "multipleMgray", 50, 50, 1, 50, 1, 50)
TextIconMultipleDgray = TextIcon(iconLink .. "multipleDgray", 50, 50, 1, 50, 1, 50)
TextIconMultipleRgray = TextIcon(iconLink .. "multipleRgray", 50, 50, 1, 50, 1, 50)
TextIconPassageDungeonRaidM = TextIcon(iconLink .. "PassageDungeonRaid", 50, 50, 1, 50, 1, 50)
TextIconPassageDungeonM = TextIcon(iconLink .. "PassageDungeon", 50, 50, 1, 50, 1, 50)
TextIconPassageRaidM = TextIcon(iconLink .. "PassageRaid", 50, 50, 1, 50, 1, 50)
TextIconPassageDungeonRaidMultiM = TextIcon(iconLink .. "PassageDungeonRaidMulti", 50, 50, 1, 50, 1, 50)
TextIconPassageDungeonMultiM = TextIcon(iconLink .. "PassageDungeonMulti", 50, 50, 1, 50, 1, 50)
TextIconPassageRaidMultiM = TextIcon(iconLink .. "PassageRaidMulti", 50, 50, 1, 50, 1, 50)
TextIconLocked = TextIcon(iconLink .. "gray", 50, 50, 1, 50, 1, 50)
--zeppelin
TextIconZeppelin = TextIcon(iconLink .. "portal", 70, 70, 1, 50, 1, 50)
TextIconHZeppelin = TextIcon(iconLink .. "hportal", 70, 70, 1, 50, 1, 50)
--zeppelin Old
TextIconZeppelinOld = TextIcon(iconLink .. "zeppelin", 70, 70, 1, 50, 1, 50)
TextIconHZeppelinOld = TextIcon(iconLink .. "zeppelinH", 70, 70, 1, 50, 1, 50)
--ship
TextIconShip = TextIcon(iconLink .. "portal", 70, 70, 1, 50, 1, 50)
TextIconHShip = TextIcon(iconLink .. "hportal", 70, 70, 1, 50, 1, 50)
TextIconAShip = TextIcon(iconLink .. "aportal", 70, 70, 1, 50, 1, 50)
--ship Old
TextIconShipOld = TextIcon(iconLink .. "shipOld", 70, 70, 1, 50, 1, 50)
TextIconHShipOld = TextIcon(iconLink .. "shipHOld", 70, 70, 1, 50, 1, 50)
TextIconAShipOld = TextIcon(iconLink .. "shipAOld", 70, 70, 1, 50, 1, 50)
--inside dungeon icons
TextIconExit = TextIcon("interface/glues/login/glues-checkbox-check.blp", 50, 50, 1, 50, 1, 50)
TextIconPassageup = TextIcon(iconLink .. "PassageUpL", 50, 50, 1, 50, 1, 50)
TextIconPassagedown = TextIcon(iconLink .. "PassageDownL", 50, 50, 1, 50, 1, 50)
TextIconPassageright = TextIcon(iconLink .. "PassageRightL", 50, 50, 1, 50, 1, 50)
TextIconPassageleft = TextIcon(iconLink .. "PassageLeftL", 50, 50, 1, 50, 1, 50)
--special icon
TextIconTravel = TextIcon(iconLink .. "travel", 50, 50, 1, 50, 1, 50)
TextIconTravelA = TextIcon(iconLink .. "travelA", 50, 50, 1, 50, 1, 50)
TextIconTravelH = TextIcon(iconLink .. "travelH", 50, 50, 1, 50, 1, 50)
TextIconTravelL = TextIcon(iconLink .. "travelL", 50, 50, 1, 50, 1, 50)
TextIconAIcon = TextIcon(iconLink .. "AIcon", 50, 50, 1, 50, 1, 50)
TextIconHIcon = TextIcon(iconLink .. "HIcon", 50, 50, 1, 50, 1, 50)
TextIconGhost = TextIcon(iconLink .. "Ghost", 50, 50, 1, 50, 1, 50)
--transport
TextIconTransport = TextIcon(iconLink .. "tport2", 60, 60, 1, 50, 1, 50)
TextIconOgreWaygate = TextIcon("Interface/Minimap/Vehicle-AllianceWarlockPortal", 60, 60, 1, 50, 1, 50)
TextIconToyTransport = TextIcon("interface/icons/inv_tailoring_elekkplushie.blp", 50, 50, 1, 50, 1, 50)
TextIconMirror = TextIcon(iconLink .. "mirror", 50, 50, 1, 50, 1, 50)
TextIconCarriage = TextIcon("interface/minimap/vehicle-carriage", 60, 60, 1, 50, 1, 50)
--information
TextIconCheck = TextIcon("Interface/Buttons/UI-CheckBox-Up", 50, 50, 1, 50, 1, 50)
TextIconHorde = TextIcon("interface/pvprankbadges/pvprankhorde")
TextIconAlliance = TextIcon("interface/pvprankbadges/pvprankalliance")
TextIconTomTom = TextIcon(iconLink .."tomtompoint")
TextIconJournal = TextIcon("interface/icons/inv_misc_book_09")
TextIconKilledBosses = TextIcon("Interface/TargetingFrame/UI-RaidTargetingIcon_8")
--expansions
TextIconKalimdor = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Female-Orc")
TextIconEK = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Female-Human")
TextIconBC = TextIcon("Interface/Icons/Achievement_Boss_Illidan")
TextIconNorthrend = TextIcon("interface/lfgframe/ui-lfr-portrait")
TextIconPandaria = TextIcon("Interface/CharacterFrame/TEMPORARYPORTRAIT-FEMALE-PANDAREN")
TextIconDraenor = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Male-MagharOrc")
TextIconLegion = TextIcon("Interface/Icons/artifactability_HavocDemonHunter_AnguishoftheDeceiver")
TextIconZandalar = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Female-ZandalariTroll")
TextIconKT = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Male-KulTiran")
TextIconSL = TextIcon("interface/icons/achievement_leader_sylvanas")
TextIconDF = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Male-Dracthyr")
TextIconKA = TextIcon("interface/lfgframe/lfgicon-khazalgar.blp")
--portrait icons
TextIconGoblinF = TextIcon("interface/characterframe/temporaryportrait-female-goblin")
TextIconKulM = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Male-KulTiran")
TextIconDwarfF = TextIcon("interface/characterframe/temporaryportrait-female-dwarf")
TextIconGilneanF = TextIcon("interface/characterframe/temporaryportrait-female-gilnean")
TextIconB11M = TextIcon"interface/characterframe/temporaryportrait-male-bloodelf"
TextIconOrcF = TextIcon("Interface/CharacterFrame/TemporaryPortrait-Female-Orc")
TextIconUndeadF = TextIcon("interface/characterframe/temporaryportrait-female-scourge")


-- 1 number --self.IconFileX = IconFileX or 0    -- the total X (horizontal) pixels in the image file - not just the icon we want
-- 2 number --self.IconFileY = IconFileY or 0    -- the total Y (vertical) pixels in the image file
-- 3 number --self.StartX = StartX or 0        -- The starting point in the file where the icon begins, counted from the left border, in pixels
-- 4 number --self.EndX = EndX or 0            -- The ending point in the file where the icon ends, counted from the left border, in pixels
-- 5 number --self.StartY = StartY or 0        -- The starting point in the file where the icon begins, counted from the top border, in pixels
-- 6 number --self.EndY = EndY or 0            -- The ending point in the file where the icon ends, counted from the top border, in pixels