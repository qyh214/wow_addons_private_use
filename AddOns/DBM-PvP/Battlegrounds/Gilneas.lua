if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z761", "DBM-PvP")

mod:SetRevision("20210403135327")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local bgzone = false

	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and zoneID == 761 then
			bgzone = true
			DBM:GetModByName("PvPGeneral"):SubscribeAssault(275, 3)
		elseif bgzone and zoneID ~= 761 then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
