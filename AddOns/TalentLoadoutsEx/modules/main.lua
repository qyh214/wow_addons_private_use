local addonName, Addon = ...;

function Addon:Init()
	Addon:RegisterAddonLoad("Blizzard_PlayerSpells", false, "InitFrame");
end

Addon:RegisterAddonLoad(addonName, false, "Init");
