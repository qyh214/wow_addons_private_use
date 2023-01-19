local _G = _G
local U, V = _G.Utils, _G.VersionInfo

local HeyboxApi = {}

function HeyboxApi.GetGlobal(SAVED, SAVED_ONE)
    SAVED["UnitGUID"] = UnitGUID("Player")
    SAVED["Date"] = time()
    SAVED["Version"] = GetBuildInfo()

    local name_realm = tostring(UnitName'player') .. "-" .. tostring(GetRealmName())
	SAVED_ONE[name_realm] = SAVED_ONE[name_realm] or {}
	SAVED_ONE[name_realm].class = select(2,UnitClass'player')

end

function HeyboxApi.GetAccountData(SAVED)
    SAVED['AccountData'] = {}
	SAVED['AccountData']["AccountType"] = IsTrialAccount()
end

function HeyboxApi.GetCharacterInfo(SAVED)
    SAVED['CharacterInfo'] = {}
	SAVED['CharacterInfo']["UnitName"] = GetUnitName("Player")
	SAVED['CharacterInfo']["UnitLevel"] = UnitLevel("Player")
	SAVED['CharacterInfo']["UnitSex"] = UnitSex("Player")
	SAVED['CharacterInfo']['UnitTitle'] = GetCurrentTitle()

	local unitRace, _, unitRaceId = UnitRace("Player")
	SAVED['CharacterInfo']["UnitRace"] = unitRace
	SAVED['CharacterInfo']["UnitRaceId"] = unitRaceId

	local unitClass, _, unitClassId = UnitClass("Player")
	SAVED['CharacterInfo']["UnitClass"] = unitClass
	SAVED['CharacterInfo']["UnitClassId"] = unitClassId

	SAVED['CharacterInfo']["UnitFactionGroup"] = select(2, UnitFactionGroup("Player"))
	SAVED['CharacterInfo']["Realm"] = GetRealmName()
	SAVED['CharacterInfo']['UnitGuild'] = GetGuildInfo("Player")
    SAVED['CharacterInfo']["UnitHealthMax"] = UnitHealthMax("Player")
	SAVED['CharacterInfo']["UnitPowerMax"] = UnitPowerMax("Player")
	SAVED['CharacterInfo']["UnitArmor"] = select(3, UnitArmor("Player"))
    SAVED['CharacterInfo']["UnitDodgeChance"] = GetDodgeChance()
	SAVED['CharacterInfo']["UnitCritChance"] = GetCritChance()
	SAVED['CharacterInfo']["UnitHaste"] = GetHaste()
	SAVED['CharacterInfo']["UnitParryChance"] = GetParryChance()
	SAVED['CharacterInfo']["UnitBlockChance"] = GetBlockChance()
	SAVED['CharacterInfo']["UnitIncreaseDamage"] = GetCombatRatingBonus(29)
	SAVED['CharacterInfo']["UnitReduceTolerance"] = GetCombatRatingBonus(31)
	SAVED['CharacterInfo']["UnitToughness"] = GetCombatRating(15)
	SAVED['CharacterInfo']["UnitArmorEffectiveness"] = C_PaperDollInfo.GetArmorEffectiveness(SAVED['CharacterInfo']["UnitArmor"], SAVED['CharacterInfo']["UnitLevel"])
	SAVED['CharacterInfo']["UnitDefenceLevel"] = GetCombatRating(2)
	SAVED['CharacterInfo']["UnitManaRegen"] = GetManaRegen() * 5
	SAVED['CharacterInfo']["UnitDodgeStrengthenPoints"] = GetCombatRating(3)
	SAVED['CharacterInfo']["UnitCritMeleeStrengthenPoints"] = GetCombatRating(9)
	SAVED['CharacterInfo']["UnitCritRangeStrengthenPoints"] = GetCombatRating(10)
	SAVED['CharacterInfo']["UnitCritSpellStrengthenPoints"] = GetCombatRating(11)
	SAVED['CharacterInfo']["UnitHasteMeleeStrengthenPoints"] = GetCombatRating(18)
	SAVED['CharacterInfo']["UnitHasteRangeStrengthenPoints"] = GetCombatRating(19)
	SAVED['CharacterInfo']["UnitHasteSpellStrengthenPoints"] = GetCombatRating(20)
	SAVED['CharacterInfo']["UnitParryStrengthenPoints"] = GetCombatRating(4)
	SAVED['CharacterInfo']["UnitMasteryStrengthenPoints"] = GetCombatRating(26)
	SAVED['CharacterInfo']["UnitIncreaseDamageStrengthenPoints"] = GetCombatRating(29)
	SAVED['CharacterInfo']["UnitReduceToleranceStrengthenPoints"] = GetCombatRating(31)
	SAVED['CharacterInfo']["UnitBlockStrengthenPoints"] = GetCombatRating(5)

	local array = {"UnitStrength", "UnitAgility", "UnitStamina", "UnitIntelligence"}
    if not V.Retail then
        table.insert(array, "UnitSpirit")
    end
    SAVED['CharacterInfo']['Buff'] = {}
	for i = 1, U.Length(array) do
		local unitStat, _, posBuff, _ = UnitStat("Player", i)
		SAVED['CharacterInfo'][array[i]] = unitStat
		if V.Wrath then
			if posBuff > 0 then
				local buff = {}
				buff[array[i]] = posBuff
				table.insert(SAVED['CharacterInfo']['Buff'], buff)
			end
		end
	end
    if U.Length(SAVED['CharacterInfo']['Buff']) == 0 then
        SAVED['CharacterInfo']['Buff'] = nil
    end

    if V.Retail then
		local specializationId, specializationName, description, icon, role, classFile, className  = GetSpecializationInfoByID(GetPrimarySpecialization())
		SAVED['CharacterInfo']["UnitSpecName"] = specializationName
		SAVED['CharacterInfo']["UnitSpecId"] = specializationId
        SAVED['CharacterInfo']["ItemLevel"] = select(2, GetAverageItemLevel())
		SAVED['CharacterInfo']["UnitMastery"] = GetMastery()
	end

    if not V.Retail then
        local array = {"UnitHolyResistance", "UnitFireResistance", "UnitNatureResistance", "UnitFrostResistance", "UnitShadowResistance", "UnitArcaneResistance"}
		for i = 1, 5 do
			SAVED["CharacterInfo"][array[i]] = select(2, UnitResistance("Player", i))
		end

		SAVED['CharacterInfo']["UnitDefense"] = UnitDefense("Player")
		SAVED['CharacterInfo']["UnitAttackPower"] = UnitAttackPower("Player")
		SAVED['CharacterInfo']["UnitRangedAttackPower"] = UnitRangedAttackPower("Player")
		SAVED['CharacterInfo']["UnitCrHitMelee"] = GetCombatRatingBonus(6)
		SAVED['CharacterInfo']["UnitCrHitRanged"] = GetCombatRatingBonus(7)
		SAVED['CharacterInfo']["UnitCrHitSpell"] = GetCombatRatingBonus(8)
		SAVED['CharacterInfo']['UnitHitLevelMelee'] = GetCombatRating(6)
		SAVED['CharacterInfo']['UnitHitLevelRange'] = GetCombatRating(7)
		SAVED['CharacterInfo']['UnitHitLevelSpell'] = GetCombatRating(8) 
		SAVED['CharacterInfo']["UnitSpellBonusHealing"] = GetSpellBonusHealing()

		local unitSpellBonusDamage = 0
		for i = 1, 7 do
			local tmp = GetSpellBonusDamage(i)
			if tmp > unitSpellBonusDamage then
				unitSpellBonusDamage = tmp
			end
		end
		SAVED['CharacterInfo']["UnitSpellBonusDamage"] = unitSpellBonusDamage

		SAVED['CharacterInfo']["UnitCrWeaponSkillOffhand"] = GetCombatRatingBonus(22)
		SAVED['CharacterInfo']["UnitCrWeaponSkillRanged"] = GetCombatRatingBonus(23)
		SAVED['CharacterInfo']["UnitCrChanceMelee"] = GetCritChance()
		SAVED['CharacterInfo']["UnitCrChanceRanged"] = GetRangedCritChance()

		SAVED['CharacterInfo']["UnitCrChanceSpell"] = {}
		for i = 1, 7 do
			local spellCrChance = GetSpellCritChance(i)
			local tmp = {}
			tmp[i] = spellCrChance
			table.insert(SAVED['CharacterInfo']["UnitCrChanceSpell"], tmp)
		end
        if U.Length(SAVED['CharacterInfo']["UnitCrChanceSpell"]) == 0 then
            SAVED['CharacterInfo']['Buff'] = nil
        end

        SAVED['CharacterInfo']['MeleeArmorPenetrationLevel'] = GetCombatRating(25)
        SAVED['CharacterInfo']['MeleeArmorPenetrationRating'] = GetArmorPenetration()
        SAVED['CharacterInfo']['RangedArmorPenetrationLevel'] = GetCombatRating(25)
        SAVED['CharacterInfo']['RangedArmorPenetrationRating'] = GetArmorPenetration()
        SAVED['CharacterInfo']['SpellArmorPenetrationLevel'] = GetSpellPenetration()
        SAVED['CharacterInfo']['SpellArmorPenetrationRating'] = GetSpellPenetration()

		local minUnitDamage, maxUnitDamage = UnitDamage("player")
		SAVED['CharacterInfo']['UnitDamage'] = {
            MinUnitDamage = minUnitDamage,
            MaxUnitDamage = maxUnitDamage,
        }

		local unitRangedAttackSpeed, minUnitRangedDamage, maxUnitRangedDamage = UnitRangedDamage("player")
		SAVED['CharacterInfo']['UnitRangedDamage'] = {
            MinUnitRangedDamage = minUnitRangedDamage,
            MaxUnitRangedDamage = maxUnitRangedDamage,
        }
		SAVED['CharacterInfo']['UnitRangedAttackSpeed'] = unitRangedAttackSpeed

		SAVED['CharacterInfo']['UnitMeleeAttackSpeed'] = UnitAttackSpeed("player")

        if not (SAVED['CharacterInfo']["UnitSpecId"] or SAVED['CharacterInfo']["UnitLevel"] or SAVED['CharacterInfo']["ItemLevel"]) then
            SAVED['CharacterInfo'] = nil
        end
    end

    if not (SAVED['CharacterInfo']["UnitSex"] or SAVED['CharacterInfo']["UnitRaceId"] or SAVED['CharacterInfo']["UnitClass"] or SAVED['CharacterInfo']["UnitClassId"]) then
        SAVED['CharacterInfo'] = nil
	end
end

function HeyboxApi.GetTalentTreeRetail(SAVED)
    if not V.Retail then
		return
	end
	SAVED["TalentTreeRetail"] = {}
	local lConfigID = C_ClassTalents.GetActiveConfigID();
	if not lConfigID then
		SAVED["TalentTreeRetail"] = nil
		return
	end
	local lConfigInfo = C_Traits.GetConfigInfo(lConfigID);
	local lTreeIDs = lConfigInfo["treeIDs"];
	for i = 1, #lTreeIDs do
		for _, lNodeID in pairs(C_Traits.GetTreeNodes(lTreeIDs[i])) do
			local lNodeInfo = C_Traits.GetNodeInfo(lConfigID, lNodeID);
			if lNodeInfo.currentRank ~= 0 then
				local tmp = {}
				tmp["NodeID"] = lNodeID
				tmp["Rank"] = lNodeInfo.currentRank
				for k, v in pairs(lNodeInfo.entryIDsWithCommittedRanks) do
					local lEntryInfo = C_Traits.GetEntryInfo(lConfigID,v);
					local lDefinitionID = lEntryInfo["definitionID"];
					local lDefinitionInfo = C_Traits.GetDefinitionInfo(lDefinitionID);
					tmp["SpellID"] = lDefinitionInfo["spellID"]
				end
				table.insert(SAVED["TalentTreeRetail"], tmp)
			end
		end
	end
    if U.Length(SAVED["TalentTreeRetail"]) == 0 then
        SAVED["TalentTreeRetail"] = nil
    end
    local talents = ""
    local loaded, _ = LoadAddOn("Blizzard_ClassTalentUI")
    if loaded then
        local t = ClassTalentFrame.TalentsTab
        t:UpdateTreeInfo()
        talents = t:GetLoadoutExportString()
    end
    SAVED["TalentTreeRetailStr"] = talents
end

function HeyboxApi.GetSkillRelated(SAVED)
    if not V.Retail then
        return 
    end
    SAVED["SkillRelated"] = {}
    for i = 1, 3 do
        local PvpTalent = {}
        local tmp = C_SpecializationInfo.GetPvpTalentSlotInfo(i)
        if tmp ~= nil and tmp.selectedTalentID ~= nil then 
            local talentID, name, icon, selected, available, spellID, unlocked, row, column, known, grantedByAura = GetPvpTalentInfoByID(tmp.selectedTalentID)
            if spellID ~= nil then 
                table.insert(SAVED["SkillRelated"], {
                    SkillSpellID = spellID,
                })
            end
        end
    end
    if U.Length(SAVED["SkillRelated"]) == 0 then
        SAVED["SkillRelated"] = nil
    end
end

function HeyboxApi.GetMounts(SAVED)
    if not V.Retail then
        return
    end
    SAVED['Mounts'] = {}
    for _, id in pairs(C_MountJournal.GetMountIDs()) do
        local name, spellID, _, _, _, _, _, _, _, _, isCollected, mountID = C_MountJournal.GetMountInfoByID(id)
        if isCollected == true then
            table.insert(SAVED['Mounts'], {
                MountID = mountID,
                MountName = name,
                MountSpellID = spellID,
            })
        end
    end
    if U.Length(SAVED['Mounts']) == 0 then
        SAVED['Mounts'] = nil
    end
end

function HeyboxApi.GetClassicMounts(SAVED)
    if not V.Wrath then
       return 
    end
    SAVED['ClassicMounts'] = {}
    for i = 1, GetNumCompanions("Mount") do
        local creatureID, creatureName, creatureSpellID = GetCompanionInfo("Mount", i)
        table.insert(SAVED['ClassicMounts'], {
            CreatureID = creatureID,
            CreatureName = creatureName,
            CreatureSpellID = creatureSpellID
        })
    end
    if U.Length(SAVED['ClassicMounts']) == 0 then
        SAVED['ClassicMounts'] = nil
    end
end

function HeyboxApi.GetAchievements(SAVED)
    if V.Classic then
        return
    end
    SAVED['Achievements'] = {}
    local achievementTable = GetCategoryList()
    for k, v in pairs(achievementTable) do
        local total, _, _ = GetCategoryNumAchievements(v)
        for i = 1, total do
            local id, name, points, completed, month, day, year, description, flags,
            icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(v, i)
            if completed == true then
                table.insert(SAVED['Achievements'], {
                    AchievementID = id,
                    AchievementPoints = points,
                    AchievementName = name,
                    AchievementIcon = icon,
                    AchievementCompleteTime = "20" .. year .. "-" .. month .. "-" .. day
                })
            end
        end
    end
    SAVED['AchievementPoints'] = GetTotalAchievementPoints()
    
    if SAVED['AchievementPoints'] == 0 then
        SAVED['AchievementPoints'] = nil
    end
    if U.Length(SAVED['Achievements']) == 0 then
        SAVED['Achievements'] = nil
    end
end

function HeyboxApi.GetRunHistory(SAVED)
    if not V.Retail then
        return 
    end
    local runHistory = C_MythicPlus.GetRunHistory(true, true)
    if U.Length(runHistory) ~= 0 then
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
                    table.insert(Mythic["IntimeInfo"]["AffixIDs"], {
                        AffixID = v
                    })
                end
                Mythic["IntimeInfo"]["Members"] = {}
                for k, v in pairs(intimeInfo["members"]) do
                    table.insert(Mythic["IntimeInfo"]["Members"], {
                        Name = v["name"],
                        ClassID = v["classID"],
                    })
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
                    table.insert(Mythic["OvertimeInfo"]["AffixIDs"], {
                        AffixID = v
                    })
                end
                Mythic["OvertimeInfo"]["Members"] = {}
                for k, v in pairs(overtimeInfo["members"]) do
                    table.insert(Mythic["OvertimeInfo"]["Members"], {
                        Name = v["name"],
                        ClassID = v["classID"]
                    })
                end
            end
            table.insert(SAVED["RunHistory"], Mythic)
        end
        if U.Length(SAVED["RunHistory"]) == 0 then
            SAVED["RunHistory"] = nil
        end
    end
end

function HeyboxApi.GetReputations(SAVED)
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
    if U.Length(SAVED["Reputations"]) == 0 then
        SAVED["Reputations"] = nil
    end
end

function HeyboxApi.GetCovenant(SAVED)
    if not V.Retail then
        return 
    end
    SAVED["Covenant"] = {}
    SAVED["Covenant"]["RenownLevel"] = C_CovenantSanctumUI.GetRenownLevel()
    local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID())
    if not covenantData then
        return
    end
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
        if U.Length(soulBindInfo["CovenantSkillNodes"]) ~= 0 then
            table.insert(SAVED["Covenant"]["CovenantSkill"], soulBindInfo)
        end
    end
    if U.Length(SAVED["Covenant"]) == 0 then
        SAVED["Covenant"] = nil
    end
end

function HeyboxApi.GetCharacterTalent(SAVED)
    if V.Retail then
        return
    end
    local ok, num = pcall(getNumTalentTabs)
    if ok then
        local upload = false
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
                if rank ~= 0 then
                    upload = true
                end
                table.insert(talentTreeLeaves, characterTalent)
            end
            talentTree['TalentTreeRoot'] = talentTabName
            talentTree['TalentTreeLeaves'] = talentTreeLeaves
            table.insert(SAVED["CharacterTalent"], talentTree)
        end
        if not upload then
            SAVED["CharacterTalent"] = nil
        end
    end
end

function HeyboxApi.GetHunterPets(SAVED)
    local unitClass, _, unitClassId = UnitClass("Player")
	if unitClassId == 3 then
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
        if U.Length(SAVED["HunterPets"]) == 0 then
            SAVED["HunterPets"] = nil
        end
	end
end

function HeyboxApi.GetGlyphs(SAVED)
    if not V.Wrath then
        return
    end
    SAVED["Glyphs"] = {}
    local num = GetNumGlyphSockets()
    local talentGroup = GetActiveTalentGroup()
    for i = 1, num do
        local tmp = {}
        local a, b, c, d = GetGlyphSocketInfo(i, talentGroup)
        if b == 1 then
            tmp['Type'] = 'big'
        elseif b == 2 then
            tmp['Type'] = 'small'
        end
        tmp['SpellID'] = c
        if c == nil then
            tmp = nil
        end
        table.insert(SAVED["Glyphs"], tmp)
    end
    if U.Length(SAVED["Glyphs"]) == 0 then
        SAVED["Glyphs"] = nil
    end
end

function HeyboxApi.GetEquipments(SAVED)
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
					l = U.Length(Equipment["EquipAttribute"])
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
		if (Equipment['EquipLevel'] or Equipment["EquipAddition"] or  Equipment["EquipDurability"] or Equipment["EquipAttribute"]) then
			table.insert(SAVED["Equipments"], Equipment)
		end
	end
    if U.Length(SAVED["Equipments"]) == 0 then
        SAVED["Equipments"] = nil
    end
end

function HeyboxApi.GetToys(SAVED)
    if not V.Retail then
        return
    end
    local switch_1 = C_ToyBox.GetCollectedShown()
    local switch_2 = C_ToyBox.GetUncollectedShown()

    C_ToyBox.SetCollectedShown(true) 
    C_ToyBox.SetUncollectedShown(false)

    SAVED["Toys"] = {}
    local num = C_ToyBox.GetNumFilteredToys()
    for i = 1, num do
        local toy = {}
        local itemId = C_ToyBox.GetToyFromIndex(i)
        toy['ToyId'] = itemId
        table.insert(SAVED["Toys"], toy)
    end
    if U.Length(SAVED["Toys"]) == 0 then
        SAVED["Toys"] = nil
    end

    C_ToyBox.SetCollectedShown(switch_1) 
    C_ToyBox.SetUncollectedShown(switch_2)
end

function HeyboxApi.GetPVPInfo(SAVED)
    SAVED["PVPInfo"] = {}
	if V.Retail then
		local unitHonor = UnitHonorLevel("player")
		SAVED["PVPInfo"]["PVPUnitHonor"] = unitHonor
	end
	local honorableKills, dishonorableKills, highestRank = GetPVPLifetimeStats()
	SAVED["PVPInfo"]["PVPHonorKill"] = honorableKills

	if not V.Classic then
		SAVED["PVPInfo"]["PVPHistory"] = {}
		local nvn = {"2v2", "3v3", "5v5", "10v10"}
		local last = 4
		if V.Wrath then 
			last = 3
		end
		for i = 1, last do
			local pvpInfo = {}
			local rating, seasonBest, _, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, _, _, _, rank = GetPersonalRatedInfo(i)
			pvpInfo["Rating"] = rating
			pvpInfo["SeasonBest"] = seasonBest
			pvpInfo["SeasonPlayed"] = seasonPlayed
			pvpInfo["SeasonWon"] = seasonWon
			pvpInfo["WeeklyPlayed"] = weeklyPlayed
			pvpInfo["WeeklyWon"] = weeklyWon
			pvpInfo["Rank"] = rank
			pvpInfo["Type"] = nvn[i]

			if (pvpInfo["SeasonPlayed"] ~= 0 or pvpInfo["SeasonBest"] ~= 0 or pvpInfo["SeasonWon"] ~= 0 or pvpInfo["Rating"] ~= 0) then
				table.insert(SAVED["PVPInfo"]["PVPHistory"], pvpInfo)
			end
		end
	end
	if (not SAVED["PVPInfo"]["PVPHistory"]) or (U.Length(SAVED["PVPInfo"]["PVPHistory"]) == 0) or (not SAVED["PVPInfo"]["PVPHonorKill"]) or (SAVED["PVPInfo"]["PVPHonorKill"] == 0) then
		SAVED["PVPInfo"] = nil
	end
end

function HeyboxApi.GetPets(SAVED)
    if not V.Retail then
        return
    end
    SAVED["Pets"] = {}
    local _, petNum = C_PetJournal.GetNumPets()
    local petIndex = 1
    local rarityTable = {"Poor", "Common", "Uncommon", "Rare", "Epic", "Legendary"}
    while (petIndex <= petNum) do
        local p = {}
        local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(petIndex)
        if petID then
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
        end
        petIndex = petIndex + 1
    end
    if U.Length(SAVED["Pets"]) == 0 then
        SAVED["Pets"] = nil
    end
end

function HeyboxApi.GetMMR(SAVED)
    local isUnratedArena, isRatedArena = IsActiveBattlefieldArena()
    if (isRatedArena) then
        local battlefieldWinner = GetBattlefieldWinner()
        if (battlefieldWinner == nil) then
            return
        end

        local teamName0, oldTeamRating0, newTeamRating0, matchMakingRating0 = GetBattlefieldTeamInfo(0)
        local teamName1, oldTeamRating1, newTeamRating1, matchMakingRating1 = GetBattlefieldTeamInfo(1)

		local mmr = {}
		--Purple Team
		mmr['TeamName0'] = teamName0
		mmr['OldTeamRating0'] = oldTeamRating0
		mmr['NewTeamRating0'] = newTeamRating0
		mmr['MatchMakingRating0'] = matchMakingRating0
        --Gold Team
		mmr['TeamName1'] = teamName1
		mmr['OldTeamRating1'] = oldTeamRating1
		mmr['NewTeamRating1'] = newTeamRating1
		mmr['MatchMakingRating1'] = matchMakingRating1

		table.insert(SAVED["MMR"], mmr)
    end
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

_G.HeyboxApi = HeyboxApi