local locale = GetLocale()

local L = {
	["Ahn'Qiraj Temple"] = "Ahn\'Qiraj Temple",
	["Assault on Violet Hold"] = "Assault on Violet Hold",
	["Auchindoun: Auchenai Crypts"] = "Auchindoun: Auchenai Crypts",
	["Auchindoun: Mana-Tombs"] = "Auchindoun: Mana-Tombs",
	["Auchindoun: Sethekk Halls"] = "Auchindoun: Sethekk Halls",
	["Auchindoun: Shadow Labyrinth"] = "Auchindoun: Shadow Labyrinth",
	["August Celestials"] = "August Celestials",
	["Black Temple"] = "Black Temple",
	["Coilfang: Serpentshrine Cavern"] = "Coilfang: Serpentshrine Cavern",
	["Coilfang: The Slave Pens"] = "Coilfang: The Slave Pens",
	["Coilfang: The Steamvault"] = "Coilfang: The Steamvault",
	["Coilfang: The Underbog"] = "Coilfang: The Underbog",
	["Deadmines"] = "Deadmines",
	["Hellfire Citadel: Ramparts"] = "Hellfire Citadel: Ramparts",
	["Hellfire Citadel: The Blood Furnace"] = "Hellfire Citadel: The Blood Furnace",
	["Hellfire Citadel: The Shattered Halls"] = "Hellfire Citadel: The Shattered Halls",
	["King's Rest"] = "King's Rest",
	["Magister's Terrace"] = "Magister's Terrace",
	["Opening of the Dark Portal"] = "Opening of the Dark Portal",
	["Shrine of the Storm"] = "Shrine of the Storm",
	["Siege of Boralus"] = "Siege of Boralus",
	["Tempest Keep"] = "Tempest Keep",
	["Tempest Keep: The Arcatraz"] = "Tempest Keep: The Arcatraz",
	["Tempest Keep: The Botanica"] = "Tempest Keep: The Botanica",
	["Tempest Keep: The Mechanar"] = "Tempest Keep: The Mechanar",
	["Temple of Sethraliss"] = "Temple of Sethraliss",
	["The Escape from Durnholde"] = "The Escape from Durnholde",
	["The Sunwell"] = "The Sunwell",
	["The Underrot"] = "The Underrot",
	["Violet Hold"] = "Violet Hold",
	["Waycrest Manor"] = "Waycrest Manor"
}

if locale == "frFR" then
	L["Assault on Violet Hold"] = "L’assaut sur le fort Pourpre"
	L["Auchindoun: Auchenai Crypts"] = "Auchindoun : Cryptes Auchenaï"
	L["Auchindoun: Mana-Tombs"] = "Auchindoun : Tombes-mana"
	L["Auchindoun: Sethekk Halls"] = "Auchindoun : Salles des Sethekk"
	L["Auchindoun: Shadow Labyrinth"] = "Auchindoun : Labyrinthe des Ombres"
	L["August Celestials"] = "Astres vénérables"
	L["Black Temple"] = "Temple noir"
	L["Coilfang: Serpentshrine Cavern"] = "Glissecroc : caverne du sanctuaire du Serpent"
	L["Coilfang: The Slave Pens"] = "Glissecroc : les Enclos aux esclaves"
	L["Coilfang: The Steamvault"] = "Glissecroc : le Caveau de la vapeur"
	L["Coilfang: The Underbog"] = "Glissecroc : la Basse-tourbière"
	L["Deadmines"] = "Mortemines"
	L["Hellfire Citadel: Ramparts"] = "Citadelle des Flammes infernales : les Remparts"
	L["Hellfire Citadel: The Blood Furnace"] = "Citadelle des Flammes infernales : la Fournaise du sang"
	L["Hellfire Citadel: The Shattered Halls"] = "Citadelle des Flammes infernales : les Salles brisées"
	L["Magister's Terrace"] = "Terrasse des magistères"
	L["Opening of the Dark Portal"] = "Ouverture de la Porte des ténèbres"
	L["Siege of Boralus"] = "Siège de Boralus"
	L["Tempest Keep"] = "Donjon de la Tempête"
	L["Tempest Keep: The Arcatraz"] = "Donjon de la Tempête : l'Arcatraz"
	L["Tempest Keep: The Botanica"] = "Donjon de la Tempête : la Botanica"
	L["Tempest Keep: The Mechanar"] = "Donjon de la Tempête : le Méchanar"
	L["The Escape from Durnholde"] = "L'évasion de Fort-de-Durn"
	L["The Sunwell"] = "Le Puits de soleil"
	L["The Underrot"] = "Tréfonds Putrides"
elseif locale == "zhTW" then
	L["Assault on Violet Hold"] = "紫羅蘭堡之襲"
	L["August Celestials"] = "天尊之廷"
	L["Siege of Boralus"] = "波拉勒斯圍城戰"
elseif locale == "deDE" then
	L["King's Rest"] = "Königsruh"
	L["Shrine of the Storm"] = "Schrein des Sturms"
	L["Siege of Boralus"] = "Belagerung von Boralus"
	L["Temple of Sethraliss"] = "Tempel von Sethraliss"
	L["Waycrest Manor"] = "Kronsteiganwesen"
elseif locale == "itIT" then
	L["Assault on Violet Hold"] = "Assalto alla Fortezza Violacea"
	L["August Celestials"] = "Venerabili Celestiali"
	L["Siege of Boralus"] = "Assedio di Boralus"
end

local eventFrame = CreateFrame("Frame", "EncounterJournalSavedInstances_EventFrame", UIParent)
eventFrame:Show()

local startTime = -1
local savedInstances = {}
local statusFrames = {}

local function UpdateSavedInstances()
	savedInstances = {}

	local pandaria = EJ_GetInstanceInfo(322)
	local draenor = EJ_GetInstanceInfo(557)
	local brokenIsles = EJ_GetInstanceInfo(822)
	local invasionPoints = EJ_GetInstanceInfo(959)
	local azeroth = EJ_GetInstanceInfo(1028)

	local difficulty = "normal"

	local fEid, fQid
	if UnitFactionGroup("player") == "Horde" then
		fEid = 2212													-- The Lion's Roar
		fQid = 52848
	else
		fEid = 2213													-- Doom's Howl
		fQid = 52847
	end

	local worldBossesData = {
		Pandaria = {
			instanceName = pandaria,
			maxBosses = 6,
			bosses = {
				{encounter = 691, quest = 32099},					-- Sha of Anger
				{encounter = 725, quest = 32098},					-- Salyis's Warband
				{encounter = 814, quest = 32518},					-- Nalak, The Storm Lord
				{encounter = 826, quest = 32519},					-- Oondasta
				{name = L["August Celestials"], quest = 33117},		-- August Celestials
				{encounter = 861, quest = 33118}					-- Ordos, Fire-God of the Yaungol
			}
		},
		Draenor = {
			instanceName = draenor,
			maxBosses = 3,
			bosses = {
				{encounter = 1291, quest = 37460},					-- Drov the Ruiner
				{encounter = 1211, quest = 37462},					-- Tarlna the Ageless
				{encounter = 1262, quest = 37464},					-- Rukhmar
				{encounter = 1452, quest = 39380}					-- Supreme Lord Kazzak
			}
		},
		BrokenIsles = {
			instanceName = brokenIsles,
			maxBosses = 1,
			bosses = {
				{encounter = 1790, quest = 43512},					-- Ana-Mouz
				{encounter = 1956, quest = 47061},					-- Apocron
				{encounter = 1883, quest = 46947},					-- Brutallus
				{encounter = 1774, quest = 43193},					-- Calamir
				{encounter = 1789, quest = 43448},					-- Drugon the Frostblood
				{encounter = 1795, quest = 43985},					-- Flotsam
				{encounter = 1770, quest = 42819},					-- Humongris
				{encounter = 1769, quest = 43192},					-- Levantus
				{encounter = 1884, quest = 46948},					-- Malificus
				{encounter = 1783, quest = 43513},					-- Na'zak the Fiend
				{encounter = 1749, quest = 42270},					-- Nithogg
				{encounter = 1763, quest = 42779},					-- Shar'thos
				{encounter = 1885, quest = 46945},					-- Si'vash
				{encounter = 1756, quest = 42269},					-- The Soultakers
				{encounter = 1796, quest = 44287}					-- Withered Jim
			}
		},
		InvasionPoints = {
			instanceName = invasionPoints,
			maxBosses = 1,
			bosses = {
				{encounter = 2010, quest = 49199},					-- Matron Folnuna
				{encounter = 2011, quest = 48620},					-- Mistress Alluradel
				{encounter = 2012, quest = 49198},					-- Inquisitor Meto
				{encounter = 2013, quest = 49195},					-- Occularus
				{encounter = 2014, quest = 49197},					-- Sotanathor
				{encounter = 2015, quest = 49196}					-- Pit Lord Vilemus
			}
		},
		Azeroth = {
			instanceName = azeroth,
			maxBosses = 1,
			bosses = {
				{encounter = 2139, quest = 52181},					-- T'zane
				{encounter = 2141, quest = 52169},					-- Ji'arak
				{encounter = 2197, quest = 52157},					-- Hailstone Construct
				{encounter = fEid, quest = fQid},					-- The Lion's Roar/Doom's Howl
				{encounter = 2199, quest = 52163},					-- Azurethos, The Winged Typhoon
				{encounter = 2198, quest = 52166},					-- Warbringer Yenajz
				{encounter = 2210, quest = 52196}					-- Dunegorger Kraulok
			}
		}
	}
	
	local worldBosses = {}
	for z, wb in pairs(worldBossesData) do
		worldBosses[z] = worldBosses[z] or {}
		for n = 1, #wb.bosses do
			if IsQuestFlaggedCompleted(wb.bosses[n].quest) then
				savedInstances[wb.instanceName] = savedInstances[wb.instanceName] or {}
			end
			if not wb.bosses[n].name then
				wb.bosses[n].name = EJ_GetEncounterInfo(wb.bosses[n].encounter)
			end
			tinsert(worldBosses[z], {
				name = wb.bosses[n].name,
				isKilled = IsQuestFlaggedCompleted(wb.bosses[n].quest)
			})
		end
	end

	local defeatedBosses = 0
	for z, wb in pairs(worldBosses) do
		for n = 1, #wb do
			if wb[n].isKilled then
				defeatedBosses = defeatedBosses + 1
			end
		end
		if worldBossesData[z].instanceName and savedInstances[worldBossesData[z].instanceName] then
			local maxBosses = worldBossesData[z].maxBosses
			if defeatedBosses > 0 then
				tinsert(savedInstances[worldBossesData[z].instanceName], {
					bosses = worldBosses[z],
					instanceName = worldBossesData[z].instanceName,
					difficulty = difficulty,
					difficultyName = RAID_INFO_WORLD_BOSS,
					maxBosses = worldBossesData[z].maxBosses,
					defeatedBosses = defeatedBosses,
					progress = defeatedBosses.."/"..maxBosses,
					complete = defeatedBosses == maxBosses
				})
			end
		end
	end
	
	RequestRaidInfo()
	for i = 1, GetNumSavedInstances() do
		local instanceName, _, reset, instanceDifficulty, _, _, _, _, _, difficultyName, maxBosses, defeatedBosses = GetSavedInstanceInfo(i)

		if instanceName == L["Ahn'Qiraj Temple"] and locale == "enUS" then
			instanceName = EJ_GetInstanceInfo(744)
		elseif instanceName == L["Coilfang: Serpentshrine Cavern"] then
			instanceName = EJ_GetInstanceInfo(748)
		elseif instanceName == L["Tempest Keep"] then
			instanceName = EJ_GetInstanceInfo(749)
		elseif instanceName == L["Black Temple"] and locale == "frFR" then
			instanceName = EJ_GetInstanceInfo(751)
		elseif instanceName == L["The Sunwell"] then
			instanceName = EJ_GetInstanceInfo(752)
		elseif instanceName == L["Magister's Terrace"] then
			instanceName = EJ_GetInstanceInfo(249)
		elseif instanceName == L["Auchindoun: Sethekk Halls"] then
			instanceName = EJ_GetInstanceInfo(252)
		elseif instanceName == L["Auchindoun: Shadow Labyrinth"] then
			instanceName = EJ_GetInstanceInfo(253)
		elseif instanceName == L["Auchindoun: Auchenai Crypts"] then
			instanceName = EJ_GetInstanceInfo(247)
		elseif instanceName == L["Auchindoun: Mana-Tombs"] then
			instanceName = EJ_GetInstanceInfo(250)
		elseif instanceName == L["Tempest Keep: The Botanica"] then
			instanceName = EJ_GetInstanceInfo(257)
		elseif instanceName == L["Tempest Keep: The Mechanar"] then
			instanceName = EJ_GetInstanceInfo(258)
		elseif instanceName == L["Tempest Keep: The Arcatraz"] then
			instanceName = EJ_GetInstanceInfo(254)
		elseif instanceName == L["Coilfang: The Slave Pens"] then
			instanceName = EJ_GetInstanceInfo(260)
		elseif instanceName == L["Coilfang: The Steamvault"] then
			instanceName = EJ_GetInstanceInfo(261)
		elseif instanceName == L["Coilfang: The Underbog"] then
			instanceName = EJ_GetInstanceInfo(262)
		elseif instanceName == L["Hellfire Citadel: The Shattered Halls"] then
			instanceName = EJ_GetInstanceInfo(259)
		elseif instanceName == L["Hellfire Citadel: Ramparts"] then
			instanceName = EJ_GetInstanceInfo(248)
		elseif instanceName == L["Hellfire Citadel: The Blood Furnace"] then
			instanceName = EJ_GetInstanceInfo(256)
		elseif instanceName == L["The Escape from Durnholde"] then
			instanceName = EJ_GetInstanceInfo(251)
		elseif instanceName == L["Opening of the Dark Portal"] then
			instanceName = EJ_GetInstanceInfo(255)
		elseif instanceName == L["Violet Hold"] and locale == "enUS" then
			instanceName = EJ_GetInstanceInfo(283)
		elseif instanceName == L["Deadmines"] and locale == "frFR" then
			instanceName = EJ_GetInstanceInfo(63)
		elseif instanceName == L["The Underrot"] and locale == "frFR" then
			instanceName = EJ_GetInstanceInfo(1022)
		elseif instanceName == L["King's Rest"] and locale == "deDE" then
			instanceName = EJ_GetInstanceInfo(1041)
		elseif instanceName == L["Shrine of the Storm"] and locale == "deDE" then
			instanceName = EJ_GetInstanceInfo(1036)
		elseif instanceName == L["Siege of Boralus"] and locale == "deDE" then
			instanceName = EJ_GetInstanceInfo(1023)
			maxBosses = 4
		elseif instanceName == L["Temple of Sethraliss"] and locale == "deDE" then
			instanceName = EJ_GetInstanceInfo(1030)
		elseif instanceName == L["Waycrest Manor"] and locale == "deDE" then
			instanceName = EJ_GetInstanceInfo(1021)
		elseif instanceName == L["Assault on Violet Hold"] then
			maxBosses = 3
		elseif instanceName == L["Siege of Boralus"] then
			maxBosses = 4
		end

		if instanceDifficulty == 7 or instanceDifficulty == 17 then
			difficulty = "lfr"
		elseif instanceDifficulty == 2 or instanceDifficulty == 5 or instanceDifficulty == 6 or instanceDifficulty == 15 then
			difficulty = "heroic"
		elseif instanceDifficulty == 16 or instanceDifficulty == 23 then
			difficulty = "mythic"
		end

		local bosses = {}
		local b = 1
		while GetSavedInstanceEncounterInfo(i, b) do
			local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, b)
			tinsert(bosses, {
				name = bossName,
				isKilled = isKilled
			})
			b = b + 1
		end

		if reset > 0 and defeatedBosses > 0 then
			savedInstances[instanceName] = savedInstances[instanceName] or {}
			tinsert(savedInstances[instanceName], {
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
				GameTooltip:AddDoubleLine(boss.name, BOSS_DEAD, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			elseif not info.complete then
				GameTooltip:AddDoubleLine(boss.name, BOSS_ALIVE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
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

	local instances = savedInstances[instanceButton.tooltipTitle]
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
