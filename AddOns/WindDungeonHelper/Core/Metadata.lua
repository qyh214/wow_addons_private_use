local W, F, L = unpack(select(2, ...))

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

W.MythicPlusMapData = {
	-- https://wago.tools/db2/MapChallengeMode
	-- https://wago.tools/db2/GroupFinderActivityGrp
	[353] = { abbr = L["[ABBR] Siege of Boralus"], activityID = 146, timers = { 1188, 1584, 1980 } },
	[375] = { abbr = L["[ABBR] Mists of Tirna Scithe"], activityID = 262, timers = { 1080, 1440, 1800 } },
	[376] = { abbr = L["[ABBR] The Necrotic Wake"], activityID = 265, timers = { 1116, 1488, 1860 } },
	[501] = { abbr = L["[ABBR] The Stonevault"], activityID = 328, timers = { 1188, 1584, 1980 } },
	[502] = { abbr = L["[ABBR] City of Threads"], activityID = 329, timers = { 1260, 1680, 2100 } },
	[503] = { abbr = L["[ABBR] Ara-Kara, City of Echoes"], activityID = 323, timers = { 1116, 1488, 1860 } },
	[505] = { abbr = L["[ABBR] The Dawnbreaker"], activityID = 326, timers = { 1116, 1488, 1860 } },
	[507] = { abbr = L["[ABBR] Grim Batol"], activityID = 56, timers = { 1224, 1632, 2040 } },
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