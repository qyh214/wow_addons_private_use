local mod = DBM:NewMod(WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "z529" or "z2107", "DBM-PvP")

mod:SetRevision("20210403135327")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local bgzone = false

	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and (zoneID == 529 or zoneID == 1681 or zoneID == 2107 or zoneID == 2177) then -- Classic Arathi, Winter, Remastered Retail, AI
			bgzone = true
			local assaultID
			if zoneID == 529 then
				assaultID = 1461
			elseif zoneID == 1681 then
				assaultID = 837
			elseif zoneID == 2107 then
				assaultID = 93
			elseif zoneID == 2177 then
				assaultID = 1383
			end
			DBM:GetModByName("PvPGeneral"):SubscribeAssault(assaultID, 5)
		elseif bgzone and (zoneID ~= 529 and zoneID ~= 1681 and zoneID ~= 2107 and zoneID ~= 2177) then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
