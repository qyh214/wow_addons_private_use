local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local TT = E:GetModule('Tooltip')

local tiers = { "NYA", "EP", "CoS", "BoD"}
local levels = { 
	"Mythic", 
	"Heroic", 
	"Normal",
	"LFR",
}

local bossesBoD = {
	{ -- Battle of Dazar'alor (BoD) Alliance
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
	{ -- Battle of Dazar'alor (BoD) Horde
		{ -- Mythic
			13331, 13336, 13357, 13362, 13366, 13370, 13374, 13378, 13382,
		},
		{ -- Heroic
			13330, 13334, 13356, 13361, 13365, 13369, 13373, 13377, 13381,
		},
		{ -- Normal
			13329, 13333, 13355, 13358, 13363, 13367, 13371, 13375, 13379,
		},
		{ -- LFR
			13328, 13332, 13354, 13358, 13363, 13367, 13371, 13375, 13379,
		},
	},
}

local bosses = {
	{ -- Nyalotha
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
	{ -- Eternal Palace
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
	{ -- Crucible of Storms
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
}

local playerGUID = UnitGUID("player")
local progressCache = {}
local highest = { 0, 0 }
local englishFaction, localizedFaction = UnitFactionGroup("player")

if (englishFaction == "Alliance") then
	table.insert(bosses, bossesBoD[1])
end

if (englishFaction == "Horde") then
	table.insert(bosses, bossesBoD[2])
end

local function GetProgression(guid)
	local kills, complete, pos = 0, false, 0
	local statFunc = guid == playerGUID and GetStatistic or GetComparisonStatistic

	for tier = 1, #bosses do
		progressCache[guid].header[tier] = {}
		progressCache[guid].info[tier] = {}
		for level = 1, 4 do
			highest = 0
			for statInfo = 1, #bosses[tier][level] do
				kills = tonumber((statFunc(bosses[tier][level][statInfo])))
				if kills and kills > 0 then						
					highest = highest + 1
				end
			end
			pos = highest
			if (highest > 0) then
				progressCache[guid].header[tier][level] = ("%s [%s]:"):format(tiers[tier], levels[level])
				progressCache[guid].info[tier][level] = ("%d/%d"):format(highest, #bosses[tier][level])
				if highest == #bosses[tier][level] then
					break
				end
			end
		end
	end		
end

local function UpdateProgression(guid)
	progressCache[guid] = progressCache[guid] or {}
	progressCache[guid].header = progressCache[guid].header or {}
	progressCache[guid].info =  progressCache[guid].info or {}
	progressCache[guid].timer = GetTime()
	GetProgression(guid)	
end

local function SetProgressionInfo(guid, tt)
	if progressCache[guid] then
		local updated = 0
		for i=1, tt:NumLines() do
			local leftTipText = _G["GameTooltipTextLeft"..i]	
			for tier = 1, #bosses do
				for level = 1, 4 do
					if (leftTipText:GetText() and leftTipText:GetText():find(tiers[tier]) and leftTipText:GetText():find(levels[level])) then
						-- update found tooltip text line
						local rightTipText = _G["GameTooltipTextRight"..i]
						leftTipText:SetText(progressCache[guid].header[tier][level])
						rightTipText:SetText(progressCache[guid].info[tier][level])
						updated = 1
					end
				end
			end
		end
		if updated == 1 then return end
		-- add progression tooltip line
		if highest > 0 then tt:AddLine(" ") end
		for tier = 1, #bosses do
			for level = 1, 4 do
				tt:AddDoubleLine(progressCache[guid].header[tier][level], progressCache[guid].info[tier][level], nil, nil, nil, 1, 1, 1)
			end
		end
	end
end

function TT:INSPECT_ACHIEVEMENT_READY(event, GUID)
	if (self.compareGUID ~= GUID) then return end

	local unit = "mouseover"
	if UnitExists(unit) then
		UpdateProgression(GUID)
		GameTooltip:SetUnit(unit)
	end
	ClearAchievementComparisonUnit()
	self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
end

hooksecurefunc(TT, 'AddInspectInfo', function(self, tt, unit, numTries, r, g, b)
	if InCombatLockdown() then return end
	if not E.db.tooltip.progressInfo then return end
	if not (unit and CanInspect(unit)) then return end
	local level = UnitLevel(unit)
	if not level or level < MAX_PLAYER_LEVEL then return end

	
	local guid = UnitGUID(unit)
	if not progressCache[guid] or (GetTime() - progressCache[guid].timer) > 600 then
		if guid == playerGUID then
			UpdateProgression(guid)
		else
			ClearAchievementComparisonUnit()		
			if not self.loadedComparison and select(2, IsAddOnLoaded("Blizzard_AchievementUI")) then
				AchievementFrame_DisplayComparison(unit)
				HideUIPanel(AchievementFrame)
				ClearAchievementComparisonUnit()
				self.loadedComparison = true
			end
			
			self.compareGUID = guid
			if SetAchievementComparisonUnit(unit) then
				self:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
			end
			return
		end
	end

	SetProgressionInfo(guid, tt)
end)
