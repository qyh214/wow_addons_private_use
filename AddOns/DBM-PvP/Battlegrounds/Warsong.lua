local mod = DBM:NewMod(WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "z489" or "z2106", "DBM-PvP")

mod:SetRevision("20210403135327")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local bgzone = false

	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and (zoneID == 489 or zoneID == 2106) then -- Classic, Retail
			bgzone = true
			DBM:GetModByName("PvPGeneral"):SubscribeFlags()
		elseif bgzone and (zoneID ~= 489 and zoneID ~= 2106) then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
