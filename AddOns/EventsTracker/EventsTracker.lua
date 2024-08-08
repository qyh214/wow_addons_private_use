local _, L = ...
local LMB, RMB = CreateAtlasMarkup("NPE_LeftClick", 18, 18), CreateAtlasMarkup("NPE_RightClick", 18,18);
-- Sprawl,		High Energy Potion,	
-- Sprawl,		Strive, 				
-- Tribal ode,	High Energy Potion,	
local eventFrame = {}
local selfName
local eventTrackerHeight

local EventsTrackerFrame = CreateFrame("Frame", "EventsTrackerFrame")

function EventsTrackerFrame:FindEventOnMaps(event, scanningMaps)
	local changedName;
	local toolTip = "";
	local x, y, findMapID, atlasName;
	local wantedEventName
	local eventName
	
	for _, uiMapID in next, scanningMaps do
		local info = C_Map.GetMapInfo(uiMapID)
		-- len ak taka mapa existuje
		if info then
			local areaPoiIDs = C_AreaPoiInfo.GetEventsForMap(uiMapID)
			-- len ak na tej mape existuju areaPoiIDs
			if areaPoiIDs then
				-- hladaj cez GetEventsForMap
				for _, areaPoiID in pairs(areaPoiIDs) do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
									
					if poiInfo and poiInfo.areaPoiID == event then
						local isTimed, hideTimerInTooltip = C_AreaPoiInfo.IsAreaPOITimed(areaPoiID)
						--print(C_AreaPoiInfo.IsAreaPOITimed(areaPoiID))
						local timeExist = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) or "notime"
						--print("EVENTS : "..info.name .. "("..uiMapID..") - |cFF40B040"..poiInfo.name.."|r ".. (poiInfo.isPrimaryMapForPOI and "|cFF20FF20TRUE|r " or "|cFFff2020FALSE|r ") .. timeExist .. areaPoiID)
						--for k, v in pairs(poiInfo) do
						--	print(k, v)
						--end
						--print(poiInfo.atlasName)
						eventName = poiInfo.name
						atlasName = poiInfo.atlasName;
						toolTip = poiInfo.description
						findMapID = uiMapID;	
						x, y = poiInfo.position:GetXY();
						break
					end
				end
			end
			
			-- hladaj cez GetAreaPOIForMap
			local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID);
			if areaPoiIDs then
				for _, areaPoiID in pairs(areaPoiIDs) do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
					
					if poiInfo and (poiInfo.isPrimaryMapForPOI or event == 7635) -- vinimka na superbloom
						and ((event == 7602 and poiInfo.atlasName == "dreamsurge_hub-icon") or (event == 7232 and string.find(poiInfo.atlasName, "ElementalStorm"))) then
						print(poiInfo.name)
						eventName = poiInfo.name
						atlasName = poiInfo.atlasName;
						local mapName = C_Map.GetMapInfo(uiMapID).name or UNKNOWN;
						if atlasName == "ElementalStorm-Lesser-Water" then
							changedName = "Snowstorms";
						elseif atlasName == "ElementalStorm-Lesser-Fire" then
							changedName = "Firestorms";
						elseif atlasName == "ElementalStorm-Lesser-Air" then
							changedName = "Thunderstorms";
						elseif atlasName == "ElementalStorm-Lesser-Earth" then
							changedName = "Sandstorms";
						end
						--if string.find(poiInfo.atlasName, "ElementalStorm") then
						--	for k, v in pairs(poiInfo) do
						--		print(k, v)
						--	end
						--print(poiInfo.atlasName)	
						--end
						--print(wantedEventName, C_AreaPoiInfo.IsAreaPOITimed(areaPoiID), C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID))
						toolTip = toolTip .. "|A:"..atlasName..":18:18|a".. (changedName and changedName or eventName) .. " in " ..mapName.."\n";
						findMapID = uiMapID;	
						x, y = poiInfo.position:GetXY();
						break
					end
				end
			end
		end
	end
	
	if findMapID then
		return eventName, findMapID, x*100, y*100, atlasName, toolTip
	end
end
---------------------------------------------
-- Default config
local function timeByCurrentWeek()
	local currWeek = date("%W")
	if currWeek == "31" then
		return 5400
	elseif currWeek == "32" then
		return 3600
	else
		return 1800
	end
end
--/run print(C_QuestLog.GetTitleForQuestID(77836))
local DefaultConfig = {
	collapsed = false,
	iconSize = 26,
	iconSpace = 8,
	iconsInRow = 8,
	fontSize = 10,
	speakVolume = 70,
	timeBefore = 300,
	extendedTooltip = true,
	events = {
		--Community Feast
		[1] = {	eventName = C_QuestLog.GetTitleForQuestID(70893),
			texture = "MajorFactions_MapIcons_Tuskarr64",
			eventRegionOffset = {
				[1] = 52,	-- us
				[2] = 52,	-- kr
				[3] = 52,	-- eu
				[4] = 52,	-- tw
				[5] = 52,},	-- ch				
			eventDuration = 900,
			eventInterval = 5400,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {70893},
			findEventOnMap = {},
			coor = {2024, 13.4, 48.4},
			datablock = {},
		},
		--Researchers under fire
		[2] = {	eventName = C_QuestLog.GetTitleForQuestID(74905),
			texture = "MajorFactions_MapIcons_Niffen64",
			eventRegionOffset = {
				[1] = 1800,
				[2] = 1800,
				[3] = 1800,
				[4] = 1800,	
				[5] = 1800,},
			eventDuration = 1500,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {75627, 75628, 75629, 75630}, -- Epic 75630, Rare 75629, Uncommon, 75628, Common 75627
			findEventOnMap = {},
			coor = {2133, 47.6, 56.7},
			datablock = {},
		},
		--Dragonbane Keep
		[3] = {	eventName = L["Siege on Dragonbane Keep"],
			texture = "MajorFactions_MapIcons_Expedition64",
			eventRegionOffset = {
				[1] = 100,
				[2] = 100,
				[3] = 100,
				[4] = 100,	
				[5] = 100,},
			eventDuration = 3600,
			eventInterval = 7200,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {70866},
			findEventOnMap = {},
			areaPoiID = 7267,--7413???
			coor = {2022, 30.48, 78.20},
			datablock = {},
		},
		-- Time rift
		[4] = {	eventName = EventsTrackerFrame:FindEventOnMaps(7492, {2025}),
			texture = "interface/targetingframe/unitframeicons.blp", --ChromieTime-32x32
			eventRegionOffset = {
				[1] = 20,
				[2] = 20,
				[3] = 20,
				[4] = 20,	
				[5] = 20,},
			eventDuration = 900,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {77836},
			findEventOnMap = {},
			coor = {2025, 51, 57},
			datablock = {},
		},
		--Rares spawn
		[5] = {	eventName = EJ_ITEM_CATEGORY_EXTREMELY_RARE,
			texture = "VignetteKillElite",
			eventRegionOffset = {
				[1] = 0,
				[2] = 0,
				[3] = 14400,
				[4] = 0,
				[5] = 0,},
			eventDuration = 60,
			eventInterval = 1800,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {},
			--achiveIDs = {16676},
			findEventOnMap = {},
			coor = {},
			datablock = {
				[0] = {eventName = L["Amethyzar the Glittering"], enable = true, coor = {2022, 63.6, 55.0},},
				[1] = {eventName = L["Eldoren the Reborn"], enable = true, coor = {2025, 47.8, 51.2},},
				[2] = {eventName = L["Pheran"], enable = true, coor = {2025, 60.6, 61.6},},
				[3] = {eventName = L["Skag the Thrower"], enable = true, coor = {2024, 26.8, 49.6},},
				[4] = {eventName = L["Mikrin of the Raging Winds"], enable = true, coor = {2023, 63.0, 80.0},},
				[5] = {eventName = L["Rokmur"], enable = true, coor = {2025, 50.0, 51.6},},
				[6] = {eventName = L["Smogswog the Firebreather"], enable = true, coor = {2022, 69.6, 64.6},},
				[7] = {eventName = L["Matriarch Remalla"], enable = true, coor = {2025, 52.8, 59.0},},
				[8] = {eventName = L["O'nank Shorescour"], enable = true, coor = {2022, 79.19, 52.92},},
				[9] = {eventName = L["Researcher Sneakwing"], enable = true, coor = {2023, 37.0, 53.8},},
				[10] = {eventName = L["Treasure-Mad Trambladd"], enable = true, coor = {2025, 35.0, 70.0},},
				[11] = {eventName = L["Harkyn Grymstone"], enable = true, coor = {2022, 42.2, 39.6},},
				[12] = {eventName = L["Fulgurb"], enable = true, coor = {2023, 75.2, 46.8},},
				[13] = {eventName = L["Sandana the Tempest"], enable = true, coor = {2025, 37.6, 78.0},},
				[14] = {eventName = L["Gorjo the Crab Shackler"], enable = true, coor = {2022, 78.6, 49.8},},
				[15] = {eventName = L["Steamgill"], enable = true, coor = {2023, 53.6, 72.8},},
				[16] = {eventName = L["Tempestrian"], enable = true, coor = {2025, 50.0, 79.0},},
				[17] = {eventName = L["Massive Magmashell"], enable = true, coor = {2022, 21.8, 76.6},},
				[18] = {eventName = L["Grumbletrunk"], enable = true, coor = {2024, 19.6, 43.2},},
				[19] = {eventName = L["Oshigol"], enable = true, coor = {2023, 61.6, 30.0},},
				[20] = {eventName = L["Broodweaver Araznae"], enable = true, coor = {2025, 61.51, 73.74},},
				[21] = {eventName = L["Azra's Prized Peony"], enable = true, coor = {2022, 54.6, 71.6},},
				[22] = {eventName = L["Malsegan"], enable = true, coor = {2023, 72.0, 46.6},},
				[23] = {eventName = L["Phleep"], enable = true, coor = {2025, 58.6, 85.6},},
				[24] = {eventName = L["Magmaton"], enable = true, coor = {2022, 40.0, 64.0},},
				[25] = {eventName = L["Gruffy"], enable = true, coor = {2024, 32.6, 29.2},},
				[26] = {eventName = L["Ronsak the Decimator"], enable = true, coor = {2023, 43.6, 55.4},},
				[27] = {eventName = L["Riverwalker Tamopo"], enable = true, coor = {2025, 39.8, 70.0},},
			},
		},
		--Dreamsurge
		[6] = {	eventName = EventsTrackerFrame:FindEventOnMaps(7602, {2022, 2023, 2024, 2025}),
			texture = "dreamsurge_hub-icon",
			eventRegionOffset = {
				[1] = 19,
				[2] = 19,
				[3] = 19,
				[4] = 19,	
				[5] = 19,},
			eventDuration = 1800,
			eventInterval = 1800,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {77251},
			findEventOnMap = {2022, 2023, 2024, 2025},
			areaPoiID = 7602,
			coor = {},
			datablock = {},
		},
		--Storm's Fury
		[7] = {	eventName = C_QuestLog.GetTitleForQuestID(74378),
			texture = "ElementalStorm-Boss-Water",
			eventRegionOffset = {
				[1] = 1670338860 + 3600,
				[2] = 1670698860,
				[3] = 1674763260,
				[4] = 1670698860,
				[5] = 1670677260,},
			eventDuration = 7200,
			eventInterval = 18000,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {74378},	--73162
			findEventOnMap = {},
			coor = {2025, 59.84, 82.29},
			datablock = {},
		},
		--Trial of the Elements
		[8] = {	eventName = L["Trial of the Elements"],
			texture = "VignetteLootElite",
			eventRegionOffset = {
				[1] = 1670342460,
				[2] = 1670698860,
				[3] = 1674763260,
				[4] = 1670698860,
				[5] = 1670677260,},
			eventDuration = 600,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {71995},	--71033 Flood
			findEventOnMap = {},
			coor = {},
			datablock = {
				[0] = {eventName = L["Trial of the Elements"], enable = false, coor = {2085, 27.91, 25.86},},
				[1] = {eventName = L["Trial of the Elements"], enable = false, coor = {2085, 27.91, 25.86},},
				[2] = {eventName = L["Trial of the Elements"], enable = true, coor = {2085, 27.91, 25.86},},
				[3] = {eventName = L["Trial of the Elements"], enable = true, coor = {2085, 27.91, 25.86},},
				[4] = {eventName = L["Trial of the Elements"], enable = true, coor = {2085, 27.91, 25.86},},
			},
		},
		--Elemental Storm
		[9] = { eventName = L["Elemental Storm"],
			texture = "ElementalStorm-Lesser-Earth",
			eventRegionOffset = {
				[1] = 30,
				[2] = 30,
				[3] = 30,
				[4] = 30,	
				[5] = 30,},
			eventDuration = 7200,
			eventInterval = 10800,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {}, --70752, 70753, 70754, 70723, 72686}, -- Water 70752, Air 70753, Fire 70754, Earth 70723, Surge 72686
			achiveIDs = {16468,16484,16476,16489},
			findEventOnMap = {2022, 2023, 2024, 2025},
			areaPoiID = 7232,--7245, 7223
			iconWidgetSet = 1095,
			coor = {},
			datablock = {},
		},
		--Superbloom
		[10] = {	eventName = L["Superbloom"],
			texture = "MajorFactions_MapIcons_Dream64",
			eventRegionOffset = {
				[1] = 11,
				[2] = 11,
				[3] = 11,
				[4] = 11,	
				[5] = 11,},
			eventDuration = 1040,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {78319},
			findEventOnMap = {},
			areaPoiID = 7834, --7634, 7635
			iconWidgetSet = 978,
			coor = {2200, 51.39, 59.71},
			datablock = {},
		},
		--The Big Dig
		[11] = {	eventName = L["The Big Dig"],
			texture = "interface/archeology/arch-icon-marker.blp",
			eventRegionOffset = {
				[1] = 1836,
				[2] = 1836,
				[3] = 1836,
				[4] = 1836,	
				[5] = 1836,},
			eventDuration = 552,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {79226},
			findEventOnMap = {},
			coor = {2024, 26.96, 46.46},
			datablock = {},
		},
		--Aylaag Camp
		[12] = {	eventName = L["Aylaag Camp"],
			texture = "MajorFactions_MapIcons_Centaur64",
			eventRegionOffset = {
				[1] = 1675566000,
				[2] = 1677571200,
				[3] = 1675612800,
				[4] = 1677571200,
				[5] = 1677571200,},
			eventDuration = 900,
			eventInterval = 270000,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {},
			achiveIDs = {16462},
			findEventOnMap = {},
			coor = {},
			datablock = {
				[0] = {eventName = L["River camp"], enable = true, coor = {2023, 55.37, 52.24},},
				[1] = {eventName = L["Aylaag Outpost"], enable = true, coor = {2023, 70.66, 63.00},},
				[2] = {eventName = L["Eaglewatch Outpost"], enable = true, coor = {2023, 71.47, 31.80,},},
			},
		},
		--Grand Hunts
		[13] = { eventName = L["Grand Hunts"],
			texture = "minimap-genericevent-hornicon-pressed",
			eventRegionOffset = {
				[1] = 10,
				[2] = 10,
				[3] = 10,
				[4] = 10,	
				[5] = 10,},
			eventDuration = 7140,
			eventInterval = 7200,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {},
			achiveIDs = {},
			findEventOnMap = {1978},
			coor = {},
			datablock = {},
		},
		--Radiant Echoes
		[14] = { eventName = L["Radiant Echoes"],
			texture = "UI-EventPoi-WorldSoulMemory",
			eventRegionOffset = {
				[1] = 43,
				[2] = 43,
				[3] = 43,
				[4] = 43,	
				[5] = 43,},
			eventDuration = 3600 - 360,
			eventInterval = 3600,
			enable = true,
			sound = false,
			voice_before = false,
			voice_active = false,
			anim = true,
			questIDs = {82540}, --id=78938,zone="Searing Gorge"},{id=82676,zone="Dustwallow Marsh"},{id=82689,zone="Dragonblight"
			achiveIDs = {},
			findEventOnMap = {},
			coor = {},
			datablock = {
				[0] = {eventName = C_Map.GetMapInfo(32).name, enable = true, coor = {32, 56.25, 44.73}, questID = 78938},
				[1] = {eventName = C_Map.GetMapInfo(70).name, enable = true, coor = {70, 51.46, 74.28,}, questID = 82676},
				[2] = {eventName = C_Map.GetMapInfo(115).name, enable = true, coor = {115, 60, 63.72}, questID = 82689},
			},
		},
	},
}

---------------------------------------------
-- Setup functions
SetupEventsTrackerMixin = {};
function SetupEventsTrackerMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2)
	self.IconSizeSlider:SetEnabled(true);
	self.IconSizeSlider:SetupSlider(L.cfg.iconSize);
	self.IconSpaceSlider:SetEnabled(true);
	self.IconSpaceSlider:SetupSlider(L.cfg.iconSpace);
	self.IconsInRowSlider:SetEnabled(true);
	self.IconsInRowSlider:SetupSlider(L.cfg.iconsInRow);
	self.FontSizeSlider:SetEnabled(true);
	self.FontSizeSlider:SetupSlider(L.cfg.fontSize);
	self.SpeakVolumeSlider:SetEnabled(true);
	self.SpeakVolumeSlider:SetupSlider(L.cfg.speakVolume);
	self.TimeBeforeSlider:SetEnabled(true);
	self.TimeBeforeSlider:SetupSlider(L.cfg.timeBefore);
	self.ExtendedTooltipCheckButton:SetControlChecked(L.cfg.extendedTooltip);
	
	local function onExtendedTooltipChecked(isChecked, isUserInput)
		L.cfg.extendedTooltip = isChecked
	end
	self.ExtendedTooltipCheckButton:SetCallback(onExtendedTooltipChecked);
	
	self.animIn:Play();
end

IconSizeSliderMixin = {};
function IconSizeSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 12, 40, 40 - 12, self.formatters);
end
function IconSizeSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function IconSizeSliderMixin:OnSliderValueChanged(value)
	L.cfg.iconSize = value;
	EventsTrackerFrame:ReloadAllEvents();
end

IconSpaceSliderMixin = {};
function IconSpaceSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 0, 16, 16, self.formatters);
end
function IconSpaceSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function IconSpaceSliderMixin:OnSliderValueChanged(value)
	L.cfg.iconSpace = value;
	EventsTrackerFrame:ReloadAllEvents();
end

IconsInRowSliderMixin = {};
function IconsInRowSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 1, 40, 40 - 1, self.formatters);
end
function IconsInRowSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function IconsInRowSliderMixin:OnSliderValueChanged(value)
	L.cfg.iconsInRow = value;
	EventsTrackerFrame:ReloadAllEvents();
end

FontSizeSliderMixin = {};
function FontSizeSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 7, 20, 20 - 7, self.formatters);
end
function FontSizeSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function FontSizeSliderMixin:OnSliderValueChanged(value)
	L.cfg.fontSize = value;
	EventsTrackerFrame:ReloadAllEvents();
end

SpeakVolumeSliderMixin = {};
function SpeakVolumeSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 1, 100, 99, self.formatters);
end
function SpeakVolumeSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function SpeakVolumeSliderMixin:OnSliderValueChanged(value)
	L.cfg.speakVolume = value;
end

TimeBeforeSliderMixin = {};
function TimeBeforeSliderMixin:SetupSlider(value)
	self.Slider:Init(value, 60, 600, 600-60, self.formatters);
end
function TimeBeforeSliderMixin:SetEnabled(enabled)
	self.Slider:SetEnabled(enabled);
end
function TimeBeforeSliderMixin:OnSliderValueChanged(value)
	L.cfg.timeBefore = value;
end



function EventsTrackerFrame:OnEvent(event, ...)
	local arg1 = ...
	if ( event == "ADDON_LOADED" ) then
		if arg1 == _ then
			selfName = UnitName("player") .. " - " .. GetRealmName();
			-- ak este neexistuje databaza alebo aktualne lognuty char v nej vytvorim ju
			if _G["EventsTrackerDB"] == nil then _G["EventsTrackerDB"] = {}; end
			if _G["EventsTrackerDB"][selfName] == nil then
				_G["EventsTrackerDB"][selfName] = {};
				_G["EventsTrackerDB"][selfName].class = select(2, UnitClass("player"));
				_G["EventsTrackerDB"][selfName].enable = true;
				_G["EventsTrackerDB"][selfName].events = {};
			end
			-- prekopiruj nove eventy pri novom chare alebo pridanom novom evente
			for i, v in pairs(DefaultConfig.events) do
				if _G["EventsTrackerDB"][selfName].events[i] == nil then
					_G["EventsTrackerDB"][selfName].events[i] = {};
					_G["EventsTrackerDB"][selfName].events[i].enable = v.enable;
					_G["EventsTrackerDB"][selfName].events[i].sound = v.sound;
					_G["EventsTrackerDB"][selfName].events[i].voice_before = v.voice_before;
					_G["EventsTrackerDB"][selfName].events[i].voice_active = v.voice_active;
					_G["EventsTrackerDB"][selfName].events[i].anim = v.anim;
				end
			end
			-- zmaz zvysne eventy pod char save
			if #DefaultConfig.events <  #_G["EventsTrackerDB"][selfName].events then
				for i = #DefaultConfig.events+1, #_G["EventsTrackerDB"][selfName].events do
					_G["EventsTrackerDB"][selfName].events[i] = nil
				end
			end
			-- pridaj nove hodnoty ak som neake prida pri update
			for key, value in pairs(DefaultConfig) do
				if _G["EventsTrackerDB"][selfName][key] == nil and type(value) ~= "table" then
					_G["EventsTrackerDB"][selfName][key] = value;
				end
			end
			
			L.cfg = _G["EventsTrackerDB"][selfName];
			
			-- ak nebol nastaveny savedposition pre ETH nastav ho z predchadzajucej pozicie uzivatela
			if not L.cfg.savedposition or (type(L.cfg.savedposition) ~= "table") then
				local point, relativeTo, relativePoint, xOfs, yOfs = EventsTrackerHeader:GetPoint(1);
				if point then
					L.cfg.savedposition = {point, relativeTo, relativePoint, xOfs, yOfs};
				else
					L.cfg.savedposition = {"CENTER", nil, "CENTER", 0, 0};
				end
			end
			-- pre ulozenie weekly reset time
			if _G["EventsTrackerSetup"] == nil then _G["EventsTrackerSetup"] = {}; end
			L.cfg.collapsed = false;
			EventsTrackerHeader.collapsed = L.cfg.collapsed;
						
			-- setup button - trochu komplikovane :(			
			EventsTrackerHeader.SetupButton:SetScript("OnClick", function(self, button)
				if button == "LeftButton" then
					if SetupEventsTrackerFrame:IsShown() then
						SetupEventsTrackerFrame:Hide();
						EventsTrackerHeader.SetupButton:SetButtonState("NORMAL", false);
					else
						SetupEventsTrackerFrame:Show();
						EventsTrackerHeader.SetupButton:SetButtonState("PUSHED", true);
					end
								
				elseif button == "RightButton"then
					local menuFrame = CreateFrame("Frame", "EventsMenuFrame", UIParent, "UIDropDownMenuTemplate");
					local menu = {};
					local eventListMenu = {};
					local copySetupMenu = {};
					local charactersEnableMenu = {};
					local selfName = UnitName("player") .. " - " .. GetRealmName();
					local selfColorStr = _G["EventsTrackerDB"][selfName].class and RAID_CLASS_COLORS[_G["EventsTrackerDB"][selfName].class].colorStr or "FFFFFFFF"
					
					-- vytvor Events enable menu list
					for i, v in ipairs(L.cfg.events) do
						tinsert(eventListMenu,
							{ text = DefaultConfig.events[i].eventName,
								checked = function() return v.enable; end,
								keepShownOnClick = 1,
								tooltipOnButton = 1,
								tooltipTitle = v.eventName,
								tooltipText = "Enable or diasable this event.",
								func = function()
									v.enable = not v.enable;
									EventsTrackerFrame:ReloadAllEvents();
									EventsTrackerFrame:SetPosition()
								end
							}
						)
					end
					
					-- vytvor character in tooltip enable/disable menu list 
					for charName in pairs(_G["EventsTrackerDB"]) do
						local classColorStr = _G["EventsTrackerDB"][charName].class and RAID_CLASS_COLORS[_G["EventsTrackerDB"][charName].class].colorStr or "FFFFFFFF"
						tinsert(charactersEnableMenu,
							{ text = charName,
								checked = function() return _G["EventsTrackerDB"][charName].enable; end,
								keepShownOnClick = 1,
								tooltipOnButton = 1,
								tooltipTitle = charName,
								tooltipText = (_G["EventsTrackerDB"][charName].enable and DISABLE or ENABLE).." |c"..classColorStr..charName.."|r > "..USE_UBERTOOLTIPS,
								colorCode = "|c" .. classColorStr,
								func = function() _G["EventsTrackerDB"][charName].enable = not _G["EventsTrackerDB"][charName].enable; end
							}
						)
					end
					
					-- vytvor Reset menu
					tinsert(copySetupMenu,
						{ text = RESET_TO_DEFAULT,
							notCheckable = 1,
							tooltipOnButton = 1,
							tooltipTitle = RESET_TO_DEFAULT,
							tooltipText = "|c"..selfColorStr .. selfName .."|r "..RESET_TO_DEFAULT,
							colorCode = "|cFFFF0000",
							func = function()
								EventsTrackerFrame:SetupReset()
								CloseDropDownMenus();
								if SetupEventsTrackerFrame:IsShown() then
									SetupEventsTrackerFrame:Hide()
								end
							end
						})
					
					-- vytvor Copy to all
					tinsert(copySetupMenu,
						{ text = CALENDAR_COPY_EVENT.." "..SETTINGS.." > "..ALL,
							notCheckable = 1,
							tooltipOnButton = 1,
							tooltipTitle = CALENDAR_COPY_EVENT.." "..SETTINGS,
							tooltipText = CALENDAR_COPY_EVENT.." |c"..selfColorStr .. selfName .."|r "..SETTINGS.." > "..ALL,
							colorCode = "|cFFFF0000",
							func = function()
								
								for charName in pairs(_G["EventsTrackerDB"]) do
									if charName ~= selfName then
										for key, value in pairs(L.cfg) do
											if ( key == "events" ) then
												for i, event in pairs(value) do
													for x, y in pairs(event) do
														if x ~= "isComplete" then
															if _G["EventsTrackerDB"][charName].events[i] == nil then
																_G["EventsTrackerDB"][charName].events[i] = {}
															end
															_G["EventsTrackerDB"][charName].events[i][x] = y;
														end
													end
												end
												
											elseif key ~= "class" and key ~= "enable" then
												_G["EventsTrackerDB"][charName][key] = value;
											end
										end
									end
								end
								CloseDropDownMenus();
							end
						})
					
					-- pridaj separator
					tinsert(copySetupMenu,
						{	text = "", hasArrow = false;	dist = 0; isTitle = true; isUninteractable = true; notCheckable = true; iconOnly = true;
							icon = "Interface\\Common\\UI-TooltipDivider-Transparent"; tCoordLeft = 0; tCoordRight = 1; tCoordTop = 0; tCoordBottom = 1; tSizeX = 0; tSizeY = 8; 	tFitDropDownSizeX = true;
							iconInfo = {	tCoordLeft = 0, tCoordRight = 1,	tCoordTop = 0, tCoordBottom = 1, tSizeX = 0, tSizeY = 8, tFitDropDownSizeX = true},
						})
											
					-- vytvor copy form selected char
					for charName in pairs(_G["EventsTrackerDB"]) do
						local classColorStr = _G["EventsTrackerDB"][charName].class and RAID_CLASS_COLORS[_G["EventsTrackerDB"][charName].class].colorStr or "FFFFFFFF"
						if charName ~= selfName then
							tinsert(copySetupMenu,
								{ text = charName,
									notCheckable = 1,
									tooltipOnButton = 1,
									tooltipTitle = charName,
									tooltipText = CALENDAR_COPY_EVENT.." |c"..classColorStr..charName.."|r "..SETTINGS.." > |c"..selfColorStr..selfName.."|r",
									colorCode = "|c" .. classColorStr,
									func = function()
										for key, value in pairs(_G["EventsTrackerDB"][charName]) do
											if ( key == "events" ) then
												for i, event in pairs(value) do
													for x, y in pairs(event) do
														if x ~= "isComplete" then
															_G["EventsTrackerDB"][selfName].events[i][x] = y;
															L.cfg.events[i][x] = y;
														end
													end
												end
												
											elseif key ~= "class" then
												_G["EventsTrackerDB"][selfName][key] = value;
												L.cfg[key] = value;
											end
										end
																				
										if SetupEventsTrackerFrame:IsShown() then
											SetupEventsTrackerFrame:Hide()
										end
										EventsTrackerFrame:ReloadAllEvents();
										EventsTrackerFrame:SetPosition()
										CloseDropDownMenus();
									end
								}
							)
						end
					end
					
	
					
					tinsert(menu, { text = ENABLE .." ".. EVENTS_LABEL, hasArrow = true, notCheckable = 1, menuList = eventListMenu});
					tinsert(menu, { text = USE_UBERTOOLTIPS, hasArrow = true, notCheckable = 1, menuList = charactersEnableMenu});
					if copySetupMenu and #copySetupMenu > 0 then
						tinsert(menu, { text = CALENDAR_COPY_EVENT.." "..SETTINGS, hasArrow = true, notCheckable = 1, menuList = copySetupMenu});
					end
					EventsTrackerFrame:EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
				end			
			end)
					
			function EventsTrackerAlertFrame_SetUp(self, str, sound)
				if str ~= nil then
					self.Text:SetText(str);
				end
				--https://github.com/Gethe/wow-ui-source/blob/live/Interface/SharedXML/SoundKitConstants.lua
				if sound then
					PlaySound(sound);
				end
			end

			EventsTrackerAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("EventsTrackerWarningTemplate", EventsTrackerAlertFrame_SetUp, 6, math.huge);
			
			--hooksecurefunc(ObjectiveTrackerManager, "OnPlayerEnteringWorld", afterPlayerEnteringWorld);
			--hooksecurefunc(QuestObjectiveTracker, "UpdateSingle", afterUpdateSingle);
			
			SLASH_ETRACKER1 = "/etracker"
			SlashCmdList["ETRACKER"] = function(msg)
				if ( msg == "reset" ) then
					self:SetupReset()
				end
			end
			
			if C_AddOns.IsAddOnLoaded(_) then
				self:UnregisterEvent('ADDON_LOADED');
			end
		end

	elseif ( event == "SCENARIO_UPDATE" ) then
		if arg1 == false then
			local bestMap = C_Map.GetBestMapForUnit("player");
			if bestMap == 2085 then
				EventsTrackerAlertSystem:AddAlert("You dont have active scenario, fly out and back to cave.", SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING);
			end
		elseif arg1 == nil then
			self:UpdateAllQuestCompleted();
		end
	
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		if not EventsTrackerHeader.collapsed then
			self:CallFunctionOutOfCombat(self:InstanceCheck());
		end
		
	elseif ( event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player" ) or event == "QUEST_TURNED_IN" or event == "ENCOUNTER_LOOT_RECEIVED" then
		self:UpdateAllQuestCompleted();
	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local isLogin, isReload = ...
		C_Timer.After(1, function()
			if not ObjectiveTrackerFrame:IsShown() then
				EventsTrackerHeader.collapsed = false;
				EventsTrackerHeader.CollapsedButton:SetButtonState("DISABLED");
				EventsTrackerHeader.CollapsedButton:GetNormalTexture():SetDesaturated(true)
			else
				EventsTrackerHeader.collapsed = L.cfg.collapsed;
				EventsTrackerHeader.CollapsedButton:SetButtonState(EventsTrackerHeader.collapsed and "PUSHED" or "NORMAL", EventsTrackerHeader.collapsed);
				EventsTrackerHeader.CollapsedButton:GetNormalTexture():SetDesaturated(false);
			end
			
			if not EventsTrackerHeader.collapsed then
				self:CallFunctionOutOfCombat(self:InstanceCheck());
			end
						
			self:WeeklyUpdate();
			self:ReloadAllEvents();
			self:SetPosition();
			self:UpdateAllQuestCompleted();
		end)
			
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		for _, function_tbl in ipairs(self.FUNC_QUEUE_TABLE) do
			if type(function_tbl[1]) == 'function' then
				function_tbl[1](unpack(function_tbl[2]));
			end
		end
		wipe(self.FUNC_QUEUE_TABLE);
		
	elseif ( event == "GUILDBANK_UPDATE_WITHDRAWMONEY" ) then
		self:WeeklyUpdate();
	end
end

for _, event in pairs({
	"ADDON_LOADED",
	"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED_NEW_AREA",
	"UNIT_QUEST_LOG_CHANGED",
	"QUEST_TURNED_IN",
	"SCENARIO_UPDATE",
	"PLAYER_REGEN_ENABLED",				-- pre spustenie funkcii outOfCombat
	"GUILDBANK_UPDATE_WITHDRAWMONEY",	-- GUILDBANK_UPDATE_WITHDRAWMONEY, TREASURE_PICKER_CACHE_FLUSH pre weekly update ak je player online pocas weekly resetu
	"ENCOUNTER_LOOT_RECEIVED",			-- pre Trial of the element
}) do EventsTrackerFrame:RegisterEvent(event) end

EventsTrackerFrame:SetScript("OnEvent", EventsTrackerFrame.OnEvent)

---------------------------------------------
-- Pomocne funkcie
EventsTrackerFrame.FUNC_QUEUE_TABLE = {}
function EventsTrackerFrame:CallFunctionOutOfCombat(funcName, ...)
	if type(funcName) == 'function' then
		if InCombatLockdown() then
			table_insert(self.FUNC_QUEUE_TABLE,{funcName,{...}})
		else
			funcName(...)
		end
    end
end
--/run EventsTrackerFrame:FindEventOnAllMaps("poi")
function EventsTrackerFrame:FindEventOnAllMaps(wantedEventName)
	--AreaPOI
	if wantedEventName == "poi" then
		for uiMapID = 2000, 2200 do
			local info = C_Map.GetMapInfo(uiMapID)
			if info then
				local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID);
				for _, ids in pairs(areaPoiIDs) do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, ids);
					if poiInfo then
						print("POI : "..info.name .. "("..uiMapID..") - |cFF40B040"..poiInfo.name.."|r ".. (poiInfo.isPrimaryMapForPOI and "|cFF20FF20TRUE|r" or "|cFFff2020FALSE|r") .. poiInfo.areaPoiID)
						--for k, v in pairs(poiInfo) do
						--	print(k, v)
						--end
					end
				end
			end
		end
	end
	
	--Delves
	if wantedEventName == "del" then
		for uiMapID = 1900, 2200 do
			local info = C_Map.GetMapInfo(uiMapID)
			if info then
				local areaPoiIDs = C_AreaPoiInfo.GetDelvesForMap(uiMapID)
				if areaPoiIDs then
					for _, ids in pairs(areaPoiIDs) do
						local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, ids);
						if poiInfo then
							print("Delves : "..info.name .. "("..uiMapID..") - |cFF40B040"..poiInfo.name.."|r ".. (poiInfo.isPrimaryMapForPOI and "|cFF20FF20TRUE|r" or "|cFFff2020FALSE|r") .. poiInfo.areaPoiID)
						end
					end
				end
			end
		end
	end
	--DragonridingRaces
	for uiMapID = 1900, 2200 do
		local info = C_Map.GetMapInfo(uiMapID)
		if info then
			local areaPoiIDs = C_AreaPoiInfo.GetDragonridingRacesForMap(uiMapID)
			if areaPoiIDs then
				for _, ids in pairs(areaPoiIDs) do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, ids);
					if wantedEventName == "dri" or poiInfo.name == wantedEventName then
						print("DRI :"..info.name .. "("..uiMapID..") - |cFF40B040"..poiInfo.name.."|r ".. (poiInfo.isPrimaryMapForPOI and "|cFF20FF20TRUE|r" or "|cFFff2020FALSE|r") .. poiInfo.areaPoiID)
					end
				end
			end
		end
	end
	--EVENTS
	if wantedEventName == "eve" then
		for uiMapID = 2200, 2200 do
			local info = C_Map.GetMapInfo(uiMapID)
			if info then
				local areaPoiIDs = C_AreaPoiInfo.GetEventsForMap(uiMapID)
				if areaPoiIDs then
					for _, ids in pairs(areaPoiIDs) do
						local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, ids);
						if poiInfo then
							local time = C_AreaPoiInfo.GetAreaPOISecondsLeft(ids) or "notime"
							print("EVENTS: :"..info.name .. "("..uiMapID..") - |cFF40B040"..poiInfo.name.."|r ".. (poiInfo.isPrimaryMapForPOI and "|cFF20FF20TRUE|r " or "|cFFff2020FALSE|r ") .. time, poiInfo.areaPoiID)
							for k, v in pairs(poiInfo) do
								print(k, v)
							end
						end
					end
				end
			end
		end
	end
	-- bounties
	if wantedEventName == "bou" then
		for uiMapID = 2000, 2200 do
			local info = C_Map.GetMapInfo(uiMapID)
			if info then
				local bounties = C_QuestLog.GetBountiesForMapID(uiMapID)
				if bounties then
					print(uiMapID)
					for k, v in pairs(bounties) do
						print(C_QuestLog.GetTitleForQuestID(v.questID))
					end
				end
			end
		end
	end
	
end


function EventsTrackerFrame:GetLocaleText(str)
	return L[str] or UNKNOWN;
end

local function SetTextureForEventFrame(frame, texture)
	if tonumber(texture) then
		frame.icon:SetTexture(texture);
		frame.icon:SetTexCoord(.08, .92, 0.08, 0.92);
	else
		local info = C_Texture.GetAtlasInfo(texture);
		if info then 
			frame.icon:SetAtlas(texture);
		else
			frame.icon:SetTexture(texture);
		end
	end
end

local function isQuestCompleted(questIDTable)
	local completed = 0;
	if questIDTable and (type(questIDTable) == "table") then
		for _, questID in pairs(questIDTable) do
			if (C_QuestLog.IsOnQuest(questID)) then
				isCompleted = C_QuestLog.IsComplete(questID);
			else
				isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID);
			end
			
			if isCompleted then
				completed = completed + 1;
			end
		end
	end
	return (completed > 0)
end

function EventsTrackerFrame:InstanceCheck()
	if IsInInstance() then
		if EventsTrackerHeader:IsShown() then
			EventsTrackerFrame:ReloadAllEvents(true);
			EventsTrackerHeader:Hide();
		end
	elseif not EventsTrackerHeader:IsShown() then
		EventsTrackerFrame:ReloadAllEvents(false);
		EventsTrackerHeader:Show();
	end
end

function EventsTrackerFrame:SetupReset()
	for key, value in pairs(DefaultConfig.events) do
		L.cfg.events[key].enable = value.enable;
		L.cfg.events[key].sound = value.sound;
		L.cfg.events[key].voice_before = value.voice_before;
		L.cfg.events[key].voice_active = value.voice_active;
		L.cfg.events[key].anim = value.anim;
	end
	
	L.cfg.collapsed = DefaultConfig.collapsed;
	EventsTrackerHeader.collapsed = L.cfg.collapsed;
	L.cfg.iconSize = DefaultConfig.iconSize;
	L.cfg.iconSpace = DefaultConfig.iconSpace;
	L.cfg.iconsInRow = DefaultConfig.iconsInRow;
	L.cfg.fontSize = DefaultConfig.fontSize;
	L.cfg.speakVolume = DefaultConfig.speakVolume;
	L.cfg.timeBefore = DefaultConfig.timeBefore;
	L.cfg.savedposition = {"CENTER", nil, "CENTER", 0, 0};
	
	self:SetPosition();	
	self:ReloadAllEvents();
end

function EventsTrackerFrame:GetLinkToEvent(index)
	return L.cfg.events[index];
end

function EventsTrackerFrame:GetLinkToFullEvent(index)
	return DefaultConfig.events[index];
end

function EventsTrackerFrame:GetTimeBefore()
	return L.cfg.timeBefore;
end

function EventsTrackerFrame:SetPosition()
	EventsTrackerHeader.CollapsedButton:SetButtonState(EventsTrackerHeader.collapsed and "PUSHED" or "NORMAL", EventsTrackerHeader.collapsed);
	EventsTrackerHeader:ClearAllPoints();
	EventsTrackerHeader:SetParent(_G.UIParent);
	EventsTrackerHeader:SetPoint(unpack(L.cfg.savedposition));
	EventsTrackerHeader:EnableMouse(true);
	EventsTrackerHeader.Background:SetAlpha(0.9);
end

function EventsTrackerFrame:SetCollapsed()
	L.cfg.collapsed = not L.cfg.collapsed;
	EventsTrackerHeader.collapsed = L.cfg.collapsed;
	EventsTrackerFrame:ReloadAllEvents();
	EventsTrackerFrame:SetPosition();
end

function EventsTrackerFrame:SavePosition(point, relativeTo, relativePoint, xOfs, yOfs)
	L.cfg.savedposition = {point, relativeTo, relativePoint, xOfs, yOfs};
end

function EventsTrackerFrame:UpdateAllQuestCompleted()
	for i, v in ipairs(L.cfg.events) do
		if next(DefaultConfig.events[i].questIDs) then
			local isComplete = isQuestCompleted(DefaultConfig.events[i].questIDs);
			if v.enable and eventFrame[i] then
				eventFrame[i].icon:SetDesaturated(isComplete);
			end
			L.cfg.events[i].isComplete = isComplete;
			_G["EventsTrackerDB"][selfName].events[i].isComplete = isComplete;
		end
	end
end

function EventsTrackerFrame:GetToolTipComplete(index)
	local completeOnCurrentChar = "";
	local extendedTooltip = "";
	
	if L.cfg.extendedTooltip and DefaultConfig.events[index].datablock and next(DefaultConfig.events[index].datablock) then
		local isActive = eventFrame[index].isEventActiveNew and SPEC_ACTIVE or NEXT
		for i = 0, #DefaultConfig.events[index].datablock do
			if DefaultConfig.events[index].datablock[i].enable then
				local questComplete = DefaultConfig.events[index].datablock[i].questID and isQuestCompleted({DefaultConfig.events[index].datablock[i].questID})
				
				if questComplete ~= nil then
					extendedTooltip = extendedTooltip .. "  "..(questComplete and CreateAtlasMarkup("common-icon-checkmark", 16, 16) or CreateAtlasMarkup("common-icon-redx", 16, 16));
				end
				
				local color = eventFrame[index].tooltipTitle == DefaultConfig.events[index].datablock[i].eventName and "|cFF00FF00"..isActive.." : " or  "|cFF408000"
				extendedTooltip = extendedTooltip .. color .. DefaultConfig.events[index].datablock[i].eventName .."|r";
								
				extendedTooltip = extendedTooltip .. "\n";
			end
		end
		extendedTooltip = extendedTooltip .. "\n";
	end
	
	if next(DefaultConfig.events[index].questIDs) then 
		if _G["EventsTrackerDB"][selfName].events[index].isComplete then
			--CRITERIA_COMPLETED SLASH_TEXTTOSPEECH_ON ,CRITERIA_NOT_COMPLETED
			completeOnCurrentChar = "|cFF00FF00"..CRITERIA_COMPLETED.." : "..selfName.."|r";
		else
			completeOnCurrentChar = "|cFFFF0000"..CRITERIA_NOT_COMPLETED.." : "..selfName.."|r";
		end
	
		if L.cfg.extendedTooltip then
			local showed = false
			for charName in pairs(_G["EventsTrackerDB"]) do
				if charName ~= selfName and _G["EventsTrackerDB"][charName].enable then
					if not _G["EventsTrackerDB"][charName].events[index] or  _G["EventsTrackerDB"][charName].events[index].isComplete == nil or not _G["EventsTrackerDB"][charName].events[index].isComplete then
						local classColorStr = _G["EventsTrackerDB"][charName].class and RAID_CLASS_COLORS[_G["EventsTrackerDB"][charName].class].colorStr or "FFFFFFFF";
						if not showed then
							showed = true;
							extendedTooltip = extendedTooltip .. "|cFFFF0000"..CRITERIA_NOT_COMPLETED.." : ".."|r\n";
						end
						
						extendedTooltip = extendedTooltip .. "  |c"..classColorStr .. charName .. "|r\n";
					end
				end
			end
		end
	end
	
	if L.cfg.extendedTooltip and DefaultConfig.events[index].achiveIDs and next(DefaultConfig.events[index].achiveIDs) then
		for _, achievementId in pairs(DefaultConfig.events[index].achiveIDs) do
			for i = 1, GetAchievementNumCriteria(achievementId) do
				local criteriaString, _, completed = GetAchievementCriteriaInfo(achievementId, i);
				extendedTooltip = extendedTooltip .. (completed and "|cFF00FF00" or "|cFFFF0000") .. criteriaString .. "|r\n";
			end
		end
	end
			
	return completeOnCurrentChar, extendedTooltip;	
end

function EventsTrackerFrame:WeeklyUpdate()
	local weeklyResetTime = C_DateAndTime.GetSecondsUntilWeeklyReset();
	if _G["EventsTrackerSetup"].savedResetTime and _G["EventsTrackerSetup"].savedResetTime < weeklyResetTime then
		print("|cFFFF0000Events tracker weekly reset.|r");
		for charName in pairs(_G["EventsTrackerDB"]) do
			for i in pairs(_G["EventsTrackerDB"][charName].events) do
				if i > #DefaultConfig.events then
					_G["EventsTrackerDB"][charName].events[i] = nil;
				elseif next(DefaultConfig.events[i].questIDs) then
					_G["EventsTrackerDB"][charName].events[i].isComplete = false;
				end
			end
		end
	end
	_G["EventsTrackerSetup"].savedResetTime = weeklyResetTime;
end

local function FindNextEventInDataBlock(self, index)
	for i = 0, #DefaultConfig.events[self.index].datablock do
		if not DefaultConfig.events[self.index].datablock[index].enable then
			self.timeTmp = (self.timeTmp or 0) + DefaultConfig.events[self.index].eventInterval;
		else
			return index;
		end
		index = index == #DefaultConfig.events[self.index].datablock and 0 or (index + 1);
	end
	return index;
end

local function SecondsToEventTime(seconds)
	local units = ConvertSecondsToUnits(seconds);
	if units.hours > 0 then
		return format("%dh%.2d", units.hours, units.minutes);
	else
		return format(MINUTES_SECONDS, units.minutes, units.seconds);
	end
end
		
local function CreateEventFrame(v, index)
	local eFrame = CreateFrame("Button", nil, EventsTrackerHeader, "EventsTrackerButton");
	local serverResetTime = GetServerTime() - (604800 - C_DateAndTime.GetSecondsUntilWeeklyReset());
	local region = GetCurrentRegion();
	-- ptr
	if not region or region > 5 then
		region = 1;
	end
	
	eFrame.index = index;
	eFrame.initComplete = false;
	eFrame.notification = false;
	eFrame.isEventActiveOld = nil;
	eFrame.timeTmp = nil;
		
	eFrame.enable = v.enable;
	eFrame.sound = v.sound;
	eFrame.voice_before = v.voice_before;
	eFrame.voice_active = v.voice_active;
	eFrame.anim = v.anim;
	eFrame.isComplete = v.isComplete;
	
	eFrame.tooltipTitle = DefaultConfig.events[index].eventName;
	eFrame.coor = DefaultConfig.events[index].coor;
	eFrame.eventNewRegionOffset = DefaultConfig.events[index].eventRegionOffset[region] > 1600000000 and DefaultConfig.events[index].eventRegionOffset[region] or (serverResetTime + DefaultConfig.events[index].eventRegionOffset[region]);
	
	SetTextureForEventFrame(eFrame, DefaultConfig.events[index].texture);
	eFrame.icon:SetDesaturated(v.isComplete);
	
	eFrame:SetScript("OnUpdate", function(self, elapsed)
		if self.initComplete then
			self.elapsed = (self.elapsed or 1) + elapsed;
			if self.elapsed < 1 then return end
			self.elapsed = 0;
		end
	
		if not self:IsShown() then return end
		
		self.timeFromFirstStart = GetServerTime() - self.eventNewRegionOffset;
		self.timeToNextEvent = (DefaultConfig.events[self.index].eventInterval - self.timeFromFirstStart % DefaultConfig.events[self.index].eventInterval) + (self.timeTmp and self.timeTmp or 0);
		self.timeActiveEvent = self.timeTmp and self.timeToNextEvent or DefaultConfig.events[self.index].eventDuration - (DefaultConfig.events[self.index].eventInterval - self.timeToNextEvent);
		self.isEventActiveNew = (DefaultConfig.events[self.index].eventInterval + (self.timeTmp and self.timeTmp or 0)) - self.timeToNextEvent <= DefaultConfig.events[self.index].eventDuration;
		self.showedTime = self.isEventActiveNew and self.timeActiveEvent or self.timeToNextEvent;
				
		if not self.initComplete or (self.isEventActiveOld and not self.isEventActiveNew) then
			if (self.isEventActiveOld and not self.isEventActiveNew) then self.isEventActiveOld = false end
			
			self.timer:SetTextColor(.9, .9, .9);
			self.timeTmp = nil;
						
			-- hladam dalsi event v databloku ak je neaky disabled preskocim ho a pripocitam cas
			if next(DefaultConfig.events[self.index].datablock) then
				local index = math.floor(((self.timeFromFirstStart + (not self.isEventActiveNew and DefaultConfig.events[self.index].eventInterval or 0)) / DefaultConfig.events[self.index].eventInterval) % (#DefaultConfig.events[self.index].datablock + 1));
							
				-- ak su nasledujuce eventy v databloku vypnute najdem prvy aktivny a upravim cas
				index = FindNextEventInDataBlock(self, index);
				self.tooltipTitle = DefaultConfig.events[self.index].datablock[index].eventName;
				self.coor = DefaultConfig.events[self.index].datablock[index].coor;
				
			elseif next(DefaultConfig.events[self.index].findEventOnMap) then
				-- po ukonceni eventu (napr. elemental storm) alebo prvom nastaveni zmen na zakladnu iconu a popis
				self.tooltipTitle = DefaultConfig.events[self.index].eventName;
				SetTextureForEventFrame(self, DefaultConfig.events[self.index].texture);
				self.icon:SetDesaturated(true);
				wipe(self.coor);
			end
		end
			
		if not self.isEventActiveOld and self.isEventActiveNew then
			if self.timeTmp and self.timeTmp > 0 then
				self.timeTmp = self.timeTmp - DefaultConfig.events[self.index].eventInterval;
							
			elseif DefaultConfig.events[self.index].eventDuration > 0 then
				if next(DefaultConfig.events[self.index].findEventOnMap) then
					local name, mapID, x, y, atlasName, toolTip = EventsTrackerFrame:FindEventOnMaps(DefaultConfig.events[self.index].areaPoiID, DefaultConfig.events[self.index].findEventOnMap);
					if mapID then
						self.tooltipTitle = toolTip
						self.coor = {mapID, x, y};
						if atlasName then
							self.icon:SetAtlas(atlasName);
						end
						self.icon:SetDesaturated(self.isComplete and true or false);
					else
						self.tooltipTitle = DefaultConfig.events[self.index].eventName;
						SetTextureForEventFrame(self, DefaultConfig.events[self.index].texture);
						self.icon:SetDesaturated(true);
						wipe(self.coor);
						--return;
					end
				end
				
				self.timer:SetTextColor(0, 1, 0);
				if self.anim and not self.icon.Anim:IsPlaying() then
					self.icon.Anim:Play();
				end
				if self.voice_active and self.initComplete then 
					C_VoiceChat.SpeakText(0, DefaultConfig.events[self.index].eventName.." is active.", 1, 0, L.cfg.speakVolume);
				end
			end
			self.isEventActiveOld = true;
			
		elseif not self.isEventActiveNew then
			if self.showedTime < L.cfg.timeBefore and not self.timeTmp then
				if not self.notification then
					if self.sound and self.initComplete then
						PlaySound(32585, "Master");
					end
					if self.voice_before and self.initComplete then 
						C_VoiceChat.SpeakText(0, DefaultConfig.events[self.index].eventName.." event will start in a moment.", 1, 0, L.cfg.speakVolume);
					end
					if self.anim and not self.icon.Anim:IsPlaying() then
						self.icon.Anim:Play();
					end
					self.timer:SetTextColor(1, 1, 0);
					self.notification = true;
				end
			elseif self.notification then
				self.notification = false;
			end
		end
		
		self.timer:SetText(SecondsToEventTime(self.showedTime))
		self.initComplete = true;
	end)

	return eFrame;
end

local function EasyMenu_Initialize( frame, level, menuList )
	for index = 1, #menuList do
		local value = menuList[index]
		if (value.text) then
			value.index = index;
			UIDropDownMenu_AddButton( value, level );
		end
	end
end

function EventsTrackerFrame:EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay )
	if ( displayMode == "MENU" ) then
		menuFrame.displayMode = displayMode;
	end
	UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList);
	ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay);
end

function EventsTrackerFrame:CreateContextMenu(region, tbls)
	MenuUtil.CreateContextMenu(region, function(owner, rootDescription)
		rootDescription:SetTag("MENU_CLASS_FILTER");

		for index, tbl in ipairs(tbls) do
			if tbl.divider then
				rootDescription:CreateDivider();
			else
				--local button = rootDescription:CreateButton(tbl.text, tbl.func);
				local button = rootDescription:CreateCheckbox(tbl.text, tbl.checked, tbl.func)
				
			end
		end
	end);
end

function EventsTrackerFrame:ReloadAllEvents(hideAll)
	local firstEventFrame, lastEventFrame;
	local iconsInRowCount = 0;
	local iconsInRowCalculated = L.cfg.iconsInRow;
			
	for i, v in ipairs(L.cfg.events) do
		if not hideAll and v.enable then
			if not eventFrame[i] then
				eventFrame[i] = CreateEventFrame(v, i);
			end
			eventFrame[i]:SetSize(L.cfg.iconSize, L.cfg.iconSize);
			eventFrame[i].icon:SetSize(L.cfg.iconSize + 6, L.cfg.iconSize + 6)
			eventFrame[i]:ClearAllPoints();
			eventFrame[i].timer:SetFont("Interface\\AddOns\\EventsTracker\\Media\\Alte.ttf", L.cfg.fontSize, "OUTLINE");
			
			iconsInRowCount = (iconsInRowCount or 0) + 1;
			if not lastEventFrame then
				eventFrame[i]:SetPoint("TOPLEFT", EventsTrackerHeader, "TOPRIGHT", 4, -5);
				firstEventFrame = eventFrame[i];
				eventTrackerHeight = L.cfg.iconSize;
			elseif iconsInRowCount > iconsInRowCalculated then
				eventFrame[i]:SetPoint("TOP", firstEventFrame, "BOTTOM", 0, -12);
				firstEventFrame = eventFrame[i];
				iconsInRowCount = 1;
				eventTrackerHeight = eventTrackerHeight + L.cfg.iconSize + 6;
			else
				eventFrame[i]:SetPoint("LEFT", lastEventFrame, "RIGHT", L.cfg.iconSpace, 0);
			end
			
			eventFrame[i].enable = true;
			eventFrame[i]:Show();
			lastEventFrame = eventFrame[i];
			
		elseif eventFrame[i] then
			eventFrame[i]:Hide();
			eventFrame[i]:SetScript("OnUpdate", nil);
			eventFrame[i] = nil;
		end
	end
end

