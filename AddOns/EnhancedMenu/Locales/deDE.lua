-- by pas06
if GetLocale() ~= "deDE" then return end

select( 2, ... ).L = setmetatable({
	ENHANCED_MENU = "Enhanced Menu",
	GUILD_INVITE = "Gildeneinladung",
	COPY_NAME = "Namen kopieren",
	SEND_WHO = "Wer",
	ARMORY_URL = "Armory",
	WOW_P = "WoW Progress",
}, { __index = select(2, ... ).L})