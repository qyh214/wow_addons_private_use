local Addon = select(2, ...);

TalentLoadoutEx = TalentLoadoutEx or {};

-- https://github.com/peavers/PeaversTalentsData/blob/master/docs/index.md

local peaversTalentsDataGroupNames = {
	mythic = "Mythic+",
	heroic_raid = "Raid: Heroic",
	mythic_raid = "Raid: Mythic",
};

local peaversTalentsDataPrefixes = {
	mythic = "Mythic+:\n",
	heroic_raid = "Raid(H):\n",
	mythic_raid = "Raid(M):\n",
};

local peaversTalentsDataIcons = {
	-- https://github.com/peavers-warcraft/PeaversTalentsData/blob/master/src/Data/ArchonMythicDB.lua
	mythic = {
		[0] = Addon.MYTHICPLUS_ICON,
		["All Dungeons"] = Addon.MYTHICPLUS_ICON,

		-- Midnight: Season 1
		["Algethar Academy"] = 4578414,
		["Magisters"] = 7439625,
		["Maisara Caverns"] = 7322719,
		["Nexus Point Xenas"] = 7553062,
		["Pit Of Saron"] = 343641,
		["Seat"] = 1711340,
		["Skyreach"] = 1002596,
		["Windrunner Spire"] = 7266215,
	},


	-- https://github.com/peavers-warcraft/PeaversTalentsData/blob/master/src/Data/ArchonHeroicRaidDB.lua
	raid = {
		-- Midnight: Season 1
		[0] = 7490911,
		["All Bosses"] = 7490911,
		["Imperator"] = 7448209,
		["Vorasius"] = 7448210,
		["Salhadaar"] = 7448212,
		["Vaelgor Ezzorak"] = 7448207,
		["Vanguard"] = 7448211,
		["Crown"] = 7448205,
		["Chimaerus"] = 7448202,
		["Beloren"] = 7448203,
		["Midnight Falls"] = 7448204,
	},
};

local murlokExportGroupNames = {
	["m+"]   = "Mythic+",
	["solo"] = "Solo PvP",
};

local murlokExportIcons = {
	["m+"]   = Addon.MYTHICPLUS_ICON,
	["solo"] = Addon.PVP_ICON,
};

local function AddData(dstTable, srcTable)
	if type(srcTable) == "table" and #srcTable > 0 then
		for _, data in ipairs(srcTable) do
			table.insert(dstTable, data);
		end
	end

	return dstTable;
end

-- [addon][category]
local groupCache = {};

-- [srcAddon][isCombineGroups][specID][category] = { data, data, ... }
local dataCache = {};

-- [category] = data
local peaversTalentsDataGroupCache = {};

local function GetGroupCache(srcAddon, category)
	groupCache[srcAddon] = groupCache[srcAddon] or {};
	return groupCache[srcAddon][category];
end

local function GetDataCache(srcAddon, isCombineGroupsText, specID, category)
	dataCache[srcAddon] = dataCache[srcAddon] or {};
	dataCache[srcAddon][isCombineGroupsText] = dataCache[srcAddon][isCombineGroupsText] or {};
	dataCache[srcAddon][isCombineGroupsText][specID] = dataCache[srcAddon][isCombineGroupsText][specID] or {};
	return dataCache[srcAddon][isCombineGroupsText][specID][category];
end

local function GetPeaversTalentsDataByCategory(category)
	local srcAddon = "PeaversTalentsData";
	local PeaversTalentsData = _G[srcAddon];
	local API = PeaversTalentsData and PeaversTalentsData.API;
	if not API then
		return nil;
	end

	local classID = select(2, UnitClassBase("player"));
	local specID, _, _, specIcon = PlayerUtil.GetCurrentSpecID();
	if not classID or not specID or not specIcon then
		return nil;
	end

	local option = TalentLoadoutEx.Option.Preset;
	if option.PeaversTalentsData[category] then
		local icons = peaversTalentsDataIcons[category == "mythic" and category or "raid"];
		local isCombineGroupsText = tostring(option.isCombineGroups or false);
		local presetData = GetDataCache(srcAddon, isCombineGroupsText, specID, category);
		if not presetData then
			presetData = {};

			local prefix = option.isCombineGroups and peaversTalentsDataPrefixes[category] or "";
			for _, build in ipairs(API.GetBuilds(classID, specID, "archon")) do
				if build.category == category then
					table.insert(
						presetData,
						{
							isPreset = true,
							name = prefix..build.label,
							icon = icons[build.label] or icons[0],
							text = build.talentString,
						}
					);
				end
			end

			if #presetData > 0 and not option.isCombineGroups then
				local group = GetGroupCache(srcAddon, category);
				if not group then
					group = {
						isPreset = true,
						name = "Archon: "..peaversTalentsDataGroupNames[category],
						icon = icons[0];
						isExpanded = false,
					};

					groupCache[srcAddon][category] = group;
				end

				table.insert(presetData, 1, group);
			end

			dataCache[srcAddon][isCombineGroupsText][specID][category] = presetData;
		end

		return #presetData > 0 and presetData;
	end
end

local function GetMurlokExportDataByCategory(category)
	local srcAddon = "MurlokExport";
	local MurlokExport = _G[srcAddon];
	local ClassConfig = _G["ClassConfig"];
	local categoryContent = MurlokExport and MurlokExport[category];
	if not ClassConfig or not categoryContent then
		return nil;
	end

	local classID = select(2, UnitClassBase("player"));
	local specID, _, _, specIcon = PlayerUtil.GetCurrentSpecID();
	if not classID or not specID or not specIcon then
		return nil;
	end

	local option = TalentLoadoutEx.Option.Preset;
	if option.MurlokExport[category] then
		local isCombineGroupsText = tostring(option.isCombineGroups or false);
		local presetData = GetDataCache(srcAddon, isCombineGroupsText, specID, category);
		if not presetData then
			presetData = {};

			for className, classContent in pairs(categoryContent) do
				local classInfo = ClassConfig[className];
				if classInfo.class.id == classID then
					for specName, specContent in pairs(classContent) do
						local specInfo = classInfo.specs[specName];
						if specInfo.id == specID then
							local subTreeIDs = C_ClassTalents.GetHeroTalentSpecsForClassSpec();
							if type(subTreeIDs) == "table" then
								for _, subTreeID in ipairs(subTreeIDs) do
									for _, heroContent in pairs(specContent) do
										if heroContent.id == subTreeID then
											local pvpTalents = {};
											if category == "solo" then
												for pvpTalentID, pvpTalentInfo in pairs(heroContent.traits.pvp) do
													table.insert(
														pvpTalents,
														{
															id = pvpTalentID,
															count = pvpTalentInfo.count,
														}
													);
												end

												table.sort(
													pvpTalents,
													function(a, b)
														return a.count > b.count;
													end
												);
											end

											C_ClassTalents.InitializeViewLoadout(specID, GetMaxLevelForPlayerExpansion());
											C_ClassTalents.ViewLoadout({})
											local subTreeInfo = C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, subTreeID);

											local prefix = heroContent.rating.."\n";
											if category == "m+" then
												prefix = "M+: "..prefix
											else
												prefix = "Solo: "..prefix
											end

											table.insert(
												presetData,
												{
													isPreset = true,
													name = prefix..subTreeInfo.name,
													icon = subTreeInfo.iconElementID,
													text = heroContent.talents[1],
													pvp1 = pvpTalents[1] and pvpTalents[1].id,
													pvp2 = pvpTalents[2] and pvpTalents[2].id,
													pvp3 = pvpTalents[3] and pvpTalents[3].id,
												}
											);
										end
									end
								end
							end
						end
					end
				end
			end

			if #presetData > 0 and not option.isCombineGroups then
				local group = GetGroupCache(srcAddon, category);
				if not group then
					group = {
						isPreset = true,
						name = "Murlok.io: "..murlokExportGroupNames[category],
						icon = murlokExportIcons[category],
						isExpanded = false,
					};

					groupCache[srcAddon][category] = group;
				end

				table.insert(presetData, 1, group);
			end

			dataCache[srcAddon][isCombineGroupsText][specID][category] = presetData;
		end

		return #presetData > 0 and presetData;
	end

	return nil;
end

local combinedGroups = {
	PeaversTalentsData = {
		isPreset = true,
		name = "Archon",
		isExpanded = false,
	},
	MurlokExport = {
		isPreset = true,
		name = "Murlok.io",
		isExpanded = false,
	},
};

local function GetPeaversTalentsData()
	local presetData = {};
	AddData(presetData, GetPeaversTalentsDataByCategory("mythic"));
	AddData(presetData, GetPeaversTalentsDataByCategory("heroic_raid"));
	AddData(presetData, GetPeaversTalentsDataByCategory("mythic_raid"));

	if #presetData > 0 and TalentLoadoutEx.Option.Preset.isCombineGroups then
		local combinedGroup = combinedGroups.PeaversTalentsData;
		local specIcon = select(4, PlayerUtil.GetCurrentSpecID());
		combinedGroup.icon = specIcon or Addon.DEFAULT_ICON;
		table.insert(presetData, 1, combinedGroup);
	end

	return presetData;
end

local function GetMurlokExportData()
	local presetData = {};
	AddData(presetData, GetMurlokExportDataByCategory("m+"));
	AddData(presetData, GetMurlokExportDataByCategory("solo"));

	if #presetData > 0 and TalentLoadoutEx.Option.Preset.isCombineGroups then
		local combinedGroup = combinedGroups.MurlokExport;
		local specIcon = select(4, PlayerUtil.GetCurrentSpecID());
		combinedGroup.icon = specIcon or Addon.DEFAULT_ICON;
		table.insert(presetData, 1, combinedGroup);
	end

	return presetData;
end

function Addon:GetPresetData()
	local presetData = {};

	AddData(presetData, GetPeaversTalentsData());
	AddData(presetData, GetMurlokExportData());

	return presetData;
end
