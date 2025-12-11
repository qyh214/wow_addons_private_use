local W, F, L = unpack(select(2, ...))

local pairs = pairs
local tostring = tostring

local PlayerIsTimerunning = PlayerIsTimerunning

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

-- Mythic+
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

-- Legion Remix dungeons
W.TimerunningMythicPlusMapData = {
	[197] = { abbr = L["[ABBR] Eye of Azshara"], activityID = 112, timers = { 1260, 1680, 2100 } },
	[198] = { abbr = L["[ABBR] Darkheart Thicket"], activityID = 113, timers = { 1080, 1440, 1800 } },
	[199] = { abbr = L["[ABBR] Black Rook Hold"], activityID = 118, timers = { 1296, 1728, 2160 } },
	[200] = { abbr = L["[ABBR] Halls of Valor"], activityID = 114, timers = { 1368, 1824, 2280 } },
	[206] = { abbr = L["[ABBR] Neltharion's Lair"], activityID = 115, timers = { 1188, 1584, 1980 } },
	[207] = { abbr = L["[ABBR] Vault of the Wardens"], activityID = 117, timers = { 1188, 1584, 1980 } },
	[208] = { abbr = L["[ABBR] Maw of Souls"], activityID = 119, timers = { 864, 1152, 1440 } },
	[209] = { abbr = L["[ABBR] The Arcway"], activityID = 121, timers = { 1620, 2160, 2700 } },
	[210] = { abbr = L["[ABBR] Court of Stars"], activityID = 120, timers = { 1080, 1440, 1800 } },
	[227] = { abbr = L["[ABBR] Return to Karazhan: Lower"], activityID = 127, timers = { 1512, 2016, 2520 } },
	[234] = { abbr = L["[ABBR] Return to Karazhan: Upper"], activityID = 128, timers = { 1260, 1680, 2100 } },
	[233] = { abbr = L["[ABBR] Cathedral of Eternal Night"], activityID = 129, timers = { 1260, 1680, 2100 } },
	[239] = { abbr = L["[ABBR] Seat of the Triumvirate"], activityID = 133, timers = { 1260, 1680, 2100 } },
}

function W:GetMythicPlusMapData()
	return PlayerIsTimerunning() and W.TimerunningMythicPlusMapData or W.MythicPlusMapData
end

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

	for id in pairs(W.TimerunningMythicPlusMapData) do
		local name, _, timeLimit, tex = C_ChallengeMode_GetMapUIInfo(id)
		W.TimerunningMythicPlusMapData[id].name = name
		W.TimerunningMythicPlusMapData[id].tex = tex
		W.TimerunningMythicPlusMapData[id].idString = tostring(id)
		W.TimerunningMythicPlusMapData[id].timeLimit = timeLimit
		if W.TimerunningMythicPlusMapData[id].timers then
			W.TimerunningMythicPlusMapData[id].timers[#W.TimerunningMythicPlusMapData[id].timers] = timeLimit
		end
	end
end
