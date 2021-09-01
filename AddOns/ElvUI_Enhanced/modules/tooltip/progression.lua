------------------------------------------------------------------
-- This feature was originally created by Darth and Repooc of S&L.
-- Credits: Darth Predator and Repooc.
-- ElvUI Shadow & Light : https://www.tukui.org/addons.php?id=38
-- Later modified by me for this addon
------------------------------------------------------------------

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local PT = E:NewModule("ProgressTooltip", "AceHook-3.0", "AceEvent-3.0")
local TT = E:GetModule('Tooltip')

PT.levels = { 
	"Mythic", 
	"Heroic", 
	"Normal",
	"LFR",
}

PT.tiers = {}
PT.tiers["LONG"] = {
		"Uldir",
		"Battle of Dazar'Alor",
		"Crucible of Storms",
		"The Eternal Palace",
		"Ny'alotha, the Waking City",
		"Castle Nathria",
		"Sanctum of Domination"
}
PT.tiers["SHORT"] = {
		"ULD",
		"BoD",
		"CoS",
		"EP",
		"NYA",
		"CN",
		"SoD"
}

PT.bosses = {
	{ -- Uldir
		["option"] = "uldir",
		["statIDs"] = {
			{ -- Mythic
				12789, 12793, 12797, 12801, 12805, 12811, 12816, 12820,
			},
			{ -- Heroic
				12788, 12792, 12796, 12800, 12804, 12810, 12815, 12819,
			},
			{ -- Normal
				12787, 12791, 12795, 12799, 12803, 12809, 12814, 12818,
			},
			{ -- LFR
				12786, 12790, 12794, 12798, 12802, 12808, 12813, 12817,
			},
		},

	},
	{ -- Battle of Dazar'Alor
		["option"] = "bod",
		["Alliance"] = {
			{ -- Mythic
				13331, 13348, 13353, 13362, 13366, 13370, 13374, 13378, 13382,
			},
			{ -- Heroic
				13330, 13347, 13351, 13361, 13365, 13369, 13373, 13377, 13381,
			},
			{ -- Normal
				13329, 13346, 13350, 13359, 13364, 13368, 13372, 13376, 13380,
			},
			{ -- LFR
				13328, 13344, 13349, 13358, 13363, 13367, 13371, 13375, 13379,
			},
		},
		["Horde"] = {
			{ -- Mythic
				13331, 13336, 13357, 13362, 13366, 13370, 13374, 13378, 13382,
			},
			{ -- Heroic
				13330, 13334, 13356, 13361, 13365, 13369, 13373, 13377, 13381,
			},
			{ -- Normal
				13329, 13333, 13355, 13359, 13364, 13368, 13372, 13376, 13380,
			},
			{ -- LFR
				13328, 13332, 13354, 13358, 13363, 13367, 13371, 13375, 13379,
			},
		},
		true,
	},
	{ -- Crucible of Storms
		["option"] = "cos",
		["statIDs"] = {
			{ -- Mythic
				13407, 13413,
			},
			{ -- Heroic
				13406, 13412,
			},
			{ -- Normal
				13405, 13411,
			},
			{ -- LFR
				13404, 13408,
			},
		},
	},
	{ -- Eternal Palace
		["option"] = "ep",
		["statIDs"] = {
			{ -- Mythic
				13590, 13594, 13598, 13603, 13607, 13611, 13615, 13619,
			},
			{ -- Heroic
				 13589, 13593, 13597, 13602, 13606, 13610, 13614, 13618,
			},
			{ -- Normal
				13588, 13592, 13596, 13601, 13605, 13609, 13613, 13617,
			},
			{ -- LFR
				13587, 13591, 13595, 13600, 13604, 13608, 13612, 13616,
			},
		},
	},
	{ -- Ny'alotha
		["option"] = "nya",
		["statIDs"] = {
			{ -- Mythic
				14082, 14094, 14098, 14105, 14110, 14115, 14120, 14211, 14126, 14130, 14134, 14138,
			},
			{ -- Heroic
				14080, 14093, 14097, 14104, 14109, 14114, 14119, 14210, 14125, 14129, 14133, 14137,
			},
			{ -- Normal
				14079, 14091, 14096, 14102, 14108, 14112, 14118, 14208, 14124, 14128, 14132, 14136,
			},
			{ -- LFR
				14078, 14089, 14095, 14101, 14107, 14111, 14117, 14207, 14123, 14127, 14131, 14135,
			},
		},
	},
	{ -- Castle Nathria
		["option"] = "nathria",
		["statIDs"] = {
			{ -- Mythic
				14421, 14425, 14429, 14433, 14437, 14441, 14445, 14449, 14453, 14457
			},
			{ -- Heroic
				14420, 14424, 14428, 14432, 14436, 14440, 14444, 14448, 14452, 14456
			},
			{ -- Normal
				14419, 14423, 14427, 14431, 14435, 14439, 14443, 14447, 14451, 14455
			},
			{ -- LFR
				14422, 14426, 14430, 14434, 14438, 14442, 14446, 14450, 14454, 14458
			},
		},
	},
	{ -- Sanctum of Domination
		["option"] = "sanctum",
		["statIDs"] = {
			{ -- Mythic
				15139, 15143, 15147, 15151, 15155, 15159, 15163, 15167, 15172, 15176
			},
			{ -- Heroic
				15138, 15142, 15146, 15150, 15154, 15158, 15162, 15166, 15171, 15175
			},
			{ -- Normal
				15137, 15141, 15145, 15149, 15153, 15157, 15161, 15165, 15170, 15174
			},
			{ -- LFR
				15136, 15140, 15144, 15148, 15152, 15156, 15160, 15164, 15169, 15173
			},
		},
	},
}

PT.progressCache = {}
PT.playerGUID = UnitGUID("player")
PT.highest = 0

function PT:GetProgression(guid)
	local kills, complete, pos = 0, false, 0
	local statFunc = guid == playerGUID and GetStatistic or GetComparisonStatistic

	for tier = 1, #PT.tiers["LONG"] do
		local option = PT.bosses[tier].option
		PT.progressCache[guid].header[tier] = {}
		PT.progressCache[guid].info[tier] = {}
		local statTable = PT.bosses[tier][E.myfaction] or PT.bosses[tier].statIDs
		for level = 1, #statTable do
			PT.highest = 0
			for statInfo = 1, #statTable[level] do
				kills = tonumber((statFunc(statTable[level][statInfo])))
				if kills and kills > 0 then						
					PT.highest = PT.highest + 1
				end
			end
			pos = PT.highest
			if (PT.highest > 0) then
				PT.progressCache[guid].header[tier][level] = ("%s [%s]:"):format(PT.tiers[E.db.eel.progression.NameStyle][tier], PT.levels[level])
				PT.progressCache[guid].info[tier][level] = ("%d/%d"):format(PT.highest, #statTable[level])
				if PT.highest == #statTable[level] then
					break
				end
			end
		end
	end		
end

function PT:UpdateProgression(guid)
	PT.progressCache[guid] = PT.progressCache[guid] or {}
	PT.progressCache[guid].header = PT.progressCache[guid].header or {}
	PT.progressCache[guid].info =  PT.progressCache[guid].info or {}
	PT.progressCache[guid].timer = GetTime()

	PT:GetProgression(guid)
end

function PT:SetProgressionInfo(guid, tt)
	if PT.progressCache[guid] and PT.progressCache[guid].header then
		local updated = 0
		for i=1, tt:NumLines() do
			local leftTipText = _G["GameTooltipTextLeft"..i]
			for tier = 1, #PT.tiers["LONG"] do
				for level = 1, 4 do
					if (leftTipText:GetText() and leftTipText:GetText():find(PT.tiers[E.db.eel.progression.NameStyle][tier]) and leftTipText:GetText():find(PT.levels[level]) and (PT.progressCache[guid].header[tier][level] and PT.progressCache[guid].info[tier][level])) then
						-- update found tooltip text line
						local rightTipText = _G["GameTooltipTextRight"..i]
						leftTipText:SetText(PT.progressCache[guid].header[tier][level])
						rightTipText:SetText(PT.progressCache[guid].info[tier][level])
						updated = 1
					end
				end
			end
		end
		if updated == 1 then return end
		-- add progression tooltip line
		if PT.highest > 0 then tt:AddLine(" ") end
		for tier = 1, #PT.tiers["LONG"] do
			local option = PT.bosses[tier].option
			if E.db.eel.progression.raids[option] then
				for level = 1, 4 do
					tt:AddDoubleLine(PT.progressCache[guid].header[tier][level], PT.progressCache[guid].info[tier][level], nil, nil, nil, 1, 1, 1)
				end
			end
		end
	end
end

local function AchieveReady(event, GUID)
	if (TT.compareGUID ~= GUID) then return end
	local unit = "mouseover"
	if UnitExists(unit) then
		PT:UpdateProgression(GUID)
		_G["GameTooltip"]:SetUnit(unit)
	end
	ClearAchievementComparisonUnit()
	TT:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
end

local function OnInspectInfo(self, tt, unit, numTries, r, g, b)
	if InCombatLockdown() then return end
	if not E.db.eel.progression.enable then return end
	if not (unit and CanInspect(unit)) then return end
	local level = UnitLevel(unit)
	if not level or level < MAX_PLAYER_LEVEL then return end
	
	local guid = UnitGUID(unit)
	if not PT.progressCache[guid] or (GetTime() - PT.progressCache[guid].timer) > 600 then
		if guid == PT.playerGUID then
			PT:UpdateProgression(guid)
		else
			ClearAchievementComparisonUnit()
			if not self.loadedComparison and select(2, IsAddOnLoaded("Blizzard_AchievementUI")) then
				AchievementFrame_DisplayComparison(unit)
				HideUIPanel(_G["AchievementFrame"])
				ClearAchievementComparisonUnit()
				self.loadedComparison = true
			end

			self.compareGUID = guid
			if SetAchievementComparisonUnit(unit) then
				self:RegisterEvent("INSPECT_ACHIEVEMENT_READY", AchieveReady)
			end
			return
		end
	end

	PT:SetProgressionInfo(guid, tt)
end

function PT:Initialize()
	hooksecurefunc(TT, 'AddInspectInfo', OnInspectInfo)
end

E:RegisterModule(PT:GetName())
