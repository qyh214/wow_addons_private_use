--Quest Log
--[[
    C_QuestLog.GetInfo(questLogIndex);

    C_CampaignInfo.GetAvailableCampaigns()
    C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID)
    C_CampaignInfo.GetCampaignID(questID)
    C_CampaignInfo.GetCampaignInfo(campaignID)
    C_CampaignInfo.GetChapterIDs(campaignID)
    C_CampaignInfo.GetCurrentChapterID(campaignID)
    C_CampaignInfo.GetFailureReason(campaignID)
    C_CampaignInfo.GetState(campaignID)
    C_CampaignInfo.IsCampaignQuest(questID)
    C_CampaignInfo.UsesNormalQuestIcons(campaignID)
    C_LoreText.RequestLoreTextForCampaignID(campaignID)


    QuestScrollFrame.campaignHeaderFramePool
    covenantCallingsHeaderFramePool 
    headerFramePool:GetNumActive();


    ORBIT_CAMERA_MOUSE_MODE_NOTHING = 0;
    ORBIT_CAMERA_MOUSE_MODE_YAW_ROTATION = 1;
    ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION = 2;
    ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION = 3;
    ORBIT_CAMERA_MOUSE_MODE_TARGET_HORIZONTAL = 4;
    ORBIT_CAMERA_MOUSE_MODE_TARGET_VERTICAL = 5;
    ORBIT_CAMERA_MOUSE_MODE_ZOOM = 6;
    ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL = 7;
    ORBIT_CAMERA_MOUSE_PAN_VERTICAL = 8;

    campaignID:
    1 Alliance
    2 Horde
    3 Test

    125 Shadowlands Campaign 0/2    Through the Shattered Sky/ Arrival in the Shadowlands
    131 Threads of Fate 0/5
    126 The Looming Dark    Choose Covenant
    
    114 Bastion 0/7 Eternity's Call Tidings of War
    118 Blade of the Primus 0/7 Champion of Pain / The Empty Throne
    124 The Groves of Ardenweald 0/8 Welcome to Ardenweald / Awaken the Dreamer
    111 The Master of Revendreth 0/7 Welcome to Revendreth / The Master of Lies

    113 Venthyr Campaign
    115 Art of War  Maldraxxus
--]]

local After = C_Timer.After;
local strsplit = strsplit;
local strtrim = strtrim;
local sin = math.sin;
local cos = math.cos;
local pi = math.pi;
local pow = math.pow;
local abs = math.abs;

local function outQuart(t, b, e, d)
    t = t / d - 1;
    return (b - e) * (pow(t, 4) - 1) + b
end

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

local MainFrame;
local LoreBook = CreateFrame("Frame");


local DataProvider = {};
DataProvider.contents = {};
DataProvider.headers = {};
DataProvider.comparisonMode = false;

function DataProvider:GetCampaignIDFromQuestLog()
    local questLogIndex = 1;
    local info = C_QuestLog.GetInfo(questLogIndex);
    if info and info.campaignID then
        print("CampaignID: "..info.campaignID);
        return info.campaignID
    end
end

function DataProvider:RequestLoreText(campaignID)
    if campaignID then
        LoreBook:RegisterEvent("LORE_TEXT_UPDATED_CAMPAIGN");
        C_LoreText.RequestLoreTextForCampaignID(campaignID);
    end
end

function DataProvider:Initialize()
    local campaignID = self:GetCampaignIDFromQuestLog();
    if not campaignID then
        if UnitFactionGroup("player") == "Alliance" then
            campaignID = 1;
        else
            campaignID = 2;
        end
    end
    if campaignID then
        self:RequestLoreText(campaignID);
    end
end

local tempEntries;

function DataProvider:UpdateEntries(textEntries)
    --One update per second
    --start from 0.5s after the event fires
    tempEntries = textEntries;
    if self.pauseUpdate then
        --print("Update Paused");
        return
    else
        self.pauseUpdate = true;
        After(0.5, function()
            --print("Start Update");
            self:FormatEntries(tempEntries);
            self.pauseUpdate = nil;
            tempEntries = nil;
        end);
    end
end

function DataProvider:FormatEntries(textEntries)
    LoreBook:UnregisterEvent("LORE_TEXT_UPDATED_CAMPAIGN");

    if not textEntries or type(textEntries) ~= "table" then
        return
    end

    local headerText = " ";
    local rawText, tempTable;
    local index = 1;
    local uiOrder = 0;
    local comparisonMode = self.comparisonMode;

    for i = 1, #textEntries do
        rawText = textEntries[i].text;
        if textEntries[i].isHeader then
            headerText = rawText;
            if not self.contents[headerText] then
                self.contents[headerText] = {};
            end
            uiOrder = uiOrder + 1;
            self.contents[headerText].uiOrder = uiOrder;
            self.headers[uiOrder] = headerText;
            index = 1;
        else
            --print("Header: "..headerText);
            if headerText and self.contents[headerText] then
                tempTable = {strsplit("\n", rawText)};
                for j = 1, #tempTable do
                    tempTable[j] = strtrim(tempTable[j]);
                    if tempTable[j] ~= "" then
                        if comparisonMode then
                            if not self.contents[headerText][index] then
                                self.contents[headerText][index] = {text = tempTable[j], isNew = true};
                                NarciLoreAlert:SetUp(headerText, uiOrder);
                            end
                        else
                            self.contents[headerText][index] = {text = tempTable[j], isNew = false};
                        end
                        index = index + 1;
                    end
                end
            end
        end
    end
    if not self.comparisonMode then
        self.comparisonMode = true;
        MainFrame:ShowPage(1);
    end
    
    MainFrame.numChapters = uiOrder;
end

function DataProvider:GetChapterTexts(index)
    local headerText = self.headers[index];
    if headerText then
        return headerText, self.contents[headerText]
    end
end

local function PrintLoreTable(textEntries)
    for i = 1, #textEntries do
        if textEntries[i].isHeader then
            textEntries[i].text = "|cFFFFD100".. textEntries[i].text .. "|r";
        end
        --print(textEntries[i].text);
    end
end


LoreBook:RegisterEvent("PLAYER_ENTERING_WORLD");
LoreBook:RegisterEvent("QUEST_TURNED_IN");
--LoreBook:RegisterEvent("QUEST_ACCEPTED");

LoreBook:SetScript("OnEvent", function(self, event, ...)
    if event == "LORE_TEXT_UPDATED_CAMPAIGN" then
        local campaignID, textEntries = ...;
        TEXTENRY = textEntries
        DataProvider:UpdateEntries(textEntries);
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        DataProvider:Initialize();
    elseif event == "QUEST_TURNED_IN" then
        local questID = ...;
        if questID and C_CampaignInfo.IsCampaignQuest(questID) then
            --print("QuestID: "..questID)
            After(0.5, function()
                local campaignID = C_CampaignInfo.GetCampaignID(questID);
                DataProvider:RequestLoreText(campaignID)
            end)
        end
    end
    --print(event)
end);


local AssetPool = {};

function AssetPool:GetObject(parentFrame)
    if not self.pool then
        self.pool = {};
    end
    for i = 1, #self.pool do
        if not self.pool[i]:IsShown() then
            self.pool[i]:SetParent(parentFrame);
            self.pool[i]:Show();
            return self.pool[i];
        end
    end

    local newObject = parentFrame:CreateFontString(nil, "OVERLAY", self.template, 0);
    tinsert(self.pool, newObject);
    return newObject;
end

function AssetPool:Recycle()
    if self.pool then
        for i = 1, #self.pool do
            if self.pool[i].unused then
                self.pool[i]:Hide();
                self.pool[i]:ClearAllPoints();
            end
        end
    end
end

function AssetPool:ReleaseAll()
    if self.pool then
        for i = 1, #self.pool do
            self.pool[i]:Hide();
            self.pool[i]:ClearAllPoints();
        end
    end
end

local HeaderPool = CreateFromMixins(AssetPool);
HeaderPool.template = "NarciLoreBookHeaderTemplate";
local TextPool = CreateFromMixins(AssetPool);
TextPool.template = "NarciLoreBookTextTemplate";


local AnimPage = NarciAPI_CreateAnimationFrame(0.5);

AnimPage:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    local x = self.easeFunc(self.total, self.fromX, self.toX, self.duration);
    local width = self.easeFunc(self.total, 342, 0.01, self.duration);
    local ratio = self.total/self.duration;
    local alpha1 = 2 - 2*ratio;
    local alpha2;
    if ratio <= 0.5 then
        alpha2 = ratio;
        if alpha2 > 1 then
            alpha2 = 1;
        end
    else
        alpha2 = 1 - ratio;
        if alpha2 < 0 then
            alpha2 = 0;
        end
    end
    if alpha1 > 1 then
        alpha1 = 1;
    elseif alpha1 < 0 then
        alpha1 = 0;
    end
    if self.total >= self.duration then
        x = self.toX;
        alpha1 = 0;
        self:Hide();
    end
    self.movingPage:SetPoint(self.point, self.relativeTo, self.relativePoint, x, 0);
    self.movingPage:SetWidth(342 - width);
    self.movingPage.ClipFrame.CurveShadow:SetAlpha(alpha1);
    self.movingPage.RightShadow:SetAlpha(alpha2);
    self.movingPage.LeftShadow:SetAlpha(alpha2);
    self.topPage:SetWidth(width);
end);

function AnimPage:PlayPage(movingPage, topPage)
    if self:IsShown() then
        return
    end

    self.movingPage = movingPage;
    self.topPage = topPage;
    self.point, self.relativeTo, self.relativePoint = movingPage:GetPoint();
    local isRightPage = movingPage.isRightPage;
    if isRightPage then
        self.duration = 0.4;
        self.easeFunc = outSine;
        self.fromX = -342;
        self.toX = 342;
        self.next = false;
    else
        self.duration = 0.5;
        self.easeFunc = inOutSine;
        self.fromX = 342;
        self.toX = -342;
        self.next = true;
    end
    self:Show();
end


local FormatUtil = {};
local strsub = strsub;
function FormatUtil:GetTruncatedText(fontString, text)
    if fontString:IsTruncated() then
        local x = fontString:GetRight();
        local y = fontString:GetBottom();
        local characterIndex, isInside = fontString:FindCharacterIndexAtCoordinate(x, y);   --causing FPS drop, no solutions
        local tempText = text or fontString:GetText();
        fontString:SetText(strsub(tempText, 1, characterIndex - 1))
        return strsub(tempText, characterIndex);
    end
end


NarciLoreBookMixin = {};

function NarciLoreBookMixin:OnLoad()
    MainFrame = self;
    self.page = 1;
    self:SetPadding(32);
    self:ResetPageLevel(-1);
    tinsert(UISpecialFrames, self:GetName());
end

function NarciLoreBookMixin:SetPadding(value)
    self.padding = value;
    self.textWidth = 342 - 2 * value;
end

function NarciLoreBookMixin:OnMouseWheel(delta)
    --Pause update during page turning
    if AnimPage:IsShown() then
        return
    end

    if delta < 0 then
        if self.page < self.numChapters then
            self.page = self.page + 1;
        else
            return
        end
    else
        if self.page > 1 then
            self.page = self.page - 1;
        else
            return
        end
    end

    self:FlipPage(delta);
end

local function SetMirrorAnchor(frame, mirrorMode)
    local frameWitdh = frame:GetWidth();
    if not frameWitdh then return end

    local point, relativeTo, relativePoint, x, y = frame:GetPoint();
    frame:ClearAllPoints();
    if frame.isRightPage then
        if mirrorMode then
            frame:SetPoint("RIGHT", relativeTo, relativePoint, 342, y);
            frame.anchorToRight = false;
        else
            frame:SetPoint("LEFT", relativeTo, relativePoint, 0, y);
            frame.anchorToRight = true;
        end
    else
        if mirrorMode then
            frame:SetPoint("LEFT", relativeTo, relativePoint, -342, y);
            frame.anchorToRight = false;
        else
            frame:SetPoint("RIGHT", relativeTo, relativePoint, 0, y);
            frame.anchorToRight = true;
        end     
    end
end


function NarciLoreBookMixin:ResetPageLevel(direction)
    local baseLevel = self:GetFrameLevel();
    local topPageRight, topPageLeft, bottomPageRight, bottomPageLeft;
    if self.page % 2 == 0 then
        --even number ~ full width 342 & lower level
        topPageRight = self.PageContainer.RightPage1;
        bottomPageRight = self.PageContainer.RightPage2;
        topPageLeft = self.PageContainer.LeftPage1;
        bottomPageLeft = self.PageContainer.LeftPage2;
    else
        topPageRight = self.PageContainer.RightPage2;
        bottomPageRight = self.PageContainer.RightPage1;
        topPageLeft = self.PageContainer.LeftPage2;
        bottomPageLeft = self.PageContainer.LeftPage1;
    end
    
    if not direction or direction < 0 then
        topPageRight:SetFrameLevel(baseLevel + 2);
        bottomPageRight:SetFrameLevel(baseLevel + 1);
        topPageLeft:SetFrameLevel(baseLevel + 4);
        bottomPageLeft:SetFrameLevel(baseLevel + 3);
        SetMirrorAnchor(topPageRight, false);
        SetMirrorAnchor(bottomPageRight, true);
        SetMirrorAnchor(bottomPageLeft, false);
        SetMirrorAnchor(topPageLeft, true);
        self:SetTextAnchorToRight(topPageRight, false);
        self:SetTextAnchorToRight(bottomPageRight, false);
    else
        topPageRight:SetFrameLevel(baseLevel + 4);
        bottomPageRight:SetFrameLevel(baseLevel + 3);
        topPageLeft:SetFrameLevel(baseLevel + 2);
        bottomPageLeft:SetFrameLevel(baseLevel + 1);
        bottomPageLeft:SetFrameLevel(baseLevel + 3);
        SetMirrorAnchor(topPageRight, true);
        SetMirrorAnchor(bottomPageRight, false);
        SetMirrorAnchor(bottomPageLeft, true);
        SetMirrorAnchor(topPageLeft, false);
        self:SetTextAnchorToRight(topPageRight, true);
        self:SetTextAnchorToRight(bottomPageLeft, true);
    end

    topPageRight:SetWidth(342);
    bottomPageRight:SetWidth(342);
    topPageLeft:SetWidth(342);
    bottomPageLeft:SetWidth(342);
    return topPageRight, topPageLeft, bottomPageRight, bottomPageLeft
end

function NarciLoreBookMixin:FormatExtraText(pageFrame, loreText)
    if loreText then
        local frame = pageFrame.ClipFrame --self.PageContainer[pageKey].ClipFrame;
        frame.Header:Hide();
        local Lore = frame.Lore; --TextPool:GetObject(frame);
        Lore:SetPoint("TOPLEFT", frame, "TOPLEFT", self.padding, -self.padding);
        Lore:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.padding, self.padding);
        Lore:SetWidth(self.textWidth);
        Lore:SetText(loreText);
    end
end

function NarciLoreBookMixin:SetTextAnchorToRight(pageFrame, anchorToRight)
    local frame = pageFrame.ClipFrame;
    local Header = frame.Header;
    local Lore = frame.Lore;
    local textHeight = Header:GetHeight() + 24;
    Header:ClearAllPoints();
    Lore:ClearAllPoints();
    pageFrame.anchorToRight = anchorToRight;
    if anchorToRight then
        Header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -self.padding, -self.padding);
        Lore:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -self.padding, -self.padding - textHeight);
        Lore:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -self.padding, self.padding);
    else
        Header:SetPoint("TOPLEFT", frame, "TOPLEFT", self.padding, -self.padding);
        Lore:SetPoint("TOPLEFT", frame, "TOPLEFT", self.padding, -self.padding - textHeight);
        Lore:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.padding, self.padding);
    end
end

function NarciLoreBookMixin:FormatPage(pageIndex, pageFrame, getTextOnTheNextPage)
    if not pageFrame then return end
    local headerText, contents = DataProvider:GetChapterTexts(pageIndex);
    local frame = pageFrame.ClipFrame --self.PageContainer[pageKey].ClipFrame;
    local Header = frame.Header; --HeaderPool:GetObject(frame);
    local Lore = frame.Lore;
    if contents then
        local textHeight = 0;
        --print(headerText)
        Header:ClearAllPoints();
        local anchorToRight = pageFrame.anchorToRight;
        if anchorToRight then
            Header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -self.padding, -self.padding);
        else
            Header:SetPoint("TOPLEFT", frame, "TOPLEFT", self.padding, -self.padding);
        end

        Header:SetWidth(self.textWidth);
        Header:SetText(headerText);
        textHeight = textHeight + Header:GetHeight();
        textHeight = textHeight + 24;
    
        local loreText = contents[1].text or "";
        for i = 2, #contents do
            if contents[i].text then
                loreText = loreText.."\n\n"..contents[i].text;
            end
        end
        Lore:ClearAllPoints();
        if anchorToRight then
            Lore:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -self.padding, -self.padding - textHeight);
            Lore:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -self.padding, self.padding);
        else
            Lore:SetPoint("TOPLEFT", frame, "TOPLEFT", self.padding, -self.padding - textHeight);
            Lore:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.padding, self.padding);
        end
        Lore:SetWidth(self.textWidth);
        Lore:SetText(loreText);
        
        if getTextOnTheNextPage then
            self.nextPageText = FormatUtil:GetTruncatedText(Lore, loreText);
        end
        --Debug
        LORE = Lore;
        self.LoreObject = Lore;
    else
        Header:SetText("");
        Lore:SetText("")
    end
end

function NarciLoreBookMixin:FlipPage(direction)
    --HeaderPool:ReleaseAll();
    --TextPool:ReleaseAll();

    --self:FormatPage(self.page - 1, "RightPage2");
    local page = self.page;
    local topPageRight, topPageLeft, bottomPageRight, bottomPageLeft = self:ResetPageLevel(direction);
    --self:FormatExtraText(bottomPageLeft, self.nextPageText);
    self.nextPageText = nil;

    --self.PageContainer.LeftPage1.ClipFrame.Picture:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\LoreBook\\Picture"..page);
    --self.PageContainer.LeftPage2.ClipFrame.Picture:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\LoreBook\\Picture"..(page + 1));
    if direction < 0 then
        --Next page, move right page to the left
        self:FormatPage(page, bottomPageRight, true);
        if direction ~= self.direction then
            self:FormatPage(page - 1, topPageRight, true);
            self.direction = direction;
        end
        AnimPage:PlayPage(topPageLeft, topPageRight);
    else
        --Previous page, move left page to the right
        self:FormatPage(page, topPageRight, true);
        if direction ~= self.direction then
            self:FormatPage(page + 1, bottomPageRight, true);
            self.direction = direction;
        end
        AnimPage:PlayPage(topPageRight, topPageLeft);
    end
end

function NarciLoreBookMixin:ShowPage(pageIndex, showFrame)
    self.page = pageIndex;
    local topPageRight, topPageLeft, bottomPageRight, bottomPageLeft = self:ResetPageLevel(-1);
    topPageRight:SetWidth(0.01);
    self.direction = nil;
    self:FormatPage(self.page, bottomPageRight, true);
    self:SetAlpha(1);
    if showFrame then
        self:Show();
    end
end

function NarciLoreBookMixin:GetScaledCursorPosition()
	local scale = self:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / scale, y / scale;
end

function NarciLoreBookMixin:OnMouseDown()

    --FormatUtil:GetTruncatedText(self.LoreObject)
    --print(strsub(self.LoreObject:GetText(), characterIndex))
end



NarciLoreAlertMixin = {};

function NarciLoreAlertMixin:OnLoad()
    --tinsert(UISpecialFrames, self:GetName());
end

function NarciLoreAlertMixin:OnHide()

end

function NarciLoreAlertMixin:OnClick()
    self:Hide();
    MainFrame:ShowPage(self.pageIndex, true);
end

function NarciLoreAlertMixin:SetUp(headerText, id)
    self:StopAnimating();
    self.Name:SetText(headerText);
    self.pageIndex = id;
    self:Show();
    self.fadeIn:Play();
end

--[[
NarciLoreBookModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

NarciLoreBookMixin = {};

function NarciLoreBookMixin:OnShow()
    self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);

    local sheatheWeapons = true;
    local autoDress = false;
    local itemModifiedAppearanceIDs = nil;
    SetupPlayerForModelScene(self.ModelScene, itemModifiedAppearanceIDs, sheatheWeapons, autoDress);

    local actor = self.ModelScene:GetPlayerActor();
    actor:SetSpellVisualKit(29521);
    actor:SetAnimation(520);
    ACTOR = actor
    CAM = self.ModelScene:GetActiveCamera();
    CAM.buttonModes.leftY = 2;
end

--]]