local _, addon = ...

local L = Narci.L;
local After = C_Timer.After;
local C_MythicPlus = C_MythicPlus;
local C_ChallengeMode = C_ChallengeMode;
local NarciAPI = NarciAPI;
local WrapNameWithClassColor = NarciAPI.WrapNameWithClassColor;
local ConvertHexColorToRGB = NarciAPI.ConvertHexColorToRGB;
local SmartSetName = NarciAPI.SmartSetName;
local UpdateTabButtonVisual = addon.UpdateTabButtonVisual;

local MAP_FILE_PREFIX = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\Maps\\";
local BLUR_FILE_PREFIX = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\BlurredMaps\\";

local AFFIX_TYRANNICAL;     --9
local AFFIX_FORTIFIED;      --10

local MainFrame;

local mapUIInfo = {
    [375] = {name = 'mists-of-tirna-scithe', color = '2f1d1b', barColor='6273f4'};
    [376] = {name = 'the-necrotic-wake', color = '30583f', barColor = '63c29a'};
    [377] = {name = 'de-other-side', color = '3b224c', barColor = '8240e8'};
    [378] = {name = 'halls-of-atonement', color = '2b172d', barColor = 'd80075'};
    [379] = {name = 'plaguefall', color = '3c4d32', barColor = '6fd54f'};
    [380] = {name = 'sanguine-depths', color = '421d1b', barColor = 'f73b39'};
    [381] = {name = 'spires-of-ascension', color = '345572', barColor = '85c5ff'};
    [382] = {name = 'theater-of-pain', color = '1d4938', barColor = '83c855'};
};

local function FormatDuration(seconds)
    seconds = (seconds and tonumber(seconds)) or 0;
    local minutes = math.floor(seconds / 60);
    local restSeconds = seconds - minutes * 60;
    if restSeconds < 10 then
        restSeconds = "0"..restSeconds;
    end
    if minutes < 10 then
        minutes = "0"..minutes;
    end
    return string.format("%s:%s", minutes, restSeconds);
end

local function CacheAffixNames()
    if not AFFIX_TYRANNICAL then
        AFFIX_TYRANNICAL = C_ChallengeMode.GetAffixInfo(9);
        return false
    end
    if not AFFIX_FORTIFIED then
        AFFIX_FORTIFIED = C_ChallengeMode.GetAffixInfo(10);
        return false
    end
    return true
end

local function SharedOnMouseDown(self, button)
    if button == "RightButton" then
        MainFrame:ToggleMapDetail(false);
    end
end


local DataProvider = {};
DataProvider.mapRecords = {};
DataProvider.mapNames = {};
DataProvider.mapTimers = {};
DataProvider.mapIDs = {};   --Map with record

function DataProvider:GetSeasonBestForMap(mapID)
    if not self.mapRecords[mapID] then
        self.mapRecords[mapID] = {};
    end
    local data = self.mapRecords[mapID];
    if data.isCached then
        return data.intimeInfo, data.overtimeInfo, true
    else
        local intimeInfo, overtimeInfo =  C_MythicPlus.GetSeasonBestForMap(mapID);
        if intimeInfo or overtimeInfo then
            data.intimeInfo = intimeInfo;
            data.overtimeInfo = overtimeInfo;
            local memberInfoReady = false;
            if intimeInfo then
                if intimeInfo.members and #intimeInfo.members >= 5 then
                    memberInfoReady = true;
                end
            end
            if overtimeInfo then
                if overtimeInfo.members and #overtimeInfo.members >= 5 then
                    memberInfoReady = memberInfoReady and true;
                else
                    memberInfoReady = false;
                end
            end
            if memberInfoReady then
                data.isCached = true;
            end
        end
        return intimeInfo, overtimeInfo, data.isCached
    end
end

function DataProvider:CacheMapUIInfo(mapID)
    local name, id, timeLimit, texture = C_ChallengeMode.GetMapUIInfo(mapID);
    if name then
        if not self.mapNames[mapID] then
            self.mapNames[mapID] = name;
        end
    end
    if timeLimit then
        if not self.mapTimers[mapID] then
            self.mapTimers[mapID] = timeLimit;
        end
    end
end

function DataProvider:GetMapName(mapID)
    if self.mapNames[mapID] then
        return self.mapNames[mapID];
    end

    self:CacheMapUIInfo(mapID);
    return self.mapNames[mapID];
end

function DataProvider:GetMapTimer(mapID)
    if self.mapTimers[mapID] then
        return self.mapTimers[mapID];
    end

    self:CacheMapUIInfo(mapID);
    return self.mapTimers[mapID];
end

function DataProvider:GetMapTexture(mapID, blurred)
    if mapID and mapUIInfo[mapID] then
        if blurred then
            return BLUR_FILE_PREFIX.. mapUIInfo[mapID].name
        else
            return MAP_FILE_PREFIX.. mapUIInfo[mapID].name
        end
    end
end

function DataProvider:GetPageByMapID(mapID)
    for page, id in pairs(self.mapIDs) do
        if id == mapID then
            return page
        end
    end
    return 0
end

function DataProvider:GetMapIDByOrder(page)
    return self.mapIDs[page];
end

function DataProvider:SetMapComplete(mapID)
    tinsert(self.mapIDs, mapID);
    self.numCompleteMaps = #self.mapIDs;
end


NarciMythicPlusAffixFrameMixin = {};

function NarciMythicPlusAffixFrameMixin:OnEnter()
    self.Icon:SetVertexColor(1, 1, 1);

    local name, description, icon = C_ChallengeMode.GetAffixInfo(self.affixID);
    local tp = NarciGameTooltip;
    tp:Hide();
    tp:SetOwner(self, "ANCHOR_NONE");
    tp:SetText(name);
    tp:AddLine(description, 1, 1, 1, true);
    tp:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
    tp:Show();
end

function NarciMythicPlusAffixFrameMixin:OnLeave()
    self.Icon:SetVertexColor(0.8, 0.8, 0.8);
    NarciGameTooltip:Hide();
end

function NarciMythicPlusAffixFrameMixin:OnMouseDown(button)
    SharedOnMouseDown(nil, button);
end

function NarciMythicPlusAffixFrameMixin:SetByID(affixID)
    self.affixID = affixID;
    if affixID then
        local name, description, icon = C_ChallengeMode.GetAffixInfo(affixID);
        self.Icon:SetTexture(icon);
        if self:IsMouseOver() then
            self:OnEnter();
        else
            self:OnLeave();
        end
        self:Show();
    else
        self:Hide();
    end
end


NarciMythicPlusRatingCardMixin = {};

function NarciMythicPlusRatingCardMixin:LoadMap(mapID)
    if mapID ~= self.mapID and mapUIInfo[mapID] then
        self.MapTexture:SetTexture( MAP_FILE_PREFIX.. (mapUIInfo[mapID].name) );
        local r, g, b = unpack(ConvertHexColorToRGB(mapUIInfo[mapID].color));
        self.Background:SetColorTexture(r, g, b);
    end
end

function NarciMythicPlusRatingCardMixin:SetUpByMapID(mapID)
    self.mapID = mapID;
    local affixScores, overallScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID);
    local objects = {self.Level1, self.Duration1, self.Level2, self.Duration2};
    local mapName = DataProvider:GetMapName(mapID);
    self.MapName:SetText(mapName);

    if (overallScore and overallScore > 0) and (affixScores and #affixScores > 0) then
        local name, duration, overTime, level, score;
        local info1, info2;
        if #affixScores == 1 then
            name = affixScores[1].name;
            if name == AFFIX_TYRANNICAL then
                info1 = affixScores[1];
            else
                info2 = affixScores[1];
            end
        else
            info1 = affixScores[1];
            info2 = affixScores[2];
        end
        local info = {info1, info2};
        local data, v;
        for i = 1, 2 do
            data = info[i];
            if data then
                name = data.name;
                duration = data.durationSec;
                level = data.level;
                overTime = data.overTime;
                if overTime then
                    v = 0.6;
                else
                    v = 0.92;
                end
                objects[i*2 - 1]:SetText(level);
                objects[i*2 - 1]:SetTextColor(v, v, v, 0.9);
                objects[i*2]:SetText( FormatDuration(duration) );
                objects[i*2]:SetTextColor(v, v, v);
                objects[i*2 - 1]:Show();
                objects[i*2]:Show();
            else
                objects[i*2 - 1]:Hide();
                objects[i*2]:Hide();
            end
        end

        local scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore);
        if (not scoreColor) then
            scoreColor = HIGHLIGHT_FONT_COLOR;
        end
        self.Score:SetText(overallScore);
        self.Score:SetTextColor(scoreColor.r, scoreColor.g, scoreColor.b);
        self.Score:Show();
        self.ScoreBound:Show();
        self.MapTexture:SetDesaturation(0);
        self.MapTexture:SetVertexColor(1, 1, 1);
        self.Header:SetDesaturation(0);
        self.GreyBackground:Hide();
        self.NoRecordLabel:Hide();
        self:Enable();
        DataProvider:SetMapComplete(mapID);
    else
        self:SetEmpty();
    end
end

function NarciMythicPlusRatingCardMixin:SetEmpty()
    self.Score:Hide();
    self.ScoreBound:Hide();
    self.Level1:Hide();
    self.Duration1:Hide();
    self.Level2:Hide();
    self.Duration2:Hide();
    self.MapTexture:SetDesaturation(1);
    self.MapTexture:SetVertexColor(0.6, 0.6, 0.6);
    self.Header:SetDesaturation(1);
    self.GreyBackground:Show();
    self.NoRecordLabel:Show();
    self:Disable();
end

function NarciMythicPlusRatingCardMixin:SetRecord(mapScore, level, duration, overTime)
    local v;
    if overTime then
        v = 0.5;
    else
        v = 0.92;
    end
    self.Level1:SetText(level);
    self.Level1:SetTextColor(v, v, v, 0.9);
    self.Level1:Show();
    self.Duration1:SetText( FormatDuration(duration) );
    self.Duration1:SetTextColor(v, v, v);
    self.Duration1:Show();

    local scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(mapScore);
    if (not scoreColor) then
        scoreColor = HIGHLIGHT_FONT_COLOR;
    end
    self.Score:SetText(mapScore);
    self.Score:SetTextColor(scoreColor.r, scoreColor.g, scoreColor.b);
    self.Score:Show();

    self.ScoreBound:Show();
    self.MapTexture:SetDesaturation(0);
    self.MapTexture:SetVertexColor(1, 1, 1);
    self.Header:SetDesaturation(0);
    self.Level2:Hide();
    self.Duration2:Hide();
    self.GreyBackground:Hide();
    self.NoRecordLabel:Hide();
    self:Enable();
end

function NarciMythicPlusRatingCardMixin:OnEnter()
    self.BlackOverlay:Hide();
end

function NarciMythicPlusRatingCardMixin:OnLeave()
    self.BlackOverlay:Show();
end

function NarciMythicPlusRatingCardMixin:OnClick()
    MainFrame:SetMapDetail(self.mapID);
    MainFrame:ToggleMapDetail(true);
end


local function MapDetail_OnMouseWheel(self, delta)
    if delta > 0 then
        if self.page > 1 then
            self.page = self.page - 1;
        else
            return
        end
    elseif delta < 0 then
        if self.page < DataProvider.numCompleteMaps then
            self.page = self.page + 1;
        else
            return
        end
    end
    self.LeftArrow:SetShown(self.page ~= 1);
    self.RightArrow:SetShown(self.page ~= DataProvider.numCompleteMaps);
    local mapID = DataProvider:GetMapIDByOrder(self.page);
    if mapID then
        MainFrame:SetMapDetail(mapID);
    end
end

local dyamicEvents = {"CHALLENGE_MODE_MAPS_UPDATE", "CHALLENGE_MODE_MEMBER_INFO_UPDATED", "CHALLENGE_MODE_LEADERS_UPDATE"};

NarciMythicPlusDisplayMixin = {};

function NarciMythicPlusDisplayMixin:OnLoad()
    MainFrame = self;
    self.t = 0;
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
    self.requireUpdate = true;
    self.requireNewHistory = true;
    local height = 24 * 14;
    self:SetHeight(height);
    self.MapDetail:SetHeight(height);

    self.MapDetail.Header:SetVertexColor(0.5, 0.5, 0.5);
end

function NarciMythicPlusDisplayMixin:OnEvent(event)
    if event == "CHALLENGE_MODE_COMPLETED" then
        self.requireUpdate = true;
        self.requireNewHistory = true;
    elseif event == "CHALLENGE_MODE_LEADERS_UPDATE" then
        if not self.pauseUpdate then
            self.pauseUpdate = true;
            After(0.5, function()
                self:PostUpdate();
                self.pauseUpdate = nil;
            end);
        end
    elseif event == "CHALLENGE_MODE_MEMBER_INFO_UPDATED" then
        self.memberInfoReady = true;
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        if UnitLevel("player") ~= GetMaxLevelForPlayerExpansion() then
            Narci_NavBar:ToggleTabButtonByIndex(4, false);
        end
    end
end

function NarciMythicPlusDisplayMixin:OnShow()
    for _, event in pairs(dyamicEvents) do
        self:RegisterEvent(event);
    end
    if self.requireUpdate then
        self:RequestUpdate();
    end
end

function NarciMythicPlusDisplayMixin:OnHide()
    for _, event in pairs(dyamicEvents) do
        self:UnregisterEvent(event);
    end
    self:SetScript("OnUpdate", nil);
end

function NarciMythicPlusDisplayMixin:Init()
    local OFFSET_Y= -24;

    if not self.maps then
        --self.maps = C_ChallengeMode.GetMapTable();
        self.maps = {376, 381, 379, 382, 375, 377, 378, 380};
    end
    if not self.Cards then
        self.Cards = {};
    end
    self.Map2Cards = {};

    local numMaps = #self.maps;
    local card;
    local row, col = 0, 0;
    local container = self.CardContainer;
    for i = 1, numMaps do
        card = self.Cards[i];
        if not card then
            card = CreateFrame("Button", nil, container, "NarciMythicPlusCompactRatingCardTemplate");
            self.Cards[i] = card;
            card:SetPoint("TOPLEFT", container, "TOPLEFT", col * 160, -row * 72 + OFFSET_Y);
            col = col + 1;
            if col >= 2 then
                row = row + 1;
                col = 0;
            end
        end
        card:LoadMap(self.maps[i]);
        self.Map2Cards[self.maps[i]] = card;
    end

    if numMaps == 0 then
        numMaps = 1;
    end


    --Map Detail Frame
    self.MapDetail:SetScript("OnMouseDown", SharedOnMouseDown);
    self.MapDetail:SetScript("OnMouseWheel", MapDetail_OnMouseWheel);
    for i = 3, 0, -1 do
        local f = CreateFrame("Frame", nil, self.MapDetail, "NarciMythicPlusAffixFrameTemplate");
        f:SetPoint("TOPRIGHT", self.MapDetail.ContentBackdrop, "TOPRIGHT", -24 - i * 32, -74);
    end
    self.MapDetail.Pointer:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\TimerlinePointer", nil, nil, "TRILINEAR");

    --Create Primary Tab Buttons
    local tabNames = {
        MYTHIC_PLUS_SEASON_BEST, L["Runs"],
    };
    self.TabButtons = {};
    for i = 1, #tabNames do
      local button = CreateFrame("Button", nil, self, "NarciNavBarTabButtonTemplate");
      self.TabButtons[i] = button;
      if i == 1 then
         button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
         button:SetSelect(true);
      else
        button:SetPoint("LEFT", self.TabButtons[i - 1], "RIGHT", 0, 0);
      end
      button.maxWidth = 100;
      button.Highlight:SetVertexColor(0.5, 0.5, 0.5);
      button:SetUp(tabNames[i], i);
      button.tabFrame = self;
    end

    local grey80 =  "|TInterface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\BarBlock32:10:10:-4:0:32:32:0:32:0:32:204:204:204|t";
    local grey50 =  "|TInterface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\BarBlock32:10:10:-4:0:32:32:0:32:0:32:128:128:128|t";
    self.HistoryFrame.GraphDescription:SetText(grey80..L["Complete In Time"].."    "..grey50..L["Complete Over Time"]);

    self.Init = nil;
end

function NarciMythicPlusDisplayMixin:SelectTab(tabIndex)
    if tabIndex ~= self.tabIndex then
        self.tabIndex = tabIndex;
    else
        return
    end
    for i, button in pairs(self.TabButtons) do
        button:SetSelect(tabIndex == i);
    end
    if tabIndex == 1 then
        self.CardContainer:Show();
        self.MapDetail:Hide();
        self.HistoryFrame:Hide();
    else
        self:ToggleHistory(true);
    end
end

function NarciMythicPlusDisplayMixin:RequestUpdate()
    self:GetParent():ShowLoading();

    CacheAffixNames();

    if self.Init then
        self:Init();
    end
    local numMaps = #self.maps;
    local card, mapID;

    for i = 1, numMaps do
        mapID = self.maps[i];
        C_ChallengeMode.RequestLeaders(mapID);
    end

    DataProvider.mapIDs = {};
    C_MythicPlus.RequestMapInfo();
end

function NarciMythicPlusDisplayMixin:PostUpdate()
    if not CacheAffixNames() then
        After(0.5, function()
            self:PostUpdate();
        end);
        return
    end
    local card;
    for i = 1, #self.maps do
        card = self.Cards[i];
        card:SetUpByMapID(self.maps[i]);
    end
    self.requireUpdate = false;

    local seasonID = (C_MythicPlus.GetCurrentSeason() or 6) - 4;
    --self.SeasonText:SetText(string.format(SL_SEASON_NUMBER, seasonID));
    self.CardContainer.GraphDescription:SetText(string.format("%s    %s    %s", PVP_RATING_HEADER or "Rating", AFFIX_TYRANNICAL, AFFIX_FORTIFIED));  --MYTHIC_PLUS_SEASON_BEST

    local overallScore = C_ChallengeMode.GetOverallDungeonScore();
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(overallScore);
	if (color) then
        overallScore = color:WrapTextInColorCode(overallScore);
    end
    local text = overallScore;
    local runHistory = C_MythicPlus.GetRunHistory(true, true);
    if runHistory then
        local numRuns = #runHistory;
        if numRuns > 0 then
            text = text.."     ".. Narci.L["Total Runs"] .."|cffffffff"..numRuns.."|r";
        end
    end

    Narci_NavBar.ChallengeFrame.DataText:SetText(string.format(DUNGEON_SCORE_LEADER, text));


    self:GetParent():HideLoading();
end

function NarciMythicPlusDisplayMixin:SetUnit(unit)
    unit = unit or "target";
    if not UnitExists(unit) then return end;

    if self.Init then
        self:Init();
    end
    local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit);
    local card;
    local mapID, mapName;
    local mapHasData = {};
    if summary and type(summary) == "table" then
        local runs = summary.runs;
        local currentSeasonScore = summary.currentSeasonScore;
        local mapData = {};
        if runs and #runs > 0 then
            local level, duration, mapScore, overTime;
            for _, run in pairs(runs) do
                mapID = run.challengeModeID;
                mapScore = run.mapScore;
                level = run.bestRunLevel;
                duration = math.ceil(run.bestRunDurationMS / 1000);
                overTime = not run.finishedSuccess;
                mapHasData[mapID] = true;
                card = self.Map2Cards[mapID];
                if card then
                    card:SetRecord(mapScore, level, duration, overTime);
                    mapName = DataProvider:GetMapName(mapID);
                    card.MapName:SetText(mapName);
                end
            end
        end
        for i = 1, #self.maps do
            mapID = self.maps[i];
            if not mapHasData[mapID] then
                card = self.Map2Cards[mapID];
                if card then
                    card:SetEmpty();
                    mapName = DataProvider:GetMapName(mapID);
                    card.MapName:SetText(mapName);
                end
            end
        end
    end
end

function NarciMythicPlusDisplayMixin:ToggleMapDetail(state)
    self.MapDetail:SetShown(state);
    self.CardContainer:SetShown(not state);
    self.HistoryFrame:Hide();
end

function NarciMythicPlusDisplayMixin:ToggleHistory(state)
    local f = self.HistoryFrame;
    f:SetShown(state);
    self.CardContainer:SetShown(not state);
    self.MapDetail:Hide();
    if self.requireNewHistory then
        self.requireNewHistory = false;
    else
        return
    end
    if state then
        local runHistory = C_MythicPlus.GetRunHistory(true, true);
        local numRuns = #runHistory;
        if numRuns > 0 then
            if not f.bars then
                f.bars = {};
                local bar;
                for i = 1, #self.maps do
                    bar = CreateFrame("Frame", nil, f, "NarciMythicPlusHistogrameTemplate");
                    bar:SetPoint("TOP", f, "TOP", 0, 12 - i * 32);
                    f.bars[i] = bar;
                end
            end
            local mapID;
            local mapData = {};
            for i = 1, #self.maps do
                mapID = self.maps[i];
                mapData[mapID] = {intime = 0, overtime = 0};
            end
            
            for i = 1, numRuns do
                mapID = runHistory[i].mapChallengeModeID;
                if mapData[mapID] then
                    if runHistory[i].completed then
                        mapData[mapID].intime = mapData[mapID].intime + 1;
                    else
                        mapData[mapID].overtime = mapData[mapID].overtime + 1;
                    end
                end
            end
            local maxRun = 0;
            local sum;
            for _, data in pairs(mapData) do
                sum = data.intime + data.overtime;
                if sum > maxRun then
                    maxRun = sum;
                end
            end
            local normalizedRun;
            if numRuns > 100 then
                normalizedRun = maxRun;
            elseif numRuns < 20 then
                normalizedRun = maxRun / 0.5;
            else
                normalizedRun = maxRun / (0.5 + (numRuns - 20)/160);
            end
            for i = 1, #self.maps do
                mapID = self.maps[i];
                f.bars[i]:SetData(mapID, mapData[mapID].intime, mapData[mapID].overtime, normalizedRun);
            end
            f.NoRecordLabel:Hide();
            f.GraphDescription:Show();
        else
            f.NoRecordLabel:Show();
            f.GraphDescription:Hide();
        end
    end
end

local function UpdateTimelinePointer(timeLimit, yourTime)
    local p = MainFrame.MapDetail.Pointer;
    local centeralTime = timeLimit * 0.8;
    local offsetXPerSec = 64 / (timeLimit * 0.2);
    --local maxOffset = 260;
    local offsetX = math.floor((yourTime - centeralTime) * offsetXPerSec);
    if offsetX > 130 then
        offsetX = 130
    elseif offsetX < -130 then
        offsetX = -130;
    end
    p:ClearAllPoints();
    p:SetPoint("TOP", MainFrame.MapDetail.Timeline, "BOTTOM", offsetX, 0);
    if timeLimit < yourTime then
        p:SetVertexColor(NarciAPI.GetColorPresetRGB("red"));
    else
        p:SetVertexColor(NarciAPI.GetColorPresetRGB("green"));
    end
end

local function MemberInfoCallBack_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.5 then
        self:SetScript("OnUpdate", nil);
        self:UpdateMemberInfo();
    end
end

function NarciMythicPlusDisplayMixin:RequestMemberInfo()
    self.t = 0;
    self:SetScript("OnUpdate", MemberInfoCallBack_OnUpdate);
end

function NarciMythicPlusDisplayMixin:UpdateMemberInfo()
    if self.activeMapID then
        local intimeInfo, overtimeInfo, isCached = DataProvider:GetSeasonBestForMap(self.activeMapID);
        local data = intimeInfo;
        if not data then
            return
        end
        local memberString = "";
        for j = 1, #data.members do
            memberString = memberString..WrapNameWithClassColor(data.members[j].name, data.members[j].classID, data.members[j].specID, true, -7).."   ";
        end
        SmartSetName(self.MapDetail.MemberText, memberString);
    end
end

function NarciMythicPlusDisplayMixin:SetMapDetail(mapID, useIntimeOrOvertime)
    if not mapID then return end;
    self.activeMapID = mapID;

    local f = self.MapDetail;
    f.page = DataProvider:GetPageByMapID(mapID);
    f.LeftArrow:SetShown(f.page ~= 1);
    f.RightArrow:SetShown(f.page ~= DataProvider.numCompleteMaps);

    f.Header:SetTexture(DataProvider:GetMapTexture(mapID, true));
    local intimeInfo, overtimeInfo, isCached = DataProvider:GetSeasonBestForMap(mapID);
    local data;

    --If time isn't specified, find the one that has data starting from intime data
    local fromI, toI;
    if useIntimeOrOvertime == nil then
        fromI = 1;
        toI = 2;
    else
        if useIntimeOrOvertime then
            fromI = 1;
            toI = 1;
        else
            fromI = 2;
            toI = 2;
        end
    end

    local hasData = false;
    for i = fromI, toI do
        if i == 1 then
            data = intimeInfo;
        else
            data = overtimeInfo;
        end
        if data then
            hasData = true;
            UpdateTabButtonVisual(i);
            local durationSec = data.durationSec;
            f.Duration:SetText( FormatDuration(durationSec) );
            f.Duration:SetTextColor(1, 1, 1);
            f.Level:SetText( data.level );
            f.Level:SetTextColor(1, 1, 1);
            f.MapName:SetText( DataProvider:GetMapName(mapID) );
            f.Date:SetText( FormatShortDate(data.completionDate.day, data.completionDate.month, data.completionDate.year) );
            f.Score:SetText( data.dungeonScore );
            local color = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(data.dungeonScore);
            if (not color) then
                color = HIGHLIGHT_FONT_COLOR;
            end
            f.Score:SetTextColor(color.r, color.g, color.b);

            --Time
            local timeLimit = DataProvider:GetMapTimer(mapID);
            if timeLimit then
                local plus3 = timeLimit * 0.6;
                local plus2 = timeLimit * 0.8;
                if durationSec < plus3 then
                    f.Area3:SetTextColor(1, 1, 1);
                    f.Area2:SetTextColor(0.5, 0.5, 0.5);
                    f.Area1:SetTextColor(0.5, 0.5, 0.5);
                    f.Area0:SetTextColor(0.5, 0.5, 0.5);
                elseif durationSec < plus2 then
                    f.Area2:SetTextColor(1, 1, 1);
                    f.Area3:SetTextColor(0.5, 0.5, 0.5);
                    f.Area1:SetTextColor(0.5, 0.5, 0.5);
                    f.Area0:SetTextColor(0.5, 0.5, 0.5);
                elseif durationSec < timeLimit then
                    f.Area1:SetTextColor(1, 1, 1);
                    f.Area2:SetTextColor(0.5, 0.5, 0.5);
                    f.Area3:SetTextColor(0.5, 0.5, 0.5);
                    f.Area0:SetTextColor(0.5, 0.5, 0.5);
                else
                    f.Area0:SetTextColor(1, 1, 1);
                    f.Area2:SetTextColor(0.5, 0.5, 0.5);
                    f.Area1:SetTextColor(0.5, 0.5, 0.5);
                    f.Area3:SetTextColor(0.5, 0.5, 0.5);
                end

                f.Timer1:SetText( FormatDuration(timeLimit) );
                f.Timer2:SetText( FormatDuration(plus2) );
                f.Timer3:SetText( FormatDuration(plus3) );

                --Timeline Pointer
                UpdateTimelinePointer(timeLimit, durationSec);
                f.Pointer:Show();
            else
                f.Pointer:Hide();
            end

            --Affix Frames
            for j = 1, 4 do
               f.AffixFrames[j]:SetByID(data.affixIDs[j]);
            end

            --Members
            local memberString = "";
            for j = 1, #data.members do
                memberString = memberString..WrapNameWithClassColor(data.members[j].name, data.members[j].classID, data.members[j].specID, true, -7).."   ";
            end
            SmartSetName(f.MemberText, memberString);
            if not isCached then
                self:RequestMemberInfo();
            end
            break;
        end
    end

    if not hasData then
        f.Score:SetText("--");
        f.Score:SetTextColor(0.5, 0.5, 0.5);
        f.Date:SetText("No Data");
        f.Duration:SetText("00:00");
        f.Duration:SetTextColor(0.5, 0.5, 0.5);
        f.Level:SetText("--");
        f.Level:SetTextColor(0.5, 0.5, 0.5);
        for j = 1, 4 do
            f.AffixFrames[j]:SetByID(nil);
        end
        f.MemberText:SetText("");
        f.Timer1:SetText("");
        f.Timer2:SetText("");
        f.Timer3:SetText("");
        f.Area0:SetTextColor(0.5, 0.5, 0.5);
        f.Area2:SetTextColor(0.5, 0.5, 0.5);
        f.Area1:SetTextColor(0.5, 0.5, 0.5);
        f.Area3:SetTextColor(0.5, 0.5, 0.5);
        f.Pointer:Hide();
    end
end

function NarciMythicPlusDisplayMixin:SetMapDetailInfoType(useIntimeOrOvertime)
    self:SetMapDetail(self.activeMapID, useIntimeOrOvertime);
end

NarciMythicPlusPageButtonMixin = {};

function NarciMythicPlusPageButtonMixin:OnLoad()
    self.Icon:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Competitive\\MythicPlus\\ArrowRight", nil, nil, "LINEAR");
    if self.increment == 1 then
        self.Icon:SetTexCoord(1, 0, 0, 1);
    end
    self:OnLeave();

    self:SetScript("OnLoad", nil);
    self.OnLoad = nil;
end

function NarciMythicPlusPageButtonMixin:OnEnter()
    self:SetAlpha(1);
end

function NarciMythicPlusPageButtonMixin:OnLeave()
    self:SetAlpha(0.5);
end

function NarciMythicPlusPageButtonMixin:OnMouseDown()
    self.Icon:SetPoint("CENTER", 0, -1);
end

function NarciMythicPlusPageButtonMixin:OnMouseUp()
    self.Icon:SetPoint("CENTER", 0, 0);
end

function NarciMythicPlusPageButtonMixin:OnClick()
    MapDetail_OnMouseWheel(MainFrame.MapDetail, self.increment);
end




NarciMythicPlusHistogrameMixin = {};

function NarciMythicPlusHistogrameMixin:SetData(mapID, intimeRun, overtimeRun, normalizedRun)
    intimeRun = intimeRun or 0;
    overtimeRun = overtimeRun or 0;
    local sum = normalizedRun--(intimeRun + overtimeRun);
    self.MapName:SetText(DataProvider:GetMapName(mapID));
    local r, g, b;
    if mapUIInfo[mapID] then
        r, g, b = unpack(ConvertHexColorToRGB(mapUIInfo[mapID].barColor));
    else
        r, g, b = 0.8, 0.8, 0.8;
    end
    self.MapName:SetTextColor(r, g, b);
    if intimeRun == 0 and overtimeRun == 0 then
        self.Bar1:Hide();
        self.Bar2:Hide();
        self.Count:Hide();
        self.MapName:SetTextColor(0.5, 0.5, 0.5);
        return
    end
    self.Count:Show();
    self.Count:SetText( (intimeRun + overtimeRun) );
    local maxWidth = 180 - 12;
    if intimeRun > 0 then
        local bar1Width = math.floor(maxWidth * intimeRun/sum + 0.5);
        self.Bar1:SetWidth(bar1Width);
        self.Bar1:Show();
        self.Bar1:SetVertexColor(0.8, 0.8, 0.8);
        self.Bar1:SetTexCoord(0, bar1Width/maxWidth, 0, 1);
        if overtimeRun > 0 then
            local bar2Width = math.floor(maxWidth * overtimeRun/sum + 0.5);
            self.Bar2:SetWidth(bar2Width);
            self.Bar2:Show();
            self.Bar2:SetVertexColor(0.5, 0.5, 0.5);
            self.Bar1:SetTexCoord(bar1Width/maxWidth, bar2Width/maxWidth, 0, 1);
        else
            self.Bar2:Hide();
            self.Bar2:SetWidth(0.1);
        end
    else
        local bar1Width = math.floor(maxWidth * overtimeRun/sum + 0.5);
        self.Bar1:SetWidth(bar1Width);
        self.Bar1:Show();
        self.Bar1:SetVertexColor(0.5, 0.5, 0.5);
        self.Bar1:SetTexCoord(0, bar1Width/maxWidth, 0, 1);
        self.Bar2:Hide();
        self.Bar2:SetWidth(0.1);
    end
end

--[[
    /run TestCard:SetUpByMapID(376)
C_ChallengeMode.GetMapTable()
name, id, timeLimit, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(mapID);
name, description, icon = C_ChallengeMode.GetAffixInfo

/run Narci_CompetitiveDisplay.MythicPlus:ToggleHistory(true)
--]]

--/run Narci_CompetitiveDisplay.MythicPlus:RequestUpdate();

--/run Narci_CompetitiveDisplay.MythicPlus:SetUnit();
--/script C_MythicPlus.RequestMapInfo();C_Timer.After(1, function() local runs=C_MythicPlus.GetRunHistory(true, true);print("numRuns: "..#runs)end)