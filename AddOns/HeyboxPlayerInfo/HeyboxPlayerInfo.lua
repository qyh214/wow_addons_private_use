SAVED = _G.HEYBOX_SAVED_PER_PLAYER_INFOS or {}
SAVED_ONE = _G.HEYBOX_SAVED_PLAYER_INFOS or {}

versionName = "wowretail"

local frm = CreateFrame("Frame") 
frm:SetScript("OnEvent", function(self, event, ...) 
    if type(self[event]) == "function" then 
		return self[event](self, ...)
	end 
end)


frm:RegisterEvent("PLAYER_LOGIN") 
function frm:PLAYER_LOGIN() 
	SAVED['AccountData'] = {}
	local accountType = IsTrialAccount()

	SAVED['AccountData']["AccountType"] = accountType

	SAVED['CharacterInfo'] = {}
	local unitName = GetUnitName("Player")
	SAVED['CharacterInfo']["UnitName"] = unitName

	local unitLevel = UnitLevel("Player")
	SAVED['CharacterInfo']["UnitLevel"] = unitLevel

	local unitSex = UnitSex("Player")
	SAVED['CharacterInfo']["UnitSex"] = unitSex

	local unitRace, _, unitRaceId = UnitRace("Player")
	SAVED['CharacterInfo']["UnitRace"] = unitRace
	SAVED['CharacterInfo']["UnitRaceId"] = unitRaceId

	local unitClass, _, unitClassId = UnitClass("Player")
	SAVED['CharacterInfo']["UnitClass"] = unitClass
	SAVED['CharacterInfo']["UnitClassId"] = unitClassId

	if versionName == "wowretail" then
		local specializationId, specializationName, description, icon, role, classFile, className  = GetSpecializationInfoByID(GetPrimarySpecialization())
		SAVED['CharacterInfo']["UnitSpecName"] = specializationName
		SAVED['CharacterInfo']["UnitSpecId"] = specializationId
	end

	local _, factionGroup = UnitFactionGroup("Player")
	SAVED['CharacterInfo']["UnitFactionGroup"] = factionGroup

	local RealmName = GetRealmName()
	SAVED['CharacterInfo']["Realm"] = RealmName

	local unitGUID = UnitGUID("Player")
	SAVED["UnitGUID"] = unitGUID

	local guildName, _, _, _ = GetGuildInfo("Player")
	SAVED['CharacterInfo']['UnitGuild'] = guildName
	if versionName == "wowretail" then
		local _, averageItemLevel, _ = GetAverageItemLevel()
		SAVED['CharacterInfo']["ItemLevel"] = averageItemLevel
	end

	local unitHealthMax = UnitHealthMax("Player")
	SAVED['CharacterInfo']["UnitHealthMax"] = unitHealthMax
	local unitPowerMax = UnitPowerMax("Player")
	SAVED['CharacterInfo']["UnitPowerMax"] = unitPowerMax
	local array = {"UnitStrength", "UnitAgility", "UnitStamina", "UnitIntelligence"}
	local last = 4
	if versionName == "wowclassicera" or versionName == "wowclassictbc" then
		array = {"UnitStrength", "UnitAgility", "UnitStamina", "UnitIntelligence", "UnitSpirit"}
		last = 5
	end

	SAVED['CharacterInfo']['Buff'] = {}
	for i = 1, last do
		local unitStat, _, posBuff, _ = UnitStat("Player", i)
		SAVED['CharacterInfo'][array[i]] = unitStat
		if versionName == 'wowclassictbc' then
			if posBuff > 0 then
				buff = {}
				buff[array[i]] = posBuff
				table.insert(SAVED['CharacterInfo']['Buff'], buff)
			end
		end
	end
	if length(SAVED['CharacterInfo']['Buff']) == 0 then
		SAVED['CharacterInfo']['Buff'] = nil
	end

	local unitArmor = UnitArmor("Player")
	SAVED['CharacterInfo']["UnitArmor"] = unitArmor

	if versionName == "wowclassicera" or versionName == "wowclassictbc" then 
		local array = {"UnitHolyResistance", "UnitFireResistance", "UnitNatureResistance", "UnitFrostResistance", "UnitShadowResistance", "UnitArcaneResistance"}
		for i = 1, 5 do
			local _, total, _, _ = UnitResistance("Player", i)
			SAVED["CharacterInfo"][array[i]] = total
		end
	end

	local dodgeChance = GetDodgeChance()
	SAVED['CharacterInfo']["UnitDodgeChance"] = dodgeChance
	local critChance = GetCritChance()
	SAVED['CharacterInfo']["UnitCritChance"] = critChance
	local haste = GetHaste()
	SAVED['CharacterInfo']["UnitHaste"] = haste
	local parryChance = GetParryChance()
	SAVED['CharacterInfo']["UnitParryChance"] = parryChance
	if versionName == "wowretail" then
		local matery = GetMastery()
		SAVED['CharacterInfo']["UnitMastery"] = matery
	end

	if versionName ~= "wowretail" then 
		local unitDefense = UnitDefense("Player")
		SAVED['CharacterInfo']["UnitDefense"] = unitDefense
		local unitAttackPower = UnitAttackPower("Player")
		SAVED['CharacterInfo']["UnitAttackPower"] = unitAttackPower
		local unitRangedAttackPower = UnitRangedAttackPower("Player")
		SAVED['CharacterInfo']["UnitRangedAttackPower"] = unitRangedAttackPower
		local unitCrHitMelee = GetCombatRatingBonus(6)
		SAVED['CharacterInfo']["UnitCrHitMelee"] = unitCrHitMelee
		local unitCrHitRanged = GetCombatRatingBonus(7)
		SAVED['CharacterInfo']["UnitCrHitRanged"] = unitCrHitRanged
		local unitCrHitSpell = GetCombatRatingBonus(8)
		SAVED['CharacterInfo']["UnitCrHitSpell"] = unitCrHitSpell
		local unitSpellBonusHealing = GetSpellBonusHealing()
		SAVED['CharacterInfo']["UnitSpellBonusHealing"] = unitSpellBonusHealing
		local unitSpellBonusDamage = 0
		for i = 1, 7 do
			local tmp = GetSpellBonusDamage(i)
			if tmp > unitSpellBonusDamage then
				unitSpellBonusDamage = tmp
			end
		end
		SAVED['CharacterInfo']["UnitSpellBonusDamage"] = unitSpellBonusDamage
		local unitCrWeaponSkillOffhand = GetCombatRatingBonus(22)
		SAVED['CharacterInfo']["UnitCrWeaponSkillOffhand"] = unitCrWeaponSkillOffhand
		local unitCrWeaponSkillRanged = GetCombatRatingBonus(23)
		SAVED['CharacterInfo']["UnitCrWeaponSkillRanged"] = unitCrWeaponSkillRanged
	end


	local block = GetBlockChance()
	SAVED['CharacterInfo']["UnitBlockChance"] = block
	local increaseDamage = GetCombatRatingBonus(29)
	SAVED['CharacterInfo']["UnitIncreaseDamage"] = increaseDamage
	local reduceTolerance = GetCombatRatingBonus(31)
	SAVED['CharacterInfo']["UnitReduceTolerance"] = reduceTolerance
	local effectiveness = C_PaperDollInfo.GetArmorEffectiveness(unitArmor, unitLevel)
	SAVED['CharacterInfo']["UnitArmorEffectiveness"] = effectiveness
	local defenceLevel = GetCombatRating(2)
	SAVED['CharacterInfo']["UnitDefenceLevel"] = defenceLevel
	local manaRegen = GetManaRegen()
	SAVED['CharacterInfo']["UnitManaRegen"] = manaRegen * 5

	local dodgeStrengthenPoints = GetCombatRating(3)
	SAVED['CharacterInfo']["UnitDodgeStrengthenPoints"] = dodgeStrengthenPoints
	local critMeleeStrengthenPoints = GetCombatRating(9)
	SAVED['CharacterInfo']["UnitCritMeleeStrengthenPoints"] = critMeleeStrengthenPoints
	local critRangeStrengthenPoints = GetCombatRating(10)
	SAVED['CharacterInfo']["UnitCritRangeStrengthenPoints"] = critRangeStrengthenPoints
	local critSpellStrengthenPoints = GetCombatRating(11)
	SAVED['CharacterInfo']["UnitCritSpellStrengthenPoints"] = critSpellStrengthenPoints
	local hasteMeleeStrengthenPoints = GetCombatRating(18)
	SAVED['CharacterInfo']["UnitHasteMeleeStrengthenPoints"] = hasteMeleeStrengthenPoints
	local hasteRangeStrengthenPoints = GetCombatRating(19)
	SAVED['CharacterInfo']["UnitHasteRangeStrengthenPoints"] = hasteRangeStrengthenPoints
	local hasteSpellStrengthenPoints = GetCombatRating(20)
	SAVED['CharacterInfo']["UnitHasteSpellStrengthenPoints"] = hasteSpellStrengthenPoints
	local parryStrengthenPoints = GetCombatRating(4)
	SAVED['CharacterInfo']["UnitParryStrengthenPoints"] = parryStrengthenPoints
	local materyStrengthenPoints = GetCombatRating(26)
	SAVED['CharacterInfo']["UnitMasteryStrengthenPoints"] = materyStrengthenPoints
	local increaseDamageStrengthenPoints = GetCombatRating(29)
	SAVED['CharacterInfo']["UnitIncreaseDamageStrengthenPoints"] = increaseDamageStrengthenPoints
	local reduceToleranceStrengthenPoints = GetCombatRating(31)
	SAVED['CharacterInfo']["UnitReduceToleranceStrengthenPoints"] = reduceToleranceStrengthenPoints
	local blockStrengthenPoints = GetCombatRating(5)
	SAVED['CharacterInfo']["UnitBlockStrengthenPoints"] = blockStrengthenPoints


	

	if versionName == "wowretail" then
		SAVED["SpecializedSkills"] = {}
		local maxLengthID = 0
		local maxLength = 0
		for specIndex = 1, 3 do
			local specialID, _, _, _, _, _ = GetSpecializationInfo(specIndex)
			SAVED["SpecializedSkills"][specialID] = {}
			for tier = 1, 7 do
				for column = 1, 3 do
					local talentID, name, texture, selected, available, spellID, unknown, row, column, known, grantedByAura = GetTalentInfoBySpecialization(specIndex, tier, column)
					if known == true then
						specialSkill = {}
						specialSkill['SpecializedSkillSpellID'] = spellID
						table.insert(SAVED["SpecializedSkills"][specialID], specialSkill)
					end
				end
			end
			if length(SAVED["SpecializedSkills"][specialID]) >= maxLength then
				SAVED["SpecializedSkills"][maxLengthID] = nil
				maxLength = length(SAVED["SpecializedSkills"][specialID])
				maxLengthID = specialID
			else
				SAVED["SpecializedSkills"][specialID] = nil
			end
		end

		SAVED["SkillRelated"] = {}
		for i = 1, 3 do
			local PvpTalent = {}
			local tmp = C_SpecializationInfo.GetPvpTalentSlotInfo(i)
			if tmp ~= nil then 
				for k, v in pairs(tmp) do
					if k == "selectedTalentID" then
						local talentID, name, icon, selected, available, spellID, unlocked, row, column, known, grantedByAura = GetPvpTalentInfoByID(v)
						skill = {}
						skill["SkillSpellID"] = spellID
						table.insert(SAVED["SkillRelated"], skill)
					end
				end
			end
		end
	end

	

	if versionName == "wowretail" then
		SAVED['Mounts'] = {}
		for _, id in pairs(C_MountJournal.GetMountIDs()) do
			local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
			if isCollected == true then
				Mount = {}
				Mount["MountID"] = mountID
				Mount["MountName"] = name
				Mount["MountSpellID"] = spellID
				table.insert(SAVED['Mounts'], Mount)
			end
		end
	end

	if versionName ~= "wowclassicera" and versionName ~= "wowretail" then
		SAVED['ClassicMounts'] = {}
		local nums = GetNumCompanions("Mount")
		for i = 1, nums do
			ClassicMount = {}
			local creatureID, creatureName, creatureSpellID, _, _, _ = GetCompanionInfo("Mount", i)
			ClassicMount["CreatureID"] = creatureID
			ClassicMount["CreatureName"] = creatureName
			ClassicMount["CreatureSpellID"] = creatureSpellID
			table.insert(SAVED['ClassicMounts'], ClassicMount)
		end
	end

	if versionName ~= "wowclassicera" then
		SAVED['Achievements'] = {}

		local achievementTable = GetCategoryList()
		for k, v in pairs(achievementTable) do
			local total, _, _ = GetCategoryNumAchievements(v)
			for i = 1, total do
				local id, name, points, completed, month, day, year, description, flags,
				icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(v, i)
				if completed == true then
					achievement = {}
					achievement["AchievementID"] = id
					achievement["AchievementPoints"] = points
					achievement["AchievementName"] = name
					achievement["AchievementIcon"] = icon
					achievement["AchievementCompleteTime"] = "20" .. year .. "-" .. month .. "-" .. day
					table.insert(SAVED['Achievements'], achievement)
				end
			end
		end
		local totalAchievementPoints = GetTotalAchievementPoints()
		SAVED['AchievementPoints'] = totalAchievementPoints
	end

	if versionName == "wowretail" then
		local runHistory = C_MythicPlus.GetRunHistory(true, true)
		if length(runHistory) ~= 0 then
			SAVED["RunHistory"] = {}
			for i = 1, runHistory and #runHistory do
				local Mythic = {}
				Mythic["Level"] = runHistory[i]["level"]
				Mythic["Completed"] = runHistory[i]["completed"]
				Mythic["RunScore"] = runHistory[i]["runScore"]
				Mythic["ThisWeek"] = runHistory[i]["thisWeek"]
				local mapChallengeModeID = runHistory[i]["mapChallengeModeID"]
				Mythic["MapChallengeModeId"] = mapChallengeModeID
				local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(mapChallengeModeID)
				if intimeInfo ~= nil then
					Mythic["IntimeInfo"] = {}
					Mythic["IntimeInfo"]["DurationSec"] = intimeInfo["durationSec"]
					local year = intimeInfo["completionDate"]["year"]
					local month = intimeInfo["completionDate"]["month"]
					local day = intimeInfo["completionDate"]["day"]
					local hour = intimeInfo["completionDate"]["hour"]
					local minute = intimeInfo["completionDate"]["minute"]
					local completionDate = "20" .. year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. minute 
					Mythic["IntimeInfo"]["CompletionDate"] = completionDate
					Mythic["IntimeInfo"]["AffixIDs"] = {}
					for k, v in pairs(intimeInfo["affixIDs"]) do
						affixId = {}
						affixId['AffixID'] = v
						table.insert(Mythic["IntimeInfo"]["AffixIDs"], affixId)
					end
					Mythic["IntimeInfo"]["Members"] = {}
					for k, v in pairs(intimeInfo["members"]) do
						local member = {}
						member["Name"] = v["name"]
						member["ClassID"] = v["classID"]
						table.insert(Mythic["IntimeInfo"]["Members"], member)
					end
				end
				if overtimeInfo ~= nil then
					Mythic["OvertimeInfo"] = {}
					Mythic["OvertimeInfo"]["DurationSec"] = overtimeInfo["durationSec"]
					local year = overtimeInfo["completionDate"]["year"]
					local month = overtimeInfo["completionDate"]["month"]
					local day = overtimeInfo["completionDate"]["day"]
					local hour = overtimeInfo["completionDate"]["hour"]
					local minute = overtimeInfo["completionDate"]["minute"]
					local completionDate = "20" .. year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. minute 
					Mythic["OvertimeInfo"]["CompletionDate"] = completionDate
					Mythic["OvertimeInfo"]["AffixIDs"] = {}
					for k, v in pairs(overtimeInfo["affixIDs"]) do
						affixId = {}
						affixId['AffixID'] = v
						table.insert(Mythic["OvertimeInfo"]["AffixIDs"], affixId)
					end
					Mythic["OvertimeInfo"]["Members"] = {}
					for k, v in pairs(overtimeInfo["members"]) do
						local member = {}
						member["Name"] = v["name"]
						member["ClassID"] = v["classID"]
						table.insert(Mythic["OvertimeInfo"]["Members"], member)
					end
				end
				table.insert(SAVED["RunHistory"], Mythic)
			end
		end
	end

	SAVED["PVPInfo"] = {}
	if versionName == "wowretail" then
		local unitHonor = UnitHonorLevel("player")
		SAVED["PVPInfo"]["PVPUnitHonor"] = unitHonor
	end
	local honorableKills, dishonorableKills, highestRank = GetPVPLifetimeStats()
	SAVED["PVPInfo"]["PVPHonorKill"] = honorableKills

	if versionName ~= "wowclassicera" then
		SAVED["PVPInfo"]["PVPHistory"] = {}
		local nvn = {"2v2", "3v3", "5v5", "10v10"}
		local last = 4
		if versionName == "wowclassictbc" then 
			last = 3
		end
		for i = 1, last do
			local pvpInfo = {}
			local rating, seasonBest, _, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, _ = GetPersonalRatedInfo(i)
			pvpInfo["Rating"] = rating
			pvpInfo["SeasonBest"] = seasonBest
			pvpInfo["SeasonPlayed"] = seasonPlayed
			pvpInfo["SeasonWon"] = seasonWon
			pvpInfo["WeeklyPlayed"] = weeklyPlayed
			pvpInfo["WeeklyWon"] = weeklyWon
			pvpInfo["Type"] = nvn[i]
			table.insert(SAVED["PVPInfo"]["PVPHistory"], pvpInfo)
		end
	end

	SAVED["Reputations"] = {}
	local standingTable = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
	standingTable[0] = "Unknown"
	local numFactions = GetNumFactions()
	local factionIndex = 1
	while (factionIndex <= numFactions) do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar,
			isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex)
		if hasRep or not isHeader then
			local s = { 
				ReputationName = name,
				ReputationLevel = standingTable[standingId], 
				ReputationExperience = earnedValue,
				ReputationLevelUpExperience = topValue
			}
			table.insert(SAVED["Reputations"], s)
		end
		factionIndex = factionIndex + 1
	end

	if versionName == "wowretail" then
		SAVED["Covenant"] = {}
		SAVED["Covenant"]["RenownLevel"] = C_CovenantSanctumUI.GetRenownLevel()
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
		local soulBindIDs = covenantData["soulbindIDs"]
		local activeSoulBindID = C_Soulbinds.GetActiveSoulbindID()
		SAVED["Covenant"]["activeSoulBindID"] = activeSoulBindID
		SAVED["Covenant"]["CovenantSkill"] = {}
		for _, v in pairs(soulBindIDs) do
			local isActive = false
			if v == activeSoulBindID then
				isActive = true
			end
			local tmp = C_Soulbinds.GetSoulbindData(v)
			local tree = tmp["tree"]
			local nodes = tree["nodes"]
			local soulBindInfo = {}
			soulBindInfo["IsActive"] = isActive
			soulBindInfo["CovenantSkillNodes"] = {}
			for _, j in pairs(nodes) do
				local node = {}
				local conduitID, conduitRank, spellID, icon, row, column, ID = j["conduitID"], j["conduitRank"], j["spellID"], j["icon"], j["row"], j["column"], j["ID"]
				node["ConduitId"] = conduitID
				node["ConduitRank"] = conduitRank
				node["SpellId"] = spellID
				node["Icon"] = icon
				node["Row"] = row
				node["Column"] = column
				node["Id"] = ID
				table.insert(soulBindInfo["CovenantSkillNodes"], node)
			end
			table.insert(SAVED["Covenant"]["CovenantSkill"], soulBindInfo)
		end
	end

	if versionName ~= "wowretail" then
		local ok, num = pcall(getNumTalentTabs)
		if ok then
			SAVED["CharacterTalent"] = {}
			for i = 1, num do
				local talentTree = {}
				local talentTabName, _, _, _ = GetTalentTabInfo(i)
				local talentTreeLeaves = {}
				for j = 1, GetNumTalents(i) do
					local characterTalent = {}
					local name, _, tier, column, rank, _, _, _ = GetTalentInfo(i, j)
					characterTalent["Name"] = name
					characterTalent["Rank"] = rank
					characterTalent["Tier"] = tier
					characterTalent["Column"] = column
					table.insert(talentTreeLeaves, characterTalent)
				end
				talentTree['TalentTreeRoot'] = talentTabName
				talentTree['TalentTreeLeaves'] = talentTreeLeaves
				table.insert(SAVED["CharacterTalent"], talentTree)
			end
		end
	end

	SAVED["HunterPets"] = {}
	for i = 1, 205 do
		local hunterPet = {}
		local petIcon, petName, petLevel, petType, petTalents = GetStablePetInfo(i)
		hunterPet['HunterPetId'] = i
		hunterPet['HunterPetName'] = petName
		hunterPet['HunterPetIcon'] = petIcon
		hunterPet['HunterPetLevel'] = petLevel
		hunterPet['HunterPetType'] = petType
		table.insert(SAVED["HunterPets"], hunterPet)
	end
end


frm:RegisterEvent("ADDON_LOADED")
function frm:ADDON_LOADED()
	local version, build, date, tocversion = GetBuildInfo()
	local v = split(version, ".")[1]
	local version = tonumber(v)
	if version == 1 then
		versionName = "wowclassicera"
	elseif version > 1 and version < 9 then
		versionName = "wowclassictbc"
	end
	
	SAVED["Equipments"] = {}
	local Quality = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Artifact", "Heirloom", "WoWToken"}
	Quality[0] = "Poor"
	local slotArray = {"Head", "Neck", "Shoulders", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger_0", "Finger_1", "Trinket_0", "Trinket_1", "Back", "Main_Hand", "Off_Hand", "Ranged", "Tabard"}
	for i = 1, 19 do
		local Equipment = {}
		Equipment["SlotName"] = slotArray[i]
		local itemID = GetInventoryItemID("Player", i)
		if type(itemID) ~= "nil" then
			Equipment["EquipID"] = itemID
			local equipAddition = GetInventoryItemLink("Player", i)
			Equipment["EquipAddition"] = equipAddition
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, _, _,_, _, _, sellPrice, _, _, _,_, setID, _ = GetItemInfo(equipAddition)

			local _, spellID = GetItemSpell(itemID)
			Equipment["EquipSpellID"] = spellID
			Equipment["EquipSetID"] = setID
			Equipment['EquipName'] = itemName
			Equipment['EquipQuality'] = Quality[itemQuality]
			Equipment['EquipPrice'] = sellPrice
			
			local effectiveILvl, _, _ = GetDetailedItemLevelInfo(equipAddition) 
			Equipment['EquipLevel'] = effectiveILvl

			local itemIcon = GetItemIcon(itemID)
			Equipment['EquipIcon'] = itemIcon
			local ok, itemStats = pcall(getItemStats, itemLink)
			if ok then
				if itemStats ~= nil then
					Equipment["EquipAttribute"] = {}
					for k, v in pairs(itemStats) do
						Equipment["EquipAttribute"][k] = v
					end
					l = length(Equipment["EquipAttribute"])
					if l == 0 then
						Equipment["EquipAttribute"] = nil
					end
				end
			end
			local current, maximum = GetInventoryItemDurability(i)
			if current ~= nil and maximum ~= nil then
				Equipment["EquipDurability"] = {}
				Equipment["EquipDurability"]["EquipDurabilityCurrent"] = current
				Equipment["EquipDurability"]["EquipDurabilityMaximum"] = maximum
			end

			local ok, itemIdForSource = pcall(getSlotVisualInfo, i)
			if ok then
				Equipment['EquipItemIdForSource'] = itemIdForSource
			end
			
			local isRangedWeapon = IsRangedWeapon()
			if i == 16 then
				local mainSpeed, _ = UnitAttackSpeed("player")
				Equipment['EquipAttackSpeed'] = mainSpeed
				if isRangedWeapon then
					local _, lowDmg, hiDmg, _, _, _ = UnitRangedDamage("player")
					Equipment['EquipAttackLowDamage'] = lowDmg
					Equipment['EquipAttackHighDamage'] = hiDmg
				else
					local lowDmg, hiDmg, _, _, _, _, _ = UnitDamage("player")
					Equipment['EquipAttackLowDamage'] = lowDmg
					Equipment['EquipAttackHighDamage'] = hiDmg
				end
			end
			if i == 17 then
				local _, offSpeed = UnitAttackSpeed("player")
				Equipment['EquipAttackSpeed'] = offSpeed
				if not isRangedWeapon then
					local _, _, offlowDmg, offhiDmg, _, _, _ = UnitDamage("player")
					Equipment['EquipAttackLowDamage'] = offlowDmg
					Equipment['EquipAttackHighDamage'] = offhiDmg
				end
			end
		end
		table.insert(SAVED["Equipments"], Equipment)
	end

	if versionName == "wowretail" then
		SAVED["Toys"] = {}
		local index = 1
		while true
		do	
			local toy = {}
			local itemId = C_ToyBox.GetToyFromIndex(index)
			if itemId == -1 then
				break
			end
			toy['ToyId'] = itemId
			index = index + 1
			table.insert(SAVED["Toys"], toy)
		end
	end
end

function split(str,delimiter)
    local dLen = string.len(delimiter)
    local newDeli = ''
    for i=1,dLen,1 do
        newDeli = newDeli .. "["..string.sub(delimiter,i,i).."]"
    end

    local locaStart,locaEnd = string.find(str,newDeli)
    local arr = {}
    local n = 1
    while locaStart ~= nil
    do
        if locaStart>0 then
            arr[n] = string.sub(str,1,locaStart-1)
            n = n + 1
        end

        str = string.sub(str,locaEnd+1,string.len(str))
        locaStart,locaEnd = string.find(str,newDeli)
    end
    if str ~= nil then
        arr[n] = str
    end
    return arr
end

function getSlotVisualInfo(i)
	local transmogLoc  = TransmogUtil.CreateTransmogLocation(i,Enum.TransmogType.Appearance,Enum.TransmogModification.None)
	local _, _, appliedSourceID, _, _, _, _, _, _ = C_Transmog.GetSlotVisualInfo(transmogLoc)
	if appliedSourceID ~= nil then
		local itemIdForSource = C_Transmog.GetItemIDForSource(appliedSourceID)
		return itemIdForSource
	end
end

function getItemStats(link)
	local itemStats = GetItemStats(link)
	return itemStats
end

function getNumTalentTabs()
	local num = GetNumTalentTabs()
	return num
end

function length(t)
    local res=0
    for k,v in pairs(t) do
        res=res+1
    end
    return res
end

luaJson = {}
local function json2true(str, from, to)
    return true, from + 3
end

local function json2false(str, from, to)
    return false, from + 4
end

local function json2null(str, from, to)
    return nil, from + 3
end

local function json2nan(str, from, to)
    return nul, from + 2
end

local numberchars = {
    ['-'] = true,
    ['+'] = true,
    ['.'] = true,
    ['0'] = true,
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
}

local function json2number(str, from, to)
    local i = from + 1
    while (i <= to) do
        local char = string.sub(str, i, i)
        if not numberchars[char] then
            break
        end
        i = i + 1
    end
    local num = tonumber(string.sub(str, from, i - 1))
    if not num then
        Log("red", 'json格式错误，不正确的数字, 错误位置:', from)
    end
    return num, i - 1
end

local function json2string(str, from, to)
    local ignor = false
    for i = from + 1, to do
        local char = string.sub(str, i, i)
        if not ignor then
            if char == '\"' then
                return string.sub(str, from + 1, i - 1), i
            elseif char == '\\' then
                ignor = true
            end
        else
            ignor = false
        end
    end
    Log("red", 'json格式错误，字符串没有找到结尾, 错误位置:{from}', from)
end

local function json2array(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            result[#result + 1], pos = json2string(str, pos, to)
        elseif char == '[' then
            result[#result + 1], pos = json2array(str, pos, to)
        elseif char == '{' then
            result[#result + 1], pos = luaJson.json2table(str, pos, to)
        elseif char == ']' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[#result + 1], pos = json2false(str, pos, to)
        elseif (char == 't' or char == 'T') then
            result[#result + 1], pos = json2true(str, pos, to)
        elseif (char == 'n') then
            result[#result + 1], pos = json2null(str, pos, to)
        elseif (char == 'N') then
            result[#result + 1], pos = json2nan(str, pos, to)
        elseif numberchars[char] then
            result[#result + 1], pos = json2number(str, pos, to)
        end
        pos = pos + 1
    end
    Log("red", 'json格式错误，表没有找到结尾, 错误位置:{from}', from)
end

local function string2json(key, value)
    return string.format("\"%s\":\"%s\",", key, value)
end

local function number2json(key, value)
    return string.format("\"%s\":%s,", key, value)
end

local function boolean2json(key, value)
    value = value == nil and false or value
    return string.format("\"%s\":%s,", key, tostring(value))
end

local function array2json(key, value)
    local str = "["
    for k, v in pairs(value) do
        str = str .. luaJson.table2json(v) .. ","
    end
    str = string.sub(str, 1, string.len(str) - 1) .. "]"
    return string.format("\"%s\":%s,", key, str)
end

local function isArrayTable(t)

    if type(t) ~= "table" then
        return false
    end

    local n = #t
    for i, v in pairs(t) do
        if type(i) ~= "number" then
            return false
        end

        if i > n then
            return false
        end
    end

    return true
end

local function table2json(key, value)
    if isArrayTable(value) then
        return array2json(key, value)
    end
    local tableStr = luaJson.table2json(value)
    return string.format("\"%s\":%s,", key, tableStr)
end



function luaJson.json2table(str, from, to)
    local result = {}
    from = from or 1
    local pos = from + 1
    local to = to or string.len(str)
    local key
    while (pos <= to) do
        local char = string.sub(str, pos, pos)
        if char == '\"' then
            if not key then
                key, pos = json2string(str, pos, to)
            else
                result[key], pos = json2string(str, pos, to)
                key = nil
            end
        --[[    elseif char == ' ' then

        elseif char == ':' then

        elseif char == ',' then]]
        elseif char == '[' then
            if not key then
                key, pos = json2array(str, pos, to)
            else
                result[key], pos = json2array(str, pos, to)
                key = nil
            end
        elseif char == '{' then
            if not key then
                key, pos = luaJson.json2table(str, pos, to)
            else
                result[key], pos = luaJson.json2table(str, pos, to)
                key = nil
            end
        elseif char == '}' then
            return result, pos
        elseif (char == 'f' or char == 'F') then
            result[key], pos = json2false(str, pos, to)
            key = nil
        elseif (char == 't' or char == 'T') then
            result[key], pos = json2true(str, pos, to)
            key = nil
        elseif (char == 'n') then
            result[key], pos = json2null(str, pos, to)
            key = nil
        elseif (char == 'N') then
            result[key], pos = json2nan(str, pos, to)
            key = nil
        elseif numberchars[char] then
            if not key then
                key, pos = json2number(str, pos, to)
            else
                result[key], pos = json2number(str, pos, to)
                key = nil
            end
        end
        pos = pos + 1
    end
    Log("red", 'json格式错误，表没有找到结尾, 错误位置:{from}', from)
end

local jsonfuncs = {
    ['\"'] = json2string,
    ['['] = json2array,
    ['{'] = luaJson.json2table,
    ['f'] = json2false,
    ['F'] = json2false,
    ['t'] = json2true,
    ['T'] = json2true,
}

function luaJson.json2lua(str)
    local char = string.sub(str, 1, 1)
    local func = jsonfuncs[char]
    if func then
        return func(str, 1, string.len(str))
    end
    if numberchars[char] then
        return json2number(str, 1, string.len(str))
    end
end

function luaJson.table2json(tab)
	print(tab)
    local str = "{"
    for k, v in pairs(tab) do
        if type(v) == "string" then
            str = str .. string2json(k, v)
        elseif type(v) == "number" then
            str = str .. number2json(k, v)
        elseif type(v) == "boolean" then
            str = str .. boolean2json(k, v)
        elseif type(v) == "table" then
            str = str .. table2json(k, v)
        end
    end
    str = string.sub(str, 1, string.len(str) - 1)
    return str .. "}"
end



local wipe, type, error, format, strsub, strchar, strbyte, tconcat = wipe, type, error, format, strsub, strchar, strbyte, table.concat
local _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local byteToNum, numToChar = {}, {}
for i = 1, #_chars do
	numToChar[i - 1] = strsub(_chars, i, i)
	byteToNum[strbyte(_chars, i)] = i - 1
end

local t = {}
local equals_byte = strbyte("=")
local whitespace = {
	[strbyte(" ")] = true,
	[strbyte("\t")] = true,
	[strbyte("\n")] = true,
	[strbyte("\r")] = true,
}

function Encode(text, maxLineLength, lineEnding)
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `Encode'. Expected string, got %q", type(text)), 2)
	end

	if maxLineLength then
		if type(maxLineLength) ~= "number" then
			error(format("Bad argument #2 to `Encode'. Expected number or nil, got %q", type(maxLineLength)), 2)
		elseif (maxLineLength % 4) ~= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a multiple of 4, got %s", maxLineLength), 2)
		elseif maxLineLength <= 0 then
			error(format("Bad argument #2 to `Encode'. Expected a number > 0, got %s", maxLineLength), 2)
		end
	end

	if lineEnding == nil then
		lineEnding = "\r\n"
	elseif type(lineEnding) ~= "string" then
		error(format("Bad argument #3 to `Encode'. Expected string, got %q", type(lineEnding)), 2)
	end

	local currentLength = 0
	for i = 1, #text, 3 do
		local a, b, c = strbyte(text, i, i+2)
		local nilNum = 0
		if not b then
			nilNum, b, c = 2, 0, 0
		elseif not c then
			nilNum, c = 1, 0
		end

		local num = a * 2^16 + b * 2^8 + c
		local d = num % 2^6;num = (num - d) / 2^6
		c = num % 2^6;num = (num - c) / 2^6
		b = num % 2^6;num = (num - b) / 2^6
		a = num % 2^6

		t[#t+1] = numToChar[a]
		t[#t+1] = numToChar[b]
		t[#t+1] = (nilNum >= 2) and "=" or numToChar[c]
		t[#t+1] = (nilNum >= 1) and "=" or numToChar[d]

		currentLength = currentLength + 4
		if maxLineLength and (currentLength % maxLineLength) == 0 then
			t[#t+1] = lineEnding
		end
	end

	local s = tconcat(t)
	wipe(t)

	return s
end

local t2 = {}

function Decode(text)
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `Decode'. Expected string, got %q", type(text)), 2)
	end

	for i = 1, #text do
		local byte = strbyte(text, i)
		if not (whitespace[byte] or byte == equals_byte) then
			local num = byteToNum[byte]
			if not num then
				wipe(t2)

				error(format("Bad argument #1 to `Decode'. Received an invalid char: %q", strsub(text, i, i)), 2)
			end

			t2[#t2+1] = num
		end
	end

	for i = 1, #t2, 4 do
		local a, b, c, d = t2[i], t2[i+1], t2[i+2], t2[i+3]
		local nilNum = 0
		if not c then
			nilNum, c, d = 2, 0, 0
		elseif not d then
			nilNum, d = 1, 0
		end

		local num = a * 2^18 + b * 2^12 + c * 2^6 + d
		c = num % 2^8;num = (num - c) / 2^8
		b = num % 2^8;num = (num - b) / 2^8
		a = num % 2^8

		t[#t+1] = strchar(a)
		if nilNum < 2 then t[#t+1] = strchar(b) end
		if nilNum < 1 then t[#t+1] = strchar(c) end
	end

	wipe(t2)

	local s = tconcat(t)
	wipe(t)

	return s
end

function IsBase64(text)
	if type(text) ~= "string" then
		error(format("Bad argument #1 to `IsBase64'. Expected string, got %q", type(text)), 2)
	end

	if #text % 4 ~= 0 then
		return false
	end

	for i = 1, #text do
		local byte = strbyte(text, i)
		if not (whitespace[byte] or byte == equals_byte) then
			local num = byteToNum[byte]
			if not num then
				return false
			end
		end
	end

	return true
end


frm:RegisterEvent("PLAYER_LOGOUT")   --退出游戏(返回角色选择界面)
function frm:PLAYER_LOGOUT()  
	local name_realm = tostring(UnitName'player') .. "-" .. tostring(GetRealmName())
	SAVED_ONE[name_realm] = SAVED_ONE[name_realm] or {}
	SAVED_ONE[name_realm].class = select(2,UnitClass'player')

	
	if versionName == "wowretail" then
		SAVED["Pets"] = {}
		local _, petNum = C_PetJournal.GetNumPets()
		local petIndex = 1
		local rarityTable = {"Poor", "Common", "Uncommon", "Rare", "Epic", "Legendary"}
		while (petIndex <= petNum) do
			local p = {}
			local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(petIndex)
			p["PetID"] = companionID
			p["PetName"] = customName
			p["PetIcon"] = icon
			local health, _, power, speed, rarity = C_PetJournal.GetPetStats(petID)
			p["PetRarity"] = rarityTable[rarity]
			p["PetSpeciesName"] = speciesName
			local table1, table2 = C_PetJournal.GetPetAbilityList(speciesID)
			for k, v in pairs(table1) do
				local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(v)
			end
			
			local petTypeStr = {"Humanoid", "Dragonkin", "Flying", "Undead", "Critter", "Magic", "Elemental", "Beast", "Aquatic", "Mechanical"}
			p["PetAttributes"] = petTypeStr[petType]
			p["PetLevel"] = level
			p["PetHealth"] = health
			p["PetPower"] = power
			p["PetSpeed"] = speed
			table.insert(SAVED["Pets"], p)
			petIndex = petIndex + 1
		end
	end

	_G.HEYBOX_SAVED_PER_PLAYER_INFOS = Encode(luaJson.table2json(SAVED), nil, nil)
	_G.HEYBOX_SAVED_PLAYER_INFOS = SAVED_ONE
end

