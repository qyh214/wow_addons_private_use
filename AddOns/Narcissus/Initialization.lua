local function Initialize_NarcissusDB()
    NarcissusDB = NarcissusDB or {};
    NarcissusDB_PC = NarcissusDB_PC or {};
    NarcissusDB.MinimapButton = NarcissusDB.MinimapButton or {};
    NarcissusDB.MinimapButton.Position = NarcissusDB.MinimapButton.Position or rad(150);

    if (not NarcissusDB.PhotoModeButton) or (type(NarcissusDB.PhotoModeButton) ~= "table") then
        NarcissusDB.PhotoModeButton = {};
    end

    if NarcissusDB.PhotoModeButton.HideTexts == nil then
        NarcissusDB.PhotoModeButton.HideTexts =  true;
    end

    if NarcissusDB.DetailedIlvlInfo == nil then
        NarcissusDB.DetailedIlvlInfo =  true;
    end

    if NarcissusDB.IsSortedByCategory == nil then
        NarcissusDB.IsSortedByCategory = true;
    end


    ---------------------
    ------Preference-----
    ---------------------    
    if NarcissusDB.EnableGrainEffect == nil then
        NarcissusDB.EnableGrainEffect = false;
    end

    if NarcissusDB.ShowMinimapButton == nil then
        NarcissusDB.ShowMinimapButton = true;
    end

    if NarcissusDB.FontHeightItemName == nil then
        NarcissusDB.FontHeightItemName = 10;
    end

    if NarcissusDB.GlobalScale == nil then
        NarcissusDB.GlobalScale = 1;
    end

    if NarcissusDB.AuotoColorTheme == nil then
        NarcissusDB.AuotoColorTheme = true;
    end

    if NarcissusDB.ColorChoice == nil then
        NarcissusDB.ColorChoice = 0;    --default blue
    end

    if NarcissusDB.EnableDoubleTap == nil then
        NarcissusDB.EnableDoubleTap = false;
    end

    if NarcissusDB.CameraOrbit == nil then
        NarcissusDB.CameraOrbit = true;
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
end

local initialize = CreateFrame("Frame")
initialize:RegisterEvent("VARIABLES_LOADED");
initialize:SetScript("OnEvent",function(self,event,...)
    if event == "VARIABLES_LOADED" then
        Initialize_NarcissusDB();
    end
end)