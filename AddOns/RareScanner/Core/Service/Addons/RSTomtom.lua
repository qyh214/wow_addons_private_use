-----------------------------------------------------------------------
-- AddOn namespace.
-----------------------------------------------------------------------
local ADDON_NAME, private = ...

local RSTomtom = private.NewLib("RareScannerTomtom")

-- RareScanner database libraries
local RSGeneralDB = private.ImportLib("RareScannerGeneralDB")
local RSConfigDB = private.ImportLib("RareScannerConfigDB")

-- RareScanner general libraries
local RSUtils = private.ImportLib("RareScannerUtils")

---============================================================================
-- Tomtom integration
---============================================================================

local tomtom_waypoint

function RSTomtom.AddWorldMapTomtomWaypoint(mapID, x, y, name)
	if (TomTom and RSConfigDB.IsAddingWorldMapTomtomWaypoints() and mapID and x and y and name) then
		RSTomtom.RemoveCurrentTomtomWaypoint()
				
		tomtom_waypoint = TomTom:AddWaypoint(tonumber(mapID), RSUtils.FixCoord(x), RSUtils.FixCoord(y), {
			title = name,
			persistent = false,
			minimap = false,
			world = false,
			cleardistance = 25
		})
	end
end

function RSTomtom.AddTomtomWaypoint(mapID, x, y, name)
	if (TomTom and RSConfigDB.IsTomtomSupportEnabled() and mapID and mapID ~= "" and x and y and name) then
		RSTomtom.RemoveCurrentTomtomWaypoint()
		
		tomtom_waypoint = TomTom:AddWaypoint(tonumber(mapID), RSUtils.FixCoord(x), RSUtils.FixCoord(y), {
			title = name,
			persistent = false,
			minimap = false,
			world = false,
			cleardistance = 25
		})
	end
end

function RSTomtom.AddTomtomAutomaticWaypoint(mapID, x, y, name, manuallyFired)
	-- If not automatic waypoints
	if (not manuallyFired and not RSConfigDB.IsAddingTomtomWaypointsAutomatically()) then
		return
	end

	-- Adds the waypoint
	RSTomtom.AddTomtomWaypoint(mapID, x, y, name)
end

function RSTomtom.RemoveCurrentTomtomWaypoint()
	if (TomTom and tomtom_waypoint) then
		TomTom:RemoveWaypoint(tomtom_waypoint)
		tomtom_waypoint = nil
	end
end
