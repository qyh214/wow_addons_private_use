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

function Addon:CopyTable(data)
	local copiedData = {};
	for key, value in pairs(data) do
		copiedData[key] = value;
	end

	return copiedData;
end
