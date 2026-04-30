local env = select(2, ...)
local L = env.L
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local MapPin = env.modules:Import("@\\MapPin")
local SupportedAddons = env.modules:Import("@\\SupportedAddons")
local SupportedAddons_APR = env.modules:New("@\\SupportedAddons\\APR")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("APRSupportEnabled") == true end

local CanSetUserWaypointOnMap = C_Map.CanSetUserWaypointOnMap
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetMapInfo = C_Map.GetMapInfo
local GetMapInfoAtPosition = C_Map.GetMapInfoAtPosition
local GetMapPosFromWorldPos = C_Map.GetMapPosFromWorldPos
local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything

local lastWaypointInfo = { mapID = nil, x = nil, y = nil }
local candidateMapIDs = {}
local seenMapIDs = {}
local textLines = {}
local worldPosition = CreateVector2D(0, 0)
local APRWaypointInfo = { name = nil, mapID = nil, x = nil, y = nil }


local function HandleAccept()
	SupportedAddons_APR.PlaceWaypointAtSession()
end

local REPLACE_PROMPT_INFO = {
	text         = L["APR_REPLACEPROMPT"],
	options      = {
		{
			text     = L["REPLACE"],
			callback = HandleAccept
		},
		{
			text     = L["CANCEL"],
			callback = nil
		}
	},
	hideOnEscape = true,
	timeout      = 10
}


local function ResetWaypointInfo(clearMapPin)
	lastWaypointInfo.mapID = nil
	lastWaypointInfo.x = nil
	lastWaypointInfo.y = nil
	APRWaypointInfo.name = nil
	APRWaypointInfo.mapID = nil
	APRWaypointInfo.x = nil
	APRWaypointInfo.y = nil

	if clearMapPin and MapPin.IsUserNavigationFlagged("APR_Waypoint") then
		MapPin.ClearUserNavigation()
	end
end

local function RoundWaypointCoordinate(value)
	return math.floor(value * 10 + 0.5)
end

local function IsCurrentAPRWaypoint(mapID, roundedX, roundedY)
	if not MapPin.IsUserNavigationFlagged("APR_Waypoint") then return false end

	local currentWaypoint = MapPin.GetUserNavigation()
	if not currentWaypoint then return false end

	local currentMapID = tonumber(currentWaypoint.mapID)
	if not currentMapID or currentMapID ~= mapID then return false end

	local currentX = currentWaypoint.x
	local currentY = currentWaypoint.y
	if not currentX or not currentY then return false end

	return RoundWaypointCoordinate(currentX * 100) == roundedX and RoundWaypointCoordinate(currentY * 100) == roundedY
end

local function UpdateCurrentAPRWaypointName(name, mapID, x, y)
	if not MapPin.IsUserNavigationFlagged("APR_Waypoint") then return end

	local currentWaypoint = MapPin.GetUserNavigation()
	if not currentWaypoint then return end
	if currentWaypoint.name == name then return end

	MapPin.SetUserNavigation(name, mapID, x / 100, y / 100, "APR_Waypoint", Path.Root .. "\\Art\\Icons\\TomTomArrow", nil, nil, nil, true)
	CallbackRegistry.Trigger("MapPin.NewUserNavigation")
end

local function NormalizeObjectiveText(text, key)
	if not text or text == "" then return nil end

	local errorDestinationKey = APR.transport and APR.transport.ErrorDestinationLineKey or "00_ERROR_DESTINATION"
	if key == errorDestinationKey then
		local _, separatorEnd = string.find(text, " - ", 1, true)
		if separatorEnd then
			text = string.sub(text, separatorEnd + 1)
		end
	end

	if string.sub(text, 1, 1) == "-" then
		text = strtrim(string.sub(text, 2))
	end

	return text ~= "" and text or nil
end

local function GetTopVisibleContainer(list, topContainer, topValue)
	if not list then
		return topContainer, topValue
	end

	for _, container in pairs(list) do
		if container and container.font and container:IsShown() then
			local text = container.font:GetText()
			local top = container:GetTop()
			if text and text ~= "" and top and top > topValue then
				topContainer = container
				topValue = top
			end
		end
	end

	return topContainer, topValue
end

local function GetContainerText(container)
	if not container or not container.font then return nil end

	wipe(textLines)
	local lineCount = 0

	local text = NormalizeObjectiveText(container.font:GetText(), container.key)
	if text then
		lineCount = 1
		textLines[1] = text
	end

	if container.subTexts then
		for _, subText in ipairs(container.subTexts) do
			text = NormalizeObjectiveText(subText and subText.text)
			if text then
				lineCount = lineCount + 1
				textLines[lineCount] = text
			end
		end
	end

	if lineCount == 0 then return nil end

	text = table.concat(textLines, "\n", 1, lineCount)
	wipe(textLines)
	return text
end

local function GetCurrentObjectiveText()
	if not APR.currentStep then return nil end

	local topContainer = nil
	local topValue = -math.huge

	topContainer, topValue = GetTopVisibleContainer(APR.currentStep.questsExtraTextList, topContainer, topValue)
	topContainer, topValue = GetTopVisibleContainer(APR.currentStep.questsList, topContainer, topValue)

	return GetContainerText(topContainer)
end

local function GetArrowWorldPosition()
	if not APR.Arrow or APR.Arrow.Active ~= true then return nil end
	if APR.Arrow.x == nil or APR.Arrow.y == nil then return nil end
	if APR.Arrow.x == 0 and APR.Arrow.y == 0 then return nil end

	worldPosition.x = APR.Arrow.y
	worldPosition.y = APR.Arrow.x
	return worldPosition
end

local function ResolveWaypointFromContinent(worldPosition)
	local continentID = APR:GetContinent()
	if not continentID or continentID == 0 then return nil end

	local _, continentPosition = GetMapPosFromWorldPos(continentID, worldPosition, continentID)
	if not continentPosition then return nil end

	local mapInfo = GetMapInfoAtPosition(continentID, continentPosition.x, continentPosition.y)
	local mapID = mapInfo and mapInfo.mapID or continentID

	while mapID and mapID ~= 0 do
		if CanSetUserWaypointOnMap(mapID) then
			local _, mapPosition = GetMapPosFromWorldPos(continentID, worldPosition, mapID)
			if mapPosition and
				mapPosition.x >= 0 and mapPosition.x <= 1 and
				mapPosition.y >= 0 and mapPosition.y <= 1 then
				return mapID, mapPosition.x * 100, mapPosition.y * 100
			end
		end

		local currentMapInfo = GetMapInfo(mapID)
		mapID = currentMapInfo and currentMapInfo.parentMapID or 0
	end

	return nil
end

local function AddCandidateMapID(mapID)
	if not mapID or mapID == 0 or seenMapIDs[mapID] then return end

	seenMapIDs[mapID] = true
	candidateMapIDs[#candidateMapIDs + 1] = mapID
end

local function ResolveWaypointFromCandidates()
	if not APR.Arrow or not APR.GetPlayerMapPos then return nil end

	wipe(candidateMapIDs)
	wipe(seenMapIDs)

	local routeMapID = nil
	local stepZoneID = nil
	local playerParentMapID = APR.GetPlayerParentMapID and APR:GetPlayerParentMapID() or nil

	AddCandidateMapID(GetBestMapForUnit("player"))
	AddCandidateMapID(playerParentMapID)

	if APR.ActiveRoute and APR.GetCurrentRouteMapIDsAndName then
		local _, resolvedRouteMapID = APR:GetCurrentRouteMapIDsAndName()
		routeMapID = resolvedRouteMapID
	end

	if APR.ActiveRoute and APRData and APRData[APR.PlayerID] and APR.GetStep then
		local step = APR:GetStep(APRData[APR.PlayerID][APR.ActiveRoute])

		if step and APR.GetStepCoord then
			local _, resolvedStepZoneID = APR:GetStepCoord(step, routeMapID, playerParentMapID)
			stepZoneID = resolvedStepZoneID
			AddCandidateMapID(stepZoneID)
		end

		if step and APR.GetStepZoneList then
			for _, zoneID in ipairs(APR:GetStepZoneList(step, routeMapID)) do
				AddCandidateMapID(zoneID)
			end
		end
	end

	AddCandidateMapID(routeMapID)

	if APR.transport and APR.transport.GetZoneMoveOrder and stepZoneID then
		local zoneEntryMapID = APR.transport:GetZoneMoveOrder(stepZoneID)
		AddCandidateMapID(zoneEntryMapID)
	end

	for index = 1, #candidateMapIDs do
		local mapID = candidateMapIDs[index]
		if CanSetUserWaypointOnMap(mapID) then
			local x, y = APR:GetPlayerMapPos(mapID, APR.Arrow.y, APR.Arrow.x)
			if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
				return mapID, x * 100, y * 100
			end
		end
	end

	return nil
end

local function ResolveWaypointPosition()
	local worldPosition = GetArrowWorldPosition()
	if not worldPosition then return nil end

	local mapID, x, y = ResolveWaypointFromContinent(worldPosition)
	if mapID and x and y then
		return mapID, x, y
	end

	return ResolveWaypointFromCandidates()
end

local function RefreshSessionWaypoint()
	if not IsModuleEnabled() then
		ResetWaypointInfo(true)
		return
	end

	local mapID, x, y = ResolveWaypointPosition()
	if not mapID or not x or not y then
		ResetWaypointInfo(true)
		return
	end

	local name = GetCurrentObjectiveText() or APRWaypointInfo.name
	if not name and APR and APR.CheckWaypointText then
		name = APR:CheckWaypointText()
	end
	if not name then
		name = "APR"
	end

	local roundedX = RoundWaypointCoordinate(x)
	local roundedY = RoundWaypointCoordinate(y)

	APRWaypointInfo.name = name
	APRWaypointInfo.mapID = mapID
	APRWaypointInfo.x = x
	APRWaypointInfo.y = y

	if (lastWaypointInfo.mapID == mapID and lastWaypointInfo.x == roundedX and lastWaypointInfo.y == roundedY) or IsCurrentAPRWaypoint(mapID, roundedX, roundedY) then
		lastWaypointInfo.mapID = mapID
		lastWaypointInfo.x = roundedX
		lastWaypointInfo.y = roundedY

		if MapPin.IsUserNavigationFlagged("APR_Waypoint") then
			UpdateCurrentAPRWaypointName(name, mapID, x, y)
		end

		return
	end

	lastWaypointInfo.mapID = mapID
	lastWaypointInfo.x = roundedX
	lastWaypointInfo.y = roundedY

	if Config.DBGlobal:GetVariable("APRAutoReplaceWaypoint") == true or not IsSuperTrackingAnything() or MapPin.IsUserNavigationFlagged("APR_Waypoint") then
		SupportedAddons_APR.PlaceWaypointAtSession()
	else
		WUISharedPrompt:Open(REPLACE_PROMPT_INFO, name)
	end
end


function SupportedAddons_APR.PlaceWaypointAtSession()
	if not APRWaypointInfo.mapID or not APRWaypointInfo.x or not APRWaypointInfo.y then return end

	MapPin.NewUserNavigation(APRWaypointInfo.name, APRWaypointInfo.mapID, APRWaypointInfo.x, APRWaypointInfo.y, "APR_Waypoint", APR_ARROW_ICON, nil, nil, nil, true)
end

local function OnAddonLoad()
	hooksecurefunc(APR, "UpdateStep", RefreshSessionWaypoint)
	hooksecurefunc(APR.Arrow, "SetArrowActive", RefreshSessionWaypoint)

	if APR.transport and APR.transport.GetMeToRightZone then
		hooksecurefunc(APR.transport, "GetMeToRightZone", RefreshSessionWaypoint)
	end

	if APR.routeconfig and APR.routeconfig.CheckIsCustomPathEmpty then
		hooksecurefunc(APR.routeconfig, "CheckIsCustomPathEmpty", RefreshSessionWaypoint)
	end

	local EL = CreateFrame("Frame")
	EL:RegisterEvent("ADDONS_UNLOADING")
	EL:SetScript("OnEvent", function()
		ResetWaypointInfo(true)
	end)

	RefreshSessionWaypoint()
end

SupportedAddons.Add("APR", OnAddonLoad)
