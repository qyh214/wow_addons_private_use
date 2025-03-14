local addonName, Addon = ...;

local prefix = "TalentLoadoutEx";
C_ChatInfo.RegisterAddonMessagePrefix(prefix);

function Addon:SendUpdateMessage()
	local name = UnitName("player");
	local realm = GetNormalizedRealmName();
	if name and realm then
		C_ChatInfo.SendAddonMessage(prefix, "Update", "whisper", name.."-"..realm);
	end
end
