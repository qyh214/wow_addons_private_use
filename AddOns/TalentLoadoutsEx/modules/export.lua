local addonName, Addon = ...;

function Addon:GetExportText()
	local talentsFrame = Addon.TalentsFrame;
	if not talentsFrame then
		local text = "Error: TalentsFrame is not exists."
		Addon:Print(text);
		error(text);
	end

	local exportStream = ExportUtil.MakeExportDataStream();
	local configID = talentsFrame:GetConfigID();
	local currentSpecID = PlayerUtil.GetCurrentSpecID();

	local treeInfo = talentsFrame:GetTreeInfo();
	local treeHash = treeInfo and C_Traits.GetTreeHash(treeInfo.ID);
	if treeHash then
		local serializationVersion = C_Traits.GetLoadoutSerializationVersion();
		talentsFrame:WriteLoadoutHeader(exportStream, serializationVersion, currentSpecID, treeHash);
		talentsFrame:WriteLoadoutContent(exportStream, configID, treeInfo.ID);

		return exportStream:GetExportString();
	end

	return nil;
end
