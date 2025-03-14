local addonName, Addon = ...;

TalentLoadoutEx = TalentLoadoutEx or {};

local localizedClass, englishClass = UnitClass("player");
Addon.className = localizedClass;
Addon.classColor = RAID_CLASS_COLORS[englishClass];

function Addon:GetSpecTable(class, spec)
	class = class or englishClass;
	spec = spec or GetSpecialization();
	TalentLoadoutEx[class] = TalentLoadoutEx[class] or {};
	TalentLoadoutEx[class][spec] = TalentLoadoutEx[class][spec] or {};
	return TalentLoadoutEx[class][spec];
end

function Addon:GetDataByName(name)
	for _, data in ipairs(Addon:GetSpecTable()) do
		if name and #name > 0 and name == data.name then
			return data;
		end
	end

	return nil;
end

function Addon:GetData(index)
	return Addon:MergeTables(Addon:GetSpecTable(), Addon:GetPresetData())[index or Addon.selectedIndex];
end

local loadoutEntryDictionaryCache = {};
local function GetCompareLoadoutInfo(text, configID)
	local loadoutEntryDictionary = loadoutEntryDictionaryCache[text];
	if loadoutEntryDictionary then
		return loadoutEntryDictionary;
	end

	loadoutEntryDictionary = {};
	local loadoutEntryInfo = Addon:GetLoadoutEntryInfo(text, configID);
	if loadoutEntryInfo then
		for _, entry in pairs(loadoutEntryInfo) do
			loadoutEntryDictionary[entry.nodeID] = entry;
		end
	end

	return loadoutEntryDictionary;
end

function Addon:IsTextLoaded(text)
	local current = Addon:GetExportText();
	if not current or #current == 0 then
		return false;
	elseif current == text then
		return true;
	else
		local configID = C_ClassTalents.GetActiveConfigID();
		local loadoutEntryDictionary = GetCompareLoadoutInfo(current, configID);
		local loadoutEntryInfo = Addon:GetLoadoutEntryInfo(text, configID);
		if loadoutEntryInfo then
			for _, entry in pairs(loadoutEntryInfo) do
				local currentEntry = loadoutEntryDictionary[entry.nodeID];
				if not currentEntry or entry.ranksGranted ~= currentEntry.ranksGranted or entry.selectionEntryID ~= currentEntry.selectionEntryID or entry.ranksPurchased ~= currentEntry.ranksPurchased then
					return false;
				end
			end
		end

		return true;
	end
end

function Addon:IsDataLoaded(data)
	if TalentLoadoutEx.Option.IsEnabledPvp then
		for index, current in ipairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do
			local pvpTalentID = tonumber(data["pvp"..index]);
			if pvpTalentID and pvpTalentID ~= current then
				return false;
			end
		end
	end

	return Addon:IsTextLoaded(data.text);
end

local function SetPvpTalent(slot, pvpTalentID)
	if pvpTalentID and (GetPvpTalentInfoByID(pvpTalentID)) then
		LearnPvpTalent(tonumber(pvpTalentID), slot); ---@diagnostic disable-line: redundant-parameter
	end
end

function Addon:SetPvpTalent(pvpTalentID1, pvpTalentID2, pvpTalentID3)
	if not TalentLoadoutEx.Option.IsEnabledPvp then
		return;
	end

	local isUIErrorsFrameShown = UIErrorsFrame and UIErrorsFrame:IsShown();
	if isUIErrorsFrameShown then
		UIErrorsFrame:Hide();
		C_Timer.After(
			1,
			function()
				UIErrorsFrame:Clear();
				UIErrorsFrame:Show();
			end
		);
	end

	SetPvpTalent(3, pvpTalentID3 or pvpTalentID1);
	SetPvpTalent(2, pvpTalentID2 or pvpTalentID1);
	SetPvpTalent(1, pvpTalentID1);
end

function Addon:LoadConfig()
	local data = Addon:GetData();
	if data then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
		if data.isLegacy then
			Addon:Print("Legacy format text is obsolated.");
		else
			Addon:ImportTextAsync(data.text);
			Addon:SetPvpTalent(data.pvp1, data.pvp2, data.pvp3);
			Addon:SendUpdateMessage();
		end
	end
end

function Addon:SavePvpTalent(pvpTalentID1, pvpTalentID2, pvpTalentID3)
	if not TalentLoadoutEx.Option.IsEnabledPvp then
		return;
	end

	local data = Addon:GetData();
	if data then
		data.pvp1 = pvpTalentID1;
		data.pvp2 = pvpTalentID2;
		data.pvp3 = pvpTalentID3;
	end
end

function Addon:SaveConfig(text)
	text = text and #text > 0 and text or Addon:GetExportText();
	local data = Addon:GetData();
	if text and data then
		data.text = text;
		data.isLegacy = nil;

		if TalentLoadoutEx.Option.IsEnabledPvp then
			Addon:SavePvpTalent(unpack(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()));
		end
	end
end

-- Swap group1 and group2.
local function SwapGroupOrder(groupIndex1, groupIndex2, groupIndex3)
	local specTable = Addon:GetSpecTable();
	for _ = 1, groupIndex2 - groupIndex1 do
		if groupIndex3 then
			table.insert(specTable, groupIndex3, specTable[groupIndex1]);
		else
			table.insert(specTable, specTable[groupIndex1]);
		end

		table.remove(specTable, groupIndex1);
	end
end

function Addon:MoveUp()
	if Addon.selectedIndex and Addon.selectedIndex > 1 then
		local specTable = Addon:GetSpecTable();
		local target = specTable[Addon.selectedIndex];

		if target.text then
			-- Config
			specTable[Addon.selectedIndex] = specTable[Addon.selectedIndex - 1];
			specTable[Addon.selectedIndex - 1] = target;

			local preGroupIndex = nil;
			for index = 1, Addon.selectedIndex - 2 do
				local data = specTable[index];
				if not data.text then
					preGroupIndex = index;
				end
			end

			if preGroupIndex then
				specTable[preGroupIndex].isExpanded = true;
			end

			Addon.selectedIndex = Addon.selectedIndex - 1;
		else
			-- Group
			local groupIndex1 = nil;
			local groupIndex2 = Addon.selectedIndex;
			local groupIndex3 = nil;

			for index, data in ipairs(specTable) do
				if not data.text then
					if index < Addon.selectedIndex then
						groupIndex1 = index;
					elseif index > Addon.selectedIndex then
						groupIndex3 = index;
						break;
					end
				end
			end

			if groupIndex1 then
				SwapGroupOrder(groupIndex1, groupIndex2, groupIndex3);
				Addon.selectedIndex = groupIndex1;
			end
		end

		Addon:RequestUpdate();
	end
end

function Addon:MoveDown()
	local specTable = Addon:GetSpecTable();
	if Addon.selectedIndex and Addon.selectedIndex < #specTable then
		local target = specTable[Addon.selectedIndex];

		if target.text then
			-- Config
			specTable[Addon.selectedIndex] = specTable[Addon.selectedIndex + 1];
			specTable[Addon.selectedIndex + 1] = target;

			if not specTable[Addon.selectedIndex].text then
				specTable[Addon.selectedIndex].isExpanded = true;
			end

			Addon.selectedIndex = Addon.selectedIndex + 1;
		else
			-- Group
			local groupIndex1 = Addon.selectedIndex;
			local groupIndex2 = nil;
			local groupIndex3 = nil;

			for index, data in ipairs(specTable) do
				if not data.text then
					if index > Addon.selectedIndex then
						if not groupIndex2 then
							groupIndex2 = index;
						else
							groupIndex3 = index;
							break;
						end
					end
				end
			end

			if groupIndex2 then
				SwapGroupOrder(groupIndex1, groupIndex2, groupIndex3);
				Addon.selectedIndex = groupIndex1 + (groupIndex3 or #specTable + 1) - groupIndex2;
			end
		end

		Addon:RequestUpdate();
	end
end

function Addon:DeleteData()
	local specTable = Addon:GetSpecTable();
	local data = Addon.selectedIndex and specTable[Addon.selectedIndex];
	if data then
		table.remove(specTable, Addon.selectedIndex);
		table.wipe(data);
	end

	if not specTable[Addon.selectedIndex] then
		Addon.selectedIndex = nil;
	end
end

local function GetNewName(name, isGroup)
	local nameDictionary = {};
	local specTable = Addon:GetSpecTable();
	for _, data in ipairs(specTable) do
		nameDictionary[data.name] = true;
	end

	local prefix = name and #name > 0 and name or (isGroup and "New Group" or "New Config");
	if not nameDictionary[prefix] then
		return prefix;
	end

	local number = 1
	while true do
		number = number + 1;
		local newName = string.format("%s %02d", prefix, number);
		if not nameDictionary[newName] then
			return newName;
		end
	end
end

local function GetImportDataList(lines)
	local tempDataList = {};

	local tempData = {};
	for line in lines:gmatch("([^\r\n]*)[\r\n]?") do
		if line:match("^# ?") then
			line = line:gsub("^# ?", "");
			if not tempData.name then
				tempData.name = line
			else
				for text in line:gmatch("([^/]+)") do
					if not tempData.icon then
						local iconID = tonumber(text);
						if tostring(iconID) == text then
							tempData.icon = iconID;
						else
							tempData.icon = text;
						end
					elseif not tempData.pvp1 then
						tempData.pvp1 = tonumber(text);
					elseif not tempData.pvp2 then
						tempData.pvp2 = tonumber(text);
					else
						tempData.pvp3 = tonumber(text);
					end
				end
			end
		else
			if #line > 0 then
				-- Config
				tempData.text = line;
				table.insert(tempDataList, tempData);
			elseif tempData.name then
				table.insert(tempDataList, tempData);
			else
				-- Blank line
			end

			tempData = {};
		end
	end

	if tempData.name then
		table.insert(tempDataList, tempData);
	end

	return tempDataList;
end

function Addon:ImportDataText(lines)
	local specTable = Addon:GetSpecTable();

	local isInGroup = false;
	local currentText = Addon:GetExportText();
	for index, tempData in ipairs(GetImportDataList(lines)) do
		if tempData.text then
			-- Config
			local data = {
				name = GetNewName(tempData.name),
				icon = tempData.icon or Addon.DEFAULT_ICON,
				pvp1 = tempData.pvp1,
				pvp2 = tempData.pvp2,
				pvp3 = tempData.pvp3,
				text = tempData.text,
			};

			if not data.pvp1 then
				data.pvp1, data.pvp2, data.pvp3 = unpack(C_SpecializationInfo.GetAllSelectedPvpTalentIDs());
			end

			if isInGroup then
				table.insert(specTable, data);
			else
				table.insert(specTable, index, data);
			end
		else
			-- Group
			table.insert(
				specTable,
				{
					name = GetNewName(tempData.name, true),
					icon = tempData.icon or Addon.DEFAULT_ICON,
					isExpanded = false;
				}
			);

			isInGroup = true;
		end
	end

	Addon:ImportText(currentText);
end

function Addon:GetSpecDataText()
	local text = "";
	local specTable = Addon:GetSpecTable();
	for _, data in ipairs(specTable) do
		if not data.text then
			-- Group
			text = string.format("%s# %s\n# %s\n\n", text, data.name, data.icon);
		elseif not data.isLegacy then
			-- Config
			-- Legacy data cannot cxport.
			text = string.format("%s# %s\n# %s", text, data.name, data.icon);

			if TalentLoadoutEx.Option.IsEnabledPvp then
				text = data.pvp1 and string.format("%s/%s", text, data.pvp1) or text;
				text = data.pvp2 and string.format("%s/%s", text, data.pvp2) or text;
				text = data.pvp3 and string.format("%s/%s", text, data.pvp3) or text;
			end

			text = string.format("%s\n%s\n\n", text, data.text);
		end
	end

	return text;
end

function Addon:UpdateData()
	-- Add Option
	TalentLoadoutEx.Option = TalentLoadoutEx.Option or {};
	if TalentLoadoutEx.Option.IsEnabledPvp == nil then
		TalentLoadoutEx.Option.IsEnabledPvp = true;
	end

	-- Add Preset Data Addons Option
	TalentLoadoutEx.Option.PresetDataSourceAddonIndex = TalentLoadoutEx.Option.PresetDataSourceAddonIndex or 0;
	TalentLoadoutEx.Option.PeaversTalentsData = TalentLoadoutEx.Option.PeaversTalentsData or {};
	TalentLoadoutEx.Option.PeaversTalentsData.mode = TalentLoadoutEx.Option.PeaversTalentsData.mode or "Archon";
	TalentLoadoutEx.Option.PeaversTalentsData.isCombineGroups = TalentLoadoutEx.Option.PeaversTalentsData.isCombineGroups or false;

	-- Remove nil data
	-- Fix PvP Talent ID
	-- Remove unused parameter
	for className, classTable in pairs(TalentLoadoutEx) do
		if className ~= "Option" then
			for specIndex, specTable in ipairs(classTable) do
				local fixedTable = {};

				-- Don't use ipairs because of a bug that can cause nil data to be mixed in.
				for _, data in pairs(specTable) do
					data.pvp1 = tonumber(data.pvp1);
					data.pvp2 = tonumber(data.pvp2);
					data.pvp3 = tonumber(data.pvp3);
					data.isInGroup = nil;
					table.insert(fixedTable, data);
				end

				classTable[specIndex] = fixedTable;
			end
		end
	end
end

function Addon:InspectImport()
	local newData = {
		icon = 133023, -- https://www.wowhead.com/icon=133023/inv-gizmo-newgoggles
		isInGroup = false,
	};

	local specTable = nil;
	local classFilename, classID = select(2, UnitClass("target"));
	if classFilename and classID then
		local specID = GetInspectSpecialization("target");
		for specIndex = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
			if specID == GetSpecializationInfoForClassID(classID, specIndex) then
				specTable = Addon:GetSpecTable(classFilename, specIndex);
			end
		end
	end

	if not specTable then
		Addon:Print("Error: Failed to get the unit class/spec info.");
		return;
	end

	local parent = Addon.ParentFrame;
	local text = parent:GetInspectUnit() and C_Traits.GenerateInspectImportString(parent:GetInspectUnit()) or parent:GetInspectString();
	if text and #text > 0 then
		newData.text = text;
	else
		Addon:Print("Error: Failed to inspect the talent string.");
		return;
	end

	local unitName = UnitName("target");
	if unitName and #unitName > 0 then
		newData.name = "Imported from "..unitName;
	else
		Addon:Print("Error: Failed to get the unit name.");
		return;
	end

	for talentIndex = 1, 3 do
		newData["pvp"..talentIndex] = C_SpecializationInfo.GetInspectSelectedPvpTalent("target", talentIndex);
	end

	-- Update
	for _, data in pairs(specTable) do
		if data.name == newData.name then
			if data.text then
				data.text = newData.text;
				data.pvp1 = newData.pvp1;
				data.pvp2 = newData.pvp2;
				data.pvp3 = newData.pvp3;
				Addon:Print("Success:", newData.name, "(Update)");
				return;
			else
				Addon:Print("Error: Cannot import because a group with the same name already exists.");
				return;
			end
		end
	end

	-- Add
	table.insert(specTable, 1, newData);
	Addon:Print("Success:", newData.name);
end

Addon:RegisterAddonLoad(addonName, true, "UpdateData");
