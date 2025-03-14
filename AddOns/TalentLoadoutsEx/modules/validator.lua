local addonName, Addon = ...;

Addon.LegacyWarningMessage = _G["LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH"];

local version = C_Traits.GetLoadoutSerializationVersion and C_Traits.GetLoadoutSerializationVersion() or 1;
function Addon:GetValidationError(treeID, importStream)
	local talentsFrame = Addon.TalentsFrame;
	local headerValid, serializationVersion, specID, treeHash = talentsFrame:ReadLoadoutHeader(importStream);
	if(not headerValid) then
		return _G["LOADOUT_ERROR_BAD_STRING"];
	elseif serializationVersion ~= version then
		return _G["LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH"];
	elseif specID ~= PlayerUtil.GetCurrentSpecID() then
		return _G["LOADOUT_ERROR_WRONG_SPEC"];
	elseif not talentsFrame:IsHashEmpty(treeHash) then
		if not talentsFrame:HashEquals(treeHash, C_Traits.GetTreeHash(treeID)) then
			return _G["LOADOUT_ERROR_TREE_CHANGED"];
		end
	end

	return nil;
end
