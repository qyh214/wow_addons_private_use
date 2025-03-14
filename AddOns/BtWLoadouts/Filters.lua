
local _,Internal = ...
local L = Internal.L

--[[ Filter Enumerators ]]
--[[
	All filter enumerators take 3 params:
	@limitations {table} that are used to filter items, currently supported: role, herotalents, character, class
	@includeLimitations {boolean} if the filtered items should be returned but flagged as filtered
	@includeOther {boolean} If an extra item on the end (called other) should be returned
	@return {function} {table} {startIndex} ipairs style
]]

local races = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 22, 25, 26, 27, 28, 29, 30, 31, 32, 34, 35, 36, 37, 52, 70, 84, 85}
local classes = {}
local specializations = {}
local herotalents = {}
do -- Build Spec List
	local _, _, classID = UnitClass("player")

	classes[#classes+1] = classID

	for specIndex=1,GetNumSpecializationsForClassID(classID) do
		local specID = GetSpecializationInfoForClassID(classID, specIndex)
		specializations[#specializations+1] = specID
	end
	for _,treeID in ipairs(Internal.GetHeroTalentTreeIDsByClassID(classID)) do
		herotalents[#herotalents+1] = treeID
	end

	local playerClassID = classID;
	for classIndex=1,GetNumClasses() do
		if classIndex ~= playerClassID and GetNumSpecializationsForClassID(classID) > 0 then
			classes[#classes+1] = classIndex

			local _, _, classID = GetClassInfo(classIndex)
			for specIndex=1,GetNumSpecializationsForClassID(classID) do
				local specID = GetSpecializationInfoForClassID(classID, specIndex);
				specializations[#specializations+1] = specID
			end
			
			for _,treeID in ipairs(Internal.GetHeroTalentTreeIDsByClassID(classID)) do
				herotalents[#herotalents+1] = treeID
			end
		end
	end
	
	function Internal.SortClassesByName()
		table.sort(classes, function (a, b)
			if a == playerClassID and b ~= playerClassID then
				return true
			elseif b == playerClassID and a ~= playerClassID then
				return false
			end
			return C_CreatureInfo.GetClassInfo(a).className < C_CreatureInfo.GetClassInfo(b).className
		end)

		wipe(specializations)
		for _,classID in ipairs(classes) do
			for specIndex=1,GetNumSpecializationsForClassID(classID) do
				local specID = GetSpecializationInfoForClassID(classID, specIndex);
				specializations[#specializations+1] = specID
			end
		end
	end
	function Internal.SortClassesByID()
		table.sort(classes, function (a, b)
			if a == playerClassID and b ~= playerClassID then
				return true
			elseif b == playerClassID and a ~= playerClassID then
				return false
			end
			return a < b
		end)

		wipe(specializations)
		for _,classID in ipairs(classes) do
			for specIndex=1,GetNumSpecializationsForClassID(classID) do
				local specID = GetSpecializationInfoForClassID(classID, specIndex);
				specializations[#specializations+1] = specID
			end
		end
	end
end
local instanceTypeEnumeratorList = {
	{ "party", L["Dungeon"], },
	{ "raid", L["Raid"], }, { "arena", L["Arena"], },
	{ "pvp", L["Battleground"], },
	{ "scenario", L["Scenarios"], },
	{ "none", L["World"], }
}
local disabledEnumeratorList = {
	{ 0, L["Enabled"], },
	{ 1, L["Disabled"], },
}
local roleEnumertorList = {}
do -- Build role list
	for _,role in Internal.Roles() do
		roleEnumertorList[#roleEnumertorList+1] = { role, _G[role] }
	end
end
local instances = {}
do
    for _,expansion in ipairs(Internal.raidInfo) do
        for _,instanceID in ipairs(expansion.instances) do
            instances[#instances+1] = instanceID
        end
    end
    for _,expansion in ipairs(Internal.dungeonInfo) do
        for _,instanceID in ipairs(expansion.instances) do
            instances[#instances+1] = instanceID
        end
    end
end
local difficulties = {220, 17, 14, 15, 16, 205, 1, 2, 23, 8}
local bosses = {}
do
    for _,instanceID in ipairs(instances) do
        for _,bossID in ipairs(Internal.instanceBosses[instanceID]) do
            bosses[#bosses+1] = bossID
        end
    end
end
local charaterEnumertorList = {} -- Reused for building character lists
Internal.Filters = {
	covenant = {
		name = L["Covenant"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					local covenantData = C_Covenants.GetCovenantData(tbl[index])
					return index, tbl[index], COVENANT_COLORS[covenantData.textureKit]:WrapTextInColorCode(covenantData.name)
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, {1, 2, 3, 4}, 0
		end,
	},
	race = {
		name = L["Race"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, tbl[index], GetFactionColor(C_CreatureInfo.GetFactionInfo(tbl[index]).groupTag):WrapTextInColorCode(C_CreatureInfo.GetRaceInfo(tbl[index]).raceName)
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, races, 0
		end,
	},
	class = {
		name = L["Class"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					local classInfo = C_CreatureInfo.GetClassInfo(tbl[index])
					local classColor = C_ClassColor.GetClassColor(classInfo.classFile)
					return index, classInfo.classFile, classColor:WrapTextInColorCode(classInfo.className)
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, classes, 0
		end,
	},
	spec = {
		name = L["Specialization"],
        -- limitations: role, herotalents, character, class
		enumerate = function (limitations, includeLimitations, includeOther)
			local limitRole, limitHeroTalents, limitClassFile
			if limitations then
				limitRole = limitations.role
				if limitations.herotalents then
					limitHeroTalents = limitations.herotalents
					local classData = C_CreatureInfo.GetClassInfo(Internal.GetClassIDByHeroTalentTreeID(limitations.herotalents))
					limitClassFile = classData.classFile
				elseif limitations.character then
					local characterData = Internal.GetCharacterInfo(limitations.character)
					limitClassFile = characterData.class
				elseif limitations.class then
					local classData = C_CreatureInfo.GetClassInfo(limitations.class)
					limitClassFile = classData.classFile
				end
			end

			return function (tbl, index)
				repeat
					index = index + 1
				until not tbl[index] or includeLimitations or (
					(limitClassFile == nil or limitClassFile == (select(6, GetSpecializationInfoByID(tbl[index])))) and
					(limitHeroTalents == nil or Internal.IsHeroTalentTreeValidForSpecID(limitHeroTalents, tbl[index])) and
					(limitRole == nil or limitRole == (select(5, GetSpecializationInfoByID(tbl[index]))))
				)

				if tbl[index] then
					local _, specName, _, _, role, classFile, className = GetSpecializationInfoByID(tbl[index])
					local classColor = C_ClassColor.GetClassColor(classFile);
					local name = format("%s - %s", classColor:WrapTextInColorCode(className), specName)

					return index, tbl[index], name, not (
						(limitClassFile == nil or limitClassFile == classFile) and
						(limitHeroTalents == nil or Internal.IsHeroTalentTreeValidForSpecID(limitHeroTalents, tbl[index])) and
						(limitRole == nil or limitRole == role)
					)
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, specializations, 0
		end,
	},
	herotalents = {
		name = L["Hero Talents"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1

				if tbl[index] then
					local tree = C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, tbl[index])
					local class = C_CreatureInfo.GetClassInfo(Internal.GetClassIDByHeroTalentTreeID(tbl[index]))
					local classColor = C_ClassColor.GetClassColor(class.classFile);
					local name = format("%s - %s", classColor:WrapTextInColorCode(class.className), tree.name)

					return index, tbl[index], name
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, herotalents, 0
		end,
	},
	role = {
		name = L["Role"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, unpack(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, roleEnumertorList, 0
		end,
	},
	character = {
		name = L["Character"],
		enumerate = function (limitations, includeLimitations, includeOther)
			wipe(charaterEnumertorList)

			local name = UnitName("player")
			local character = Internal.GetCharacterSlug();
			local characterInfo = Internal.GetCharacterInfo(character);
			if characterInfo then
				local classColor = C_ClassColor.GetClassColor(characterInfo.class);
				name = format("%s - %s", classColor:WrapTextInColorCode(characterInfo.name), characterInfo.realm);
			end
			charaterEnumertorList[#charaterEnumertorList+1] = {character, name}

			local playerCharacter = character
			for _,character in Internal.CharacterIterator() do
				if playerCharacter ~= character then
					local characterInfo = Internal.GetCharacterInfo(character);
					if characterInfo then
						local classColor = C_ClassColor.GetClassColor(characterInfo.class);
						name = format("%s - %s", classColor:WrapTextInColorCode(characterInfo.name), characterInfo.realm);
					end
					charaterEnumertorList[#charaterEnumertorList+1] = {character,name}
				end
			end

			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, unpack(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, charaterEnumertorList, 0
		end,
	},
	instanceType = {
		name = L["Instance Type"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, unpack(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, instanceTypeEnumeratorList, 0
		end,
	},
	instance = {
		name = L["Instance"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, tbl[index], GetRealZoneText(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, instances, 0
		end,
	},
	difficulty = {
		name = L["Difficulty"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, tbl[index], GetDifficultyInfo(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, difficulties, 0
		end,
	},
	boss = {
		name = L["Boss"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, tbl[index], EJ_GetEncounterInfo(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, bosses, 0
		end,
	},
	disabled = {
		name = L["Enabled"],
		enumerate = function (limitations, includeLimitations, includeOther)
			return function (tbl, index)
				index = index + 1
				if tbl[index] then
					return index, unpack(tbl[index])
				elseif includeOther and index == #tbl + 1 then
					return index, 0, L["Other"]
				end
			end, disabledEnumeratorList, 0
		end,
	},
}
