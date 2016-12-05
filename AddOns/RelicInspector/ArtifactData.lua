-- ArtifactData.lua

local _, addon = ...; 

addon.RelicTypes = {
	["Blood"] = RELIC_SLOT_TYPE_BLOOD,
	["Shadow"] = RELIC_SLOT_TYPE_SHADOW,
	["Iron"] = RELIC_SLOT_TYPE_IRON,
	["Frost"] = RELIC_SLOT_TYPE_FROST,
	["Fire"] = RELIC_SLOT_TYPE_FIRE,
	["Fel"] = RELIC_SLOT_TYPE_FEL,
	["Arcane"] = RELIC_SLOT_TYPE_ARCANE,
	["Life"] = RELIC_SLOT_TYPE_LIFE,
	["Wind"] = RELIC_SLOT_TYPE_WIND,
	["Holy"] = RELIC_SLOT_TYPE_HOLY,
}

addon.RelicSlots = {
	[127829] = {"Fel","Shadow","Fel"}, -- Havoc DH
	[128832] = {"Iron","Arcane","Fel"}, -- Vengeance DH

	[128402] = {"Blood","Shadow","Iron"}, -- Blood DK
	[128292] = {"Frost","Shadow","Frost"}, -- Frost DK
	[128403] = {"Fire","Shadow","Blood"}, -- Unholy DK

	[128858] = {"Arcane","Life","Arcane"}, -- Balance Druid
	[128860] = {"Frost","Blood","Life"}, -- Feral Druid
	[128821] = {"Fire","Blood","Life"}, -- Guardian Druid
	[128306] = {"Life","Frost","Life"}, -- Restoration Druid

	[128861] = {"Wind","Arcane","Iron"}, -- Beast Mastery Hunter
	[128826] = {"Wind","Blood","Life"}, -- Marksmanship Hunter
	[128808] = {"Wind","Iron","Blood"}, -- Survival Hunter

	[127857] = {"Arcane","Frost","Arcane"}, -- Arcane Mage
	[128820] = {"Fire","Arcane","Fire"}, -- Fire Mage
	[128862] = {"Frost","Arcane","Frost"}, -- Frost Mage

	[128938] = {"Life","Wind","Iron"}, -- Brewmaster Monk
	[128937] = {"Frost","Life","Wind"}, -- Mistweaver Monk
	[128940] = {"Wind","Iron","Wind"}, -- Windwalker Monk

	[128823] = {"Holy","Life","Holy"}, -- Holy Paladin
	[128866] = {"Holy","Iron","Arcane"}, -- Protection Paladin
	[120978] = {"Holy","Fire","Holy"}, -- Retribution Paladin

	[128868] = {"Holy","Shadow","Holy"}, -- Discipline Priest
	[128825] = {"Holy","Life","Holy"}, -- Holy Priest
	[128827] = {"Shadow","Blood","Shadow"}, -- Shadow Priest

	[128870] = {"Shadow","Iron","Blood"}, -- Assassination Rogue
	[128872] = {"Blood","Iron","Wind"}, -- Outlaw Rogue
	[128476] = {"Fel","Shadow","Fel"}, -- Subtlety Rogue

	[128935] = {"Wind","Frost","Wind"}, -- Elemental Shaman
	[128819] = {"Fire","Iron","Wind"}, -- Enhancement Shaman
	[128911] = {"Life","Frost","Life"}, -- Restoration Shaman

	[128942] = {"Shadow","Blood","Shadow"}, -- Affliction Warlock
	[128943] = {"Shadow","Fire","Fel"}, -- Demonology Warlock
	[128941] = {"Fel","Fire","Fel"}, -- Destruction Warlock

	[128910] = {"Iron","Blood","Shadow"}, -- Arms Warrior
	[128908] = {"Fire","Wind","Iron"}, -- Fury Warrior
	[128289] = {"Iron","Blood","Fire"}, -- Protection Warrior
}

addon.Artifacts = {
	[127829] = 577, -- Havoc DH
	[128832] = 581, -- Vengeance DH

	[128402] = 250, -- Blood DK
	[128292] = 251, -- Frost DK
	[128403] = 252, -- Unholy DK

	[128858] = 102, -- Balance Druid
	[128860] = 103, -- Feral Druid
	[128821] = 104, -- Guardian Druid
	[128306] = 105, -- Restoration Druid

	[128861] = 253, -- Beast Mastery Hunter
	[128826] = 254, -- Marksmanship Hunter
	[128808] = 255, -- Survival Hunter

	[127857] = 62, -- Arcane Mage
	[128820] = 63, -- Fire Mage
	[128862] = 64, -- Frost Mage

	[128938] = 268, -- Brewmaster Monk
	[128937] = 270, -- Mistweaver Monk
	[128940] = 269, -- Windwalker Monk

	[128823] = 65, -- Holy Paladin
	[128866] = 66, -- Protection Paladin
	[120978] = 70, -- Retribution Paladin

	[128868] = 256, -- Discipline Priest
	[128825] = 257, -- Holy Priest
	[128827] = 258, -- Shadow Priest

	[128870] = 259, -- Assassination Rogue
	[128872] = 260, -- Outlaw Rogue
	[128476] = 261, -- Subtlety Rogue

	[128935] = 262, -- Elemental Shaman
	[128819] = 263, -- Enhancement Shaman
	[128911] = 264, -- Restoration Shaman

	[128942] = 265, -- Affliction Warlock
	[128943] = 266, -- Demonology Warlock
	[128941] = 267, -- Destruction Warlock

	[128910] = 71, -- Arms Warrior
	[128908] = 72, -- Fury Warrior
	[128289] = 73, -- Protection Warrior	
}
