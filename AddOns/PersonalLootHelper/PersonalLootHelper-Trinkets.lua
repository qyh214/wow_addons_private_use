--[[
to easily populate these arrays:
	wowhead search trinkets -> usable by "whichever" -> added in expansion/patch; also ID > 0
	paste into OpenOffice
	=concatenate(b1;", -- ";d1)
	ensure curly quotes are off in tools -> autocorrect options -> localized options
	to obtain IDs: http://www.wowhead.com/items/armor/trinkets/role:1?filter=166:151;7:1;0:0#0-3+2
]]--	
PLH_TRINKET_AGILITY_DPS = {
	-- 7.3 trinkets
	152288, -- 7.3 Raid - Antorus - Boss 11 - Trinket Ranged WS
	152285, -- 7.3 Raid - Antorus - Boss 11 - Trinket Melee Str WS
	152701, -- 7.3 Raid - Antorus - Boss 11 - Trinket Melee Agi WS
	151970, -- Vitality Resonator
	151969, -- Terminus Signaling Beacon
	151971, -- Sheath of Asara
	151968, -- Shadow-Singed Fang
	151964, -- Seeping Scourgewing
	151962, -- Prototype Personnel Decimator
	151961, -- Legionsteel Flywheel
	152093, -- Gorshalach's Legacy
	151963, -- Forgefiend's Fabricator
	151967, -- Electrostatic Lasso
	152782, -- Venerable Triad Statuette
	152781, -- Unblemished Sigil of Argus
	152783, -- Mac'aree Focusing Amethyst
	153172, -- Doomed Exarch's Memento
	
	-- 7.2.5 trinkets
	151190, -- Specter of Betrayal
	150526,	-- Shadowmoon Insignia
	150527,	-- Madness of the Betrayer

	-- 7.2 trinkets
	147275, -- Beguiler's Talisman
	144477, -- Splinters of Agronax
	147011, -- Vial of Ceaseless Toxins
	147012, -- Umbral Moonglaives
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147009, -- Infernal Cinders
	147015, -- Engine of Eradication
	147010, -- Cradle of Anguish
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142506, -- Eye of Guarm
	142166, -- Ethereal Urn
	
	-- 7.1 trinkets
	140027, -- Ley Spark
	142164, -- Toe Knee's Promise
	142160, -- Mrrgria's Favor
	142167, -- Eye of Command
	142165, -- Deteriorated Construct Core
	142159, -- Bloodstained Handkerchief
	142157, -- Aran's Relaxing Ruby

	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141537, -- Thrice-Accursed Compass
	141482, -- Unstable Arcanocrystal
	140794, -- Arcanogolem Digit
	140806, -- Convergence of Fates
	140808, -- Draught of Souls
	140796, -- Entwined Elemental Foci
	140801, -- Fury of the Burning Sky
	140798, -- Icon of Rot
	140802, -- Nightblooming Frond
	136258, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	136145, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	139329, -- Bloodthirsty Instinct
	139334, -- Nature's Call
	139320, -- Ravaged Seed Pod
	139325, -- Spontaneous Appendages
	139323, -- Twisting Wind
	138224, -- Unstable Horrorslime
	135806, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	135693, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136716, -- Caged Horror
	137459, -- Chaos Talisman
	137446, -- Elementium Bomb Squirrel Generator
	133641, -- Eye of Skovald
	137539, -- Faulty Countermeasure
	137329, -- Figurehead of the Naglfar
	137369, -- Giant Ornamental Pearl
	136975, -- Hunger of the Pack
	137357, -- Mark of Dargrul
	133644, -- Memento of Angerboda
	137541, -- Moonlit Prism
	137349, -- Naraxas' Spiked Tongue
	137312, -- Nightmare Egg Shell
	137306, -- Oakheart's Gnarled Root
	137433, -- Obelisk of the Void
	136715, -- Spiked Counterweight
	137367, -- Stormsinger Fulmination Charge
	137373, -- Tempered Egg of Serpentrix
	137406, -- Terrorbound Nexus
	140026, -- The Devilsaur's Bite
	137439, -- Tiny Oozeling in a Jar
	137537, -- Tirathon's Betrayal
	137486, -- Windscar Whetstone
	135919, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	136032, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	139630, -- Etching of SargerasDemon Hunter
	128958, -- Lekos' LeashDemon Hunter
	129044, -- Frothing Helhound's Fury
	131803 -- Spine of Barax
}

PLH_TRINKET_INTELLECT_DPS = {
	-- 7.3 trinkets
	152288, -- 7.3 Raid - Antorus - Boss 11 - Trinket Ranged WS
	151970, -- Vitality Resonator
	151969, -- Terminus Signaling Beacon
	151971, -- Sheath of Asara
	151962, -- Prototype Personnel Decimator
	151955, -- Acrid Catalyst Injector
	152782, -- Venerable Triad Statuette
	152781, -- Unblemished Sigil of Argus
	152783, -- Mac'aree Focusing Amethyst
	153172, -- Doomed Exarch's Memento
	151310, -- Reality Breacher
	
	-- 7.2.5 trinkets
	150522,	-- The Skull of Gul'dan
	150388,	-- Hibernation Crystal
	
	-- 7.2 trinkets
	147276, -- Spellbinder's Seal
	144480, -- Dreadstone of Endless Shadows
	147019, -- Tome of Unraveling Sanity
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147002, -- Charm of the Rising Tide
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn

	-- 7.1 trinkets
	140031, -- Mana Spark
	142160, -- Mrrgria's Favor
	142165, -- Deteriorated Construct Core
	142157, -- Aran's Relaxing Ruby
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141536, -- Padawsen's Unlucky Charm
	132970, -- Runas' Nearly Depleted Ley Crystal
	136038, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	135925, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	132895, -- The Watcher's Divine Inspiration
	137367, -- Stormsinger Fulmination Charge
	137398, -- Portable Manacracker
	121810, -- Pocket Void Portal
	137433, -- Obelisk of the Void
	137306, -- Oakheart's Gnarled Root
	137349, -- Naraxas' Spiked Tongue
	137541, -- Moonlit Prism
	137485, -- Infernal Writ
	137329, -- Figurehead of the Naglfar
	133641, -- Eye of Skovald
	137446, -- Elementium Bomb Squirrel Generator
	140030, -- Devilsaur Shock-Baton
	137301, -- Corrupted Starlight
	136716, -- Caged Horror
	121652, -- Ancient Leaf
	139326, -- Wriggling Sinew
	140809, -- Whispers in the Dark
	135699, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136151, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	135812, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136264, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	138224, -- Unstable Horrorslime
	139323, -- Twisting Wind
	139321, -- Swarming Plaguehive
	140804, -- Star Gate
	140800, -- Pharamere's Forbidden Grimore
	140798, -- Icon of Rot
	140801, -- Fury of the Burning Sky
	140792, -- Erratic Metronome
	139336 -- Bough of Corruption
}

PLH_TRINKET_STRENGTH_DPS = {
	-- 7.3 trinkets
	152285, -- 7.3 Raid - Antorus - Boss 11 - Trinket Melee Str WS
	152701, -- 7.3 Raid - Antorus - Boss 11 - Trinket Melee Agi WS
	151968, -- Shadow-Singed Fang
	151964, -- Seeping Scourgewing
	151961, -- Legionsteel Flywheel
	152093, -- Gorshalach's Legacy
	151963, -- Forgefiend's Fabricator
	151967, -- Electrostatic Lasso
	152782, -- Venerable Triad Statuette
	152781, -- Unblemished Sigil of Argus
	152783, -- Mac'aree Focusing Amethyst
	153172, -- Doomed Exarch's Memento
	151307, -- Void Stalker's Contract
	
	-- 7.2.5 trinkets
	151190, -- Specter of Betrayal
	150526,	-- Shadowmoon Insignia
	150527,	-- Madness of the Betrayer

	-- 7.2 trinkets
	147278, -- Stalwart Crest
	144482, -- Fel-Oiled Infernal Machine
	147011, -- Vial of Ceaseless Toxins
	147012, -- Umbral Moonglaives
	147009, -- Infernal Cinders
	147015, -- Engine of Eradication
	147010, -- Cradle of Anguish
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn
	142508, -- Chains of the Valorous

	-- 7.1 trinkets
	140035, -- Fluctuating Arc Capacitor
	142164, -- Toe Knee's Promise
	142167, -- Eye of Command
	142159, -- Bloodstained Handkerchief
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141535, -- Ettin Fingernail
	137486, -- Windscar Whetstone
	136041, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	135928, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	137439, -- Tiny Oozeling in a Jar
	137406, -- Terrorbound Nexus
	129260, -- Tenacity of Cursed Blood
	136715, -- Spiked Counterweight
	137312, -- Nightmare Egg Shell
	121806, -- Mountain Rage Shaker
	121570, -- Might of the Forsaken
	133644, -- Memento of Angerboda
	137357, -- Mark of Dargrul
	140034, -- Impact Tremor
	136975, -- Hunger of the Pack
	137369, -- Giant Ornamental Pearl
	137539, -- Faulty Countermeasure
	137459, -- Chaos Talisman
	135815, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	135702, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136154, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	136267, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	139328, -- Ursoc's Rending Paw
	139325, -- Spontaneous Appendages
	139320, -- Ravaged Seed Pod
	139334, -- Nature's Call
	140799, -- Might of Krosus
	140796, -- Entwined Elemental Foci
	140808, -- Draught of Souls
	140806, -- Convergence of Fates
	140790 -- Claw of the Crystalline Scorpid
}

PLH_TRINKET_HEALER = {
	-- 7.3 trinkets
	152288, -- 7.3 Raid - Antorus - Boss 11 - Trinket Ranged WS
	151959, -- 7.3 Raid - Antorus - Boss 11 - Trinket Healer WS
	152702, -- 7.3 Raid - Antorus - Boss 11 - Trinket All WS
	151970, -- Vitality Resonator
	151969, -- Terminus Signaling Beacon
	151958, -- Tarratus Keystone
	151971, -- Sheath of Asara
	151962, -- Prototype Personnel Decimator
	151957, -- Ishkar's Felshield Emitter
	152289, -- Highfather's Machination
	151956, -- Garothi Feedback Conduit
	151960, -- Carafe of Searing Light
	151955, -- Acrid Catalyst Injector
	152782, -- Venerable Triad Statuette
	152781, -- Unblemished Sigil of Argus
	152783, -- Mac'aree Focusing Amethyst
	153172, -- Doomed Exarch's Memento
	
	-- 7.2.5 trinkets
	150523,	-- Memento of Tyrande
	150388,	-- Hibernation Crystal

	-- 7.2 trinkets
	147276, -- Spellbinder's Seal
	144480, -- Dreadstone of Endless Shadows
	147019, -- Tome of Unraveling Sanity
	147007, -- The Deceiver's Grand Design
	147016, -- Terror From Below
	147017, -- Tarnished Sentinel Medallion
	147018, -- Spectral Thurible
	147004, -- Sea Star of the Depthmother
	147002, -- Charm of the Rising Tide
	147005, -- Chalice of Moonlight
	147003, -- Barbaric Mindslaver
	147006, -- Archive of Faith
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142166, -- Ethereal Urn
	142507, -- Brinewater Slime in a Bottle

	-- 7.1 trinkets
	140031, -- Mana Spark
	142160, -- Mrrgria's Favor
	142162, -- Fluctuating Energy
	142158, -- Faith's Crucible
	142165, -- Deteriorated Construct Core
	142157, -- Aran's Relaxing Ruby
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	141536, -- Padawsen's Unlucky Charm
	132970, -- Runas' Nearly Depleted Ley Crystal
	136038, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	135925, -- Legion Season 1Vindictive Combatant's Insignia of Dominance
	137452, -- Thrumming Gossamer
	132895, -- The Watcher's Divine Inspiration
	137367, -- Stormsinger Fulmination Charge
	137398, -- Portable Manacracker
	121810, -- Pocket Void Portal
	137433, -- Obelisk of the Void
	137306, -- Oakheart's Gnarled Root
	133766, -- Nether Anti-Toxin
	137349, -- Naraxas' Spiked Tongue
	133645, -- Naglfar Fare
	133646, -- Mote of Sanctification
	137541, -- Moonlit Prism
	137462, -- Jewel of Insatiable Desire
	137485, -- Infernal Writ
	137484, -- Flask of the Solemn Night
	137329, -- Figurehead of the Naglfar
	133641, -- Eye of Skovald
	137446, -- Elementium Bomb Squirrel Generator
	140030, -- Devilsaur Shock-Baton
	137301, -- Corrupted Starlight
	137540, -- Concave Reflecting Lens
	136716, -- Caged Horror
	137378, -- Bottled Hurricane
	121652, -- Ancient Leaf
	136714, -- Amalgam's Seventh Spine
	139326, -- Wriggling Sinew
	135812, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136264, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	135699, -- Legion Season 1Vindictive Gladiator's Insignia of Dominance
	136151, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Dominance
	138222, -- Vial of Nightmare Fog
	138224, -- Unstable Horrorslime
	139323, -- Twisting Wind
	139321, -- Swarming Plaguehive
	140793, -- Perfectly Preserved Cake
	139333, -- Horn of Cenarius
	139330, -- Heightened Senses
	140803, -- Etraeus' Celestial Map
	140805, -- Ephemeral Paradox
	139322, -- Cocoon of Enforced Solitude
	139336, -- Bough of Corruption
	140795 -- Aluriel's Mirror
}

PLH_TRINKET_TANK = {
	-- 7.3 trinkets
	152287, -- 7.3 Raid - Antorus - Boss 11 - Trinket Tank WS
	151976, -- Riftworld Codex
	151978, -- Foe-Breaker Titanguard
	152645, -- Eye of
	151974, -- Eye of
	151977, -- Diima's Glacial Aegis
	151975, -- Apocalypse Drive
	152782, -- Venerable Triad Statuette
	152781, -- Unblemished Sigil of Argus
	152783, -- Mac'aree Focusing Amethyst
	153172, -- Doomed Exarch's Memento
	
	-- 7.2.5 trinkets
	150526,	-- Shadowmoon Insignia
	150527,	-- Madness of the Betrayer	
	
	-- 7.2 trinkets
	147278, -- Stalwart Crest
	147275, -- Beguiler's Talisman
	144477, -- Splinters of Agronax
	144482, -- Fel-Oiled Infernal Machine
	147026, -- Shifting Cosmic Sliver
	147024, -- Reliquary of the Damned
	147025, -- Recompiled Guardian Module
	147023, -- Leviathan's Hunger
	147022, -- Feverish Carapace
	
	-- 7.1.5 and previously missed 7.1 trinkets
	142506, -- Eye of Guarm
	142166, -- Ethereal Urn

	-- 7.1 trinkets
	140027, -- Ley Spark
	140035, -- Fluctuating Arc Capacitor
	142169, -- Raven Eidolon
	142168, -- Majordomo's Dinner Bell
	142161, -- Inescapable Dread
	
	137419, -- Chrono Shard
	133642, -- Horn of Valor
	141482, -- Unstable Arcanocrystal
	137315, -- Writhing Heart of Darkness
	136041, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	135928, -- Legion Season 1Vindictive Combatant's Insignia of Victory
	136032, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	135919, -- Legion Season 1Vindictive Combatant's Insignia of Conquest
	140026, -- The Devilsaur's Bite
	129260, -- Tenacity of Cursed Blood
	137344, -- Talisman of the Cragshaper
	131803, -- Spine of Barax
	137440, -- Shivermaw's Jawbone
	137338, -- Shard of Rokmora
	137362, -- Parjesh's Medallion
	137538, -- Orb of Torment
	121806, -- Mountain Rage Shaker
	121570, -- Might of the Forsaken
	128958, -- Lekos' LeashDemon Hunter
	137430, -- Impenetrable Nerubian Husk
	140034, -- Impact Tremor
	133647, -- Gift of Radiance
	129044, -- Frothing Helhound's Fury
	136978, -- Ember of Nullification
	137400, -- Coagulated Nightwell Residue
	135702, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136267, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	135815, -- Legion Season 1Vindictive Gladiator's Insignia of Victory
	136154, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Victory
	135693, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136258, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	135806, -- Legion Season 1Vindictive Gladiator's Insignia of Conquest
	136145, -- Legion Season 1 EliteVindictive Gladiator's Insignia of Conquest
	139327, -- Unbridled Fury
	140791, -- Royal Dagger Haft
	138225, -- Phantasmal Echo
	140807, -- Infernal Contract
	139335, -- Grotesque Statuette
	139324, -- Goblet of Nightmarish Ichor
	140797, -- Fang of Tichcondrius
	139630, -- Etching of SargerasDemon Hunter
	140789 -- Animated Exoskeleton
}
