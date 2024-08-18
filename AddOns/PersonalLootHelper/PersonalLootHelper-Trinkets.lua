--[[
to easily populate these arrays:
	wowhead search item -> armor -> trinkets ->
		usable by = whichever role
		added in expansion/patch = whichever expansion/patch
		obtained through looting = yes
		ID > 0
		quality = rare or epic
	sort by ID descending
	paste into OpenOffice
	=concatenate("[";b1;"] = true, -- ";d1)
	ensure curly quotes are off in tools -> autocorrect options -> localized options
]]--

local TRINKET_AGILITY_DPS = {

	-- 8.3 trinkets
	[173943] = true, -- Torment in a Jar
	[173946] = true, -- Writhing Segment of Drest'agath
	[174044] = true, -- Humming Black Dragonscale
	[174277] = true, -- Lingering Psychic Shell
	[173940] = true, -- Sigil of Warding

	-- 8.1.5 and 8.2 trinkets
	[167866] = true, -- Lurker's Insidious Gift
	[167868] = true, -- Idol of Indiscriminate Consumption
	[168965] = true, -- Modular Platinum Plating
	[169307] = true, -- Vision of Demise
	[169308] = true, -- Chain of Suffering
	[169310] = true, -- Bloodthirsty Urchin
	[169311] = true, -- Ashvane's Razor Coral
	[169313] = true, -- Phial of the Arcane Tempest
	[169315] = true, -- Edicts of the Faithless
	[169318] = true, -- Shockbiter's Fang
	[169319] = true, -- Dribbling Inkpod
	[169769] = true, -- Remote Guidance Device
	
	-- 8.1 trinkets
	[165572] = true, -- Variable Intensity Gigavolt Oscillating Reactor
	[165579] = true, -- Kimbul's Razor Claw
	[165568] = true, -- Invocation of Yu'lon
	[166794] = true, -- Forest Lord's Razorleaf
	[165573] = true, -- Diamond-Laced Refracting Prism
	[165577] = true, -- Bwonsamdi's Bargain
	
	-- 8.0 Trinkets
	[161412] = true, -- Spiritbound Voodoo Burl
	[161125] = true, -- Kaja-fied Banana
	[161119] = true, -- Ravasaur Skull Bijou
	[161113] = true, -- Incessantly Ticking Clock
	[160653] = true, -- Xalzaix's Veiled Eye
	[160652] = true, -- Construct Overcharger
	[160648] = true, -- Frenetic Corpuscle
	[160263] = true, -- Snowpelt Mangler
	[159628] = true, -- Kul Tiran Cannonball Runner
	[159626] = true, -- Lingering Sporepods
	[159623] = true, -- Dead-Eye Spyglass
	[159618] = true, -- Mchimba's Ritual Bandages
	[159617] = true, -- Lustrous Golden Plumage
	[159614] = true, -- Galecaller's Boon
	[158556] = true, -- Siren's Tongue
	[158555] = true, -- Doom Shroom
	[158374] = true, -- Tiny Electromental in a Jar
	[158319] = true, -- My'das Talisman
	[158224] = true, -- Vial of Storms
	[158218] = true, -- Dadalea's Wing
	[158216] = true, -- Living Oil Cannister
	[155881] = true, -- Harlan's Loaded Dice
	[155568] = true, -- Galewind Chimes
	
	-- Legion Trinkets
	[154174] = true, -- Golganneth's Vitality
	[154173] = true, -- Aggramar's Conviction
	[153544] = true, -- Eye of F'harg
	[151977] = true, -- Diima's Glacial Aegis
	[151312] = true, -- Ampoule of Pure Void
	[151307] = true, -- Void Stalker's Contract
	[151190] = true, -- Specter of Betrayal
	[150527] = true, -- Madness of the Betrayer
	[150526] = true, -- Shadowmoon Insignia
	[147022] = true, -- Feverish Carapace
	[147019] = true, -- Tome of Unraveling Sanity
	[147011] = true, -- Vial of Ceaseless Toxins
	[144477] = true, -- Splinters of Agronox
	[144113] = true, -- Windswept Pages
	[142506] = true, -- Eye of Guarm
	[142167] = true, -- Eye of Command
	[142166] = true, -- Ethereal Urn
	[142165] = true, -- Deteriorated Construct Core
	[142159] = true, -- Bloodstained Handkerchief
	[141585] = true, -- Six-Feather Fan
	[141537] = true, -- Thrice-Accursed Compass
	[140806] = true, -- Convergence of Fates
	[140802] = true, -- Nightblooming Frond
	[140797] = true, -- Fang of Tichondrius
	[140796] = true, -- Entwined Elemental Foci
	[140794] = true, -- Arcanogolem Digit
	[139630] = true, -- Etching of SargerasDemon Hunter
	[139329] = true, -- Bloodthirsty Instinct
	[139324] = true, -- Goblet of Nightmarish Ichor
	[139323] = true, -- Twisting Wind
	[137537] = true, -- Tirathon's Betrayal
	[137419] = true, -- Chrono Shard
	[137373] = true, -- Tempered Egg of Serpentrix
	[137367] = true, -- Stormsinger Fulmination Charge
	[137338] = true, -- Shard of Rokmora
	[137312] = true, -- Nightmare Egg Shell
	[136978] = true, -- Ember of Nullification
	[136975] = true, -- Hunger of the Pack
	[133647] = true, -- Gift of Radiance
	[133644] = true, -- Memento of Angerboda
	[129091] = true, -- Golza's Iron Fin
	[121808] = true  -- Nether Conductors
}

local TRINKET_INTELLECT_DPS = {

	-- 8.3 trinkets
	[174060] = true, -- Psyche Shredder
	[174103] = true, -- Manifesto of Madness
	[173944] = true, -- Forbidden Obsidian Claw
	[174044] = true, -- Humming Black Dragonscale
	[174180] = true, -- Oozing Coagulum
	
	
	-- 8.1.5 and 8.2 trinkets
	[169344] = true, -- Ingenious Mana Battery
	[169318] = true, -- Shockbiter's Fang
	[169316] = true, -- Deferred Sentence
	[169312] = true, -- Luminous Jellyweed
	[169309] = true, -- Zoatroid Egg Sac
	[169305] = true, -- Aquipotent Nautilus
	[169304] = true, -- Leviathan's Lure
	[168905] = true, -- Shiver Venom Relic
	[167867] = true, -- Harbinger's Inscrutable Will
	[167865] = true, -- Void Stone
	
	-- 8.1 trinkets
	[165569] = true, -- Ward of Envelopment
	[165576] = true, -- Tidestorm Codex
	[165578] = true, -- Mirror of Entwined Fate
	[165571] = true, -- Incandescent Sliver
	[165581] = true, -- Crest of Pa'ku
	[166418] = true, -- Crest of Pa'ku
	[166793] = true, -- Ancient Knot of Wisdom
	
	-- 8.0 Trinkets
	[161472] = true, -- Lion's Grace
	[161461] = true, -- Doom's Hatred
	[161411] = true, -- T'zane's Barkspines
	[161377] = true, -- Azurethos' Singed Plumage
	[161125] = true, -- Kaja-fied Banana
	[161119] = true, -- Ravasaur Skull Bijou
	[161113] = true, -- Incessantly Ticking Clock
	[160651] = true, -- Vigilant's Bloodshaper
	[160649] = true, -- Inoculating Extract
	[160263] = true, -- Snowpelt Mangler
	[159631] = true, -- Lady Waycrest's Music Box
	[159624] = true, -- Rotcrusted Voodoo Doll
	[159622] = true, -- Hadal's Nautilus
	[159620] = true, -- Conch of Dark Whispers
	[159615] = true, -- Ignition Mage's Fuse
	[159610] = true, -- Vessel of Skittering Shadows
	[158556] = true, -- Siren's Tongue
	[158555] = true, -- Doom Shroom
	[158368] = true, -- Fangs of Intertwined Essence
	[158320] = true, -- Revitalizing Voodoo Totem
	[158224] = true, -- Vial of Storms
	[158218] = true, -- Dadalea's Wing
	[158216] = true, -- Living Oil Cannister
	[155568] = true, -- Galewind Chimes
	
	-- Legion Trinkets
	[156288] = true, -- Elemental Focus Stone
	[156245] = true, -- Show of Faith
	[156021] = true, -- Energy Siphon
	[154175] = true, -- Eonar's Compassion
	[151971] = true, -- Sheath of Asara
	[151960] = true, -- Carafe of Searing Light
	[151958] = true, -- Tarratus Keystone
	[151956] = true, -- Garothi Feedback Conduit
	[151955] = true, -- Acrid Catalyst Injector
	[151340] = true, -- Echo of L'ura
	[151310] = true, -- Reality Breacher
	[150523] = true, -- Memento of Tyrande
	[150522] = true, -- The Skull of Gul'dan
	[147019] = true, -- Tome of Unraveling Sanity
	[147005] = true, -- Chalice of Moonlight
	[147003] = true, -- Barbaric Mindslaver
	[147002] = true, -- Charm of the Rising Tide
	[144480] = true, -- Dreadstone of Endless Shadows
	[144159] = true, -- Price of Progress
	[144157] = true, -- Vial of Ichorous Blood
	[144136] = true, -- Vision of the Predator
	[142166] = true, -- Ethereal Urn
	[142165] = true, -- Deteriorated Construct Core
	[142162] = true, -- Fluctuating Energy
	[141584] = true, -- Eyasu's Mulligan
	[141536] = true, -- Padawsen's Unlucky Charm
	[140809] = true, -- Whispers in the Dark
	[140805] = true, -- Ephemeral Paradox
	[140804] = true, -- Star Gate
	[140803] = true, -- Etraeus' Celestial Map
	[140792] = true, -- Erratic Metronome
	[139323] = true, -- Twisting Wind
	[139322] = true, -- Cocoon of Enforced Solitude
	[137485] = true, -- Infernal Writ
	[137484] = true, -- Flask of the Solemn Night
	[137462] = true, -- Jewel of Insatiable Desire
	[137452] = true, -- Thrumming Gossamer
	[137419] = true, -- Chrono Shard
	[137398] = true, -- Portable Manacracker
	[137367] = true, -- Stormsinger Fulmination Charge
	[136714] = true, -- Amalgam's Seventh Spine
	[129056] = true  -- Dreadlord's Hamstring
}

local TRINKET_STRENGTH_DPS = {

	-- 8.3 trinkets
	[173943] = true, -- Torment in a Jar
	[173946] = true, -- Writhing Segment of Drest'agath
	[174044] = true, -- Humming Black Dragonscale
	[174277] = true, -- Lingering Psychic Shell
	[173940] = true, -- Sigil of Warding


	-- 8.1.5 and 8.2 trinkets
	[169769] = true, -- Remote Guidance Device
	[169319] = true, -- Dribbling Inkpod
	[169318] = true, -- Shockbiter's Fang
	[169315] = true, -- Edicts of the Faithless
	[169313] = true, -- Phial of the Arcane Tempest
	[169311] = true, -- Ashvane's Razor Coral
	[169310] = true, -- Bloodthirsty Urchin
	[169308] = true, -- Chain of Suffering
	[169307] = true, -- Vision of Demise
	[168965] = true, -- Modular Platinum Plating
	[167868] = true, -- Idol of Indiscriminate Consumption
	[167866] = true, -- Lurker's Insidious Gift
	
	-- 8.1 trinkets
	[165580] = true, -- Ramping Amplitude Gigavolt Engine
	[166795] = true, -- Knot of Ancient Fury
	[165574] = true, -- Grong's Primal Rage
	[165570] = true, -- Everchill Anchor
	[165573] = true, -- Diamond-Laced Refracting Prism
	[165577] = true, -- Bwonsamdi's Bargain
	
	-- 8.0 Trinkets
	[161474] = true, -- Lion's Strength
	[161463] = true, -- Doom's Fury
	[161379] = true, -- Galecaller's Beak
	[161125] = true, -- Kaja-fied Banana
	[161119] = true, -- Ravasaur Skull Bijou
	[161113] = true, -- Incessantly Ticking Clock
	[160655] = true, -- Syringe of Bloodborne Infirmity
	[160653] = true, -- Xalzaix's Veiled Eye
	[160650] = true, -- Disc of Systematic Regression
	[160263] = true, -- Snowpelt Mangler
	[159627] = true, -- Jes' Howler
	[159626] = true, -- Lingering Sporepods
	[159619] = true, -- Briny Barnacle
	[159618] = true, -- Mchimba's Ritual Bandages
	[159616] = true, -- Gore-Crusted Butcher's Block
	[159611] = true, -- Razdunk's Big Red Button
	[158712] = true, -- Rezan's Gleaming Eye
	[158556] = true, -- Siren's Tongue
	[158555] = true, -- Doom Shroom
	[158367] = true, -- Merektha's Fang
	[158224] = true, -- Vial of Storms
	[158218] = true, -- Dadalea's Wing
	[158216] = true, -- Living Oil Cannister
	[155568] = true, -- Galewind Chimes
	
	-- Legion Trinkets
	[154176] = true, -- Khaz'goroth's Courage
	[154173] = true, -- Aggramar's Conviction
	[153544] = true, -- Eye of F'harg
	[151977] = true, -- Diima's Glacial Aegis
	[151312] = true, -- Ampoule of Pure Void
	[151307] = true, -- Void Stalker's Contract
	[151190] = true, -- Specter of Betrayal
	[150527] = true, -- Madness of the Betrayer
	[150526] = true, -- Shadowmoon Insignia
	[147022] = true, -- Feverish Carapace
	[147011] = true, -- Vial of Ceaseless Toxins
	[144482] = true, -- Fel-Oiled Infernal Machine
	[144122] = true, -- Carbonic Carbuncle
	[142508] = true, -- Chains of the Valorous
	[142167] = true, -- Eye of Command
	[142166] = true, -- Ethereal Urn
	[142159] = true, -- Bloodstained Handkerchief
	[141586] = true, -- Marfisi's Giant Censer
	[141535] = true, -- Ettin Fingernail
	[140806] = true, -- Convergence of Fates
	[140799] = true, -- Might of Krosus
	[140797] = true, -- Fang of Tichondrius
	[140796] = true, -- Entwined Elemental Foci
	[140790] = true, -- Claw of the Crystalline Scorpid
	[139328] = true, -- Ursoc's Rending Paw
	[139324] = true, -- Goblet of Nightmarish Ichor
	[137419] = true, -- Chrono Shard
	[137338] = true, -- Shard of Rokmora
	[137312] = true, -- Nightmare Egg Shell
	[136978] = true, -- Ember of Nullification
	[136975] = true, -- Hunger of the Pack
	[133647] = true, -- Gift of Radiance
	[133644] = true, -- Memento of Angerboda
	[131799] = true, -- Zugdug's Piece of Paradise
	[130126] = true, -- Iron Branch
	[129163] = true  -- Lost Etin's Strength
}

local TRINKET_HEALER = {

	-- 8.3 trinkets
	[174060] = true, -- Psyche Shredder
	[174103] = true, -- Manifesto of Madness
	[173944] = true, -- Forbidden Obsidian Claw
	[174044] = true, -- Humming Black Dragonscale
	[174180] = true, -- Oozing Coagulum


	-- 8.1.5 and 8.2 trinkets
	[169344] = true, -- Ingenious Mana Battery
	[169318] = true, -- Shockbiter's Fang
	[169316] = true, -- Deferred Sentence
	[169312] = true, -- Luminous Jellyweed
	[169309] = true, -- Zoatroid Egg Sac
	[169305] = true, -- Aquipotent Nautilus
	[169304] = true, -- Leviathan's Lure
	[168905] = true, -- Shiver Venom Relic
	[167867] = true, -- Harbinger's Inscrutable Will
	[167865] = true, -- Void Stone
	
	-- 8.1 trinkets
	[165569] = true, -- Ward of Envelopment
	[165576] = true, -- Tidestorm Codex
	[165578] = true, -- Mirror of Entwined Fate
	[165571] = true, -- Incandescent Sliver
	[165581] = true, -- Crest of Pa'ku
	[166418] = true, -- Crest of Pa'ku
	[166793] = true, -- Ancient Knot of Wisdom
	
	-- 8.0 Trinkets
	[161472] = true, -- Lion's Grace
	[161461] = true, -- Doom's Hatred
	[161411] = true, -- T'zane's Barkspines
	[161377] = true, -- Azurethos' Singed Plumage
	[161125] = true, -- Kaja-fied Banana
	[161119] = true, -- Ravasaur Skull Bijou
	[161113] = true, -- Incessantly Ticking Clock
	[160651] = true, -- Vigilant's Bloodshaper
	[160649] = true, -- Inoculating Extract
	[160263] = true, -- Snowpelt Mangler
	[159631] = true, -- Lady Waycrest's Music Box
	[159624] = true, -- Rotcrusted Voodoo Doll
	[159622] = true, -- Hadal's Nautilus
	[159620] = true, -- Conch of Dark Whispers
	[159615] = true, -- Ignition Mage's Fuse
	[159610] = true, -- Vessel of Skittering Shadows
	[158556] = true, -- Siren's Tongue
	[158555] = true, -- Doom Shroom
	[158368] = true, -- Fangs of Intertwined Essence
	[158320] = true, -- Revitalizing Voodoo Totem
	[158224] = true, -- Vial of Storms
	[158218] = true, -- Dadalea's Wing
	[158216] = true, -- Living Oil Cannister
	[155568] = true, -- Galewind Chimes

	-- Legion Trinkets
	[156288] = true, -- Elemental Focus Stone
	[156245] = true, -- Show of Faith
	[156021] = true, -- Energy Siphon
	[154175] = true, -- Eonar's Compassion
	[151971] = true, -- Sheath of Asara
	[151960] = true, -- Carafe of Searing Light
	[151958] = true, -- Tarratus Keystone
	[151956] = true, -- Garothi Feedback Conduit
	[151955] = true, -- Acrid Catalyst Injector
	[151340] = true, -- Echo of L'ura
	[151310] = true, -- Reality Breacher
	[150523] = true, -- Memento of Tyrande
	[150522] = true, -- The Skull of Gul'dan
	[147019] = true, -- Tome of Unraveling Sanity
	[147005] = true, -- Chalice of Moonlight
	[147003] = true, -- Barbaric Mindslaver
	[147002] = true, -- Charm of the Rising Tide
	[144480] = true, -- Dreadstone of Endless Shadows
	[144159] = true, -- Price of Progress
	[144157] = true, -- Vial of Ichorous Blood
	[144136] = true, -- Vision of the Predator
	[142166] = true, -- Ethereal Urn
	[142165] = true, -- Deteriorated Construct Core
	[142162] = true, -- Fluctuating Energy
	[141584] = true, -- Eyasu's Mulligan
	[141536] = true, -- Padawsen's Unlucky Charm
	[140809] = true, -- Whispers in the Dark
	[140805] = true, -- Ephemeral Paradox
	[140804] = true, -- Star Gate
	[140803] = true, -- Etraeus' Celestial Map
	[140792] = true, -- Erratic Metronome
	[139323] = true, -- Twisting Wind
	[139322] = true, -- Cocoon of Enforced Solitude
	[137485] = true, -- Infernal Writ
	[137484] = true, -- Flask of the Solemn Night
	[137462] = true, -- Jewel of Insatiable Desire
	[137452] = true, -- Thrumming Gossamer
	[137419] = true, -- Chrono Shard
	[137398] = true, -- Portable Manacracker
	[137367] = true, -- Stormsinger Fulmination Charge
	[136714] = true, -- Amalgam's Seventh Spine
	[129056] = true  -- Dreadlord's Hamstring
}

local TRINKET_TANK = {

	-- 8.3 trinkets
	[173943] = true, -- Torment in a Jar
	[173946] = true, -- Writhing Segment of Drest'agath
	[174044] = true, -- Humming Black Dragonscale
	[174277] = true, -- Lingering Psychic Shell
	[173940] = true, -- Sigil of Warding


	-- 8.1.5 and 8.2 trinkets
	[169769] = true, -- Remote Guidance Device
	[169319] = true, -- Dribbling Inkpod
	[169318] = true, -- Shockbiter's Fang
	[169315] = true, -- Edicts of the Faithless
	[169313] = true, -- Phial of the Arcane Tempest
	[169311] = true, -- Ashvane's Razor Coral
	[169310] = true, -- Bloodthirsty Urchin
	[169308] = true, -- Chain of Suffering
	[169307] = true, -- Vision of Demise
	[168965] = true, -- Modular Platinum Plating
	[167868] = true, -- Idol of Indiscriminate Consumption
	[167866] = true, -- Lurker's Insidious Gift
	
	-- 8.1 trinkets
	[165572] = true, -- Variable Intensity Gigavolt Oscillating Reactor
	[165580] = true, -- Ramping Amplitude Gigavolt Engine
	[166795] = true, -- Knot of Ancient Fury
	[165579] = true, -- Kimbul's Razor Claw
	[165568] = true, -- Invocation of Yu'lon
	[165574] = true, -- Grong's Primal Rage
	[166794] = true, -- Forest Lord's Razorleaf
	[165570] = true, -- Everchill Anchor
	[165573] = true, -- Diamond-Laced Refracting Prism
	[165577] = true, -- Bwonsamdi's Bargain
	
	-- 8.0 Trinkets
	[161474] = true, -- Lion's Strength
	[161463] = true, -- Doom's Fury
	[161412] = true, -- Spiritbound Voodoo Burl
	[161379] = true, -- Galecaller's Beak
	[161125] = true, -- Kaja-fied Banana
	[161119] = true, -- Ravasaur Skull Bijou
	[161113] = true, -- Incessantly Ticking Clock
	[160655] = true, -- Syringe of Bloodborne Infirmity
	[160653] = true, -- Xalzaix's Veiled Eye
	[160652] = true, -- Construct Overcharger
	[160650] = true, -- Disc of Systematic Regression
	[160648] = true, -- Frenetic Corpuscle
	[160263] = true, -- Snowpelt Mangler
	[159628] = true, -- Kul Tiran Cannonball Runner
	[159627] = true, -- Jes' Howler
	[159626] = true, -- Lingering Sporepods
	[159623] = true, -- Dead-Eye Spyglass
	[159619] = true, -- Briny Barnacle
	[159618] = true, -- Mchimba's Ritual Bandages
	[159617] = true, -- Lustrous Golden Plumage
	[159616] = true, -- Gore-Crusted Butcher's Block
	[159614] = true, -- Galecaller's Boon
	[159611] = true, -- Razdunk's Big Red Button
	[158712] = true, -- Rezan's Gleaming Eye
	[158556] = true, -- Siren's Tongue
	[158555] = true, -- Doom Shroom
	[158374] = true, -- Tiny Electromental in a Jar
	[158367] = true, -- Merektha's Fang
	[158319] = true, -- My'das Talisman
	[158224] = true, -- Vial of Storms
	[158218] = true, -- Dadalea's Wing
	[158216] = true, -- Living Oil Cannister
	[155881] = true, -- Harlan's Loaded Dice
	[155568] = true, -- Galewind Chimes
	
	-- Legion Trinkets
	[154176] = true, -- Khaz'goroth's Courage
	[154174] = true, -- Golganneth's Vitality
	[154173] = true, -- Aggramar's Conviction
	[153544] = true, -- Eye of F'harg
	[151977] = true, -- Diima's Glacial Aegis
	[151312] = true, -- Ampoule of Pure Void
	[151307] = true, -- Void Stalker's Contract
	[151190] = true, -- Specter of Betrayal
	[150527] = true, -- Madness of the Betrayer
	[150526] = true, -- Shadowmoon Insignia
	[147022] = true, -- Feverish Carapace
	[147019] = true, -- Tome of Unraveling Sanity
	[147011] = true, -- Vial of Ceaseless Toxins
	[144482] = true, -- Fel-Oiled Infernal Machine
	[144477] = true, -- Splinters of Agronox
	[144122] = true, -- Carbonic Carbuncle
	[144113] = true, -- Windswept Pages
	[142508] = true, -- Chains of the Valorous
	[142506] = true, -- Eye of Guarm
	[142167] = true, -- Eye of Command
	[142166] = true, -- Ethereal Urn
	[142165] = true, -- Deteriorated Construct Core
	[142159] = true, -- Bloodstained Handkerchief
	[141586] = true, -- Marfisi's Giant Censer
	[141585] = true, -- Six-Feather Fan
	[141537] = true, -- Thrice-Accursed Compass
	[141535] = true, -- Ettin Fingernail
	[140806] = true, -- Convergence of Fates
	[140802] = true, -- Nightblooming Frond
	[140799] = true, -- Might of Krosus
	[140797] = true, -- Fang of Tichondrius
	[140796] = true, -- Entwined Elemental Foci
	[140794] = true, -- Arcanogolem Digit
	[140790] = true, -- Claw of the Crystalline Scorpid
	[139630] = true, -- Etching of SargerasDemon Hunter
	[139329] = true, -- Bloodthirsty Instinct
	[139328] = true, -- Ursoc's Rending Paw
	[139324] = true, -- Goblet of Nightmarish Ichor
	[139323] = true, -- Twisting Wind
	[137537] = true, -- Tirathon's Betrayal
	[137419] = true, -- Chrono Shard
	[137373] = true, -- Tempered Egg of Serpentrix
	[137367] = true, -- Stormsinger Fulmination Charge
	[137338] = true, -- Shard of Rokmora
	[137312] = true, -- Nightmare Egg Shell
	[136978] = true, -- Ember of Nullification
	[136975] = true, -- Hunger of the Pack
	[133647] = true, -- Gift of Radiance
	[133644] = true, -- Memento of Angerboda
	[131799] = true, -- Zugdug's Piece of Paradise
	[130126] = true, -- Iron Branch
	[129163] = true, -- Lost Etin's Strength
	[129091] = true, -- Golza's Iron Fin
	[121808] = true  -- Nether Conductors
}

local TRINKET_UNKNOWN = {
	-- 8.0 Trinkets
	[163703] = true, -- Crawg Gnawed Femur
	[161473] = true, -- Lion's Guile
	[161462] = true, -- Doom's Wake
	[161419] = true, -- Kraulok's Claw
	[161381] = true, -- Permafrost-Encrusted Heart
	[161380] = true, -- Drust-Runed Icicle
	[161378] = true, -- Plume of the Seaborne Avian
	[161376] = true, -- Prism of Dark Intensity
	[160656] = true, -- Twitching Tentacle of Xalzaix
	[160654] = true, -- Vanquished Tendril of G'huun
	[159630] = true, -- Balefire Branch
	[159625] = true, -- Vial of Animated Blood
	[159612] = true, -- Azerokk's Resonating Heart
	[158215] = true, -- Whirlwing's Plumage
	
	-- Legion Trinkets
	[156458] = true, -- Vanquished Clutches of Yogg-Saron
	[156345] = true, -- Royal Seal of King Llane
	[156234] = true, -- Blood of the Old God
	[156230] = true, -- Flare of the Heavens
	[156221] = true, -- The General's Heart
	[156041] = true, -- Furnace Stone
	[156036] = true, -- Eye of the Broodmother
	[156016] = true, -- Pyrite Infuser
	[155952] = true, -- Heart of Iron
	[155947] = true, -- Living Flame
	[154177] = true, -- Norgannon's Prowess
	[152645] = true, -- Eye of Shatug
	[152289] = true, -- Highfather's Machination
	[152093] = true, -- Gorshalach's Legacy
	[151978] = true, -- Smoldering Titanguard
	[151976] = true, -- Riftworld Codex
	[151975] = true, -- Apocalypse Drive
	[151974] = true, -- Eye of
	[151970] = true, -- Vitality Resonator
	[151969] = true, -- Terminus Signaling Beacon
	[151968] = true, -- Shadow-Singed Fang
	[151964] = true, -- Seeping Scourgewing
	[151963] = true, -- Forgefiend's Fabricator
	[151962] = true, -- Prototype Personnel Decimator
	[151957] = true, -- Ishkar's Felshield Emitter
	[150388] = true, -- Hibernation Crystal
	[147026] = true, -- Shifting Cosmic Sliver
	[147025] = true, -- Recompiled Guardian Module
	[147024] = true, -- Reliquary of the Damned
	[147023] = true, -- Leviathan's Hunger
	[147018] = true, -- Spectral Thurible
	[147017] = true, -- Tarnished Sentinel Medallion
	[147016] = true, -- Terror From Below
	[147015] = true, -- Engine of Eradication
	[147012] = true, -- Umbral Moonglaives
	[147010] = true, -- Cradle of Anguish
	[147009] = true, -- Infernal Cinders
	[147007] = true, -- The Deceiver's Grand Design
	[147006] = true, -- Archive of Faith
	[147004] = true, -- Sea Star of the Depthmother
	[144161] = true, -- Lessons of the Darkmaster
	[144160] = true, -- Searing Words
	[144158] = true, -- Flashing Steel Talisman
	[144156] = true, -- Flashfrozen Resin Globule
	[144119] = true, -- Empty Fruit Barrel
	[142169] = true, -- Raven Eidolon
	[142168] = true, -- Majordomo's Dinner Bell
	[142164] = true, -- Toe Knee's Promise
	[142161] = true, -- Inescapable Dread
	[142160] = true, -- Mrrgria's Favor
	[142158] = true, -- Faith's Crucible
	[142157] = true, -- Aran's Relaxing Ruby
	[141482] = true, -- Unstable Arcanocrystal
	[140808] = true, -- Draught of Souls
	[140807] = true, -- Infernal Contract
	[140801] = true, -- Fury of the Burning Sky
	[140800] = true, -- Pharamere's Forbidden Grimoire
	[140798] = true, -- Icon of Rot
	[140795] = true, -- Aluriel's Mirror
	[140793] = true, -- Perfectly Preserved Cake
	[140791] = true, -- Royal Dagger Haft
	[140789] = true, -- Animated Exoskeleton
	[140533] = true, -- Huntmaster's Injector
	[139336] = true, -- Bough of Corruption
	[139335] = true, -- Grotesque Statuette
	[139330] = true, -- Heightened Senses
	[139327] = true, -- Unbridled Fury
	[139326] = true, -- Wriggling Sinew
	[139325] = true, -- Spontaneous Appendages
	[139321] = true, -- Swarming Plaguehive
	[139320] = true, -- Ravaged Seed Pod
	[138225] = true, -- Phantasmal Echo
	[138224] = true, -- Unstable Horrorslime
	[138222] = true, -- Vial of Nightmare Fog
	[137541] = true, -- Moonlit Prism
	[137540] = true, -- Concave Reflecting Lens
	[137539] = true, -- Faulty Countermeasure
	[137538] = true, -- Orb of Torment
	[137486] = true, -- Windscar Whetstone
	[137459] = true, -- Chaos Talisman
	[137446] = true, -- Elementium Bomb Squirrel Generator
	[137440] = true, -- Shivermaw's Jawbone
	[137439] = true, -- Tiny Oozeling in a Jar
	[137433] = true, -- Obelisk of the Void
	[137430] = true, -- Impenetrable Nerubian Husk
	[137406] = true, -- Terrorbound Nexus
	[137400] = true, -- Coagulated Nightwell Residue
	[137378] = true, -- Bottled Hurricane
	[137369] = true, -- Giant Ornamental Pearl
	[137362] = true, -- Parjesh's Medallion
	[137357] = true, -- Mark of Dargrul
	[137344] = true, -- Talisman of the Cragshaper
	[137329] = true, -- Figurehead of the Naglfar
	[137315] = true, -- Writhing Heart of Darkness
	[137306] = true, -- Oakheart's Gnarled Root
	[137301] = true, -- Corrupted Starlight
	[136716] = true, -- Caged Horror
	[136715] = true, -- Spiked Counterweight
	[133766] = true, -- Nether Anti-Toxin
	[133646] = true, -- Mote of Sanctification
	[133645] = true, -- Naglfar Fare
	[133641] = true, -- Eye of Skovald
	[133580] = true, -- Brutarg's Sword TipDemon Hunter
	[132895] = true, -- The Watcher's Divine Inspiration
	[129101] = true, -- Alpha's Paw
	[129044] = true, -- Frothing Helhound's Fury
	[128958] = true, -- Lekos' LeashDemon Hunter
	[121810] = true, -- Pocket Void Portal
	[121806] = true  -- Mountain Rage Shaker
}

function PLH_GetTrinketList(role)
	trinketList = nil
	if role == PLH_ROLE_AGILITY_DPS then
		trinketList = TRINKET_AGILITY_DPS
	elseif role == PLH_ROLE_INTELLECT_DPS then
		trinketList = TRINKET_INTELLECT_DPS
	elseif role == PLH_ROLE_STRENGTH_DPS then
		trinketList = TRINKET_STRENGTH_DPS
	elseif role == PLH_ROLE_HEALER then
		trinketList = TRINKET_HEALER
	elseif role == PLH_ROLE_TANK then
		trinketList = TRINKET_TANK
	elseif role == PLH_ROLE_UNKNOWN then
		trinketList = TRINKET_UNKNOWN
	end
	return trinketList
end
