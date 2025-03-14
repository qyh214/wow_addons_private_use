local Addon = select(2, ...);

-- https://github.com/peavers/PeaversTalentsData/blob/master/docs/index.md

Addon.PresetDataAddons = {
	{
		name = "PeaversTalentsData",
		Modes = {
			"Archon",
			"Icy Veins",
			"Wowhead",
		},
		Sources = {
			["Archon"] = "archon",
			["Icy Veins"] = "icy-veins",
			["Wowhead"] = "wowhead",
		},
		Categories = {
			mythic = "M+",
			raid = "Raid",
			misc = "Misc",
		},
		Icons = {
			mythic = {
				[0] = Addon.MYTHICPLUS_ICON,
				5912508, -- Cinderbrew Meadery
				5912510, -- Darkflame Cleft
				6422372, -- Operation: Floodgate
				3025336, -- Operation: Mechagon - Workshop
				5912512, -- Priory of the Sacred Flame
				2178735, -- The MOTHERLODE!!
				5912514, -- The Rookery
				3759934, -- Theater of Pain
			},
			raid = {
				[0] = 6392621,
			},
		},
	},
};

local peaversTalentsDataCache = {};
local function GetPeaversTalentsDataCache(classID, specID, sourceName, isCombineGroups)
	local isCombineGroupsText = tostring(isCombineGroups or false);
	peaversTalentsDataCache[classID] = peaversTalentsDataCache[classID] or {};
	peaversTalentsDataCache[classID][specID] = peaversTalentsDataCache[classID][specID] or {};
	peaversTalentsDataCache[classID][specID][sourceName] = peaversTalentsDataCache[classID][specID][sourceName] or {};
	peaversTalentsDataCache[classID][specID][sourceName][isCombineGroupsText] = peaversTalentsDataCache[classID][specID][sourceName][isCombineGroupsText] or {};
	return peaversTalentsDataCache[classID][specID][sourceName][isCombineGroupsText];
end

local function GetPeaversTalentsDataIcon(category, index)
	local icons = Addon.PresetDataAddons[1].Icons;
	local categoryIcons = icons[category];
	return index and categoryIcons and categoryIcons[index];
end

local function GetPeaversTalentsData(addonIndex)
	local sourceAddonInfo = Addon.PresetDataAddons[addonIndex];
	local option = TalentLoadoutEx.Option.PeaversTalentsData;

	local sourceText = option.mode;
	local sourceName = sourceAddonInfo.Sources[sourceText];
	if not sourceName then
		return nil;
	end

	local sourceAddon = _G[sourceAddonInfo.name];
	local API = sourceAddon and sourceAddon.API;
	if not API then
		return nil;
	end

	local classID = select(2, UnitClassBase("player"));
	local specInfo = { PlayerUtil.GetCurrentSpecID() };
	if not specInfo or not specInfo[1] or not specInfo[4] then
		return nil;
	end

	local specID = specInfo[1];
	local specIconID = specInfo[4];

	local group = GetPeaversTalentsDataCache(classID, specID, sourceName, option.isCombineGroups);
	if group and #group > 0 then
		return group;
	end

	local builds, errorMsg = API.GetBuilds(classID, specID, sourceName);
	if errorMsg then
		Addon:Print("Error: PeaversTalentsData: API.GetBuilds(): ", errorMsg);
		error(errorMsg);
	end

	local categories = {};
	for _, build in ipairs(builds) do
		local categoryKey = build.category or 0;
		categories[categoryKey] = categories[categoryKey] or {};
		table.insert(categories[categoryKey], build);
	end

	local data = {};
	if option.isCombineGroups then
		-- Group: Combined
		data[1] = {
			isPreset = true,
			name = sourceText,
			icon = specIconID,
			isExpanded = false,
		};
	end

	for categoryKey, categoryBuilds in pairs(categories) do
		-- Group: Category
		if not option.isCombineGroups then
			local categoryText = categoryKey ~= 0 and sourceAddonInfo.Categories[categoryKey] or "Default";
			table.insert(
				data,
				{
					isPreset = true,
					name = sourceText..": "..categoryText,
					icon = GetPeaversTalentsDataIcon(categoryKey, 0) or specIconID,
					isExpanded = false,
				}
			);
		end

		-- Configs
		for _, build in ipairs(categoryBuilds) do
			table.insert(
				data,
				{
					isPreset = true,
					name = build.label,
					icon = GetPeaversTalentsDataIcon(categoryKey, build.dungeonID) or specIconID,
					text = build.talentString,
				}
			);
		end
	end

	peaversTalentsDataCache[classID][specID][sourceName][tostring(option.isCombineGroups)] = data;

	return data;
end

function Addon:GetPresetData()
	local index = TalentLoadoutEx.Option.PresetDataSourceAddonIndex;
	if index == 1 then
		return GetPeaversTalentsData(index);
	end
end
