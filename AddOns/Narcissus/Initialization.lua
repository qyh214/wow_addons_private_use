local DefaultValue = {
    ["DetailedIlvlInfo"] = true,
    ["IsSortedByCategory"] = true,
    ["EnableGrainEffect"] = false,
    ["ShowMinimapButton"] = true,
    ["FontHeightItemName"] = 10,
    ["GlobalScale"] = 0.8,
    ["AuotoColorTheme"] = true,
    ["ColorChoice"] = 0,
    ["EnableDoubleTap"] = false,
    ["CameraOrbit"] = true,
    ["BorderTheme"] = "Bright",
    ["TruncateText"] = false,
    ["ItemNameWidth"] = 200,
    ["FadeButton"] = false,
    ["WeatherEffect"] = true,
    ["VignetteStrength"] = 0.7,
    ["FadeMusic"] = true,
    ["AlwaysShowModel"] = false,
    ["DefaultLayout"] = 2,
    ["ShowFullBody"] = true,
    ["LetterboxEffect"] = false,
    ["LetterboxRatio"] = 2.35,
    ["AFKScreen"] = false,
    ["GemManager"] = true,
}

local TutorialInclude = {
    "CaptureButton", "NextAnimationButton", "PlayerModelLayerButton",
}
local function Initialize_NarcissusDB()
    NarcissusDB = NarcissusDB or {};
    NarcissusDB_PC = NarcissusDB_PC or {};
    NarcissusDB.MinimapButton = NarcissusDB.MinimapButton or {};
    NarcissusDB.MinimapButton.Position = NarcissusDB.MinimapButton.Position or rad(150);

    if (not NarcissusDB.Version) or (type(NarcissusDB.Version) ~= "number") then
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

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "VARIABLES_LOADED" then
        Initialize_NarcissusDB();
    end
    self:UnregisterEvent("VARIABLES_LOADED")
end)