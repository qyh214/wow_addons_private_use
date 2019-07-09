-- Locale
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("RareScanner", "frFR", false);

if AL then

	-- CONTINENT names
	AL["ZONES_CONTINENT_LIST"] = {
		[9999] = "Class Halls"; --Class Halls
		[9998] = "Île de Sombrelune"; --Darkmoon Island
		[9997] = "Dungeons/Scenarios"; --Dungeons/Scenarios
		[9996] = "Raids"; --Raids
		[9995] = "Unknown"; --Unknown
	}
end