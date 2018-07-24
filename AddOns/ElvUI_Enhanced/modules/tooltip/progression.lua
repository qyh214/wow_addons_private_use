local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local TT = E:GetModule('Tooltip')

local tiers = { "ToV", "NH", "ToS", "ABT"}
local levels = { 
	"Mythic", 
	"Heroic", 
	"Normal",
	"LFR",
}

local bosses = {
	{ -- Trial of Valor
		{ --Mythic
			11410, 11414, 11418,
		},
		{ -- Herioc
			11409, 11413, 11417,
		},
		{ -- Normal
			11408, 11412, 11416,
		},
		{ -- LFR
			11407, 11411, 11415,
		},
	},
	{ -- Nighthold
		{ --Mythic
			10943, 10947, 10951, 10955, 10960, 10964, 10968, 10972, 10976, 10980,
		},
		{ -- Herioc
			10942, 10946, 10950, 10954, 10959, 10963, 10967, 10971, 10975, 10979,
		},
		{ -- Normal
			10941, 10945, 10949, 10953, 10957, 10962, 10966, 10970, 10974, 10978,
		},
		{ -- LFR
			10940, 10944, 10948, 10952, 10956, 10961, 10965, 10969, 10973, 10977,
		},
	},
	{ -- Tomb of Sargeras
		{ --Mythic
			11880, 11884, 11888, 11892, 11896, 11900, 11904, 11908, 11912,
		},
		{ -- Herioc
			11879, 11883, 11887, 11891, 11895, 11899, 11903, 11907, 11911,
		},
		{ -- Normal
			11878, 11882, 11886, 11890, 11894, 11898, 11902, 11906, 11910,
		},
		{ -- LFR
			11877, 11881, 11885, 11889, 11893, 11897, 11901, 11905, 11909,
		},
	},
	{ -- Antorus, the Burning Throne
		{ --Mythic
			11956, 11959, 11962, 11965, 11968, 11971, 11974, 11977, 11980, 11983, 11986,
		},
		{ -- Herioc
			11955, 11958, 11961, 11964, 11967, 11970, 11973, 11976, 11979, 11982, 11985,
		},
		{ -- Normal
			11954, 11957, 11960, 11963, 11966, 11969, 11972, 11975, 11978, 11981, 11984,
		},
		{ -- LFR
			12117, 12118, 12119, 12120, 12121, 12122, 12123, 12124, 12125, 12126, 12127,
		},
	},
}

local playerGUID = UnitGUID("player")
local progressCache = {}
local highest = { 0, 0 }

local function GetProgression(guid)
	local kills, complete, pos = 0, false, 0
	local statFunc = guid == playerGUID and GetStatistic or GetComparisonStatistic
	
	for tier = 1, 4 do
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
			for tier = 1, 4 do
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
		for tier = 1, 4 do
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
	if not level or level < MAX_PLAYER_LEVEL then return end
	if not (unit and CanInspect(unit)) then return end
	
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
