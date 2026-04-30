-- By D4KiR
local _, SpecBisTooltip = ...
SpecBisTooltip:SetAddonOutput("SpecBisTooltip", 136031)
local classIcons = {
	["DEATHKNIGHT"] = 135771,
	["DEMONHUNTER"] = 1260827,
	["DRUID"] = 625999,
	["EVOKER"] = 4574311,
	["HUNTER"] = 626000,
	["MAGE"] = 626001,
	["MONK"] = 626002,
	["PALADIN"] = 626003,
	["PRIEST"] = 626004,
	["ROGUE"] = 626005,
	["SHAMAN"] = 626006,
	["WARLOCK"] = 626007,
	["WARRIOR"] = 626008,
}

function SpecBisTooltip:GetClassIcon(className)
	return classIcons[className]
end
