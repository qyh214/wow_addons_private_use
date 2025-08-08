local addon, ns = ... 

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetInstanceInfo, GetGameTime, GetSubZoneText = GetInstanceInfo, GetGameTime, GetSubZoneText
local SetCVar = C_CVar.SetCVar

local function OnEvent()
	local MapID = C_Map_GetBestMapForUnit("player")
	local hour = GetGameTime()
	local name = GetSubZoneText()
	local instanceID = select(8, GetInstanceInfo())
	local inDepths = (ns.LDActive == true) and ns.ignoreID[instanceID] and ns.subName[name]

	if not MapID then return end
	if inDepths == true then return end

	if ns.zoneLightID[MapID] or ns.insLightID[instanceID] then
		-- set gamma here
		SetCVar("Gamma", 1.2)		-- 0.3~2.8
		SetCVar("Brightness", 50)	-- 1~100
		SetCVar("Contrast", 50)		-- 1~100
	elseif ns.zoneDarkID[MapID] or ns.insDarkID[instanceID] then
		SetCVar("Gamma", .9)
		SetCVar("Brightness", 40)
		SetCVar("Contrast", 50)
	elseif ns.timeID[MapID] then
		if hour and (hour < 6 or hour > 17) then
			SetCVar("Gamma", 1.2)
			SetCVar("Brightness", 50)
			SetCVar("Contrast", 50)
		else
			SetCVar("Gamma", 1)
			SetCVar("Brightness", 50)
			SetCVar("Contrast", 50)
		end
	else
		SetCVar("Gamma", 1)
		SetCVar("Brightness", 50)
		SetCVar("Contrast", 50)
	end

	-- FUCK YOU!
	SetCVar("ffxGlow", 0)
	SetCVar("ffxDeath", 0)
end

local CG = CreateFrame("Frame")
	CG:RegisterEvent("PLAYER_ENTERING_WORLD")
	CG:RegisterEvent("ZONE_CHANGED")
	CG:RegisterEvent("ZONE_CHANGED_INDOORS")
	CG:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	CG:SetScript("OnEvent", function() C_Timer.After(2, OnEvent) end)