if DBM:GetTOC() < 20000 then
	return
end
local mod	= DBM:NewMod("z566", "DBM-PvP")

mod:SetRevision("20210403135327")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local bgzone = false
	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and (zoneID == 566 or zoneID == 968) then
			bgzone = true
			local modz = DBM:GetModByName("PvPGeneral")
			modz:SubscribeAssault(DBM:GetCurrentArea() == 566 and 112 or 397, 4)
			modz:SubscribeFlags()
		elseif bgzone and (zoneID ~= 566 and zoneID ~= 968) then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
