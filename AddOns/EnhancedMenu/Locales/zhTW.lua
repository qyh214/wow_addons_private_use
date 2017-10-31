if GetLocale() ~= "zhTW" then return end

select( 2, ... ).L = setmetatable({
	ENHANCED_MENU = "增強菜單",
	GUILD_INVITE = "邀請入會",
	COPY_NAME = "複製名字",
	SEND_WHO = "查詢",
	ARMORY_URL = "英雄榜",
	WOW_P = "WoW Progress",
}, { __index = select(2, ... ).L})