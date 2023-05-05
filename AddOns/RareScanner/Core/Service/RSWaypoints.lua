-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSWaypoints = private.NewLib("RareScannerWaypoints")

-- RareScanner database libraries
local RSGeneralDB = private.ImportLib("RareScannerGeneralDB")
local RSConfigDB = private.ImportLib("RareScannerConfigDB")

-- RareScanner general libraries
local RSUtils = private.ImportLib("RareScannerUtils")

---============================================================================
-- Ingame waypoints
---============================================================================

local function AddWaypoint(mapID, x, y)
	C_Map.ClearUserWaypoint();

	if (mapID and mapID ~= "" and x and y) then
		local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, tostring(RSUtils.FixCoord(x)), tostring(RSUtils.FixCoord(y)));
		C_Map.SetUserWaypoint(uiMapPoint);
		C_SuperTrack.SetSuperTrackedUserWaypoint(true);
	end
end

function RSWaypoints.AddWorldMapWaypoint(mapID, x, y)
	if (RSConfigDB.IsAddingWorldMapIngameWaypoints() and mapID and mapID ~= "" and x and y) then
		C_Map.ClearUserWaypoint();
		local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, tostring(RSUtils.FixCoord(x)), tostring(RSUtils.FixCoord(y)));
		C_Map.SetUserWaypoint(uiMapPoint);
		C_SuperTrack.SetSuperTrackedUserWaypoint(true);
	end
end

function RSWaypoints.AddWaypoint(mapID, x, y)
	if (mapID and mapID ~= "" and x and y and RSConfigDB.IsWaypointsSupportEnabled()) then
		AddWaypoint(mapID, x, y)
	end
end

function RSWaypoints.AddAutomaticWaypoint(mapID, x, y, manuallyFired)
	-- If not automatic waypoints
	if (not manuallyFired and not RSConfigDB.IsAddingWaypointsAutomatically()) then
		return
	end

	-- Adds the waypoint
	AddWaypoint(mapID, x, y)
end
