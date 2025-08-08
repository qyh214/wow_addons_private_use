local _, Addon = ...;

_G.TLX = {};
function _G.TLX.GetLoadedData()
	if Addon.loadedDataList then
		return unpack(Addon.loadedDataList);
	else
		return nil;
	end
end
