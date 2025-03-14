local addonName, Addon = ...;

local function ConvertToImportLoadoutEntryInfo(specID, configID, treeID, loadoutContent)
	local loadoutEntryInfo = Addon.TalentsFrame:ConvertToImportLoadoutEntryInfo(configID, treeID, loadoutContent);
	local nodeOrder = Addon:GetNodeOrder(specID, configID, treeID);
	table.sort(
		loadoutEntryInfo,
		function(a, b)
			return nodeOrder[a.nodeID] < nodeOrder[b.nodeID];
		end
	);

	return loadoutEntryInfo;
end

local function CommitTalent(configID)
	if configID and Addon.ApplyButton.isShown and Addon.ApplyButton.isEnabled then
		-- When applying Talent from an addon, a taint error may occur.
		-- If there are too many reports of this occurring, I will discontinue this feature.
		-- Addon.TalentsFrame:CommitConfig();

		-- It looks a little worse than it is, but this one does not cause taint error.
		C_Traits.CommitConfig(configID);
	end
end

local loadoutEntryInfoCache = {};
local starterBuildDeactiveFrame = CreateFrame("Frame");
function Addon:GetLoadoutEntryInfo(importText, configID)
	local loadoutEntryInfo = loadoutEntryInfoCache[importText];
	if loadoutEntryInfo then
		return loadoutEntryInfo;
	end

	local talentsFrame = Addon.TalentsFrame;
	local specID = PlayerUtil.GetCurrentSpecID();
	local treeID = C_ClassTalents.GetTraitTreeForSpec(specID);
	if not treeID then
		Addon:Print("Error: C_ClassTalents.GetTraitTreeForSpec() = nil");
		return false;
	end

	local importStream = ExportUtil.MakeImportDataStream(importText);

	local errorMessage = Addon:GetValidationError(treeID, importStream);
	if errorMessage then
		Addon:Print(errorMessage);
		return false;
	end

	if C_ClassTalents.GetStarterBuildActive() then
		local eventName = "TRAIT_CONFIG_UPDATED";
		starterBuildDeactiveFrame:RegisterEvent(eventName);
		starterBuildDeactiveFrame:SetScript(
			"OnEvent",
			function(_, event, ...)
				if event == eventName and (...) == configID then
					starterBuildDeactiveFrame:UnregisterAllEvents();
					Addon:ImportTextAsync(importText);
				end
			end
		);

		C_ClassTalents.SetStarterBuildActive(false);
		return false;
	end

	local loadoutContent = talentsFrame:ReadLoadoutContent(importStream, treeID);
	loadoutEntryInfoCache[importText] = ConvertToImportLoadoutEntryInfo(specID, configID, treeID, loadoutContent);
	return loadoutEntryInfoCache[importText];
end

local function ResetTree()
	local configID = C_ClassTalents.GetActiveConfigID();
	if not configID then
		Addon:Print("Error: C_ClassTalents.GetActiveConfigID() = nil");
		return false;
	end

	local specID = PlayerUtil.GetCurrentSpecID();
	local treeID = C_ClassTalents.GetTraitTreeForSpec(specID);
	if not treeID then
		Addon:Print("Error: C_ClassTalents.GetTraitTreeForSpec() = nil");
		return false;
	end

	C_Traits.ResetTree(configID, treeID);
	return true;
end

function Addon:ImportText(importText)
	local configID = C_ClassTalents.GetActiveConfigID();
	if not configID then
		Addon:Print("Error: C_ClassTalents.GetActiveConfigID() = nil");
		return false;
	end

	if Addon:IsTextLoaded(importText) then
		CommitTalent(configID);
		return false;
	end

	local loadoutEntryInfo = Addon:GetLoadoutEntryInfo(importText, configID);
	if not loadoutEntryInfo then
		return;
	end

	local hasError = false;
	Addon.isLocked = true;

	if not ResetTree() then
		return;
	end

	for _, entry in ipairs(loadoutEntryInfo) do
		local result = true;
		local errorRank = nil;
		local nodeInfo = C_Traits.GetNodeInfo(configID, entry.nodeID);
		if nodeInfo.type == Enum.TraitNodeType.Single or nodeInfo.type == Enum.TraitNodeType.Tiered then
			for rank = 1, entry.ranksPurchased do
				result = C_Traits.PurchaseRank(configID, entry.nodeID);
				if not result then
					errorRank = rank;
					break;
				end
			end
		else
			-- Enum.TraitNodeType.Selection or Enum.TraitNodeType.SubTreeSelection
			result = C_Traits.SetSelection(configID, entry.nodeID, entry.selectionEntryID);
		end

		if not result then
			hasError = true;
			local entryInfo = entry.selectionEntryID and C_Traits.GetEntryInfo(configID, entry.selectionEntryID);
			local definitionInfo = entryInfo and entryInfo.definitionID and C_Traits.GetDefinitionInfo(entryInfo.definitionID);

			if definitionInfo then
				local name = definitionInfo.overrideName;
				if not name then
					local spellInfo = definitionInfo.spellID and C_Spell.GetSpellInfo(definitionInfo.spellID);
					name = spellInfo and spellInfo.name;
				end

				if not name then
					Addon:Print("Error: Loadout entry cannot use.");
					DevTools_Dump(entry);
					break;
				elseif errorRank and entry.ranksPurchased > 1 then
					Addon:Print(string.format("Cannot Learn: %s (%d)", name, errorRank));
				else
					Addon:Print(string.format("Cannot Learn: %s", name));
				end
			end
		end
	end

	Addon.isLocked = false;

	return not hasError;
end

function Addon:ImportTextAsync(importText)
	C_Timer.After(
		0,
		function()
			Addon:ImportText(importText);
		end
	);
end
