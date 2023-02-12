if WOW_PROJECT_ID ~= (WOW_PROJECT_WRATH_CLASSIC or 11) then -- Added in Wrath, removed in BfA
	return
end
local mod	= DBM:NewMod("z607", "DBM-PvP")

mod:SetRevision("20230128190440")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and zoneID == 607 then
			bgzone = true
			-- TODO
		elseif bgzone and zoneID ~= 607 then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
