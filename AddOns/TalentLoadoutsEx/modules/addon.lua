local addonName, Addon = ...;

function Addon:IsAddOnLoaded(name)
	local loadedOrLoading, loaded = C_AddOns.IsAddOnLoaded(name);
	return loadedOrLoading and loaded;
end

function Addon:RegisterAddonLoad(target, isLoadNow, funcName, ...)
	local func = Addon[funcName];
	if not func then
		local text = "Error: "..funcName.." is not defined function."
		error(text);
	elseif Addon:IsAddOnLoaded(target) then
		func(Addon, ...);
	else
		local funcValues = {...};
		local addonFrame = CreateFrame("Frame");
		addonFrame:RegisterEvent("ADDON_LOADED");
		addonFrame:SetScript(
			"OnEvent",
			function(frame, event, name)
				if event == "ADDON_LOADED" and name == target then
					frame:UnregisterAllEvents();
					func(Addon, unpack(funcValues));
				end
			end
		);

		if isLoadNow then
			C_AddOns.LoadAddOn(target);
		end
	end
end
