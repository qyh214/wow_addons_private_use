local IPUI_ICON_COORDS_DUNGEON = {0,0.242,0,0.242}
local IPUI_ICON_COORDS_RAID = {0.242,0.484,0,0.242}
local IPUI_ICON_COORDS_DUNGEON_HIGHLIGHTED = {0,0.242,0.242,0.484}
local IPUI_ICON_COORDS_RAID_HIGHLIGHTED = {0.242,0.484,0.242,0.484}

local IPUI_ICON_COORDS_HUB = IPUI_ICON_COORDS_DUNGEON
local IPUI_ICON_COORDS_HUB_HIGHLIGHTED = IPUI_ICON_COORDS_DUNGEON_HIGHLIGHTED

local IPUIPinFrames = {}
local IPUIMapTooltip = nil
local IPUIDungeonTable = {}

local IPUIDebug=false

function InstancePortalUI_OnLoad(self)
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("WORLD_MAP_UPDATE")
	self:RegisterEvent("WORLD_MAP_NAME_UPDATE")
	self:SetScript("OnEvent", IPUIEventHandler)

	_, _, _, uiVersion = GetBuildInfo()
	if (uiVersion < 70000) then
		IPUILoadEJ()
	end

	IPUIPrintDebug("InstancePortalUI_OnLoad()")
	IPUIMapTooltipSetup()
end

function IPUILoadEJ()
	if(not EncounterJournal) then
		LoadAddOn("Blizzard_EncounterJournal")
	end
end

function IPUIPrintDebug(t)
	if (IPUIDebug) then
		print(t)
	end
end

function IPUIHideAllPins()
	for i = 1, #IPUIPinFrames do
		IPUIPinFrames[i]:Hide()
	end

	wipe(IPUIPinFrames)
end

function IPUIRefreshPins()

	local mapName, textureHeight, _, isMicroDungeon, microDungeonMapName = GetMapInfo();
	if IPUIDebug and isMicroDungeon then
		local dungeonLevel = GetCurrentMapDungeonLevel();
		if (DungeonUsesTerrainMap()) then
			dungeonLevel = dungeonLevel - 1;
		end
		IPUIPrintDebug("micro: "..microDungeonMapName)
		IPUIPrintDebug("level: "..dungeonLevel)
	end

	IPUIHideAllPins()
	if not (WorldMapFrame:IsVisible()) then return nil end

	local cityOverride = false

	if ((GetCurrentMapAreaID() == 301) or (GetCurrentMapAreaID() == 321) or (GetCurrentMapAreaID() == 504)) then
		cityOverride = true
	end

	IPUIPrintDebug("IPUIRefreshPins for map: "..GetCurrentMapAreaID())

	if isMicroDungeon then
		local dungeonLevel = GetCurrentMapDungeonLevel();
		if (DungeonUsesTerrainMap()) then
			dungeonLevel = dungeonLevel - 1;
		end

		if IPUIMicroDungeonPinDB[microDungeonMapName] then
			if IPUIMicroDungeonPinDB[microDungeonMapName][dungeonLevel] then
				for i = 1, #IPUIMicroDungeonPinDB[microDungeonMapName][dungeonLevel] do
					IPUIShowPin(i)
				end
			end
		end
	else
		if ((GetCurrentMapDungeonLevel() == 0) or cityOverride) then
			if IPUIPinDB[GetCurrentMapAreaID()] then
				for i = 1, #IPUIPinDB[GetCurrentMapAreaID()] do
					IPUIShowPin(i)
				end
			end
		else
			IPUIPrintDebug("No pins for this dungeon level")
		end
	end
end

function IPUIMapTooltipSetup()
	IPUIMapTooltip = CreateFrame("GameTooltip", "IPUIMapTooltip", WorldMapFrame, "GameTooltipTemplate")
	IPUIMapTooltip:SetFrameStrata("TOOLTIP")
	IPUIMapTooltip:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel()+11)
	WorldMapFrame:HookScript("OnSizeChanged",
		function(self)
			IPUIMapTooltip:SetScale(1/self:GetScale())
		end
	)
end

function IPUIFindInstanceByName(name, isRaid)
   if isRaid == nil then
      local id = findInstanceByName(name, true)
      if not id then id = findInstanceByName(name, false) end
      return id
   end
   
   local i = 1
   local instanceId,instanceName = EJ_GetInstanceByIndex(i, isRaid)
   name = name:lower()
   
   while instanceId do
      if name == instanceName:lower() then return instanceId end
      i = i + 1
      instanceId, instanceName = EJ_GetInstanceByIndex(i, isRaid)        
   end
   return nil
end

function IPUIShowInstance(subInstanceMapIDs, index)
	local name = IPUIInstanceMapDB[subInstanceMapIDs[index]][1]
	local type = IPUIInstanceMapDB[subInstanceMapIDs[index]][2]
	local tier = IPUIInstanceMapDB[subInstanceMapIDs[index]][4]

	_, _, _, uiVersion = GetBuildInfo()

	if (uiVersion < 70000) and ((tier <= 3) and (type == 2)) then -- no journal for Vanilla, TBC & WotLK raids before 7.0
		SetMapByID(subInstanceMapIDs[index])
	else
		ToggleEncounterJournal()
		EJ_SelectTier(tier) -- have to select expansion tier before we can query details or select
		local instanceID = IPUIFindInstanceByName(name, (type == 2))

		IPUIPrintDebug("Loading instance: "..instanceID.." for name: "..name)

		EncounterJournal_ResetDisplay(instanceID, -1, -1)
	end
end

function IPUIShowPin(locationIndex)
	local mapName, textureHeight, _, isMicroDungeon, microDungeonMapName = GetMapInfo();

	if isMicroDungeon then

		local dungeonLevel = GetCurrentMapDungeonLevel();
		if (DungeonUsesTerrainMap()) then
			dungeonLevel = dungeonLevel - 1;
		end

		instancePortal = IPUIMicroDungeonPinDB[microDungeonMapName][dungeonLevel][locationIndex]
	else
		instancePortal = IPUIPinDB[GetCurrentMapAreaID()][locationIndex]
	end

	if not (instancePortal) then
		IPUIPrintDebug("No pin "..locationIndex.." for map: "..GetCurrentMapAreaID())
		return nil
	end

	local x = instancePortal[1]
	local y = instancePortal[2]
	local subInstanceMapIDs = instancePortal[3]
	local hubName = instancePortal[4]

	local type = IPUIInstanceMapDB[subInstanceMapIDs[1]][2]

	local pin = CreateFrame("Frame", "IPPin", WorldMapDetailFrame)

	pin.Texture = pin:CreateTexture()
	pin.Texture:SetTexture("Interface\\Addons\\InstancePortals\\Images\\IPIcons")
	pin.Texture:SetAllPoints()
	pin:EnableMouse(true)
	pin:SetFrameStrata("TOOLTIP")
	pin:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel()+10)

	pin:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", (x / 100) * WorldMapDetailFrame:GetWidth(), (-y / 100) * WorldMapDetailFrame:GetHeight())

	pin:SetWidth(31)
	pin:SetHeight(31)
	if (type == 1) then
		pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_DUNGEON))
	elseif (type == 2) then
		pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_RAID))
	end

	if (#subInstanceMapIDs > 1) then
		pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_HUB))
	end

	pin:HookScript("OnEnter",
			function(pin, motion)

				if (type == 1) then
					pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_DUNGEON_HIGHLIGHTED))
				elseif (type == 2) then
					pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_RAID_HIGHLIGHTED))
				end

				IPUIMapTooltip:SetOwner(pin, "ANCHOR_RIGHT")
				IPUIMapTooltip:ClearLines()
				IPUIMapTooltip:SetScale(WorldMapFrame:GetScale())
				if (#subInstanceMapIDs > 1) then
					IPUIMapTooltip:AddLine(hubName)
				end
					for i = 1, #subInstanceMapIDs do
						local name = IPUIInstanceMapDB[subInstanceMapIDs[i]][1]
						local type = IPUIInstanceMapDB[subInstanceMapIDs[i]][2]
						local requiredLevel = IPUIInstanceMapDB[subInstanceMapIDs[i]][3]
						local tier = IPUIInstanceMapDB[subInstanceMapIDs[i]][4]

						IPUIMapTooltip:AddDoubleLine(string.format("|cffffffff%s|r",name), string.format("|cffff7d0a%d|r", requiredLevel))
						if (type == 1) then
							IPUIMapTooltip:AddTexture("Interface\\Addons\\InstancePortals\\Images\\IPDungeon")
						else
							IPUIMapTooltip:AddTexture("Interface\\Addons\\InstancePortals\\Images\\IPRaid")
						end
					end


				IPUIMapTooltip:Show()
			end
	)
	pin:HookScript("OnLeave",
			function(pin)
				if (type == 1) then
					pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_DUNGEON))
				elseif (type == 2) then
					pin.Texture:SetTexCoord(unpack(IPUI_ICON_COORDS_RAID))
				end
				IPUIMapTooltip:Hide()
			end
		)
	pin:HookScript("OnMouseDown",
			function(self, button)
				if (button == "LeftButton") then
					if (#subInstanceMapIDs == 1) then
						IPUIShowInstance(subInstanceMapIDs, 1)
					else
						local menu = {
							{ text = hubName, isTitle = true},
						}
						for i = 1, #subInstanceMapIDs do
							local name = IPUIInstanceMapDB[subInstanceMapIDs[i]][1]
							local line = { text = name, notCheckable = true, func = function() IPUIShowInstance(subInstanceMapIDs, i); end }

							table.insert(menu, line)
						end

						local menuFrame = CreateFrame("Frame", "IPUISelectMenuFrame", UIParent, "UIDropDownMenuTemplate")
						EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
					end
				end
			end
		)
	table.insert(IPUIPinFrames, pin)
	pin:Show()
end

function IPUIEventHandler(self, event, ...)
	IPUIRefreshPins()
end
