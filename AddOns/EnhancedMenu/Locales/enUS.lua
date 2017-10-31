select( 2, ... ).L = setmetatable({
	ENHANCED_MENU = "Enhanced Menu",
	GUILD_INVITE = "Guild Invite",
	COPY_NAME = "Copy Name",
	SEND_WHO = "Who",
	ARMORY_URL = "Armory",
	WOW_P = "WoW Progress",
}, {
	__index = function(self, Key)
		if (Key ~= nil) then
			rawset(self, Key, Key)
			return Key
		end
	end
})