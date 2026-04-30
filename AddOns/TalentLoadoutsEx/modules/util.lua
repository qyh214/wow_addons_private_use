local addonName, Addon = ...;

function Addon:Print(...)
	print(format("|cff1eff00%s: |r", addonName), ...);
end

Addon.isLocked = false;
function Addon:Lock()
	Addon.isLocked = true;
	Addon:UpdatePanelButton();
end

function Addon:Unlock()
	Addon.isLocked = false;
	Addon:UpdatePanelButton();
end

function Addon:MergeTables(...)
	local mergedTable = {};
	for _, data in ipairs({...}) do
		if type(data) == "table" then
			for _, value in ipairs(data) do
				table.insert(mergedTable, value);
			end
		end
	end

	return mergedTable;
end

function Addon:GetNewName(name, isGroup, specTable)
	local nameDictionary = {};
	for _, data in pairs(specTable or Addon:GetSpecTable()) do
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

function Addon:SetTrackNode(isEnabled)
	local frame = Addon.frame;
	if isEnabled then
		frame:RegisterEvent("TRAIT_NODE_CHANGED");
	else
		frame:UnregisterEvent("TRAIT_NODE_CHANGED");
	end
end
