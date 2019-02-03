local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local TT = E:GetModule('Tooltip')

local tiers = { "Uldir", "BoD (A)", "BoD (H)", "CoS" }
local levels = { 
	"Mythic", 
	"Heroic", 
	"Normal",
	"LFR",
}

local bosses = {
	{ -- Uldir
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
	{ -- Battle of Dazar'alor (BoD) Alliance
		{ -- Mythic
			13331, 13348, 13353, 13362, 13366, 13370,
		},
		{ -- Heroic
			13330, 13347, 13351, 13361, 13365, 13369,
		},
		{ -- Normal
			13329, 13346, 13350, 13359, 13364, 13368,
		},
		{ -- LFR
			13328, 13344, 13349, 13358, 13363, 13367,
		},
	},
	{ -- Battle of Dazar'alor (BoD) Horde
		{ -- Mythic
			13331, 13336, 13357, 13374, 13378, 13382,
		},
		{ -- Heroic
			13330, 13334, 13356, 13373, 13377, 13381,
		},
		{ -- Normal
			13329, 13333, 13355, 13372, 13376, 13380,
		},
		{ -- LFR
			13328, 13332, 13354, 13371, 13375, 13379,
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

hooksecurefunc(TT, 'ShowInspectInfo', function(self, tt, unit, level, r, g, b, numTries)
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
