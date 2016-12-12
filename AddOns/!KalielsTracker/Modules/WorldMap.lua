--- Kaliel's Tracker
--- Copyright (c) 2012-2016, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_WorldMap")
KT.WorldMap = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db

local trackingDropDownFrame, levelDropDownFrame

--------------
-- Internal --
--------------

local function SetHooks()
    -- Map Tracking Options DropDown
    function WorldMapTrackingOptionsDropDown_Initialize()   -- replacement
        local info = MSA_DropDownMenu_CreateInfo();

        info.isTitle = true;
        info.notCheckable = true;
        info.text = WORLD_MAP_FILTER_TITLE;
        MSA_DropDownMenu_AddButton(info);

        info.isTitle = nil;
        info.disabled = nil;
        info.notCheckable = nil;
        info.isNotRadio = true;
        info.keepShownOnClick = true;
        info.func = WorldMapTrackingOptionsDropDown_OnClick;

        info.text = SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT;
        info.value = "quests";
        info.checked = GetCVarBool("questPOI");
        MSA_DropDownMenu_AddButton(info);

        local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
        if arch then
            info.text = ARCHAEOLOGY_SHOW_DIG_SITES;
            info.value = "digsites";
            info.checked = GetCVarBool("digSites");
            MSA_DropDownMenu_AddButton(info);
        end

        if CanTrackBattlePets() then
            info.text = SHOW_PET_BATTLES_ON_MAP_TEXT;
            info.value = "tamers";
            info.checked = GetCVarBool("showTamers");
            MSA_DropDownMenu_AddButton(info);
        end

        -- If we aren't on a map with world quests don't show the world quest reward filter options.
        if not WorldMapFrame.UIElementsFrame.BountyBoard or not WorldMapFrame.UIElementsFrame.BountyBoard:AreBountiesAvailable() then
            return;
        end

        if prof1 or prof2 then
            info.text = SHOW_PRIMARY_PROFESSION_ON_MAP_TEXT;
            info.value = "primaryProfessionsFilter";
            info.checked = GetCVarBool("primaryProfessionsFilter");
            MSA_DropDownMenu_AddButton(info);
        end

        if fish or cook or firstAid then
            info.text = SHOW_SECONDARY_PROFESSION_ON_MAP_TEXT;
            info.value = "secondaryProfessionsFilter";
            info.checked = GetCVarBool("secondaryProfessionsFilter");
            MSA_DropDownMenu_AddButton(info);
        end

        MSA_DropDownMenu_AddSeparator(info);
        -- Clear out the info from the separator wholesale.
        info = MSA_DropDownMenu_CreateInfo();

        info.isTitle = true;
        info.notCheckable = true;
        info.text = WORLD_QUEST_REWARD_FILTERS_TITLE;
        MSA_DropDownMenu_AddButton(info);
        info.text = nil;

        info.isTitle = nil;
        info.disabled = nil;
        info.notCheckable = nil;
        info.isNotRadio = true;
        info.keepShownOnClick = true;
        info.func = WorldMapTrackingOptionsDropDown_OnClick;

        info.text = WORLD_QUEST_REWARD_FILTERS_ORDER_RESOURCES;
        info.value = "worldQuestFilterOrderResources";
        info.checked = GetCVarBool("worldQuestFilterOrderResources");
        MSA_DropDownMenu_AddButton(info);

        info.text = WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER;
        info.value = "worldQuestFilterArtifactPower";
        info.checked = GetCVarBool("worldQuestFilterArtifactPower");
        MSA_DropDownMenu_AddButton(info);

        info.text = WORLD_QUEST_REWARD_FILTERS_PROFESSION_MATERIALS;
        info.value = "worldQuestFilterProfessionMaterials";
        info.checked = GetCVarBool("worldQuestFilterProfessionMaterials");
        MSA_DropDownMenu_AddButton(info);

        info.text = WORLD_QUEST_REWARD_FILTERS_GOLD;
        info.value = "worldQuestFilterGold";
        info.checked = GetCVarBool("worldQuestFilterGold");
        MSA_DropDownMenu_AddButton(info);

        info.text = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT;
        info.value = "worldQuestFilterEquipment";
        info.checked = GetCVarBool("worldQuestFilterEquipment");
        MSA_DropDownMenu_AddButton(info);
    end

    local function WorldMapTrackingOptionsDropDown_OnClick(self, button)
        local parent = self:GetParent()
        MSA_ToggleDropDownMenu(1, nil, trackingDropDownFrame, parent, 0, -5, nil, nil, MSA_DROPDOWNMENU_SHOW_TIME)
        PlaySound("igMainMenuOptionCheckBoxOn")
    end
    WorldMapFrame.UIElementsFrame.TrackingOptionsButton.Button:SetScript("OnClick", WorldMapTrackingOptionsDropDown_OnClick)    -- replacement

    -- Map Level DropDown
    function WorldMapLevelDropDown_Initialize()     -- replacement
        local info = MSA_DropDownMenu_CreateInfo();
        local level = GetCurrentMapDungeonLevel();
        if (DungeonUsesTerrainMap()) then
            level = level - 1;
        end

        local mapname = strupper(GetMapInfo() or "");
        local dungeonLevels = { GetNumDungeonMapLevels() };

        for i, floorNum in ipairs(dungeonLevels) do
            local floornameToken = "DUNGEON_FLOOR_" .. mapname .. floorNum;
            local floorname =_G[floornameToken];
            info.text = floorname or string.format(FLOOR_NUMBER, i);
            info.func = WorldMapLevelButton_OnClick;
            info.checked = (floorNum == level);
            MSA_DropDownMenu_AddButton(info);
        end
    end

    function WorldMapLevelDropDown_Update()     -- replacement
        MSA_DropDownMenu_Initialize(levelDropDownFrame, WorldMapLevelDropDown_Initialize);
        MSA_DropDownMenu_SetWidth(levelDropDownFrame, 130);

        local dungeonLevels = { GetNumDungeonMapLevels() };
        if ( #dungeonLevels <= 1 ) then
            MSA_DropDownMenu_ClearAll(levelDropDownFrame);
            levelDropDownFrame:Hide();
        else
            local level = GetCurrentMapDungeonLevel();
            if (DungeonUsesTerrainMap()) then
                level = level - 1;
            end

            -- find the current floor in the list of levels, that's its ID in the dropdown
            local levelID = 1;
            for id, floorNum in ipairs(dungeonLevels) do
                if (floorNum == level) then
                    levelID = id;
                end
            end

            MSA_DropDownMenu_SetSelectedID(levelDropDownFrame, levelID);
            levelDropDownFrame:Show();
            if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
            end
        end
    end

    function WorldMapLevelButton_OnClick(self)      -- replacement
        local dropDownID = self:GetID();
        MSA_DropDownMenu_SetSelectedID(levelDropDownFrame, dropDownID);

        local dungeonLevels = { GetNumDungeonMapLevels() };
        if (dropDownID <= #dungeonLevels) then
            local level = dungeonLevels[dropDownID];
            if (DungeonUsesTerrainMap()) then
                level = level + 1;
            end
            SetDungeonMapLevel(level);
            WorldMapScrollFrame_ResetZoom()
        end
    end

    -- World Map protected frame fix
    -- TODO: Identify all taints!
    local bck_WorldMapFrame_UIElementsFrame_ActionButton_Refresh = WorldMapFrame.UIElementsFrame.ActionButton.Refresh
    function WorldMapFrame.UIElementsFrame.ActionButton:Refresh()
        if InCombatLockdown() then return end
        bck_WorldMapFrame_UIElementsFrame_ActionButton_Refresh(self)
    end

    local bck_WorldMapFrame_UIElementsFrame_BountyBoard_Refresh = WorldMapFrame.UIElementsFrame.BountyBoard.Refresh
    function WorldMapFrame.UIElementsFrame.BountyBoard:Refresh()
        if InCombatLockdown() then return end
        bck_WorldMapFrame_UIElementsFrame_BountyBoard_Refresh(self)
    end

    local bck_WorldMapFrame_UpdateOverlayLocations = WorldMapFrame_UpdateOverlayLocations
    WorldMapFrame_UpdateOverlayLocations = function()
        if InCombatLockdown() then return end
        bck_WorldMapFrame_UpdateOverlayLocations()
    end

    local bck_WorldMapScrollFrame_ResetZoom = WorldMapScrollFrame_ResetZoom
    WorldMapScrollFrame_ResetZoom = function()
        if InCombatLockdown() then return end
        bck_WorldMapScrollFrame_ResetZoom()
    end
end

local function SetFrames()
    -- Map Tracking Options DropDown frame
    trackingDropDownFrame = CreateFrame("Frame", addonName.."WorldMapDropDown", WorldMapFrame.UIElementsFrame.TrackingOptionsButton, "MSA_DropDownMenuTemplate")
    MSA_DropDownMenu_Initialize(trackingDropDownFrame, WorldMapTrackingOptionsDropDown_Initialize, "MENU")

    -- Map Level DropDown frame
    levelDropDownFrame = CreateFrame("Frame", addonName.."WorldMapLevelDropDown", WorldMapFrame.UIElementsFrame, "MSA_DropDownMenuTemplate")
    levelDropDownFrame:SetPoint("TOPLEFT", -17, 2)
    WorldMapLevelDropDown:Hide()
end

--------------
-- External --
--------------

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
    SetFrames()
end