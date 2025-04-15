
-- App locals
local _, app = ...;

if app.GameBuildVersion < 110100 then
	app.CreateWarbandScene = app.CreateUnimplementedClass("WarbandScene", "warbandSceneID");
	return
end

-- Warband Scene Lib
do

	local C_WarbandScene_HasWarbandScene, C_WarbandScene_GetWarbandSceneEntry
		= C_WarbandScene.HasWarbandScene, C_WarbandScene.GetWarbandSceneEntry;

	local CACHE = "WarbandScene";
	local CLASSNAME = "WarbandScene";
	local KEY = "warbandSceneID";
	local WarbandSceneInfoMeta = setmetatable({}, {
		__index = function(t, id)
			local info = C_WarbandScene_GetWarbandSceneEntry(id) or app.EmptyTable
			t[id] = info
			return info
		end
	})
	app.CreateWarbandScene = app.CreateClassWithInfo(CLASSNAME, KEY, WarbandSceneInfoMeta, {
		icon = function(t)
			-- return app.asset("Category_WarbandScenes") PH?
			return 648901;
		end,
		--collectible = function(t)
		--	return app.Settings.Collectibles[CACHE];
		--end,
		collected = function(t)
			return C_WarbandScene_HasWarbandScene(t[KEY])
		end,
		RefreshCollectionOnly = true,	-- TODO: remove when adding proper collection caching
	});
	-- app.AddSimpleCollectibleSwap(CLASSNAME, CACHE)
end