local _, Addon = ...;

function Addon:SendUpdateMessage()
	local WeakAuras = _G["WeakAuras"];
	if Addon:IsAddOnLoaded("Weakauras") and WeakAuras and WeakAuras.ScanEvents then
		local loadedData = Addon.loadedDataList and Addon.loadedDataList[1];
		local name = loadedData and loadedData.name;
		local icon = loadedData and loadedData.icon;

		WeakAuras.ScanEvents("TalentLoadoutEx", name, icon);
	end
end
