Narci = {};

local DefaultValue = {
    ["DetailedIlvlInfo"] = true,
    ["IsSortedByCategory"] = true,
    ["EnableGrainEffect"] = false,
    ["ShowMinimapButton"] = true,
    ["FontHeightItemName"] = 10,
    ["GlobalScale"] = 0.8,
    ["AutoColorTheme"] = true,
    ["ColorChoice"] = 0,
    ["EnableDoubleTap"] = false,
    ["CameraOrbit"] = true,
    ["CameraSafeMode"] = true,
    ["BorderTheme"] = "Bright",
    ["TooltipTheme"] = "Dark",
    ["TruncateText"] = false,
    ["ItemNameWidth"] = 180,
    ["FadeButton"] = false,
    ["WeatherEffect"] = true,
    ["VignetteStrength"] = 0.5,
    ["FadeMusic"] = true,
    ["AlwaysShowModel"] = false,
    ["DefaultLayout"] = 2,
    ["ShowFullBody"] = true,
    ["LetterboxEffect"] = false,
    ["LetterboxRatio"] = 2.35,
    ["AFKScreen"] = false,
    ["GemManager"] = true,                          --Enable gem manager for Blizzard item socketing frame
    ["DressingRoom"] = true,                        --Enable dressing room module
    ["DressingRoomUseTargetModel"] = true,          --Replace the the dressing room room with your targeted player
    ["DressingRoomIncludeItemID"] = false,          --Show Item ID in the clipboard
    ["UseEntranceVisual"] = true,
    ["ModelPanelScale"] = 1,
    ["UseExitConfirmation"] = true,                 --Show exit confirmation dialog upon leaving group photo mode
    ["BaseLineOffset"] = 0,                         --Ultra-wide
    ["ShrinkArea"] = 0,                             --Reduce the width of the area where you can control the model
    ["AutoPlayAnimation"] = true,                   --Play recommended animation when clicking a spell visual entry
    ["UseBustShot"] = true,                         --Zoom in to the upper torso
    ["EyeColor"] = 1,                               --Corruption Indicator Orange
    ["CorruptionBar"] = true,
    ["CorruptionTooltip"] = false,
    ["CorruptionTooltipModel"] = true,
    ["UseEscapeButton"] = true,                     --Use Escape button to exit
    ["IndependentMinimapButton"] = false,           --Set Minimap Button Parent to Minimap or UIParent
}

local TutorialInclude = {
    "SpellVisualBrowser", "EquipmentSetManager", "Movement", "ExitConfirmation", "IndependentMinimapButton"
};

local function Initialize_NarcissusDB()
    NarcissusDB = NarcissusDB or {};        --Account-wide Variables
    NarcissusDB_PC = NarcissusDB_PC or {};  --Character-specific Variables;
    NarcissusDB_PC.EquipmentSetDB = NarcissusDB_PC.EquipmentSetDB or {};

    NarcissusDB.MinimapButton = NarcissusDB.MinimapButton or {};
    NarcissusDB.MinimapButton.Position = NarcissusDB.MinimapButton.Position or rad(150);

    if (not NarcissusDB.Version) or (type(NarcissusDB.Version) ~= "number") then    --Used for showing patch notes when opening Narcissus after an update
        NarcissusDB.Version = 10000;
    end

    if (not NarcissusDB.PhotoModeButton) or (type(NarcissusDB.PhotoModeButton) ~= "table") then
        NarcissusDB.PhotoModeButton = {};
    end

    if NarcissusDB.PhotoModeButton.HideTexts == nil then
        NarcissusDB.PhotoModeButton.HideTexts =  true;
    end

    ---------------------
    ------Preference-----
    ---------------------    
    for k, v in pairs(DefaultValue) do
        if NarcissusDB[k] == nil then
            NarcissusDB[k] = v;
        end
    end

    ---------------------
    ----Per Character----
    ---------------------
    if NarcissusDB_PC.UseAlias == nil then
        NarcissusDB_PC.UseAlias = false;
    end

    if NarcissusDB_PC.PlayerAlias == nil then
        NarcissusDB_PC.PlayerAlias = "";
    end

    --
    NarcissusDB.Tutorials = NarcissusDB.Tutorials or {};
    local Tutorials = NarcissusDB.Tutorials;
    for _, v in pairs(TutorialInclude) do
        if Tutorials[v] == nil then
            Tutorials[v] = true;   --True ~ will show tutorial
        end
    end
end

local initialize = CreateFrame("Frame");
initialize:RegisterEvent("ADDON_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "Narcissus" then
            Initialize_NarcissusDB();
            self:UnregisterEvent("ADDON_LOADED");
        end
    end
end)