local W, F, L = unpack(select(2, ...))

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

W.MythicPlusMapData = {
	-- https://wago.tools/db2/MapChallengeMode
	-- https://wago.tools/db2/GroupFinderActivityGrp
	[378] = { abbr = L["[ABBR] Halls of Atonement"], activityID = 261, timers = { 1152, 1536, 1920 } },
	[391] = { abbr = L["[ABBR] Tazavesh: Streets of Wonder"], activityID = 280, timers = { 1152, 1536, 1920 } },
	[392] = { abbr = L["[ABBR] Tazavesh: So'leah's Gambit"], activityID = 281, timers = { 1080, 1440, 1800 } },
	[499] = { abbr = L["[ABBR] Priory of the Sacred Flame"], activityID = 324, timers = { 1170, 1560, 1950 } },
	[503] = { abbr = L["[ABBR] Ara-Kara, City of Echoes"], activityID = 323, timers = { 1080, 1440, 1800 } },
	[505] = { abbr = L["[ABBR] The Dawnbreaker"], activityID = 326, timers = { 1116, 1488, 1860 } },
	[525] = { abbr = L["[ABBR] Operation: Floodgate"], activityID = 371, timers = { 1188, 1584, 1980 } },
	[542] = { abbr = L["[ABBR] Eco-Dome Al'dani"], activityID = 381, timers = { 1116, 1488, 1860 } },
}

function W:InitializeMetadata()
	for id in pairs(W.MythicPlusMapData) do
		local name, _, timeLimit, tex = C_ChallengeMode_GetMapUIInfo(id)
		W.MythicPlusMapData[id].name = name
		W.MythicPlusMapData[id].tex = tex
		W.MythicPlusMapData[id].idString = tostring(id)
		W.MythicPlusMapData[id].timeLimit = timeLimit
		if W.MythicPlusMapData[id].timers then
			W.MythicPlusMapData[id].timers[#W.MythicPlusMapData[id].timers] = timeLimit
		end
	end
end
