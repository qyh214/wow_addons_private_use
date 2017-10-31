if GetLocale() ~= "zhCN" then return end

select( 2, ... ).L = setmetatable({
	ENHANCED_MENU = "增强菜单",
	GUILD_INVITE = "邀请入会",
	COPY_NAME = "复制名字",
	SEND_WHO = "查询",
	ARMORY_URL = "英雄榜",
	WOW_P = "WoW Progress",
}, { __index = select(2, ... ).L})