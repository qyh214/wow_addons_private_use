local ADDON_NAME,Internal = ...
local L = Internal.L
local Settings = Internal.Settings

local GetSubZoneText = GetSubZoneText
local GetRealZoneText = GetRealZoneText
local GetInstanceInfo = GetInstanceInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes
local EJ_GetEncounterInfo = EJ_GetEncounterInfo

local StaticPopup_Show = StaticPopup_Show
local StaticPopup_Hide = StaticPopup_Hide

local UIDropDownMenu_SetText = UIDropDownMenu_SetText
local UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_JustifyText = UIDropDownMenu_JustifyText
local UIDropDownMenu_EnableDropDown = UIDropDownMenu_EnableDropDown;
local UIDropDownMenu_DisableDropDown = UIDropDownMenu_DisableDropDown;
local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue;
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo;

local sort = table.sort

local instanceBosses = Internal.instanceBosses;
local scenarioInfo = Internal.scenarioInfo;
local battlegroundInfo = Internal.battlegroundInfo;
local dungeonDifficultiesAll = Internal.dungeonDifficultiesAll;
local raidDifficultiesAll = Internal.raidDifficultiesAll;
local instanceDifficulties = Internal.instanceDifficulties;
local dungeonInfo = Internal.dungeonInfo;
local raidInfo = Internal.raidInfo;
local npcIDToBossID = Internal.npcIDToBossID;
local InstanceAreaIDToBossID = Internal.InstanceAreaIDToBossID;

local CONDITION_TYPE_WORLD = "none";
local CONDITION_TYPE_DUNGEONS = "party";
local CONDITION_TYPE_RAIDS = "raid";
local CONDITION_TYPE_ARENA = "arena";
local CONDITION_TYPE_BATTLEGROUND = "pvp";
local CONDITION_TYPE_SCENARIO = "scenario";
local CONDITION_TYPES = {
	CONDITION_TYPE_WORLD,
	CONDITION_TYPE_DUNGEONS,
	CONDITION_TYPE_RAIDS,
	CONDITION_TYPE_ARENA,
	CONDITION_TYPE_BATTLEGROUND,
	CONDITION_TYPE_SCENARIO
}
local CONDITION_TYPE_NAMES = {
	[CONDITION_TYPE_WORLD] = L["World"],
	[CONDITION_TYPE_DUNGEONS] = L["Dungeons"],
	[CONDITION_TYPE_RAIDS] = L["Raids"],
	[CONDITION_TYPE_ARENA] = L["Arena"],
	[CONDITION_TYPE_BATTLEGROUND] = L["Battlegrounds"],
	[CONDITION_TYPE_SCENARIO] = L["Scenarios"]
}

local function GetMapAncestor(uiMapID, mapTypes)
	if not uiMapID then
		return
	end
	local info = C_Map.GetMapInfo(uiMapID)
	if not info then
		return nil
	end
	if mapTypes == nil or mapTypes[info.mapType] then
		return info.mapID
	end
	return GetMapAncestor(info.parentMapID, mapTypes)
end
local UiMaps = {
	[1409] = 1409, [1726] = 1409, [1727] = 1409,
	[1670] = 1670, [1671] = 1670, [1672] = 1670, [1673] = 1670,
}
local function GenerateZoneTables(idToName, nameToID, uiMapID)
	local maps = C_Map.GetMapChildrenInfo(946, Enum.UIMapType.Zone, true)
	for _,map in ipairs(maps) do
		idToName[map.mapID] = map.name
		nameToID[map.name] = map.mapID
	end
	for _,mapID in pairs(UiMaps) do
		local map = C_Map.GetMapInfo(mapID)
		idToName[map.mapID] = map.name
		nameToID[map.name] = map.mapID
	end
	return idToName, nameToID
end
local ZoneIDToNameMap, ZoneNameToIDMap = GenerateZoneTables({}, {}, 946)

local activeConditionSelection;
local previousActiveConditions = {}; -- List of the previously active conditions
local activeConditions = {}; -- List of the currently active conditions profiles
local sortedActiveConditions = {};
local conditionProfilesDropDown = CreateFrame("FRAME", "BtWLoadoutsConditionProfilesDropDown", UIParent, "UIDropDownMenuTemplate");
local function ConditionProfilesDropDown_OnClick(self, arg1, arg2, checked)
	activeConditionSelection = arg1;
	UIDropDownMenu_SetText(conditionProfilesDropDown, arg1.condition.name);
end
local function ConditionProfilesDropDownInit(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    if (level or 1) == 1 then
		for _,set in ipairs(sortedActiveConditions) do
            info.text = set.condition.name;
            info.arg1 = set;
            info.func = ConditionProfilesDropDown_OnClick;
            info.checked = activeConditionSelection == set;
            UIDropDownMenu_AddButton(info, level);
        end
    end
end
function Internal.GetAciveConditionSelection()
	return activeConditionSelection
end

-- Maps condition flags to condition groups
local conditionMap = {
	instanceType = {},
	difficultyID = {},
	instanceID = {},
	uiMapID = {},
	bossID = {},
	affixID1 = {},
	affixID2 = {},
	affixID3 = {},
	affixID4 = {},
};
local function ActivateConditionMap(map, key)
	if key ~= nil and map[key] ~= nil then
		local tbl = map[key];
		for k,v in pairs(tbl) do
			tbl[k] = true;
		end
	end
end
local function DeactivateConditionMap(map, key)
	if key ~= nil and map[key] ~= nil then
		local tbl = map[key];
		for k,v in pairs(tbl) do
			tbl[k] = false;
		end
	end
end
-- As long as a set hasnt been changed it can be added multiple times
-- without causing any issues
local function AddConditionToMap(set)
	if set.profileSet ~= nil then
		local profile = Internal.GetProfile(set.profileSet);
		for k,v in pairs(set.map) do
			conditionMap[k][v] = conditionMap[k][v] or {};
			conditionMap[k][v][set] = false;
		end
	end
end
Internal.AddConditionToMap = AddConditionToMap;
local function RemoveConditionFromMap(set)
	for k,v in pairs(set.map) do
		conditionMap[k][v] = conditionMap[k][v] or {};
		conditionMap[k][v][set] = nil;
	end
end
Internal.RemoveConditionFromMap = RemoveConditionFromMap;
local function IsConditionActive(condition)
	local matchCount = 0;
	for k,v in pairs(condition.map) do
		if not conditionMap[k][v][condition] then
			return false;
		end
		matchCount = matchCount + 1;
	end

	return matchCount;
end
local function IsConditionEnabled(set)
	if set.disabled then
		return false
	end

	-- Set Defaults
	if type(set.character) ~= "table" then
		set.character = {inherit = true}
	end
	if set.character["inherit"] then
		local character = Internal.GetCharacterSlug()
		local loadout = Internal.GetProfile(set.profileSet)

		-- Set Loadout Defaults too
		if loadout and type(loadout.character) ~= "table" then
			loadout.character = {}
		end

		return loadout and (next(loadout.character) == nil or loadout.character[character] ~= nil)
	elseif next(set.character) ~= nil then
		local character = Internal.GetCharacterSlug()
		return set.character[character] ~= nil
	end

	return true
end
local function UpdateSetFilters(set)
	local filters = set.filters or {}

	local specID
	if set.profileSet then
		local profile = Internal.GetProfile(set.profileSet)
		specID = profile.specID
	end
	filters.spec = specID
	if specID then
		filters.role, filters.class = select(5, GetSpecializationInfoByID(specID))
	else
		filters.role, filters.class = nil, nil
	end

	-- Rebuild character list
	filters.character = filters.character or {}
	local characters = filters.character
	wipe(characters)

	if type(set.character) == "table" and next(set.character) ~= nil then
		if set.character.inherit then
			local loadout = Internal.GetProfile(set.profileSet)
			if loadout and type(loadout.character) == "table" and next(loadout.character) ~= nil then
				for character in pairs(loadout.character) do
					characters[#characters+1] = character
				end
			else
				local class = filters.class
				for _,character in Internal.CharacterIterator() do
					if class == nil or class == Internal.GetCharacterInfo(character).class then
						characters[#characters+1] = character
					end
				end
			end
		else
			for character in pairs(set.character) do
				characters[#characters+1] = character
			end
		end
	else
		local class = filters.class
		for _,character in Internal.CharacterIterator() do
			if class == nil or class == Internal.GetCharacterInfo(character).class then
				characters[#characters+1] = character
			end
		end
	end

	filters.instanceType = set.type
	filters.instance = set.instanceID
	filters.difficulty = set.difficultyID

	filters.disabled = set.disabled ~= true and 0 or 1

	set.filters = filters

	return set
end
-- Update a condition set with current active conditions
local function RefreshConditionSet(set)
	local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo();
	local uiMapID

	if instanceType ~= "party" and instanceType ~= "raid" and instanceType ~= "arena" and instanceType ~= "pvp" and instanceType ~= "scenario" then
		instanceType = "none"
		difficultyID = nil
		instanceID = nil
		uiMapID = UiMaps[C_Map.GetBestMapForUnit("player")]
		if not uiMapID then
			uiMapID = GetMapAncestor(C_Map.GetBestMapForUnit("player"), {[Enum.UIMapType.Zone] = true})
		end
	end

	set.type = instanceType
	set.instanceID = instanceID
	set.difficultyID = difficultyID
	set.uiMapID = uiMapID
	set.bossID = nil
	set.affixID1 = nil
	set.affixID2 = nil
	set.affixID3 = nil
	set.affixID4 = nil
	if difficultyID == 8 then -- In M+
		local affixes = GetCurrentAffixes();
		if affixes then
			-- Handle Xal'atath's Guile rearranging affixes
			if affixes[4] == 147 then
				set["affixID" .. 1] = 147
				for i=1,3 do
					set["affixID" .. (i + 1)] = affixes[i] and affixes[i].id or nil
				end
			else
				for i=1,4 do
					set["affixID" .. i] = affixes[i] and affixes[i].id or nil
				end
			end
		end
		-- if affixes then
		-- 	-- Ignore the 4th (seasonal) affix
		-- 	set.affixesID = Internal.GetAffixesInfo(affixes[1].id, affixes[2].id, affixes[3].id).id
		-- end
	else
		set.bossID = Internal.GetCurrentBoss()
	end

	UpdateSetFilters(set)

	Internal.Call("ConditionUpdated", set.setID);

	return set
end
local function AddConditionSet()
	local name = L["New Condition Set"];

    local set = {
		setID = Internal.GetNextSetID(BtWLoadoutsSets.conditions),
		name = name,
		type = CONDITION_TYPE_WORLD,
		map = {},
    };
	UpdateSetFilters(set)
    BtWLoadoutsSets.conditions[set.setID] = set;

	Internal.Call("ConditionCreated", set.setID);

    return set;
end
local function GetConditionSet(id)
    return BtWLoadoutsSets.conditions[id];
end
local function DeleteConditionSet(id)
	local set = type(id) == "table" and id or Internal.GetProfile(id);
	if set.profileSet then
		local subSet = Internal.GetProfile(set.profileSet);
		subSet.useCount = (subSet.useCount or 1) - 1;
	end
	RemoveConditionFromMap(set);

	Internal.DeleteSet(BtWLoadoutsSets.conditions, id);

	if type(id) == "table" then
		id = id.setID;
	end

	Internal.Call("ConditionDeleted", id);

	local frame = BtWLoadoutsFrame.Conditions;
	set = frame.set;
	if set.setID == id then
		frame.set = nil;
		BtWLoadoutsFrame:Update();
	end
end
local previousConditionInfo = {};
function Internal.ClearConditions()
	wipe(previousConditionInfo);
	wipe(activeConditions);
end
-- Table of Instances IDs that we want to override instanceType
local instanceTypeOverride = {
	-- Garrisons
	[1152] = "none",
	[1330] = "none",
	[1153] = "none",
	[1154] = "none",

	[1158] = "none",
	[1331] = "none",
	[1159] = "none",
	[1160] = "none",
}
function Internal.UpdateConditionsForInstance()
	local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo();
	local uiMapID
	if instanceType == "none" then
		uiMapID = UiMaps[C_Map.GetBestMapForUnit("player")]
		if not uiMapID then
			uiMapID = GetMapAncestor(C_Map.GetBestMapForUnit("player"), {[Enum.UIMapType.Zone] = true})
		end
	end

	instanceType = instanceTypeOverride[instanceID] or instanceType

	if previousConditionInfo.instanceType ~= instanceType then
		DeactivateConditionMap(conditionMap.instanceType, previousConditionInfo.instanceType);
		ActivateConditionMap(conditionMap.instanceType, instanceType);
		previousConditionInfo.instanceType = instanceType;
	end
	if previousConditionInfo.difficultyID ~= difficultyID then
		DeactivateConditionMap(conditionMap.difficultyID, previousConditionInfo.difficultyID);
		ActivateConditionMap(conditionMap.difficultyID, difficultyID);
		previousConditionInfo.difficultyID = difficultyID;
	end
	if previousConditionInfo.instanceID ~= instanceID then
		DeactivateConditionMap(conditionMap.instanceID, previousConditionInfo.instanceID);
		ActivateConditionMap(conditionMap.instanceID, instanceID);
		previousConditionInfo.instanceID = instanceID;
	end
	if previousConditionInfo.uiMapID ~= uiMapID then
		DeactivateConditionMap(conditionMap.uiMapID, previousConditionInfo.uiMapID);
		ActivateConditionMap(conditionMap.uiMapID, uiMapID);
		previousConditionInfo.uiMapID = uiMapID;
	end
end
function Internal.UpdateConditionsForBoss(unitId)
	local bossID = Internal.GetCurrentBoss(unitId) or previousConditionInfo.bossID;

	if previousConditionInfo.bossID ~= bossID then
		DeactivateConditionMap(conditionMap.bossID, previousConditionInfo.bossID);
		ActivateConditionMap(conditionMap.bossID, bossID);
		previousConditionInfo.bossID = bossID;
	end

	return bossID
end
-- Get the current boss id for conditions
function Internal.GetConditionBossID()
	return previousConditionInfo.bossID
end
function Internal.UpdateConditionsForAffixes()
	-- local affixesID;
	local affixIDs = {}
	local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo();
	if difficultyID == 23 then -- In a mythic dungeon (not M+)
		local affixes = GetCurrentAffixes();
		if affixes then
			-- Handle Xal'atath's Guile rearranging affixes
			if affixes[4] == 147 then
				affixIDs[1] = 147
				for i=1,3 do
					affixIDs[(i + 1)] = affixes[i] and affixes[i].id or nil
				end
			else
				for i=1,4 do
					affixIDs[i] = affixes[i] and affixes[i].id or nil
				end
			end
		-- 	-- Ignore the 4th (seasonal) affix
		-- 	affixesID = Internal.GetAffixesInfo(affixes[1].id, affixes[2].id, affixes[3].id).id
		end
	end

	for i=1,4 do
		local key = "affixID" .. i
		if previousConditionInfo[key] ~= affixIDs[i] then
			DeactivateConditionMap(conditionMap[key], previousConditionInfo[key]);
			ActivateConditionMap(conditionMap[key], affixIDs[i]);
			previousConditionInfo[key] = affixIDs[i];
		end
	end
	-- if previousConditionInfo.affixesID ~= affixesID then
	-- 	DeactivateConditionMap(conditionMap.affixesID, previousConditionInfo.affixesID);
	-- 	ActivateConditionMap(conditionMap.affixesID, affixesID);
	-- 	previousConditionInfo.affixesID = affixesID;
	-- end
end
local function CompareConditions(a,b)
	for k,v in pairs(a) do
		if b[k] ~= v then
			return false;
		end
	end
	for k,v in pairs(b) do
		if a[k] ~= v then
			return false;
		end
	end
	return true;
end
-- Loops through conditions and checks if they are active
local conditionMatchCount = {};
function Internal.TriggerConditions()
	-- In a Mythic Plus cant cant change anything anyway or during a boss
	if select(3,GetInstanceInfo()) == 8 or IsEncounterInProgress() then
		return;
	end

	-- Generally speaking people wont want a popup asking to switch stuff if they are editing things
	if BtWLoadoutsFrame:IsShown() or Internal.IsActivatingLoadout() then
		return;
	end

	previousActiveConditions,activeConditions = activeConditions,previousActiveConditions;
	wipe(activeConditions);
	wipe(conditionMatchCount);
	local specID = GetSpecializationInfo(GetSpecialization())
	for setID,set in pairs(BtWLoadoutsSets.conditions) do
		if type(set) == "table" and set.profileSet ~= nil and IsConditionEnabled(set) then
			local profile = Internal.GetProfile(set.profileSet);
			if (not Settings.noSpecSwitch or profile.specID == specID or profile.specID == nil) and Internal.IsLoadoutActivatable(profile) then
				local match = IsConditionActive(set);
				if match then
					activeConditions[profile] = set;
					conditionMatchCount[profile] = (conditionMatchCount[profile] or 0) + match;
				end
			end
		end
	end

	if CompareConditions(previousActiveConditions, activeConditions) then
		return
	end

	wipe(sortedActiveConditions);
	for profile,condition in pairs(activeConditions) do
		sortedActiveConditions[#sortedActiveConditions+1] = {
			profile = profile,
			condition = condition,
			match = conditionMatchCount[profile],
			specMatch = specID == profile.specID and 1 or 0
		};
	end

	if #sortedActiveConditions == 0 then
		return;
	elseif #sortedActiveConditions == 1 then
		if not Internal.IsProfileActive(sortedActiveConditions[1].profile) then
			StaticPopup_Hide("BTWLOADOUTS_REQUESTMULTIACTIVATE");
			StaticPopup_Show("BTWLOADOUTS_REQUESTACTIVATE", sortedActiveConditions[1].condition.name, nil, {
				set = sortedActiveConditions[1].profile,
				func = Internal.ActivateProfile,
			});
		end
	else
		sort(sortedActiveConditions, function(a,b)
			if a.match == b.match then
				return a.specMatch > b.specMatch;
			end
			return a.match > b.match;
		end);

		if Settings.limitConditions then
			local match = sortedActiveConditions[1].match
			for _,condition in ipairs(sortedActiveConditions) do
				if condition.match ~= match then
					break
				end

				if Internal.IsProfileActive(condition.profile) then
					return
				end
			end
		else
			local allActive = true
			for _,condition in ipairs(sortedActiveConditions) do
				if not Internal.IsProfileActive(condition.profile) then
					allActive = false
					break
				end
			end
			if allActive then
				return
			end
		end

		if not conditionProfilesDropDown.initialized then
			UIDropDownMenu_SetWidth(conditionProfilesDropDown, 170);
			UIDropDownMenu_Initialize(conditionProfilesDropDown, ConditionProfilesDropDownInit);
			UIDropDownMenu_JustifyText(conditionProfilesDropDown, "LEFT");
			conditionProfilesDropDown.initialized = true;
		end

		activeConditionSelection = sortedActiveConditions[1];
		UIDropDownMenu_SetText(conditionProfilesDropDown, activeConditionSelection.condition.name);
		StaticPopup_Hide("BTWLOADOUTS_REQUESTACTIVATE");
		StaticPopup_Show("BTWLOADOUTS_REQUESTMULTIACTIVATE", nil, nil, {
			func = Internal.ActivateProfile,
		}, conditionProfilesDropDown);
	end
end

Internal.IsConditionEnabled = IsConditionEnabled
Internal.UpdateConditionFilters = UpdateSetFilters
Internal.AddConditionSet = AddConditionSet
Internal.RefreshConditionSet = RefreshConditionSet
Internal.GetConditionSet = GetConditionSet
Internal.DeleteConditionSet = DeleteConditionSet

local function shallowcopy(tbl)
	local result = {}
	for k,v in pairs(tbl) do
		result[k] = v
	end
	return result
end

local setsFiltered = {} -- Used to filter sets in various parts of the file
local function ProfilesDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	if set.profileSet then
		local subset = Internal.GetProfile(set.profileSet);
		subset.useCount = (subset.useCount or 1) - 1;
		
		local classFile = subset.specID and select(6, GetSpecializationInfoByID(subset.specID))
		tab.temp[classFile or "NONE"] = set.character
	else
		tab.temp["NONE"] = set.character
	end

	set.profileSet = arg1;

	if set.profileSet then
		local subset = Internal.GetProfile(set.profileSet);
		subset.useCount = (subset.useCount or 0) + 1;
	
		local classFile = subset.specID and select(6, GetSpecializationInfoByID(subset.specID))
		set.character = tab.temp[classFile or "NONE"] or shallowcopy(set.character)
	else
		set.character = tab.temp["NONE"] or shallowcopy(set.character)
	end

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function ProfilesDropDown_NewOnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	if set.profileSet then
		local subset = Internal.GetProfile(set.profileSet);
		subset.useCount = (subset.useCount or 1) - 1;
	end

	local newSet = Internal.AddProfile();
	set.profileSet = newSet.setID;

	if set.profileSet then
		local subset = Internal.GetProfile(set.profileSet);
		subset.useCount = (subset.useCount or 0) + 1;
	end

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame.Profiles.set = newSet;
	PanelTemplates_SetTab(BtWLoadoutsFrame, BtWLoadoutsFrame.Profiles:GetID());

	BtWLoadoutsFrame:Update();
end
local function ProfilesDropDownInit(self, level, menuList)
	if not BtWLoadoutsSets or not BtWLoadoutsSets.profiles then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();

	local frame = BtWLoadoutsFrame -- self:GetParent():GetParent();
	local tab = BtWLoadoutsFrame.Conditions

	local set = tab.set;
	local selected = set and set.profileSet;

	if (level or 1) == 1 then
		info.text = L["None"];
		info.func = ProfilesDropDown_OnClick;
		info.checked = selected == nil;
		UIDropDownMenu_AddButton(info, level);

		wipe(setsFiltered);
		local sets = BtWLoadoutsSets.profiles;
		for setID,subset in pairs(sets) do
			if type(subset) == "table" then
				setsFiltered[subset.specID or 0] = true;
			end
		end

		local className, classFile, classID = UnitClass("player");
		local classColor = C_ClassColor.GetClassColor(classFile);
		className = classColor and classColor:WrapTextInColorCode(className) or className;

		for specIndex=1,GetNumSpecializationsForClassID(classID) do
			local specID, specName, _, icon, role = GetSpecializationInfoForClassID(classID, specIndex);
			if setsFiltered[specID] then
				info.text = format("%s: %s", className, specName);
				info.hasArrow, info.menuList = true, specID;
				info.keepShownOnClick = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, level);
			end
		end

		local playerClassID = classID;
		for classID=1,GetNumClasses() do
			if classID ~= playerClassID and GetNumSpecializationsForClassID(classID) > 0 then
				local className, classFile = GetClassInfo(classID);
				local classColor = C_ClassColor.GetClassColor(classFile);
				className = classColor and classColor:WrapTextInColorCode(className) or className;

				for specIndex=1,GetNumSpecializationsForClassID(classID) do
					local specID, specName, _, icon, role = GetSpecializationInfoForClassID(classID, specIndex);
					if setsFiltered[specID] then
						info.text = format("%s: %s", className, specName);
						info.hasArrow, info.menuList = true, specID;
						info.keepShownOnClick = true;
						info.notCheckable = true;
						UIDropDownMenu_AddButton(info, level);
					end
				end
			end
		end

		local specID = 0;
		if setsFiltered[specID] then
			info.text = L["Other"];
			info.hasArrow, info.menuList = true, nil;
			info.keepShownOnClick = true;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info, level);
		end

		info.text = L["New Set"];
		info.func = ProfilesDropDown_NewOnClick;
		info.hasArrow, info.menuList = false, nil;
		info.keepShownOnClick = false;
		info.notCheckable = true;
		info.checked = false;
		UIDropDownMenu_AddButton(info, level);
	else
		local specID = menuList;

		wipe(setsFiltered);
		local sets = BtWLoadoutsSets.profiles;
		for setID,subset in pairs(sets) do
			if type(subset) == "table" and subset.specID == specID then
				setsFiltered[#setsFiltered+1] = setID;
			end
		end
		sort(setsFiltered, function (a,b)
			return sets[a].name < sets[b].name;
		end)

		for _,setID in ipairs(setsFiltered) do
			info.text = sets[setID].name;
			info.arg1 = setID;
			info.func = ProfilesDropDown_OnClick;
			info.checked = selected == setID;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end


local function ConditionTypeDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.type = arg1;
	set.instanceID = nil;
	set.uiMapID = nil;
	set.difficultyID = nil;
	set.bossID = nil;
	set.affixesID = nil;

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function ConditionTypeDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local selected = set and set.type;

	if (level or 1) == 1 then
		for _,conditionType in ipairs(CONDITION_TYPES) do
			info.text = CONDITION_TYPE_NAMES[conditionType];
			info.arg1 = conditionType;
			info.func = ConditionTypeDropDown_OnClick;
			info.checked = selected == conditionType;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end


local function InstanceDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.instanceID = arg1;
	set.bossID = nil;

	if set.instanceID ~= nil then
		local supportedDifficulties = instanceDifficulties[set.instanceID]
		local supportsDifficulty = false;
		if not supportsDifficulty then
			for _,difficultyID in ipairs(supportedDifficulties) do
				if difficultyID == set.difficultyID then
					supportsDifficulty = true;
					break;
				end
			end
		end

		if not supportsDifficulty then
			set.difficultyID = #supportedDifficulties == 1 and supportedDifficulties[1] or nil;
		end
	end

	if set.difficultyID ~= 8 then
		set.affixesID = nil;
	end

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function InstanceDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local dungeonType = set and set.type;
	local selected = set and set.instanceID;

	if dungeonType == CONDITION_TYPE_DUNGEONS then
		if (level or 1) == 1 then
			info.text = L["Any"];
			info.func = InstanceDropDown_OnClick;
			info.checked = selected == nil;
			UIDropDownMenu_AddButton(info, level);

		-- 	for expansion,expansionData in ipairs(dungeonInfo) do
		-- 		info.text = expansionData.name;
		-- 		info.hasArrow, info.menuList = true, expansion;
		-- 		info.keepShownOnClick = true;
		-- 		info.notCheckable = true;
		-- 		UIDropDownMenu_AddButton(info, level);
		-- 	end
		-- else
			for _,instanceID in ipairs(dungeonInfo[GetExpansionLevel()+1].instances) do
				info.text = GetRealZoneText(instanceID);
				info.arg1 = instanceID;
				info.func = InstanceDropDown_OnClick;
				info.checked = selected == instanceID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	elseif dungeonType == CONDITION_TYPE_RAIDS then
		if (level or 1) == 1 then
			info.text = L["Any"];
			info.func = InstanceDropDown_OnClick;
			info.checked = selected == nil;
			UIDropDownMenu_AddButton(info, level);

		-- 	for expansion,expansionData in ipairs(dungeonInfo) do
		-- 		info.text = expansionData.name;
		-- 		info.hasArrow, info.menuList = true, expansion;
		-- 		info.keepShownOnClick = true;
		-- 		info.notCheckable = true;
		-- 		UIDropDownMenu_AddButton(info, level);
		-- 	end
		-- else
			for _,instanceID in ipairs(raidInfo[GetExpansionLevel()+1].instances) do
				info.text = GetRealZoneText(instanceID);
				info.arg1 = instanceID;
				info.func = InstanceDropDown_OnClick;
				info.checked = selected == instanceID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end


local function DifficultyDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.difficultyID = arg1;
	if arg1 == 8 then
		set.bossID = nil;
	else
		set.affixesID = nil;
	end

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function DifficultyDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local conditionType = set and set.type;
	local instanceID = set and set.instanceID;
	local selected = set and set.difficultyID;

	if instanceID == nil then
		if conditionType == CONDITION_TYPE_DUNGEONS then
			info.text = L["Any"];
			info.func = DifficultyDropDown_OnClick;
			info.checked = selected == nil;
			UIDropDownMenu_AddButton(info, level);

			for _,difficultyID in ipairs(Internal.dungeonDifficultiesAll) do
				info.text = GetDifficultyInfo(difficultyID);
				info.arg1 = difficultyID;
				info.func = DifficultyDropDown_OnClick;
				info.checked = selected == difficultyID;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif conditionType == CONDITION_TYPE_RAIDS then
			info.text = L["Any"];
			info.func = DifficultyDropDown_OnClick;
			info.checked = selected == nil;
			UIDropDownMenu_AddButton(info, level);

			for _,difficultyID in ipairs(Internal.raidDifficultiesAll) do
				info.text = GetDifficultyInfo(difficultyID);
				info.arg1 = difficultyID;
				info.func = DifficultyDropDown_OnClick;
				info.checked = selected == difficultyID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	else
		if (level or 1) == 1 then
			local difficulies = instanceDifficulties[instanceID]

			if #difficulies ~= 1 then
				info.text = L["Any"];
				info.func = DifficultyDropDown_OnClick;
				info.checked = selected == nil;
				UIDropDownMenu_AddButton(info, level);
			end

			for _,difficultyID in ipairs(difficulies) do
				info.text = GetDifficultyInfo(difficultyID);
				info.arg1 = difficultyID;
				info.func = DifficultyDropDown_OnClick;
				info.checked = selected == difficultyID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end


local function BossDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.bossID = arg1;

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function BossDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local instanceID = set and set.instanceID;
	local selected = set and set.bossID;

	if (level or 1) == 1 then
		info.text = L["Any"];
		info.func = BossDropDown_OnClick;
		info.checked = selected == nil;
		UIDropDownMenu_AddButton(info, level);

		if instanceBosses[instanceID] then
			for _,bossID in ipairs(instanceBosses[instanceID]) do
				info.text = EJ_GetEncounterInfo(bossID);
				info.arg1 = bossID;
				info.func = BossDropDown_OnClick;
				info.checked = selected == bossID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

local function ScenarioDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.instanceID = arg1;
	set.difficultyID = arg2;

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function ScenarioDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local instanceID = set and set.instanceID;
	local difficultyID = set and set.difficultyID;

	if (level or 1) == 1 then
		info.text = L["Any"];
		info.func = ScenarioDropDown_OnClick;
		info.checked = (instanceID == nil) and (difficultyID == nil);
		UIDropDownMenu_AddButton(info, level);

	-- 	for expansion,expansionData in ipairs(dungeonInfo) do
	-- 		info.text = expansionData.name;
	-- 		info.hasArrow, info.menuList = true, expansion;
	-- 		info.keepShownOnClick = true;
	-- 		info.notCheckable = true;
	-- 		UIDropDownMenu_AddButton(info, level);
	-- 	end
	-- else
		for _,details in ipairs(scenarioInfo[GetExpansionLevel()+1].instances) do
			info.text = details[3];
			info.arg1 = details[1];
			info.arg2 = details[2];
			info.func = ScenarioDropDown_OnClick;
			info.checked = (instanceID == details[1]) and (difficultyID == details[2]);
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

local function BattlegroundDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	set.instanceID = arg1;
	set.difficultyID = arg2;

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end
local function BattlegroundDropDownInit(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo();

	local set = self:GetParent().set;
	local instanceID = set and set.instanceID;

	if (level or 1) == 1 then
		info.text = L["Any"];
		info.func = BattlegroundDropDown_OnClick;
		info.checked = instanceID == nil;
		UIDropDownMenu_AddButton(info, level);

	-- 	for expansion,expansionData in ipairs(dungeonInfo) do
	-- 		info.text = expansionData.name;
	-- 		info.hasArrow, info.menuList = true, expansion;
	-- 		info.keepShownOnClick = true;
	-- 		info.notCheckable = true;
	-- 		UIDropDownMenu_AddButton(info, level);
	-- 	end
	-- else
		for _,details in ipairs(battlegroundInfo[GetExpansionLevel()+1].instances) do
			info.text = GetRealZoneText(details);
			info.arg1 = details;
			info.func = BattlegroundDropDown_OnClick;
			info.checked = instanceID == details;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

local function AffixDropDown_OnClick(self, arg1, arg2, checked)
	local tab = BtWLoadoutsFrame.Conditions

	CloseDropDownMenus();
	local set = tab.set;

	if set.affixesID ~= nil and bit.band(set.affixesID, arg2) == arg2 then
		set.affixesID = bit.band(set.affixesID, arg1);
	else
		set.affixesID = bit.bor(bit.band(set.affixesID or 0, arg1), arg2);
	end
	if set.affixesID == 0 then
		set.affixesID = nil
	end

	Internal.Call("ConditionUpdated", set.setID);

	BtWLoadoutsFrame:Update();
end

do
	BtWLoadoutsConditionsAffixesMixin = {}
	function BtWLoadoutsConditionsAffixesMixin:OnLoad()
		self.Buttons = {}

		local x = 20
		for index,level in Internal.AffixesLevels() do
			local y = -17
			local relativeTo

			local columnWidth = 0
			for _,affix in Internal.Affixes(level) do
				local name = self:GetName() .. "Button" .. affix
				local button = CreateFrame("Button", name, self, "BtWLoadoutsConditionsAffixesDropDownButton", affix);
				if relativeTo then
					button:SetPoint("TOP", relativeTo, "BOTTOM", 0, -5);
				else
					button:SetPoint("TOPLEFT", x, y);
				end

				local fullname, icons, mask = select(2, Internal.GetAffixesName(affix));
				_G[name .. "NormalText"]:SetText(icons);
				columnWidth = math.max(columnWidth, _G[name .. "NormalText"]:GetWidth())

				button.mask = mask;

				button.keepShownOnClick = true
				button.notCheckable = true
				button.arg1 = bit.bxor(0xffffffff, bit.lshift(0xff, 8*(index-1)))
				button.arg2 = bit.lshift(affix, 8*(index-1))
				button.func = AffixDropDown_OnClick

				self.Buttons[#self.Buttons+1] = button
				
				button:Show();
				relativeTo = button;
			end
			for _,affix in Internal.Affixes(level) do
				local name = self:GetName() .. "Button" .. affix
				_G[name]:SetWidth(columnWidth + 10)
			end

			x = x + columnWidth + 30
		end
		self:SetWidth(x - 40)
		self:SetHeight(5 * 20 + 32)
		hooksecurefunc("CloseDropDownMenus", function ()
			if not MouseIsOver(self) then
				self:Hide();
			end
		end)
	end
	-- Changes the buttons based on mask
	function BtWLoadoutsConditionsAffixesMixin:Update(affixesID)
		local a, b, c, d = Internal.GetAffixesForID(affixesID)
		local mask = Internal.GetExclusiveAffixes(affixesID)
		for _,button in ipairs(self.Buttons) do
			button:SetEnabled(Internal.CompareAffixMasks(button.mask, mask));
			local affixID = button:GetID()
			button.Selection:SetShown(affixID == a or affixID == b or affixID == c or affixID == d);
		end
	end
end

BtWLoadoutsConditionsMixin = {}
function BtWLoadoutsConditionsMixin:OnLoad()
	self.temp = {} -- Stores character restrictions for unselected specs
end
function BtWLoadoutsConditionsMixin:OnShow()
	if not self.initialized then
		UIDropDownMenu_SetWidth(self.LoadoutDropDown, 175);
		UIDropDownMenu_Initialize(self.LoadoutDropDown, ProfilesDropDownInit);
		UIDropDownMenu_JustifyText(self.LoadoutDropDown, "LEFT");

		self.CharacterDropDown.GetValue = function (self)
			local frame = self:GetParent()

			if type(frame.set.character) ~= "table" then
				frame.set.character = {inherit = true}
			end

			return frame.set and frame.set.character
		end
		self.CharacterDropDown.SetValue = function (self, button, arg1, arg2, checked)
			local frame = self:GetParent()
			if frame.set then
				if arg1 == nil then
					wipe(frame.set.character)
				elseif arg1 == "inherit" then
					if frame.set.character[arg1] then
						frame.set.character[arg1] = nil
					else
						wipe(frame.set.character)
						frame.set.character[arg1] = true
					end
				else
					frame.set.character["inherit"] = nil
					if frame.set.character[arg1] then
						frame.set.character[arg1] = nil
					else
						frame.set.character[arg1] = true
					end
				end

				Internal.Call("ConditionUpdated", frame.set.setID);

				BtWLoadoutsFrame:Update()
			end
		end
		UIDropDownMenu_SetWidth(self.CharacterDropDown, 175);
		UIDropDownMenu_JustifyText(self.CharacterDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.ConditionTypeDropDown, 400);
		UIDropDownMenu_Initialize(self.ConditionTypeDropDown, ConditionTypeDropDownInit);
		UIDropDownMenu_JustifyText(self.ConditionTypeDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.InstanceDropDown, 175);
		UIDropDownMenu_Initialize(self.InstanceDropDown, InstanceDropDownInit);
		UIDropDownMenu_JustifyText(self.InstanceDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.DifficultyDropDown, 175);
		UIDropDownMenu_Initialize(self.DifficultyDropDown, DifficultyDropDownInit);
		UIDropDownMenu_JustifyText(self.DifficultyDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.BossDropDown, 400);
		UIDropDownMenu_Initialize(self.BossDropDown, BossDropDownInit);
		UIDropDownMenu_JustifyText(self.BossDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.AffixesDropDown, 400);
		UIDropDownMenu_JustifyText(self.AffixesDropDown, "LEFT");

		self.AffixesDropDown.Button:SetScript("OnClick", function ()
			BtWLoadoutsConditionsAffixesDropDownList:SetShown(not BtWLoadoutsConditionsAffixesDropDownList:IsShown());
		end)

		UIDropDownMenu_SetWidth(self.ScenarioDropDown, 400);
		UIDropDownMenu_Initialize(self.ScenarioDropDown, ScenarioDropDownInit);
		UIDropDownMenu_JustifyText(self.ScenarioDropDown, "LEFT");

		UIDropDownMenu_SetWidth(self.BattlegroundDropDown, 400);
		UIDropDownMenu_Initialize(self.BattlegroundDropDown, BattlegroundDropDownInit);
		UIDropDownMenu_JustifyText(self.BattlegroundDropDown, "LEFT");

		self.initialized = true;
	end
end
function BtWLoadoutsConditionsMixin:ChangeSet(set)
    self.set = set
	wipe(self.temp);
    self:Update()
end
function BtWLoadoutsConditionsMixin:UpdateSetEnabled(value)
	if self.set and self.set.disabled ~= value then
		self.set.disabled = value;
		Internal.Call("ConditionUpdated", self.set.setID);
		self:Update();
	end
end
function BtWLoadoutsConditionsMixin:UpdateSetName(value)
	if self.set and self.set.name ~= not value then
		self.set.name = value;
		
		Internal.Call("ConditionUpdated", self.set.setID);

		self:Update();
	end
end
function BtWLoadoutsConditionsMixin:UpdateSetZone(value)
	if self.set then
		local valid = true
		if type(value) == "number" then
			self.set.uiMapID = value;
		elseif tonumber(value) then
			self.set.uiMapID = tonumber(value);
		elseif ZoneNameToIDMap[value] then
			self.set.uiMapID = ZoneNameToIDMap[value];
		elseif value ~= '' then
			self.set.uiMapID = value
			valid = false
		else
			self.set.uiMapID = nil
		end
		if valid then
			--@TODO invalid zone?
		end

		Internal.Call("ConditionUpdated", self.set.setID);

		self:Update();
	end
end
local autoCompleteList = {}
function BtWLoadoutsConditionsMixin:UpdateZoneAutoComplete(zone)
	local utf8Position = zone:GetUTF8CursorPosition()
	local text = strsub(zone:GetText(), 0, utf8Position):lower()

    wipe(autoCompleteList)
    for _,name in pairs(ZoneIDToNameMap) do
		if strsub(name, 0, utf8Position):lower() == text then
			autoCompleteList[#autoCompleteList+1] = name
		end
	end
	if #autoCompleteList == 0 then
		return
	end
	table.sort(autoCompleteList)

	local newText = autoCompleteList[1]
	if utf8Position == strlenutf8(text) and newText ~= zone:GetText() then
        zone:SetText(newText);
        zone:HighlightText(strlen(text), strlen(newText))
        zone:SetCursorPosition(strlen(text))
	end
end
function BtWLoadoutsConditionsMixin:OnButtonClick(button)
	CloseDropDownMenus()
	if button.isAdd then
		self.Name:ClearFocus();
		self:ChangeSet(AddConditionSet())
		C_Timer.After(0, function ()
			self.Name:HighlightText();
			self.Name:SetFocus();
		end);
	elseif button.isDelete then
		local set = self.set;
		StaticPopup_Show("BTWLOADOUTS_DELETESET", set.name, nil, {
			set = set,
			func = DeleteConditionSet,
		});
	elseif button.isRefresh then
		RefreshConditionSet(self.set)
		self:Update();
	end
end
function BtWLoadoutsConditionsMixin:OnSidebarItemClick(button)
	CloseDropDownMenus()
	if button.isHeader then
		button.collapsed[button.id] = not button.collapsed[button.id]
		self:Update()
	else
		self.Name:ClearFocus();
		self:ChangeSet(GetConditionSet(button.id))
	end
end
function BtWLoadoutsConditionsMixin:OnSidebarItemDoubleClick(button)
end
function BtWLoadoutsConditionsMixin:OnSidebarItemDragStart(button)
end
function BtWLoadoutsConditionsMixin:Update()
	self:GetParent():SetTitle(L["Conditions"]);
	local sidebar = BtWLoadoutsFrame.Sidebar

	sidebar:SetSupportedFilters("spec", "class", "role", "character", "instanceType", "instance", "difficulty", "disabled")
	sidebar:SetSets(BtWLoadoutsSets.conditions)
	sidebar:SetCollapsed(BtWLoadoutsCollapsed.conditions)
	sidebar:SetCategories(BtWLoadoutsCategories.conditions)
	sidebar:SetFilters(BtWLoadoutsFilters.conditions)
	sidebar:SetSelected(self.set)

	sidebar:Update()
	self.set = sidebar:GetSelected()
	local set = self.set;
	
	local showingNPE = BtWLoadoutsFrame:SetNPEShown(set == nil, L["Conditions"], L["Create conditions to notify you to change sets under specific circumstances, including raid bosses and mythic keystone dungeon affixes."])

	self:GetParent().ExportButton:SetEnabled(false)
	self:GetParent().RefreshButton:SetEnabled(true)
	self:GetParent().ActivateButton:SetEnabled(false)
	self:GetParent().DeleteButton:SetEnabled(true)

    if not showingNPE then
		-- 8 is M+ and 23 is Mythic, since we cant change specs inside a M+ we need to check trigger within the mythic but still,
		-- show in the editor as Mythic Keystone whatever.
		if set.difficultyID == 8 then
			set.mapDifficultyID = 23;
		else
			set.mapDifficultyID = set.difficultyID;
		end

		local affixID1, affixID2, affixID3, affixID4
		if set.affixesID then
			affixID1, affixID2, affixID3, affixID4 = Internal.GetAffixesForID(set.affixesID)
		end
		if set.map.instanceType ~= set.type or
		   set.map.uiMapID ~= set.uiMapID or
		   set.map.instanceID ~= set.instanceID or
		   set.map.difficultyID ~= set.mapDifficultyID or
		   set.map.bossID ~= set.bossID or

		   set.map.affixID1 ~= (affixID1 ~= 0 and affixID1 or nil) or
		   set.map.affixID2 ~= (affixID2 ~= 0 and affixID2 or nil) or
		   set.map.affixID3 ~= (affixID3 ~= 0 and affixID3 or nil) or
		   set.map.affixID4 ~= (affixID4 ~= 0 and affixID4 or nil) or

		   set.mapProfileSet ~= set.profileSet then
			RemoveConditionFromMap(set);

			set.mapProfileSet = set.profileSet; -- Used to check if we should handle the condition

			wipe(set.map);
			set.map.instanceType = set.type;
			set.map.uiMapID = set.uiMapID;
			set.map.instanceID = set.instanceID;
			set.map.difficultyID = set.mapDifficultyID;
			set.map.bossID = set.bossID;
			set.map.affixID1 = (affixID1 ~= 0 and affixID1 or nil)
			set.map.affixID2 = (affixID2 ~= 0 and affixID2 or nil)
			set.map.affixID3 = (affixID3 ~= 0 and affixID3 or nil)
			set.map.affixID4 = (affixID4 ~= 0 and affixID4 or nil)
		end

		-- Refresh filters
		UpdateSetFilters(set)
		sidebar:Update()

		if IsConditionEnabled(set) then
			AddConditionToMap(set);
		else
			RemoveConditionFromMap(set);
		end

		if not self.Name:HasFocus() then
			self.Name:SetText(set.name or "");
		end

		self.Enabled:SetChecked(not set.disabled);

		if set.profileSet == nil then
			UIDropDownMenu_SetText(self.LoadoutDropDown, L["None"]);
		else
			local subset = Internal.GetProfile(set.profileSet);
			UIDropDownMenu_SetText(self.LoadoutDropDown, subset.name);
		end

		if set.profileSet ~= nil then
			local profile = Internal.GetProfile(set.profileSet)
			local classFile = profile.specID and select(6, GetSpecializationInfoByID(profile.specID))
			if classFile and type(set.character) == "table" and not set.character["inherit"] then
				-- Filter out any characters that are not valid for the selected loadout spec
				local changed = false
				for character in pairs(set.character) do
					local characterData = Internal.GetCharacterInfo(character)
					if not characterData or characterData.class ~= classFile then
						set.character[character] = nil
						changed = true
					end
				end
				if changed then -- If we filtered out everything just default to inherit
					if next(set.character) == nil then
						set.character["inherit"] = true
					end
				end
			end
			self.CharacterDropDown:SetClass(classFile)
		else
			self.CharacterDropDown:SetClass(nil)
		end
		self.CharacterDropDown:UpdateName()

		UIDropDownMenu_SetText(self.ConditionTypeDropDown, CONDITION_TYPE_NAMES[set.type]);
		self.InstanceDropDown:SetShown(set.type == CONDITION_TYPE_DUNGEONS or set.type == CONDITION_TYPE_RAIDS);
		if set.instanceID == nil then
			UIDropDownMenu_SetText(self.InstanceDropDown, L["Any"]);
		else
			UIDropDownMenu_SetText(self.InstanceDropDown, GetRealZoneText(set.instanceID));
		end
		self.DifficultyDropDown:SetShown(set.type == CONDITION_TYPE_DUNGEONS or set.type == CONDITION_TYPE_RAIDS);
		if set.difficultyID == nil then
			UIDropDownMenu_SetText(self.DifficultyDropDown, L["Any"]);
		else
			UIDropDownMenu_SetText(self.DifficultyDropDown, GetDifficultyInfo(set.difficultyID));
		end

		-- With no instance selected, no bosses for that instance, or when M+ is selected, hide the boss drop down
		if set.instanceID == nil or Internal.instanceBosses[set.instanceID] == nil or set.difficultyID == 8 then
			self.BossDropDown:SetShown(false);
		else
			self.BossDropDown:SetShown(true);
			self.BossDropDown.Button:SetEnabled(true);

			if set.bossID == nil then
				UIDropDownMenu_SetText(self.BossDropDown, L["Any"]);
			else
				UIDropDownMenu_SetText(self.BossDropDown, EJ_GetEncounterInfo(set.bossID));
			end
		end
		if set.difficultyID ~= 8 then
			self.AffixesDropDown:SetShown(false);
		else
			self.AffixesDropDown:SetShown(true);
			self.AffixesDropDown.Button:SetEnabled(true);

			if set.affixesID == nil then
				UIDropDownMenu_SetText(self.AffixesDropDown, L["Any"]);
			else
				UIDropDownMenu_SetText(self.AffixesDropDown, select(3, Internal.GetAffixesName(set.affixesID)));
			end
			BtWLoadoutsConditionsAffixesDropDownList:Update(set.affixesID or 0)
		end
		self.ScenarioDropDown:SetShown(set.type == CONDITION_TYPE_SCENARIO);
		if set.instanceID == nil and set.difficultyID == nil then
			UIDropDownMenu_SetText(self.ScenarioDropDown, L["Any"]);
		else
			-- This isnt a good way to do this, but it'll work
			for _,details in ipairs(scenarioInfo[GetExpansionLevel()+1].instances) do
				if (set.instanceID == details[1]) and (set.difficultyID == details[2]) then
					UIDropDownMenu_SetText(self.ScenarioDropDown, details[3]);
				end
			end
		end
		self.BattlegroundDropDown:SetShown(set.type == CONDITION_TYPE_BATTLEGROUND);
		if set.instanceID == nil then
			UIDropDownMenu_SetText(self.BattlegroundDropDown, L["Any"]);
		else
			UIDropDownMenu_SetText(self.BattlegroundDropDown, GetRealZoneText(set.instanceID));
		end
		self.ZoneEditBox:SetShown(set.type == CONDITION_TYPE_WORLD);
		local zone = set.uiMapID and ZoneIDToNameMap[set.uiMapID] or set.uiMapID
		if self.ZoneEditBox:GetText() ~= zone then
			self.ZoneEditBox:SetText(zone or '');
		end

		local helpTipBox = self:GetParent().HelpTipBox;
		helpTipBox:Hide();
	else
		self.Name:SetText(L["New Condition Set"]);

		self.Enabled:SetChecked(true);
		
		UIDropDownMenu_SetText(self.LoadoutDropDown, L["None"]);
		UIDropDownMenu_SetText(self.ConditionTypeDropDown, CONDITION_TYPE_NAMES["world"]);

		self.InstanceDropDown:SetShown(false);
		self.DifficultyDropDown:SetShown(false);
		self.BossDropDown:SetShown(false);
		self.AffixesDropDown:SetShown(false);
		self.ScenarioDropDown:SetShown(false);

		local helpTipBox = self:GetParent().HelpTipBox;
		helpTipBox:Hide();
	end
end
