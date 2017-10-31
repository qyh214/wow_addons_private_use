-- by Sexnonstop
if GetLocale() ~= "ruRU" then return end

select( 2, ... ).L = setmetatable({
	ENHANCED_MENU = "Улучшенное Меню:",
	GUILD_INVITE = "Пригласить в Гильдию",
	COPY_NAME = "Cкопировать никнейм",
	SEND_WHO = "Информация",
	ARMORY_URL = "Ссылка в Оружейной",
	WOW_P = "WoW Progress",
}, { __index = select(2, ... ).L})