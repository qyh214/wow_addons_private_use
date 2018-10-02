local pairs, ipairs, tonumber, match, tinsert, tremove
    = pairs, ipairs, tonumber, match, tinsert, tremove

local GetSavedInstanceInfo, GetNumSavedInstances, GetSavedInstanceEncounterInfo, GetSavedInstanceChatLink, UnitFactionGroup, RequestRaidInfo,                         GetState,             GetQuestTimeLeftMinutes, IsQuestFlaggedCompleted, EJ_GetInstanceInfo, EJ_GetEncounterInfo
    = GetSavedInstanceInfo, GetNumSavedInstances, GetSavedInstanceEncounterInfo, GetSavedInstanceChatLink, UnitFactionGroup, RequestRaidInfo, C_ContributionCollector.GetState, C_TaskQuest.GetQuestTimeLeftMinutes, IsQuestFlaggedCompleted, EJ_GetInstanceInfo, EJ_GetEncounterInfo

local BOSS_DEAD, BOSS_ALIVE,       BOSS_UNAVAILABLE,           WORLD_BOSS, RED_FONT,       GREEN_FONT,           WHITE_FONT,       GRAY_FONT
    = BOSS_DEAD, BOSS_ALIVE, QUEUE_TIME_UNAVAILABLE, RAID_INFO_WORLD_BOSS, RED_FONT_COLOR, GREEN_FONT_COLOR, HIGHLIGHT_FONT_COLOR, GRAY_FONT_COLOR

local locale = GetLocale()

local L = {"August Celestials"}

if locale == "deDE" then
	L[1] = "Die Himmlischen Erhabenen"
elseif locale == "frFR" then
	L[1] = "Astres vénérables"
elseif locale == "itIT" then
	L[1] = "Venerabili Celestiali"
elseif locale == "zhCN" then
	L[1] = "至尊天神"
elseif locale == "zhTW" then
	L[1] = "天尊之廷"
end

local instancesData = {
	[409] = 741,	-- Molten Core
	[469] = 742,	-- Blackwing Lair
	[509] = 743,	-- Ruins of Ahn'Qiraj
	[531] = 744,	-- Temple of Ahn'Qiraj
	[558] = 247,	-- Auchenai Crypts
	[543] = 248,	-- Hellfire Ramparts
	[585] = 249,	-- Magisters' Terrace
	[557] = 250,	-- Mana-Tombs
	[560] = 251,	-- Old Hillsbrad Foothills
	[556] = 252,	-- Sethekk Halls
	[555] = 253,	-- Shadow Labyrinth
	[552] = 254,	-- The Arcatraz
	[269] = 255,	-- The Black Morass
	[542] = 256,	-- The Blood Furnace
	[553] = 257,	-- The Botanica
	[554] = 258,	-- The Mechanar
	[540] = 259,	-- The Shattered Halls
	[547] = 260,	-- The Slave Pens
	[545] = 261,	-- The Steamvault
	[546] = 262,	-- The Underbog
	[532] = 745,	-- Karazhan
	[565] = 746,	-- Gruul's Lair
	[544] = 747,	-- Magtheridon's Lair
	[548] = 748,	-- Serpentshrine Cavern
	[550] = 749,	-- The Eye
	[534] = 750,	-- The Battle for Mount Hyjal
	[564] = 751,	-- Black Temple
	[580] = 752,	-- Sunwell Plateau
	[619] = 271,	-- Ahn'kahet: The Old Kingdom
	[601] = 272,	-- Azjol-Nerub
	[600] = 273,	-- Drak'Tharon Keep
	[604] = 274,	-- Gundrak
	[602] = 275,	-- Halls of Lightning
	[668] = 276,	-- Halls of Reflection
	[599] = 277,	-- Halls of Stone
	[658] = 278,	-- Pit of Saron
	[595] = 279,	-- The Culling of Stratholme
	[632] = 280,	-- The Forge of Souls
	[576] = 281,	-- The Nexus
	[578] = 282,	-- The Oculus
	[608] = 283,	-- The Violet Hold
	[650] = 284,	-- Trial of the Champion
	[574] = 285,	-- Utgarde Keep
	[575] = 286,	-- Utgarde Pinnacle
	[624] = 753,	-- Vault of Archavon
	[533] = 754,	-- Naxxramas
	[615] = 755,	-- The Obsidian Sanctum
	[616] = 756,	-- The Eye of Eternity
	[603] = 759,	-- Ulduar
	[649] = 757,	-- Trial of the Crusader
	[249] = 760,	-- Onyxia's Lair
	[631] = 758,	-- Icecrown Citadel
	[724] = 761,	-- The Ruby Sanctum		
	[645] = 66,  	-- Blackrock Caverns
	[36] = 63,  	-- Deadmines
	[938] = 184,	-- End Time
	[670] = 71,  	-- Grim Batol
	[644] = 70,  	-- Halls of Origination
	[940] = 186,	-- Hour of Twilight
	[755] = 69,  	-- Lost City of the Tol'vir
	[33] = 64,  	-- Shadowfang Keep
	[752] = 67,  	-- The Stonecore
	[657] = 68,  	-- The Vortex Pinnacle
	[643] = 65,  	-- Throne of the Tides
	[939] = 185,	-- Well of Eternity
	[568] = 77,  	-- Zul'Aman
	[859] = 76,  	-- Zul'Gurub
	[757] = 75,  	-- Baradin Hold
	[669] = 73,  	-- Blackwing Descent
	[671] = 72,  	-- The Bastion of Twilight
	[754] = 74,  	-- Throne of the Four Winds
	[720] = 78,  	-- Firelands
	[967] = 187,	-- Dragon Soul
	[962] = 303,	-- Gate of the Setting Sun
	[994] = 321,	-- Mogu'shan Palace
	[1001] = 311,	-- Scarlet Halls
	[1004] = 316,	-- Scarlet Monastery
	[1007] = 246,	-- Scholomance
	[959] = 312,	-- Shado-Pan Monastery
	[1011] = 324,	-- Siege of Niuzao Temple
	[961] = 302,	-- Stormstout Brewery
	[960] = 313,	-- Temple of the Jade Serpent
	[1008] = 317,	-- Mogu'shan Vaults
	[1009] = 330,	-- Heart of Fear
	[996] = 320,	-- Terrace of Endless Spring
	[1098] = 362,	-- Throne of Thunder
	[1136] = 369,	-- Siege of Orgrimmar		
	[1182] = 547,	-- Auchindoun
	[1175] = 385,	-- Bloodmaul Slag Mines
	[1208] = 536,	-- Grimrail Depot
	[1195] = 558,	-- Iron Docks
	[1176] = 537,	-- Shadowmoon Burial Grounds
	[1209] = 476,	-- Skyreach
	[1279] = 556,	-- The Everbloom
	[1358] = 559,	-- Upper Blackrock Spire
	[1228] = 477,	-- Highmaul
	[1205] = 457,	-- Blackrock Foundry
	[1448] = 669,	-- Hellfire Citadel
	[1544] = 777,	-- Assault on Violet Hold
	[1501] = 740,	-- Black Rook Hold
	[1677] = 900,	-- Cathedral of Eternal Night
	[1571] = 800,	-- Court of Stars
	[1466] = 762,	-- Darkheart Thicket
	[1456] = 716,	-- Eye of Azshara
	[1477] = 721,	-- Halls of Valor
	[1492] = 727,	-- Maw of Souls
	[1458] = 767,	-- Neltharion's Lair
	[1651] = 860,	-- Return to Karazhan
	[1753] = 945,	-- Seat of the Triumvirate
	[1516] = 726,	-- The Arcway
	[1493] = 707,	-- Vault of the Wardens
	[1520] = 768,	-- The Emerald Nightmare
	[1648] = 861,	-- Trial of Valor
	[1530] = 786,	-- The Nighthold
	[1676] = 875,	-- Tomb of Sargeras
	[1712] = 946,	-- Antorus, the Burning Throne
	[1763] = 968,	-- Atal'Dazar
	[1754] = 1001,	-- Freehold
	[1762] = 1041,	-- Kings' Rest
	[1864] = 1036,	-- Shrine of the Storm
	[1822] = 1023,	-- Siege of Boralus
	[1877] = 1030,	-- Temple of Sethraliss
	[1594] = 1012,	-- The MOTHERLODE!!
	[1841] = 1022,	-- The Underrot
	[1771] = 1002,	-- Tol Dagor
	[1862] = 1021,	-- Waycrest Manor
	[1861] = 1031	-- Uldir
}

local worldBossesData = {
	[322] = {
		instanceName = EJ_GetInstanceInfo(322),
		maxBosses = 6,
		bosses = {
			{encounter = 691, quest = 32099},	-- Sha of Anger
			{encounter = 725, quest = 32098},	-- Salyis's Warband
			{encounter = 814, quest = 32518},	-- Nalak, The Storm Lord
			{encounter = 826, quest = 32519},	-- Oondasta
			{name = L[1], quest = 33117},  		-- August Celestials
			{encounter = 861, quest = 33118}	-- Ordos, Fire-God of the Yaungol
		}
	},
	[557] = {
		instanceName = EJ_GetInstanceInfo(557),
		maxBosses = 3,
		bosses = {
			{encounter = 1291, quest = 37460},	-- Drov the Ruiner
			{encounter = 1211, quest = 37462},	-- Tarlna the Ageless
			{encounter = 1262, quest = 37464},	-- Rukhmar
			{encounter = 1452, quest = 39380}	-- Supreme Lord Kazzak
		}
	},
	[822] = {
		instanceName = EJ_GetInstanceInfo(822),
		maxBosses = 1,
		bosses = {
			{encounter = 1790, quest = 43512},	-- Ana-Mouz
			{encounter = 1956, quest = 47061},	-- Apocron
			{encounter = 1883, quest = 46947},	-- Brutallus
			{encounter = 1774, quest = 43193},	-- Calamir
			{encounter = 1789, quest = 43448},	-- Drugon the Frostblood
			{encounter = 1795, quest = 43985},	-- Flotsam
			{encounter = 1770, quest = 42819},	-- Humongris
			{encounter = 1769, quest = 43192},	-- Levantus
			{encounter = 1884, quest = 46948},	-- Malificus
			{encounter = 1783, quest = 43513},	-- Na'zak the Fiend
			{encounter = 1749, quest = 42270},	-- Nithogg
			{encounter = 1763, quest = 42779},	-- Shar'thos
			{encounter = 1885, quest = 46945},	-- Si'vash
			{encounter = 1756, quest = 42269},	-- The Soultakers
			{encounter = 1796, quest = 44287}	-- Withered Jim
		}
	},
	[959] = {
		instanceName = EJ_GetInstanceInfo(959),
		maxBosses = 1,
		bosses = {
			{encounter = 2010, quest = 49199},	-- Matron Folnuna
			{encounter = 2011, quest = 48620},	-- Mistress Alluradel
			{encounter = 2012, quest = 49198},	-- Inquisitor Meto
			{encounter = 2013, quest = 49195},	-- Occularus
			{encounter = 2014, quest = 49197},	-- Sotanathor
			{encounter = 2015, quest = 49196}	-- Pit Lord Vilemus
		}
	},
	[1028] = {
		instanceName = EJ_GetInstanceInfo(1028),
		maxBosses = 1,
		bosses = {
			{encounter = 2139, quest = 52181},	-- T'zane
			{encounter = 2141, quest = 52169},	-- Ji'arak
			{encounter = 2197, quest = 52157},	-- Hailstone Construct
			{encounter = 0, quest = 0},  		-- The Lion's Roar/Doom's Howl
			{encounter = 2199, quest = 52163},	-- Azurethos, The Winged Typhoon
			{encounter = 2198, quest = 52166},	-- Warbringer Yenajz
			{encounter = 2210, quest = 52196}	-- Dunegorger Kraulok
		}
	}
}

local eventFrame = CreateFrame("Frame", "EncounterJournalSavedInstances_EventFrame", UIParent)
eventFrame:Show()

local startTime = -1
local savedInstances = {}
local statusFrames = {}

local function UpdateSavedInstances()
	savedInstances = {}

	RequestRaidInfo()

	for i = 1, GetNumSavedInstances() do
		local instanceName, _, reset, instanceDifficulty, _, _, _, _, _, difficultyName, maxBosses, defeatedBosses = GetSavedInstanceInfo(i)
		local instanceLink = GetSavedInstanceChatLink(i) or ""
		local instanceID = tonumber(instanceLink:match(":(%d+)"))

		instanceID = instancesData[instanceID]

		if instanceID == 777 then
			maxBosses = 3
		elseif instanceID == 1023 then
			maxBosses = 4
		end

		local difficulty = "normal"

		if instanceDifficulty == 7 or instanceDifficulty == 17 then
			difficulty = "lfr"
		elseif instanceDifficulty == 2 or instanceDifficulty == 5 or instanceDifficulty == 6 or instanceDifficulty == 15 then
			difficulty = "heroic"
		elseif instanceDifficulty == 16 or instanceDifficulty == 23 then
			difficulty = "mythic"
		end

		local bosses = {}
		local b = 1
		local encounters = {2168, 2167, 2169, 2146, 2166, 2195, 2194, 2147}
		while GetSavedInstanceEncounterInfo(i, b) do
			local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, b)
			if instanceID == 1031 then
				local encounterID = tremove(encounters, 1)
				bossName = EJ_GetEncounterInfo(encounterID)
			end
			tinsert(bosses, {
				name = bossName,
				isKilled = isKilled
			})
			b = b + 1
		end

		if reset > 0 and defeatedBosses > 0 then
			savedInstances[instanceID] = savedInstances[instanceID] or {}
			tinsert(savedInstances[instanceID], {
				bosses = bosses,
				instanceName = instanceName,
				instanceDifficulty = instanceDifficulty,
				difficulty = difficulty,
				difficultyName = difficultyName,
				maxBosses = maxBosses,
				defeatedBosses = defeatedBosses,
				progress = defeatedBosses.."/"..maxBosses,
				complete = defeatedBosses == maxBosses
			})
		end
	end

	local isBossAvailable = false
	local state = GetState(11)
	if UnitFactionGroup("player") == "Horde" then
		worldBossesData[1028].bosses[4].encounter = 2212
		worldBossesData[1028].bosses[4].quest = 52848

		if state == 3 or state == 4 then
			isBossAvailable = true
			worldBossesData[1028].maxBosses = 2
		end
	else
		worldBossesData[1028].bosses[4].encounter = 2213    
		worldBossesData[1028].bosses[4].quest = 52847

		if state == 1 or state == 2 then
			isBossAvailable = true
			worldBossesData[1028].maxBosses = 2
		end
	end
	
	local worldBosses = {}
	for instanceID, data in pairs(worldBossesData) do
		worldBosses[instanceID] = worldBosses[instanceID] or {}
		for i, boss in ipairs(data.bosses) do
			if IsQuestFlaggedCompleted(boss.quest) then
				savedInstances[instanceID] = savedInstances[instanceID] or {}
			end
			if not boss.name then
				boss.name = EJ_GetEncounterInfo(boss.encounter)
			end
			tinsert(worldBosses[instanceID], {
				name = boss.name,
				isKilled = IsQuestFlaggedCompleted(boss.quest)
			})
			if instanceID == 1028 then
				if i == 4 then
					worldBosses[1028][i].isAvailable = isBossAvailable
					worldBosses[1028][i].isKilled = worldBosses[1028][i].isKilled and isBossAvailable
				else
					worldBosses[1028][i].isAvailable = GetQuestTimeLeftMinutes(boss.quest) > 0
				end
			end
		end
	end

	for instanceID, worldBoss in pairs(worldBosses) do
		local defeatedBosses = 0
		local maxBosses = worldBossesData[instanceID].maxBosses

		for _, boss in ipairs(worldBoss) do
			if boss.isKilled then
				defeatedBosses = defeatedBosses + 1
			end
		end
		
		if savedInstances[instanceID] then
			if defeatedBosses > 0 then
				tinsert(savedInstances[instanceID], {
					bosses = worldBosses[instanceID],
					instanceName = worldBossesData[instanceID].instanceName,
					difficulty = "normal",
					difficultyName = WORLD_BOSS,
					maxBosses = maxBosses,
					defeatedBosses = defeatedBosses,
					progress = defeatedBosses.."/"..maxBosses,
					complete = defeatedBosses == maxBosses
				})
			end
		end
	end
end

local function UpdateStatusFramePosition(instanceButton)
	local savedFrames = statusFrames[instanceButton:GetName()]
	local lfrVisible = savedFrames and savedFrames["lfr"] and savedFrames["lfr"]:IsShown()
	local normalVisible = savedFrames and savedFrames["normal"] and savedFrames["normal"]:IsShown()
	local heroicVisible = savedFrames and savedFrames["heroic"] and savedFrames["heroic"]:IsShown()
	local mythicVisible = savedFrames and savedFrames["mythic"] and savedFrames["mythic"]:IsShown()

	if mythicVisible then
		savedFrames["mythic"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -12)
	end

	if heroicVisible then
		if mythicVisible then
			savedFrames["heroic"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -12)
		else
			savedFrames["heroic"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -12)
		end
	end

	if normalVisible then
		if heroicVisible and mythicVisible then
			savedFrames["normal"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -60, -23)
		elseif heroicVisible or mythicVisible then
			savedFrames["normal"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -23)
		else
			savedFrames["normal"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -23)
		end
	end

	if lfrVisible then
		if normalVisible and heroicVisible and mythicVisible then
			savedFrames["lfr"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -92, -23)
		elseif heroicVisible and mythicVisible or heroicVisible and normalVisible or mythicVisible and normalVisible then
			savedFrames["lfr"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -60, -23)
		elseif normalVisible or heroicVisible or mythicVisible then
			savedFrames["lfr"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", -28, -23)
		else
			savedFrames["lfr"]:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 4, -23)
		end
	end
end

local function ShowTooltip(frame)
	local info = frame.instanceInfo
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	if info.defeatedBosses > 0 then
		GameTooltip:SetText(info.instanceName.." ("..info.difficultyName..")")
		for i, boss in ipairs(info.bosses) do
			if boss.isKilled then
				GameTooltip:AddDoubleLine(boss.name, BOSS_DEAD, WHITE_FONT.r, WHITE_FONT.g, WHITE_FONT.b, RED_FONT.r, RED_FONT.g, RED_FONT.b)
			elseif boss.isAvailable ~= nil and not boss.isAvailable then
				GameTooltip:AddDoubleLine(boss.name, BOSS_UNAVAILABLE, WHITE_FONT.r, WHITE_FONT.g, WHITE_FONT.b, GRAY_FONT.r, GRAY_FONT.g, GRAY_FONT.b)
			else
				GameTooltip:AddDoubleLine(boss.name, BOSS_ALIVE, WHITE_FONT.r, WHITE_FONT.g, WHITE_FONT.b, GREEN_FONT.r, GREEN_FONT.g, GREEN_FONT.b)
			end
		end
	end
	GameTooltip:Show()
end

local function hideTooltip(frame)
	GameTooltip:Hide()
end

local function CreateStatusFrame(instanceButton, difficulty)
	local statusFrame = CreateFrame("Frame", nil, instanceButton)
	statusFrame:Hide()

	statusFrame:SetScript("OnEnter", ShowTooltip)
	statusFrame:SetScript("OnLeave", hideTooltip)

	-- skull flag
	statusFrame.texture = statusFrame:CreateTexture(nil, "ARTWORK")
	statusFrame.texture:SetPoint("TOPLEFT")
	statusFrame:SetSize(38, 46)
	statusFrame.texture:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
	statusFrame.texture:SetSize(38, 46)

	statusFrame:SetPoint("BOTTOMRIGHT", instanceButton, "BOTTOMRIGHT", 17, -12)

	if difficulty == "mythic" then
		statusFrame.texture:SetTexCoord(0.30, 0.45, 0.0703125, 0.4296875)
	elseif difficulty == "heroic" then
		statusFrame.texture:SetTexCoord(0.05, 0.20, 0.0703125, 0.4296875)
	else
		statusFrame.texture:SetTexCoord(0.05, 0.20, 0.5703125, 0.9296875)
	end

	-- green check mark
	local completeFrame = CreateFrame("Frame", nil, statusFrame)
	completeFrame:Hide()

	completeFrame.texture = completeFrame:CreateTexture(nil, "ARTWORK", "GreenCheckMarkTemplate")
	completeFrame:SetSize(16, 16)

	if difficulty == "lfr" or difficulty == "normal" then
		completeFrame:SetPoint("BOTTOM", statusFrame, "BOTTOM", 0, 14)
	else
		completeFrame:SetPoint("BOTTOM", statusFrame, "BOTTOM", 0, 3)
	end

	completeFrame.texture:ClearAllPoints()
	completeFrame.texture:SetPoint("TOPLEFT")
	completeFrame.texture:Show()

	-- progress
	local progressFrame = statusFrame:CreateFontString(nil, nil, "GameFontNormalLeft")
	progressFrame:Hide()
	progressFrame:SetFont("Fonts\\ARIALN.TTF", 13)
	if difficulty == "lfr" or difficulty == "normal" then
		progressFrame:SetPoint("BOTTOM", statusFrame, "BOTTOM", 0, 19)
	else
		progressFrame:SetPoint("BOTTOM", statusFrame, "BOTTOM", 0, 8)
	end
	progressFrame:SetTextColor(1, 1, 1)

	statusFrame.completeFrame = completeFrame
	statusFrame.progressFrame = progressFrame

	if statusFrames[instanceButton:GetName()] == nil then
		statusFrames[instanceButton:GetName()] = {}
	end
	statusFrames[instanceButton:GetName()][difficulty] = statusFrame

	return statusFrame
end

local function UpdateInstanceStatusFrame(instanceButton)
	if statusFrames[instanceButton:GetName()] then
		for difficulty, frame in pairs(statusFrames[instanceButton:GetName()]) do
			frame:Hide()
		end
	end

	local instances = savedInstances[instanceButton.instanceID]
	if instances == nil then
		return
	end

	for key, instance in ipairs(instances) do
		local frame = (statusFrames[instanceButton:GetName()] and statusFrames[instanceButton:GetName()][instance.difficulty]) or CreateStatusFrame(instanceButton, instance.difficulty)
		if instance.complete then
			frame.completeFrame:Show()
			frame.progressFrame:Hide()
			frame:Show()
		elseif instance.progress then
			frame.completeFrame:Hide()
			frame.progressFrame:SetText(instance.progress)
			frame.progressFrame:Show()
			frame:Show()
		else
			frame:Hide()
		end

		frame.instanceInfo = instance
	end
	UpdateStatusFramePosition(instanceButton)
end

-------------------

eventFrame:RegisterEvent("PLAYER_LOGIN")
local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" then
		startTime = GetTime()
	end
end
eventFrame:SetScript("OnEvent", OnEvent)

local function OnUpdate(self, elapsed)
	if startTime >= 0 and GetTime() - startTime > 2 and IsAddOnLoaded("Blizzard_EncounterJournal") then
		eventFrame:SetScript("OnUpdate", nil)
		startTime = nil

		local function UpdateFrames()
			UpdateSavedInstances()
			local b1 = _G["EncounterJournalInstanceSelectScrollFrameScrollChildInstanceButton1"]
			if b1 then
				UpdateInstanceStatusFrame(b1)
			end
			for i = 1, 100 do
				local b = _G["EncounterJournalInstanceSelectScrollFrameinstance"..i]
				if b then
					UpdateInstanceStatusFrame(b)
				end
			end
		end
		hooksecurefunc("EncounterJournal_ListInstances", UpdateFrames)
		UpdateFrames()
	end
end
eventFrame:SetScript("OnUpdate", OnUpdate)
